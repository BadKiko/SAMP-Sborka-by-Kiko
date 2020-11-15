/*
	La Pirula Project
*/

#include "main.h"

int iLastBulletFlood = GetTickCount();
int iLastCrasherActivation = GetTickCount();

void cheat_handle_fakebullets ()
{
	traceLastFunc( "cheat_handle_fakebullets()" );

	if(g_SAMP == NULL || g_SAMP->iGameState != GAMESTATE_CONNECTED)
		return;

	if( cheat_state->_generic.fakebullets == 1 )
	{
		if ( KEY_DOWN (0x59) && (GetTickCount()-iLastBulletFlood) >= 50)
		{
			for ( int v = 0; v < SAMP_PLAYER_MAX; v++ )
				g_iRakClient->SendFakeBulletToPlayer(v);

			iLastBulletFlood = GetTickCount();
		}
	}
	else if( cheat_state->_generic.bulletcrasher_p == 1 && cheat_state->_generic.bulletcrasher_v == 0 )
	{
		if ( KEY_PRESSED (0x59) && (GetTickCount()-iLastCrasherActivation) >= 250)
		{
            stBulletData BulletSync;
            memset(&BulletSync, 0, sizeof(stBulletData));

			BulletSync.bHitType = 1;
			BulletSync.iHitID = g_Players->sLocalPlayerID;

            BulletSync.fCenterOfHit[0] = (float)0x7777777B;
            BulletSync.fCenterOfHit[1] = (float)0x7777777B;
            BulletSync.fCenterOfHit[2] = (float)0x7777777B;
 
			RakNet::BitStream bsSend;

			bsSend.Write((BYTE)ID_BULLET_SYNC);
			bsSend.Write((PCHAR)&BulletSync, sizeof(stBulletData));

			g_iRakClient->Send(&bsSend, HIGH_PRIORITY, UNRELIABLE_SEQUENCED, 0);

			cheat_state_text("Bulletcrasher: Data sent. [player]");

			iLastCrasherActivation = GetTickCount();
		}
	}
	else if( cheat_state->_generic.bulletcrasher_p == 0 && cheat_state->_generic.bulletcrasher_v == 1 )
	{
		if ( KEY_PRESSED (0x59) && (GetTickCount()-iLastCrasherActivation) >= 250)
		{
			if ( cheat_state->state == CHEAT_STATE_VEHICLE )
			{
				stBulletData BulletSync;
				memset(&BulletSync, 0, sizeof(stBulletData));

				BulletSync.bHitType = 2;
				BulletSync.iHitID = g_Players->pLocalPlayer->sCurrentVehicleID;

				BulletSync.fCenterOfHit[0] = (float)0x7777777B;
				BulletSync.fCenterOfHit[1] = (float)0x7777777B;
				BulletSync.fCenterOfHit[2] = (float)0x7777777B;
	 
				RakNet::BitStream bsSend;

				bsSend.Write((BYTE)ID_BULLET_SYNC);
				bsSend.Write((PCHAR)&BulletSync, sizeof(stBulletData));

				g_iRakClient->Send(&bsSend, HIGH_PRIORITY, UNRELIABLE_SEQUENCED, 0);

				cheat_state_text("Bulletcrasher: Data sent [vehicle].");

				iLastCrasherActivation = GetTickCount();
			}
			else cheat_state_text("Bulletcrasher: Enter a vehicle!");
		}
	}
}

void cheat_handle_playerbugger ()
{
	traceLastFunc( "cheat_handle_playerbugger()" );

	if(g_SAMP == NULL || g_SAMP->iGameState != GAMESTATE_CONNECTED)
		return;

	if( cheat_state->_generic.playerbugger_incar == 1 )
	{
		struct actor_info *self = actor_info_get( ACTOR_SELF, 0 );

		static int iPlayerID;

		if ( g_Players->iIsListed[iPlayerID] != 1
			||  g_Players->pRemotePlayer[iPlayerID] == NULL
			||  g_Players->pRemotePlayer[iPlayerID]->pPlayerData == NULL
			||  g_Players->pRemotePlayer[iPlayerID]->pPlayerData->pSAMP_Actor == NULL
			||  g_Players->pRemotePlayer[iPlayerID]->pPlayerData->pSAMP_Actor->pGTA_Ped == NULL
			||  getPlayerSAMPVehicleID(iPlayerID) == NULL
			||  getPlayerSAMPVehicleID(iPlayerID) == g_Players->pLocalPlayer->sCurrentVehicleID
			||  getPlayerState(iPlayerID) != PLAYER_STATE_DRIVER && getPlayerState(iPlayerID) != PLAYER_STATE_PASSENGER )
			goto find_another_player;

		struct vehicle_info *vinfo = g_Players->pRemotePlayer[iPlayerID]->pPlayerData->pSAMP_Actor->pGTA_Ped->vehicle;

		int iSAMPVehicleID;

		if ( vinfo == vehicle_info_get(VEHICLE_SELF, 0) && vinfo->passengers[0] != self )
			iSAMPVehicleID = g_Players->pLocalPlayer->passengerData.sVehicleID;
		else
			iSAMPVehicleID = getSAMPVehicleIDFromGTAVehicle(vinfo);

		if(iSAMPVehicleID == g_Players->pLocalPlayer->sCurrentVehicleID/* || iSAMPVehicleID == g_Players->pLocalPlayer->passengerData.sVehicleID*/)
		{
			iPlayerID++;
			goto find_another_player;
		}

		if ( KEY_PRESSED(VK_LBUTTON) )
		{
			struct actor_info *pSelfActor = actor_info_get( ACTOR_SELF, 0 );

			BYTE byteCurrentWeap;

			if ( cheat_state->state == CHEAT_STATE_VEHICLE )
				byteCurrentWeap = g_Players->pLocalPlayer->inCarData.byteCurrentWeapon;

			else if ( cheat_state->state == CHEAT_STATE_ACTOR )
				byteCurrentWeap = g_Players->pLocalPlayer->onFootData.byteCurrentWeapon;

			else byteCurrentWeap = 0;

			bool bWasInVehicle = pSelfActor->pedFlags.bInVehicle;

			pSelfActor->pedFlags.bInVehicle = true;

			float fPos[3];
			vect3_copy(&self->base.matrix[4 * 3], fPos);

			fPos[0] += -128471816.0000;
			fPos[1] += 889395.2500;
			fPos[2] += 13083.3252;

			float fSpeed[3];
			fSpeed[0] = cam_matrix[4] * 6.0f;
			fSpeed[1] = cam_matrix[5] * 6.0f;
			fSpeed[2] = cam_matrix[6] * 6.0f;

			RakNet::BitStream bsPassengerSync;
			RakNet::BitStream bsInCarSync;

			stInCarData InCarData;
			stPassengerData PassengerData;

			InCarData.sVehicleID = iSAMPVehicleID;
			PassengerData.sVehicleID = iSAMPVehicleID;

			InCarData.fVehicleHealth = vinfo->hitpoints;

			InCarData.bytePlayerHealth = pSelfActor->hitpoints;
			PassengerData.byteHealth = pSelfActor->hitpoints;

			InCarData.byteArmor = pSelfActor->armor;
			PassengerData.byteArmor = pSelfActor->armor;

			InCarData.byteCurrentWeapon = byteCurrentWeap;
			PassengerData.byteCurrentWeapon = byteCurrentWeap;

			InCarData.sTrailerID = g_SAMP->pPools->pPool_Player->pRemotePlayer[iPlayerID]->pPlayerData->inCarData.sTrailerID;

			vect3_copy(vinfo->base.coords, InCarData.fPosition);
			vect3_copy(vinfo->base.coords, PassengerData.fPosition);

			PassengerData.byteSeatID = 1;

			bsPassengerSync.Write((BYTE)ID_PASSENGER_SYNC);
			bsPassengerSync.Write((PCHAR)&PassengerData,sizeof(stPassengerData));

			vect3_copy(fPos, InCarData.fPosition);
			vect3_copy(fSpeed, InCarData.fMoveSpeed);

			bsInCarSync.Write((BYTE)ID_VEHICLE_SYNC);
			bsInCarSync.Write((PCHAR)&InCarData,sizeof(stInCarData));

			g_iRakClient->Send(&bsPassengerSync, HIGH_PRIORITY, RELIABLE_ORDERED, 0);

			g_iRakClient->Send(&bsInCarSync, HIGH_PRIORITY, RELIABLE_ORDERED, 0);

			pSelfActor->pedFlags.bInVehicle = bWasInVehicle;

			iPlayerID++;
		}

find_another_player:
	for ( iPlayerID; iPlayerID < SAMP_PLAYER_MAX; iPlayerID++ )
	{
		if ( g_Players->iIsListed[iPlayerID] == 1
			&&  g_Players->pRemotePlayer[iPlayerID] != NULL
			&&  g_Players->pRemotePlayer[iPlayerID]->pPlayerData != NULL
			&&  g_Players->pRemotePlayer[iPlayerID]->pPlayerData->pSAMP_Actor != NULL
			&&  g_Players->pRemotePlayer[iPlayerID]->pPlayerData->pSAMP_Actor->pGTA_Ped != NULL
			&&  getPlayerSAMPVehicleID(iPlayerID) != NULL
			&&  getPlayerSAMPVehicleID(iPlayerID) != g_Players->pLocalPlayer->sCurrentVehicleID
			&&  getPlayerState(iPlayerID) == PLAYER_STATE_DRIVER || getPlayerState(iPlayerID) == PLAYER_STATE_PASSENGER)
		break;
	}

	if ( iPlayerID >= SAMP_PLAYER_MAX )
		iPlayerID = 0;
	}

}

void cheat_handle_car_remote_control()
{
	traceLastFunc( "cheat_handle_car_remote_control()" );

	if( cheat_state->_generic.car_remote_control == 1 )
	{
		struct actor_info *self = actor_info_get( ACTOR_SELF, 0 );
		struct vehicle_info *vinfo = vehicle_info_get( VEHICLE_SELF, 0 );

		if ( vinfo != NULL )
		{
			if ( set.car_remote_control_with_driver && !set.car_remote_control_without_driver )
			{
				int iPlayerID = sampFindNearestPlayer();
				struct actor_info *ainfo = getGTAPedFromSAMPPlayerID(iPlayerID);

				if ( ainfo == NULL || ainfo->vehicle == NULL || ainfo == self || ainfo->vehicle == vinfo
					||  getPlayerSAMPVehicleID(iPlayerID) == NULL || getPlayerSAMPVehicleID(iPlayerID) == g_Players->pLocalPlayer->sCurrentVehicleID
					||  getPlayerState(iPlayerID) != PLAYER_STATE_DRIVER && getPlayerState(iPlayerID) != PLAYER_STATE_PASSENGER )
					return;

				struct vehicle_info *vtemp = ainfo->vehicle;
				int iSAMPVehicleID = getSAMPVehicleIDFromGTAVehicle(vtemp);

				float fPos[3];
				vect3_copy( &vtemp->base.matrix[4 * 3], fPos );

				stInCarData vehSync;
				memset(&vehSync, 0, sizeof(stInCarData));

				vehSync.sVehicleID = iSAMPVehicleID;
				vehSync.fPosition[0] = fPos[0];
				vehSync.fPosition[1] = fPos[1];
				vehSync.fPosition[2] = vinfo->base.matrix[4 * 3 + 2];
				vehSync.fVehicleHealth = vtemp->hitpoints;
				vehSync.fMoveSpeed[0] = vinfo->speed[0];
				vehSync.fMoveSpeed[1] = vinfo->speed[1];
				vehSync.fMoveSpeed[2] = vinfo->speed[2];
				vehSync.fQuaternion[0] = g_Players->pLocalPlayer->inCarData.fQuaternion[0];
				vehSync.fQuaternion[1] = g_Players->pLocalPlayer->inCarData.fQuaternion[1];
				vehSync.fQuaternion[2] = g_Players->pLocalPlayer->inCarData.fQuaternion[2];
				vehSync.fQuaternion[3] = g_Players->pLocalPlayer->inCarData.fQuaternion[3];
				vehSync.bytePlayerHealth = self->hitpoints;
				vehSync.byteArmor = self->armor;
				vehSync.sLeftRightKeys = g_Players->pLocalPlayer->inCarData.sLeftRightKeys;
				vehSync.sUpDownKeys = g_Players->pLocalPlayer->inCarData.sUpDownKeys;
				vehSync.sKeys = g_Players->pLocalPlayer->inCarData.sKeys;

				g_iRakClient->SendInCarFullSyncData(&vehSync);

				vtemp->speed[0] = vinfo->speed[0];
				vtemp->speed[1] = vinfo->speed[1];
				vtemp->speed[2] = vinfo->speed[2];
			}
			else if ( !set.car_remote_control_with_driver && set.car_remote_control_without_driver )
			{
				static int carUsed[SAMP_VEHICLE_MAX];
				static int nearestCar = 0;

				static bool carFound = false;

				if ( carFound == false )
				{
					float fPos[3];
					vect3_copy( &vinfo->base.matrix[4 * 3], fPos );

					float fSmallestDistance = -1.0f;

					for ( int v = 0; v < SAMP_VEHICLE_MAX; v++ )
					{
						if ( g_Vehicles->iIsListed[v] != 1 )
							continue;

						int car_id = (int)( ((DWORD) g_Vehicles->pGTA_Vehicle[v]) - (DWORD) pool_vehicle->start ) / 2584;
						struct vehicle_info *vtemp = vehicle_info_get( car_id, 0 );

						if ( vtemp == NULL || vtemp == vinfo )
							continue;

						if ( carUsed[v] == 1 )
							continue;

						int iSAMPVehicleID = getSAMPVehicleIDFromGTAVehicle(vtemp);
						if(iSAMPVehicleID <= 0 || iSAMPVehicleID >= SAMP_VEHICLE_MAX || iSAMPVehicleID == g_Players->pLocalPlayer->sCurrentVehicleID)
						   continue;

						float car_pos[3];
						vect3_copy( &vtemp->base.matrix[4 * 3], car_pos );

						float fDistance = vect3_dist(car_pos, fPos);

						if ( fSmallestDistance == -1.0f )
						{
							fSmallestDistance = fDistance;

							nearestCar = v;
						}

						if ( fDistance < fSmallestDistance )
						{
							fSmallestDistance = fDistance;

							nearestCar = v;
						}
					}

					if ( nearestCar == 0 )
					{
						for ( int i = 0; i < SAMP_VEHICLE_MAX; i++ )
							carUsed[i] = 0;

						return;
					}

					carFound = true;
				}

				if ( carFound == true )
				{
					if ( nearestCar <= 0 || nearestCar >= SAMP_VEHICLE_MAX || nearestCar == g_Players->pLocalPlayer->sCurrentVehicleID )
					{
						nearestCar = 0;
						carFound = false;
						return;
					}

					struct vehicle_info *vtemp = getGTAVehicleFromSAMPVehicleID(nearestCar);
					if ( vtemp == NULL || vtemp == vinfo )
					{
						nearestCar = 0;
						carFound = false;
						return;
					}

					carUsed[nearestCar] = 1;

					float fPos[3];
					vect3_copy( &vinfo->base.matrix[4 * 3], fPos );

					fPos[1] += 8.0f;

					float fQuaternion[4];

					if ( vinfo->passengers[0] != self )
					{
						int iPlayerID = getSAMPPlayerIDFromGTAPed(vinfo->passengers[0]);

						if ( iPlayerID == -1 )
						{
							fQuaternion[0] = vinfo->base.matrix[3];
							fQuaternion[1] = vinfo->base.matrix[6];
							fQuaternion[2] = vinfo->base.matrix[5];
							fQuaternion[3] = vinfo->base.matrix[4];
						}
						else
						{
							fQuaternion[0] = g_Players->pRemotePlayer[iPlayerID]->pPlayerData->inCarData.fQuaternion[0];
							fQuaternion[1] = g_Players->pRemotePlayer[iPlayerID]->pPlayerData->inCarData.fQuaternion[1];
							fQuaternion[2] = g_Players->pRemotePlayer[iPlayerID]->pPlayerData->inCarData.fQuaternion[2];
							fQuaternion[3] = g_Players->pRemotePlayer[iPlayerID]->pPlayerData->inCarData.fQuaternion[3];
						}
					}
					else
					{
						fQuaternion[0] = g_Players->pLocalPlayer->inCarData.fQuaternion[0];
						fQuaternion[1] = g_Players->pLocalPlayer->inCarData.fQuaternion[1];
						fQuaternion[2] = g_Players->pLocalPlayer->inCarData.fQuaternion[2];
						fQuaternion[3] = g_Players->pLocalPlayer->inCarData.fQuaternion[3];
					}

					stInCarData vehSync;
					memset(&vehSync, 0, sizeof(stInCarData));

					vehSync.sVehicleID = nearestCar;
					vehSync.fPosition[0] = fPos[0];
					vehSync.fPosition[1] = fPos[1];
					vehSync.fPosition[2] = fPos[2];
					vehSync.fVehicleHealth = vtemp->hitpoints;
					vehSync.fMoveSpeed[0] = vinfo->speed[0];
					vehSync.fMoveSpeed[1] = vinfo->speed[1];
					vehSync.fMoveSpeed[2] = vinfo->speed[2];
					vehSync.fQuaternion[0] = fQuaternion[0];
					vehSync.fQuaternion[1] = fQuaternion[1];
					vehSync.fQuaternion[2] = fQuaternion[2];
					vehSync.fQuaternion[3] = fQuaternion[3];
					vehSync.bytePlayerHealth = self->hitpoints;
					vehSync.byteArmor = self->armor;
					vehSync.sLeftRightKeys = g_Players->pLocalPlayer->inCarData.sLeftRightKeys;
					vehSync.sUpDownKeys = g_Players->pLocalPlayer->inCarData.sUpDownKeys;
					vehSync.sKeys = g_Players->pLocalPlayer->inCarData.sKeys;
					vehSync.byteLandingGearState = g_Players->pLocalPlayer->inCarData.byteLandingGearState;
					vehSync.byteSiren = g_Players->pLocalPlayer->inCarData.byteSiren;
					vehSync.byteCurrentWeapon = g_Players->pLocalPlayer->inCarData.byteCurrentWeapon;

					g_iRakClient->SendInCarFullSyncData(&vehSync);

					vtemp->speed[0] = vinfo->speed[0];
					vtemp->speed[1] = vinfo->speed[1];
					vtemp->speed[2] = vinfo->speed[2];
					vtemp->base.matrix[0] = vinfo->base.matrix[0];
					vtemp->base.matrix[1] = vinfo->base.matrix[1];
					vtemp->base.matrix[2] = vinfo->base.matrix[2];
					vtemp->base.matrix[3] = vinfo->base.matrix[3];
					vtemp->base.matrix[4] = vinfo->base.matrix[4];
					vtemp->base.matrix[5] = vinfo->base.matrix[5];
					vtemp->base.matrix[6] = vinfo->base.matrix[6];
					vtemp->base.matrix[7] = vinfo->base.matrix[7];
					vtemp->base.matrix[8] = vinfo->base.matrix[8];
					vtemp->base.matrix[9] = vinfo->base.matrix[9];
					vtemp->base.matrix[10] = vinfo->base.matrix[10];
					vtemp->base.matrix[11] = vinfo->base.matrix[11];
					vtemp->base.matrix[12] = vinfo->base.matrix[12];
					vtemp->base.matrix[13] = fPos[1];
					vtemp->base.matrix[14] = vinfo->base.matrix[14];
					vtemp->base.matrix[15] = vinfo->base.matrix[15];
				}
			}
		}
		else
		{
			cheat_state_text("Car remote control: You must be in a vehicle!");
			cheat_state->_generic.car_remote_control = 0;
			return;
		}
	}
	return;
}

int iLastSentFakekill = GetTickCount();
int iFakeKillerID = 0;

void cheat_handle_fakekill ()
{
	traceLastFunc( "cheat_handle_fakekill()" );

	if(g_SAMP == NULL || g_Players == NULL || g_SAMP->iGameState != GAMESTATE_CONNECTED)
		return;

	if( cheat_state->_generic.fakekill == 1 && GetTickCount()-iLastSentFakekill >= 50 )
	{
		int randkillerid = 0xFFFF + 1;
		int randreason = rand() % 46;

		while(!ValidPlayer(randkillerid))
		{
			if(getPlayerCount() < 2)
			{
				randkillerid = 0xFFFF;
				break;
			}

			randkillerid = rand() % SAMP_PLAYER_MAX;
		}

		if(randkillerid != 0xFFFF + 1)
			g_iRakClient->SendDeath(randkillerid, randreason);

		iLastSentFakekill = GetTickCount();
	}
}

int iLastComponentCrasherUpdate = GetTickCount();
int iInvalidComponent = 1000;

void cheat_handle_vehcomponent_crasher ()
{
	traceLastFunc( "cheat_handle_vehcomponent_crasher()" );

	if(g_SAMP == NULL || g_Players == NULL || g_SAMP->iGameState != GAMESTATE_CONNECTED)
		return;

	if(cheat_state->_generic.vehcomponentcrasher == 1 && GetTickCount()-iLastComponentCrasherUpdate >= 100)
	{
		if(cheat_state->state != CHEAT_STATE_VEHICLE)
			return;

		struct vehicle_info *vinfo = vehicle_info_get( VEHICLE_SELF, NULL );
		
		if(!IsLegalCarComponent(vinfo->base.model_alt_id, iInvalidComponent))
		{
			sendSCMEvent(2, g_Players->pLocalPlayer->sCurrentVehicleID, iInvalidComponent, 0);

			iLastComponentCrasherUpdate = GetTickCount();
		}

		if(iInvalidComponent >= 1145)
			iInvalidComponent = 1000;
		else
			iInvalidComponent++;
	}
}

void cheat_handle_bike_crasher()
{
	traceLastFunc( "cheat_handle_bike_crasher()" );

	if(cheat_state->_generic.bikecrasher == 0)
		return;

	if(cheat_state->state != CHEAT_STATE_VEHICLE)
		return;

	if(g_SAMP == NULL || g_SAMP->iGameState != GAMESTATE_CONNECTED)
		return;

	if(g_Players == NULL && g_Vehicles == NULL)
		return;

	struct actor_info *pSelfActor = actor_info_get( ACTOR_SELF, 0 );
	struct vehicle_info *pSelfVehicle = vehicle_info_get( VEHICLE_SELF, NULL );

	float *coord = ( cheat_state->state == CHEAT_STATE_VEHICLE ) ? cheat_state->vehicle.coords : cheat_state->actor.coords;

	static bool bBikeCrasherState = 0;
	static bool bTrainSpeedState = 0;
	static DWORD dwBikeCrasherTimerTick = GetTickCount();

	uint16_t sCurrentVehicleID = g_Players->pLocalPlayer->sCurrentVehicleID;

	BYTE byteCurrentWeapon;

	if ( cheat_state->state == CHEAT_STATE_VEHICLE )
		byteCurrentWeapon = g_Players->pLocalPlayer->inCarData.byteCurrentWeapon;

	else if ( cheat_state->state == CHEAT_STATE_ACTOR )
		byteCurrentWeapon = g_Players->pLocalPlayer->onFootData.byteCurrentWeapon;

	else byteCurrentWeapon = 0;

	if(dwBikeCrasherTimerTick < GetTickCount() - 50)
	{
		if(!bBikeCrasherState)
		{
			stInCarData vehSync;
			RakNet::BitStream bsVehicleSync;

			memset(&vehSync, 0, sizeof(stInCarData));

			vehSync.sVehicleID = sCurrentVehicleID;

			vehSync.bytePlayerHealth = pSelfActor->hitpoints;
			vehSync.byteArmor = pSelfActor->armor;

			vehSync.byteCurrentWeapon = byteCurrentWeapon;

			vehSync.fPosition[0] = coord[0];
			vehSync.fPosition[1] = coord[1];
			vehSync.fPosition[2] = coord[2];

			vehSync.fVehicleHealth = pSelfVehicle->hitpoints;

			if(!bTrainSpeedState)
				vehSync.fTrainSpeed = (float)0xFFFFFFFFFFFFFFFF;

			bTrainSpeedState ^= 1;
			
			g_iRakClient->SendInCarFullSyncData(&vehSync);
		}
		else
		{
			float fPos[3], fSpeed[3];

			fPos[0] = coord[0];
			fPos[1] = coord[1];
			fPos[2] = coord[2] + 1.5f;

			g_iRakClient->SendFakeOnfootSyncData(fPos, pSelfActor->hitpoints, pSelfActor->armor, byteCurrentWeapon, fSpeed);
		}

		bBikeCrasherState ^= 1;
		dwBikeCrasherTimerTick = GetTickCount();
	}
}

void cheat_handle_player_bugger_onfoot ( )
{
	traceLastFunc( "cheat_player_bugger_onfoot()" );

	if(cheat_state->state == CHEAT_STATE_NONE)
		return;

	if(!g_SAMP || !g_Players || !g_Vehicles)
		return;

	int iPlayerID = cheat_state->_generic.playerbugger_onfoot_targetid;

	static unsigned short usFoundVehicleID = 0xFFFF;
	static DWORD dwVehicleFoundTick = GetTickCount();

	stInCarData sync;
	RakNet::BitStream bsVehicleSync;

	float pos[3] = { pPedSelf->GetPosition()->fX, pPedSelf->GetPosition()->fY, pPedSelf->GetPosition()->fZ };
	
	struct actor_info *self = actor_info_get(ACTOR_SELF, ACTOR_ALIVE);

	if(cheat_state->_generic.playerbugger_onfoot)
	{
		if ( iPlayerID < 0 || iPlayerID > SAMP_PLAYER_MAX )
			return;

		if(g_Players->sLocalPlayerID == iPlayerID ||g_Players->pRemotePlayer[iPlayerID] == NULL)
			return;

		if (getPlayerState(iPlayerID) != PLAYER_STATE_ONFOOT && getPlayerState(iPlayerID) != PLAYER_STATE_DRIVER)
			return;

		if(usFoundVehicleID != 0xFFFF)
		{
			if(!ValidVehicle(usFoundVehicleID))
			{
				usFoundVehicleID = 0xFFFF;
				return;
			}

			if(dwVehicleFoundTick < GetTickCount() - 50)
			{
				self->vehicle = g_Vehicles->pGTA_Vehicle[usFoundVehicleID];

				memset(&sync, 0, sizeof(stInCarData));

				sync.sVehicleID = usFoundVehicleID;
				sync.fVehicleHealth = g_Vehicles->pGTA_Vehicle[usFoundVehicleID]->hitpoints;

				sync.bytePlayerHealth = self->hitpoints;
				sync.byteArmor = self->armor;

				sync.fQuaternion[0] = 0.707107;
				sync.fQuaternion[1] = -0.707107;
				sync.fQuaternion[2] = 0;
				sync.fQuaternion[3] = 0;

				sync.fPosition[0] = g_Players->pRemotePlayer[iPlayerID]->pPlayerData->onFootData.fPosition[0] + -128471816.0000;
				sync.fPosition[1] = g_Players->pRemotePlayer[iPlayerID]->pPlayerData->onFootData.fPosition[1] + 889395.2500;
				sync.fPosition[2] = g_Players->pRemotePlayer[iPlayerID]->pPlayerData->onFootData.fPosition[2] - 0.75f + 13083.3252;

				sync.fMoveSpeed[0] = cam_matrix[4] * 6.0f;
				sync.fMoveSpeed[1] = cam_matrix[5] * 6.0f;
				sync.fMoveSpeed[2] = cam_matrix[6] * 6.0f;

				cheat_vehicle_teleport(g_Vehicles->pGTA_Vehicle[usFoundVehicleID], sync.fPosition, 0);

				GTAfunc_RemoveActorFromCarAndPutAt(pos);

				bsVehicleSync.Reset();
				bsVehicleSync.Write((BYTE)ID_VEHICLE_SYNC);
				bsVehicleSync.Write((PCHAR)&sync,sizeof(stInCarData));

				g_iRakClient->Send(&bsVehicleSync, HIGH_PRIORITY, RELIABLE_SEQUENCED, 0);

				usFoundVehicleID = 0xFFFF;
				return;
			}
		}

		int iClosestVehicleGTAID = vehicle_find_nearest( VEHICLE_ALIVE + VEHICLE_NOTBURNING );
		struct vehicle_info *pSlapperVehicle = vehicle_info_get( iClosestVehicleGTAID, 0 );
		unsigned short usClosestVehicleSAMPID = getSAMPVehicleIDFromGTAVehicle(pSlapperVehicle);

		if(!ValidVehicle(usClosestVehicleSAMPID))
			return;

		if(KEY_PRESSED(VK_LBUTTON))
		{
			if(usFoundVehicleID == 0xFFFF)
			{
				self->vehicle = pSlapperVehicle;

				memset(&sync, 0, sizeof(stInCarData));

				sync.sVehicleID = usClosestVehicleSAMPID;
				sync.fVehicleHealth = pSlapperVehicle->hitpoints;
				sync.bytePlayerHealth = self->hitpoints;
				sync.byteArmor = self->armor;
						
				sync.fQuaternion[0] = 0.707107;
				sync.fQuaternion[1] = -0.707107;
				sync.fQuaternion[2] = 0;
				sync.fQuaternion[3] = 0;

				sync.fPosition[0] = g_Players->pRemotePlayer[iPlayerID]->pPlayerData->onFootData.fPosition[0];
				sync.fPosition[1] = g_Players->pRemotePlayer[iPlayerID]->pPlayerData->onFootData.fPosition[1]; 
				sync.fPosition[2] = g_Players->pRemotePlayer[iPlayerID]->pPlayerData->onFootData.fPosition[2] - 0.75f;
					
				cheat_vehicle_teleport(pSlapperVehicle, sync.fPosition, 0);

				pSlapperVehicle->base.matrixStruct->right.X = 1;
				pSlapperVehicle->base.matrixStruct->right.Y = 1;
				pSlapperVehicle->base.matrixStruct->right.Z = 1;

				pSlapperVehicle->base.matrixStruct->up.Z = 1;

				GTAfunc_RemoveActorFromCarAndPutAt(pos);

				bsVehicleSync.Reset();
				bsVehicleSync.Write((BYTE)ID_VEHICLE_SYNC);
				bsVehicleSync.Write((PCHAR)&sync,sizeof(stInCarData));

				g_iRakClient->Send(&bsVehicleSync, HIGH_PRIORITY, RELIABLE_SEQUENCED, 0);

				usFoundVehicleID = sync.sVehicleID;
				dwVehicleFoundTick = GetTickCount();
			}
		}
	}
}

void cheat_settings_samp()
{
	/* protections */
	cheat_state->_generic.anti_vehcomponentcrasher = true;
	cheat_state->_generic.anti_bulletcrasher = true;
	cheat_state->_generic.anti_weaponcrasher = true;
	cheat_state->_generic.anti_traincrasher = true;
	cheat_state->_generic.anti_attachedobjectcrasher = true;

	cheat_state->_generic.prevent_trolling_vehicle = true;

	/* aimbot */
	cheat_state->_aimbot.carAimbot = false;
	cheat_state->_aimbot.skinAimbot = false;
	cheat_state->_aimbot.sniperAimbot = false;

	cheat_state->_aimbot.silentAimbot = false;

	cheat_state->_aimbot.silentFrame = false;
	cheat_state->_aimbot.silentFrameX = 0.12f;
	cheat_state->_aimbot.silentFrameY = 0.2f;

	/* bullshit funcs */
	cheat_state->_generic.fastwalk = 1.0f;
	cheat_state->_generic.damagedivider = 100;

	/* itroll */
	cheat_state->_generic.itroll = 0;
	cheat_state->_generic.itroll_target = 0xFFFF;

	/* nocollision */
	if(iIsSAMPSupported) cheat_state->_generic.nocols_actors_enabled = true;
}

HANDLE DroneHandle = NULL;

void cheat_thread_drone_mode()
{
	static float dronepos[3];

	dronepos[0] = cheat_state->actor.coords[0];
	dronepos[1] = cheat_state->actor.coords[1];
	dronepos[2] = cheat_state->actor.coords[2];

	const SCRIPT_COMMAND cam_set_pos = { 0x0936, "ffffffii" };

	while (true)
	{
		struct actor_info* self = actor_info_get(ACTOR_SELF, 0);
		float rotation = self->fCurrentRotation;

		if (KEY_DOWN(0x57) || KEY_DOWN(0x41) || KEY_DOWN(0x53) || KEY_DOWN(0x44)) // WASD
		{
			dronepos[1] -= 0.2f * -cos(-rotation);
			dronepos[0] -= 0.2f * -sin(-rotation);
		}
		
		if (KEY_DOWN(0xA0)) // LSHIFT
			dronepos[2] -= 0.2f;

		if (KEY_DOWN(0x20)) // SPACEBAR
			dronepos[2] += 0.2f;

		ScriptCommand(&cam_set_pos, dronepos[0], dronepos[1], dronepos[2], dronepos[0], dronepos[1], dronepos[2], 100, 1);
		Sleep(10);
	}
}

bool bDroneModeState = 0;

void cheat_handle_drone_mode()
{
	if(cheat_state->_generic.dronemode != bDroneModeState)
	{
		if (DroneHandle == NULL)
		{
			GTAfunc_LockActor(1);
			DroneHandle = CreateThread(0, 0, (LPTHREAD_START_ROUTINE)cheat_thread_drone_mode, 0, 0, 0);

			bDroneModeState = 1;
		}
		else
		{
			TerminateThread(DroneHandle, 0);
			GTAfunc_TogglePlayerControllable(0);
			GTAfunc_LockActor(0);
			DroneHandle = NULL;

			bDroneModeState = 0;
		}
	}
}

void cheat_handle_samp()
{
	cheat_handle_fakebullets();
	cheat_handle_playerbugger();
	cheat_handle_car_remote_control();
	cheat_handle_fakekill();
	cheat_handle_vehcomponent_crasher();
	cheat_handle_bike_crasher();
	cheat_handle_player_bugger_onfoot();
	cheat_handle_drone_mode();

	cheat_handle_car_operations();
}