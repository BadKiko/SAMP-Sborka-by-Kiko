#include "main.h"

void ConsoleCommandHandler(PCHAR szCommand)
{
	// EXIT
	if(!strncmp(szCommand, "exit", 4) || !strncmp(szCommand, "EXIT", 4) ||
		!strncmp(szCommand, "quit", 4) || !strncmp(szCommand, "QUIT", 4))
	{
		ExitProcess(0);
		return;
	}

	// RECONNECT
	if(!strncmp(szCommand, "reconnect", 9) || !strncmp(szCommand, "RECONNECT", 9))
	{
		restartGame();
		disconnect( 500 );
		cheat_state_text( "Rejoining in %d seconds...", set.rejoin_delay / 1000 );
		cheat_state->_generic.rejoinTick = GetTickCount();
		return;
	}

	// ADD BOT WITH CUSTOM NAME
	if(!strncmp(szCommand, "bot_add", 7) || !strncmp(szCommand, "BOT_ADD", 7))
	{
		char szBotName[128];

		if(sscanf(&szCommand[8], "%s", szBotName) < 1)
		{
			addMessageToConsole("USAGE: bot_add <name>");
			return;
		}

		if(g_pBotManager)
			g_pBotManager->AddBotEx(szBotName);

		return;
	}

	// KICK BOT BY ID
	if(!strncmp(szCommand, "bot_kick", 8) || !strncmp(szCommand, "BOT_KICK", 8))
	{
		if(!strncmp(szCommand, "bot_kick_all", 12) || !strncmp(szCommand, "BOT_KICK_ALL", 12))
		{
			if(g_pBotManager)
			{
				if(g_pBotManager->m_pBots->m_iBotCount > 0)
				{
					g_pBotManager->KickAllBots();
					addMessageToConsole("Kicked all bots.");
				}
				else
					addMessageToConsole("There are no bots connected.");
			}
			return;
		}

		int iBotID;

		if(sscanf(&szCommand[9], "%d", &iBotID) < 1)
		{
			addMessageToConsole("USAGE: bot_kick <bot id>");
			return;
		}

		if(g_pBotManager)
		{
			if(g_pBotManager->m_pBots->IsInited(iBotID))
			{
				g_pBotManager->m_pBots->Destroy(iBotID, 1);
				addMessageToConsole("Bot (%s) kicked! | BotID: %d.", g_pBotManager->m_pBots->m_Bots[iBotID].szName, iBotID);
			}
			else
				addMessageToConsole("Bot ID %d doesn't exists!", iBotID);
		}

		return;
	}

	// BOT SELECT CLASS
	if(!strncmp(szCommand, "bot_class", 9) || !strncmp(szCommand, "BOT_CLASS", 9))
	{
		int iBotID, iClassID;

		if(sscanf(&szCommand[10], "%d%d", &iBotID, &iClassID) < 2)
		{
			addMessageToConsole("USAGE: bot_class <bot id> <class id>");
			return;
		}

		if(g_pBotManager)
		{
			if(g_pBotManager->m_pBots->IsInited(iBotID))
			{
				RakNet::BitStream bsSpawnRequest;
				bsSpawnRequest.Write(iClassID);
				g_pBotManager->m_pBots->SendRPC(iBotID, RPC_RequestClass, bsSpawnRequest, HIGH_PRIORITY, RELIABLE, 0, FALSE);

				addMessageToConsole("Bot (%s) selected %d. class. | BotID: %d.", g_pBotManager->m_pBots->m_Bots[iBotID].szName, iClassID, iBotID);
			}
			else
				addMessageToConsole("Bot ID %d doesn't exists!", iBotID);
		}

		return;
	}

	// BOT REQUEST SPAWN
	if(!strncmp(szCommand, "bot_spawn", 9) || !strncmp(szCommand, "BOT_SPAWN", 9))
	{
		int iBotID;

		if(sscanf(&szCommand[10], "%d", &iBotID) < 1)
		{
			addMessageToConsole("USAGE: bot_spawn <bot id>");
			return;
		}

		if(g_pBotManager)
		{
			if(g_pBotManager->m_pBots->IsInited(iBotID))
			{
				RakNet::BitStream bsSendRequestSpawn;
				g_pBotManager->m_pBots->SendRPC(iBotID, RPC_RequestSpawn, bsSendRequestSpawn, HIGH_PRIORITY, RELIABLE, 0, FALSE);

				addMessageToConsole("Bot (%s) requested spawn. | BotID: %d.", g_pBotManager->m_pBots->m_Bots[iBotID].szName, iBotID);
			}
			else
				addMessageToConsole("Bot ID %d doesn't exists!", iBotID);
		}
	}

	// BOT FORCE SPAWN
	if(!strncmp(szCommand, "bot_forcespawn", 14) || !strncmp(szCommand, "BOT_FORCESPAWN", 14))
	{
		int iBotID;

		if(sscanf(&szCommand[15], "%d", &iBotID) < 1)
		{
			addMessageToConsole("USAGE: bot_forcespawn <bot id>");
			return;
		}

		if(g_pBotManager)
		{
			if(g_pBotManager->m_pBots->IsInited(iBotID))
			{
				RakNet::BitStream bsSendRequestSpawn;
				g_pBotManager->m_pBots->SendRPC(iBotID, RPC_RequestSpawn, bsSendRequestSpawn, HIGH_PRIORITY, RELIABLE, 0, FALSE);

				RakNet::BitStream bsSendSpawn;
				g_pBotManager->m_pBots->SendRPC(iBotID, RPC_Spawn, bsSendSpawn, HIGH_PRIORITY, RELIABLE, 0, FALSE);

				g_pBotManager->m_pBots->m_Bots[iBotID].bIsSpawned = 1;

				addMessageToConsole("Bot (%s) forced spawn. | BotID: %d.", g_pBotManager->m_pBots->m_Bots[iBotID].szName, iBotID);
			}
			else
				addMessageToConsole("Bot ID %d doesn't exists!", iBotID);
		}
	}

	// BOT SAY
	if(!strncmp(szCommand, "bot_say", 7) || !strncmp(szCommand, "BOT_SAY", 7))
	{
		int iBotID;
		char szText[128];

		if(sscanf(&szCommand[8], "%d %[^\t\n]", &iBotID, szText) < 2)
		{
			addMessageToConsole("USAGE: bot_say <bot id> <text>");
			return;
		}

		if(g_pBotManager)
		{
			if(g_pBotManager->m_pBots->IsInited(iBotID))
			{
				RakNet::BitStream bsSend;

				BYTE byteTextLen = strlen(szText);

				bsSend.Write(byteTextLen);
				bsSend.Write(szText, byteTextLen);

				g_pBotManager->m_pBots->SendRPC(iBotID, RPC_Chat, bsSend, HIGH_PRIORITY, RELIABLE, 0, FALSE);

				addMessageToConsole("Bot (%s) say: %s. | BotID: %d.", g_pBotManager->m_pBots->m_Bots[iBotID].szName, szText, iBotID);
			}
			else
				addMessageToConsole("Bot ID %d doesn't exists!", iBotID);
		}
	}

	// TOGGLE TEST CRASHER
	if(!strncmp(szCommand, "testcrasher", 11) || !strncmp(szCommand, "TESTCRASHER", 11))
	{
		cheat_state->_generic.testcrasher ^= 1;
	
		if(cheat_state->_generic.testcrasher != 0)
			addMessageToConsole("Test crasher enabled.");
		else
			addMessageToConsole("Test crasher disabled.");
	}
}