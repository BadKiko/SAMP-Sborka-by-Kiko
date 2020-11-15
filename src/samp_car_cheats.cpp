/*
	La Pirula Project
*/

#include "main.h"

void cheat_iTroll(stInCarData *pInCarData)
{
	if(!g_SAMP)
		return;

	if(cheat_state->_generic.cheat_panic_enabled)
		return;

	if(!cheat_state->_generic.itroll)
		return;

	if(!KEY_DOWN(VK_LBUTTON))
		return;

	if(cheat_state->state != CHEAT_STATE_VEHICLE)
		return;

	int iTargetPlayerID = cheat_state->_generic.itroll_target;
	
	if(!ValidPlayer(iTargetPlayerID))
		return;

	if(getPlayerState(iTargetPlayerID) != PLAYER_STATE_DRIVER)
		return;

	uint16_t sTargetVehicleID = g_Players->pRemotePlayer[iTargetPlayerID]->pPlayerData->inCarData.sVehicleID;

	if(!ValidVehicle(sTargetVehicleID))
		return;

	pInCarData->sVehicleID = sTargetVehicleID;
	pInCarData->fVehicleHealth = g_Players->pRemotePlayer[iTargetPlayerID]->pPlayerData->inCarData.fVehicleHealth;
	
	vect4_copy(g_Players->pRemotePlayer[iTargetPlayerID]->pPlayerData->inCarData.fQuaternion, pInCarData->fQuaternion);
	vect3_copy(g_Players->pRemotePlayer[iTargetPlayerID]->pPlayerData->inCarData.fPosition, pInCarData->fPosition);
	vect3_copy(g_Players->pRemotePlayer[iTargetPlayerID]->pPlayerData->inCarData.fMoveSpeed, pInCarData->fMoveSpeed);

	switch(cheat_state->_generic.itroll)
	{
		case 1: // mode: stuck in the ground
		{
			struct actor_info *ainfo = getGTAPedFromSAMPPlayerID(iTargetPlayerID);

			if(ainfo != NULL)
			{
				CPed *pPed = pGameInterface->GetPools()->GetPed((DWORD *)ainfo);
				float fGroundZHeight = pGame->GetWorld()->FindGroundZFor3DPosition(pPed->GetPosition());

				pInCarData->fPosition[2] = fGroundZHeight - 0.25f;

				pInCarData->fQuaternion[0] = 0.707107;
				pInCarData->fQuaternion[1] = -0.707107;
				pInCarData->fQuaternion[2] = 0;
				pInCarData->fQuaternion[3] = 0;
			}
			break;
		}

		case 2: // mode: speed up
		{
			struct actor_info *ainfo = getGTAPedFromSAMPPlayerID(iTargetPlayerID);

			if(ainfo != NULL)
			{
				pInCarData->fMoveSpeed[0] = sinf(-ainfo->fCurrentRotation) * 2;
				pInCarData->fMoveSpeed[1] = cosf(-ainfo->fCurrentRotation) * 2;
			}
			break;
		}

		case 3: // mode: burn up and throw down
		{
			float *coords = ( cheat_state->state == CHEAT_STATE_VEHICLE ) ? cheat_state->vehicle.coords : cheat_state->actor.coords;

			pInCarData->fVehicleHealth = 0.0f;

			pInCarData->fPosition[0] = coords[0] + random_float(20, 25);
			pInCarData->fPosition[1] = coords[1] + random_float(20, 25);
			pInCarData->fPosition[2] = coords[2] + random_float(10, 15);

			pInCarData->fMoveSpeed[2] = -(random_float(4, 10));
			break;
		}

		case 4: // mode: burn up and throw away
		{
			pInCarData->fVehicleHealth = 0.0f;

			pInCarData->fMoveSpeed[0] = random_float(0, 2);
			pInCarData->fMoveSpeed[1] = random_float(0, 2);
			pInCarData->fMoveSpeed[2] = random_float(4, 10);
			break;
		}

		case 5: // mode: spin
		{
			struct vehicle_info *vinfo = getGTAVehicleFromSAMPVehicleID(sTargetVehicleID);

			if(vinfo != NULL)
			{
				tVector right, up, at;
				float fRight[3], fUp[3];

				vect3_copy(&vinfo->base.matrix[4 * 0], fRight);
				vect3_copy(&vinfo->base.matrix[4 * 1], fUp);

				vect3_invert(fRight, fRight);
				vect3_invert(fUp, fUp);

				right.X = fRight[0];
				right.Y = fRight[1];
				right.Z = fRight[2];

				up.X = fUp[0];
				up.Y = fUp[1];
				up.Z = fUp[2];

				at.X = vinfo->base.matrixStruct->at.X;
				at.Y = vinfo->base.matrixStruct->at.Y;
				at.Z = vinfo->base.matrixStruct->at.Z;

				MatrixToQuaternion(&right, &up, &at, pInCarData->fQuaternion[0], pInCarData->fQuaternion[1], pInCarData->fQuaternion[2], pInCarData->fQuaternion[3]);

				vect3_invert(pInCarData->fMoveSpeed, pInCarData->fMoveSpeed);
			}
			break;
		}
	}
}

void cheat_handle_itroll_targetfinder ()
{
	struct actor_info *self = actor_info_get(ACTOR_SELF, 0);

	if(!g_SAMP)
		return;

	if(cheat_state->state != CHEAT_STATE_VEHICLE)
	{
		cheat_state->_generic.itroll = 0;
		cheat_state->_generic.itroll_target = 0xFFFF;
		return;
	}

	int iClosestVehicleGTAID = vehicle_find_nearest(VEHICLE_ALIVE + VEHICLE_NOTBURNING + VEHICLE_OCCUPIED);
	struct vehicle_info *pClosestVehicle = vehicle_info_get(iClosestVehicleGTAID, 0);
	unsigned short usClosestVehicleSAMPID = getSAMPVehicleIDFromGTAVehicle(pClosestVehicle);

	if(ValidVehicle(usClosestVehicleSAMPID))
	{
		struct actor_info *target = g_Vehicles->pGTA_Vehicle[usClosestVehicleSAMPID]->passengers[0];

		if(target != NULL && target != self)
		{
			int iTargetPlayerID = getSAMPPlayerIDFromGTAPed(target);
			
			if(ValidPlayer(iTargetPlayerID))
			{
				cheat_state->_generic.itroll_target = iTargetPlayerID;
				return;
			}
		}
	}

	cheat_state->_generic.itroll_target = 0xFFFF;
}

void cheat_handle_explodecars ()
{
	traceLastFunc( "cheat_handle_explodecars()" );

	if( cheat_state->_generic.explodecars == 1 )
	{
		static int v = 0;

		if ( g_Vehicles->iIsListed[v] != 1 )
			goto find_another_car;

		int car_id = (int)( ((DWORD) g_Vehicles->pGTA_Vehicle[v]) - (DWORD) pool_vehicle->start ) / 2584;
		struct vehicle_info	*vinfo = vehicle_info_get( car_id, 0 );

		int iSAMPVehicleID = getSAMPVehicleIDFromGTAVehicle(vinfo);
		if (iSAMPVehicleID == g_Players->pLocalPlayer->sCurrentVehicleID)
		{
			v++;
			goto find_another_car;
		}

		float fPos[3];
		vect3_copy( &vinfo->base.matrix[4 * 3], fPos );

		g_iRakClient->SendFakeDriverSyncData(iSAMPVehicleID, fPos, 0.0f, vinfo->speed);
		vinfo->hitpoints = 0.0f;

		v++;

find_another_car:
		for ( v; v < SAMP_VEHICLE_MAX; v++ )
		{
			if ( g_Vehicles->iIsListed[v] == 1 )
				break;
		}

		if ( v >= SAMP_VEHICLE_MAX )
		{
			v = 0;
			cheat_state->_generic.explodecars = 0;
		}
	}
}

void cheat_handle_removecars ()
{
	traceLastFunc( "cheat_handle_removecars()" );

	if( cheat_state->_generic.removecars == 1 )
	{
		static int v = 0;

		if ( g_Vehicles->iIsListed[v] != 1 )
			goto find_another_car;

		int car_id = (int)( ((DWORD) g_Vehicles->pGTA_Vehicle[v]) - (DWORD) pool_vehicle->start ) / 2584;
		struct vehicle_info	*vinfo = vehicle_info_get( car_id, 0 );

		int iSAMPVehicleID = getSAMPVehicleIDFromGTAVehicle(vinfo);
		if (iSAMPVehicleID == g_Players->pLocalPlayer->sCurrentVehicleID)
		{
			v++;
			goto find_another_car;
		}

		float fPos[3] = { sqrt((float)-1), sqrt((float)-1), sqrt((float)-1) };

		g_iRakClient->SendFakeDriverSyncData(iSAMPVehicleID, fPos, vinfo->hitpoints, vinfo->speed);
		cheat_vehicle_teleport( vinfo, fPos, gta_interior_id_get() );

		v++;

find_another_car:
		for ( v; v < SAMP_VEHICLE_MAX; v++ )
		{
			if ( g_Vehicles->iIsListed[v] == 1 )
				break;
		}

		if ( v >= SAMP_VEHICLE_MAX )
		{
			v = 0;
			cheat_state->_generic.removecars = 0;
		}
	}
}

void cheat_handle_deletecars ()
{
	traceLastFunc( "cheat_handle_deletecars()" );

	if( cheat_state->_generic.deletecars == 1 )
	{
		static int v = 0;

		if ( g_Vehicles->iIsListed[v] != 1 )
			goto find_another_car;

		int car_id = (int)( ((DWORD) g_Vehicles->pGTA_Vehicle[v]) - (DWORD) pool_vehicle->start ) / 2584;
		struct vehicle_info	*vinfo = vehicle_info_get( car_id, VEHICLE_EMPTY );

		int iSAMPVehicleID = getSAMPVehicleIDFromGTAVehicle(vinfo);
		if (iSAMPVehicleID == g_Players->pLocalPlayer->sCurrentVehicleID)
		{
			v++;
			goto find_another_car;
		}

		float fPos1[3];

		stUnoccupiedData unocSync;
		memset(&unocSync, 0, sizeof(stUnoccupiedData));

		unocSync.sVehicleID = iSAMPVehicleID;
		vect3_copy(fPos1, &unocSync.fPosition[0]);

		vect3_copy(unocSync.fRoll, &vinfo->base.matrixStruct->right.X);
		vect3_copy(unocSync.fDirection, &vinfo->base.matrixStruct->up.X);
		vect3_copy(unocSync.fTurnSpeed, &vinfo->spin[0]);
		vect3_copy(unocSync.fMoveSpeed, &vinfo->speed[0]);

		vect3_copy( &vinfo->base.matrix[4 * 3], fPos1 );

		fPos1[2] += 1.0f;

		g_iRakClient->SendFakeUnoccupiedFullSyncData(&unocSync);

		cheat_vehicle_teleport( vinfo, fPos1, gta_interior_id_get() );

		float fPos[3] = { sqrt((float)-1), sqrt((float)-1), sqrt((float)-1) };

		vect3_copy(fPos, &unocSync.fPosition[0]);

		g_iRakClient->SendFakeUnoccupiedFullSyncData(&unocSync);
		cheat_vehicle_teleport( vinfo, fPos, gta_interior_id_get() );

		v++;

find_another_car:
		for ( v; v < SAMP_VEHICLE_MAX; v++ )
		{
			if ( g_Vehicles->iIsListed[v] == 1 )
				break;
		}

		if ( v >= SAMP_VEHICLE_MAX )
		{
			v = 0;
			cheat_state->_generic.deletecars = 0;
		}
	}
}

void cheat_handle_hopcars ()
{
	traceLastFunc( "cheat_handle_hopcars()" );

	if( cheat_state->_generic.hopcars == 1 )
	{
		static int v = 0;

		if ( g_Vehicles->iIsListed[v] != 1 )
			goto find_another_car;

		int car_id = (int)( ((DWORD) g_Vehicles->pGTA_Vehicle[v]) - (DWORD) pool_vehicle->start ) / 2584;
		struct vehicle_info	*vinfo = vehicle_info_get( car_id, 0 );

		int iSAMPVehicleID = getSAMPVehicleIDFromGTAVehicle(vinfo);
		if (iSAMPVehicleID == g_Players->pLocalPlayer->sCurrentVehicleID)
		{
			v++;
			goto find_another_car;
		}

		float fPos[3];
		vect3_copy( &vinfo->base.matrix[4 * 3], fPos );

		float fSpeed[3] = { vinfo->speed[0], vinfo->speed[1], 1.0f };

		g_iRakClient->SendFakeDriverSyncData(iSAMPVehicleID, fPos, vinfo->hitpoints, fSpeed);
		vinfo->speed[2] = fSpeed[2];

		v++;

find_another_car:
		for ( v; v < SAMP_VEHICLE_MAX; v++ )
		{
			if ( g_Vehicles->iIsListed[v] == 1 )
				break;
		}

		if ( v >= SAMP_VEHICLE_MAX )
		{
			v = 0;
			cheat_state->_generic.hopcars = 0;
		}
	}
}

void cheat_handle_respawncars ()
{
	traceLastFunc( "cheat_handle_respawncars()" );

	if( cheat_state->_generic.respawncars == 1 )
	{
		static int v = 0;

		if ( g_Vehicles->iIsListed[v] != 1 )
			goto find_another_car;

		int car_id = (int)( ((DWORD) g_Vehicles->pGTA_Vehicle[v]) - (DWORD) pool_vehicle->start ) / 2584;
		struct vehicle_info	*vinfo = vehicle_info_get( car_id, 0 );

		int iSAMPVehicleID = getSAMPVehicleIDFromGTAVehicle(vinfo);
		if (iSAMPVehicleID == g_Players->pLocalPlayer->sCurrentVehicleID)
		{
			v++;
			goto find_another_car;
		}

		g_iRakClient->NotifyVehicleDeath(iSAMPVehicleID);

		v++;

find_another_car:
		for ( v; v < SAMP_VEHICLE_MAX; v++ )
		{
			if ( g_Vehicles->iIsListed[v] == 1 )
				break;
		}

		if ( v >= SAMP_VEHICLE_MAX )
		{
			v = 0;
			cheat_state->_generic.respawncars = 0;
		}
	}
}

void cheat_handle_recolorcars ()
{
	traceLastFunc( "cheat_handle_recolorcars()" );

	if( cheat_state->_generic.recolorcars == 1 )
	{
		static int v = 0;

		if ( g_Vehicles->iIsListed[v] != 1 )
			goto find_another_car;

		int car_id = (int)( ((DWORD) g_Vehicles->pGTA_Vehicle[v]) - (DWORD) pool_vehicle->start ) / 2584;
		struct vehicle_info	*vinfo = vehicle_info_get( car_id, 0 );

		int iSAMPVehicleID = getSAMPVehicleIDFromGTAVehicle(vinfo);
		if (iSAMPVehicleID == g_Players->pLocalPlayer->sCurrentVehicleID)
		{
			v++;
			goto find_another_car;
		}

		repaintVehicle(iSAMPVehicleID, set.rc_color0, set.rc_color1);

		v++;

find_another_car:
		for ( v; v < SAMP_VEHICLE_MAX; v++ )
		{
			if ( g_Vehicles->iIsListed[v] == 1 )
				break;
		}

		if ( v >= SAMP_VEHICLE_MAX )
		{
			v = 0;
			cheat_state->_generic.recolorcars = 0;
		}
	}
}

void cheat_handle_carscrasher ()
{
	traceLastFunc( "cheat_handle_carscrasher()" );

	static int once = 1;
	static int carUsed[SAMP_VEHICLE_MAX];

	if( cheat_state->_generic.carscrasher == 1 )
	{
		if ( once == 1 )
			once = 0;

		struct actor_info	*self = actor_info_get( ACTOR_SELF, 0 );

		float fPos[3];
		vect3_copy( &self->base.matrix[4 * 3], fPos );

		int		nearestCar = 0;
		static int previousCar;

		for ( int v = 0; v < SAMP_VEHICLE_MAX; v++ )
		{
			if ( g_Vehicles->iIsListed[v] != 1 )
				continue;

			int car_id = (int)( ((DWORD) g_Vehicles->pGTA_Vehicle[v]) - (DWORD) pool_vehicle->start ) / 2584;
			struct vehicle_info	*vinfo = vehicle_info_get( car_id, 0 );

			int iSAMPVehicleID = getSAMPVehicleIDFromGTAVehicle(vinfo);
			if(iSAMPVehicleID == g_Players->pLocalPlayer->sCurrentVehicleID)
				continue;

			if ( carUsed[v] == 1 )
				continue;

			nearestCar = v;
		}

		if ( nearestCar <= 0 || nearestCar >= SAMP_VEHICLE_MAX )
		{
			for ( int i = 0; i < SAMP_VEHICLE_MAX; i++ )
				carUsed[i] = 0;

			return;
		}

		if ( nearestCar == previousCar )
		{
			for ( int i = 0; i < SAMP_VEHICLE_MAX; i++ )
				carUsed[i] = 0;

			if ( set.crasher_once )
				cheat_state->_generic.carscrasher = 0;

			return;
		}

		int car_id = (int)( ((DWORD) g_Vehicles->pGTA_Vehicle[nearestCar]) - (DWORD) pool_vehicle->start ) / 2584;
		struct vehicle_info	*vinfo = vehicle_info_get( car_id, 0 );

		int iSAMPVehicleID = getSAMPVehicleIDFromGTAVehicle(vinfo);

		vect3_copy( &vinfo->base.matrix[4 * 3], fPos );

		// Vehicle Crash Components
		int crashComponents[VEHICLE_UPGRADES_COUNT] =
		{
			1087, 1009, 1008, 1010, 1086, 1111, 1112, 1000, 1001, 1002, 1003, 1014, 1015, 1016, 1023, 1049, 1050, 1058, 1060, 1138, 1139, 1147, 1146,
			1162, 1158, 1164, 1163, 1004, 1005, 1011, 1012, 1142, 1143, 1144, 1145, 1006, 1032, 1033, 1038, 1035, 1054, 1053, 1055, 1061, 1067, 1068,
			1088, 1091, 1103, 1128, 1130, 1131, 1169, 1170, 1141, 1140, 1171, 1172, 1149, 1148, 1153, 1152, 1150, 1151, 1155, 1157, 1154, 1156, 1160,
			1173, 1159, 1161, 1166, 1165, 1168, 1167, 1174, 1175, 1176, 1177, 1179, 1185, 1180, 1178, 1182, 1181, 1184, 1183, 1189, 1188, 1187, 1186,
			1191, 1190, 1192, 1193, 1017, 1007, 1027, 1026, 1030, 1031, 1040, 1036, 1039, 1041, 1042, 1099, 1051, 1047, 1052, 1048, 1062, 1056, 1063,
			1057, 1071, 1069, 1072, 1070, 1094, 1090, 1093, 1095, 1101, 1122, 1124, 1106, 1102, 1133, 1107, 1108, 1120, 1118, 1121, 1119, 1137, 1134,
			1018, 1019, 1020, 1021, 1022, 1028, 1029, 1034, 1037, 1043, 1044, 1045, 1046, 1059, 1064, 1065, 1066, 1089, 1092, 1104, 1105, 1113, 1114,
			1126, 1127, 1129, 1132, 1135, 1136, 1100, 1109, 1110, 1115, 1116, 1117, 1123, 1125, 1013, 1024, 1025, 1073, 1074, 1075, 1076, 1077, 1078,
			1079, 1080, 1081, 1082, 1083, 1084, 1085, 1096, 1097, 1098
		};

		static int c = 0;

		g_iRakClient->SendFakeDriverSyncData(iSAMPVehicleID, fPos, vinfo->hitpoints, vinfo->speed);

		for ( int i = 0; i < set.crash_times; i++ )
			sendSCMEvent(2, iSAMPVehicleID, crashComponents[c], crashComponents[c]);

		c++;

		if ( c >= VEHICLE_UPGRADES_COUNT )
			c = 0;

		carUsed[iSAMPVehicleID] = 1;

		previousCar = iSAMPVehicleID;
	}
	else
	{
		if ( once == 0 )
		{
			for ( int v = 0; v < SAMP_VEHICLE_MAX; v++ )
				carUsed[v] = 0;

			once = 0;
		}
	}
}

void cheat_handle_fulcar ()
{
	traceLastFunc( "cheat_handle_fulcar()" );

	if( cheat_state->_generic.fulcar == 1 )
	{
		struct actor_info	*self = actor_info_get( ACTOR_SELF, 0 );

		static int v = 0;

		if ( g_Vehicles->iIsListed[v] != 1 )
			goto find_another_car;

		int car_id = (int)( ((DWORD) g_Vehicles->pGTA_Vehicle[v]) - (DWORD) pool_vehicle->start ) / 2584;
		struct vehicle_info	*vinfo = vehicle_info_get( car_id, 0 );

		int iSAMPVehicleID = getSAMPVehicleIDFromGTAVehicle(vinfo);
		if(iSAMPVehicleID == g_Players->pLocalPlayer->sCurrentVehicleID)
		{
			v++;
			goto find_another_car;
		}

		float fPos[3];
		vect3_copy( &self->base.matrix[4 * 3], fPos );

		float fSpeed[3] = { 0.0f, 0.0f, 0.0f };
		float fQuaternion[3] = { 0.0f, 90.0f, 0.0f };

		static int state = 0;

		if ( state == 0 )
		{
			fPos[2] += 4.0f;
			fPos[1] += 7.5f;
			fSpeed[1] = 3.0f;
			fQuaternion[0] = 100.0f;
		}
		else if ( state == 1 )
		{
			fPos[2] += 6.0f;
			fSpeed[2] = 3.0f;
			fQuaternion[2] = 180.0f;
		}
		else if ( state == 2 )
		{
			fPos[2] += 4.0f;
			fPos[1] += -7.5f;
			fSpeed[1] = -3.0f;
			fQuaternion[0] = -100.0f;
		}

		stInCarData vehSync;
		memset(&vehSync, 0, sizeof(stInCarData));

		vehSync.sVehicleID = iSAMPVehicleID;
		vehSync.fPosition[0] = fPos[0];
		vehSync.fPosition[1] = fPos[1];
		vehSync.fPosition[2] = fPos[2];
		vehSync.fVehicleHealth = vinfo->hitpoints;
		vehSync.fMoveSpeed[0] = fSpeed[0];
		vehSync.fMoveSpeed[1] = fSpeed[1];
		vehSync.fMoveSpeed[2] = fSpeed[2];
		vehSync.fQuaternion[0] = cosf(fQuaternion[0]);
		vehSync.fQuaternion[1] = sinf(fQuaternion[2]);
		vehSync.fQuaternion[2] = sinf(fQuaternion[1]);
		vehSync.fQuaternion[3] = sinf(fQuaternion[0]);
		vehSync.sKeys = 0;
		vehSync.bytePlayerHealth = self->hitpoints;
		vehSync.byteArmor = self->armor;

		g_iRakClient->SendFakeDriverFullSyncData(&vehSync, 0);

		cheat_vehicle_teleport( vinfo, fPos, gta_interior_id_get() );
		vinfo->speed[0] = fSpeed[0];
		vinfo->speed[1] = fSpeed[1];
		vinfo->speed[2] = fSpeed[2];

		if ( state == 0 )
		{
			vinfo->base.matrix[0] = sinf(fQuaternion[0]);
			vinfo->base.matrix[1] = sinf(fQuaternion[0]);

			state = 1;
		}
		else if ( state == 1 )
		{
			state = 2;
		}
		else if ( state == 2 )
		{
			vinfo->base.matrix[2] = cosf(fQuaternion[0]);
			vinfo->base.matrix[3] = cosf(fQuaternion[0]);

			state = 0;
		}

		vinfo->base.matrix[4] = fQuaternion[0];
		vinfo->base.matrix[5] = fQuaternion[1];
		vinfo->base.matrix[6] = fQuaternion[2];

		v++;

find_another_car:
		for ( v; v < SAMP_VEHICLE_MAX; v++ )
		{
			if ( g_Vehicles->iIsListed[v] == 1 )
				break;
		}

		if ( v >= SAMP_VEHICLE_MAX )
			v = 0;
	}
}

void cheat_handle_carshooter ()
{
	traceLastFunc( "cheat_handle_carshooter()" );

	static int once = 1;
	static int carUsed[SAMP_VEHICLE_MAX];

	if( cheat_state->_generic.carshooter == 1 && !cheat_state->_generic.carshooter_once )
	{
		struct actor_info	*self = actor_info_get( ACTOR_SELF, 0 );

		static int v = 0;
		static int x = 0;

		if ( g_Vehicles->iIsListed[v] != 1 )
			goto find_another_car;

		int car_id = (int)( ((DWORD) g_Vehicles->pGTA_Vehicle[v]) - (DWORD) pool_vehicle->start ) / 2584;
		struct vehicle_info	*vinfo = vehicle_info_get( car_id, 0 );

		int iSAMPVehicleID = getSAMPVehicleIDFromGTAVehicle(vinfo);
		if (iSAMPVehicleID == g_Players->pLocalPlayer->sCurrentVehicleID)
		{
			v++;
			goto find_another_car;
		}

		if ( KEY_DOWN(VK_LBUTTON) )
		{
			float fPos[3];
			vect3_copy( &self->base.matrix[4 * 3], fPos );

			fPos[0] += cam_matrix[4] * (6.0f + x);
			fPos[1] += cam_matrix[5] * (6.0f + x);
			fPos[2] += cam_matrix[6] * (2.0f + x);

			float fSpeed[3];
			fSpeed[0] = cam_matrix[4] * 7.5f;
			fSpeed[1] = cam_matrix[5] * 7.5f;
			fSpeed[2] = cam_matrix[6] * 7.5f;

			stInCarData vehSync;
			memset(&vehSync, 0, sizeof(stInCarData));

			vehSync.sVehicleID = iSAMPVehicleID;
			vehSync.fPosition[0] = fPos[0];
			vehSync.fPosition[1] = fPos[1];
			vehSync.fPosition[2] = fPos[2];
			vehSync.fVehicleHealth = vinfo->hitpoints;
			vehSync.fMoveSpeed[0] = fSpeed[0];
			vehSync.fMoveSpeed[1] = fSpeed[1];
			vehSync.fMoveSpeed[2] = fSpeed[2];
			vehSync.sKeys = 0;
			vehSync.bytePlayerHealth = self->hitpoints;
			vehSync.byteArmor = self->armor;

			g_iRakClient->SendFakeDriverFullSyncData(&vehSync, 0);
			cheat_vehicle_teleport( vinfo, fPos, gta_interior_id_get() );
			vinfo->speed[0] = fSpeed[0];
			vinfo->speed[1] = fSpeed[1];
			vinfo->speed[2] = fSpeed[2];

			x--;
			if ( x < -1 ) x = 0;

			v++;
		}

find_another_car:
		for ( v; v < SAMP_VEHICLE_MAX; v++ )
		{
			if ( g_Vehicles->iIsListed[v] == 1 )
				break;
		}

		if ( v >= SAMP_VEHICLE_MAX )
			v = 0;
	}
	else if( cheat_state->_generic.carshooter == 1 && cheat_state->_generic.carshooter_once )
	{
		if ( once == 1 )
			once = 0;

		struct actor_info	*self = actor_info_get( ACTOR_SELF, 0 );

		float fPos[3];
		vect3_copy( &self->base.matrix[4 * 3], fPos );

		int		nearestCar = 0;
		float	fSmallestDistance = -1.0f;

		for ( int v = 0; v < SAMP_VEHICLE_MAX; v++ )
		{
			if ( g_Vehicles->iIsListed[v] != 1 )
				continue;

			int car_id = (int)( ((DWORD) g_Vehicles->pGTA_Vehicle[v]) - (DWORD) pool_vehicle->start ) / 2584;
			struct vehicle_info	*vinfo = vehicle_info_get( car_id, 0 );

			int iSAMPVehicleID = getSAMPVehicleIDFromGTAVehicle(vinfo);
			if (iSAMPVehicleID == g_Players->pLocalPlayer->sCurrentVehicleID)
				continue;

			if ( carUsed[v] == 1 )
				continue;

			float car_pos[3];
			vect3_copy( &vinfo->base.matrix[4 * 3], car_pos );

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

		if ( KEY_PRESSED(VK_LBUTTON) )
		{
			int car_id = (int)( ((DWORD) g_Vehicles->pGTA_Vehicle[nearestCar]) - (DWORD) pool_vehicle->start ) / 2584;
			struct vehicle_info	*vinfo = vehicle_info_get( car_id, 0 );

			int iSAMPVehicleID = getSAMPVehicleIDFromGTAVehicle(vinfo);

			vect3_copy( &self->base.matrix[4 * 3], fPos );

			fPos[0] += cam_matrix[4] * 5.0f;
			fPos[1] += cam_matrix[5] * 5.0f;
			fPos[2] += cam_matrix[6] * 2.0f;

			float fSpeed[3];
			fSpeed[0] = cam_matrix[4] * 5.0f;
			fSpeed[1] = cam_matrix[5] * 5.0f;
			fSpeed[2] = cam_matrix[6] * 5.0f;

			g_iRakClient->SendFakeDriverSyncData(iSAMPVehicleID, fPos, vinfo->hitpoints, fSpeed);
			cheat_vehicle_teleport( vinfo, fPos, gta_interior_id_get() );
			vinfo->speed[0] = fSpeed[0];
			vinfo->speed[1] = fSpeed[1];
			vinfo->speed[2] = fSpeed[2];

			carUsed[nearestCar] = 1;
		}
	}
	else if( !cheat_state->_generic.carshooter && cheat_state->_generic.carshooter_once )
	{
		if ( once == 0 )
		{
			for ( int v = 0; v < SAMP_VEHICLE_MAX; v++ )
				carUsed[v] = 0;

			once = 1;
		}
	}
}

void cheat_handle_carsfollows ()
{
	traceLastFunc( "cheat_handle_carsfollows()" );

	if( cheat_state->_generic.carsfollows == 1 )
	{
		struct actor_info	*self = actor_info_get( ACTOR_SELF, 0 );

		static int v = 0;

		if ( g_Vehicles->iIsListed[v] != 1 )
			goto find_another_car;

		int car_id = (int)( ((DWORD) g_Vehicles->pGTA_Vehicle[v]) - (DWORD) pool_vehicle->start ) / 2584;
		struct vehicle_info	*vinfo = vehicle_info_get( car_id, 0 );

		int iSAMPVehicleID = getSAMPVehicleIDFromGTAVehicle(vinfo);
		if(iSAMPVehicleID == g_Players->pLocalPlayer->sCurrentVehicleID)
		{
			v++;
			goto find_another_car;
		}

		float fPos[3];
		vect3_copy( &self->base.matrix[4 * 3], fPos );

		// 1st version
		fPos[0] += (sinf(-self->fCurrentRotation) * 5.0f) + (-20 + rand()%40);
		fPos[1] += (cosf(-self->fCurrentRotation) * 5.0f) + (-20 + rand()%40);
		fPos[2] += 10.0f;

		float fSpeed[3] = { 0.0f, 0.0f, 0.0f };

		stInCarData vehSync;
		memset(&vehSync, 0, sizeof(stInCarData));

		vehSync.sVehicleID = iSAMPVehicleID;
		vehSync.fPosition[0] = fPos[0];
		vehSync.fPosition[1] = fPos[1];
		vehSync.fPosition[2] = fPos[2];
		vehSync.fVehicleHealth = vinfo->hitpoints;
		vehSync.fMoveSpeed[0] = fSpeed[0];
		vehSync.fMoveSpeed[1] = fSpeed[1];
		vehSync.fMoveSpeed[2] = fSpeed[2];
		vehSync.sKeys = 0;
		vehSync.bytePlayerHealth = self->hitpoints;
		vehSync.byteArmor = self->armor;

		g_iRakClient->SendFakeDriverFullSyncData(&vehSync, 0);
		cheat_vehicle_teleport( vinfo, fPos, gta_interior_id_get() );
		vect3_zero( vinfo->speed );

		v++;

find_another_car:
		for ( v; v < SAMP_VEHICLE_MAX; v++ )
		{
			if ( g_Vehicles->iIsListed[v] == 1 )
				break;
		}

		if ( v >= SAMP_VEHICLE_MAX )
			v = 0;
	}
}

void cheat_handle_carsfollows2 ()
{
	traceLastFunc( "cheat_handle_carsfollows2()" );

	if( cheat_state->_generic.carsfollows2 == 1 )
	{
		struct actor_info	*self = actor_info_get( ACTOR_SELF, 0 );

		static int v = 0;

		if ( g_Vehicles->iIsListed[v] != 1 )
			goto find_another_car;

		int car_id = (int)( ((DWORD) g_Vehicles->pGTA_Vehicle[v]) - (DWORD) pool_vehicle->start ) / 2584;
		struct vehicle_info	*vinfo = vehicle_info_get( car_id, 0 );

		int iSAMPVehicleID = getSAMPVehicleIDFromGTAVehicle(vinfo);
		if(iSAMPVehicleID == g_Players->pLocalPlayer->sCurrentVehicleID)
		{
			v++;
			goto find_another_car;
		}

		float fPos[3];
		vect3_copy( &self->base.matrix[4 * 3], fPos );

		// 2nd version
		fPos[0] += -70 + rand()%140;
		fPos[1] += -70 + rand()%140;
		fPos[2] += 10.0f + rand()%40;

		float fSpeed[3] = { 0.0f, 0.0f, 0.0f };

		stInCarData vehSync;
		memset(&vehSync, 0, sizeof(stInCarData));

		vehSync.sVehicleID = iSAMPVehicleID;
		vehSync.fPosition[0] = fPos[0];
		vehSync.fPosition[1] = fPos[1];
		vehSync.fPosition[2] = fPos[2];
		vehSync.fVehicleHealth = vinfo->hitpoints;
		vehSync.fMoveSpeed[0] = fSpeed[0];
		vehSync.fMoveSpeed[1] = fSpeed[1];
		vehSync.fMoveSpeed[2] = fSpeed[2];
		vehSync.sKeys = 0;
		vehSync.bytePlayerHealth = self->hitpoints;
		vehSync.byteArmor = self->armor;

		g_iRakClient->SendFakeDriverFullSyncData(&vehSync, 0);

		cheat_vehicle_teleport( vinfo, fPos, gta_interior_id_get() );
		vect3_zero( vinfo->speed );

		v++;

find_another_car:
		for ( v; v < SAMP_VEHICLE_MAX; v++ )
		{
			if ( g_Vehicles->iIsListed[v] == 1 )
				break;
		}

		if ( v >= SAMP_VEHICLE_MAX )
			v = 0;
	}
}

void cheat_handle_carsfloating ()
{
	traceLastFunc( "cheat_handle_carsfloating()" );

	if( cheat_state->_generic.carsfloating == 1 )
	{
		struct actor_info	*self = actor_info_get( ACTOR_SELF, 0 );

		static int v = 0;

		if ( g_Vehicles->iIsListed[v] != 1 )
			goto find_another_car;

		int car_id = (int)( ((DWORD) g_Vehicles->pGTA_Vehicle[v]) - (DWORD) pool_vehicle->start ) / 2584;
		struct vehicle_info	*vinfo = vehicle_info_get( car_id, 0 );

		int iSAMPVehicleID = getSAMPVehicleIDFromGTAVehicle(vinfo);
		if(iSAMPVehicleID == g_Players->pLocalPlayer->sCurrentVehicleID)
		{
			v++;
			goto find_another_car;
		}

		float fPos[3];
		vect3_copy( &self->base.matrix[4 * 3], fPos );

		// 1st version
		fPos[0] += -15 + rand()%35;
		fPos[1] += -15 + rand()%35;
		fPos[2] += 8.0f;

		float fSpeed[3] = { 0.0f, 0.0f, 1.75f };

		float fQuaternion = -180.0f;

		stInCarData vehSync;
		memset(&vehSync, 0, sizeof(stInCarData));

		vehSync.sVehicleID = iSAMPVehicleID;
		vehSync.fPosition[0] = fPos[0];
		vehSync.fPosition[1] = fPos[1];
		vehSync.fPosition[2] = fPos[2];
		vehSync.fVehicleHealth = vinfo->hitpoints;
		vehSync.fMoveSpeed[0] = fSpeed[0];
		vehSync.fMoveSpeed[1] = fSpeed[1];
		vehSync.fMoveSpeed[2] = fSpeed[2];
		vehSync.sKeys = 0;
		vehSync.bytePlayerHealth = self->hitpoints;
		vehSync.byteArmor = self->armor;

		g_iRakClient->SendFakeDriverFullSyncData(&vehSync, 0);

		cheat_vehicle_teleport( vinfo, fPos, gta_interior_id_get() );

		vinfo->speed[0] = fSpeed[0];
		vinfo->speed[1] = fSpeed[1];
		vinfo->speed[2] = fSpeed[2];

		v++;

find_another_car:
		for ( v; v < SAMP_VEHICLE_MAX; v++ )
		{
			if ( g_Vehicles->iIsListed[v] == 1 )
				break;
		}

		if ( v >= SAMP_VEHICLE_MAX )
			v = 0;
	}
}

void cheat_handle_carsfloating2 ()
{
	traceLastFunc( "cheat_handle_carsfloating2()" );

	if( cheat_state->_generic.carsfloating2 == 1 )
	{
		struct actor_info	*self = actor_info_get( ACTOR_SELF, 0 );

		static int v = 0;

		if ( g_Vehicles->iIsListed[v] != 1 )
			goto find_another_car;

		int car_id = (int)( ((DWORD) g_Vehicles->pGTA_Vehicle[v]) - (DWORD) pool_vehicle->start ) / 2584;
		struct vehicle_info	*vinfo = vehicle_info_get( car_id, 0 );

		int iSAMPVehicleID = getSAMPVehicleIDFromGTAVehicle(vinfo);
		if(iSAMPVehicleID == g_Players->pLocalPlayer->sCurrentVehicleID)
		{
			v++;
			goto find_another_car;
		}

		float fPos[3];
		vect3_copy( &self->base.matrix[4 * 3], fPos );

		// 2nd version
		fPos[0] += -15 + rand()%30;
		fPos[1] += -15 + rand()%30;
		fPos[2] += 20.0f;

		float fSpeed[3] = { 0.0f, 0.0f, 0.3f };

		stInCarData vehSync;
		memset(&vehSync, 0, sizeof(stInCarData));

		vehSync.sVehicleID = iSAMPVehicleID;
		vehSync.fPosition[0] = fPos[0];
		vehSync.fPosition[1] = fPos[1];
		vehSync.fPosition[2] = fPos[2];
		vehSync.fVehicleHealth = vinfo->hitpoints;
		vehSync.fMoveSpeed[0] = fSpeed[0];
		vehSync.fMoveSpeed[1] = fSpeed[1];
		vehSync.fMoveSpeed[2] = fSpeed[2];
		vehSync.sKeys = 0;
		vehSync.bytePlayerHealth = self->hitpoints;
		vehSync.byteArmor = self->armor;

		g_iRakClient->SendFakeDriverFullSyncData(&vehSync, 0);

		cheat_vehicle_teleport( vinfo, fPos, gta_interior_id_get() );

		vinfo->speed[0] = fSpeed[0];
		vinfo->speed[1] = fSpeed[1];
		vinfo->speed[2] = fSpeed[2];

		v++;

find_another_car:
		for ( v; v < SAMP_VEHICLE_MAX; v++ )
		{
			if ( g_Vehicles->iIsListed[v] == 1 )
				break;
		}

		if ( v >= SAMP_VEHICLE_MAX )
			v = 0;
	}
}

void cheat_handle_car_operations()
{
	// InCar
	cheat_handle_itroll_targetfinder();

	// Generic
	cheat_handle_explodecars();
	cheat_handle_removecars();
	cheat_handle_deletecars();
	cheat_handle_hopcars();
	cheat_handle_respawncars();
	cheat_handle_recolorcars();
	cheat_handle_carscrasher();
	cheat_handle_fulcar();
	cheat_handle_carshooter();
	cheat_handle_carsfollows();
	cheat_handle_carsfollows2();
	cheat_handle_carsfloating();
	cheat_handle_carsfloating2();
}