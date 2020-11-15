struct gta_cheat
{
	uint8_t		*addr;
	const char	*name;
};

int		cheat_panic ( void );
void	cheat_prevent_freeze ( void );
void	cheat_teleport ( const float pos[3], int interior_id );
void	cheat_teleport_nearest_car ( void );
void	cheat_handle_misc ( void );
void	cheat_handle_debug ( HWND wnd );
void	cheat_handle_spoof_weapon ( void );
void	cheat_handle_weapon_disable ( void );
void	cheat_handle_freeze_vehicles ( struct vehicle_info *vehicle_info, struct actor_info *actor_info );
void	cheat_handle_unlock ( void );
void	cheat_handle_hp ( struct vehicle_info *vehicle_info, struct actor_info *actor_info, float time_diff );
void	cheat_handle_stick ( struct vehicle_info *vehicle_info, struct actor_info *actor_info, float time_diff );
void	cheat_handle_money ( void );
void	cheat_handle_weapon ( void );
void	cheat_handle_pulse ( void );
void	cheat_handle_teleport ( struct vehicle_info *vehicle_info, struct actor_info *actor_info, float time_diff );
void	cheat_handle_checkpoint ( void );
void	cheat_handle_unfreeze ( struct vehicle_info *vehicle_info, struct actor_info *actor_info, float time_diff );
void	cheat_handle_emo ( struct vehicle_info *vehicle_info, struct actor_info *actor_info, float time_diff );
void	cheat_handle_exit_vehicle ( struct vehicle_info *vehicle_info, struct actor_info *actor_info );
// samp only
void	cheat_handle_antiHijack ( actor_info *ainfo, vehicle_info *veh, float time_diff );
