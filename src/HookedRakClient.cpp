#include "main.h"

extern unsigned int uiClientChallengeResponse;

extern stCheckpointData g_stCheckpointData;

bool HookedRakClientInterface::Connect( const char* host, unsigned short serverPort, unsigned short clientPort, unsigned int depreciated, int threadSleepTimer )
{
	traceLastFunc( "HookedRakClientInterface::Connect" );

	return g_iRakClient->GetRakClientInterface()->Connect( host, serverPort, clientPort, depreciated, threadSleepTimer );
}

void HookedRakClientInterface::Disconnect( unsigned int blockDuration, unsigned char orderingChannel )
{
	traceLastFunc( "HookedRakClientInterface::Disconnect" );

	g_iRakClient->GetRakClientInterface()->Disconnect( blockDuration, orderingChannel );
}

void HookedRakClientInterface::InitializeSecurity( const char *privKeyP, const char *privKeyQ )
{
	traceLastFunc( "HookedRakClientInterface::InitializeSecurity" );

	g_iRakClient->GetRakClientInterface()->InitializeSecurity( privKeyP, privKeyQ );
}

void HookedRakClientInterface::SetPassword( const char *_password )
{
	traceLastFunc( "HookedRakClientInterface::SetPassword" );

	g_iRakClient->GetRakClientInterface()->SetPassword( _password );
}

bool HookedRakClientInterface::HasPassword( void ) const
{
	traceLastFunc( "HookedRakClientInterface::HasPassword" );

	return g_iRakClient->GetRakClientInterface()->HasPassword();
}

bool HookedRakClientInterface::Send( const char *data, const int length, PacketPriority priority, PacketReliability reliability, char orderingChannel )
{
	traceLastFunc( "HookedRakClientInterface::Send" );

	return g_iRakClient->GetRakClientInterface()->Send( data, length, priority, reliability, orderingChannel );
}

bool bCrasherState = 0;

bool HookedRakClientInterface::Send( RakNet::BitStream * bitStream, PacketPriority priority, PacketReliability reliability, char orderingChannel )
{
	traceLastFunc( "HookedRakClientInterface::Send(BitStream)" );

	BYTE packetId;
	bitStream->Read(packetId);

	if(packetId == ID_PLAYER_SYNC && cheat_state->packet_dsbl_settings.DSBL_SND_PLAYER_SYNC) return 1;
	if(packetId == ID_UNOCCUPIED_SYNC && cheat_state->packet_dsbl_settings.DSBL_SND_UNOCCUPIED_SYNC) return 1;
	if(packetId == ID_TRAILER_SYNC && cheat_state->packet_dsbl_settings.DSBL_SND_TRAILER_SYNC) return 1;
	if(packetId == ID_PASSENGER_SYNC && cheat_state->packet_dsbl_settings.DSBL_SND_PASSENGER_SYNC) return 1;
	if(packetId == ID_SPECTATOR_SYNC && cheat_state->packet_dsbl_settings.DSBL_SND_SPECTATOR_SYNC) return 1;
	if(packetId == ID_AIM_SYNC && cheat_state->packet_dsbl_settings.DSBL_SND_AIM_SYNC) return 1;
	if(packetId == ID_VEHICLE_SYNC && cheat_state->packet_dsbl_settings.DSBL_SND_VEHICLE_SYNC) return 1;
	if(packetId == ID_WEAPONS_UPDATE && cheat_state->packet_dsbl_settings.DSBL_SND_WEAPONS_UPDATE) return 1;
	if(packetId == ID_STATS_UPDATE && cheat_state->packet_dsbl_settings.DSBL_SND_STATS_UPDATE) return 1;
	if(packetId == ID_BULLET_SYNC && cheat_state->packet_dsbl_settings.DSBL_SND_BULLET_SYNC) return 1;

	if(cheat_state->_generic.bikecrasher && (packetId == ID_PLAYER_SYNC || packetId == ID_VEHICLE_SYNC))
		return 1;

	if(packetId == ID_PLAYER_SYNC)
	{
		stOnFootData OutgoingOnFootData;
			
		bitStream->ResetReadPointer();

		bitStream->Read(packetId);
		bitStream->Read((PCHAR)&OutgoingOnFootData, sizeof(stOnFootData));

		if(cheat_state->_generic.invisible)
		{
			OutgoingOnFootData.fPosition[2] -= 15.0f;
		}

		if(cheat_state->_generic.bulletbugger)
		{
			float zero = 0;
			float infinity = 1 / zero;

			OutgoingOnFootData.fPosition[2] = infinity;
		}

		if(cheat_state->_generic.twistmode)
		{
			static float fRotation = 0.0f;

			OutgoingOnFootData.fQuaternion[0] = cosf(fRotation);
			OutgoingOnFootData.fQuaternion[3] = sinf(fRotation);

			OutgoingOnFootData.byteCurrentWeapon = 46;

			static DWORD timer = 0;
			if ( GetTickCount() - timer > 95 )
			{
				fRotation += 1.0f;
				if ( fRotation >= 360.0f ) fRotation = 0.0f;

				timer = GetTickCount();
			}

			static DWORD timer2 = 0;
			if ( GetTickCount() - timer2 > 250 )
			{
				OutgoingOnFootData.sUpDownKeys = 128;
				OutgoingOnFootData.sCurrentAnimationID = 0x3C5;
				OutgoingOnFootData.sAnimFlags = 0x1901;

				timer2 = GetTickCount();
			}
		}

		if(cheat_state->_generic.ghostmode)
		{
			OutgoingOnFootData.byteSpecialAction = 3;
		}

		if(cheat_state->_generic.rand_quats)
		{
			OutgoingOnFootData.fQuaternion[0] = random_float(-1, 1);
			OutgoingOnFootData.fQuaternion[1] = random_float(-1, 1);
			OutgoingOnFootData.fQuaternion[2] = random_float(-1, 1);
			OutgoingOnFootData.fQuaternion[3] = random_float(-1, 1);
		}
		else if(cheat_state->_generic.upside_down)
		{
			OutgoingOnFootData.fQuaternion[0] = 0;
			OutgoingOnFootData.fQuaternion[1] = 1;
			OutgoingOnFootData.fQuaternion[2] = 0;
			OutgoingOnFootData.fQuaternion[3] = 0;
		}

		if(cheat_state->_generic.slapper)
		{
			int iPlayerID = sampFindNearestPlayer();

			if(ValidPlayer(iPlayerID))
			{
				struct actor_info *self = actor_info_get( ACTOR_SELF, 0 );
				struct actor_info *ainfo = getGTAPedFromSAMPPlayerID(iPlayerID);

				float fSelfPos[3], fTargetPos[3];

				vect3_copy(&self->base.matrix[4*3], fSelfPos);
				getPlayerPos(iPlayerID, fTargetPos);

				if ( ainfo != NULL && ainfo != self )
				{
					/*
						Sync - hit the player from 4 angles (0, 90, 180, 270)
					*/

					static BYTE byteSlapperState = 0;

					WORD wHitAngle = 0;

					if(byteSlapperState == 0)
						wHitAngle = 0;

					else if(byteSlapperState == 1)
						wHitAngle = 90;

					else if(byteSlapperState == 2)
						wHitAngle = 180;

					else if(byteSlapperState == 3)
						wHitAngle = 270;

					if(byteSlapperState < 3)
						byteSlapperState++;
					else
						byteSlapperState = 0;

					vect3_copy(fTargetPos, OutgoingOnFootData.fPosition);

					float fHitAngleInRadian = wHitAngle * 0.0174532925;

					if(getPlayerState(iPlayerID) == PLAYER_STATE_DRIVER || getPlayerState(iPlayerID) == PLAYER_STATE_PASSENGER)
					{
						OutgoingOnFootData.sCurrentAnimationID = 301;

						OutgoingOnFootData.fPosition[0] += sinf(-fHitAngleInRadian) * 15;
						OutgoingOnFootData.fPosition[1] += sinf(-fHitAngleInRadian) * 15;
					}
					else
					{
						OutgoingOnFootData.sCurrentAnimationID = random(0, 1000);

						OutgoingOnFootData.fQuaternion[0] = random_float(0, 2);
						OutgoingOnFootData.fQuaternion[1] = random_float(0, 2);
						OutgoingOnFootData.fQuaternion[2] = random_float(0, 2);
						OutgoingOnFootData.fQuaternion[3] = random_float(0, 2);

						OutgoingOnFootData.fPosition[0] += sinf(-fHitAngleInRadian) * 5;
						OutgoingOnFootData.fPosition[1] += sinf(-fHitAngleInRadian) * 5;
					}

					OutgoingOnFootData.fMoveSpeed[0] = sinf(fHitAngleInRadian) * 20;
					OutgoingOnFootData.fMoveSpeed[1] = cosf(fHitAngleInRadian) * 20;

					/*
						Visualization - show the target with bullet impacts to his position.
					*/

					CVector vecOrigin = CVector(fSelfPos[0], fSelfPos[1], fSelfPos[2]);
					CVector vecDirection = CVector(fTargetPos[0], fTargetPos[1], fTargetPos[2]);

					CColPoint* pColPoint;
					CEntitySAInterface	*pCollisionEntity = NULL;

					bool bCollision = GTAfunc_ProcessLineOfSight( &vecOrigin, &vecDirection, &pColPoint, &pCollisionEntity, 0, 0, 0, 0, 0, 0, 0, 0 );
					pPedSelf->GetWeapon(pPedSelf->GetCurrentWeaponSlot())->DoBulletImpact(0, 0, &vecOrigin, &vecDirection, 0, 0);
				}
			}
		}

		if(g_bPlayerCopierToggle)
		{
			if(ValidPlayer(g_iPlayerCopierTarget) && getPlayerState(g_iPlayerCopierTarget) == PLAYER_STATE_ONFOOT)
			{
				float fTargetPos[3];
				int bGotTargetPos = getPlayerPos(g_iPlayerCopierTarget, fTargetPos);

				if(bGotTargetPos)
				{
					OutgoingOnFootData.fPosition[0] = fTargetPos[0] + g_fPlayerCopierFollowOffset[0];
					OutgoingOnFootData.fPosition[1] = fTargetPos[1] + g_fPlayerCopierFollowOffset[1];
					OutgoingOnFootData.fPosition[2] = fTargetPos[2] + g_fPlayerCopierFollowOffset[2];
				}
			}
		}

		bitStream->Reset();

		bitStream->Write((BYTE)ID_PLAYER_SYNC);
		bitStream->Write((PCHAR)&OutgoingOnFootData,sizeof(stOnFootData));
	}

	if(packetId == ID_VEHICLE_SYNC)
	{
		static bool bTrainCrasherState = 0;
		static DWORD dwLastTrainCrasherStateChange = GetTickCount();

		stInCarData OutgoingInCarData;
			
		bitStream->ResetReadPointer();

		bitStream->Read(packetId);
		bitStream->Read((PCHAR)&OutgoingInCarData, sizeof(stInCarData));

		if(cheat_state->_generic.itroll != 0 && cheat_state->state == CHEAT_STATE_VEHICLE && KEY_DOWN(VK_LBUTTON))
		{
			cheat_iTroll(&OutgoingInCarData);
		}
		else
		{
			if(cheat_state->_generic.invisible)
			{
				OutgoingInCarData.fPosition[2] -= 20.0f;
			}

			if(cheat_state->_generic.traincrasher)
			{
				if(bTrainCrasherState)
				{
					OutgoingInCarData.fPosition[0] += 5000.0f;
					OutgoingInCarData.fPosition[1] += 5000.0f;
				}
				else
				{
					float zero = 0;
					float infinity = 1 / zero;
					float nan = infinity / infinity;

					OutgoingInCarData.fPosition[2] = nan;
				}

				if(GetTickCount() - dwLastTrainCrasherStateChange >= 3000)
				{
					bTrainCrasherState ^= 1;

					dwLastTrainCrasherStateChange = GetTickCount();
				}
			}

			if(cheat_state->_generic.rand_quats)
			{
				OutgoingInCarData.fQuaternion[0] = random_float(-1, 1);
				OutgoingInCarData.fQuaternion[1] = random_float(-1, 1);
				OutgoingInCarData.fQuaternion[2] = random_float(-1, 1);
				OutgoingInCarData.fQuaternion[3] = random_float(-1, 1);
			}
			else if(cheat_state->_generic.upside_down)
			{
				OutgoingInCarData.fQuaternion[0] = 0;
				OutgoingInCarData.fQuaternion[1] = 1;
				OutgoingInCarData.fQuaternion[2] = 0;
				OutgoingInCarData.fQuaternion[3] = 0;
			}
		}

		bitStream->Reset();

		bitStream->Write((BYTE)ID_VEHICLE_SYNC);
		bitStream->Write((PCHAR)&OutgoingInCarData,sizeof(stInCarData));
	}

	if(packetId == ID_AIM_SYNC)
	{
		stAimData OutgoingAimData;

		bitStream->ResetReadPointer();

		bitStream->Read(packetId);
		bitStream->Read((PCHAR)&OutgoingAimData, sizeof(stAimData));

		if(cheat_state->_generic.weaponcrasher)
		{
			OutgoingAimData.vecAimPos[2] = pow(10.f + random_float(0, 1), random_float(6, 9))*(int)random(-1, 1) * 3;
			OutgoingAimData.byteCamMode = 53;
			OutgoingAimData.byteWeaponState = WS_MORE_BULLETS;
		}

		if(cheat_state->_generic.invalid_aimz)
		{
			OutgoingAimData.fAimZ = sqrt((float)-1);
		}

		if(cheat_state->_generic.shaking_camera)
		{
			BYTE bNums[] = {34, 45}; // Invalid byteCamMode IDs

			OutgoingAimData.byteCamMode = bNums[random(0, sizeof(bNums))];
			OutgoingAimData.byteWeaponState = WS_MORE_BULLETS;
		}

		bitStream->Reset();

		bitStream->Write((BYTE)ID_AIM_SYNC);
		bitStream->Write((PCHAR)&OutgoingAimData,sizeof(stAimData));
	}

	if ( packetId == ID_BULLET_SYNC )
	{
		if(cheat_state->_generic.bulletcrasher_p || cheat_state->_generic.bulletcrasher_v)
		{
			stBulletData OutgoingBulletData;

			bitStream->Read((PCHAR)&OutgoingBulletData, sizeof(stBulletData));

			if((cheat_state->_generic.bulletcrasher_p && OutgoingBulletData.bHitType == BULLET_HIT_TYPE_PLAYER) || (cheat_state->_generic.bulletcrasher_v && OutgoingBulletData.bHitType == BULLET_HIT_TYPE_VEHICLE))
			{
				OutgoingBulletData.fCenterOfHit[0] = (float)0x7FFFFFFF;
				OutgoingBulletData.fCenterOfHit[1] = (float)0x7FFFFFFF;
				OutgoingBulletData.fCenterOfHit[2] = (float)0x7FFFFFFF;
			}

			bitStream->Reset();

			bitStream->Write((BYTE)ID_BULLET_SYNC);
			bitStream->Write((PCHAR)&OutgoingBulletData,sizeof(stBulletData));
		}
		else
		{
			if(cheat_state->_aimbot.playerAiming == true && cheat_state->_aimbot.silentAIMsafe == true && cheat_state->_aimbot.silentAimbot == true)
			{
				stBulletData OutgoingBulletData;

				bitStream->Read((PCHAR)&OutgoingBulletData, sizeof(stBulletData));

				cheat_handle_silent_aim(&OutgoingBulletData);

				bitStream->Reset();

				bitStream->Write((BYTE)ID_BULLET_SYNC);
				bitStream->Write((PCHAR)&OutgoingBulletData,sizeof(stBulletData));
			}

			if(cheat_state->_generic.shotrepeater > 0)
			{
				for(int x = 0; x < cheat_state->_generic.shotrepeater; x++)
					g_iRakClient->Send(bitStream, HIGH_PRIORITY, UNRELIABLE_SEQUENCED, 0);
			}
		}
	}

	if(cheat_state->_generic.log_packet_send)
	{
		Log( "< [Packet Send] id: %d, len: %d", packetId, bitStream->GetNumberOfBytesUsed() );
		addMessageToChatWindow( "< [Packet Send] id: %d, len: %d", packetId, bitStream->GetNumberOfBytesUsed() );
	}

	return g_iRakClient->GetRakClientInterface()->Send( bitStream, priority, reliability, orderingChannel );
}

Packet* HookedRakClientInterface::Receive( void )
{
	traceLastFunc( "HookedRakClientInterface::Receive" );

	Packet* ReceivedPacket = g_iRakClient->GetRakClientInterface()->Receive();
	BYTE ReceivedPacketID = GetPacketID(ReceivedPacket);

	if(cheat_state->_generic.prevent_trolling_vehicle && ReceivedPacketID == ID_VEHICLE_SYNC)
	{
		RakNet::BitStream bsVehicleSync((unsigned char *)ReceivedPacket->data, ReceivedPacket->length, false);
		bool bInvalid = 0;

		stInCarData IncomingInCarData;
		unsigned short PlayerID;

		memset(&IncomingInCarData, 0, sizeof(stInCarData));

		bsVehicleSync.IgnoreBits(8);
		bsVehicleSync.Read(PlayerID);

		bsVehicleSync.Read(IncomingInCarData.sVehicleID);

		// KEYS
		bsVehicleSync.Read(IncomingInCarData.sLeftRightKeys);
		bsVehicleSync.Read(IncomingInCarData.sUpDownKeys);
		bsVehicleSync.Read(IncomingInCarData.sKeys);

		// QUATERNIONS
		bsVehicleSync.ReadNormQuat(IncomingInCarData.fQuaternion[0], IncomingInCarData.fQuaternion[1], IncomingInCarData.fQuaternion[2], IncomingInCarData.fQuaternion[3]);

		// POSITION
		bsVehicleSync.Read(IncomingInCarData.fPosition[0]);
		bsVehicleSync.Read(IncomingInCarData.fPosition[1]);
		bsVehicleSync.Read(IncomingInCarData.fPosition[2]);

		// MOVE SPEED
		bsVehicleSync.ReadVector(IncomingInCarData.fMoveSpeed[0], IncomingInCarData.fMoveSpeed[1], IncomingInCarData.fMoveSpeed[2]);

		/*bsVehicleSync.SetReadOffset(352);

		// TRAIN SPECIAL
		bool bTrain;
		WORD wSpeed;
		bsVehicleSync.ReadCompressed(bTrain);

		if(bTrain)
		{
			bsVehicleSync.Read(wSpeed);
			addMessageToChatWindow("fTrainSpeed = %f", (float)wSpeed);
		}*/

		if(!_finite(IncomingInCarData.fPosition[0]) || !_finite(IncomingInCarData.fPosition[1]) || !_finite(IncomingInCarData.fPosition[2]))
			bInvalid = 1;

		if(IncomingInCarData.fPosition[0] > 20000.0f || IncomingInCarData.fPosition[0] < -20000.0f || IncomingInCarData.fPosition[1] > 20000.0f || IncomingInCarData.fPosition[1] < -20000.0f || IncomingInCarData.fPosition[2] > 20000.0f || IncomingInCarData.fPosition[2] < -100.0f)
			bInvalid = 1;

		if(IncomingInCarData.fMoveSpeed[0] > 35.0f || IncomingInCarData.fMoveSpeed[0] < -35.0f || IncomingInCarData.fMoveSpeed[1] > 35.0f || IncomingInCarData.fMoveSpeed[1] < -35.0f || IncomingInCarData.fMoveSpeed[2] > 35.0f || IncomingInCarData.fMoveSpeed[2] < -35.0f)
			bInvalid = 1;

		if(ValidVehicle(IncomingInCarData.sVehicleID))
		{
			struct actor_info *pSelfActor = actor_info_get( ACTOR_SELF, 0 );
			struct vehicle_info *pSyncedVehicle = g_SAMP->pPools->pPool_Vehicle->pGTA_Vehicle[IncomingInCarData.sVehicleID];

			if(pSelfActor != NULL && pSyncedVehicle != NULL)
			{
				if(pSelfActor->vehicle == pSyncedVehicle && pSelfActor->vehicle->passengers[0] == pSelfActor)
				{
					if(vect3_dist(pSyncedVehicle->base.coords, IncomingInCarData.fPosition) > 100.0f)
						bInvalid = 1;

					if(ValidPlayer(PlayerID))
					{
						struct actor_info *pSyncActor = getGTAPedFromSAMPPlayerID(PlayerID);

						if(pSyncActor == NULL)
							bInvalid = 1;

						if(pSyncActor->vehicle != NULL)
							bInvalid = 1;
					}
				}
			}
		}

		if(bInvalid)
		{
			ReceivedPacket->data[0] = 255;
			ReceivedPacketID = 255;
		}
	}

	if(cheat_state->_generic.anti_bulletcrasher && ReceivedPacketID == ID_BULLET_SYNC)
	{
		RakNet::BitStream bsBulletSync((unsigned char *)ReceivedPacket->data, ReceivedPacket->length, false);

		stBulletData BulletData;
		unsigned short PlayerID;

		memset(&BulletData, 0, sizeof(stBulletData));

		bsBulletSync.IgnoreBits(8);
		bsBulletSync.Read(PlayerID);
		bsBulletSync.Read((PCHAR)&BulletData, sizeof(stBulletData));

		bool bInvalid = 0;

		if(!_finite(BulletData.fHitOrigin[0]) || !_finite(BulletData.fHitOrigin[1]) || !_finite(BulletData.fHitOrigin[2]))
			bInvalid = 1;

		if(!_finite(BulletData.fHitTarget[0]) || !_finite(BulletData.fHitTarget[1]) || !_finite(BulletData.fHitTarget[2]))
			bInvalid = 1;

		if(!_finite(BulletData.fCenterOfHit[0]) || !_finite(BulletData.fCenterOfHit[1]) || !_finite(BulletData.fCenterOfHit[2]))
			bInvalid = 1;

		if(BulletData.fHitOrigin[0] > 35000.0f || BulletData.fHitOrigin[0] < -35000.0f || BulletData.fHitOrigin[1] > 35000.0f || BulletData.fHitOrigin[1] < -35000.0f || BulletData.fHitOrigin[2] > 35000.0f || BulletData.fHitOrigin[2] < -35000.0f)
			bInvalid = 1;

		if(BulletData.fHitTarget[0] > 35000.0f || BulletData.fHitTarget[0] < -35000.0f || BulletData.fHitTarget[1] > 35000.0f || BulletData.fHitTarget[1] < -35000.0f || BulletData.fHitTarget[2] > 35000.0f || BulletData.fHitTarget[2] < -35000.0f)
			bInvalid = 1;

		if(BulletData.bHitType == BULLET_HIT_TYPE_PLAYER && ((BulletData.fCenterOfHit[0] > 10.0f || BulletData.fCenterOfHit[0] < -10.0f) || (BulletData.fCenterOfHit[1] > 10.0f || BulletData.fCenterOfHit[1] < -10.0f) || (BulletData.fCenterOfHit[2] > 10.0f || BulletData.fCenterOfHit[2] < -10.0f)))
			bInvalid = 1;

		if(BulletData.bHitType == BULLET_HIT_TYPE_VEHICLE && ((BulletData.fCenterOfHit[0] > 100.0f || BulletData.fCenterOfHit[0] < -100.0f) || (BulletData.fCenterOfHit[1] > 100.0f || BulletData.fCenterOfHit[1] < -100.0f) || (BulletData.fCenterOfHit[2] > 100.0f || BulletData.fCenterOfHit[2] < -100.0f)))
			bInvalid = 1;

		if(BulletData.bHitType == BULLET_HIT_TYPE_OBJECT || BulletData.bHitType == BULLET_HIT_TYPE_PLAYER_OBJECT && ((BulletData.fCenterOfHit[0] > 1000.0 || BulletData.fCenterOfHit[0] < -1000.0) || (BulletData.fCenterOfHit[1] > 1000.0 || BulletData.fCenterOfHit[1] < -1000.0) || (BulletData.fCenterOfHit[2] > 1000.0 || BulletData.fCenterOfHit[2] < -1000.0)))
			bInvalid = 1;

		if(bInvalid)
		{
			ReceivedPacket->data[0] = 255;
			cheat_state_text("Anti-Crasher: %s sent you invalid bullet data.", getPlayerName(PlayerID));
		}
		else
		{
			if(ValidPlayer(PlayerID))
			{
				bool bBulletBugger = 0;

				float fPos[3] = { 0, 0, 0 };
				int bGotPos = getPlayerPos(PlayerID, fPos);

				if(bGotPos)
				{
					if(!_finite(fPos[2]))
					{
						ReceivedPacket->data[0] = 255;
						cheat_state_text("%s tried to send bugged bullets.", getPlayerName(PlayerID));
					}
				}
				else
					ReceivedPacket->data[0] = 255;
			}
			else
				ReceivedPacket->data[0] = 255;
		}
	}

	if(cheat_state->_generic.anti_weaponcrasher && ReceivedPacketID == ID_AIM_SYNC)
	{
		RakNet::BitStream bsAimSync((unsigned char *)ReceivedPacket->data, ReceivedPacket->length, false);

		stAimData AimData;
		unsigned short PlayerID;

		bsAimSync.IgnoreBits(8);
		bsAimSync.Read(PlayerID);
		bsAimSync.Read((PCHAR)&AimData, sizeof(stAimData));

		float fPos[3] = { 0, 0, 0 };

		bool bInvalidData = false;
		int bGotPos = getPlayerPos(PlayerID, fPos);
 
		if(bGotPos && vect3_dist(fPos, AimData.vecAimPos) > 500.0f)
		{
			vect3_mult(AimData.vecAimPos, 0.0f, AimData.vecAimPos);
			bInvalidData = true;
		}

		for(int i = 0; i < 3; i++)
		{
			if(AimData.vecAimf1[i] < -9.9f || AimData.vecAimf1[i] > 9.9f)
			{
				AimData.vecAimf1[i] = 0.0f;
				bInvalidData = true;
			}
		}

		if(bInvalidData)
		{
			RakNet::BitStream bsFix;

			bsFix.Write((BYTE)ID_AIM_SYNC);
			bsFix.Write(PlayerID);
			bsFix.Write((char *)&AimData, sizeof(stAimData));

			memcpy(ReceivedPacket->data, bsFix.GetData(), ReceivedPacket->length);

			cheat_state_text("Anti-Crasher: %s sent you invalid aim data.", getPlayerName(PlayerID));
		}
	}

	if(IsDisabledIncomingPacketID(ReceivedPacketID))
	{
		ReceivedPacket->data[0] = 255;
		ReceivedPacketID = 255;
	}

	if(ReceivedPacketID != 255)
	{
		if (cheat_state->_generic.log_packet_recv)
		{
			Log( "< [Packet Recv] id: %d, len: %d", ReceivedPacketID, ReceivedPacket->length );
			addMessageToChatWindow( "< [Packet Recv] id: %d, len: %d", ReceivedPacketID, ReceivedPacket->length );
		}
	}

	return ReceivedPacket;
}

void HookedRakClientInterface::DeallocatePacket( Packet *packet )
{
	traceLastFunc( "HookedRakClientInterface::DeallocatePacket" );

	g_iRakClient->GetRakClientInterface()->DeallocatePacket( packet );
}

void HookedRakClientInterface::PingServer( void )
{
	traceLastFunc( "HookedRakClientInterface::PingServer" );

	g_iRakClient->GetRakClientInterface()->PingServer();
}

void HookedRakClientInterface::PingServer( const char* host, unsigned short serverPort, unsigned short clientPort, bool onlyReplyOnAcceptingConnections )
{
	traceLastFunc( "HookedRakClientInterface::PingServer" );

	g_iRakClient->GetRakClientInterface()->PingServer( host, serverPort, clientPort, onlyReplyOnAcceptingConnections );
}

int HookedRakClientInterface::GetAveragePing( void )
{
	traceLastFunc( "HookedRakClientInterface::GetAveragePing" );

	return g_iRakClient->GetRakClientInterface()->GetAveragePing();
}

int HookedRakClientInterface::GetLastPing( void ) const
{
	traceLastFunc( "HookedRakClientInterface::GetLastPing" );

	return g_iRakClient->GetRakClientInterface()->GetLastPing();
}

int HookedRakClientInterface::GetLowestPing( void ) const
{		
	traceLastFunc( "HookedRakClientInterface::GetLowestPing" );

	return g_iRakClient->GetRakClientInterface()->GetLowestPing();
}

int HookedRakClientInterface::GetPlayerPing( const PlayerID playerId )
{
	traceLastFunc( "HookedRakClientInterface::GetPlayerPing" );

	return g_iRakClient->GetRakClientInterface()->GetPlayerPing( playerId );
}

void HookedRakClientInterface::StartOccasionalPing( void )
{
	traceLastFunc( "HookedRakClientInterface::StartOccasionalPing" );

	g_iRakClient->GetRakClientInterface()->StartOccasionalPing();
}

void HookedRakClientInterface::StopOccasionalPing( void )
{
	traceLastFunc( "HookedRakClientInterface::StopOccasionalPing" );

	g_iRakClient->GetRakClientInterface()->StopOccasionalPing();
}

bool HookedRakClientInterface::IsConnected( void ) const
{
	traceLastFunc( "HookedRakClientInterface::IsConnected" );

	return g_iRakClient->GetRakClientInterface()->IsConnected();
}

unsigned int HookedRakClientInterface::GetSynchronizedRandomInteger( void ) const
{
	traceLastFunc( "HookedRakClientInterface::GetSynchronizedRandomInteger" );

	return g_iRakClient->GetRakClientInterface()->GetSynchronizedRandomInteger();
}

bool HookedRakClientInterface::GenerateCompressionLayer( unsigned int inputFrequencyTable[ 256 ], bool inputLayer )
{
	traceLastFunc( "HookedRakClientInterface::GenerateCompressionLayer" );

	return g_iRakClient->GetRakClientInterface()->GenerateCompressionLayer( inputFrequencyTable, inputLayer );
}

bool HookedRakClientInterface::DeleteCompressionLayer( bool inputLayer )
{
	traceLastFunc( "HookedRakClientInterface::DeleteCompressionLayer" );

	return g_iRakClient->GetRakClientInterface()->DeleteCompressionLayer( inputLayer );
}

void HookedRakClientInterface::RegisterAsRemoteProcedureCall( int* uniqueID, void ( *functionPointer ) ( RPCParameters *rpcParms ) )
{
	traceLastFunc( "HookedRakClientInterface::RegisterAsRemoteProcedureCall" );

	g_iRakClient->GetRakClientInterface()->RegisterAsRemoteProcedureCall( uniqueID, functionPointer );
}

void HookedRakClientInterface::RegisterClassMemberRPC( int* uniqueID, void *functionPointer )
{
	traceLastFunc( "HookedRakClientInterface::RegisterClassMemberRPC" );

	g_iRakClient->GetRakClientInterface()->RegisterClassMemberRPC( uniqueID, functionPointer );
}

void HookedRakClientInterface::UnregisterAsRemoteProcedureCall( int* uniqueID )
{
	traceLastFunc( "HookedRakClientInterface::UnregisterAsRemoteProcedureCall" );

	g_iRakClient->GetRakClientInterface()->UnregisterAsRemoteProcedureCall( uniqueID );
}

bool HookedRakClientInterface::RPC( int* uniqueID, const char *data, unsigned int bitLength, PacketPriority priority, PacketReliability reliability, char orderingChannel, bool shiftTimestamp )
{
	traceLastFunc( "HookedRakClientInterface::RPC" );

	return g_iRakClient->GetRakClientInterface()->RPC( uniqueID, data, bitLength, priority, reliability, orderingChannel, shiftTimestamp );
}

bool HookedRakClientInterface::RPC( int* uniqueID, RakNet::BitStream *parameters, PacketPriority priority, PacketReliability reliability, char orderingChannel, bool shiftTimestamp )
{
	traceLastFunc( "HookedRakClientInterface::RPC(BitStream)" );

	if( *uniqueID == RPC_DialogResponse && cheat_state->_generic.blockdialogs )
		return 1;

	if( *uniqueID == RPC_ClientJoin )
	{
		int iVersion;
		BYTE byteMod;
		BYTE byteNameLen;
		char szNickName[32];

		parameters->Read(iVersion);
		parameters->Read(byteMod);
		parameters->Read(byteNameLen);
		parameters->Read(szNickName, byteNameLen);
		parameters->Read(uiClientChallengeResponse);

		parameters->Reset();

		char auth_bs[4*16];
		gen_rand_gpci(auth_bs);

		BYTE byteAuthBSLen;
		byteAuthBSLen = (BYTE)strlen(auth_bs);

		parameters->Write(iVersion);
		parameters->Write(byteMod);
		parameters->Write(byteNameLen);
		parameters->Write(szNickName, byteNameLen);

		parameters->Write(uiClientChallengeResponse);
		parameters->Write(byteAuthBSLen);
		parameters->Write(auth_bs, byteAuthBSLen);
		char szClientVer[] = CLIENT_VERSION;
		const BYTE iClientVerLen = (sizeof(szClientVer)-1);
		parameters->Write(iClientVerLen);
		parameters->Write(szClientVer, iClientVerLen);

		cheat_state_text("Serial spoofed: %s", auth_bs);
	}

	// use this if you wanna log outgoing RPCs
	if ( cheat_state->_generic.log_rpc_send && *uniqueID != RPC_UpdateScoresPingsIPs )
	{
		int len = parameters ? parameters->GetNumberOfBytesUsed() : 0;
		Log( "< [RPC Send] id: %d, len: %d", *uniqueID, len );
		addMessageToChatWindow( "< [RPC Send] id: %d, len: %d", *uniqueID, len );
	}

	if( *uniqueID == RPC_Death && cheat_state->_generic.fastrespawn )
	{
		g_iRakClient->GetRakClientInterface()->RPC(uniqueID, parameters, priority, reliability, orderingChannel, shiftTimestamp);

		struct actor_info *info;

		if ( (info = actor_info_get(ACTOR_SELF, ACTOR_ALIVE)) != NULL )
			info->hitpoints = 100.0f;

		return 1;
	}

	return g_iRakClient->GetRakClientInterface()->RPC( uniqueID, parameters, priority, reliability, orderingChannel, shiftTimestamp );
}

void HookedRakClientInterface::SetTrackFrequencyTable( bool b )
{
	traceLastFunc( "HookedRakClientInterface::SetTrackFrequencyTable" );

	g_iRakClient->GetRakClientInterface()->SetTrackFrequencyTable( b );
}

bool HookedRakClientInterface::GetSendFrequencyTable( unsigned int outputFrequencyTable[ 256 ] )
{
	traceLastFunc( "HookedRakClientInterface::GetSendFrequencyTable" );

	return g_iRakClient->GetRakClientInterface()->GetSendFrequencyTable( outputFrequencyTable );
}

float HookedRakClientInterface::GetCompressionRatio( void ) const 
{
	traceLastFunc( "HookedRakClientInterface::GetCompressionRatio" );

	return g_iRakClient->GetRakClientInterface()->GetCompressionRatio();
}

float HookedRakClientInterface::GetDecompressionRatio( void ) const
{
	traceLastFunc( "HookedRakClientInterface::GetDecompressionRatio" );

	return g_iRakClient->GetRakClientInterface()->GetDecompressionRatio();
}

void HookedRakClientInterface::AttachPlugin( void *messageHandler )
{
	traceLastFunc( "HookedRakClientInterface::AttachPlugin" );

	g_iRakClient->GetRakClientInterface()->AttachPlugin(messageHandler);
}

void HookedRakClientInterface::DetachPlugin( void *messageHandler )
{
	traceLastFunc( "HookedRakClientInterface::DetachPlugin" );

	g_iRakClient->GetRakClientInterface()->DetachPlugin(messageHandler);
}

RakNet::BitStream * HookedRakClientInterface::GetStaticServerData( void )
{
	traceLastFunc( "HookedRakClientInterface::GetStaticServerData" );

	return g_iRakClient->GetRakClientInterface()->GetStaticServerData();
}

void HookedRakClientInterface::SetStaticServerData( const char *data, const int length )
{
	traceLastFunc( "HookedRakClientInterface::SetStaticServerData" );

	g_iRakClient->GetRakClientInterface()->SetStaticServerData( data, length );
}

RakNet::BitStream * HookedRakClientInterface::GetStaticClientData( const PlayerID playerId )
{	
	traceLastFunc( "HookedRakClientInterface::GetStaticClientData" );

	return g_iRakClient->GetRakClientInterface()->GetStaticClientData( playerId );
}

void HookedRakClientInterface::SetStaticClientData( const PlayerID playerId, const char *data, const int length )
{
	traceLastFunc( "HookedRakClientInterface::SetStaticClientData" );

	g_iRakClient->GetRakClientInterface()->SetStaticClientData( playerId, data, length );
}

void HookedRakClientInterface::SendStaticClientDataToServer( void )
{
	traceLastFunc( "HookedRakClientInterface::SendStaticClientDataToServer" );

	g_iRakClient->GetRakClientInterface()->SendStaticClientDataToServer();
}

PlayerID HookedRakClientInterface::GetServerID( void ) const
{
	traceLastFunc( "HookedRakClientInterface::GetServerID" );

	return g_iRakClient->GetRakClientInterface()->GetServerID();
}

PlayerID HookedRakClientInterface::GetPlayerID( void ) const
{
	traceLastFunc( "HookedRakClientInterface::GetPlayerID" );

	return g_iRakClient->GetRakClientInterface()->GetPlayerID();
}

PlayerID HookedRakClientInterface::GetInternalID( void ) const
{
	traceLastFunc( "HookedRakClientInterface::GetInternalID" );

	return g_iRakClient->GetRakClientInterface()->GetInternalID();
}

const char* HookedRakClientInterface::PlayerIDToDottedIP( const PlayerID playerId ) const
{
	traceLastFunc( "HookedRakClientInterface::PlayerIDToDottedIP" );

	return g_iRakClient->GetRakClientInterface()->PlayerIDToDottedIP( playerId );
}

void HookedRakClientInterface::PushBackPacket( Packet *packet, bool pushAtHead )
{
	traceLastFunc( "HookedRakClientInterface::PushBackPacket" );

	g_iRakClient->GetRakClientInterface()->PushBackPacket(packet, pushAtHead);
}

void HookedRakClientInterface::SetRouterInterface( void *routerInterface )
{
	traceLastFunc( "HookedRakClientInterface::SetRouterInterface" );

	g_iRakClient->GetRakClientInterface()->SetRouterInterface(routerInterface);
}
void HookedRakClientInterface::RemoveRouterInterface( void *routerInterface )
{
	traceLastFunc( "HookedRakClientInterface::RemoveRouterInterface" );

	g_iRakClient->GetRakClientInterface()->RemoveRouterInterface(routerInterface);
}

void HookedRakClientInterface::SetTimeoutTime( RakNetTime timeMS )
{
	traceLastFunc( "HookedRakClientInterface::SetTimeoutTime" );

	g_iRakClient->GetRakClientInterface()->SetTimeoutTime( timeMS );
}

bool HookedRakClientInterface::SetMTUSize( int size )
{
	traceLastFunc( "HookedRakClientInterface::SetMTUSize" );

	return g_iRakClient->GetRakClientInterface()->SetMTUSize( size );
}

int HookedRakClientInterface::GetMTUSize( void ) const
{
	traceLastFunc( "HookedRakClientInterface::GetMTUSize" );

	return g_iRakClient->GetRakClientInterface()->GetMTUSize();
}

void HookedRakClientInterface::AllowConnectionResponseIPMigration( bool allow )
{
	traceLastFunc( "HookedRakClientInterface::AllowConnectionResponseIPMigration" );

	g_iRakClient->GetRakClientInterface()->AllowConnectionResponseIPMigration( allow );
}

void HookedRakClientInterface::AdvertiseSystem( const char *host, unsigned short remotePort, const char *data, int dataLength )
{
	traceLastFunc( "HookedRakClientInterface::AdvertiseSystem" );

	g_iRakClient->GetRakClientInterface()->AdvertiseSystem( host, remotePort, data, dataLength );
}

RakNetStatisticsStruct* const HookedRakClientInterface::GetStatistics( void )
{
	traceLastFunc( "HookedRakClientInterface::GetStatistics" );

	return g_iRakClient->GetRakClientInterface()->GetStatistics();
}

void HookedRakClientInterface::ApplyNetworkSimulator( double maxSendBPS, unsigned short minExtraPing, unsigned short extraPingVariance)
{
	traceLastFunc( "HookedRakClientInterface::ApplyNetworkSimulator" );

	g_iRakClient->GetRakClientInterface()->ApplyNetworkSimulator( maxSendBPS, minExtraPing, extraPingVariance );
}

bool HookedRakClientInterface::IsNetworkSimulatorActive( void )
{
	traceLastFunc( "HookedRakClientInterface::IsNetworkSimulatorActive" );

	return g_iRakClient->GetRakClientInterface()->IsNetworkSimulatorActive();
}

PlayerIndex HookedRakClientInterface::GetPlayerIndex( void )
{
	traceLastFunc( "HookedRakClientInterface::GetPlayerIndex" );

	return g_iRakClient->GetRakClientInterface()->GetPlayerIndex();
}

void HookedRakClientInterface::Pad( void )
{
	DWORD at = (DWORD)_ReturnAddress();
	Log( "HookedRakClientInterface::Pad has been called. Return address: %p", at );
}

BYTE GetPacketID(Packet *p)
{
	if (p==0) return 255;

	if ((unsigned char)p->data[0] == ID_TIMESTAMP) {
		assert(p->length > sizeof(unsigned char) + sizeof(unsigned long));
		return (unsigned char) p->data[sizeof(unsigned char) + sizeof(unsigned long)];
	}
	else {
		return (unsigned char) p->data[0];
	}
}

bool IsUpdatePacket(unsigned char packetId)
{
	if(packetId == ID_PLAYER_SYNC || packetId == ID_VEHICLE_SYNC || packetId == ID_PASSENGER_SYNC || packetId == ID_SPECTATOR_SYNC)
		return true;
	else
		return false;
}

BOOL IsDisabledIncomingPacketID(BYTE packetId)
{
	if(packetId == ID_PLAYER_SYNC && cheat_state->packet_dsbl_settings.DSBL_RCV_PLAYER_SYNC) return 1;
	if(packetId == ID_MARKERS_SYNC && cheat_state->packet_dsbl_settings.DSBL_RCV_MARKERS_SYNC) return 1;
	if(packetId == ID_UNOCCUPIED_SYNC && cheat_state->packet_dsbl_settings.DSBL_RCV_UNOCCUPIED_SYNC) return 1;
	if(packetId == ID_TRAILER_SYNC && cheat_state->packet_dsbl_settings.DSBL_RCV_TRAILER_SYNC) return 1;
	if(packetId == ID_PASSENGER_SYNC && cheat_state->packet_dsbl_settings.DSBL_RCV_PASSENGER_SYNC) return 1;
	if(packetId == ID_AIM_SYNC && cheat_state->packet_dsbl_settings.DSBL_RCV_AIM_SYNC) return 1;
	if(packetId == ID_VEHICLE_SYNC && cheat_state->packet_dsbl_settings.DSBL_RCV_VEHICLE_SYNC) return 1;
	if(packetId == ID_BULLET_SYNC && cheat_state->packet_dsbl_settings.DSBL_RCV_BULLET_SYNC) return 1;
	return 0;
}