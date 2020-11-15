#include "main.h"

static WNDPROC		orig_wndproc;
static HWND			orig_wnd;

struct key_state	key_table[256];
int					keys_cleared;
int					key_being_pressed;

static void process_key ( int down, int vkey, int repeat, int scancode, int extended, HWND wnd )
{
	if ( down && KEY_DOWN(vkey) )
		return; /* ignore key repeat, bad states */
	if ( !down && KEY_UP(vkey) )
		return; /* ignore bad states */

	if ( g_Input != NULL && g_Input->iInputEnabled
		|| GetForegroundWindow() != wnd
		//|| 0x90 == *(uint8_t *)0x541DF5
		)
	{
		if ( !down && KEY_DOWN(vkey) )
			key_table[vkey].count++;
		return;
	}

	key_table[vkey].count++;
}

static LRESULT CALLBACK wnd_proc ( HWND wnd, UINT umsg, WPARAM wparam, LPARAM lparam )
{
	if (gta_menu_active())
		goto wnd_proc_original;

	if ( cheat_state->_generic.new_menu && set.ant_tweak_menu && iIsSAMPSupported )
	{
		if ( !gta_menu_active() )
		{
			if ( TwEventWin(wnd, umsg, wparam, lparam) )
				return 0;
		}
	}

	if ( g_pCheatConsole )
	{
		if ( !gta_menu_active() )
		{
			if ( g_pCheatConsole->IsEnabled() )
			{
				if ( umsg == WM_KEYUP && wparam == VK_ESCAPE )
				{
					g_pCheatConsole->ToggleConsole();
					return 0;
				}

				if ( umsg == WM_CHAR )
				{
					g_pCheatConsole->HandleInput(wparam);
					return 0;
				}

				if ( umsg == WM_CHAR || umsg == WM_SYSCHAR || umsg == WM_KEYDOWN || umsg == WM_SYSKEYDOWN )
					return 0;
			}
			else
			{
				if ( g_Input != NULL )
				{
					if ( !g_Input->iInputEnabled && umsg == WM_KEYUP && wparam == set.key_console )
					{
						g_pCheatConsole->ToggleConsole();
						return 0;
					}
				}
			}
		}
	}

	switch ( umsg )
	{
	case WM_LBUTTONDOWN:
	case WM_LBUTTONUP:
		process_key( (umsg == WM_LBUTTONDOWN), VK_LBUTTON, 0, 0, 0, wnd );
		break;

	case WM_RBUTTONDOWN:
	case WM_RBUTTONUP:
		process_key( (umsg == WM_RBUTTONDOWN), VK_RBUTTON, 0, 0, 0, wnd );
		break;

	case WM_MBUTTONDOWN:
	case WM_MBUTTONUP:
		process_key( (umsg == WM_MBUTTONDOWN), VK_MBUTTON, 0, 0, 0, wnd );
		break;

	/* :D */
	case WM_SYSKEYDOWN:
	case WM_SYSKEYUP:
	case WM_KEYDOWN:
	case WM_KEYUP:
		{
			unsigned long	p = (unsigned long)lparam;
			int				down = ( umsg == WM_KEYDOWN || umsg == WM_SYSKEYDOWN );
			int				vkey = (int)wparam;
			key_being_pressed = vkey;

			unsigned int	repeat = ( p >> 0 ) & 0x7FFF;
			unsigned int	scancode = ( p >> 16 ) & 0x00FF;
			unsigned int	extended = ( p >> 24 ) & 0x0001;

			if ( cheat_state == NULL )
				break;

			/* :D :D :D :D :D */
			switch ( vkey )
			{
			case VK_SHIFT:
				if ( scancode == MapVirtualKey(VK_LSHIFT, 0) )
					vkey = VK_LSHIFT;
				else if ( scancode == MapVirtualKey(VK_RSHIFT, 0) )
					vkey = VK_RSHIFT;
				break;

			case VK_CONTROL:
				if ( scancode == MapVirtualKey(VK_LCONTROL, 0) )
					vkey = VK_LCONTROL;
				else if ( scancode == MapVirtualKey(VK_RCONTROL, 0) )
					vkey = VK_RCONTROL;
				break;

			case VK_MENU:
				if ( scancode == MapVirtualKey(VK_LMENU, 0) )
					vkey = VK_LMENU;
				else if ( scancode == MapVirtualKey(VK_RMENU, 0) )
					vkey = VK_RMENU;
				break;
			}

			/* :D */
			if ( KEY_DOWN(VK_LMENU) && vkey == VK_LMENU && down )
				break;
			if ( KEY_UP(VK_LMENU) && vkey == VK_LMENU && !down )
				break;

			process_key( down, vkey, repeat, scancode, extended, wnd );

			/* XXX move this */
			if ( cheat_state->debug_enabled
			 &&	 (
					 (vkey >= VK_NUMPAD1 && vkey <= VK_NUMPAD9)
			 ||	 vkey == VK_DIVIDE
			 ||	 vkey == VK_MULTIPLY
			 ||	 vkey == VK_SUBTRACT
			 ||	 vkey == VK_ADD
			 ) )
			{
				return 0;
			}

			/* XXX move this */
			if ( cheat_state->_generic.menu
			 &&	 (
					 vkey == set.key_menu_up
			 ||	 vkey == set.key_menu_right
			 ||	 vkey == set.key_menu_down
			 ||	 vkey == set.key_menu_left
			 ||	 vkey == set.key_menu_select
			 ) )
			{
				return 0;
			}

		}
		break;
		
		case WM_KILLFOCUS:
			keys_cleared = 0;
			keyhook_clear_states();
			break;
	}
wnd_proc_original:
	return CallWindowProc( orig_wndproc, wnd, umsg, wparam, lparam );
}

void keyhook_maybe_install ( HWND wnd )
{
	if ( orig_wndproc == NULL || wnd != orig_wnd )
	{
		keyhook_uninstall();

		//Log("Installing keyhook...");
		memset( key_table, 0, sizeof(struct key_state) * 256 );
		orig_wndproc = ( WNDPROC ) ( UINT_PTR ) SetWindowLong( wnd, GWL_WNDPROC, (LONG) (UINT_PTR) wnd_proc );
		orig_wnd = wnd;
	}
}

void keyhook_uninstall ( void )
{
	if ( orig_wnd != NULL )
	{
		//Log("Removing keyhook...");
		SetWindowLong( orig_wnd, GWL_WNDPROC, (LONG) (UINT_PTR) orig_wndproc );
		orig_wnd = NULL;
	}
}

void keyhook_run ( void )
{
	keys_cleared = 0;
	for ( int i = 0; i < 256; i++ )
	{
		key_table[i].consume = 0;

		if ( i == VK_PRIOR || i == VK_NEXT || i == VK_TAB )
			key_table[i].pstate = ( key_table[i].count & 1 );
		else
			key_table[i].pstate = KEY_DOWN( i );

		if ( key_table[i].count > 0 )
		{
			key_table[i].flip ^= 1;
			key_table[i].count--;
		}
	}
}

int keyhook_key_down ( int v )
{
	if ( key_table[v].consume )
		return 0;
	else
		return ( key_table[v].count & 1 ) ^ key_table[v].flip;
}

int keyhook_key_up ( int v )
{
	return !KEY_DOWN( v );
}

int keyhook_key_pressed ( int v )
{
	if ( key_table[v].consume )
		return 0;
	else if ( v == VK_PRIOR || v == VK_NEXT || v == VK_TAB )
		return KEY_DOWN( v ) && !( key_table[v].pstate ^ key_table[v].flip );
	else
		return KEY_DOWN( v ) && !key_table[v].pstate;
}

int keyhook_key_released ( int v )
{
	return KEY_UP( v ) && key_table[v].pstate;
}

void keyhook_key_consume ( int v )
{
	key_table[v].consume = 1;
}

void keyhook_clear_states ( void )
{
	if ( !keys_cleared )
	{
		keys_cleared = 1;
		for ( int i = 0; i < 256; i++ )
		{
			key_table[i].pstate = 0;
			key_table[i].count = 0;
			key_table[i].flip = 0;
		}
	}
}
