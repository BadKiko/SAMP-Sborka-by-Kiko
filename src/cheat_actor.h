void				cheat_actor_teleport ( struct actor_info *info, const float pos[3], int interior_id );
void				cheat_handle_actor_air_brake ( struct actor_info *info, double time_diff );
void				cheat_handle_actor_fly ( struct actor_info *ainfo, double time_diff );

void				cheat_handle_maprun(actor_info* self);
void				cheat_handle_fastwalk(actor_info* self);
void				cheat_handle_damage_divider(actor_info* self);

CEntitySAInterface	*cheat_actor_GetCEntitySAInterface ( actor_info *ainfo );
