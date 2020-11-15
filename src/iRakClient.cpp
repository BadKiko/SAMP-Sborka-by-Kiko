/*
	La Pirula Project
*/

#include "main.h"

iRakClient *g_iRakClient = NULL;

iRakClient::iRakClient( void *pRakClientInterface )
{
	pInternalRakClientInterface = (InternalRakClientInterface *)pRakClientInterface;
}

bool iRakClient::RPC( int rpcId, RakNet::BitStream *bitStream, PacketPriority priority, PacketReliability reliability, char orderingChannel, bool shiftTimestamp )
{
	if ( !pInternalRakClientInterface )
		return false;

	return pInternalRakClientInterface->RPC( &rpcId, bitStream, priority, reliability, orderingChannel, shiftTimestamp );
}

bool iRakClient::Send( RakNet::BitStream *bitStream, PacketPriority priority, PacketReliability reliability, char orderingChannel )
{
	if ( !pInternalRakClientInterface )
		return false;

	return pInternalRakClientInterface->Send( bitStream, priority, reliability, orderingChannel );
}

// misc functions
void iRakClient::SendDeath( uint16_t killerId, uint8_t reason )
{
	RakNet::BitStream bsDeath;

	bsDeath.Write( reason );
	bsDeath.Write( killerId );
	g_iRakClient->RPC( RPC_Death, &bsDeath );
}

void iRakClient::SendPickUp( int pickupId )
{
	RakNet::BitStream bsPickup;

	bsPickup.Write( pickupId );
	
	RPC( RPC_PickedUpPickup, &bsPickup );
}

void iRakClient::RequestClass( int classId )
{
	RakNet::BitStream bsClass;

	bsClass.Write( classId );
	g_iRakClient->RPC( RPC_RequestClass, &bsClass );
}

void iRakClient::SendSCMEvent( int vehicleID, int eventId, int param1, int param2 )
{
	RakNet::BitStream bsScmEvent;

	bsScmEvent.Write ( vehicleID );
	bsScmEvent.Write ( param1 );
	bsScmEvent.Write ( param2 );
	bsScmEvent.Write ( eventId );

	RPC( RPC_ScmEvent, &bsScmEvent );
}

void iRakClient::SendSpawn( void )
{
	RakNet::BitStream bsSpawn;

	g_iRakClient->RPC( RPC_RequestSpawn, &bsSpawn );
	g_iRakClient->RPC( RPC_Spawn, &bsSpawn );
}

void iRakClient::NotifyVehicleDeath(int VehicleID)
{
	RakNet::BitStream bsDeath;
	bsDeath.Write(VehicleID);
	g_iRakClient->RPC(RPC_VehicleDestroyed, &bsDeath);
}

void iRakClient::NotifyDamageGiven(int DamagedID, float Amount, int WeaponID, BYTE Bodypart)
{
	RakNet::BitStream bsGiveDamage;
	bsGiveDamage.Write(false);
	bsGiveDamage.Write(Bodypart);
	bsGiveDamage.Write((WORD)DamagedID);
	bsGiveDamage.Write(Amount);
	bsGiveDamage.Write(WeaponID);
	g_iRakClient->RPC(RPC_GiveTakeDamage, &bsGiveDamage);
}

void iRakClient::SendDialogResponse(WORD wDialogID, BYTE bButtonID, WORD wListBoxItem, char *szInputResp)
{
	BYTE respLen = (BYTE)strlen(szInputResp);
	RakNet::BitStream bsSend;
	bsSend.Write(wDialogID);
	bsSend.Write(bButtonID);
	bsSend.Write(wListBoxItem);
	bsSend.Write(respLen);
	bsSend.Write(szInputResp, respLen);
	g_iRakClient->RPC(RPC_DialogResponse, &bsSend);
}

void iRakClient::SendFakeOnfootSyncData(float fPos[3], float fHealth, float fArmor, int byteCurrentWeapon, float fSpeed[3])
{
	stOnFootData ofSync;
	memset(&ofSync, 0, sizeof(stOnFootData));

	RakNet::BitStream bsOnfootSync;

	ofSync.byteHealth = fHealth;
	ofSync.byteArmor = fArmor;

	ofSync.byteCurrentWeapon = byteCurrentWeapon;

	ofSync.fPosition[0] = fPos[0];
	ofSync.fPosition[1] = fPos[1];
	ofSync.fPosition[2] = fPos[2];

	ofSync.fMoveSpeed[0] = fSpeed[0];
	ofSync.fMoveSpeed[1] = fSpeed[1];
	ofSync.fMoveSpeed[2] = fSpeed[2];

	bsOnfootSync.Write((BYTE)ID_PLAYER_SYNC);
	bsOnfootSync.Write((PCHAR)&ofSync, sizeof(stOnFootData));

	g_iRakClient->Send(&bsOnfootSync);
}

void iRakClient::SendFakeDriverSyncData(int iSAMPVehicleID, float fVehiclePos[3], float fVehicleHealth, float fMoveSpeed[3])
{
	stInCarData InCarData;
	RakNet::BitStream bsInCarData;

	struct actor_info *pSelfActor = actor_info_get( ACTOR_SELF, 0 );

	InCarData.sVehicleID = iSAMPVehicleID;
	InCarData.fMoveSpeed[0] = fMoveSpeed[0];
	InCarData.fMoveSpeed[1] = fMoveSpeed[1];
	InCarData.fMoveSpeed[2] = fMoveSpeed[2];
	InCarData.fPosition[0] = fVehiclePos[0];
	InCarData.fPosition[1] = fVehiclePos[1];
	InCarData.fPosition[2] = fVehiclePos[2];
	InCarData.fVehicleHealth = fVehicleHealth;
	InCarData.bytePlayerHealth = (BYTE)pSelfActor->hitpoints;
	InCarData.byteArmor = (BYTE)pSelfActor->armor;

	if ( cheat_state->state == CHEAT_STATE_VEHICLE )
		InCarData.byteCurrentWeapon = g_Players->pLocalPlayer->inCarData.byteCurrentWeapon;

	else if ( cheat_state->state == CHEAT_STATE_ACTOR )
		InCarData.byteCurrentWeapon = g_Players->pLocalPlayer->onFootData.byteCurrentWeapon;

	else InCarData.byteCurrentWeapon = 0;

	bsInCarData.Write((BYTE)ID_VEHICLE_SYNC);
	bsInCarData.Write((PCHAR)&InCarData,sizeof(stInCarData));

	g_iRakClient->Send(&bsInCarData, HIGH_PRIORITY, RELIABLE_SEQUENCED, 0);
}

void iRakClient::SendFakeBulletToPlayer(int PlayerID)
{
	actor_info *self = actor_info_get(ACTOR_SELF, NULL);
	actor_info *target = getGTAPedFromSAMPPlayerID(PlayerID);

	if(self != NULL && target != NULL)
	{
		if(g_Players->iIsListed[PlayerID] != 1)
			return;

		stBulletData bsSync;

		memset(&bsSync, 0, sizeof(stBulletData));

		bsSync.bHitType = (BYTE)BULLET_HIT_TYPE_PLAYER;
		bsSync.iHitID = (unsigned short)PlayerID;

		vect3_copy(&self->base.matrix[4 * 3], bsSync.fHitOrigin);
		vect3_copy(&target->base.matrix[4 * 3], bsSync.fHitTarget);

		if(cheat_state->_generic.bulletcrasher_p)
		{
			bsSync.fCenterOfHit[0] = (float)0x7FFFFFFF;
			bsSync.fCenterOfHit[1] = (float)0x7FFFFFFF;
			bsSync.fCenterOfHit[2] = (float)0x7FFFFFFF;
		}

		RakNet::BitStream bsSend;

		bsSend.Write((BYTE)ID_BULLET_SYNC);
		bsSend.Write((PCHAR)&bsSync, sizeof(stBulletData));

		g_iRakClient->Send(&bsSend, HIGH_PRIORITY, UNRELIABLE_SEQUENCED, 0);

		if(!cheat_state->_generic.bulletcrasher_p)
		{
			CVector vecOrigin = CVector(bsSync.fHitOrigin[0], bsSync.fHitOrigin[1], bsSync.fHitOrigin[2]);
			CVector vecDirection = CVector(bsSync.fHitTarget[0], bsSync.fHitTarget[1], bsSync.fHitTarget[2]);

			CColPoint* pColPoint;
			CEntitySAInterface	*pCollisionEntity = NULL;

			bool bCollision = GTAfunc_ProcessLineOfSight( &vecOrigin, &vecDirection, &pColPoint, &pCollisionEntity, 0, 0, 0, 0, 0, 0, 0, 0 );

			pPedSelf->GetWeapon(pPedSelf->GetCurrentWeaponSlot())->DoBulletImpact(0, 0, &vecOrigin, &vecDirection, 0, 0);
		}
	}
}

void iRakClient::SendFakeBulletToVehicle(int VehicleID)
{
	actor_info *self = actor_info_get(ACTOR_SELF, NULL);
	vehicle_info *target = getGTAVehicleFromSAMPVehicleID(VehicleID);

	if(self != NULL && target != NULL)
	{
		if(g_Vehicles->iIsListed[VehicleID] != 1)
			return;

		stBulletData bsSync;

		memset(&bsSync, 0, sizeof(stBulletData));

		bsSync.bHitType = (BYTE)BULLET_HIT_TYPE_VEHICLE;
		bsSync.iHitID = (unsigned short)VehicleID;

		vect3_copy(&self->base.matrix[4 * 3], bsSync.fHitOrigin);
		vect3_copy(&target->base.matrix[4 * 3], bsSync.fHitTarget);

		if(cheat_state->_generic.bulletcrasher_v)
		{
			bsSync.fCenterOfHit[0] = (float)0x7FFFFFFF;
			bsSync.fCenterOfHit[1] = (float)0x7FFFFFFF;
			bsSync.fCenterOfHit[2] = (float)0x7FFFFFFF;
		}

		RakNet::BitStream bsSend;

		bsSend.Write((BYTE)ID_BULLET_SYNC);
		bsSend.Write((PCHAR)&bsSync, sizeof(stBulletData));

		g_iRakClient->Send(&bsSend, HIGH_PRIORITY, UNRELIABLE_SEQUENCED, 0);

		if(!cheat_state->_generic.bulletcrasher_v)
		{
			CVector vecOrigin = CVector(bsSync.fHitOrigin[0], bsSync.fHitOrigin[1], bsSync.fHitOrigin[2]);
			CVector vecDirection = CVector(bsSync.fHitTarget[0], bsSync.fHitTarget[1], bsSync.fHitTarget[2]);

			CColPoint* pColPoint;
			CEntitySAInterface	*pCollisionEntity = NULL;

			bool bCollision = GTAfunc_ProcessLineOfSight( &vecOrigin, &vecDirection, &pColPoint, &pCollisionEntity, 0, 0, 0, 0, 0, 0, 0, 0 );

			pPedSelf->GetWeapon(pPedSelf->GetCurrentWeaponSlot())->DoBulletImpact(0, 0, &vecOrigin, &vecDirection, 0, 0);
		}
	}
}

void iRakClient::FuckUpVehicleComponents(int v)
{
	RakNet::BitStream bStream;

	uint32_t vehPanelStatus = encode_panels(3, 3, 3, 3, 3, 3, 3);
    uint32_t vehDoorStatus = encode_doors(4, 4, 4, 4);
	uint8_t vehLightStatus = 0;
	uint8_t vehTireStatus = 0;

	bStream.Write(v);
	bStream.Write((uint32_t)vehPanelStatus);
	bStream.Write((uint32_t)vehDoorStatus);
	bStream.Write((uint8_t)vehLightStatus);
    bStream.Write((uint8_t)vehTireStatus);

	g_iRakClient->RPC(RPC_DamageVehicle, &bStream);
}

void iRakClient::RestoreVehicleComponents(int v)
{
	RakNet::BitStream bStream;

    uint32_t vehDoorStatus = 0;
	uint32_t vehPanelStatus = 0;
	uint8_t vehLightStatus = 0;
	uint8_t vehTireStatus = 0;

	bStream.Write(v);
	bStream.Write(vehPanelStatus);
	bStream.Write(vehDoorStatus);
	bStream.Write(vehLightStatus);
    bStream.Write(vehTireStatus);

	g_iRakClient->RPC(RPC_DamageVehicle, &bStream);
}

void iRakClient::SendEnterVehicleNotification(uint16_t VehicleID, BOOL bPassenger)
{
	RakNet::BitStream bsSend;
	BYTE bytePassenger=0;

	if(bPassenger)
		bytePassenger = 1;

	bsSend.Write(VehicleID);
	bsSend.Write(bytePassenger);

	g_iRakClient->RPC(RPC_EnterVehicle, &bsSend);
}

void iRakClient::SendExitVehicleNotification(uint16_t VehicleID)
{
	RakNet::BitStream bsSend;

	bsSend.Write(VehicleID);

	g_iRakClient->RPC(RPC_ExitVehicle, &bsSend);
}

DWORD dwLastInVehicleDataSentTick = GetTickCount();

void iRakClient::SendInCarFullSyncData(stInCarData *picSync)
{
	if(picSync == NULL)
		return;

	if(dwLastInVehicleDataSentTick && dwLastInVehicleDataSentTick < (GetTickCount() - 2*(*(int*)(g_dwSAMP_Addr + 0xE609C))))
	{
		RakNet::BitStream bsVehicleSync;

		bsVehicleSync.Write((BYTE)ID_VEHICLE_SYNC);
		bsVehicleSync.Write((PCHAR)picSync,sizeof(stInCarData));
		pInternalRakClientInterface->Send(&bsVehicleSync,HIGH_PRIORITY,UNRELIABLE_SEQUENCED,0);

		dwLastInVehicleDataSentTick = GetTickCount();
	}
}

void iRakClient::EditAttachedObject(int iIndex, int iResponse, stAttachedObject *AttachedObjectData)
{
	RakNet::BitStream bsSend;

	bsSend.Write(iResponse);
	bsSend.Write(iIndex);
	bsSend.Write((PCHAR)AttachedObjectData, sizeof(stAttachedObject));

	g_iRakClient->RPC(RPC_EditAttachedObject, &bsSend);
}

void iRakClient::SendFakeDriverFullSyncData(stInCarData *picSync, int iUseCarPos)
{
	if (picSync == NULL)
		return;

	RakNet::BitStream bsVehicleSync;

	if(iUseCarPos)
	{
		int car_id = (int)( ((DWORD) g_Vehicles->pGTA_Vehicle[picSync->sVehicleID]) - (DWORD) pool_vehicle->start ) / 2584;
		struct vehicle_info *vinfo = vehicle_info_get( car_id, 0 );

		if(!vinfo)
			return;

		float fPos[3];
		vect3_copy( &vinfo->base.matrix[4 * 3], fPos );

		picSync->fPosition[0] = fPos[0];
		picSync->fPosition[1] = fPos[1];
		picSync->fPosition[2] = fPos[2];
	}

	bsVehicleSync.Write((BYTE)ID_VEHICLE_SYNC);
	bsVehicleSync.Write((PCHAR)picSync, sizeof(stInCarData));

	g_iRakClient->Send(&bsVehicleSync);
}

void iRakClient::SendFakeUnoccupiedFullSyncData(stUnoccupiedData *punocSync)
{
	if(punocSync == NULL)
		return;

	RakNet::BitStream bsUnocSync;

	bsUnocSync.Write((BYTE)ID_UNOCCUPIED_SYNC);
	bsUnocSync.Write((PCHAR)punocSync, sizeof(stUnoccupiedData));

	g_iRakClient->Send(&bsUnocSync);
}

void iRakClient::ReportPacketWasModified()
{
	RakNet::BitStream bsSend;

	bsSend.Write((BYTE)ID_MODIFIED_PACKET);

	g_iRakClient->Send(&bsSend, HIGH_PRIORITY, RELIABLE, 0);
}

void iRakClient::SendLagToServer()
{
	static int players = 0, vehicles = 0, pickups = 0, menus = 0, textdraws = 0, dialogs = 0, classes = 0;
	RakNet::BitStream bsPlayers, bsVehicles, bsPickups, bsMenus, bsTextDraws;

	bsPlayers.Write(players);
	bsVehicles.Write(vehicles);
	bsPickups.Write(pickups);
	bsMenus.Write(menus);
	bsTextDraws.Write(textdraws);

	g_iRakClient->RPC(RPC_ClickPlayer, &bsPlayers, HIGH_PRIORITY, RELIABLE_SEQUENCED, 0, false);
	g_iRakClient->RPC(RPC_EnterVehicle, &bsVehicles, HIGH_PRIORITY, RELIABLE_SEQUENCED, 0, false);
	g_iRakClient->RPC(RPC_ExitVehicle, &bsVehicles, HIGH_PRIORITY, RELIABLE_SEQUENCED, 0, false);
	g_iRakClient->RPC(RPC_PickedUpPickup, &bsPickups, HIGH_PRIORITY, RELIABLE_SEQUENCED, 0, false);
	g_iRakClient->RequestClass(classes);
	g_iRakClient->SendSpawn();
	g_iRakClient->SendDialogResponse(dialogs, 1, 1, "");
	g_iRakClient->RPC(RPC_MenuSelect, &bsMenus, HIGH_PRIORITY, RELIABLE_SEQUENCED, 0, false);
	g_iRakClient->RPC(RPC_MenuQuit, &bsMenus, HIGH_PRIORITY, RELIABLE_SEQUENCED, 0, false);
	g_iRakClient->RPC(RPC_ClickTextDraw, &bsTextDraws, HIGH_PRIORITY, RELIABLE_SEQUENCED, 0, false);

	players++;
	vehicles++;
	pickups++;
	menus++;
	textdraws++;
	dialogs++;
	classes++;

	if ( players >= SAMP_PLAYER_MAX ) players = 0;
	if ( vehicles >= SAMP_VEHICLE_MAX ) vehicles = 0;
	if ( pickups >= SAMP_PICKUP_MAX ) pickups = 0;
	if ( menus >= SAMP_MENUS_MAX ) menus = 0;
	if ( textdraws >= MAX_TEXTDRAW ) textdraws = 0;
	if ( dialogs >= SAMP_DIALOG_MAX ) dialogs = 0;
	if ( classes >= SAMP_CLASS_MAX ) classes = 0;
}