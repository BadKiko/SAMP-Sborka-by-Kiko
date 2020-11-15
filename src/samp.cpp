/*
	La Pirula Project
*/

#include "main.h"

#define SAMP_DLL				"samp.dll"
#define SAMP_CMP				"00E8000085D27408508B"

// randomStuff
extern int						iViewingInfoPlayer;
extern int						iLastFrame;
int								g_iSpectateEnabled = 0, g_iSpectateLock = 0, g_iSpectatePlayerID = -1;
int								g_iCursorEnabled = 0;

// global samp pointers
int								iIsSAMPSupported = 0;
int								g_renderSAMP_initSAMPstructs;
unsigned int					uiClientChallengeResponse;
stSAMP							*g_SAMP = NULL;
stPlayerPool					*g_Players = NULL;
stVehiclePool					*g_Vehicles = NULL;
stChatInfo						*g_Chat = NULL;
stInputInfo						*g_Input = NULL;
stKillInfo						*g_DeathList = NULL;
stDialogInfo					*g_Dialog = NULL;

// global managed support variables
stTranslateGTASAMP_vehiclePool	translateGTASAMP_vehiclePool;
stTranslateGTASAMP_pedPool		translateGTASAMP_pedPool;

stStreamedOutPlayerInfo			g_stStreamedOutInfo;
stCheckpointData				g_stCheckpointData;

CBotManager						*g_pBotManager = NULL;

int								g_iLastAttachedObjectIndex = -1;

bool							g_bPlayerCopierToggle;
int								g_iPlayerCopierTarget;
float							g_fPlayerCopierFollowOffset[3];

BYTE							g_byteLagCompensation;

//////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////// FUNCTIONS //////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////

// update SAMPGTA vehicle translation structure
void update_translateGTASAMP_vehiclePool ( void )
{
	traceLastFunc( "update_translateGTASAMP_vehiclePool()" );
	if ( !g_Vehicles )
		return;

	int iGTAID;
	for ( int i = 0; i <= SAMP_VEHICLE_MAX; i++ )
	{
		if ( g_Vehicles->iIsListed[i] != 1 )
			continue;
		if ( isBadPtr_writeAny(g_Vehicles->pSAMP_Vehicle[i], sizeof(stSAMPVehicle)) )
			continue;
		iGTAID = getVehicleGTAIDFromInterface( (DWORD *)g_Vehicles->pSAMP_Vehicle[i]->pGTA_Vehicle );
		if ( iGTAID <= SAMP_VEHICLE_MAX && iGTAID >= 0 )
		{
			translateGTASAMP_vehiclePool.iSAMPID[iGTAID] = i;
		}
	}
}

// update SAMPGTA ped translation structure
void update_translateGTASAMP_pedPool ( void )
{
	traceLastFunc( "update_translateGTASAMP_pedPool()" );
	if ( !g_Players )
		return;

	int iGTAID, i;
	for ( i = 0; i < SAMP_PLAYER_MAX; i++ )
	{
		if ( i == g_Players->sLocalPlayerID )
		{
			translateGTASAMP_pedPool.iSAMPID[0] = i;
			continue;
		}

		if ( isBadPtr_writeAny(g_Players->pRemotePlayer[i], sizeof(stRemotePlayer)) )
			continue;
		if ( isBadPtr_writeAny(g_Players->pRemotePlayer[i]->pPlayerData, sizeof(stRemotePlayerData)) )
			continue;
		if ( isBadPtr_writeAny(g_Players->pRemotePlayer[i]->pPlayerData->pSAMP_Actor, sizeof(stSAMPPed)) )
			continue;

		iGTAID = getPedGTAIDFromInterface( (DWORD *)g_Players->pRemotePlayer[i]->pPlayerData->pSAMP_Actor->pGTA_Ped );
		if ( iGTAID <= SAMP_PLAYER_MAX && iGTAID >= 0 )
		{
			translateGTASAMP_pedPool.iSAMPID[iGTAID] = i;
		}
	}
}

//ClientCommands

extern int	joining_server;
void cmd_change_server ( char *param )	//127.0.0.1 7777 Username Password
{
	traceLastFunc( "cmd_change_server()" );

	bool	success = false;

	char	IP[128], Nick[MAX_PLAYER_NAME], Password[128] = "", Port[128];
	int		iPort;

	int ipc = sscanf( param, "%s%s%s%s", IP, Port, Nick, Password );
	if ( ipc < 2 )
	{
		addMessageToChatWindow( "USAGE: /.change_server <ip> <port> <nickname> <password>" );
		return;
	}
	if ( stricmp( IP, "NULL" ) == NULL )
		strcpy( IP, g_SAMP->szIP );

	if ( stricmp( Port, "NULL" ) == NULL )
		iPort = g_SAMP->ulPort;
	else
		iPort = atoi( Port );

	if ( ipc > 2 )
	{
		if ( stricmp( Nick, "NULL" ) != NULL )
		{
			if ( strlen( Nick ) > ALLOWED_PLAYER_NAME_LENGTH )
				Nick[ALLOWED_PLAYER_NAME_LENGTH] = '\0';
			setLocalPlayerName( Nick );
		}
	}
	if ( ipc > 3 )
	{
		if ( stricmp( Password, "NULL" ) == NULL )
			strcpy( Password, "" );
	}

	changeServer( IP, iPort, Password );
}

typedef int (__cdecl *AUTH_GEN)(char *out, char *incoming_key);
void gen_auth_key(char *out, char *incoming_key)
{
	if (g_dwSAMP_Addr == NULL) 
		return;

	((AUTH_GEN)(LPVOID)((DWORD)g_dwSAMP_Addr+0x28E39B))(out, incoming_key);
}

typedef int (__cdecl *GPCI_GEN)(char *out, char *generator, unsigned int factor);
void gen_gpci(char *out, char* gtafolder)
{ 
	if (g_dwSAMP_Addr == NULL) 
		return;

	((GPCI_GEN)(LPVOID)((DWORD)g_dwSAMP_Addr+0x27A99E))(out, gtafolder, 0x3E9);
}

void gen_rand_gpci(char *out)
{ 
	if (g_dwSAMP_Addr == NULL) 
		return;

	char random_string[32] = {0}; 
	gen_random(random_string, (rand()%31)+1);

	gen_gpci(out, random_string);
}

void cmd_change_name ( char *param )
{
	if ( strlen(param) == 0 )
	{
		addMessageToChatWindow( "/.change_name <your new nickname>" );
		return;
	}

	char auth_bs[4*16];
	gen_rand_gpci(auth_bs);

	int iVersion = NETGAME_VERSION;
	BYTE byteMod = 1;

	BYTE byteAuthBSLen;
	byteAuthBSLen = (BYTE)strlen(auth_bs);
	BYTE byteNameLen = (BYTE)strlen(param);

	RakNet::BitStream bsSend;

	bsSend.Write(iVersion);
	bsSend.Write(byteMod);
	bsSend.Write(byteNameLen);
	bsSend.Write(param, byteNameLen);

	bsSend.Write(uiClientChallengeResponse);
	bsSend.Write(byteAuthBSLen);
	bsSend.Write(auth_bs, byteAuthBSLen);
	char szClientVer[] = CLIENT_VERSION;
	const BYTE iClientVerLen = (sizeof(szClientVer)-1);
	bsSend.Write(iClientVerLen);
	bsSend.Write(szClientVer, iClientVerLen);

	setLocalPlayerName(param);

	g_iRakClient->RPC(RPC_ClientJoin, &bsSend, HIGH_PRIORITY, RELIABLE);
	playerSpawn();

	cheat_state_text("Changed name to %s and respawned.");
}

void cmd_change_server_fav ( char *param )
{
	traceLastFunc( "cmd_change_server_fav()" );

	if ( strlen(param) == 0 )
	{
		addMessageToChatWindow( "/.fav_server <server name/part of server name>" );
		addMessageToChatWindow( "In order to see the favorite server list type: /.fav_server list" );
		return;
	}

	if ( strncmp(param, "list", 4) == 0 )
	{
		int count = 0;
		for ( int i = 0; i < INI_SERVERS_MAX; i++ )
		{
			if ( set.server[i].server_name == NULL )
				continue;

			count++;
			addMessageToChatWindow( "%s", set.server[i].server_name );
		}
		if ( count == 0 )
			addMessageToChatWindow( "No servers in favorite server list. Edit the ini file to add some." );
		return;
	}

	for ( int i = 0; i < INI_SERVERS_MAX; i++ )
	{
		if ( set.server[i].server_name == NULL || set.server[i].ip == NULL
			|| strlen(set.server[i].ip) < 7 || set.server[i].port == 0 )
			continue;

		if ( !findstrinstr((char *)set.server[i].server_name, param) )
			continue;

		if ( !set.use_current_name )
			setLocalPlayerName( set.server[i].nickname );

		changeServer( set.server[i].ip, set.server[i].port, set.server[i].password );

		return;
	}

	addMessageToChatWindow( "/.fav_server <server name/part of server name>" );
	return;
}

// strtokstristr?
bool findstrinstr ( char *text, char *find )
{
	char	realtext[256];
	char	subtext[256];
	char	*result;
	char	*next;
	char	temp;
	int		i = 0;

	traceLastFunc( "findstrinstr()" );

	// can't find stuff that isn't there unless you are high
	if ( text == NULL || find == NULL )
		return false;

	// lower case text ( sizeof()-2 = 1 for array + 1 for termination after while() )
	while ( text[i] != NULL && i < (sizeof(realtext)-2) )
	{
		temp = text[i];
		if ( isupper(temp) )
			temp = tolower( temp );
		realtext[i] = temp;
		i++;
	}
	realtext[i] = 0;

	// replace unwanted characters/spaces with dots
	i = 0;
	while ( find[i] != NULL && i < (sizeof(subtext)-2) )
	{
		temp = find[i];
		if ( isupper(temp) )
			temp = tolower( temp );
		if ( !isalpha(temp) )
			temp = '.';
		subtext[i] = temp;
		i++;
	}
	subtext[i] = 0;

	// use i to count the successfully found text parts
	i = 0;

	// split and find every part of subtext/find in text
	result = &subtext[0];
	while ( *result != NULL )
	{
		next = strstr( result, "." );
		if ( next != NULL )
		{
			// more than one non-alphabetic character
			if ( next == result )
			{
				do
					next++;
				while ( *next == '.' );

				if ( *next == NULL )
					return (i != 0);
				result = next;
				next = strstr( result, "." );
				if ( next != NULL )
					*next = NULL;
			}
			else
				*next = NULL;
		}

		if ( strstr(realtext, result) == NULL )
			return false;

		if ( next == NULL )
			return true;

		i++;
		result = next + 1;
	}

	return false;
}

void cmd_tele_loc ( char *param )
{
	if ( strlen(param) == 0 )
	{
		addMessageToChatWindow( "USAGE: /.tele_loc <location name>" );
		addMessageToChatWindow( "Use /.tele_locations to show the location names." );
		addMessageToChatWindow( "The more specific you are on location name the better the result." );
		return;
	}

	for ( int i = 0; i < STATIC_TELEPORT_MAX; i++ )
	{
		if ( strlen(set.static_teleport_name[i]) == 0 || vect3_near_zero(set.static_teleport[i].pos) )
			continue;

		if ( !findstrinstr(set.static_teleport_name[i], param) )
			continue;

		cheat_state_text( "Teleported to: %s.", set.static_teleport_name[i] );
		cheat_teleport( set.static_teleport[i].pos, set.static_teleport[i].interior_id );
		return;
	}

	addMessageToChatWindow( "USAGE: /.tele_loc <location name>" );
	addMessageToChatWindow( "Use /.tele_locations to show the location names." );
	addMessageToChatWindow( "The more specific you are on location name the better the result." );
}

void cmd_tele_locations ()
{
	for ( int i = 0; i < STATIC_TELEPORT_MAX; i++ )
	{
		if ( strlen(set.static_teleport_name[i]) == 0 || vect3_near_zero(set.static_teleport[i].pos) )
			continue;
		addMessageToChatWindow( "%s", set.static_teleport_name[i] );
	}

	addMessageToChatWindow( "To teleport use the menu or: /.tele_loc <location name>" );
}

void cmd_pickup ( char *params )
{
	if ( !strlen( params ) )
	{
		addMessageToChatWindow( "USAGE: /.pickup <pickup id>" );
		return;
	}

	g_iRakClient->SendPickUp( atoi( params ) );
}

void cmd_setclass ( char *params )
{
	if ( !strlen( params ) )
	{
		addMessageToChatWindow( "USAGE: /.setclass <class id>" );
		return;
	}

	g_iRakClient->RequestClass( atoi( params ) );
	g_iRakClient->SendSpawn();
}

void cmd_fakekill ( char *params )
{
	int killer, reason, amount;
	if ( !strlen( params ) || sscanf( params, "%d%d%d", &killer, &reason, &amount ) < 3 )
	{
		addMessageToChatWindow( "USAGE: /.fakekill <killer id> <reason> <amount>" );
		return;
	}
	if ( amount < 1 || killer < 0 || killer > SAMP_PLAYER_MAX )
		return;

	for ( int i = 0; i < amount; i++ ) 
		g_iRakClient->SendDeath( killer, reason );
}

void cmd_respond_dialog ( char *params )
{
	traceLastFunc( "cmd_respond_dialog()" );

	char strDialogID[128], strButtonID[128], strListBoxItem[128], strInputResp[128];

	int ipc = sscanf( params, "%s%s%s%s", strDialogID, strButtonID, strListBoxItem, strInputResp );
	if ( ipc < 4 )
	{
		addMessageToChatWindow( "USAGE: /.respond_dialog <dialog id> <button id> <listboxitem> <inputresp>" );
		return;
	}

	int iDialogID, iButtonID, iListBoxItem;

	iDialogID = atoi(strDialogID);
	iButtonID = atoi(strButtonID);
	iListBoxItem = atoi(strListBoxItem);

	g_iRakClient->SendDialogResponse(iDialogID, iButtonID, iListBoxItem, strInputResp);
}

void cmd_jacker ( char *params )
{
	traceLastFunc( "cmd_jacker()" );

	char szPlayerID[128], szEnterCar[128];

	int ipc = sscanf( params, "%s%s", szPlayerID, szEnterCar );
	if ( ipc < 2 )
	{
		addMessageToChatWindow( "USAGE: /.jacker <playerid> <enter car (0/1)>" );
		return;
	}

	int iPlayerID = atoi(szPlayerID), iEnterCar = atoi(szEnterCar);

	if ( iPlayerID < 0 || iPlayerID > SAMP_PLAYER_MAX )
		return;

	if ( iEnterCar != 0 && iEnterCar != 1)
		return;

	if(g_Players->sLocalPlayerID == iPlayerID || g_Players->pRemotePlayer[iPlayerID] == NULL)
		return;

	if(getPlayerState(iPlayerID) != PLAYER_STATE_DRIVER)
		return;

	struct actor_info *pSelfActor = actor_info_get( ACTOR_SELF, 0 );
	struct vehicle_info *pTargetVehicle = g_Players->pRemotePlayer[iPlayerID]->pPlayerData->pSAMP_Vehicle->pGTA_Vehicle;

	stInCarData InCarData;
	RakNet::BitStream bsInCarData;
	
	stOnFootData OnFootData;
	RakNet::BitStream bsOnFootData;

	InCarData.sVehicleID = g_Players->pRemotePlayer[iPlayerID]->pPlayerData->inCarData.sVehicleID;
	InCarData.sLeftRightKeys = g_Players->pRemotePlayer[iPlayerID]->pPlayerData->inCarData.sLeftRightKeys;
	InCarData.sUpDownKeys = g_Players->pRemotePlayer[iPlayerID]->pPlayerData->inCarData.sUpDownKeys;
	InCarData.sKeys = g_Players->pRemotePlayer[iPlayerID]->pPlayerData->inCarData.sKeys;
	InCarData.fQuaternion[0] = g_Players->pRemotePlayer[iPlayerID]->pPlayerData->inCarData.fQuaternion[0];
	InCarData.fQuaternion[1] = g_Players->pRemotePlayer[iPlayerID]->pPlayerData->inCarData.fQuaternion[1];
	InCarData.fQuaternion[2] = g_Players->pRemotePlayer[iPlayerID]->pPlayerData->inCarData.fQuaternion[2];
	InCarData.fQuaternion[3] = g_Players->pRemotePlayer[iPlayerID]->pPlayerData->inCarData.fQuaternion[3];
	InCarData.fPosition[0] = g_Players->pRemotePlayer[iPlayerID]->pPlayerData->inCarData.fPosition[0];
	InCarData.fPosition[1] = g_Players->pRemotePlayer[iPlayerID]->pPlayerData->inCarData.fPosition[1];
	InCarData.fPosition[2] = g_Players->pRemotePlayer[iPlayerID]->pPlayerData->inCarData.fPosition[2];
	InCarData.fVehicleHealth = g_Players->pRemotePlayer[iPlayerID]->pPlayerData->inCarData.fVehicleHealth;
	InCarData.bytePlayerHealth = (BYTE)pSelfActor->hitpoints;
	InCarData.byteArmor = (BYTE)pSelfActor->armor;
	
	if ( cheat_state->state == CHEAT_STATE_VEHICLE )
		InCarData.byteCurrentWeapon = g_Players->pLocalPlayer->inCarData.byteCurrentWeapon;

	else if ( cheat_state->state == CHEAT_STATE_ACTOR )
		InCarData.byteCurrentWeapon = g_Players->pLocalPlayer->onFootData.byteCurrentWeapon;

	else InCarData.byteCurrentWeapon = 0;

	InCarData.byteSiren = g_Players->pRemotePlayer[iPlayerID]->pPlayerData->inCarData.byteSiren;
	InCarData.byteLandingGearState = g_Players->pRemotePlayer[iPlayerID]->pPlayerData->inCarData.byteLandingGearState;

	bsInCarData.Write((BYTE)ID_VEHICLE_SYNC);
	bsInCarData.Write((PCHAR)&InCarData,sizeof(stInCarData));

	OnFootData.fPosition[0] = pSelfActor->base.coords[0];
	OnFootData.fPosition[1] = pSelfActor->base.coords[1];
	OnFootData.fPosition[2] = pSelfActor->base.coords[2];
	OnFootData.byteHealth = (BYTE)pSelfActor->hitpoints;
	OnFootData.byteArmor = (BYTE)pSelfActor->armor;

	if ( cheat_state->state == CHEAT_STATE_VEHICLE )
		OnFootData.byteCurrentWeapon = g_Players->pLocalPlayer->inCarData.byteCurrentWeapon;

	else if ( cheat_state->state == CHEAT_STATE_ACTOR )
		OnFootData.byteCurrentWeapon = g_Players->pLocalPlayer->onFootData.byteCurrentWeapon;

	else OnFootData.byteCurrentWeapon = 0;

	bsOnFootData.Write((BYTE)ID_PLAYER_SYNC);
	bsOnFootData.Write((PCHAR)&OnFootData,sizeof(stOnFootData));

	g_iRakClient->Send(&bsOnFootData, HIGH_PRIORITY, RELIABLE_SEQUENCED, 0);

	for(int x = 0; x < 3; x++)
		g_iRakClient->Send(&bsInCarData, HIGH_PRIORITY, RELIABLE_SEQUENCED, 0);

	if(iEnterCar == 1)
	{
		GTAfunc_PutActorInCar(pTargetVehicle);
		pGameInterface->GetCamera()->RestoreWithJumpCut();
	}

	cheat_state_text("%s jacked out.", getPlayerName(iPlayerID));
}

void cmd_shotrepeater ( char *param )
{
	traceLastFunc( "cmd_shotrepeater()" );

	if ( !strlen( param ) )
	{
		addMessageToChatWindow( "USAGE: /.shotrepeater <amount(0 = off)>" );
		return;
	}

	cheat_state->_generic.shotrepeater = atoi(param);
}

void sendClientJoinWithRandomName()
{
	char auth_bs[4*16];
	gen_rand_gpci(auth_bs);

	char random_name[16];
	gen_random(random_name, 16);

	int iVersion = NETGAME_VERSION;
	BYTE byteMod = 1;

	BYTE byteAuthBSLen;
	byteAuthBSLen = (BYTE)strlen(auth_bs);
	BYTE byteNameLen = (BYTE)strlen(random_name);

	RakNet::BitStream bsSend;

	bsSend.Write(iVersion);
	bsSend.Write(byteMod);
	bsSend.Write(byteNameLen);
	bsSend.Write(random_name, byteNameLen);

	bsSend.Write(uiClientChallengeResponse);
	bsSend.Write(byteAuthBSLen);
	bsSend.Write(auth_bs, byteAuthBSLen);
	char szClientVer[] = CLIENT_VERSION;
	const BYTE iClientVerLen = (sizeof(szClientVer)-1);
	bsSend.Write(iClientVerLen);
	bsSend.Write(szClientVer, iClientVerLen);

	g_iRakClient->RPC(RPC_ClientJoin, &bsSend, HIGH_PRIORITY, RELIABLE);
}

void joinflooder(void* Argument)
{
	for(int x = 0; x < (int)Argument; x++)
		sendClientJoinWithRandomName();
}

void cmd_joinflood ( char *param )
{
	if ( !strlen( param ) )
	{
		addMessageToChatWindow( "/.joinflood <amount>" );
		return;
	}

	_beginthread(joinflooder, 0, (void*)atoi(param));
}

void cmd_dump_objects ( char *params )
{
	dumpStreamedObjects();
}

void cmd_repaint ( char *params )
{
	traceLastFunc( "cmd_repaint()" );

	int VehicleID, Color1, Color2;

	if ( !strlen( params ) || sscanf( params, "%d%d%d", &VehicleID, &Color1, &Color2 ) < 3 )
	{
		addMessageToChatWindow( "/.repaint <vehicleid> <color1> <color2>" );
		return;
	}

	if ( g_Vehicles->iIsListed[VehicleID] != 1 )
		return;

	if ( g_Vehicles->pSAMP_Vehicle[VehicleID] == NULL )
		return;

	if ( g_Vehicles->pSAMP_Vehicle[VehicleID]->pGTA_Vehicle == NULL )
		return;

	repaintVehicle(VehicleID, Color1, Color2);
}

void cmd_repaint_all ( char *params )
{
	traceLastFunc( "cmd_repaint_all()" );

	int Color1, Color2;

	if ( !strlen( params ) || sscanf( params, "%d%d", &Color1, &Color2 ) < 2 )
	{
		addMessageToChatWindow( "/.repaint_all <color1> <color2>" );
		return;
	}

	repaintStreamedVehicles(Color1, Color2);
}

void cmd_sendbullet ( char *params )
{
	traceLastFunc( "cmd_sendbullet()" );

	int PlayerID = -1;

	if ( !strlen( params ) )
	{
		addMessageToChatWindow( "USAGE: /.sendbullet <playerid>" );
		return;
	}

	PlayerID = atoi(params);

	if(PlayerID == -1)
		return;

	g_iRakClient->SendFakeBulletToPlayer(PlayerID);
}

void cmd_goto ( char *param )
{
	traceLastFunc( "cmd_goto()" );

	if( strlen(param) == 0 )
	{
		addMessageToChatWindow( "/.goto <playerid>");
		return;
	}

	int ID = atoi(param);

	if ( g_Players == NULL || ID < 0 || ID > SAMP_PLAYER_MAX )
		return;

	return TriggerPlayerWarpMenu(ID);
}

void cmd_gethere ( char *param )
{
	traceLastFunc( "cmd_gethere()" );

	if( strlen(param) == 0 )
	{
		addMessageToChatWindow( "/.gethere <playerid>");
		return;
	}

	gethere(atoi(param));
	return;
}

void cmd_slap ( char *params )
{
	traceLastFunc( "cmd_slap()" );

	char szPlayerID[128], szVehicleID[128];

	int ipc = sscanf( params, "%s%s", szPlayerID, szVehicleID );
	if ( ipc < 2 )
	{
		addMessageToChatWindow( "USAGE: /.slap <playerid> <vehicleid>" );
		return;
	}

	int iPlayerID = atoi(szPlayerID), iVehicleID = atoi(szVehicleID);

	if ( iPlayerID < 0 || iPlayerID > SAMP_PLAYER_MAX )
		return;

	if(g_Players->sLocalPlayerID == iPlayerID || g_Players->pRemotePlayer[iPlayerID] == NULL)
		return;

	if(!ValidVehicle(iVehicleID))
		return;

	if (getPlayerState(iPlayerID) != PLAYER_STATE_ONFOOT && getPlayerState(iPlayerID) != PLAYER_STATE_DRIVER)
		return;

	float coord[3] = { g_Players->pRemotePlayer[iPlayerID]->pPlayerData->onFootData.fPosition[0], g_Players->pRemotePlayer[iPlayerID]->pPlayerData->onFootData.fPosition[1], g_Players->pRemotePlayer[iPlayerID]->pPlayerData->onFootData.fPosition[2] };
	float pos[3] = { pPedSelf->GetPosition()->fX, pPedSelf->GetPosition()->fY, pPedSelf->GetPosition()->fZ };

	struct vehicle_info *info = g_SAMP->pPools->pPool_Vehicle->pSAMP_Vehicle[iVehicleID]->pGTA_Vehicle;
	struct actor_info *self = actor_info_get(ACTOR_SELF, ACTOR_ALIVE);

	self->vehicle = info;

	stInCarData sync;
	RakNet::BitStream bsVehicleSync;

	memset(&sync, 0, sizeof(stInCarData));

	sync.sVehicleID = iVehicleID;
	sync.fVehicleHealth = info->hitpoints;
	sync.fMoveSpeed[0] = info->speed[0];
	sync.fMoveSpeed[1] = info->speed[1];
	sync.fMoveSpeed[2] = info->speed[2];
	sync.bytePlayerHealth = self->hitpoints;
	sync.byteArmor = self->armor;

	cheat_vehicle_teleport(info, coord, 0);

	GTAfunc_RemoveActorFromCarAndPutAt(pos); 

	vect3_copy(&info->base.matrix[12], sync.fPosition);

	bsVehicleSync.Write((BYTE)ID_VEHICLE_SYNC);
	bsVehicleSync.Write((PCHAR)&sync,sizeof(stInCarData));
	g_iRakClient->Send(&bsVehicleSync, HIGH_PRIORITY, RELIABLE_SEQUENCED, 0);

	sync.fMoveSpeed[2] = info->speed[2] + 6.0f;
	vect3_copy(sync.fMoveSpeed, info->speed);

	bsVehicleSync.Reset();
	bsVehicleSync.Write((BYTE)ID_VEHICLE_SYNC);
	bsVehicleSync.Write((PCHAR)&sync,sizeof(stInCarData));
	g_iRakClient->Send(&bsVehicleSync, HIGH_PRIORITY, RELIABLE_SEQUENCED, 0);
}

void cmd_randv ( char *param )
{
	traceLastFunc( "cmd_randv()" );

	std::list<int> ValidVehicleIDs;

	for ( int xv = 0; xv < SAMP_VEHICLE_MAX; xv++ )
	{
		if(!ValidVehicle(xv))
			continue;

		ValidVehicleIDs.push_back(xv);
	}

	srand(time(NULL));

	std::list<int>::iterator rand_it = ValidVehicleIDs.begin();
	std::advance(rand_it, std::rand() % ValidVehicleIDs.size());

	int v = *rand_it;

	addMessageToChatWindow("Random streamed vehicle: %s(%d)%s.",
		gta_vehicle_get_by_id(g_SAMP->pPools->pPool_Vehicle->pSAMP_Vehicle[v]->pGTA_Vehicle->base.model_alt_id)->name,
		v,
		(g_SAMP->pPools->pPool_Vehicle->pSAMP_Vehicle[v]->pGTA_Vehicle->passengers[0] == NULL) ? "" : " (occupied)");
}

void cmd_fakekick ( char *param )
{
	traceLastFunc( "cmd_fakekick()" );

	g_iRakClient->SendEnterVehicleNotification(0xFFFF, 0);
}

// new functions to check for bad pointers
int isBadPtr_SAMP_iVehicleID ( int iVehicleID )
{
	if ( g_Vehicles == NULL || iVehicleID == (uint16_t)-1)
		return 1;
	return !g_Vehicles->iIsListed[iVehicleID];

	// this hasn't been required yet
	//if (g_Vehicles->pSAMP_Vehicle[iVehicleID] == NULL) continue;
}

int isBadPtr_SAMP_iPlayerID ( int iPlayerID )
{
	if ( g_Players == NULL || iPlayerID < 0 || iPlayerID > SAMP_PLAYER_MAX)
		return 1;
	return !g_Players->iIsListed[iPlayerID];
}

void getSamp ()
{
	if ( set.basic_mode )
		return;

	uint32_t	samp_dll = getSampAddress();

	if ( samp_dll != NULL )
	{
		g_dwSAMP_Addr = ( uint32_t ) samp_dll;

		if ( g_dwSAMP_Addr != NULL )
		{
			if ( memcmp_safe((uint8_t *)g_dwSAMP_Addr + 0xBABE, hex_to_bin(SAMP_CMP), 10) )
			{
				strcpy(g_szSAMPVer, "SA:MP 0.3z");
				Log( "%s was detected. g_dwSAMP_Addr: 0x%p", g_szSAMPVer, g_dwSAMP_Addr );

				// anticheat patch
				struct patch_set fuckAC =
				{
					"Anticheat patch", 0, 0,
					{
						{ 1, (void *)( g_dwSAMP_Addr + 0x61430 ), NULL, (uint8_t *)"\xC3", 0 }, 
						{ 1, (void *)( g_dwSAMP_Addr + 0x5B68B ), NULL, (uint8_t *)"\xEB", 0 },
						{ 1, (void *)( g_dwSAMP_Addr + 0x71410 ), NULL, (uint8_t *)"\xEB", 0 }
					}
				};
				patcher_install( &fuckAC );

				DWORD ACPatchOffsets[] =
				{
					0x5B681, 0x219F66
				};
				DWORD ACPatchOffsets2[] = 
				{
					0x225798
				};
				static DWORD ACC[2] = { 0, 0 };
				DWORD *pACC[] = { &ACC[0], &ACC[2] };
				for ( int i = 0; i < _countof( ACPatchOffsets ); i++ )
					memcpy_safe( ( void * )( g_dwSAMP_Addr + ACPatchOffsets[i] ), &pACC[0], 4 );
				for ( int i = 0; i < _countof( ACPatchOffsets2 ); i++ )
					memcpy_safe( (void *)( g_dwSAMP_Addr + ACPatchOffsets2[i] ), &pACC[1], 4 );

				iIsSAMPSupported = 1;
			}
			else
			{
				Log( "Unknown SA:MP version. Running in basic mode." );
				iIsSAMPSupported = 0;
				set.basic_mode = true;

				g_dwSAMP_Addr = NULL;
			}
		}
	}
	else
	{
		iIsSAMPSupported = 0;
		set.basic_mode = true;
		Log( "samp.dll not found. Running in basic mode." );
	}

	return;
}

uint32_t getSampAddress ()
{
	if ( set.run_mode == RUNMODE_SINGLEPLAYER )
		return 0x0;

	uint32_t	samp_dll;

	if ( set.run_mode == RUNMODE_SAMP )
	{
		if ( set.wine_compatibility )
		{
			HMODULE temp = LoadLibrary( SAMP_DLL );
			__asm mov samp_dll, eax
		}
		else
		{
			void	*temp = dll_baseptr_get( SAMP_DLL );
			__asm mov samp_dll, eax
		}
	}

	if ( samp_dll == NULL )
		return 0x0;

	return samp_dll;
}

struct stSAMP *stGetSampInfo ( void )
{
	if ( g_dwSAMP_Addr == NULL )
		return NULL;

	uint32_t	info_ptr;
	info_ptr = ( UINT_PTR ) * ( uint32_t * ) ( (uint8_t *) (void *)((uint8_t *)g_dwSAMP_Addr + SAMP_INFO_OFFSET) );
	if ( info_ptr == NULL )
		return NULL;

	return (struct stSAMP *)info_ptr;
}

struct stChatInfo *stGetSampChatInfo ( void )
{
	if ( g_dwSAMP_Addr == NULL )
		return NULL;

	uint32_t	chat_ptr;
	chat_ptr = ( UINT_PTR ) * ( uint32_t * ) ( (uint8_t *) (void *)((uint8_t *)g_dwSAMP_Addr + SAMP_CHAT_INFO_OFFSET) );
	if ( chat_ptr == NULL )
		return NULL;

	return (struct stChatInfo *)chat_ptr;
}

struct stInputInfo *stGetInputInfo ( void )
{
	if ( g_dwSAMP_Addr == NULL )
		return NULL;

	uint32_t	input_ptr;
	input_ptr = ( UINT_PTR ) * ( uint32_t * ) ( (uint8_t *) (void *)((uint8_t *)g_dwSAMP_Addr + SAMP_CHAT_INPUT_INFO_OFFSET) );
	if ( input_ptr == NULL )
		return NULL;

	return (struct stInputInfo *)input_ptr;
}

struct stKillInfo *stGetKillInfo ( void )
{
	if ( g_dwSAMP_Addr == NULL )
		return NULL;

	uint32_t	kill_ptr;
	kill_ptr = ( UINT_PTR ) * ( uint32_t * ) ( (uint8_t *) (void *)((uint8_t *)g_dwSAMP_Addr + SAMP_KILL_INFO_OFFSET) );
	if ( kill_ptr == NULL )
		return NULL;

	return (struct stKillInfo *)kill_ptr;
}

struct stDialogInfo *stGetDialogInfo ( void )
{
	if ( g_dwSAMP_Addr == NULL )
		return NULL;

	uint32_t	dialog_ptr;
	dialog_ptr = ( UINT_PTR ) * ( uint32_t * ) ( (uint8_t *) (void *)((uint8_t *)g_dwSAMP_Addr + SAMP_DIALOG_INFO_OFFSET) );
	if ( dialog_ptr == NULL )
		return NULL;

	return (struct stDialogInfo *)dialog_ptr;
}

D3DCOLOR samp_color_get ( int id, DWORD trans )
{
	if ( g_dwSAMP_Addr == NULL )
		return NULL;

	D3DCOLOR	*color_table;
	if ( id < 0 || id >= (SAMP_PLAYER_MAX + 3) )
		return D3DCOLOR_ARGB( 0xFF, 0x99, 0x99, 0x99 );

	switch ( id )
	{
	case ( SAMP_PLAYER_MAX ):
		return 0xFF888888;

	case ( SAMP_PLAYER_MAX + 1 ):
		return 0xFF0000AA;

	case ( SAMP_PLAYER_MAX + 2 ):
		return 0xFF63C0E2;
	}

	color_table = ( D3DCOLOR * ) ( (uint8_t *)g_dwSAMP_Addr + SAMP_COLOR_OFFSET );
	return ( color_table[id] >> 8 ) | trans;
}

void spectatePlayer(int iPlayerID)
{
	if ( iPlayerID == -1 )
	{
		GTAfunc_TogglePlayerControllable(0);
		GTAfunc_LockActor(0);
		pGameInterface->GetCamera()->RestoreWithJumpCut();

		g_iSpectateEnabled = 0;
		g_iSpectateLock = 0;
		g_iSpectatePlayerID = -1;
		return;
	}

	g_iSpectatePlayerID = iPlayerID;
	g_iSpectateLock = 0;
	g_iSpectateEnabled = 1;
}

void spectateHandle()
{
	if(g_iSpectateEnabled)
	{
		if(g_iSpectateLock) return;

		if(g_iSpectatePlayerID != -1)
		{
			if(g_Players->iIsListed[g_iSpectatePlayerID] != 0)
			{
				if(g_Players->pRemotePlayer[g_iSpectatePlayerID] != NULL)
				{
					int iState = getPlayerState(g_iSpectatePlayerID);

					if(iState == PLAYER_STATE_ONFOOT)
					{
						struct actor_info *pPlayer = getGTAPedFromSAMPPlayerID(g_iSpectatePlayerID);
						if(pPlayer == NULL) return;
						GTAfunc_CameraOnActor(pPlayer);
						g_iSpectateLock = 1;
					}
					else if(iState == PLAYER_STATE_DRIVER)
					{
						struct vehicle_info *pPlayerVehicleID = g_Players->pRemotePlayer[g_iSpectatePlayerID]->pPlayerData->pSAMP_Vehicle->pGTA_Vehicle;
						if(pPlayerVehicleID == NULL) return;
						GTAfunc_CameraOnVehicle(pPlayerVehicleID);
						g_iSpectateLock = 1;
					}
					else if(iState == PLAYER_STATE_PASSENGER)
					{
						struct vehicle_info *pPlayerVehicleID = g_Players->pRemotePlayer[g_iSpectatePlayerID]->pPlayerData->pSAMP_Vehicle->pGTA_Vehicle;
						if(pPlayerVehicleID == NULL) return;
						GTAfunc_CameraOnVehicle(pPlayerVehicleID);
						g_iSpectateLock = 1;
					}
				}
				else
				{
					cheat_state_text("Player is not streamed in");
					g_iSpectateEnabled = 0;
				}
			}
		}
	}
}

void sampMainCheat ()
{
	traceLastFunc( "sampMainCheat()" );
	const int i = sizeof( stRemotePlayerData );
	// g_Vehicles & g_Players pointers need to be refreshed or nulled
	if ( isBadPtr_writeAny(g_SAMP->pPools, sizeof(stSAMPPools)) )
	{
		g_Vehicles = NULL;
		g_Players = NULL;
	}
	else if ( g_Vehicles != g_SAMP->pPools->pPool_Vehicle || g_Players != g_SAMP->pPools->pPool_Player )
	{
		if ( isBadPtr_writeAny(g_SAMP->pPools->pPool_Vehicle, sizeof(stVehiclePool)) )
			g_Vehicles = NULL;
		else
			g_Vehicles = g_SAMP->pPools->pPool_Vehicle;
		if ( isBadPtr_writeAny(g_SAMP->pPools->pPool_Player, sizeof(stPlayerPool)) )
			g_Players = NULL;
		else
			g_Players = g_SAMP->pPools->pPool_Player;
	}

	// update GTA to SAMP translation structures
	update_translateGTASAMP_vehiclePool();
	update_translateGTASAMP_pedPool();

	spectateHandle();

	// Anti-Crasher 0.3z
	memset_safe((DWORD*)(g_dwSAMP_Addr + 0x10B7F8), 0x00, 1);
	memset_safe((uint32_t *)(g_dwSAMP_Addr + 0x61430), 0xC3, 1);
	memset_safe((uint32_t *)(g_dwSAMP_Addr + 0x5B68B), 0xEB, 1);
	memset_safe((uint32_t *)(g_dwSAMP_Addr + 0x71410), 0xEB, 1);

	// start chatbox logging
	if ( set.chatbox_logging )
	{
		static int	chatbox_init;
		if ( !chatbox_init )
		{
			SYSTEMTIME	time;
			GetLocalTime( &time );
			LogChatbox( false, "Session started at %02d/%02d/%02d", time.wDay, time.wMonth, time.wYear );
			chatbox_init = 1;
		}
	}

	if ( KEY_DOWN(set.secondary_key) )
	{
		if ( KEY_PRESSED(set.key_player_info_list) )
			cheat_state->player_info_list ^= 1;

		if ( KEY_PRESSED(set.key_rejoin) )
		{
			restartGame();
			disconnect( 500 );
			cheat_state_text( "Rejoining in %d seconds...", set.rejoin_delay / 1000 );
			cheat_state->_generic.rejoinTick = GetTickCount();
		}

		if ( KEY_PRESSED(set.key_respawn) )
			playerSpawn();
	}

	if ( KEY_DOWN(set.chat_secondary_key) )
	{
		int			i, key, spam;
		const char	*msg;
		for ( i = 0; i < INI_CHATMSGS_MAX; i++ )
		{
			struct chat_msg *msg_item = &set.chat[i];
			if ( msg_item->key == NULL )
				continue;
			if ( msg_item->msg == NULL )
				continue;
			if ( msg_item->key != key_being_pressed )
				continue;
			key = msg_item->key;
			msg = msg_item->msg;
			spam = msg_item->spam;
			if ( spam )
			{
				if ( msg )
					if ( KEY_DOWN(key) )
						say( "%s", msg );
			}
			else
			{
				if ( msg )
					if ( KEY_PRESSED(key) )
						say( "%s", msg );
			}
		}
	}

	static int	iSAMPHooksInstalled;
	if ( !iSAMPHooksInstalled )
	{
		installSAMPHooks();
		iSAMPHooksInstalled = 1;
	}

	if ( cheat_state->_generic.rejoinTick && cheat_state->_generic.rejoinTick < (GetTickCount() - set.rejoin_delay) )
	{
		g_SAMP->iGameState = GAMESTATE_WAIT_CONNECT;
		cheat_state->_generic.rejoinTick = 0;
	}

	if ( joining_server == 1 )
	{
		restartGame();
		disconnect( 500 );
		cheat_state_text( "Joining server in %d seconds...", set.rejoin_delay / 1000 );
		cheat_state->_generic.join_serverTick = GetTickCount();
		joining_server = 2;
	}

	if ( joining_server == 2
	 &&	 cheat_state->_generic.join_serverTick
	 &&	 cheat_state->_generic.join_serverTick < (GetTickCount() - set.rejoin_delay) )
	{
		g_SAMP->iGameState = GAMESTATE_WAIT_CONNECT;
		joining_server = 0;
		cheat_state->_generic.join_serverTick = 0;
	}

	if ( KEY_PRESSED(set.key_dialoghider) )
	{
		g_Dialog->iDialogShowed ^= 1;

		if(g_Dialog->iDialogShowed == 1)
		{
			cheat_state_text( "Dialog showed." );
			toggleSAMPCursor( 1 );
			g_iCursorEnabled = 0;
		}
		else
		{
			cheat_state_text( "Dialog hided." );
			toggleSAMPCursor( 0 );
		}
	}
}

int getNthPlayerID ( int n )
{
	if ( g_Players == NULL )
		return -1;

	int thisplayer = 0;
	for ( int i = 0; i < SAMP_PLAYER_MAX; i++ )
	{
		if ( g_Players->iIsListed[i] != 1 )
			continue;
		if ( g_Players->sLocalPlayerID == i )
			continue;
		if ( thisplayer < n )
		{
			thisplayer++;
			continue;
		}

		return i;
	}

	//shouldnt happen
	return -1;
}

int getPlayerCount ( void )
{
	if ( g_Players == NULL )
		return NULL;

	int iCount = 0;
	int i;

	for ( i = 0; i < SAMP_PLAYER_MAX; i++ )
	{
		if ( g_Players->iIsListed[i] != 1 )
			continue;
		iCount++;
	}

	return iCount + 1;
}

#define SAMP_FUNC_NAMECHANGE 0xA500
int setLocalPlayerName ( const char *name )
{
	if ( g_Players == NULL || g_Players->pLocalPlayer == NULL )
		return 0;

	int strlen_name = strlen( name );
	if ( strlen_name == 0 || strlen_name > ALLOWED_PLAYER_NAME_LENGTH )
		return 0;

	traceLastFunc( "setLocalPlayerName()" );

	//strcpy(g_Players->szLocalPlayerName, name);
	//g_Players->iStrlen_LocalPlayerName = strlen_name;

	DWORD	vtbl_nameHandler = ((DWORD)&g_Players->pVTBL_txtHandler);
	DWORD	func = g_dwSAMP_Addr + SAMP_FUNC_NAMECHANGE;
	__asm push strlen_name
	__asm push name
	__asm mov ecx, vtbl_nameHandler
	__asm call func
	return 1;
}

int getVehicleCount ( void )
{
	if ( g_Vehicles == NULL )
		return NULL;

	int iCount = 0;
	int i;

	for ( i = 0; i < SAMP_VEHICLE_MAX; i++ )
	{
		if ( g_Vehicles->iIsListed[i] != 1 )
			continue;
		iCount++;
	}

	return iCount;
}

int getPlayerPos ( int iPlayerID, float fPos[3] )
{
	traceLastFunc( "getPlayerPos()" );

	struct actor_info	*pActor = NULL;
	struct vehicle_info *pVehicle = NULL;

	struct actor_info	*pSelfActor = actor_info_get( ACTOR_SELF, 0 );

	if ( g_Players == NULL )
		return 0;
	if ( g_Players->iIsListed[iPlayerID] != 1 )
		return 0;
	if ( g_Players->pRemotePlayer[iPlayerID] == NULL )
		return 0;
	if ( g_Players->pRemotePlayer[iPlayerID]->pPlayerData == NULL )
		return 0;

	if ( g_Players->pRemotePlayer[iPlayerID]->pPlayerData->pSAMP_Actor == NULL )
		return 0;	// not streamed
	else
	{
		pActor = g_Players->pRemotePlayer[iPlayerID]->pPlayerData->pSAMP_Actor->pGTA_Ped;

		if ( g_Players->pRemotePlayer[iPlayerID]->pPlayerData->pSAMP_Vehicle != NULL )
			pVehicle = g_Players->pRemotePlayer[iPlayerID]->pPlayerData->pSAMP_Vehicle->pGTA_Vehicle;

		if ( pVehicle != NULL && pActor->vehicle == pVehicle && pVehicle->passengers[0] == pActor )
		{
			// driver of a vehicle
			vect3_copy( &pActor->vehicle->base.matrix[4 * 3], fPos );

			//vect3_copy(g_Players->pRemotePlayer[iPlayerID]->fVehiclePosition, fPos);
		}
		else if ( pVehicle != NULL )
		{
			// passenger of a vehicle
			vect3_copy( &pActor->base.matrix[4 * 3], fPos );

			//vect3_copy(g_Players->pRemotePlayer[iPlayerID]->fActorPosition, fPos);
		}
		else
		{
			// on foot
			vect3_copy( &pActor->base.matrix[4 * 3], fPos );

			//vect3_copy(g_Players->pRemotePlayer[iPlayerID]->fActorPosition, fPos);
		}
	}

	if ( pSelfActor != NULL )
	{
		if ( vect3_dist(&pSelfActor->base.matrix[4 * 3], fPos) < 100.0f )
			vect3_copy( &pActor->base.matrix[4 * 3], fPos );
	}

	// detect zombies
	if ( vect3_near_zero(fPos) )
		vect3_copy( &pActor->base.matrix[4 * 3], fPos );

	return !vect3_near_zero( fPos );
}

const char *getPlayerName ( int iPlayerID )
{
	if ( g_Players == NULL || iPlayerID < 0 || iPlayerID > SAMP_PLAYER_MAX )
		return NULL;

	if ( iPlayerID == g_Players->sLocalPlayerID )
	{
		if ( g_Players->iStrlen_LocalPlayerName <= 0xF )
			return g_Players->szLocalPlayerName;
		return g_Players->pszLocalPlayerName;
	}

	if ( g_Players->pRemotePlayer[iPlayerID] == NULL )
		return NULL;

	if ( g_Players->pRemotePlayer[iPlayerID]->iStrlenName <= 0xF )
		return g_Players->pRemotePlayer[iPlayerID]->szPlayerName;

	return g_Players->pRemotePlayer[iPlayerID]->pszPlayerName;
}

int getPlayerState ( int iPlayerID )
{
	if ( g_Players == NULL || iPlayerID < 0 || iPlayerID > SAMP_PLAYER_MAX )
		return NULL;
	if ( iPlayerID == g_Players->sLocalPlayerID )
		return NULL;
	if ( g_Players->iIsListed[iPlayerID] != 1 )
		return NULL;
	if ( g_Players->pRemotePlayer[iPlayerID]->pPlayerData == NULL )
		return NULL;

	return g_Players->pRemotePlayer[iPlayerID]->pPlayerData->bytePlayerState;
}

int getPlayerVehicleGTAScriptingID ( int iPlayerID )
{
	if ( g_Players == NULL )
		return 0;

	// fix to always return our own vehicle always if that's what's being asked for
	if ( iPlayerID == ACTOR_SELF )
	{
		if(g_Players->pLocalPlayer->sCurrentVehicleID == (uint16_t)-1) return 0;

		stSAMPVehicle	*sampveh = g_Vehicles->pSAMP_Vehicle[g_Players->pLocalPlayer->sCurrentVehicleID];
		if ( sampveh )
		{
			return ScriptCarId( sampveh->pGTA_Vehicle );
			//return (int)( ((DWORD) sampveh->pGTA_Vehicle) - (DWORD) pool_vehicle->start ) / 2584;
		}
		else
			return 0;
	}

	// make sure remote player is legit
	if ( g_Players->pRemotePlayer[iPlayerID] == NULL || g_Players->pRemotePlayer[iPlayerID]->pPlayerData == NULL ||
		g_Players->pRemotePlayer[iPlayerID]->pPlayerData->pSAMP_Vehicle == NULL ||
		g_Players->pRemotePlayer[iPlayerID]->pPlayerData->pSAMP_Vehicle->pGTA_Vehicle == NULL)
		return 0;

	// make sure samp knows the vehicle exists
	if ( g_Vehicles->pSAMP_Vehicle[g_Players->pRemotePlayer[iPlayerID]->pPlayerData->sVehicleID] == NULL )
		return 0;

	// return the remote player's vehicle
	return ScriptCarId( g_Players->pRemotePlayer[iPlayerID]->pPlayerData->pSAMP_Vehicle->pGTA_Vehicle );
}

int getPlayerSAMPVehicleID(int iPlayerID)
{
	if(g_Players == NULL && g_Vehicles == NULL) return 0;
	if(g_Players->pRemotePlayer[iPlayerID] == NULL) return 0;
	if(g_Vehicles->pSAMP_Vehicle[g_Players->pRemotePlayer[iPlayerID]->pPlayerData->sVehicleID] == NULL) return 0;
	return g_Players->pRemotePlayer[iPlayerID]->pPlayerData->sVehicleID;
}

struct actor_info *getGTAPedFromSAMPPlayerID ( int iPlayerID )
{
	if ( g_Players == NULL || iPlayerID < 0 || iPlayerID > SAMP_PLAYER_MAX )
		return NULL;
	if ( iPlayerID == g_Players->sLocalPlayerID )
		return actor_info_get( ACTOR_SELF, 0 );
	if ( g_Players->iIsListed[iPlayerID] != 1 )
		return NULL;
	if ( g_Players->pRemotePlayer[iPlayerID] == NULL )
		return NULL;
	if ( g_Players->pRemotePlayer[iPlayerID]->pPlayerData == NULL )
		return NULL;
	if ( g_Players->pRemotePlayer[iPlayerID]->pPlayerData->pSAMP_Actor == NULL )
		return NULL;
	if ( g_Players->pRemotePlayer[iPlayerID]->pPlayerData->pSAMP_Actor->pGTA_Ped == NULL )
		return NULL;
		
	// return actor_info, null or otherwise
	return g_Players->pRemotePlayer[iPlayerID]->pPlayerData->pSAMP_Actor->pGTA_Ped;
}

struct vehicle_info *getGTAVehicleFromSAMPVehicleID ( int iVehicleID )
{
	if ( g_Vehicles == NULL || iVehicleID < 0 || iVehicleID >= SAMP_VEHICLE_MAX )
		return NULL;
	if ( iVehicleID == g_Players->pLocalPlayer->sCurrentVehicleID )
		return vehicle_info_get( VEHICLE_SELF, 0 );
	if ( g_Vehicles->iIsListed[iVehicleID] != 1 )
		return NULL;

	// return vehicle_info, null or otherwise
	return g_Vehicles->pGTA_Vehicle[iVehicleID];
}

int getSAMPPlayerIDFromGTAPed ( struct actor_info *pGTAPed )
{
	if ( g_Players == NULL )
		return 0;
	if ( actor_info_get(ACTOR_SELF, 0) == pGTAPed )
		return g_Players->sLocalPlayerID;

	int i;
	for ( i = 0; i < SAMP_PLAYER_MAX; i++ )
	{
		if ( g_Players->iIsListed[i] != 1 )
			continue;
		if ( g_Players->pRemotePlayer[i] == NULL )
			continue;
		if ( g_Players->pRemotePlayer[i]->pPlayerData == NULL )
			continue;
		if ( g_Players->pRemotePlayer[i]->pPlayerData->pSAMP_Actor == NULL )
			continue;
		if ( g_Players->pRemotePlayer[i]->pPlayerData->pSAMP_Actor->pGTA_Ped == NULL )
			continue;
		if ( g_Players->pRemotePlayer[i]->pPlayerData->pSAMP_Actor->pGTA_Ped == pGTAPed )
			return i;
	}

	return ACTOR_SELF;
}

int getSAMPVehicleIDFromGTAVehicle ( struct vehicle_info *pVehicle )
{
	if ( g_Vehicles == NULL )
		return NULL;
	if ( vehicle_info_get(VEHICLE_SELF, 0) == pVehicle && g_Players != NULL )
		return g_Players->pLocalPlayer->sCurrentVehicleID;

	int i, iReturn = 0;
	for ( i = 0; i < SAMP_VEHICLE_MAX; i++ )
	{
		if ( g_Vehicles->iIsListed[i] != 1 )
			continue;
		if ( g_Vehicles->pGTA_Vehicle[i] == pVehicle )
			return i;
	}

	return VEHICLE_SELF;
}

uint32_t getPedGTAScriptingIDFromPlayerID ( int iPlayerID )
{
	if ( g_Players == NULL )
		return NULL;

	if ( g_Players->iIsListed[iPlayerID] != 1 )
		return NULL;
	if ( g_Players->pRemotePlayer[iPlayerID] == NULL )
		return NULL;
	if ( g_Players->pRemotePlayer[iPlayerID]->pPlayerData == NULL )
		return NULL;
	if ( g_Players->pRemotePlayer[iPlayerID]->pPlayerData->pSAMP_Actor == NULL )
		return NULL;

	return g_Players->pRemotePlayer[iPlayerID]->pPlayerData->pSAMP_Actor->ulGTA_Ped_ID;
}

uint32_t getVehicleGTAScriptingIDFromVehicleID ( int iVehicleID )
{
	if ( g_Vehicles == NULL )
		return NULL;

	if ( g_Vehicles->iIsListed[iVehicleID] != 1 )
		return NULL;
	if ( g_Vehicles->pSAMP_Vehicle[iVehicleID] == NULL )
		return NULL;

	return g_Vehicles->pSAMP_Vehicle[iVehicleID]->ulGTA_Vehicle_ID;
}

bool ValidPlayer(int PlayerID)
{
	if ( g_Players == NULL )
		return 0;

	if ( PlayerID < 0 || PlayerID > SAMP_PLAYER_MAX )
		return 0;

	if ( PlayerID == g_Players->sLocalPlayerID )
		return 0;

	if ( g_Players->iIsListed[PlayerID] != 1 )
		return 0;

	return 1;
}

bool IsPlayerTeamMate(int PlayerID)
{
	if (g_Players == NULL)
		return 0;

	if(!ValidPlayer(PlayerID))
		return 0;

	if(g_Players->pLocalPlayer->byteTeamID == 255)
		return 0;

	if(g_Players->pRemotePlayer[PlayerID]->pPlayerData->byteTeamID == 255)
		return 0;

	if(g_Players->pRemotePlayer[PlayerID]->pPlayerData->byteTeamID == g_Players->pLocalPlayer->byteTeamID)
		return 1;
	else
		return 0;
}

bool ValidVehicle(int VehicleID)
{
	if ( g_Vehicles->iIsListed[VehicleID] != 1 )
		return 0;

	if ( g_Vehicles->pSAMP_Vehicle[VehicleID] == NULL )
		return 0;

	if ( g_Vehicles->pSAMP_Vehicle[VehicleID]->pGTA_Vehicle == NULL )
		return 0;

	return 1;
}

struct m0dClientCMD
{
#pragma pack( 1 )
	char	cmd_name[30];

	//char cmd_description[128];
} m0d_cmd_list[( MAX_CLIENTCMDS - 22 )];
int m0d_cmd_num = 0;

void cmd_showCMDS ()
{
	int i = 0;
	for ( ; i < m0d_cmd_num; i++ )
	{
		addMessageToChatWindow( "%s", m0d_cmd_list[i].cmd_name );
	}
}

#define FUNC_ADDCLIENTCMD	0x7BC40
void addClientCommand ( char *name, int function )
{
	if ( name == NULL || function == NULL || g_Input == NULL )
		return;

	if ( g_Input->iCMDCount == (MAX_CLIENTCMDS-1) )
	{
		Log( "Error: couldn't initialize '%s'. Maximum command amount reached.", name );
		return;
	}

	if ( strlen(name) > 30 )
	{
		Log( "Error: command name '%s' was too long.", name );
		return;
	}

	if ( m0d_cmd_num < (MAX_CLIENTCMDS - 22) )
	{
		strncpy_s( m0d_cmd_list[m0d_cmd_num].cmd_name, name, sizeof(m0d_cmd_list[m0d_cmd_num].cmd_name)-1 );
		m0d_cmd_num++;
	}
	else
		Log( "m0d_cmd_list[] too short." );

	uint32_t	data = g_dwSAMP_Addr + SAMP_CHAT_INPUT_INFO_OFFSET;
	uint32_t	func = g_dwSAMP_Addr + FUNC_ADDCLIENTCMD;
	__asm mov eax, data
	__asm mov ecx, [eax]
	__asm push function
	__asm push name
	__asm call func
}

bool	modcommands = false;
bool get_isModCommandsActive ()
{
	return modcommands;
}

void init_samp_chat_cmds ()
{
	if ( modcommands == true )
	{
		return;
	}
	else
	{
		cheat_state_text( "initiated modcommands" );
		modcommands = true;
	}

	addClientCommand( ".cmds", (int)cmd_showCMDS );
	addClientCommand( ".change_server", (int)cmd_change_server );
	addClientCommand( ".change_name", (int)cmd_change_name );
	addClientCommand( ".fav_server", (int)cmd_change_server_fav );
	addClientCommand( ".tele_loc", (int)cmd_tele_loc );
	addClientCommand( ".teleport_location", (int)cmd_tele_loc );
	addClientCommand( ".tele_locations", (int)cmd_tele_locations );
	addClientCommand( ".teleport_locations", (int)cmd_tele_locations );
	addClientCommand( ".pickup", (int)cmd_pickup );
	addClientCommand( ".setclass", (int)cmd_setclass );
	addClientCommand( ".fakekill", (int)cmd_fakekill );
	addClientCommand( ".respond_dialog", (int)cmd_respond_dialog );
	addClientCommand( ".jacker", (int)cmd_jacker );
	addClientCommand( ".shotrepeater", (int)cmd_shotrepeater );
	addClientCommand( ".joinflood", (int)cmd_joinflood );
	addClientCommand( ".dump_objects", (int)cmd_dump_objects );
	addClientCommand( ".repaint", (int)cmd_repaint );
	addClientCommand( ".repaint_all", (int)cmd_repaint_all );
	addClientCommand( ".sendbullet", (int)cmd_sendbullet );
	addClientCommand( ".goto", (int)cmd_goto );
	addClientCommand( ".gethere", (int)cmd_gethere );
	addClientCommand( ".slap", (int)cmd_slap );
	addClientCommand( ".randv", (int)cmd_randv );
	addClientCommand( ".fakekick", (int)cmd_fakekick );
}

struct gui	*gui_samp_cheat_state_text = &set.guiset[1];
void addMessageToChatWindow ( const char *text, ... )
{
	if ( g_SAMP != NULL )
	{
		va_list ap;
		if ( text == NULL )
			return;

		char	tmp[512];
		memset( tmp, 0, 512 );

		va_start( ap, text );
		vsnprintf( tmp, sizeof(tmp)-1, text, ap );
		va_end( ap );

		addToChatWindow( tmp, D3DCOLOR_XRGB(gui_samp_cheat_state_text->red, gui_samp_cheat_state_text->green,
						 gui_samp_cheat_state_text->blue) );
	}
	else
	{
		va_list ap;
		if ( text == NULL )
			return;

		char	tmp[512];
		memset( tmp, 0, 512 );

		va_start( ap, text );
		vsnprintf( tmp, sizeof(tmp)-1, text, ap );
		va_end( ap );

		cheat_state_text( tmp, D3DCOLOR_ARGB(255, 0, 200, 200) );
	}
}

void addMessageToChatWindowSS ( const char *text, ... )
{
	if ( g_SAMP != NULL )
	{
		va_list ap;
		if ( text == NULL )
			return;

		char	tmp[512];
		memset( tmp, 0, 512 );

		va_start( ap, text );
		vsprintf( tmp, text, ap );
		va_end( ap );

		addMessageToChatWindow( tmp, D3DCOLOR_ARGB(255, 0, 200, 200) );
	}
	else
	{
		va_list ap;
		if ( text == NULL )
			return;

		char	tmp[512];
		memset( tmp, 0, 512 );

		va_start( ap, text );
		vsprintf( tmp, text, ap );
		va_end( ap );

		cheat_state_text( tmp, D3DCOLOR_ARGB(255, 0, 200, 200) );
	}
}

#define FUNC_ADDTOCHATWND	0x7A4F0
void addToChatWindow ( char *text, D3DCOLOR textColor, int playerID )
{
	if ( g_SAMP == NULL || g_Chat == NULL )
		return;

	if ( text == NULL )
		return;

	if ( playerID < -1 )
		playerID = -1;

	uint32_t	chatinfo = g_dwSAMP_Addr + SAMP_CHAT_INFO_OFFSET;
	uint32_t	func = g_dwSAMP_Addr + FUNC_ADDTOCHATWND;

	if ( playerID != -1 )
	{
		// getPlayerName does the needed validity checks, no need for doubles
		char *playerName = (char*)getPlayerName(playerID);
		if ( playerName == NULL )
			return;

		D3DCOLOR playerColor = samp_color_get(playerID);

		__asm mov eax, dword ptr[chatinfo]
		__asm mov ecx, dword ptr[eax]
		__asm push playerColor
		__asm push textColor
		__asm push playerName
		__asm push text
		__asm push 2
		__asm call func
		return;
	}

	__asm mov eax, dword ptr[chatinfo]
	__asm mov ecx, dword ptr[eax]
	__asm push 0
	__asm push textColor
	__asm push 0
	__asm push text
	__asm push 8
	__asm call func
	return;
}

#define FUNC_RESTARTGAME	0x9280
void restartGame ()
{
	if ( g_SAMP == NULL )
		return;

	uint32_t samp_info = g_dwSAMP_Addr + SAMP_INFO_OFFSET;
	uint32_t func = g_dwSAMP_Addr + FUNC_RESTARTGAME;

	g_byteLagCompensation = 0;
	g_iLastAttachedObjectIndex = -1;

	deleteAllRemotePlayers();

	__asm mov eax, dword ptr[samp_info]
	__asm mov ecx, dword ptr[eax]
	__asm call func
	__asm pop eax
	__asm pop ecx
}

void say ( char *text, ... )
{
	if ( g_SAMP == NULL )
		return;

	if ( text == NULL )
		return;
	if ( isBadPtr_readAny(text, 128) )
		return;
	traceLastFunc( "say()" );

	va_list ap;
	char	tmp[128];
	memset( tmp, 0, 128 );

	va_start( ap, text );
	vsprintf( tmp, text, ap );
	va_end( ap );

	addSayToChatWindow( tmp );
}

#define FUNC_SAY		0x4CA0
#define FUNC_SENDCMD	0x7BDD0
void addSayToChatWindow ( char *msg )
{
	if ( g_SAMP == NULL )
		return;

	if ( msg == NULL )
		return;
	if ( isBadPtr_readAny(msg, 128) )
		return;
	traceLastFunc( "addSayToChatWindow()" );

	if ( msg[0] == '/' )
	{
		uint32_t	func = g_dwSAMP_Addr + FUNC_SENDCMD;
		__asm push msg
		__asm call func
	}
	else
	{
		uint32_t	func = g_dwSAMP_Addr + FUNC_SAY;
		void		*lpPtr = g_Players->pLocalPlayer;
		__asm mov ebx, dword ptr[lpPtr]
		__asm push msg
		__asm call func
		__asm pop ebx
	}
}

#define FUNC_GAMETEXT	0x643B0
void showGameText ( char *text, int time, int textsize )
{
	if ( g_SAMP == NULL )
		return;

	uint32_t	func = g_dwSAMP_Addr + FUNC_GAMETEXT;
	__asm push textsize
	__asm push time
	__asm push text
	__asm call func
}

#define FUNC_SPAWN			0x36D0
#define FUNC_REQUEST_SPAWN	0x3620
void playerSpawn ( void )
{
	if ( g_SAMP == NULL )
		return;

	uint32_t	func_request = g_dwSAMP_Addr + FUNC_REQUEST_SPAWN;
	uint32_t	func_spawn = g_dwSAMP_Addr + FUNC_SPAWN;
	void		*lpPtr = g_Players->pLocalPlayer;

	__asm mov ecx, dword ptr[lpPtr]
	__asm push ecx
	__asm call func_request
	__asm pop ecx

	__asm mov ecx, dword ptr[lpPtr]
	__asm push ecx
	__asm call func_spawn
	__asm pop ecx
}

void disconnect ( int reason /*0=timeout, 500=quit*/ )
{
	if ( g_SAMP == NULL )
		return;

	g_iRakClient->GetRakClientInterface()->Disconnect( reason );
}

void setPassword ( char *password )
{
	if ( g_SAMP == NULL )
		return;

	g_iRakClient->GetRakClientInterface()->SetPassword( password );
}

#define FUNC_SENDINTERIOR	0x4BF0
void sendSetInterior ( uint8_t interiorID )
{
	if ( g_SAMP == NULL )
		return;

	uint32_t	func = g_dwSAMP_Addr + FUNC_SENDINTERIOR;
	void		*lpPtr = g_Players->pLocalPlayer;
	__asm mov ecx, dword ptr[interiorID]
	__asm push ecx
	__asm mov ecx, dword ptr[lpPtr]
	__asm call func
	__asm pop ecx
}

#define FUNC_SETSPECIALACTION	0x2C70
void setSpecialAction ( uint8_t byteSpecialAction )
{
	if ( g_SAMP == NULL )
		return;

	if ( g_Players->pLocalPlayer == NULL )
		return;

	g_Players->pLocalPlayer->onFootData.byteSpecialAction = byteSpecialAction;

	uint32_t	func = g_dwSAMP_Addr + FUNC_SETSPECIALACTION;
	void		*lpPtr = g_Players->pLocalPlayer;
	__asm mov ecx, dword ptr[byteSpecialAction]
	__asm push ecx
	__asm mov ecx, dword ptr[lpPtr]
	__asm call func
	__asm pop ecx
}

void sendSCMEvent ( int iEvent, int iVehicleID, int iParam1, int iParam2 )
{
	g_iRakClient->SendSCMEvent( iVehicleID, iEvent, iParam1, iParam2 );
}

/*
// this doesn't work when wrapped around the toggle below, samp sux
CMatrix toggleSAMPCursor_Camera = CMatrix();
void _cdecl toggleSAMPCursor_SaveCamera ( void )
{
	pGame->GetCamera()->GetMatrix(&toggleSAMPCursor_Camera);
}

void _cdecl toggleSAMPCursor_RestoreCamera ( void )
{
	pGame->GetCamera()->SetMatrix(&toggleSAMPCursor_Camera);
}
*/

#define FUNC_TOGGLECURSOR			0x63E20
#define FUNC_CURSORUNLOCKACTORCAM	0x63D00
void toggleSAMPCursor(int iToggle)
{
	if(g_Input->iInputEnabled) return;

	uint32_t	func = g_dwSAMP_Addr + FUNC_TOGGLECURSOR;
	uint32_t	obj = * ( DWORD * ) ( g_dwSAMP_Addr + SAMP_MISC_INFO );

	if(iToggle)
	{
		_asm
		{
			//call toggleSAMPCursor_SaveCamera;
			mov ecx, obj;
			push 0;
			push 3;
			call func;
			//call toggleSAMPCursor_RestoreCamera;
		}
		g_iCursorEnabled = 1;
	}
	else
	{
		_asm
		{
			mov ecx, obj;
			push 1;
			push 0;
			call func;
		}
		uint32_t funcunlock = g_dwSAMP_Addr + FUNC_CURSORUNLOCKACTORCAM;
		_asm
		{
			mov ecx, obj;
			call funcunlock;
		}
		g_iCursorEnabled = 0;
	}
}

#define HOOK_EXIT_ANTICARJACKED_HOOK	0x1131C
uint16_t	anticarjacked_vehid;
DWORD		anticarjacked_ebx_backup;
DWORD		anticarjacked_jmp;
uint8_t _declspec ( naked ) carjacked_hook ( void )
{
	__asm mov anticarjacked_ebx_backup, ebx
	__asm mov ebx, [ebx + 7]
	__asm mov anticarjacked_vehid, bx
	__asm pushad
	cheat_state->_generic.anti_carjackTick = GetTickCount();
	cheat_state->_generic.car_jacked = true;

	if ( g_Vehicles != NULL && g_Vehicles->pGTA_Vehicle[anticarjacked_vehid] != NULL )
		vect3_copy( &g_Vehicles->pGTA_Vehicle[anticarjacked_vehid]->base.matrix[4 * 3],
					cheat_state->_generic.car_jacked_lastPos );

	__asm popad
	__asm mov ebx, g_dwSAMP_Addr
	__asm add ebx, HOOK_EXIT_ANTICARJACKED_HOOK
	__asm mov anticarjacked_jmp, ebx
	__asm xor ebx, ebx
	__asm mov ebx, anticarjacked_ebx_backup
	__asm jmp anticarjacked_jmp
}

#define HOOK_EXIT_SERVERMESSAGE_HOOK	0x7AAD1
int		g_iNumPlayersMuted = 0;
bool	g_bPlayerMuted[SAMP_PLAYER_MAX];
uint8_t _declspec ( naked ) server_message_hook ( void )
{
	int		thismsg;
	DWORD	thiscolor;

	__asm mov thismsg, esi
	__asm mov thiscolor, eax
	thiscolor = ( thiscolor >> 8 ) | 0xFF000000;

	static char		last_servermsg[256];
	static DWORD	allow_show_again;
	if ( !set.anti_spam || cheat_state->_generic.cheat_panic_enabled
	 || (strcmp(last_servermsg, (char *)thismsg) != NULL || GetTickCount() > allow_show_again) )
	{
		// might be a personal message by muted player - look for name in server message
		// ignore message, if name was found
		if ( set.anti_spam && g_iNumPlayersMuted > 0 )
		{
			int i, j;
			char *playerName = NULL;
			for ( i = 0, j = 0; i < SAMP_PLAYER_MAX && j < g_iNumPlayersMuted; i++ )
			{
				if ( g_bPlayerMuted[i] )
				{
					playerName = (char*)getPlayerName(i);

					if ( playerName == NULL )
					{
						// Player not connected anymore - remove player from muted list
						g_bPlayerMuted[i] = false;
						g_iNumPlayersMuted--;
						continue;
					}
					else if ( strstr((char*)thismsg, playerName) != NULL )
						goto ignoreThisServChatMsg;
					j++;
				}
			}
		}
		strncpy_s( last_servermsg, (char *)thismsg, sizeof(last_servermsg)-1 );
		addToChatWindow( (char *)thismsg, thiscolor );
		allow_show_again = GetTickCount() + 5000;
		
		if( set.chatbox_logging )
			LogChatbox( false, "%s", thismsg );
	}

ignoreThisServChatMsg:
	__asm mov ebx, g_dwSAMP_Addr
	__asm add ebx, HOOK_EXIT_SERVERMESSAGE_HOOK
	__asm jmp ebx
}

#define HOOK_EXIT_CLIENTMESSAGE_HOOK	0xDEC8
uint8_t _declspec ( naked ) client_message_hook ( void )
{
	static char last_clientmsg[SAMP_PLAYER_MAX][256];
	int			thismsg;
	uint16_t	id;

	__asm mov id, dx
	__asm lea edx, [esp+0x128]
	__asm mov thismsg, edx

	if ( id >= 0 && id <= SAMP_PLAYER_MAX )
	{
		if( id == g_Players->sLocalPlayerID )
		{
			addToChatWindow( (char*)thismsg, g_Chat->clTextColor, id );

			if( set.chatbox_logging )
				LogChatbox( false, "%s: %s", getPlayerName(id), thismsg );
			goto client_message_hook_jump_out;
		}

		static DWORD	allow_show_again = GetTickCount();
		if ( !set.anti_spam
		 ||  (strcmp(last_clientmsg[id], (char *)thismsg) != NULL || GetTickCount() > allow_show_again)
		 ||	 cheat_state->_generic.cheat_panic_enabled )
		{
			// ignore chat from muted players
			if ( set.anti_spam && g_iNumPlayersMuted > 0 && g_bPlayerMuted[id] )
				goto client_message_hook_jump_out;

			// nothing to copy anymore, after chatbox_logging, so copy this before
			strncpy_s( last_clientmsg[id], (char *)thismsg, sizeof(last_clientmsg[id])-1 );

			if( set.chatbox_logging )
				LogChatbox( false, "%s: %s", getPlayerName(id), thismsg );

			addToChatWindow( (char*)thismsg, g_Chat->clTextColor, id );
			allow_show_again = GetTickCount() + 5000;
		}
	}

client_message_hook_jump_out:;
	__asm mov ebx, g_dwSAMP_Addr
	__asm add ebx, HOOK_EXIT_CLIENTMESSAGE_HOOK
	__asm jmp ebx
}

#define HOOK_CALL_STREAMEDOUTINFO	0x64430
DWORD dwStreamedOutInfoOrigFunc;
float fStreamedOutInfoPosX, fStreamedOutInfoPosY, fStreamedOutInfoPosZ;
uint16_t wStreamedOutInfoPlayerID;
uint8_t _declspec ( naked ) StreamedOutInfo ( void )
{
	_asm
	{
		push eax
		mov eax, dword ptr [esp+12]
		mov fStreamedOutInfoPosX, eax
		mov eax, dword ptr [esp+16]
		mov fStreamedOutInfoPosY, eax
		mov eax, dword ptr [esp+20]
		mov fStreamedOutInfoPosZ, eax
		mov ax, word ptr [esp+24]
		mov wStreamedOutInfoPlayerID, ax
		pop eax
	}

	_asm pushad
	g_stStreamedOutInfo.iPlayerID[wStreamedOutInfoPlayerID] = (int)wStreamedOutInfoPlayerID;
	g_stStreamedOutInfo.fPlayerPos[wStreamedOutInfoPlayerID][0] = fStreamedOutInfoPosX;
	g_stStreamedOutInfo.fPlayerPos[wStreamedOutInfoPlayerID][1] = fStreamedOutInfoPosY;
	g_stStreamedOutInfo.fPlayerPos[wStreamedOutInfoPlayerID][2] = fStreamedOutInfoPosZ;
	_asm popad

	_asm
	{
		push eax
		mov eax, g_dwSAMP_Addr
		add eax, HOOK_CALL_STREAMEDOUTINFO
		mov dwStreamedOutInfoOrigFunc, eax
		pop eax

		jmp dwStreamedOutInfoOrigFunc
	}
}

void teleportToCurrentCheckpoint( bool bManualTeleport )
{
	vehicle_info *vself = vehicle_info_get( VEHICLE_SELF, NULL );

	if( vself )
	{
		stInCarData InCarData;
		RakNet::BitStream bsInCarData;

		InCarData.sVehicleID = g_Players->pLocalPlayer->inCarData.sVehicleID;
		InCarData.sLeftRightKeys = g_Players->pLocalPlayer->inCarData.sLeftRightKeys;
		InCarData.sUpDownKeys = g_Players->pLocalPlayer->inCarData.sUpDownKeys;
		InCarData.sKeys = g_Players->pLocalPlayer->inCarData.sKeys;
		InCarData.stSampKeys = g_Players->pLocalPlayer->inCarData.stSampKeys;
		InCarData.fQuaternion[0] = g_Players->pLocalPlayer->inCarData.fQuaternion[0];
		InCarData.fQuaternion[1] = g_Players->pLocalPlayer->inCarData.fQuaternion[1];
		InCarData.fQuaternion[2] = g_Players->pLocalPlayer->inCarData.fQuaternion[2];
		InCarData.fQuaternion[3] = g_Players->pLocalPlayer->inCarData.fQuaternion[3];
		InCarData.fPosition[0] = g_stCheckpointData.fPosition[0];
		InCarData.fPosition[1] = g_stCheckpointData.fPosition[1];
		InCarData.fPosition[2] = g_stCheckpointData.fPosition[2];
		InCarData.fVehicleHealth = g_Players->pLocalPlayer->inCarData.fVehicleHealth;
		InCarData.bytePlayerHealth = g_Players->pLocalPlayer->inCarData.bytePlayerHealth;
		InCarData.byteArmor = g_Players->pLocalPlayer->inCarData.byteArmor;
		InCarData.byteCurrentWeapon = g_Players->pLocalPlayer->inCarData.byteCurrentWeapon;
		InCarData.byteSiren = g_Players->pLocalPlayer->inCarData.byteSiren;
		InCarData.byteLandingGearState = g_Players->pLocalPlayer->inCarData.byteLandingGearState;

		bsInCarData.Write((BYTE)ID_VEHICLE_SYNC);
		bsInCarData.Write((PCHAR)&InCarData,sizeof(stInCarData));
		
		if(bManualTeleport)
		{
			for(int x = 0; x < 9; x++)
				g_iRakClient->Send(&bsInCarData, HIGH_PRIORITY, RELIABLE_ORDERED, 0);
		}

		g_iRakClient->Send(&bsInCarData, HIGH_PRIORITY, RELIABLE_ORDERED, 0);
	}
	else
	{
		stOnFootData OnFootData;
		RakNet::BitStream bsOnFootData;

		OnFootData.sLeftRightKeys = g_Players->pLocalPlayer->onFootData.sLeftRightKeys;
		OnFootData.sUpDownKeys = g_Players->pLocalPlayer->onFootData.sUpDownKeys;
		OnFootData.sKeys = g_Players->pLocalPlayer->onFootData.sKeys;
		OnFootData.stSampKeys = g_Players->pLocalPlayer->onFootData.stSampKeys;
		OnFootData.fQuaternion[0] = g_Players->pLocalPlayer->onFootData.fQuaternion[0];
		OnFootData.fQuaternion[1] = g_Players->pLocalPlayer->onFootData.fQuaternion[1];
		OnFootData.fQuaternion[2] = g_Players->pLocalPlayer->onFootData.fQuaternion[2];
		OnFootData.fQuaternion[3] = g_Players->pLocalPlayer->onFootData.fQuaternion[3];
		OnFootData.fPosition[0] = g_stCheckpointData.fPosition[0];
		OnFootData.fPosition[1] = g_stCheckpointData.fPosition[1];
		OnFootData.fPosition[2] = g_stCheckpointData.fPosition[2];
		OnFootData.byteHealth = g_Players->pLocalPlayer->onFootData.byteHealth;
		OnFootData.byteArmor = g_Players->pLocalPlayer->onFootData.byteArmor;
		OnFootData.byteCurrentWeapon = g_Players->pLocalPlayer->onFootData.byteCurrentWeapon;
		OnFootData.byteSpecialAction = g_Players->pLocalPlayer->onFootData.byteSpecialAction;
		OnFootData.sCurrentAnimationID = g_Players->pLocalPlayer->onFootData.sCurrentAnimationID;
		OnFootData.sAnimFlags = g_Players->pLocalPlayer->onFootData.sAnimFlags;

		bsOnFootData.Write((BYTE)ID_PLAYER_SYNC);
		bsOnFootData.Write((PCHAR)&OnFootData,sizeof(stOnFootData));

		if(bManualTeleport)
		{
			for(int x = 0; x < 9; x++)
				g_iRakClient->Send(&bsOnFootData, HIGH_PRIORITY, RELIABLE_ORDERED, 0);
		}

		g_iRakClient->Send(&bsOnFootData, HIGH_PRIORITY, RELIABLE_ORDERED, 0);
	}
}

void HandleRPCPacketFunc( unsigned char byteRPCID, RPCParameters *rpcParams, void ( *functionPointer ) ( RPCParameters * ) )
{
	// use this if you wanna log received RPCs (can help you with finding samp RPC-patches)
	if (cheat_state->_generic.log_rpc_recv)
	{
		if ( byteRPCID != RPC_UpdateScoresPingsIPs && byteRPCID != RPC_ScrRemoveBuildingForPlayer && byteRPCID != RPC_ScrClientMessage && byteRPCID != RPC_ScrServerJoin && byteRPCID != RPC_ScrServerQuit )
		{
			int len = rpcParams ? rpcParams->numberOfBitsOfData / 8 : 0;
			Log( "> [RPC Recv] id: %d, func offset: %p, len: %d", byteRPCID, (DWORD)functionPointer - g_dwSAMP_Addr, len );
			addMessageToChatWindow( "> [RPC Recv] id: %d, func offset: %p, len: %d", byteRPCID, (DWORD)functionPointer - g_dwSAMP_Addr, len );
		}
	}

	if ( byteRPCID == RPC_ScrInitGame )
	{
		RakNet::BitStream bsData( rpcParams->input, rpcParams->numberOfBitsOfData / 8, false );

		bsData.SetReadOffset(363);
		bsData.Read(g_byteLagCompensation);
	}

	if ( byteRPCID == RPC_RequestClass )
	{
		RakNet::BitStream bsData( rpcParams->input, rpcParams->numberOfBitsOfData / 8, false );

		BYTE classid;
		bsData.Read(classid);

		//addMessageToChatWindow("classid %d", classid);
	}

	if ( byteRPCID == RPC_ScrShowDialog)
	{
		RakNet::BitStream bsData( rpcParams->input, rpcParams->numberOfBitsOfData / 8, false );

		WORD wDialogID;
		BYTE bDialogStyle;

		BYTE bTitleLength;
		char szTitle[257];

		bsData.Read(wDialogID);
		bsData.Read(bDialogStyle);

		bsData.Read(bTitleLength);
		bsData.Read(szTitle, bTitleLength);
		szTitle[bTitleLength] = 0;

		cheat_state_text("{FFFFFF}[Dialog] %s {FFFFFF}(ID: %d | Style: %d)", szTitle, wDialogID, bDialogStyle);
	}

	if ( byteRPCID == RPC_ScrSetCheckpo )
	{
		RakNet::BitStream bsData( rpcParams->input, rpcParams->numberOfBitsOfData / 8, false );

		bsData.Read(g_stCheckpointData.fPosition[0]);
		bsData.Read(g_stCheckpointData.fPosition[1]);
		bsData.Read(g_stCheckpointData.fPosition[2]);
		bsData.Read(g_stCheckpointData.fSize);

		g_stCheckpointData.bActive = true;

		cheat_state_text("SA:MP checkpoint set by the server: %.2f %.2f %.2f (size: %.2f)", g_stCheckpointData.fPosition[0], g_stCheckpointData.fPosition[1], g_stCheckpointData.fPosition[2], g_stCheckpointData.fSize);

		if ( cheat_state->_generic.cptele )
			teleportToCurrentCheckpoint(0);

	}

	if ( byteRPCID == RPC_ScrDisableCheckpo )
	{
		g_stCheckpointData.bActive = false;

		cheat_state_text("SA:MP checkpoint disabled by the server.");
	}

	if ( set.enable_extra_godmode && cheat_state->_generic.hp_cheat && rpcParams )
	{
		if ( byteRPCID == RPC_ScrSetPlayerHealth )
		{
			actor_info *self = actor_info_get( ACTOR_SELF, NULL );
			if ( self )
			{
				RakNet::BitStream bsData( rpcParams->input, rpcParams->numberOfBitsOfData / 8, false );
				float fHealth;
				bsData.Read( fHealth );
				if ( fHealth < self->hitpoints )
				{
					cheat_state_text( "Warning: Server tried change your health to %0.1f", fHealth );
					return; // exit from the function without processing RPC
				}
			}
		}
		else if ( byteRPCID == RPC_ScrSetVehicleHealth )
		{
			vehicle_info *vself = vehicle_info_get( VEHICLE_SELF, NULL );
			if ( vself )
			{
				RakNet::BitStream bsData( rpcParams->input, rpcParams->numberOfBitsOfData / 8, false );
				short sId;
				float fHealth;
				bsData.Read( sId );
				bsData.Read( fHealth );
				if ( sId == g_Players->pLocalPlayer->sCurrentVehicleID && fHealth < vself->hitpoints )
				{
					cheat_state_text( "Warning: Server tried change your vehicle health to %0.1f", fHealth );
					return; // exit from the function without processing RPC
				}
			}
		}
	}

	if ( byteRPCID == RPC_ScrWorldVehicleAdd )
	{
		RakNet::BitStream bsData(rpcParams->input, rpcParams->numberOfBitsOfData / 8, false);

		bool bCrashPrevented = 0;
		stNewVehicleInfo NewVehicle;

		bsData.Read((char *)&NewVehicle,sizeof(stNewVehicleInfo));

		if(cheat_state->_generic.anti_traincrasher)
		{
			if(!_finite(NewVehicle.vecPos[0]) || NewVehicle.vecPos[0] > 35000.0f || NewVehicle.vecPos[0] < -35000.0f)
			{
				NewVehicle.vecPos[0] = 0.0f;
				bCrashPrevented = 1;
			}

			if(!_finite(NewVehicle.vecPos[1]) || NewVehicle.vecPos[1] > 35000.0f || NewVehicle.vecPos[1] < -35000.0f)
			{
				NewVehicle.vecPos[1] = 0.0f;
				bCrashPrevented = 1;
			}

			if(!_finite(NewVehicle.vecPos[2]) || NewVehicle.vecPos[2] > 35000.0f || NewVehicle.vecPos[2] < -35000.0f)
			{
				NewVehicle.vecPos[2] = 0.0f;
				bCrashPrevented = 1;
			}

			if(!_finite(NewVehicle.fRotation) || NewVehicle.fRotation > 5000.0f || NewVehicle.fRotation < -5000.0f)
			{
				NewVehicle.fRotation = 0.0f;
				bCrashPrevented = 1;
			}
		}

		if(cheat_state->_generic.anti_vehcomponentcrasher)
		{
			for(int x = 0; x < 14; x++)
			{
				if(NewVehicle.byteModSlots[x] != 0)
				{
					DWORD dwComponentID = (NewVehicle.byteModSlots[x] - 1) + 1000;

					if(!((dwComponentID >= 1000 && dwComponentID <= 1193 ) && IsLegalCarComponent(NewVehicle.iVehicleType, dwComponentID)))
					{
						NewVehicle.byteModSlots[x] = 0;
						bCrashPrevented = 1;
					}
				}
			}
		}

		if(bCrashPrevented)
		{
			cheat_state_text("Anti-Crasher: %d vehicle had invalid data.", NewVehicle.VehicleId);

			bsData.Reset();
			bsData.Write((char *)&NewVehicle, sizeof(stNewVehicleInfo));

			rpcParams->input = bsData.GetData();
			rpcParams->numberOfBitsOfData = bsData.GetNumberOfBitsUsed();
		}
	}

	if ( byteRPCID == RPC_ScrSetPlayerAttachedObject )
	{
		RakNet::BitStream bsData(rpcParams->input, rpcParams->numberOfBitsOfData / 8, false);

		unsigned short usPlayerID;
		int iIndex, iModelID;
		bool bUnk;

		bsData.Read(usPlayerID);
		bsData.Read(iIndex);
		bsData.Read(bUnk);
		bsData.Read(iModelID);

		if ( cheat_state->_generic.anti_attachedobjectcrasher )
		{
			if(iModelID >= 384 && iModelID <= 393) // Singleplayer clothes objects: 384-393
			{
				cheat_state_text("%s tried to crash you with invalid attached objects!", getPlayerName(usPlayerID));
				return;
			}
		}

		g_iLastAttachedObjectIndex = iIndex;
	}

	if ( byteRPCID == RPC_ScmEvent )
	{
		RakNet::BitStream bsData(rpcParams->input, rpcParams->numberOfBitsOfData / 8, false);

		unsigned short usPlayerID;

		int iEvent;
		DWORD dwParam1,dwParam2,dwParam3;

		bsData.Read(usPlayerID);
		bsData.Read(iEvent);
		bsData.Read(dwParam1);
		bsData.Read(dwParam2);
		bsData.Read(dwParam3);

		if(cheat_state->_generic.anti_vehcomponentcrasher && iEvent == 2)
		{
			struct vehicle_info *vinfo = getGTAVehicleFromSAMPVehicleID(dwParam1);

			if(!vinfo)
				return;

			if(!((dwParam2 >= 1000 && dwParam2 <= 1193 ) && IsLegalCarComponent(vinfo->base.model_alt_id, dwParam2)))
			{
				cheat_state_text("%s tried to crash you with invalid car component! (%d [%s] | %d)", getPlayerName(usPlayerID), dwParam1, gta_vehicle_get_by_id(vinfo->base.model_alt_id)->name, dwParam2);
				return;
			}
		}
	}

	functionPointer( rpcParams );
}

#define SAMP_HOOKEXIT_HANDLE_RPC		0x35013
uint8_t _declspec ( naked ) hook_handle_rpc_packet ( void )
{
	static DWORD dwTemp1, dwTemp2;
	__asm pushad;
	__asm mov dwTemp1, eax; // RPCParameters rpcParms
	__asm mov dwTemp2, edi; // RPCNode *node
	
	HandleRPCPacketFunc( *( unsigned char *)dwTemp2, (RPCParameters *)dwTemp1, *( void ( ** ) ( RPCParameters *rpcParams ) )( dwTemp2 + 1 ) );
	dwTemp1 = g_dwSAMP_Addr + SAMP_HOOKEXIT_HANDLE_RPC;

	__asm popad;
	// execute overwritten code
	__asm add esp, 4
	// exit from the custom code
	__asm jmp dwTemp1;
}

#define SAMP_HOOKEXIT_HANDLE_RPC2		0x35021
uint8_t _declspec ( naked ) hook_handle_rpc_packet2 ( void )
{
	static DWORD dwTemp1, dwTemp2;
	__asm pushad;
	__asm mov dwTemp1, ecx; // RPCParameters rpcParms
	__asm mov dwTemp2, edi; // RPCNode *node
	
	HandleRPCPacketFunc( *( unsigned char *)dwTemp2, (RPCParameters *)dwTemp1, *( void ( ** ) ( RPCParameters *rpcParams ) )( dwTemp2 + 1 ) );
	dwTemp1 = g_dwSAMP_Addr + SAMP_HOOKEXIT_HANDLE_RPC2;

	__asm popad;
	// exit from the custom code
	__asm jmp dwTemp1;
}

#define FUNC_CNETGAMEDESTRUCTOR			0x85E0
void __stdcall CNetGame__destructor( void )
{
	if ( g_pBotManager != NULL )
		delete g_pBotManager;

	if ( g_pCheatConsole != NULL )
		delete g_pCheatConsole;

	// release hooked rakclientinterface, restore original rakclientinterface address and call CNetGame destructor
	if ( g_SAMP->pRakClientInterface != NULL )
		delete g_SAMP->pRakClientInterface; 

	g_SAMP->pRakClientInterface = g_iRakClient->GetRakClientInterface();
	return ( ( void ( __thiscall * ) ( void * ) ) ( g_dwSAMP_Addr + FUNC_CNETGAMEDESTRUCTOR ) )( g_SAMP );
}

void SetupSAMPHook( char *szName, DWORD dwFuncOffset, void *Func, int iType, int iSize, char *szCompareBytes )
{
	CDetour api;
	int strl = strlen( szCompareBytes );
	uint8_t *bytes = hex_to_bin( szCompareBytes );

	if ( !strl || !bytes || memcmp_safe( (uint8_t *)g_dwSAMP_Addr + dwFuncOffset, bytes, strl / 2 ) )
	{
		if ( api.Create( (uint8_t *)( (uint32_t)g_dwSAMP_Addr ) + dwFuncOffset, (uint8_t *)Func, iType, iSize ) == 0 )
			Log( "Failed to hook %s.", szName );
	}
	else
	{
		Log( "Failed to hook %s (memcmp)", szName );
	}

	if ( bytes )
		free( bytes );
}

#define SAMP_HOOKPOS_ServerMessage			0x7AABA
#define SAMP_HOOKPOS_ClientMessage 			0xDE6E
#define SAMP_HOOK_STATECHANGE				0x1130B
#define SAMP_HOOK_StreamedOutInfo			0xF82A
#define SAMP_HOOKENTER_HANDLE_RPC			0x3500D
#define SAMP_HOOKENTER_HANDLE_RPC2			0x34F99
#define SAMP_HOOKENTER_CNETGAME_DESTR		0xAD753
#define SAMP_HOOKENTER_CNETGAME_DESTR2		0xAE8E2
void installSAMPHooks ()
{
	if( g_SAMP == NULL )
		return;
	
	if ( set.anti_spam || set.chatbox_logging )
	{
		SetupSAMPHook( "ServerMessage", SAMP_HOOKPOS_ServerMessage, server_message_hook, DETOUR_TYPE_JMP, 5, "6A00C1E808" );
		SetupSAMPHook( "ClientMessage", SAMP_HOOKPOS_ClientMessage, client_message_hook, DETOUR_TYPE_JMP, 5, "663BD1752D" );
	}

	if ( set.anti_carjacking )
	{
		SetupSAMPHook( "AntiCarJack", SAMP_HOOK_STATECHANGE, carjacked_hook, DETOUR_TYPE_JMP, 5, "6A0568E8" );
	}

	SetupSAMPHook( "StreamedOutInfo", SAMP_HOOK_StreamedOutInfo, StreamedOutInfo, DETOUR_TYPE_CALL_FUNC, 5, "E8" );
	SetupSAMPHook( "HandleRPCPacket", SAMP_HOOKENTER_HANDLE_RPC, hook_handle_rpc_packet, DETOUR_TYPE_JMP, 6, "FF5701" );
	SetupSAMPHook( "HandleRPCPacket2", SAMP_HOOKENTER_HANDLE_RPC2, hook_handle_rpc_packet2, DETOUR_TYPE_JMP, 8, "FF5701" );
	SetupSAMPHook( "CNETGAMEDESTR1", SAMP_HOOKENTER_CNETGAME_DESTR, CNetGame__destructor, DETOUR_TYPE_CALL_FUNC, 5, "E8" );
	SetupSAMPHook( "CNETGAMEDESTR2", SAMP_HOOKENTER_CNETGAME_DESTR2, CNetGame__destructor, DETOUR_TYPE_CALL_FUNC, 5, "E8" );
}

#define SAMP_ONFOOTSENDRATE		0xE6098 // at 100035D7  MOV ECX,DWORD PTR DS:[100E6098]
#define SAMP_INCARSENDRATE		0xE609C
#define SAMP_AIMSENDRATE		0xE60A0
void setSAMPCustomSendRates ( int iOnFoot, int iInCar, int iAim, int iHeadSync )
{
	if ( !set.samp_custom_sendrates_enable )
		return;
	if ( g_dwSAMP_Addr == NULL )
		return;
	if ( g_SAMP == NULL )
		return;

	memcpy_safe( (void *)(g_dwSAMP_Addr + SAMP_ONFOOTSENDRATE), &iOnFoot, sizeof(int) );
	memcpy_safe( (void *)(g_dwSAMP_Addr + SAMP_INCARSENDRATE), &iInCar, sizeof(int) );
	memcpy_safe( (void *)(g_dwSAMP_Addr + SAMP_AIMSENDRATE), &iAim, sizeof(int) );
}

#define SAMP_DISABLE_NAMETAGS		0x86770
#define SAMP_DISABLE_NAMETAGS_HP	0x85670
int sampPatchDisableNameTags ( int iEnabled )
{
	static struct patch_set sampPatchEnableNameTags_patch =
	{
		"Remove player status",
		0,
		0,
		{
			{ 1, (void *)( (uint8_t *)g_dwSAMP_Addr + SAMP_DISABLE_NAMETAGS ), NULL, (uint8_t *)"\xC3", NULL },
			{ 1, (void *)( (uint8_t *)g_dwSAMP_Addr + SAMP_DISABLE_NAMETAGS_HP ), NULL, (uint8_t *)"\xC3", NULL }
		}
	};
	if ( iEnabled && !sampPatchEnableNameTags_patch.installed )
		return patcher_install( &sampPatchEnableNameTags_patch );
	else if ( !iEnabled && sampPatchEnableNameTags_patch.installed )
		return patcher_remove( &sampPatchEnableNameTags_patch );
	return NULL;
}

#define SAMP_SKIPSENDINTERIOR 0x6985
int sampPatchDisableInteriorUpdate ( int iEnabled )
{
	static struct patch_set sampPatchDisableInteriorUpdate_patch =
	{
		"NOP sendinterior",
		0,
		0,
		{
			{ 1, (void *)( (uint8_t *)g_dwSAMP_Addr + SAMP_SKIPSENDINTERIOR ), NULL, (uint8_t *)"\xEB", NULL }
		}
	};

	if ( iEnabled && !sampPatchDisableInteriorUpdate_patch.installed )
		return patcher_install( &sampPatchDisableInteriorUpdate_patch );
	else if ( !iEnabled && sampPatchDisableInteriorUpdate_patch.installed )
		return patcher_remove( &sampPatchDisableInteriorUpdate_patch );
	return NULL;
}

#define SAMP_NOPSCOREBOARDTOGGLEON			0x80D80
#define SAMP_NOPSCOREBOARDTOGGLEONKEYLOCK	0x81040
int sampPatchDisableScoreboardToggleOn ( int iEnabled )
{
	static struct patch_set sampPatchDisableScoreboard_patch =
	{
		"NOP Scoreboard Functions",
		0,
		0,
		{
			{ 1, (void *)( (uint8_t *)g_dwSAMP_Addr + SAMP_NOPSCOREBOARDTOGGLEON ), NULL, (uint8_t *)"\xC3", NULL },
			{ 1, (void *)( (uint8_t *)g_dwSAMP_Addr + SAMP_NOPSCOREBOARDTOGGLEONKEYLOCK ), NULL, (uint8_t *)"\xC3", NULL }
		}
	};
	if ( iEnabled && !sampPatchDisableScoreboard_patch.installed )
		return patcher_install( &sampPatchDisableScoreboard_patch );
	else if ( !iEnabled && sampPatchDisableScoreboard_patch.installed )
		return patcher_remove( &sampPatchDisableScoreboard_patch );
	return NULL;
}

#define SAMP_CHATINPUTADJUST_Y				0x7A4C6
#define SAMP_CHATINPUTADJUST_X				0x7B9E5
int sampPatchDisableChatInputAdjust ( int iEnabled )
{
	static struct patch_set sampPatchDisableChatInputAdj_patch =
	{
		"NOP Adjust Chat input box",
		0,
		0,
		{
			{ 6, (void *)( (uint8_t *)g_dwSAMP_Addr + SAMP_CHATINPUTADJUST_Y ), NULL, (uint8_t *)"\x90\x90\x90\x90\x90\x90", NULL },
			{ 7, (void *)( (uint8_t *)g_dwSAMP_Addr + SAMP_CHATINPUTADJUST_X ), NULL, (uint8_t *)"\x90\x90\x90\x90\x90\x90\x90", NULL }
		}
	};
	if ( iEnabled && !sampPatchDisableChatInputAdj_patch.installed )
		return patcher_install( &sampPatchDisableChatInputAdj_patch );
	else if ( !iEnabled && sampPatchDisableChatInputAdj_patch.installed )
		return patcher_remove( &sampPatchDisableChatInputAdj_patch );
	return NULL;
}

#define	FUNC_DEATH	0x4A90
void sendDeath ( void )
{
	if ( g_SAMP == NULL )
		return;

	uint32_t func = g_dwSAMP_Addr + FUNC_DEATH;
	void  *lpPtr = g_Players->pLocalPlayer;
	__asm mov ecx, dword ptr[lpPtr]
	__asm push ecx
	__asm call func
	__asm pop ecx
}

#define FUNC_ENCRYPT_PORT 0x19870
void changeServer( const char *pszIp, unsigned ulPort, const char *pszPassword )
{
	if ( !g_SAMP )
		return;

	( ( void ( __cdecl * )( unsigned ) )( g_dwSAMP_Addr + FUNC_ENCRYPT_PORT ) )( ulPort );

	disconnect( 500 );
	strcpy( g_SAMP->szIP, pszIp );
	g_SAMP->ulPort = ulPort;
	setPassword( (char *)pszPassword );
	joining_server = 1;
}

void dumpStreamedObjects ( void )
{
	traceLastFunc("dumpStreamedObjects()");

	struct actor_info *self = actor_info_get(ACTOR_SELF, 0);

	if (cheat_state->_generic.cheat_panic_enabled || self == NULL)
		return;

	if (g_SAMP->pPools->pPool_Object == NULL)
		return;

	FILE		*flObjects = NULL;
	SYSTEMTIME	time;
	char		filename[512];
	int			i;
	int			objectcount = 0;
	float		*coord = ( cheat_state->state == CHEAT_STATE_VEHICLE ) ? cheat_state->vehicle.coords : cheat_state->actor.coords;
	
	GetLocalTime(&time);

	for ( i = 0; i < SAMP_OBJECTS_MAX; i++ )
	{
		if ( g_SAMP->pPools->pPool_Object->iIsListed[i] != 1 )
			continue;
		if ( g_SAMP->pPools->pPool_Object->object[i] == NULL )
			continue;
		if ( g_SAMP->pPools->pPool_Object->object[i]->pGTAObject == NULL )
			continue;

		objectcount++;
	}

	snprintf(filename, sizeof(filename), "%s\\" M0D_FOLDER "objects_%02d-%02d-%02d-%02d-%02d-%02d.log", g_szWorkingDirectory, time.wYear, time.wMonth, time.wDay, time.wHour, time.wMinute, time.wSecond);
	flObjects = fopen(filename, "w");

	if (flObjects == NULL)
		return;

	fprintf(flObjects, "# Object dump file. Date and time of creation: %02d. %02d. %02d. %02d:%02d:%02d.\n", time.wYear, time.wMonth, time.wDay, time.wHour, time.wMinute, time.wSecond);
	fprintf(flObjects, "# Created by: %s for %s.\n", M0D_NAME, SAMP_VERSION);
	fprintf(flObjects, "# Created on this server: %s (%s:%d).\n", g_SAMP->szHostname, g_SAMP->szIP, g_SAMP->ulPort);
	fprintf(flObjects, "# Position of creation: %.2f, %.2f, %.2f (Interior: %d).\n", coord[0], coord[1], coord[2], gta_interior_id_get());
	fprintf(flObjects, "# Number of objects: %d.", objectcount);
	
	fprintf(flObjects, "\n\n");

	for ( i = 0; i < SAMP_OBJECTS_MAX; i++ )
	{
		if ( g_SAMP->pPools->pPool_Object->iIsListed[i] != 1 )
			continue;
		if ( g_SAMP->pPools->pPool_Object->object[i] == NULL )
			continue;
		if ( g_SAMP->pPools->pPool_Object->object[i]->pGTAObject == NULL )
			continue;

		DWORD baseObjAddr = (DWORD)g_SAMP->pPools->pPool_Object->object[i];

		uint16_t	model_id = g_SAMP->pPools->pPool_Object->object[i]->pGTAObject->base.model_alt_id;
		float		pos[3];
		float		rot[3];

		vect3_copy( &g_SAMP->pPools->pPool_Object->object[i]->pGTAObject->base.matrix[4 * 3], pos );
		if ( vect3_near_zero(pos) )
			continue;

		rot[0] = *(float *)(baseObjAddr + 0xAC);
		rot[1] = *(float *)(baseObjAddr + 0xB0);
		rot[2] = *(float *)(baseObjAddr + 0xB4); 

		fprintf(flObjects, "CreateObject(%d, %f, %f, %f, %f, %f, %f);\n", model_id, pos[0], pos[1], pos[2], rot[0], rot[1], rot[2]);
	}

	fclose(flObjects);

	cheat_state_text("Streamed objects successfully dumped. Output: %s", filename);
	return;
}

void repaintVehicle(int v, int color1, int color2)
{
	if(g_SAMP == NULL || g_SAMP->iGameState != GAMESTATE_CONNECTED)
		return;

	if ( g_Vehicles->iIsListed[v] != 1 )
		return;

	if ( g_Vehicles->pSAMP_Vehicle[v] == NULL )
		return;

	if ( g_Vehicles->pSAMP_Vehicle[v]->pGTA_Vehicle == NULL )
		return;

	RakNet::BitStream bsFakeSync;
	stInCarData fakeSync;

	CVehicle *pVehicle = pGameInterface->GetPools()->GetVehicle((DWORD *)g_SAMP->pPools->pPool_Vehicle->pGTA_Vehicle[v]);
	CVector vecMoveSpeed;

	pVehicle->GetMoveSpeed(&vecMoveSpeed);

	memset(&fakeSync, 0, sizeof(stInCarData));

	fakeSync.sVehicleID = v;

	fakeSync.sLeftRightKeys = g_SAMP->pPools->pPool_Player->pLocalPlayer->onFootData.sLeftRightKeys;
	fakeSync.sUpDownKeys = g_SAMP->pPools->pPool_Player->pLocalPlayer->onFootData.sUpDownKeys;
	fakeSync.sKeys = g_SAMP->pPools->pPool_Player->pLocalPlayer->onFootData.sKeys;

	fakeSync.fPosition[0] = pVehicle->GetPosition()->fX;
	fakeSync.fPosition[1] = pVehicle->GetPosition()->fY;
	fakeSync.fPosition[2] = pVehicle->GetPosition()->fZ;

	fakeSync.fMoveSpeed[0] = vecMoveSpeed.fX;
	fakeSync.fMoveSpeed[1] = vecMoveSpeed.fY;
	fakeSync.fMoveSpeed[2] = vecMoveSpeed.fZ;

	fakeSync.fVehicleHealth = g_SAMP->pPools->pPool_Vehicle->pGTA_Vehicle[v]->hitpoints;
	fakeSync.bytePlayerHealth = g_SAMP->pPools->pPool_Player->pLocalPlayer->pSAMP_Actor->pGTA_Ped->hitpoints;
	fakeSync.byteArmor = g_SAMP->pPools->pPool_Player->pLocalPlayer->pSAMP_Actor->pGTA_Ped->armor;
	fakeSync.byteCurrentWeapon = g_Players->pLocalPlayer->byteCurrentWeapon;

	bsFakeSync.Write((BYTE)ID_VEHICLE_SYNC);
	bsFakeSync.Write((PCHAR)&fakeSync,sizeof(stInCarData));

	g_iRakClient->Send(&bsFakeSync, HIGH_PRIORITY, RELIABLE_ORDERED, 0);

	g_SAMP->pPools->pPool_Vehicle->pGTA_Vehicle[v]->color[0] = color1;
	g_SAMP->pPools->pPool_Vehicle->pGTA_Vehicle[v]->color[1] = color2;

	sendSCMEvent(3, v, color1, color2);

	//cheat_state_text("%s (ID: %d) repainted to ID %d and %d colors.", gta_vehicle_get_by_id(g_SAMP->pPools->pPool_Vehicle->pGTA_Vehicle[v]->base.model_alt_id)->name, v, color1, color2);
}

void repaintStreamedVehicles(int color1, int color2)
{
	if(g_SAMP == NULL || g_SAMP->iGameState != GAMESTATE_CONNECTED)
		return;

	if ( g_Players == NULL && g_Vehicles == NULL )
		return;

	//int repaintedVehicles = 0;

	for ( int v = 0; v < SAMP_VEHICLE_MAX; v++ )
	{
		if ( g_Vehicles->iIsListed[v] != 1 )
			continue;
		if ( g_Vehicles->pSAMP_Vehicle[v] == NULL )
			continue;
		if ( g_Vehicles->pSAMP_Vehicle[v]->pGTA_Vehicle == NULL )
			continue;

		repaintVehicle(v, color1, color2);
		//repaintedVehicles++;
	}

	//cheat_state_text("Repainted %d vehicles to ID %d and %d colors.", repaintedVehicles, color1, color2);
	return;
}

void notifyStreamedVehiclesAreDestroyed()
{
	if(g_SAMP == NULL || g_SAMP->iGameState != GAMESTATE_CONNECTED)
		return;

	if ( g_Players == NULL && g_Vehicles == NULL )
		return;

	for ( int v = 0; v < SAMP_VEHICLE_MAX; v++ )
	{
		if ( g_Vehicles->iIsListed[v] != 1 )
			continue;
		if ( g_Vehicles->pSAMP_Vehicle[v] == NULL )
			continue;
		if ( g_Vehicles->pSAMP_Vehicle[v]->pGTA_Vehicle == NULL )
			continue;

		g_iRakClient->NotifyVehicleDeath(v);
	}
	return;
}

void teleportStreamedVehiclesToCenter()
{
	if(g_SAMP == NULL || g_SAMP->iGameState != GAMESTATE_CONNECTED)
		return;

	if ( g_Players == NULL && g_Vehicles == NULL )
		return;

	RakNet::BitStream bsVehicleSync;
	stInCarData InCarData;

	struct actor_info			*actorinfo = actor_info_get( ACTOR_SELF, 0 );

	const struct vehicle_entry	*vehicle;
	struct vehicle_info			*vehinfo;
	int							v;

	for ( v = 0; v < SAMP_VEHICLE_MAX; v++ )
	{
		if ( g_Vehicles->iIsListed[v] != 1 )
			continue;
		if ( g_Vehicles->pSAMP_Vehicle[v] == NULL )
			continue;
		if ( g_Vehicles->pSAMP_Vehicle[v]->pGTA_Vehicle == NULL )
			continue;

		vehicle = gta_vehicle_get_by_id( g_Vehicles->pSAMP_Vehicle[v]->pGTA_Vehicle->base.model_alt_id );
		vehinfo = g_Vehicles->pSAMP_Vehicle[v]->pGTA_Vehicle;

		memset(&InCarData, 0, sizeof(stInCarData));

		InCarData.sVehicleID = v;
		InCarData.fVehicleHealth = vehinfo->hitpoints;
		InCarData.bytePlayerHealth = actorinfo->hitpoints;
		InCarData.byteArmor = actorinfo->armor;
		InCarData.byteCurrentWeapon = g_SAMP->pPools->pPool_Player->pLocalPlayer->byteCurrentWeapon;

		bsVehicleSync.Reset();
		bsVehicleSync.Write((BYTE)ID_VEHICLE_SYNC);
		bsVehicleSync.Write((PCHAR)&InCarData,sizeof(stInCarData));

		g_iRakClient->Send(&bsVehicleSync,HIGH_PRIORITY,UNRELIABLE_SEQUENCED,0);
	}

	return;
}

void explodeStreamedVehicles()
{
	if(g_SAMP == NULL || g_SAMP->iGameState != GAMESTATE_CONNECTED)
		return;

	if ( g_Players == NULL && g_Vehicles == NULL )
		return;

	for ( int v = 0; v < SAMP_VEHICLE_MAX; v++ )
	{
		if ( g_Vehicles->iIsListed[v] != 1 )
			continue;
  
		if ( g_Vehicles->pSAMP_Vehicle[v] == NULL )
			continue;
  
		if ( g_Vehicles->pSAMP_Vehicle[v]->pGTA_Vehicle == NULL )
			continue;
  
		int car_id = (int)( ((DWORD) g_Vehicles->pGTA_Vehicle[v]) - (DWORD) pool_vehicle->start ) / 2584;

		struct vehicle_info *vinfo = vehicle_info_get( car_id, 0 );
		int iSAMPVehicleID = getSAMPVehicleIDFromGTAVehicle(vinfo);

		if(iSAMPVehicleID == g_Players->pLocalPlayer->sCurrentVehicleID)
			continue;

		struct vehicle_info *info = vehicle_info_get( car_id, 0 );

		float coord[3];
		vect3_copy(&info->base.matrix[12], coord);

		g_iRakClient->SendFakeDriverSyncData(v, coord, 1.0f, info->speed);

		info->hitpoints = 1.0f;
    }

	return;
}

int sampFindNearestPlayer()
{
	unsigned int iClosestPlayerID = 0xFFFF;
	float fClosestPlayerDistance = 999999999.9f;
	float fTargetPos[3];
	float fDistances[SAMP_PLAYER_MAX];

	CVector	vecOrigin, vecTarget;

	vecOrigin = *pGame->GetCamera()->GetCam(pGame->GetCamera()->GetActiveCam())->GetSource();

	for ( int p = 0; p < SAMP_PLAYER_MAX; p++ )
	{
		fDistances[p] = 999999999.9f;

		if(getPlayerPos(p, fTargetPos) && getPlayerState(p) != PLAYER_STATE_NONE && getPlayerState(p) != PLAYER_STATE_WASTED)
		{
			vecTarget.fX = fTargetPos[0];
			vecTarget.fY = fTargetPos[1];
			vecTarget.fZ = fTargetPos[2];

			if(GTAfunc_IsLineOfSightClear(&vecOrigin, &vecTarget, 1, 0, 0, 1, 1, 0, 0))
				fDistances[p] = getDistanceFromLocalPlayer(fTargetPos[0], fTargetPos[1], fTargetPos[2]);
		}
	}

	for ( int p = 0; p < SAMP_PLAYER_MAX; p++ )
	{
		if(fClosestPlayerDistance > fDistances[p] && fDistances[p] != 999999999.9f)
		{
			iClosestPlayerID = p;
			fClosestPlayerDistance = fDistances[p];
		}
	}

	if(iClosestPlayerID != 0xFFFF && fClosestPlayerDistance != 999999999.9f)
		return iClosestPlayerID;
	else
		return 0xFFFF;
}

int sampFindNearestDriver()
{
	unsigned int iClosestPlayerID = 0xFFFF;
	float fClosestPlayerDistance = 999999999.9f;
	float fTargetPos[3];
	float fDistances[SAMP_PLAYER_MAX];

	for ( int p = 0; p < SAMP_PLAYER_MAX; p++ )
	{
		fDistances[p] = 999999999.9f;

		if(getPlayerPos(p, fTargetPos) && getPlayerState(p) == PLAYER_STATE_DRIVER)
			fDistances[p] = getDistanceFromLocalPlayer(fTargetPos[0], fTargetPos[1], fTargetPos[2]);
	}

	for ( int p = 0; p < SAMP_PLAYER_MAX; p++ )
	{
		if(fClosestPlayerDistance > fDistances[p] && fDistances[p] != 999999999.9f)
		{
			iClosestPlayerID = p;
			fClosestPlayerDistance = fDistances[p];
		}
	}

	if(iClosestPlayerID != 0xFFFF && fClosestPlayerDistance != 999999999.9f)
		return iClosestPlayerID;
	else
		return 0xFFFF;
}

void gethere(int id)
{
	if ( g_Players == NULL )
		return;

	if(cheat_state->state != CHEAT_STATE_VEHICLE)
		return;

	if ( g_Players->iIsListed[id] != 1
		||  g_Players->pRemotePlayer[id] == NULL
		||  g_Players->pRemotePlayer[id]->pPlayerData == NULL
		||  g_Players->pRemotePlayer[id]->pPlayerData->pSAMP_Actor == NULL
		||  g_Players->pRemotePlayer[id]->pPlayerData->pSAMP_Actor->pGTA_Ped == NULL
		||  getPlayerState(id) != PLAYER_STATE_ONFOOT )
			return;

	struct vehicle_info *vinfo = vehicle_info_get( VEHICLE_SELF, NULL );

	float coord[3];

	coord[0] = g_Players->pRemotePlayer[id]->pPlayerData->onFootData.fPosition[0];
	coord[1] = g_Players->pRemotePlayer[id]->pPlayerData->onFootData.fPosition[1];
	coord[2] = g_Players->pRemotePlayer[id]->pPlayerData->onFootData.fPosition[2] - 1.0f;

	g_iRakClient->SendFakeDriverSyncData( g_SAMP->pPools->pPool_Player->pLocalPlayer->inCarData.sVehicleID, coord, vinfo->hitpoints, vinfo->speed );

	cheat_state_text("Tried to teleport here %s.", getPlayerName(id));
}

void moveStreamedVehiclesToPlayer(int id)
{
	if(!ValidPlayer(id))
		return;

	struct actor_info *self = actor_info_get( ACTOR_SELF, ACTOR_ALIVE);

	struct actor_info *info = actor_info_get( ACTOR_SELF, 0 ); 

	for ( int v = 0; v < SAMP_VEHICLE_MAX; v++ )
	{
		if ( g_Vehicles->iIsListed[v] != 1 )
			continue;
  
		if ( g_Vehicles->pSAMP_Vehicle[v] == NULL )
			continue;
  
		if ( g_Vehicles->pSAMP_Vehicle[v]->pGTA_Vehicle == NULL )
			continue;
  
		int car_id = (int)( ((DWORD) g_Vehicles->pGTA_Vehicle[v]) - (DWORD) pool_vehicle->start ) / 2584;
  
		struct vehicle_info *info = vehicle_info_get( car_id, 0 );
  
		self->vehicle = info;

		for(int x = 0; x < 5; x++)
			g_iRakClient->SendFakeDriverSyncData(v, g_Players->pRemotePlayer[id]->pPlayerData->onFootData.fPosition, info->hitpoints, info->speed);

		cheat_vehicle_teleport(info, g_Players->pRemotePlayer[id]->pPlayerData->onFootData.fPosition, 0);

		float pos[3] = { pPedSelf->GetPosition()->fX, pPedSelf->GetPosition()->fY, pPedSelf->GetPosition()->fZ };
		GTAfunc_RemoveActorFromCarAndPutAt(pos);
	}
}

void attachedObjectCrasher()
{
	if(g_iLastAttachedObjectIndex == -1)
	{
		cheat_state_text("Enter attached object editor before using this.");
		return;
	}

	stAttachedObject AttachedObjectData;

	AttachedObjectData.iModelID = 392;
	AttachedObjectData.iBoneID = 2;

	AttachedObjectData.vecScale[0] = 1;
	AttachedObjectData.vecScale[1] = 1;
	AttachedObjectData.vecScale[2] = 1;

	g_iRakClient->EditAttachedObject(g_iLastAttachedObjectIndex, 1, &AttachedObjectData);

	cheat_state_text("Attached object crasher activated.");
}

void addMessageToConsole ( const char *text, ... )
{
	if ( g_SAMP != NULL && g_Input != NULL && g_pCheatConsole != NULL )
	{
		va_list ap;
		if ( text == NULL )
			return;

		char	tmp[512];
		memset( tmp, 0, 512 );

		va_start( ap, text );
		vsnprintf( tmp, sizeof(tmp)-1, text, ap );
		va_end( ap );

		g_pCheatConsole->AddMessageToConsole(tmp, D3DCOLOR_XRGB(255, 255, 255));
	}
}

void addMessageToConsole ( DWORD dwColor, const char *text, ... )
{
	if ( g_SAMP != NULL && g_Input != NULL && g_pCheatConsole != NULL )
	{
		va_list ap;
		if ( text == NULL )
			return;

		char	tmp[512];
		memset( tmp, 0, 512 );

		va_start( ap, text );
		vsnprintf( tmp, sizeof(tmp)-1, text, ap );
		va_end( ap );

		g_pCheatConsole->AddMessageToConsole(tmp, dwColor);
	}
}

void deleteAllRemotePlayers()
{
	uint32_t serverquit_rpcfunc = g_dwSAMP_Addr + 0xBFF0;

	for(uint16_t x = 0; x < SAMP_PLAYER_MAX; x++)
	{
		if ( g_Players->iIsListed[x] == 1 && g_Players->pRemotePlayer[x] != NULL)
		{
			RakNet::BitStream bsData;

			bsData.Write(x);
			bsData.Write((BYTE)0);

			RPCParameters rpcParams;

			rpcParams.input = bsData.GetData();
			rpcParams.numberOfBitsOfData = bsData.GetNumberOfBitsUsed();

			RPCParameters *rpcParamsPointer = &rpcParams;

			_asm push rpcParamsPointer
			_asm call serverquit_rpcfunc
		}
	}
}

D3DCOLOR sampGetRadarColor(int iColorType)
{
	if(!g_SAMP)
		return NULL;

	DWORD dwColor = NULL;

	switch(iColorType)
	{
		case 1: // vehicle marker color
		{
			dwColor = *(DWORD*)(g_dwSAMP_Addr + 0x7447C);
			break;
		}

		case 2: // checkpoint marker color
		{
			dwColor = *(DWORD*)(g_dwSAMP_Addr + 0x7448B);
			break;
		}

		case 3: // objective vehicle marker color
		{
			dwColor = *(DWORD*)(g_dwSAMP_Addr + 0x7449A);
			break;
		}
	}

	if(dwColor != NULL)
	{
		return D3DCOLOR_ARGB((dwColor) & 0xFF, (dwColor >> 24) & 0xFF, (dwColor >> 16) & 0xFF, (dwColor >> 8) & 0xFF);
	}
	else
		return NULL;
}

void sampSetRadarColor(int iColorType, DWORD dwColorRGBA)
{
	if(!g_SAMP)
		return;

	switch(iColorType)
	{
		case 1: // vehicle marker color
		{
			UnFuck(g_dwSAMP_Addr + 0x7447C, 4);
			*(DWORD*)(g_dwSAMP_Addr + 0x7447C) = dwColorRGBA;
			break;
		}

		case 2: // checkpoint marker color
		{
			UnFuck(g_dwSAMP_Addr + 0x7448B, 4);
			*(DWORD*)(g_dwSAMP_Addr + 0x7448B) = dwColorRGBA;
			break;
		}

		case 3: // objective vehicle marker color
		{
			UnFuck(g_dwSAMP_Addr + 0x7449A, 4);
			*(DWORD*)(g_dwSAMP_Addr + 0x7449A) = dwColorRGBA;
			break;
		}
	}

	return;
}