#include "main.h"

extern struct gui *menu_titlebar_background;
extern struct gui *menu_background;
extern struct gui *menu_selected_item_bar;
extern struct gui *menu_selected_item_text;

extern struct gui *gta_hp_bar;
extern struct gui *gta_money_hud;

TwBar *twBar_MainMenu;
TwBar *twBar_NewCheats;
TwBar *twBar_CarOperations;
TwBar *twBar_Aimbot;
TwBar *twBar_AutoPilot;
TwBar *twBar_Bots;
TwBar *twBar_RakNet;
TwBar *twBar_Interface;

void runNewMenu ()
{
	if ( KEY_PRESSED(set.key_new_menu) )
	{
		if ( gta_menu_active() ) return;
		if ( g_SAMP != NULL ) if( IS_SCOREBOARD_TOGGLED_ON ) return;

		cheat_state->_generic.new_menu ^= 1;
		if ( cheat_state->_generic.new_menu )
			toggleATBCursor( true );
		else
			toggleATBCursor( false );
	}
}

DWORD dwLastUpdate_MenuPopulator;
void menuPopulator ()
{
	if ( dwLastUpdate_MenuPopulator < (GetTickCount() - set.new_menu_populator_time) )
	{
		dwLastUpdate_MenuPopulator = GetTickCount();
	}
}

DWORD menuUpdateHook_origfunc = 0x50B8F0;
void _declspec(naked) menuUpdateHook ()
{
	_asm call menuUpdateHook_origfunc
	_asm pushad
	menuPopulator();
	_asm popad
	_asm retn
}

void TW_CALL newcheatsMenuLinker(void *)
{
	if(TwIsBarMinimized(twBar_NewCheats))
		TwMaximizeBar(twBar_NewCheats);
	else
		TwMinimizeBar(twBar_NewCheats);
}

void TW_CALL caroperationsMenuLinker(void *)
{
	if(TwIsBarMinimized(twBar_CarOperations))
		TwMaximizeBar(twBar_CarOperations);
	else
		TwMinimizeBar(twBar_CarOperations);
}

void TW_CALL aimbotMenuLinker(void *)
{
	if(TwIsBarMinimized(twBar_Aimbot))
		TwMaximizeBar(twBar_Aimbot);
	else
		TwMinimizeBar(twBar_Aimbot);
}

void TW_CALL autopilotMenuLinker(void *)
{
	if(TwIsBarMinimized(twBar_AutoPilot))
		TwMaximizeBar(twBar_AutoPilot);
	else
		TwMinimizeBar(twBar_AutoPilot);
}

void TW_CALL botsMenuLinker(void *)
{
	if(TwIsBarMinimized(twBar_Bots))
		TwMaximizeBar(twBar_Bots);
	else
		TwMinimizeBar(twBar_Bots);
}

void TW_CALL raknetMenuLinker(void *)
{
	if(TwIsBarMinimized(twBar_RakNet))
		TwMaximizeBar(twBar_RakNet);
	else
		TwMinimizeBar(twBar_RakNet);
}

void TW_CALL interfaceMenuLinker(void *)
{
	if(TwIsBarMinimized(twBar_Interface))
		TwMaximizeBar(twBar_Interface);
	else
		TwMinimizeBar(twBar_Interface);
}

void TW_CALL newcheatsMenu_attachedObjectCrasher(void *)
{
	attachedObjectCrasher();
}

void TW_CALL newcheatsMenu_teleportToCurrentCheckpoint(void *)
{
	teleportToCurrentCheckpoint(1);
}

void TW_CALL newcheatsMenu_dumpStreamedObjects(void *)
{
	dumpStreamedObjects();
}

void TW_CALL botsMenu_addBot(void *)
{
	if(g_pBotManager) g_pBotManager->AddBot();
}

void TW_CALL botsMenu_spawnBot(void *)
{
	if(g_pBotManager) g_pBotManager->SpawnBot();
}

void TW_CALL botsMenu_kickBot(void *)
{
	if(g_pBotManager) g_pBotManager->KickBot();
}

void TW_CALL botsMenu_kickAllBots(void *)
{
	if(g_pBotManager) g_pBotManager->KickAllBots();
}

void TW_CALL botsMenu_timeoutAllBots(void *)
{
	if(g_pBotManager) g_pBotManager->TimeoutAllBots();
}

void TW_CALL botsMenu_spawnAllBots(void *)
{
	if(g_pBotManager) g_pBotManager->SpawnAllBots();
}

void TW_CALL botsMenu_GetGroupAction(void *value, void *clientData)
{
	int iActionID = (int)clientData;

	if(g_pBotManager)
	{
		if(g_pBotManager->BotManagerSettings.iGroupAction == iActionID)
			*(bool*)value = 1;
		else
			*(bool*)value = 0;
	}
}

void TW_CALL botsMenu_SetGroupAction(const void *value, void *clientData)
{
	int iActionID = (int)clientData;

	if(g_pBotManager)
	{
		if(g_pBotManager->BotManagerSettings.iGroupAction == iActionID)
			g_pBotManager->BotManagerSettings.iGroupAction = 0;
		else
			g_pBotManager->BotManagerSettings.iGroupAction = iActionID;
	}
}

void TW_CALL raknetMenu_fakeDisconnect(void *)
{
	disconnect(500);
}

void TW_CALL raknetMenu_fakeTimeout(void *)
{
	disconnect(0);
}

void TW_CALL raknetMenu_fakeKick(void *)
{
	if(g_iRakClient) g_iRakClient->SendEnterVehicleNotification(0xFFFF, 0);
}

void TW_CALL interfaceMenu_GetInterfaceColor(void *value, void *clientData)
{
	int iColorID = (int)clientData;

	switch(iColorID)
	{
		case 1:
			*(DWORD*)value = D3DCOLOR_ARGB(menu_titlebar_background->alpha, menu_titlebar_background->red, menu_titlebar_background->green, menu_titlebar_background->blue);
			break;

		case 2:
			*(DWORD*)value = D3DCOLOR_ARGB(menu_background->alpha, menu_background->red, menu_background->green, menu_background->blue);
			break;

		case 3:
			*(DWORD*)value = D3DCOLOR_ARGB(menu_selected_item_bar->alpha, menu_selected_item_bar->red, menu_selected_item_bar->green, menu_selected_item_bar->blue);
			break;

		case 4:
			*(DWORD*)value = D3DCOLOR_ARGB(menu_selected_item_text->alpha, menu_selected_item_text->red, menu_selected_item_text->green, menu_selected_item_text->blue);
			break;

		case 5:
			*(DWORD*)value = D3DCOLOR_ARGB(gta_hp_bar->alpha, gta_hp_bar->red, gta_hp_bar->green, gta_hp_bar->blue);
			break;

		case 6:
			*(DWORD*)value = D3DCOLOR_ARGB(gta_money_hud->alpha, gta_money_hud->red, gta_money_hud->green, gta_money_hud->blue);
			break;

		case 7:
			*(DWORD*)value = sampGetRadarColor(1);
			break;

		case 8:
			*(DWORD*)value = sampGetRadarColor(2);
			break;

		case 9:	
			*(DWORD*)value = sampGetRadarColor(3);
			break;
	}
}

void TW_CALL interfaceMenu_SetInterfaceColor(const void *value, void *clientData)
{
	int iColorID = (int)clientData;
	DWORD dwColor = *(DWORD*)value;

	BYTE byteA, byteR, byteG, byteB;

	byteA = dwColor >> 24; byteR = (dwColor >> 16) & 0xFF;
	byteG = (dwColor >> 8 ) & 0xFF; byteB = dwColor & 0xFF;

	if(iColorID == 1)
	{
		menu_titlebar_background->alpha = byteA; menu_titlebar_background->red = byteR;
		menu_titlebar_background->green = byteG; menu_titlebar_background->blue = byteB;
	}
	else if(iColorID == 2)
	{
		menu_background->alpha = byteA; menu_background->red = byteR;
		menu_background->green = byteG; menu_background->blue = byteB;
	}
	else if(iColorID == 3)
	{
		menu_selected_item_bar->alpha = byteA; menu_selected_item_bar->red = byteR;
		menu_selected_item_bar->green = byteG; menu_selected_item_bar->blue = byteB;
	}
	else if(iColorID == 4)
	{
		menu_selected_item_text->alpha = byteA; menu_selected_item_text->red = byteR;
		menu_selected_item_text->green = byteG; menu_selected_item_text->blue = byteB;
	}
	else if(iColorID == 5)
	{
		gta_hp_bar->alpha = byteA; gta_hp_bar->red = byteR;
		gta_hp_bar->green = byteG; gta_hp_bar->blue = byteB;
	}
	else if(iColorID == 6)
	{
		gta_money_hud->alpha = byteA; gta_money_hud->red = byteR;
		gta_money_hud->green = byteG; gta_money_hud->blue = byteB;
	}

	else if(iColorID == 7)
		sampSetRadarColor(1, byteA | (byteB << 8) | (byteG << 16) | (byteR << 24));

	else if(iColorID == 8)
		sampSetRadarColor(2, byteA | (byteB << 8) | (byteG << 16) | (byteR << 24));

	else if(iColorID == 9)
		sampSetRadarColor(3, byteA | (byteB << 8) | (byteG << 16) | (byteR << 24));

	if(iColorID == 5 || iColorID == 6)
		UpdateHUDColors();
}

void initializeBarsMenu ()
{
	if ( memcmp_safe( (uint8_t *)0x53EB0D, hex_to_bin("E8DECDFCFF"), 5 ) )
	{
		CDetour api;
		if ( api.Create( (uint8_t *) ( (uint32_t)0x53EB0D ), (uint8_t *)menuUpdateHook, DETOUR_TYPE_CALL_FUNC, 5 ) == 0 )
			Log( "Failed to hook menuUpdateHook." );
	}
	else
		Log( "Failed to hook menuUpdateHook (memcmp)" );

	TwDefine(" TW_HELP visible=false iconified=false ");

	char menuParameters[512];

	int iMainMenuPosX = pPresentParam.BackBufferWidth / 2 - 400 / 2;
	int iMainMenuPosY = pPresentParam.BackBufferHeight - 275;
	//int iMainMenuPosY = pPresentParam.BackBufferHeight / 2;

	sprintf(menuParameters, " Main_Menu label='~ La Pirula Project ~' color='0 0 0' position='%d %d' size='405 235' fontsize='4' iconpos='topright' iconmargin='8 24' valueswidth=150 ", iMainMenuPosX, iMainMenuPosY);
	TwDefine(menuParameters);

	TwAddSeparator(twBar_MainMenu, NULL, NULL);

	iMainMenuPosX = (pPresentParam.BackBufferWidth / 2) - (405 / 2) - 150;
	iMainMenuPosY = (pPresentParam.BackBufferHeight / 2) - (235 / 2) - 150;

	TwAddButton(twBar_MainMenu, "New_Cheats", newcheatsMenuLinker, NULL, " label='New cheats' ");

	sprintf(menuParameters, " New_Cheats label='~ New cheats ~' color='0 0 0' position='%d %d' size='405 235' fontsize='2' ", iMainMenuPosX, iMainMenuPosY);
	TwDefine(menuParameters);

	iMainMenuPosX = (pPresentParam.BackBufferWidth / 2) - (405 / 2) - 125;
	iMainMenuPosY = (pPresentParam.BackBufferHeight / 2) - (235 / 2) - 125;

	TwAddButton(twBar_MainMenu, "Car_Operations", caroperationsMenuLinker, NULL, " label='Car operations' ");

	sprintf(menuParameters, " Car_Operations label='~ Car operations ~' color='0 0 0' position='%d %d' size='405 235' fontsize='2' ", iMainMenuPosX, iMainMenuPosY);
	TwDefine(menuParameters);

	iMainMenuPosX = (pPresentParam.BackBufferWidth / 2) - (405 / 2) - 100;
	iMainMenuPosY = (pPresentParam.BackBufferHeight / 2) - (235 / 2) - 100;

	TwAddButton(twBar_MainMenu, "Aimbot", aimbotMenuLinker, NULL, " label='Aimbot' ");

	sprintf(menuParameters, " Aimbot label='~ Aimbot ~' color='0 0 0' position='%d %d' size='405 235' fontsize='2' ", iMainMenuPosX, iMainMenuPosY);
	TwDefine(menuParameters);

	iMainMenuPosX = (pPresentParam.BackBufferWidth / 2) - (405 / 2) - 75;
	iMainMenuPosY = (pPresentParam.BackBufferHeight / 2) - (235 / 2) - 75;

	TwAddButton(twBar_MainMenu, "Autopilot", autopilotMenuLinker, NULL, " label='Autopilot' ");

	sprintf(menuParameters, " AutoPilot label='~ Autopilot ~' color='0 0 0' position='%d %d' size='405 235' fontsize='2' ", iMainMenuPosX, iMainMenuPosY);
	TwDefine(menuParameters);

	iMainMenuPosX = (pPresentParam.BackBufferWidth / 2) - (405 / 2) - 50;
	iMainMenuPosY = (pPresentParam.BackBufferHeight / 2) - (235 / 2) - 50;

	TwAddButton(twBar_MainMenu, "Bots", botsMenuLinker, NULL, " label='Bots' ");

	sprintf(menuParameters, " Bots label='~ Bots ~' color='0 0 0' position='%d %d' size='405 235' fontsize='2' ", iMainMenuPosX, iMainMenuPosY);
	TwDefine(menuParameters);
	
	iMainMenuPosX = (pPresentParam.BackBufferWidth / 2) - (405 / 2) - 25;
	iMainMenuPosY = (pPresentParam.BackBufferHeight / 2) - (235 / 2) - 25;

	TwAddButton(twBar_MainMenu, "RakNet", raknetMenuLinker, NULL, " label='RakNet' ");

	sprintf(menuParameters, " RakNet label='~ RakNet ~' color='0 0 0' position='%d %d' size='405 235' fontsize='2' ", iMainMenuPosX, iMainMenuPosY);
	TwDefine(menuParameters);

	iMainMenuPosX = (pPresentParam.BackBufferWidth / 2) - (405 / 2);
	iMainMenuPosY = (pPresentParam.BackBufferHeight / 2) - (235 / 2);

	TwAddButton(twBar_MainMenu, "Interface", interfaceMenuLinker, NULL, " label='Interface' ");

	sprintf(menuParameters, " Interface label='~ Interface ~' color='0 0 0' position='%d %d' size='405 235' fontsize='2' ", iMainMenuPosX, iMainMenuPosY);
	TwDefine(menuParameters);

	TwAddSeparator(twBar_MainMenu, NULL, NULL);

	/*
		New cheats
	*/
	TwAddVarRW(twBar_NewCheats, "Vehicle component crasher", TW_TYPE_BOOLCPP, &cheat_state->_generic.vehcomponentcrasher, " label='Vehicle component crasher' group='Crashers' ");
	TwAddVarRW(twBar_NewCheats, "Bullet crasher (Player)", TW_TYPE_BOOLCPP, &cheat_state->_generic.bulletcrasher_p, " label='Bullet crasher (Player)' group='Crashers' ");
	TwAddVarRW(twBar_NewCheats, "Bullet crasher (Vehicle)", TW_TYPE_BOOLCPP, &cheat_state->_generic.bulletcrasher_v, " label='Bullet crasher (Vehicle)' group='Crashers' ");
	TwAddVarRW(twBar_NewCheats, "Weapon crasher", TW_TYPE_BOOLCPP, &cheat_state->_generic.weaponcrasher, " label='Weapon crasher' group='Crashers' ");
	TwAddVarRW(twBar_NewCheats, "Train crasher", TW_TYPE_BOOLCPP, &cheat_state->_generic.traincrasher, " label='Train crasher' group='Crashers' ");
	TwAddVarRW(twBar_NewCheats, "Bike & train (v2) crasher", TW_TYPE_BOOLCPP, &cheat_state->_generic.bikecrasher, " label='Bike & train (v2) crasher' group='Crashers' ");
	TwAddButton(twBar_NewCheats, "Attached object crasher", newcheatsMenu_attachedObjectCrasher, NULL, " label='Attached object crasher' group='Crashers' ");

	TwDefine(" 'New_Cheats'/'Crashers' opened=false ");

	TwAddVarRW(twBar_NewCheats, "Anti vehicle component crasher", TW_TYPE_BOOLCPP, &cheat_state->_generic.anti_vehcomponentcrasher, " label='Anti vehicle component crasher' group='Protections' ");
	TwAddVarRW(twBar_NewCheats, "Anti bullet crasher", TW_TYPE_BOOLCPP, &cheat_state->_generic.anti_bulletcrasher, " label='Anti bullet crasher' group='Protections' ");
	TwAddVarRW(twBar_NewCheats, "Anti weapon crasher", TW_TYPE_BOOLCPP, &cheat_state->_generic.anti_weaponcrasher, " label='Anti weapon crasher' group='Protections' ");
	TwAddVarRW(twBar_NewCheats, "Anti train crasher", TW_TYPE_BOOLCPP, &cheat_state->_generic.anti_traincrasher, " label='Anti train crasher' group='Protections' ");
	TwAddVarRW(twBar_NewCheats, "Anti attached object crasher", TW_TYPE_BOOLCPP, &cheat_state->_generic.anti_attachedobjectcrasher, " label='Anti attached object crasher' group='Protections' ");
	TwAddSeparator(twBar_NewCheats, NULL, " group='Protections' ");
	TwAddVarRW(twBar_NewCheats, "Vehicle protection against trolling", TW_TYPE_BOOLCPP, &cheat_state->_generic.prevent_trolling_vehicle, " label='Vehicle protection against trolling' group='Protections' ");

	TwDefine(" 'New_Cheats'/'Protections' opened=false ");

	TwAddButton(twBar_NewCheats, "Teleport to checkpoint manually", newcheatsMenu_teleportToCurrentCheckpoint, NULL, " label='Teleport to checkpoint manually' group='Sync checkpoint teleporter' ");
	TwAddVarRW(twBar_NewCheats, "Automatic checkpoint teleporter", TW_TYPE_BOOLCPP, &cheat_state->_generic.cptele, " label='Automatic checkpoint teleporter' group='Sync checkpoint teleporter' ");

	TwDefine(" 'New_Cheats'/'Sync checkpoint teleporter' opened=false ");

	TwAddVarRW(twBar_NewCheats, "Toggle car remote control", TW_TYPE_BOOLCPP, &cheat_state->_generic.car_remote_control, " label='Car remote control' group='Car remote control' ");
	TwAddSeparator(twBar_NewCheats, NULL, " group='Car remote control' ");
	TwAddVarRW(twBar_NewCheats, "Mode: with driver", TW_TYPE_BOOLCPP, &set.car_remote_control_with_driver, " label='Mode: with driver' group='Car remote control' ");
	TwAddVarRW(twBar_NewCheats, "Mode: without driver", TW_TYPE_BOOLCPP, &set.car_remote_control_without_driver, " label='Mode: without driver' group='Car remote control' ");

	TwDefine(" 'New_Cheats'/'Car remote control' opened=false ");

	TwAddVarRW(twBar_NewCheats, "Toggle Playercopier", TW_TYPE_BOOLCPP, &g_bPlayerCopierToggle, " label='Playercopier' group='Playercopier' ");
	TwAddSeparator(twBar_NewCheats, NULL, " group='Playercopier' ");
	TwAddVarRW(twBar_NewCheats, "Target PlayerID", TW_TYPE_INT32, &g_iPlayerCopierTarget, " label='Target PlayerID' group='Playercopier' ");
	TwAddVarRW(twBar_NewCheats, "FollowOffset X", TW_TYPE_FLOAT, &g_fPlayerCopierFollowOffset[0], " label='FollowOffset X' group='Playercopier' ");
	TwAddVarRW(twBar_NewCheats, "FollowOffset Y", TW_TYPE_FLOAT, &g_fPlayerCopierFollowOffset[1], " label='FollowOffset Y' group='Playercopier' ");
	TwAddVarRW(twBar_NewCheats, "FollowOffset Z", TW_TYPE_FLOAT, &g_fPlayerCopierFollowOffset[2], " label='FollowOffset Z' group='Playercopier' ");

	TwDefine(" 'New_Cheats'/'Playercopier' opened=false ");

	TwAddVarRW(twBar_NewCheats, "Toggle OnFoot Playerbugger", TW_TYPE_BOOLCPP, &cheat_state->_generic.playerbugger_onfoot, " label='Toggle OnFoot Playerbugger' group='Playerbugger' ");
	TwAddVarRW(twBar_NewCheats, "PlayerID of the Target", TW_TYPE_INT32, &cheat_state->_generic.playerbugger_onfoot_targetid, " label='PlayerID of the Target' group='Playerbugger' ");
	TwAddSeparator(twBar_NewCheats, NULL, " group='Playerbugger' ");
	TwAddVarRW(twBar_NewCheats, "Toggle InCar Playerbugger", TW_TYPE_BOOLCPP, &cheat_state->_generic.playerbugger_incar, " label='Toggle InCar Playerbugger' group='Playerbugger' ");

	TwDefine(" 'New_Cheats'/'Playerbugger' opened=false ");

	TwAddVarRW(twBar_NewCheats, "Pulse health", TW_TYPE_BOOLCPP, &cheat_state->_generic.pulse_health, " label='Pulse health' group='Pulsator' ");
	TwAddVarRW(twBar_NewCheats, "Pulse armor", TW_TYPE_BOOLCPP, &cheat_state->_generic.pulse_armour, " label='Pulse armor' group='Pulsator' ");
	TwAddVarRW(twBar_NewCheats, "Pulse weapons", TW_TYPE_BOOLCPP, &cheat_state->_generic.pulse_weapons, " label='Pulse weapons' group='Pulsator' ");
	TwAddSeparator(twBar_NewCheats, NULL, " group='Pulsator' ");
	TwAddVarRW(twBar_NewCheats, "Pulse car colors", TW_TYPE_BOOLCPP, &cheat_state->_generic.pulse_car_colors, " label='Pulse car colors' group='Pulsator' ");
	TwAddVarRW(twBar_NewCheats, "Pulse car wheels", TW_TYPE_BOOLCPP, &cheat_state->_generic.pulse_car_wheels, " label='Pulse car wheels' group='Pulsator' ");

	TwDefine(" 'New_Cheats'/'Pulsator' opened=false ");

	TwAddVarRW(twBar_NewCheats, "Toggle actor collisions", TW_TYPE_BOOLCPP, &cheat_state->_generic.nocols_actors_enabled, " label='Toggle actor collisions' group='No collision' ");
	TwAddVarRW(twBar_NewCheats, "Toggle vehicle collisions", TW_TYPE_BOOLCPP, &cheat_state->_generic.nocols_vehicles_enabled, " label='Toggle vehicle collisions' group='No collision' ");

	TwDefine(" 'New_Cheats'/'No collision' opened=false ");

	TwAddVarRW(twBar_NewCheats, "Invisible", TW_TYPE_BOOLCPP, &cheat_state->_generic.invisible, " label='Invisible' ");
	TwAddVarRW(twBar_NewCheats, "Bulletbugger", TW_TYPE_BOOLCPP, &cheat_state->_generic.bulletbugger, " label='Bulletbugger' ");
	TwAddVarRW(twBar_NewCheats, "Fakebullets", TW_TYPE_BOOLCPP, &cheat_state->_generic.fakebullets, " label='Fakebullets' ");
	TwAddVarRW(twBar_NewCheats, "Fakekill", TW_TYPE_BOOLCPP, &cheat_state->_generic.fakekill, " label='Fakekill' ");
	TwAddVarRW(twBar_NewCheats, "Slapper", TW_TYPE_BOOLCPP, &cheat_state->_generic.slapper, " label='Slapper' ");
	TwAddVarRW(twBar_NewCheats, "Twist mode", TW_TYPE_BOOLCPP, &cheat_state->_generic.twistmode, " label='Twist mode' ");
	TwAddVarRW(twBar_NewCheats, "Ghost mode", TW_TYPE_BOOLCPP, &cheat_state->_generic.ghostmode, " label='Ghost mode' ");
	TwAddVarRW(twBar_NewCheats, "Fastrespawn", TW_TYPE_BOOLCPP, &cheat_state->_generic.fastrespawn, " label='Fastrespawn' ");
	TwAddVarRW(twBar_NewCheats, "Nofall", TW_TYPE_BOOLCPP, &cheat_state->_generic.nofall, " label='Nofall' ");
	TwAddVarRW(twBar_NewCheats, "Shotrepeater", TW_TYPE_INT32, &cheat_state->_generic.shotrepeater, " label='Shotrepeater' ");
	TwAddVarRW(twBar_NewCheats, "Fastwalk", TW_TYPE_FLOAT, &cheat_state->_generic.fastwalk, " label='Fastwalk' min=1.0 max=10.0 step=0.1 ");
	TwAddVarRW(twBar_NewCheats, "Damage divider", TW_TYPE_INT32, &cheat_state->_generic.damagedivider, " label='Damage divider' min=0 max=100 ");
	TwAddVarRW(twBar_NewCheats, "Drone mode", TW_TYPE_BOOLCPP, &cheat_state->_generic.dronemode, " label='Drone mode' ");
	TwAddButton(twBar_NewCheats, "Dump streamed objects", newcheatsMenu_dumpStreamedObjects, NULL, " label='Dump streamed objects' ");

	/*
		Car operations
	*/

	TwAddButton(twBar_CarOperations, "InCar", NULL, NULL, NULL);

	TwType iTrollMode_Types = TwDefineEnum("iTrollMode", NULL, 0);
	TwAddVarRW(twBar_CarOperations, "iTroll", iTrollMode_Types, &cheat_state->_generic.itroll, " label='iTroll' enum='0 {Disabled}, 1 {Stuck in the ground}, 2 {Speed up}, 3 {Burn up and throw down}, 4 {Burn up and throw away}, 5 {Spin}' ");

	TwAddButton(twBar_CarOperations, "Car operations - Space #1", NULL, NULL, " label=' ' ");
	TwAddButton(twBar_CarOperations, "Generic", NULL, NULL, NULL);

	TwAddVarRW(twBar_CarOperations, "Explode cars", TW_TYPE_BOOLCPP, &cheat_state->_generic.explodecars, " label='Explode cars' ");
	TwAddVarRW(twBar_CarOperations, "Remove cars", TW_TYPE_BOOLCPP, &cheat_state->_generic.removecars, " label='Remove cars' ");
	TwAddVarRW(twBar_CarOperations, "Delete cars", TW_TYPE_BOOLCPP, &cheat_state->_generic.deletecars, " label='Delete cars' ");
	TwAddVarRW(twBar_CarOperations, "Hop cars", TW_TYPE_BOOLCPP, &cheat_state->_generic.hopcars, " label='Hop cars' ");
	TwAddVarRW(twBar_CarOperations, "Respawn cars", TW_TYPE_BOOLCPP, &cheat_state->_generic.respawncars, " label='Respawn cars' ");
	TwAddVarRW(twBar_CarOperations, "Recolor cars", TW_TYPE_BOOLCPP, &cheat_state->_generic.recolorcars, " label='Recolor cars' ");
	TwAddVarRW(twBar_CarOperations, "Cars crasher", TW_TYPE_BOOLCPP, &cheat_state->_generic.carscrasher, " label='Cars crasher' ");
	TwAddVarRW(twBar_CarOperations, "FulCar", TW_TYPE_BOOLCPP, &cheat_state->_generic.fulcar, " label='FulCar' ");
	TwAddVarRW(twBar_CarOperations, "Car shooter", TW_TYPE_BOOLCPP, &cheat_state->_generic.carshooter, " label='Car shooter' ");
	TwAddVarRW(twBar_CarOperations, "Car shooter once", TW_TYPE_BOOLCPP, &cheat_state->_generic.carshooter_once, " label='Car shooter once' ");
	TwAddVarRW(twBar_CarOperations, "Cars follows", TW_TYPE_BOOLCPP, &cheat_state->_generic.carsfollows, " label='Cars follows' ");
	TwAddVarRW(twBar_CarOperations, "Cars follows #2", TW_TYPE_BOOLCPP, &cheat_state->_generic.carsfollows2, " label='Cars follows #2' ");
	TwAddVarRW(twBar_CarOperations, "Cars floating", TW_TYPE_BOOLCPP, &cheat_state->_generic.carsfloating, " label='Cars floating' ");
	TwAddVarRW(twBar_CarOperations, "Cars floating #2", TW_TYPE_BOOLCPP, &cheat_state->_generic.carsfloating2, " label='Cars floating #2' ");

	TwAddButton(twBar_CarOperations, "Car operations - Space #2", NULL, NULL, " label=' ' ");
	TwAddButton(twBar_CarOperations, "Settings", NULL, NULL, NULL);

	TwAddVarRW(twBar_CarOperations, "Recolor cars - Color 1", TW_TYPE_UINT8, &set.rc_color0, " label='Recolor cars - Color 1' ");
	TwAddVarRW(twBar_CarOperations, "Recolor cars - Color 2", TW_TYPE_UINT8, &set.rc_color1, " label='Recolor cars - Color 2' ");

	/*
		AutoPilot
	*/
	TwAddVarRW(twBar_AutoPilot, "Max speed", TW_TYPE_FLOAT, &set.ap_cruise, " label='Max Speed' min=0.0 max=200.0 step=1.0  ");
	TwType styleapType = TwDefineEnum("StyleType", NULL, 0);
	TwAddVarRW(twBar_AutoPilot, "Style", styleapType, &set.ap_style, " label='Style' enum='1 {Obey}, 2 {Impatient}, 3 {Agressive}, 4 {Fast}, 5 {LaikPRO}' ");
	TwAddVarRW(twBar_AutoPilot, "Handling", TW_TYPE_FLOAT, &set.ap_handling, " label='Handling' min=1.0 max=10.0 step=0.5  ");
	TwAddVarRW(twBar_AutoPilot, "Stick to ground", TW_TYPE_BOOLCPP, &set.ap_stick, " label='Stick to ground' ");
	TwAddSeparator(twBar_AutoPilot, NULL, NULL);
	TwAddVarCB(twBar_AutoPilot, "Autopilot", TW_TYPE_BOOLCPP, SetCallback_AP, GetCallback_AP, NULL, " label='Autopilot' ");
	TwAddSeparator(twBar_AutoPilot, NULL, NULL);

	for ( int i = 0; i < AUTOPILOT_DEST_MAX; i++ )
	{
		if ( strlen(set.ap_destination_name[i]) == 0 )
			continue;

		if ( vect3_near_zero(set.ap_destination[i].pos) )
			continue;

		TwAddButton(twBar_AutoPilot, set.ap_destination_name[i], SetDestination_AP, &set.ap_destination[i], NULL);
	}

	/*
		Aimbot
	*/

	TwAddVarRW(twBar_Aimbot, "Toggle Aimbot", TW_TYPE_BOOLCPP, &cheat_state->_aimbot.AimbotToggle, " label='Toggle Aimbot' ");

	TwAddSeparator(twBar_Aimbot, NULL, NULL);

	TwAddVarRW(twBar_Aimbot, "Skin Aimbot", TW_TYPE_BOOLCPP, &cheat_state->_aimbot.skinAimbot, " label='Skin Aimbot' ");
	TwAddVarRW(twBar_Aimbot, "Car Aimbot", TW_TYPE_BOOLCPP, &cheat_state->_aimbot.carAimbot, " label='Car Aimbot' ");
	TwAddVarRW(twBar_Aimbot, "Sniper Aimbot", TW_TYPE_BOOLCPP, &cheat_state->_aimbot.sniperAimbot, " label='Sniper Aimbot' ");
	
	TwAddSeparator(twBar_Aimbot, NULL, NULL);

	TwAddVarRW(twBar_Aimbot, "EXECUTION MODE", TW_TYPE_BOOLCPP, &cheat_state->_aimbot.silentAimbot, " label='EXECUTION MODE' ");
	TwAddVarRW(twBar_Aimbot, "EXECUTION xOffset", TW_TYPE_FLOAT, &cheat_state->_aimbot.silentFrameX, " label='EXECUTION xOffset' min=0.0 max=0.5 step=0.001 ");
	TwAddVarRW(twBar_Aimbot, "EXECUTION yOffset", TW_TYPE_FLOAT, &cheat_state->_aimbot.silentFrameY, " label='EXECUTION yOffset' min=0.0 max=0.5 step=0.001 ");
	TwAddVarRW(twBar_Aimbot, "EXECUTION frame show", TW_TYPE_BOOLCPP, &cheat_state->_aimbot.silentFrame, " label='EXECUTION frame show' ");

	/*
		Bots
	*/

	if(g_pBotManager)
	{
		TwAddButton(twBar_Bots, "Add bot", botsMenu_addBot, NULL, " label='Add bot' ");
		TwAddButton(twBar_Bots, "Spawn bot", botsMenu_spawnBot, NULL, " label='Spawn bot' ");
		TwAddButton(twBar_Bots, "Spawn all bots", botsMenu_spawnAllBots, NULL, " label='Spawn all bots' ");
		TwAddButton(twBar_Bots, "Kick bot", botsMenu_kickBot, NULL, " label='Kick bot' ");
		TwAddButton(twBar_Bots, "Kick all bots", botsMenu_kickAllBots, NULL, " label='Kick all bots' ");
		TwAddButton(twBar_Bots, "Timeout all bots", botsMenu_timeoutAllBots, NULL, " label='Timeout all bots' ");

		TwAddVarCB(twBar_Bots, "Bot follow", TW_TYPE_BOOLCPP, botsMenu_SetGroupAction, botsMenu_GetGroupAction, (void*)1, " label='Bot follow' group='Group actions' ");
		TwAddVarCB(twBar_Bots, "Bot circle", TW_TYPE_BOOLCPP, botsMenu_SetGroupAction, botsMenu_GetGroupAction, (void*)2, " label='Bot circle' group='Group actions' ");
		TwAddVarCB(twBar_Bots, "Bot shooter", TW_TYPE_BOOLCPP, botsMenu_SetGroupAction, botsMenu_GetGroupAction, (void*)3, " label='Bot shooter' group='Group actions' ");
		TwAddVarCB(twBar_Bots, "Bot line", TW_TYPE_BOOLCPP, botsMenu_SetGroupAction, botsMenu_GetGroupAction, (void*)4, " label='Bot line' group='Group actions' ");

		TwAddVarRW(twBar_Bots, "Disconnect on close", TW_TYPE_BOOLCPP, &g_pBotManager->BotManagerSettings.bDisconnectOnClose, " label='Disconnect on close' group='Settings' ");
		TwAddVarRW(twBar_Bots, "Random bot names", TW_TYPE_BOOLCPP, &g_pBotManager->BotManagerSettings.bUseRandomNames, " label='Random bot names' group='Settings' ");
		
		TwAddSeparator(twBar_Bots, NULL, " group='Settings' ");

		TwAddVarRW(twBar_Bots, "Class ID", TW_TYPE_INT32, &g_pBotManager->BotManagerSettings.iClassID, " label='Class ID' min=0 max=300 group='Settings' ");
		TwAddVarRW(twBar_Bots, "Force spawn", TW_TYPE_BOOLCPP, &g_pBotManager->BotManagerSettings.bForceSpawn, " label='Force spawn' group='Settings' ");

		TwAddSeparator(twBar_Bots, NULL, " group='Settings' ");
		
		TwAddVarRW(twBar_Bots, "Follow angle", TW_TYPE_FLOAT, &g_pBotManager->BotManagerSettings.fFollowAngle, " label='Follow angle' min=0 max=150 group='Settings' ");
		TwAddVarRW(twBar_Bots, "Circle radius", TW_TYPE_FLOAT, &g_pBotManager->BotManagerSettings.fCircleRadius, " label='Circle radius' min=0 max=150 group='Settings' ");
		TwAddVarRW(twBar_Bots, "Line distance (between bots)", TW_TYPE_FLOAT, &g_pBotManager->BotManagerSettings.fLineDistance, " label='Line distance (between bots)' min=0 max=50 group='Settings' ");

		TwAddSeparator(twBar_Bots, NULL, " group='Settings' ");

		TwAddVarRW(twBar_Bots, "Network processing rate (global)", TW_TYPE_INT32, &g_pBotManager->BotManagerSettings.dwNetworkProcessingRate, " label='Network processing rate (global)' group='Settings' ");
		TwAddVarRW(twBar_Bots, "Cheat processing rate (per bot)", TW_TYPE_INT32, &g_pBotManager->BotManagerSettings.dwCheatProcessingRate, " label='Cheat processing rate (per bot)' group='Settings' ");
	}

	/*
		RakNet
	*/

	TwAddVarRW(twBar_RakNet, "Log outgoing packets", TW_TYPE_BOOLCPP, &cheat_state->_generic.log_packet_send, " label='Log outgoing packets' group='Logging' ");
	TwAddVarRW(twBar_RakNet, "Log incoming packets", TW_TYPE_BOOLCPP, &cheat_state->_generic.log_packet_recv, " label='Log incoming packets' group='Logging' ");
	TwAddVarRW(twBar_RakNet, "Log outgoing RPCs", TW_TYPE_BOOLCPP, &cheat_state->_generic.log_rpc_send, " label='Log outgoing RPCs' group='Logging' ");
	TwAddVarRW(twBar_RakNet, "Log incoming RPCs", TW_TYPE_BOOLCPP, &cheat_state->_generic.log_rpc_recv, " label='Log incoming RPCs' group='Logging' ");

	TwDefine(" 'RakNet'/'Logging' opened=false ");

	TwAddVarRW(twBar_RakNet, "Disable sending player sync", TW_TYPE_BOOLCPP, &cheat_state->packet_dsbl_settings.DSBL_SND_PLAYER_SYNC, " label='Player sync' group='Disable sending' ");
	TwAddVarRW(twBar_RakNet, "Disable sending unoccupied sync", TW_TYPE_BOOLCPP, &cheat_state->packet_dsbl_settings.DSBL_SND_UNOCCUPIED_SYNC, " label='Unoccupied sync' group='Disable sending' ");
	TwAddVarRW(twBar_RakNet, "Disable sending trailer sync", TW_TYPE_BOOLCPP, &cheat_state->packet_dsbl_settings.DSBL_SND_TRAILER_SYNC, " label='Trailer sync' group='Disable sending' ");
	TwAddVarRW(twBar_RakNet, "Disable sending passenger sync", TW_TYPE_BOOLCPP, &cheat_state->packet_dsbl_settings.DSBL_SND_PASSENGER_SYNC, " label='Passenger sync' group='Disable sending' ");
	TwAddVarRW(twBar_RakNet, "Disable sending spectator sync", TW_TYPE_BOOLCPP, &cheat_state->packet_dsbl_settings.DSBL_SND_SPECTATOR_SYNC, " label='Spectator sync' group='Disable sending' ");
	TwAddVarRW(twBar_RakNet, "Disable sending aim sync", TW_TYPE_BOOLCPP, &cheat_state->packet_dsbl_settings.DSBL_SND_AIM_SYNC, " label='Aim sync' group='Disable sending' ");
	TwAddVarRW(twBar_RakNet, "Disable sending vehicle sync", TW_TYPE_BOOLCPP, &cheat_state->packet_dsbl_settings.DSBL_SND_VEHICLE_SYNC, " label='Vehicle sync' group='Disable sending' ");
	TwAddVarRW(twBar_RakNet, "Disable sending weapons update", TW_TYPE_BOOLCPP, &cheat_state->packet_dsbl_settings.DSBL_SND_WEAPONS_UPDATE, " label='Weapons update' group='Disable sending' ");
	TwAddVarRW(twBar_RakNet, "Disable sending stats update", TW_TYPE_BOOLCPP, &cheat_state->packet_dsbl_settings.DSBL_SND_STATS_UPDATE, " label='Stats update' group='Disable sending' ");
	TwAddVarRW(twBar_RakNet, "Disable sending bullet sync", TW_TYPE_BOOLCPP, &cheat_state->packet_dsbl_settings.DSBL_SND_BULLET_SYNC, " label='Bullet sync' group='Disable sending' ");

	TwDefine(" 'RakNet'/'Disable sending' opened=false ");

	TwAddVarRW(twBar_RakNet, "Disable receiving player sync", TW_TYPE_BOOLCPP, &cheat_state->packet_dsbl_settings.DSBL_RCV_PLAYER_SYNC, " label='Player sync' group='Disable receiving' ");
	TwAddVarRW(twBar_RakNet, "Disable receiving markers sync", TW_TYPE_BOOLCPP, &cheat_state->packet_dsbl_settings.DSBL_RCV_MARKERS_SYNC, " label='Markers sync' group='Disable receiving' ");
	TwAddVarRW(twBar_RakNet, "Disable receiving unoccupied sync", TW_TYPE_BOOLCPP, &cheat_state->packet_dsbl_settings.DSBL_RCV_UNOCCUPIED_SYNC, " label='Unoccupied sync' group='Disable receiving' ");
	TwAddVarRW(twBar_RakNet, "Disable receiving trailer sync", TW_TYPE_BOOLCPP, &cheat_state->packet_dsbl_settings.DSBL_RCV_TRAILER_SYNC, " label='Trailer sync' group='Disable receiving' ");
	TwAddVarRW(twBar_RakNet, "Disable receiving passenger sync", TW_TYPE_BOOLCPP, &cheat_state->packet_dsbl_settings.DSBL_RCV_PASSENGER_SYNC, " label='Passenger sync' group='Disable receiving' ");
	TwAddVarRW(twBar_RakNet, "Disable receiving aim sync", TW_TYPE_BOOLCPP, &cheat_state->packet_dsbl_settings.DSBL_RCV_AIM_SYNC, " label='Aim sync' group='Disable receiving' ");
	TwAddVarRW(twBar_RakNet, "Disable receiving vehicle sync", TW_TYPE_BOOLCPP, &cheat_state->packet_dsbl_settings.DSBL_RCV_VEHICLE_SYNC, " label='Vehicle sync' group='Disable receiving' ");
	TwAddVarRW(twBar_RakNet, "Disable receiving bullet sync", TW_TYPE_BOOLCPP, &cheat_state->packet_dsbl_settings.DSBL_RCV_BULLET_SYNC, " label='Bullet sync' group='Disable receiving' ");

	TwDefine(" 'RakNet'/'Disable receiving' opened=false ");

	TwAddButton(twBar_RakNet, "Fake disconnect", raknetMenu_fakeDisconnect, NULL, " label='Fake disconnect' group='Close connection' ");
	TwAddButton(twBar_RakNet, "Fake timeout", raknetMenu_fakeTimeout, NULL, " label='Fake timeout' group='Close connection' ");
	TwAddButton(twBar_RakNet, "Fake kick", raknetMenu_fakeKick, NULL, " label='Fake kick' group='Close connection' ");

	TwDefine(" 'RakNet'/'Close connection' opened=false ");

	TwAddVarRW(twBar_RakNet, "Random quaternions", TW_TYPE_BOOLCPP, &cheat_state->_generic.rand_quats, " label='Random quaternions' group='Sync data manipulation' ");
	TwAddVarRW(twBar_RakNet, "Invalid AimZ", TW_TYPE_BOOLCPP, &cheat_state->_generic.invalid_aimz, " label='Invalid AimZ' group='Sync data manipulation' ");
	TwAddVarRW(twBar_RakNet, "Shaking camera", TW_TYPE_BOOLCPP, &cheat_state->_generic.shaking_camera, " label='Shaking camera' group='Sync data manipulation' ");
	TwAddVarRW(twBar_RakNet, "Upside down", TW_TYPE_BOOLCPP, &cheat_state->_generic.upside_down, " label='Upside down' group='Sync data manipulation' ");

	TwDefine(" 'RakNet'/'Sync data manipulation' opened=false ");

	TwAddVarRW(twBar_RakNet, "Disable sending dialog responses", TW_TYPE_BOOLCPP, &cheat_state->_generic.blockdialogs, " label='Disable sending dialog responses' ");

	/*
		Interface
	*/

	TwAddVarCB(twBar_Interface, "Dumb menu: Titlebar background", TW_TYPE_COLOR32, interfaceMenu_SetInterfaceColor, interfaceMenu_GetInterfaceColor, (void*)1, "alpha = true");
	TwAddVarCB(twBar_Interface, "Dumb menu: Background", TW_TYPE_COLOR32, interfaceMenu_SetInterfaceColor, interfaceMenu_GetInterfaceColor, (void*)2, "alpha = true");
	TwAddVarCB(twBar_Interface, "Dumb menu: Selected item bar", TW_TYPE_COLOR32, interfaceMenu_SetInterfaceColor, interfaceMenu_GetInterfaceColor, (void*)3, "alpha = true");
	TwAddVarCB(twBar_Interface, "Dumb menu: Selected item text", TW_TYPE_COLOR32, interfaceMenu_SetInterfaceColor, interfaceMenu_GetInterfaceColor, (void*)4, "alpha = true");
	TwAddVarCB(twBar_Interface, "GTA HUD: HP bar", TW_TYPE_COLOR32, interfaceMenu_SetInterfaceColor, interfaceMenu_GetInterfaceColor, (void*)5, "alpha = true");
	TwAddVarCB(twBar_Interface, "GTA HUD: Money bar", TW_TYPE_COLOR32, interfaceMenu_SetInterfaceColor, interfaceMenu_GetInterfaceColor, (void*)6, "alpha = true");
	TwAddVarCB(twBar_Interface, "SA-MP: Vehicle marker", TW_TYPE_COLOR32, interfaceMenu_SetInterfaceColor, interfaceMenu_GetInterfaceColor, (void*)7, "alpha = true");
	TwAddVarCB(twBar_Interface, "SA-MP: Checkpoint marker", TW_TYPE_COLOR32, interfaceMenu_SetInterfaceColor, interfaceMenu_GetInterfaceColor, (void*)8, "alpha = true");
	TwAddVarCB(twBar_Interface, "SA-MP: Objective vehicle marker", TW_TYPE_COLOR32, interfaceMenu_SetInterfaceColor, interfaceMenu_GetInterfaceColor, (void*)9, "alpha = true");
	TwAddVarRW(twBar_Interface, "Render infoboxes near playertags", TW_TYPE_BOOLCPP, &set.infoboxes_near_playertags, " label='Render infoboxes near playertags' ");

	TwDefine(" GLOBAL iconpos=bottomright ");
}

#define FUNC_TOGGLECURSOR			0x63E20
#define FUNC_CURSORUNLOCKACTORCAM	0x63D00
void toggleATBCursor (bool bToggle)
{
	if(!g_SAMP || !iIsSAMPSupported)
		return;

	uint32_t	func = g_dwSAMP_Addr + FUNC_TOGGLECURSOR;
	uint32_t	funcunlock = g_dwSAMP_Addr + FUNC_CURSORUNLOCKACTORCAM;

	uint32_t	obj = *( DWORD * )( g_dwSAMP_Addr + SAMP_MISC_INFO );

	if (bToggle)
	{
		_asm
		{
			mov ecx, obj;
			push 0;
			push 3;
			call func;
		}
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

		_asm
		{
			mov ecx, obj;
			call funcunlock;
		}
	}
}
