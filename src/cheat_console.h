#pragma once

#define MAX_CONSOLE_MESSAGES 100
#define MAX_CONSOLE_MESSAGE_LENGTH 128

struct stConsoleEntry
{
	CHAR szMessage[MAX_CONSOLE_MESSAGE_LENGTH+1];
	DWORD dwColor;
};

class CCheatConsole
{
private:
	stConsoleEntry m_ConsoleEntries[MAX_CONSOLE_MESSAGES];

	bool m_bEnabled;
	CHAR szCommandWindowText[MAX_CONSOLE_MESSAGE_LENGTH+1];

public:
	CCheatConsole::CCheatConsole();
	~CCheatConsole();

	void AddMessageToConsole(PCHAR szMessage, DWORD dwColor);
	void PushBack();

	bool IsEnabled();
	void ToggleConsole();

	void Render();

	void HandleInput(WPARAM wParam);
};