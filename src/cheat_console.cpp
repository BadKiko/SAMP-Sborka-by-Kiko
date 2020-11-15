#include "main.h"

CCheatConsole::CCheatConsole()
{
	for(int x = 0; x < MAX_CONSOLE_MESSAGES; x++)
	{
		memset(&m_ConsoleEntries[x], 0, sizeof(stConsoleEntry));
	}

	memset(szCommandWindowText, 0, sizeof(szCommandWindowText));

	m_bEnabled = 0;
}

CCheatConsole::~CCheatConsole()
{
}

void CCheatConsole::AddMessageToConsole(PCHAR szMessage, DWORD dwColor)
{
	PushBack();

	m_ConsoleEntries[0].dwColor = dwColor;
	strcpy(m_ConsoleEntries[0].szMessage, szMessage);
}

void CCheatConsole::PushBack()
{
	int x = MAX_CONSOLE_MESSAGES - 1;

	while(x)
	{
		memcpy(&m_ConsoleEntries[x], &m_ConsoleEntries[x-1], sizeof(stConsoleEntry));
		x--;
	}
}

bool CCheatConsole::IsEnabled()
{
	return m_bEnabled;
}

BOOL isCmdWindowDisabled;

int LastInputEnabled;
int LastChatWindowMode;
int LastIsChatboxOpen;
stInputBox *LastChatEditBox;

void CCheatConsole::ToggleConsole()
{
	traceLastFunc("CCheatConsole::ToggleConsole()");

	m_bEnabled ^= 1;

	ToggleKeyInputsDisabled(m_bEnabled);
	toggleATBCursor(m_bEnabled);

	if(m_bEnabled)
	{
		LastIsChatboxOpen = g_Input->pDXUTEditBox->bIsChatboxOpen;
		LastInputEnabled = g_Input->iInputEnabled;
		LastChatEditBox = g_Input->pDXUTEditBox;

		g_Input->pDXUTEditBox->bIsChatboxOpen = 0;
		g_Input->iInputEnabled = 0;
		g_Input->pDXUTEditBox = NULL;

		isCmdWindowDisabled = TRUE;
	}
	else
	{
		isCmdWindowDisabled = FALSE;

		g_Input->iInputEnabled = LastInputEnabled;
		g_Input->pDXUTEditBox = LastChatEditBox;
		g_Input->pDXUTEditBox->bIsChatboxOpen = LastIsChatboxOpen;
	}
}

#define FUNC_TOGGLECURSOR 0x63E20

void CCheatConsole::Render()
{
	traceLastFunc("CCheatConsole::Render()");

	if(gta_menu_active() || cheat_panic())
		return;

	static int iLastInputEnabledState = -1;

	if(g_Input->iInputEnabled && !m_bEnabled)
		ToggleKeyInputsDisabled(TRUE);

	else if(!m_bEnabled && iLastInputEnabledState != -1 && g_Input->iInputEnabled == 0 && g_Input->iInputEnabled != iLastInputEnabledState)
		ToggleKeyInputsDisabled(FALSE);

	iLastInputEnabledState = g_Input->iInputEnabled;

	ProcessInputDisabling();

	if(m_bEnabled)
	{
		render->D3DBox(15, 10, (int)(pPresentParam.BackBufferWidth - 30), (((pD3DFontConsoleWnd->DrawHeight()+1)*20) + 15), D3DCOLOR_ARGB(180, 0, 0, 0)); // console background
		render->D3DBox(15, 10 + (((pD3DFontConsoleWnd->DrawHeight()+1)*20) + 15), (int)(pPresentParam.BackBufferWidth - 30), 20, D3DCOLOR_ARGB(127, 0, 0, 0)); // cmdwindow background

		char buf[256];
		sprintf_s(buf, sizeof(buf), "> {FFFFFF}%s", szCommandWindowText);

		pD3DFont->Print(15, 10 + (((pD3DFontConsoleWnd->DrawHeight()+1)*20) + 15) + 1, D3DCOLOR_XRGB(70, 170, 255), buf, false); // cmdwindow text

		for(int x = 0; x < 20; x++)
		{
			if(strlen(m_ConsoleEntries[x].szMessage) != 0)
				pD3DFontConsoleWnd->Print(25, (int)(5 + ((pD3DFontConsoleWnd->DrawHeight()+1)*20) - ((pD3DFontConsoleWnd->DrawHeight()+1)*x)), m_ConsoleEntries[x].dwColor, m_ConsoleEntries[x].szMessage, false);
		}

		*(int *)( *(DWORD *)( g_dwSAMP_Addr + SAMP_SCOREBOARD_INFO ) ) = 0;
		g_Chat->iChatWindowMode = 0;

		if(isCmdWindowDisabled)
		{
			g_Input->iInputEnabled = 0;
			g_Input->pDXUTEditBox = NULL;

			uint32_t	func = g_dwSAMP_Addr + 0x63E20;
			uint32_t	obj = * ( DWORD * ) ( g_dwSAMP_Addr + SAMP_MISC_INFO );

			_asm
			{
				mov ecx, obj;
				push 0;
				push 3;
				call func;
			}
		}

		SetCursor(NULL); // hide the cursor
	}
}

void CCheatConsole::HandleInput(WPARAM wParam)
{
	switch(wParam)
	{
		case VK_RETURN:
		{
			ConsoleCommandHandler(szCommandWindowText);
			memset(szCommandWindowText, 0, sizeof(szCommandWindowText));
			break;
		}

		case VK_BACK:
		{
			int len = strlen(szCommandWindowText);

			if(len > 0)
				szCommandWindowText[len - 1] = 0;

			break;
		}

		default:
		{
			if(wParam >= 32 && wParam < 256)
			{
				int len = strlen(szCommandWindowText);

				if(len < MAX_CONSOLE_MESSAGE_LENGTH+1)
				{
					szCommandWindowText[len] = wParam;
					szCommandWindowText[len + 1] = 0;
				}
			}
			break;
		}
	}
}