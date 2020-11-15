#include "main.h"

bool isOldAimKeyDown = false;
int aimidf = 9999;

float getRandomFloat()
{
	return static_cast <float> (rand()) / static_cast <float> (RAND_MAX);
}

#define CAMERA_X	*(float *)0xB6F258

void skin_aimbot(struct actor_info *self, struct actor_info *target)
{
	float mult1 = 35.0f;
	float mult2 = 17.0f;
	mult2 /= 360.0f;
	CVector vecSpeed = target->m_SpeedVec;
	vecSpeed.fX *= mult2;
	vecSpeed.fY *= mult2;
	vecSpeed.fZ *= mult2;
	vecSpeed.fX *= mult1;
	vecSpeed.fY *= mult1;
	vecSpeed.fZ *= mult1;
	CVector vecPos(target->base.matrix[12], target->base.matrix[13], target->base.matrix[14]);
	vecPos.fX += vecSpeed.fX;
	vecPos.fY += vecSpeed.fY;
	vecPos.fZ += vecSpeed.fZ;
	CVector newVecPos = vecPos;
	CVector vecCameraPos = *pGame->GetCamera()->GetCam(pGame->GetCamera()->GetActiveCam())->GetSource();
	CVector newVecOrigin = *pPedSelf->GetPosition();
	vecCameraPos.fX -= newVecPos.fX;
	vecCameraPos.fY -= newVecPos.fY;
	if (vecCameraPos.fX < 0.0f) vecCameraPos.fX = -vecCameraPos.fX;
	if (vecCameraPos.fY < 0.0f) vecCameraPos.fY = -vecCameraPos.fY;
	float camerax = vecCameraPos.fX;
	float cameray = vecCameraPos.fY;
	camerax *= camerax;
	cameray *= cameray;
	camerax += cameray;
	camerax = sqrt(camerax);
	cameray = vecCameraPos.fX;
	float ccamx = camerax;
	cameray /= ccamx;
	ccamx = asinf(cameray);
	float ccamy = acosf(cameray);
	if (self->weapon_slot != 2 && self->weapon_slot != 3 && self->weapon_slot != 4 && self->weapon_slot != 5
		&& self->weapon_slot != 6 && self->weapon_slot != 7)
		return;
	float cam_x;
	float unk7[4];
	if (self->weapon_slot == 5)
	{
		unk7[0] = 0.01f;
		unk7[1] = 0.01f;
		unk7[2] = 1.5607f;
		unk7[3] = 1.5807f;
	}
	else if (self->weapon_slot == 6)
	{
		unk7[0] = 0.018f;
		unk7[1] = 0.02f;
		unk7[2] = 1.5507f;
		unk7[3] = 1.5907f;
	}
	else
	{
		unk7[0] = 0.0f;
		unk7[1] = 0.0f;
		unk7[2] = 1.5707f;
		unk7[3] = 1.5707f;
	}
	if (newVecOrigin.fX > newVecPos.fX && newVecOrigin.fY > newVecPos.fY)
	{
		ccamy -= unk7[1];
		cam_x = ccamy;
	}
	else if (newVecOrigin.fX > newVecPos.fX && newVecOrigin.fY < newVecPos.fY)
	{
		ccamy *= -1.0f;
		ccamy -= unk7[0];
		cam_x = ccamy;
	}
	else if (newVecOrigin.fX < newVecPos.fX && newVecOrigin.fY > newVecPos.fY)
	{
		ccamx += unk7[2];
		cam_x = ccamx;
	}
	else if (newVecOrigin.fX < newVecPos.fX && newVecOrigin.fY < newVecPos.fY)
	{
		ccamx *= -1.0f;
		ccamx -= unk7[3];
		cam_x = ccamx;
	}
	//else
	//{
		float cam_xx = CAMERA_X;
		cam_xx -= cam_x;
		if (cam_xx < 0.18f && cam_xx > -0.18f)
		{
			cam_x += 0.0389f;
			CAMERA_X = cam_x;
		}
		else
			return;
	//}
}


void car_aimbot(struct actor_info *self, struct vehicle_info *target)
{
	float mult1 = 35.0f;
	float mult2 = 17.0f;
	mult2 /= 360.0f;
	CVector vecSpeed = target->m_SpeedVec;
	vecSpeed.fX *= mult2;
	vecSpeed.fY *= mult2;
	vecSpeed.fZ *= mult2;
	vecSpeed.fX *= mult1;
	vecSpeed.fY *= mult1;
	vecSpeed.fZ *= mult1;
	CVector vecPos(target->base.matrix[12], target->base.matrix[13], target->base.matrix[14]);
	vecPos.fX += vecSpeed.fX;
	vecPos.fY += vecSpeed.fY;
	vecPos.fZ += vecSpeed.fZ;
	CVector newVecPos = vecPos;
	CVector vecCameraPos = *pGame->GetCamera()->GetCam(pGame->GetCamera()->GetActiveCam())->GetSource();
	CVector newVecOrigin = *pPedSelf->GetPosition();
	vecCameraPos.fX -= newVecPos.fX;
	vecCameraPos.fY -= newVecPos.fY;
	if (vecCameraPos.fX < 0.0f) vecCameraPos.fX = -vecCameraPos.fX;
	if (vecCameraPos.fY < 0.0f) vecCameraPos.fY = -vecCameraPos.fY;
	float camerax = vecCameraPos.fX;
	float cameray = vecCameraPos.fY;
	camerax *= camerax;
	cameray *= cameray;
	camerax += cameray;
	camerax = sqrt(camerax);
	cameray = vecCameraPos.fX;
	float ccamx = camerax;
	cameray /= ccamx;
	ccamx = asinf(cameray);
	float ccamy = acosf(cameray);
	if (self->weapon_slot != 2 && self->weapon_slot != 3 && self->weapon_slot != 4 && self->weapon_slot != 5
		&& self->weapon_slot != 6 && self->weapon_slot != 7)
		return;
	float cam_x;
	float unk7[4];
	if (self->weapon_slot == 5)
	{
		unk7[0] = 0.01f;
		unk7[1] = 0.01f;
		unk7[2] = 1.5607f;
		unk7[3] = 1.5807f;
	}
	else if (self->weapon_slot == 6)
	{
		unk7[0] = 0.018f;
		unk7[1] = 0.02f;
		unk7[2] = 1.5507f;
		unk7[3] = 1.5907f;
	}
	else
	{
		unk7[0] = 0.0f;
		unk7[1] = 0.0f;
		unk7[2] = 1.5707f;
		unk7[3] = 1.5707f;
	}
	if (newVecOrigin.fX > newVecPos.fX && newVecOrigin.fY > newVecPos.fY)
	{
		ccamy -= unk7[1];
		cam_x = ccamy;
	}
	else if (newVecOrigin.fX > newVecPos.fX && newVecOrigin.fY < newVecPos.fY)
	{
		ccamy *= -1.0f;
		ccamy -= unk7[0];
		cam_x = ccamy;
	}
	else if (newVecOrigin.fX < newVecPos.fX && newVecOrigin.fY > newVecPos.fY)
	{
		ccamx += unk7[2];
		cam_x = ccamx;
	}
	else if (newVecOrigin.fX < newVecPos.fX && newVecOrigin.fY < newVecPos.fY)
	{
		ccamx *= -1.0f;
		ccamx -= unk7[3];
		cam_x = ccamx;
	}
	//else
	//{
	float cam_xx = CAMERA_X;
	cam_xx -= cam_x;
	if (cam_xx < 0.18f && cam_xx > -0.18f)
	{
		cam_x += 0.0389f;
		CAMERA_X = cam_x;
	}
	else
		return;
	//}
}

void cheat_handle_aim(actor_info* info)
{
	if (!cheat_state->_aimbot.AimbotToggle)
		return;

	if (g_Players!=NULL)
	{
		//GET CHAIR POSITION

		float silentAimMargins[2];
		if (info->weapon_model != 358) {
			silentAimMargins[0] = pPresentParam.BackBufferWidth * 0.5299999714f;
			silentAimMargins[1] = pPresentParam.BackBufferHeight * 0.4f;
		}
		else {
			silentAimMargins[0] = pPresentParam.BackBufferWidth * 0.5f;
			silentAimMargins[1] = pPresentParam.BackBufferHeight * 0.5f;
		}

		//DRAW THE EXECUTION FRAME IF AIMBOT IS TOGGLED ON
		/*if (cheat_state->_aimbot.AimbotToggle) {
			render->D3DBoxBorder(
				silentAimMargins[0] - (pPresentParam.BackBufferWidth * cheat_state->_aimbot.silentFrameX),
				silentAimMargins[1] - (pPresentParam.BackBufferHeight * cheat_state->_aimbot.silentFrameY),
				(pPresentParam.BackBufferWidth * (cheat_state->_aimbot.silentFrameX * 2)), (pPresentParam.BackBufferHeight * (cheat_state->_aimbot.silentFrameY * 2)),
				D3DCOLOR_ARGB(255, 255, 255, 255), D3DCOLOR_ARGB(0, 0, 0, 0));
		}*/
		
		//THIS GET INFO FOR GREEN TRIANGLE WHILE AIMING
		uint8_t	*ptr = (uint8_t *)g_Players->pLocalPlayer - 320;
		uint16_t thedata[5];
		memcpy_safe(&thedata, ptr + 0x2b9, 4);

		if (thedata[0] == 0xffff)
		{
			//cheat_state->playerAimed = -1;
		}
		else {
			cheat_state->_aimbot.playerAimed = thedata[0];
		}


		//IS SHOOTING?
		bool						isAimKeyDown = false;
		bool						isAim2KeyDown = false;
		CControllerConfigManager	*pPadConfig = pGameInterface->GetControllerConfigManager();

		// doesnt seem to work in single player with pPadConfig and keyboard input?
		if (pPadConfig->GetInputType())
		{
			// mouse + keyboard
			if (KEY_DOWN(pPadConfig->GetControllerKeyAssociatedWithAction(FIRE, MOUSE)))
				isAimKeyDown = true;

			else if (KEY_DOWN(pPadConfig->GetControllerKeyAssociatedWithAction(FIRE, KEYBOARD)))
				isAimKeyDown = true;
		}
		else
		{
			// gamepad
			if (KEY_DOWN(pPadConfig->GetControllerKeyAssociatedWithAction(FIRE, JOYSTICK)))
				isAimKeyDown = true;
		}


		//IS AIMING?
			if (KEY_DOWN(0x02))
			{
				isAim2KeyDown = true;
				cheat_state->_aimbot.playerAiming = true;
			}
			else
			{
				isAim2KeyDown = false;
				cheat_state->_aimbot.playerAiming = false;
			}

			//IF AIMING, GET TARGETS IN CHAIR
			if (isAim2KeyDown)
			{
				CVehicle *pCVehicleTeleport = NULL;
				CPed     *pCPedTeleport = NULL;
				D3DXVECTOR3 poss, screenposs;
				
				//pPresentParam X = screenWidth * 0.5299999714f; Y = screenHeight * 0.4f

				if (info->weapon_model != 358)
				{
					screenposs.x = pPresentParam.BackBufferWidth * 0.5299999714f;
					screenposs.y = pPresentParam.BackBufferHeight * 0.4f;
				}
				else
				{
					screenposs.x = pPresentParam.BackBufferWidth * 0.5f;
					screenposs.y = pPresentParam.BackBufferHeight * 0.5f;
				}

				screenposs.z = 700.0f;

				CalcWorldCoors(&screenposs, &poss);

				CVector vecTarget(poss.x, poss.y, poss.z);

				// setup variables
				CVector				vecOrigin, vecGroundPos;
				CColPoint			*pCollision = NULL;
				CEntitySAInterface	*pCollisionEntity = NULL;

				// origin = our camera
				vecOrigin = *pGame->GetCamera()->GetCam(pGame->GetCamera()->GetActiveCam())->GetSource();

				// check for collision
				bool bCollision = GTAfunc_ProcessLineOfSight(&vecOrigin, &vecTarget, &pCollision, &pCollisionEntity,
					1, 1, 1, 1, 0, 0, 0, 0);

				if (bCollision && pCollision)
				{
					//IS CAR???
					if (pCollisionEntity && pCollisionEntity->nType == ENTITY_TYPE_VEHICLE)
					{
						pCVehicleTeleport = pGameInterface->GetPools()->GetVehicle((DWORD *)pCollisionEntity);
						if (pCVehicleTeleport)
						{
							//vecGroundPos = *pCVehicleTeleport->GetPosition();
							const struct vehicle_entry *vehicleEntry = gta_vehicle_get_by_id(pCVehicleTeleport->GetModelIndex());
							if (vehicleEntry != NULL)
							{
								
								int iVehicleID = getVehicleGTAIDFromInterface((DWORD*)pCVehicleTeleport->GetInterface());
								struct vehicle_info * vinfo = vehicle_info_get(iVehicleID, 0);
								struct actor_info * tinfo = vinfo->passengers[0];
								if (tinfo != NULL) {
									aimidf = getSAMPPlayerIDFromGTAPed(tinfo);
									cheat_state->_aimbot.RealAIMID = aimidf;
									cheat_state->_aimbot.TypeAIMID = 1;
								}
								else {
									//I PREFER AIM ONLY PEDS AND DRIVERS, UNCOMMENT FOR EMPTY VEHICLES OR CHANGE LOGIC
									//cheat_state_text("collision %d", translateGTASAMP_pedPool.iSAMPID[iActorID]);
									/*aimidf = translateGTASAMP_vehiclePool.iSAMPID[iVehicleID];
									cheat_state->RealAIMID = aimidf;
									cheat_state->TypeAIMID = 2;*/
									//fix not empty cars
								}

								
							}
						}
					}

					//IS ACTOR????
					else if (pCollisionEntity && pCollisionEntity->nType == ENTITY_TYPE_PED)
					{
						pCPedTeleport = pGameInterface->GetPools()->GetPed((DWORD *)pCollisionEntity);
						if (pCPedTeleport)
						{
							//vecGroundPos = *pCPedTeleport->GetPosition();
							int iActorID = getPedGTAIDFromInterface((DWORD*)pCPedTeleport->GetInterface());

							if (iActorID != NULL)
							{
								//sprintf(buf, "Aim-menu (%d)", translateGTASAMP_pedPool.iSAMPID[iActorID]);
								aimidf = translateGTASAMP_pedPool.iSAMPID[iActorID];
								cheat_state->_aimbot.RealAIMID = aimidf;
								cheat_state->_aimbot.TypeAIMID = 1;
							}
						}
					}

				}
				
				//KTXBYE
				pCollision->Destroy();
				
				//DRAW EXECUTION BOX WHILE AIMING
				if (cheat_state->_aimbot.TypeAIMID == 1)
				{
					D3DXVECTOR3 poss, screenposs;

					struct actor_info	*nearest;
					if ((nearest = getGTAPedFromSAMPPlayerID(cheat_state->_aimbot.RealAIMID)) != NULL)
					{

						poss.x = nearest->base.matrix[(3 * 4) * 1];
						poss.y = nearest->base.matrix[(3 * 4) + 1];
						poss.z = nearest->base.matrix[(3 * 4) + 2];
						CalcScreenCoors(&poss, &screenposs);
						//IS PLAYER IN THE FRAME?
						if ((screenposs.x  < silentAimMargins[0] + (pPresentParam.BackBufferWidth * cheat_state->_aimbot.silentFrameX)
						  && screenposs.x  > silentAimMargins[0] - (pPresentParam.BackBufferWidth * cheat_state->_aimbot.silentFrameX))
								  &&
							(screenposs.y /*+ 15.0f*/ < silentAimMargins[1] + (pPresentParam.BackBufferHeight * cheat_state->_aimbot.silentFrameY)
						  && screenposs.y /*+ 15.0f*/ > silentAimMargins[1] - (pPresentParam.BackBufferHeight * cheat_state->_aimbot.silentFrameY)))
						{
							cheat_state->_aimbot.silentAIMsafe = true;
							//YEA
							if (cheat_state->_aimbot.silentFrame)
							render->D3DBoxBorder(
								silentAimMargins[0] - (pPresentParam.BackBufferWidth * cheat_state->_aimbot.silentFrameX),
								silentAimMargins[1] - (pPresentParam.BackBufferHeight * cheat_state->_aimbot.silentFrameY),
								(pPresentParam.BackBufferWidth * (cheat_state->_aimbot.silentFrameX * 2)), (pPresentParam.BackBufferHeight * (cheat_state->_aimbot.silentFrameY * 2)),
								D3DCOLOR_ARGB(255, 255, 255, 255), D3DCOLOR_ARGB(0, 0, 0, 0));
						}

					
						else 
						{
							cheat_state->_aimbot.silentAIMsafe = false;
							//NOPE
							if (cheat_state->_aimbot.silentFrame)
							render->D3DBoxBorder(
								silentAimMargins[0] - (pPresentParam.BackBufferWidth * cheat_state->_aimbot.silentFrameX),
								silentAimMargins[1] - (pPresentParam.BackBufferHeight * cheat_state->_aimbot.silentFrameY),
								(pPresentParam.BackBufferWidth * (cheat_state->_aimbot.silentFrameX * 2)), (pPresentParam.BackBufferHeight * (cheat_state->_aimbot.silentFrameY * 2)),
								D3DCOLOR_ARGB(255, 255, 0, 0), D3DCOLOR_ARGB(0, 0, 0, 0));
						}
					}
				}

				//cheat_state_text("playerzone %d    %0.2f  %0.2f       %0.2f  %0.2f  ", cheat_state->RealAIMID, g_playerTagInfo[cheat_state->RealAIMID].tagPosition.fX, g_playerTagInfo[cheat_state->RealAIMID].tagPosition.fY + 35.0f, silentAimMargins[0], silentAimMargins[1]);
				//LETS HANDLE AIMBOTZ
				if (info->weapon_model != 358) {
					//SKIN AIMBOT
					if (cheat_state->_aimbot.TypeAIMID == 1 && cheat_state->_aimbot.skinAimbot) {
						struct actor_info	*nearest;
						if ((nearest = getGTAPedFromSAMPPlayerID(cheat_state->_aimbot.RealAIMID)) != NULL)
							skin_aimbot(info, nearest);
					}
					//CAR AIMBOT
					if (cheat_state->_aimbot.TypeAIMID == 2 && cheat_state->_aimbot.carAimbot) {
						struct vehicle_info	*nearest;
						if ((nearest = getGTAVehicleFromSAMPVehicleID(cheat_state->_aimbot.RealAIMID)) != NULL)
							car_aimbot(info, nearest);
					}

				}
				else {

					//SNIPER SKIN AIMBOT
					if (cheat_state->_aimbot.TypeAIMID == 1 && cheat_state->_aimbot.sniperAimbot) {
						static float		adj_rx, adj_rz, prev_rx, prev_rz;
						float				rx = *(float *)0x00B6F248;
						float				rz = *(float *)0x00B6F258;
						static int prev_id;
						float				vect[3], ax, az;
						struct actor_info	*nearest;

						if ((nearest = getGTAPedFromSAMPPlayerID(cheat_state->_aimbot.RealAIMID)) == NULL)
							return; // won't happen

						// calculate distance vector

						float nearestmatrix[3];
						nearestmatrix[0] = nearest->base.matrix[1 * (4 * 3)];
						nearestmatrix[1] = nearest->base.matrix[1 + (4 * 3)];
						nearestmatrix[2] = nearest->base.matrix[2 + (4 * 3)];

						float mymatrix[3];

						mymatrix[0] = vecOrigin.fX;
						mymatrix[1] = vecOrigin.fY;
						mymatrix[2] = vecOrigin.fZ;

						vect3_vect3_sub(nearestmatrix, &info->base.matrix[4 * 3], vect);

						// z angle
						az = atan2f(vect[0], vect[1]);

						// rotate around z axis
						vect[1] = sinf(az) * vect[0] + cosf(az) * vect[1];

						// x angle
						ax = atan2f(vect[1], vect[2]);

						ax = -ax + M_PI / 2.0f;// +adj_rx;
						az = -az - M_PI / 2.0f;// +adj_rz;

						ax = ax - 0.002f;
						//az = az + 0.022f;

						if (ax < -M_PI)
							ax = -M_PI;
						else if (ax > M_PI)
							ax = M_PI;

						*(float *)0x00B6F248 = ax;// -0.150f;
						*(float *)0x00B6F258 = az;// +0.038f;

					}

					//SNIPPER CAR AIMBOT
					if (cheat_state->_aimbot.TypeAIMID == 2 && cheat_state->_aimbot.sniperAimbot)
					{
						static float		adj_rx, adj_rz, prev_rx, prev_rz;
						float				rx = *(float *)0x00B6F248;
						float				rz = *(float *)0x00B6F258;
						static int prev_id;
						float				vect[3], ax, az;
						struct vehicle_info	*nearest;
						//b6f258

						//pGameInterface->GetCamera()->Find3rdPersonCamTargetVector()
						if ((nearest = getGTAVehicleFromSAMPVehicleID(cheat_state->_aimbot.RealAIMID)) == NULL)
							return; // won't happen

						// calculate distance vector

						float nearestmatrix[3];
						nearestmatrix[0] = nearest->base.matrix[1 * (4 * 3)];
						nearestmatrix[1] = nearest->base.matrix[1 + (4 * 3)];
						nearestmatrix[2] = nearest->base.matrix[2 + (4 * 3)];


						float mymatrix[3];

						mymatrix[0] = vecOrigin.fX;
						mymatrix[1] = vecOrigin.fY;
						mymatrix[2] = vecOrigin.fZ;

						vect3_vect3_sub(nearestmatrix, mymatrix, vect);


						// z angle
						az = atan2f(vect[0], vect[1]);

						// rotate around z axis
						vect[1] = sinf(az) * vect[0] + cosf(az) * vect[1];

						// x angle
						ax = atan2f(vect[1], vect[2]);

						ax = -ax + M_PI / 2.0f;// +adj_rx;
						az = -az - M_PI / 2.0f;// +adj_rz;
						//cheat_state_text("aimm %0.2f %0.2f", ax, az);

						//ax = ax - 0.078f;
						//az = az + 0.048f;

						if (ax < -M_PI)
							ax = -M_PI;
						else if (ax > M_PI)
							ax = M_PI;

						// XXX make function
						*(float *)0x00B6F248 = ax;
						*(float *)0x00B6F258 = az;
					}
				}
			}
			
			//vecGroundPos = *pCollision->GetPosition();
			//cheat_state_text("collision ID(%d)         %0.2f    %0.2f     Distance(%0.2f)", aimidf, (float)poss.x, (float)poss.y, vect3_dist(&vecOrigin.fX, &vecGroundPos.fX));

			CVector lol;
			lol.fX = 0;
			lol.fY = 0;
			lol.fZ = 0;

			//save current aim status SHITY DATA NOT NECXCESARY BUT OK
			float posss[3];
			if (cheat_state->_aimbot.TypeAIMID == 1) {
				if (getPlayerPos(cheat_state->_aimbot.RealAIMID, posss)) {
					cheat_state->_aimbot.CurrentAIMstreamed = true;
					cheat_state->_aimbot.CurrentAIMstreamed = 1;
					cheat_state->_aimbot.DistanceAIM = vect3_dist(cheat_state->actor.coords, posss);

					lol.fX = posss[0];
					lol.fY = posss[1];
					lol.fZ = posss[2];
					//cheat_state_text("collision ID(%d)         %0.2f    %0.2f     Distance(%0.2f) Distance(%0.2f)", aimidf, (float)poss.x, (float)poss.y, vect3_dist(&vecOrigin.fX, &vecGroundPos.fX), cheat_state->DistanceAIM);
				}
				else {
					cheat_state->_aimbot.CurrentAIMstreamed = false;
					cheat_state->_aimbot.DistanceAIM = 0.0f;
				}
			}

			if (cheat_state->_aimbot.TypeAIMID == 2) {
				if (g_Vehicles->pSAMP_Vehicle[cheat_state->_aimbot.RealAIMID] != NULL) {
					cheat_state->_aimbot.CurrentAIMstreamed = true;
					cheat_state->_aimbot.DistanceAIM = vect3_dist(cheat_state->actor.coords, &g_Vehicles->pSAMP_Vehicle[cheat_state->_aimbot.RealAIMID]->pGTA_Vehicle->base.matrix[4 * 3]);
					lol.fX = g_Vehicles->pSAMP_Vehicle[cheat_state->_aimbot.RealAIMID]->pGTA_Vehicle->base.matrix[4 * 3];
					lol.fY = g_Vehicles->pSAMP_Vehicle[cheat_state->_aimbot.RealAIMID]->pGTA_Vehicle->base.matrix[13];
					lol.fZ = g_Vehicles->pSAMP_Vehicle[cheat_state->_aimbot.RealAIMID]->pGTA_Vehicle->base.matrix[14];
				}
				else {
					cheat_state->_aimbot.CurrentAIMstreamed = false;
					cheat_state->_aimbot.DistanceAIM = 0.0f;
				}
			}


		isOldAimKeyDown = isAimKeyDown;

		//DRAW TAG ON PLYER
		if (cheat_state->_aimbot.TypeAIMID==1)
		{
			D3DXVECTOR3 poss, screenposs;

			struct actor_info	*nearest;
			if ((nearest = getGTAPedFromSAMPPlayerID(cheat_state->_aimbot.RealAIMID)) != NULL)
			{
				poss.x = nearest->base.matrix[(3 * 4) * 1];
				poss.y = nearest->base.matrix[(3 * 4) + 1];
				poss.z = nearest->base.matrix[(3 * 4) + 2];

				CalcScreenCoors(&poss, &screenposs);

				//IS PLAYER ON SCREEN?
				if ((screenposs.x  < (pPresentParam.BackBufferWidth)
					&& screenposs.x  > 0)
					&&
					(screenposs.y < (pPresentParam.BackBufferHeight)
					&& screenposs.y > 0)
					&& screenposs.z>0.0f)
				{
					char AIMText[] = "AIM";
		
					float w = pD3DFontFixedSmall->DrawLength(AIMText);
					float h = pD3DFontFixedSmall->DrawHeight() + 1;
					render->D3DBox(screenposs.x - 20.0f + 1.0f, screenposs.y - 1.5f, pD3DFont_sampStuff->DrawLength(AIMText) + 1.2f, 10.0f, D3DCOLOR_ARGB(255, 0, 0, 0));
					pD3DFontFixedSmall->PrintShadow(screenposs.x - 17.0f + 1.0f, screenposs.y - h + 8.5f, D3DCOLOR_ARGB(130, 170, 170, 0), AIMText);
				}
			}
		}
	}
}

void cheat_handle_silent_aim(stBulletData *bSync)
{
	struct actor_info	*nearest;
	
	if ((nearest = getGTAPedFromSAMPPlayerID(cheat_state->_aimbot.RealAIMID)) == NULL)
		return;

	if (bSync->bHitType == 0 || bSync->bHitType == 3 || bSync->bHitType == 4)
	{
		if (cheat_state->_aimbot.TypeAIMID == 1)
		{
			bSync->bHitType = 1;
			bSync->iHitID = cheat_state->_aimbot.RealAIMID;
			
			bSync->fHitTarget[0] = nearest->step_pos[0];
			bSync->fHitTarget[1] = nearest->step_pos[1];
			bSync->fHitTarget[2] = nearest->step_pos[2];
		}
		else
		{
			struct vehicle_info	*nearest;

			if ((nearest = getGTAVehicleFromSAMPVehicleID(cheat_state->_aimbot.RealAIMID)) == NULL)
				return;

			bSync->bHitType = 2;
			bSync->iHitID = cheat_state->_aimbot.RealAIMID;

			bSync->fHitTarget[0] = nearest->base.matrix[(4 * 3)*1];
			bSync->fHitTarget[1] = nearest->base.matrix[(4 * 3)+1];
			bSync->fHitTarget[2] = nearest->base.matrix[(4 * 3)+2];
		}

		bSync->fCenterOfHit[0] = -0.01f;
		bSync->fCenterOfHit[1] = -0.02f;
		bSync->fCenterOfHit[2] = 0.04f;
	}
}