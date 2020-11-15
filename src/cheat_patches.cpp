#include "main.h"

// these get installed before most functions within the process get called
void cheat_patches_installRuntimePatches(void)
{
	patcher_install(&patch_EnableResolutions);
	//patcher_install(&patch_DisableLoadingScreen); // 0x_: Theres no need for that, it's a also a type of "detecting" you as user of s0beit.
}
