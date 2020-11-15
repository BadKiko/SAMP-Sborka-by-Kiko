#pragma once

#define MAX_SCRIPT_VARS 16              // Size of our variable saving array
#define MAX_SCRIPT_SIZE 255             // Size of ScriptBuf - Max is really (2+(13*5))

struct GAME_SCRIPT_THREAD               // 0xE0 bytes total.
{
	BYTE    Pad1[0x14];                     // 0x00 [0x14]
	DWORD   dwScriptIP;                     // 0x14 [0x04]
	BYTE    Pad2[0x24];                     // 0x18 [0x24]
	DWORD   dwLocalVar[18];         // 0x3C [0x48]
	BYTE    Pad3[0x41];                     // 0x84 [0x41]
	DWORD   dwIfFlag;                       // 0xC5 [0x04]
	BYTE    Pad4[0xF];                      // 0xC9 [0x0F]
	DWORD   dwIndexSomething;       // 0xD8 [0x04]  (indexes into 0xA49960)
	BYTE    bHasLocalCopy;          // 0xDC [0x01]  (has local copy of something, if 1, then uses .data:00A48960 CTheScripts_LocalCopy instead of var0)
	BYTE    Pad5[0x3];                      // 0xDD [0x03]
};

struct SCRIPT_COMMAND                   //      Params
{       //              i = integer
	WORD    OpCode; //              f = float
	char    Params[MAX_SCRIPT_VARS];        //      v = variable
};      //              s = string
void                                    InitScripting();
int                                             ScriptCommand(const SCRIPT_COMMAND *pScriptCommand, ...);

const SCRIPT_COMMAND    toggle_player_controllable = { 0x01B4, "ii" };
const SCRIPT_COMMAND    lock_actor = { 0x04D7, "ii" };
const SCRIPT_COMMAND    put_actor_in_car = { 0x036A, "ii" };
const SCRIPT_COMMAND    put_actor_in_car_passenger = { 0x0430, "iii" };
const SCRIPT_COMMAND    restore_camera_with_jumpcut = { 0x02EB, "" };
const SCRIPT_COMMAND    set_camera_directly_behind = { 0x0373, "" };
const SCRIPT_COMMAND    remove_actor_from_car_and_put_at = { 0x0362, "ifff" };
const SCRIPT_COMMAND    apply_momentum_in_direction_XYZ = { 0x07D5, "iffffff" };
const SCRIPT_COMMAND    apply_rotory_pulse_about_an_axis_XYZ = { 0x07DA, "ifff" };
const SCRIPT_COMMAND    repair_car = { 0x0A30, "i" };
const SCRIPT_COMMAND    get_actor_car = { 0x03C0, "iv" };
const SCRIPT_COMMAND    camera_on_actor = { 0x0159, "iii" };
const SCRIPT_COMMAND    camera_on_vehicle = { 0x0158, "iii" };
const SCRIPT_COMMAND    put_trailer_on_cab = { 0x0893, "ii" };
const SCRIPT_COMMAND    enter_car_as_driver = { 0x05CB, "iii" };
const SCRIPT_COMMAND    set_car_lights = { 0x067F, "ii" };

const SCRIPT_COMMAND player_perform_animation_at_x_times_normal_rate = { 0x0393, "isf" }; //0393=3,actor %1d% perform_animation %2h% at %3d% times_normal_rate
const SCRIPT_COMMAND play_sound = { 0x018C , "fffi" };