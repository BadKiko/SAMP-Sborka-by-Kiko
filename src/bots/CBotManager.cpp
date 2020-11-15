/*
	La Pirula Project
*/

#include "main.h"

CBotManager::CBotManager()
{
	BotManagerSettings.bUseRandomNames = 0;
	BotManagerSettings.bDisconnectOnClose = 1;

	BotManagerSettings.iGroupAction = 0;

	BotManagerSettings.fFollowAngle = 0;
	BotManagerSettings.fCircleRadius = 100;
	BotManagerSettings.fLineDistance = 3.5f;

	BotManagerSettings.dwNetworkProcessingRate = 50;
	BotManagerSettings.dwCheatProcessingRate = 75;

	m_pBots = new CBots();
}

CBotManager::~CBotManager()
{
	if(BotManagerSettings.bDisconnectOnClose)
		KickAllBots();

	if(m_pBots)
	{
		delete m_pBots;
		m_pBots = NULL;
	}
}

void CBotManager::AddBot()
{
	if(m_pBots == NULL || g_SAMP == NULL || g_Players == NULL)
		return;

	char *szName = new char[MAX_PLAYER_NAME+1];
	
	if(BotManagerSettings.bUseRandomNames)
		gen_random(szName, 16);
	else
		sprintf(szName, "%s_%d", getPlayerName(g_Players->sLocalPlayerID), m_pBots->GetBotCount());

	m_pBots->Create(g_SAMP->szIP, g_SAMP->ulPort, szName, "");
}

void CBotManager::AddBotEx(char *szNickname)
{
	if(m_pBots == NULL || g_SAMP == NULL || g_Players == NULL)
		return;

	m_pBots->Create(g_SAMP->szIP, g_SAMP->ulPort, szNickname, "");
}

void CBotManager::SpawnBot()
{
	int iLastBot = -1;

	for(int x = 0; x < 500; x++)
	{
		if(m_pBots->IsInited(x) && m_pBots->IsJoined(x) && !m_pBots->IsSpawned(x))
			iLastBot = x;
	}

	if(iLastBot != -1)
		m_pBots->m_Bots[iLastBot].iTaskID = 1; // request spawn & class
}

void CBotManager::KickBot()
{
	int iLastBot = -1;

	for(int x = 0; x < 500; x++)
	{
		if(m_pBots->IsInited(x))
			iLastBot = x;
	}

	if(iLastBot != -1)
		m_pBots->Destroy(iLastBot, 1);
}

void CBotManager::KickAllBots()
{
	for(int x = 0; x < 500; x++)
		m_pBots->Destroy(x, 1);
}

void CBotManager::TimeoutAllBots()
{
	for(int x = 0; x < 500; x++)
		m_pBots->Destroy(x, 0);
}

void CBotManager::SpawnAllBots()
{
	for(int x = 0; x < 500; x++)
	{
		if(m_pBots->m_Bots[x].bIsInited && m_pBots->m_Bots[x].bIsJoined && !m_pBots->m_Bots[x].bIsSpawned)
			m_pBots->m_Bots[x].iTaskID = 1; // request spawn & class
	}
}

void CBotManager::Process()
{
	if(m_pBots) m_pBots->Process();
}

void CBotManager::HandleRPC(int iBotID, int iRPCID, RakNet::BitStream Params)
{
	if(m_pBots) m_pBots->HandleRPC(iBotID, iRPCID, Params);
}