#pragma once

//----------------------------------------------------

/*
	Group action IDs:
	0 - disabled
	1 - follow
	2 - circle
	3 - shooter
	4 - line
*/

//----------------------------------------------------

struct stBotManagerSettings
{
	int iGroupAction;

	bool bUseRandomNames;
	bool bDisconnectOnClose;

	int iClassID;
	bool bForceSpawn;

	float fFollowAngle;
	float fCircleRadius;
	float fLineDistance;

	DWORD dwNetworkProcessingRate;
	DWORD dwCheatProcessingRate;
};

//----------------------------------------------------

#pragma pack(1)
class CBotManager
{
public:
	CBots *m_pBots;

	stBotManagerSettings BotManagerSettings;

	CBotManager();
	~CBotManager();

	void AddBot();
	void AddBotEx(char *szNickname);

	void SpawnBot();

	void KickBot();

	void KickAllBots();
	void TimeoutAllBots();

	void SpawnAllBots();

	void Process();

	void HandleRPC(int iBotID, int iRPCID, RakNet::BitStream Params);
};

//----------------------------------------------------
