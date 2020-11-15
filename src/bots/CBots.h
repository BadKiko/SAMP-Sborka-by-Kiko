#pragma once

//----------------------------------------------------

#define NETCODE_OPENCONNLULZ		6969
#define NETGAME_VERSION				4047

//----------------------------------------------------

struct stBots
{
	RakClientInterface *pRakClient;

	unsigned short usPlayerID;
	unsigned int uiChallenge;

	char szName[MAX_PLAYER_NAME+1];

	bool bIsInited;
	bool bIsJoined;
	bool bIsSpawned;

	/*
		Task IDs:
		1 - request spawn & class
	*/
	int iTaskID;
};

//----------------------------------------------------

extern int iProcessedBotID;

//----------------------------------------------------

#pragma pack(1)
class CBots
{
	public:
		int m_iBotCount;
		stBots m_Bots[500];

		float m_fCircleAngle;

		CBots();

		int Create(char *szHostname, int iPort, char *szNickname, char *szPassword);
		void Destroy(int iBotID, bool bDisconnect);

		bool IsInited(int iBotID)
		{
			return m_Bots[iBotID].bIsInited;
		}

		bool IsJoined(int iBotID)
		{
			return m_Bots[iBotID].bIsJoined;
		}

		bool IsSpawned(int iBotID)
		{
			return m_Bots[iBotID].bIsSpawned;
		}

		int GetBotCount()
		{
			return m_iBotCount;
		}

		void UpdateNetwork(int iBotID);

		void HandleRPC(int iBotID, int iRPCID, RakNet::BitStream Params);
		bool SendRPC(int iBotID, int iRPCID, RakNet::BitStream Params, PacketPriority Priority, PacketReliability Reliability, char OrderingChannel, bool ShiftTimestamp);

		bool SendOnFootFullSyncData(int iBotID, stOnFootData *pofSync);

		void ProcessCheats();
		void ProcessNetwork();

		void Process();

		void Error(int iBotID, char* szError);
};

//----------------------------------------------------
