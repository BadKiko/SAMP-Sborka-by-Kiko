#include "main.h"

HANDLE AP_ThreadHandle;
float AP_posgoto[3];

void AP_Thread()
{
	float dest[3];// = { -1702.1f, 1328.3f, 7.2f };

	dest[0] = AP_posgoto[0];
	dest[1] = AP_posgoto[1];
	dest[2] = AP_posgoto[2];

	const SCRIPT_COMMAND assign_scm_path = { 0x07E7, "iifiii" };
	const SCRIPT_COMMAND set_car_traffic_beh = { 0x00AE, "ii" };
	const SCRIPT_COMMAND set_car_improved_handling = { 0x0423, "if" };
	const SCRIPT_COMMAND car_drive_to = { 0x02C2, "ifff" };
	const SCRIPT_COMMAND plane_drive_to = { 0x04D2, "ifffff" };
	const SCRIPT_COMMAND car_cruise = { 0x00AD, "if" };
	const SCRIPT_COMMAND node_threshold = { 0x0648, "if" };
	const SCRIPT_COMMAND node_nth_get = { 0x04D3, "fffivvv" };
	const SCRIPT_COMMAND car_action = { 0x03A2, "ii" };

	struct actor_info* self = actor_info_get(ACTOR_SELF, 0);
	if (self == NULL) return;
	struct vehicle_info *vself = vehicle_info_get(VEHICLE_SELF, NULL);
	if (vself == NULL) return;

	float dist = vect3_dist(cheat_state->vehicle.coords, dest);

	if (dist>2000.0f)
	{
		cheat_state_text("The destination is too far. Maybe you're in an another island?");
		return;
	}

	cheat_state->_autopilot.driving = true;
	cheat_state->_autopilot.apdriving = false;
	
	float distance = vect3_dist(cheat_state->vehicle.coords, dest);

	while (distance > 15.0f)
	{
		if (vself == NULL) return;

		distance = vect3_dist(cheat_state->vehicle.coords, dest);

		ScriptCommand(&set_car_traffic_beh, ScriptCarId(vself), set.ap_style);
		ScriptCommand(&set_car_improved_handling, ScriptCarId(vself), set.ap_handling);
		ScriptCommand(&car_cruise, ScriptCarId(vself), set.ap_cruise);

		if (!KEY_DOWN(0x57) && !KEY_DOWN(0x41) && !KEY_DOWN(0x53) && !KEY_DOWN(0x44)) // WASD
		{
			if (!cheat_state->_autopilot.apdriving)
			ScriptCommand(&car_drive_to, ScriptCarId(vself), dest[0], dest[1], dest[2]);
			cheat_state->_autopilot.apdriving = true;
		}
		else
		{
			if (cheat_state->_autopilot.apdriving)
			ScriptCommand(&car_action, ScriptCarId(vself), 0);
			cheat_state->_autopilot.apdriving = false;
		}
		
		if (set.ap_stick)
		{
			CVehicle *vehSelf = pPedSelf->GetVehicle();
			if (vehSelf)
			{
				vehSelf->PlaceAutomobileOnRoadProperly();
			}
		}
		Sleep(50);
	}

	cheat_state->_autopilot.driving = false;
	cheat_state->_autopilot.apdriving = false;
	
	ScriptCommand(&car_action, ScriptCarId(vself), 0);

	cheat_state->_autopilot.apdriving = false;
	cheat_state->_autopilot.driving = false;
}

void TW_CALL SetCallback_AP(const void *value, void *clientData)
{
	bool act = *(const bool *)value;  // for instance
	if (AP_ThreadHandle==NULL)
	{
		AP_ThreadHandle = CreateThread(0, 0, (LPTHREAD_START_ROUTINE)AP_Thread, 0, 0, 0);
	}
	else
	{
		const SCRIPT_COMMAND car_action = { 0x03A2, "ii" };
		struct vehicle_info *vself = vehicle_info_get(VEHICLE_SELF, NULL);
		if (vself == NULL) return;
		ScriptCommand(&car_action, ScriptCarId(vself), 0);
		TerminateThread(AP_ThreadHandle, 0);
		AP_ThreadHandle = NULL;
		cheat_state->_autopilot.apdriving = false;
		cheat_state->_autopilot.driving = false;
	}
}

void TW_CALL GetCallback_AP(void *value, void *clientData)
{
	*(bool *)value = cheat_state->_autopilot.driving;  // for instance
}

void TW_CALL SetDestination_AP(void *clientData)
{
	struct settings_coord *menuinfo = (struct settings_coord *)clientData;
	if (menuinfo == NULL) return;

	AP_posgoto[0] = menuinfo->pos[0];
	AP_posgoto[1] = menuinfo->pos[1];
	AP_posgoto[2] = menuinfo->pos[2];

	SetCallback_AP(NULL, NULL);
}