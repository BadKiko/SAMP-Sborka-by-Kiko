/*
	La Pirula Project
*/

#include "main.h"

int iProcessedBotID = -1;

CBots::CBots()
{
	m_iBotCount = 0;
	m_fCircleAngle = 0;

	for(int x = 0; x < 500; x++)
	{
		m_Bots[x].bIsInited = 0;
		m_Bots[x].bIsJoined = 0;
		m_Bots[x].bIsSpawned = 0;
		m_Bots[x].usPlayerID = 0xFFFF;
		m_Bots[x].pRakClient = NULL;
	}
}

int CBots::Create(char *szHostname, int iPort, char *szNickname, char *szPassword)
{
	strcpy(m_Bots[m_iBotCount].szName, szNickname);

	m_Bots[m_iBotCount].pRakClient = RakNetworkFactory::GetRakClientInterface();

	if(m_Bots[m_iBotCount].pRakClient == NULL) return -1;

	m_Bots[m_iBotCount].pRakClient->SetMTUSize(576);
	m_Bots[m_iBotCount].pRakClient->SetPassword(szPassword);
	m_Bots[m_iBotCount].pRakClient->Connect(szHostname, iPort, 0, 0, 5);

	cheat_state_text("Bot (%s) connection request sent. | BotID: %d.", m_Bots[m_iBotCount].szName, m_iBotCount);
	addMessageToConsole("Bot (%s) connection request sent. | BotID: %d.", m_Bots[m_iBotCount].szName, m_iBotCount);

	m_Bots[m_iBotCount].bIsInited = 1;
	m_Bots[m_iBotCount].bIsJoined = 0;
	m_Bots[m_iBotCount].bIsSpawned = 0;
	m_iBotCount++;

	return (m_iBotCount - 1);
}

void CBots::Destroy(int iBotID, bool bDisconnect)
{
	if(!m_Bots[iBotID].bIsInited)
		return;

	if(bDisconnect)
		m_Bots[iBotID].pRakClient->Disconnect(500);

	RakNetworkFactory::DestroyRakClientInterface(m_Bots[iBotID].pRakClient);

	m_Bots[iBotID].bIsInited = 0;
	m_Bots[iBotID].bIsJoined = 0;
	m_Bots[iBotID].bIsSpawned = 0;
	m_Bots[iBotID].usPlayerID = 0xFFFF;
	m_Bots[iBotID].pRakClient = NULL;

	m_iBotCount--;
}

void CBots::UpdateNetwork(int iBotID)
{
	if(!m_Bots[iBotID].bIsInited || !m_Bots[iBotID].pRakClient)
		return;

	unsigned char packetIdentifier;
	Packet *pkt;

	while(pkt = m_Bots[iBotID].pRakClient->Receive())
	{
		packetIdentifier = GetPacketID(pkt);

		switch(packetIdentifier)
		{
			case ID_CONNECTION_REQUEST_ACCEPTED:
			{
				RakNet::BitStream bsSuccAuth((unsigned char *)pkt->data, pkt->length, false);

				bsSuccAuth.IgnoreBits(8); // ID_CONNECTION_REQUEST_ACCEPTED
				bsSuccAuth.IgnoreBits(32); // binaryAddress
				bsSuccAuth.IgnoreBits(16); // port

				bsSuccAuth.Read(m_Bots[iBotID].usPlayerID);
				bsSuccAuth.Read(m_Bots[iBotID].uiChallenge);

				int iVersion = NETGAME_VERSION;

				char auth_bs[4*16] = {0};
				char client_version[] = CLIENT_VERSION;

				gen_rand_gpci(auth_bs);

				BYTE byteNameLen = (BYTE) strlen(m_Bots[iBotID].szName);
				BYTE byteAuthBSLen = (BYTE) strlen(auth_bs);
				BYTE byteVersionLen = (BYTE) strlen(client_version);

				unsigned int uiClientChallengeResponse = m_Bots[iBotID].uiChallenge ^ iVersion;

				RakNet::BitStream bsSend;

				bsSend.Write(iVersion);
				bsSend.Write((BYTE)1);

				bsSend.Write(byteNameLen);
				bsSend.Write(m_Bots[iBotID].szName, byteNameLen);

				bsSend.Write(uiClientChallengeResponse);

				bsSend.Write(byteAuthBSLen);
				bsSend.Write(auth_bs, byteAuthBSLen);

				bsSend.Write(byteVersionLen);
				bsSend.Write(client_version, byteVersionLen);

				SendRPC(iBotID, RPC_ClientJoin, bsSend, HIGH_PRIORITY, RELIABLE_ORDERED, 0, false);

				m_Bots[iBotID].bIsJoined = 1;

				Log("[BOT:CLIENTJOIN] BotID: %d | %s, %s, %d -> %d, %s.", iBotID, m_Bots[iBotID].szName, auth_bs, m_Bots[iBotID].uiChallenge, uiClientChallengeResponse, client_version);

				cheat_state_text("Bot (%s) connected. | BotID: %d.", m_Bots[iBotID].szName, iBotID);
				addMessageToConsole("Bot (%s) connected. | BotID: %d.", m_Bots[iBotID].szName, iBotID);
				break;
			}

			case ID_AUTH_KEY:
			{
				char* auth_key;
				bool found_key = false;

				for(int x = 0; x < 1535; x++)
				{
					if(!strcmp(((char*)pkt->data + 2), AuthKeyTable[x][0]))
					{
						auth_key = AuthKeyTable[x][1];
						found_key = true;
					}
				}

				if(found_key)
				{
					RakNet::BitStream bsKey;
					BYTE byteAuthKeyLen;

					byteAuthKeyLen = (BYTE)strlen(auth_key);
					
					bsKey.Write((BYTE)ID_AUTH_KEY);
					bsKey.Write((BYTE)byteAuthKeyLen);
					bsKey.Write(auth_key, byteAuthKeyLen);

					m_Bots[iBotID].pRakClient->Send(&bsKey, SYSTEM_PRIORITY, RELIABLE, NULL);

					Log("[BOT:AUTH] BotID: %d | %s -> %s", iBotID, ((char*)pkt->data + 2), auth_key);
				}
				else
				{
					Log("[BOT:AUTH] BotID: %d | Unknown AUTH_IN! (%s)", iBotID, ((char*)pkt->data + 2));
				}
				break;
			}

			case ID_RSA_PUBLIC_KEY_MISMATCH:
				return Error(iBotID, "Failed to initialize encryption.");
				break;

			case ID_CONNECTION_BANNED:
				return Error(iBotID, "You're banned from this server.");
				break;

			case ID_NO_FREE_INCOMING_CONNECTIONS:
				return Error(iBotID, "The server is full.");
				break;

			case ID_DISCONNECTION_NOTIFICATION:
				return Error(iBotID, "Server closed the connection.");
				break;

			case ID_CONNECTION_LOST:
				return Error(iBotID, "Lost connection to the server.");
				break;

			case ID_INVALID_PASSWORD:
				return Error(iBotID, "Wrong server password.");
				break;

			case ID_CONNECTION_ATTEMPT_FAILED: 
				return Error(iBotID, "The server didn't respond.");
				break;
		}

		if(m_Bots[iBotID].pRakClient != NULL)
			m_Bots[iBotID].pRakClient->DeallocatePacket(pkt);
	}
}

void CBots::HandleRPC(int iBotID, int iRPCID, RakNet::BitStream Params)
{
	if(!IsInited(iBotID))
		return;

	if(iRPCID == RPC_RequestSpawn && !m_Bots[iBotID].bIsSpawned)
	{
		BYTE byteRequestOutcome = 0;
		Params.Read(byteRequestOutcome);

		if (byteRequestOutcome != 0)
		{
			RakNet::BitStream bsSendSpawn;
			g_pBotManager->m_pBots->SendRPC(iBotID, RPC_Spawn, bsSendSpawn, HIGH_PRIORITY, RELIABLE, 0, FALSE);

			m_Bots[iBotID].bIsSpawned = 1;

			addMessageToConsole("The server accepted the spawn request of %s bot. (ID: %d)", m_Bots[iBotID].szName, iBotID);
		}
		else
			addMessageToConsole("The server rejected the spawn request of %s bot. (ID: %d)", m_Bots[iBotID].szName, iBotID);
	}
}

bool CBots::SendRPC(int iBotID, int iRPCID, RakNet::BitStream Params, PacketPriority Priority, PacketReliability Reliability, char OrderingChannel, bool ShiftTimestamp)
{
	if(!m_Bots[iBotID].bIsInited)
		return 0;

	if(!m_Bots[iBotID].pRakClient)
		return 0;

	return m_Bots[iBotID].pRakClient->RPC(&iRPCID, &Params, Priority, Reliability, OrderingChannel, ShiftTimestamp);
}

bool CBots::SendOnFootFullSyncData(int iBotID, stOnFootData *pofSync)
{
	if(!m_Bots[iBotID].bIsInited)
		return 0;

	if(pofSync == NULL)
		return 0;

	RakNet::BitStream bsSendData;

	bsSendData.Write((BYTE) ID_PLAYER_SYNC);
	bsSendData.Write((PCHAR) pofSync, sizeof(stOnFootData));

	return m_Bots[iBotID].pRakClient->Send(&bsSendData, HIGH_PRIORITY, UNRELIABLE_SEQUENCED, 0);
}

void CBots::ProcessCheats()
{
	if(!g_pBotManager)
		return;

	static WORD i = 0;

	static DWORD dwLastBotProcessTick = GetTickCount();

	static int iFollowMultiplier = 1;

	static float fPulsedRotation = 0;

	static bool iLineState = 0;
	static int iLineLeftMultiplier = 1;
	static int iLineRightMultiplier = 1;

	if(!m_Bots[i].bIsInited || !m_Bots[i].bIsJoined)
		goto find_another_bot;

	if(GetTickCount() - dwLastBotProcessTick >= g_pBotManager->BotManagerSettings.dwCheatProcessingRate && m_Bots[i].bIsInited && m_Bots[i].bIsJoined)
	{
		if(m_Bots[i].iTaskID == 1)
		{
			if(!m_Bots[i].bIsSpawned)
			{
				RakNet::BitStream bsSpawnRequest;
				bsSpawnRequest.Write(g_pBotManager->BotManagerSettings.iClassID);
				SendRPC(i, RPC_RequestClass, bsSpawnRequest, HIGH_PRIORITY, RELIABLE, 0, FALSE);

				addMessageToConsole("Bot (%s) selected %d. class. | BotID: %d.", m_Bots[i].szName, g_pBotManager->BotManagerSettings.iClassID, i);

				RakNet::BitStream bsSendRequestSpawn;
				SendRPC(i, RPC_RequestSpawn, bsSendRequestSpawn, HIGH_PRIORITY, RELIABLE, 0, FALSE);

				addMessageToConsole("Bot (%s) requested spawn. | BotID: %d.", m_Bots[i].szName, i);

				if(g_pBotManager->BotManagerSettings.bForceSpawn)
				{
					RakNet::BitStream bsSendSpawn;
					SendRPC(i, RPC_Spawn, bsSendSpawn, HIGH_PRIORITY, RELIABLE, 0, FALSE);

					m_Bots[i].bIsSpawned = 1;

					addMessageToConsole("Bot (%s) forced spawn. | BotID: %d.", m_Bots[i].szName, i);
				}
			}

			m_Bots[i].iTaskID = 0;
		}

		if(g_pBotManager->BotManagerSettings.iGroupAction == 1 && cheat_state->state != CHEAT_STATE_NONE)
		{
			struct actor_info *self = actor_info_get(ACTOR_SELF, 0);

			if(self != NULL)
			{
				float *coord = (cheat_state->state == CHEAT_STATE_VEHICLE) ? cheat_state->vehicle.coords : cheat_state->actor.coords;

				float rotation = g_pBotManager->BotManagerSettings.fFollowAngle;
				float distance = 3.5f;

				if(GetBotCount() > 20) distance = 7.5f;
				else if(GetBotCount() > 40) distance = 12.5f;
				else if(GetBotCount() > 60) distance = 15.5f;
				else if(GetBotCount() > 80) distance = 18.5f;
				else if(GetBotCount() > 100) distance = 20.0f;

				stOnFootData OnFootData;

				memset(&OnFootData, 0, sizeof(stOnFootData));

				if(cheat_state->state == CHEAT_STATE_ACTOR)
				{
					memcpy(&OnFootData, &g_Players->pLocalPlayer->onFootData, sizeof(stOnFootData));
				}
				else
					OnFootData.sCurrentAnimationID = 301;

				OnFootData.byteHealth = 1;
				OnFootData.byteArmor = 0;

				OnFootData.fPosition[0] = coord[0] + iFollowMultiplier * (distance * -sin(-self->fCurrentRotation-rotation));
				OnFootData.fPosition[1] = coord[1] + iFollowMultiplier * (distance * -cos(-self->fCurrentRotation-rotation));
				OnFootData.fPosition[2] = coord[2];

				SendOnFootFullSyncData(i, &OnFootData);

				iFollowMultiplier++;
			}
		}

		if(g_pBotManager->BotManagerSettings.iGroupAction == 2 && cheat_state->state != CHEAT_STATE_NONE)
		{
			float *coord = (cheat_state->state == CHEAT_STATE_VEHICLE) ? cheat_state->vehicle.coords : cheat_state->actor.coords;
			float radius = g_pBotManager->BotManagerSettings.fCircleRadius;
			float pos[3] = {coord[0] + sinf(-m_fCircleAngle) * radius, coord[1] + cosf(-m_fCircleAngle) * radius, coord[2] + 1};

			stOnFootData OnFootData;

			memset(&OnFootData, 0, sizeof(stOnFootData));

			OnFootData.byteHealth = 1;
			OnFootData.byteArmor = 0;

			OnFootData.sCurrentAnimationID= 301;

			vect3_copy(pos, OnFootData.fPosition);

			SendOnFootFullSyncData(i, &OnFootData);

			m_fCircleAngle += 3.1415 / 10;
			if(m_fCircleAngle >= 2 * 3.1415) m_fCircleAngle = 0;
		}

		if(g_pBotManager->BotManagerSettings.iGroupAction == 3 && cheat_state->state == CHEAT_STATE_ACTOR && KEY_DOWN(VK_LBUTTON))
		{
			struct actor_info *self = actor_info_get(ACTOR_SELF, 0);

			stOnFootData OnFootData;

			memset(&OnFootData, 0, sizeof(stOnFootData));

			OnFootData.byteHealth = 1;
			OnFootData.byteArmor = 0;

			OnFootData.sCurrentAnimationID = 301;

			vect3_copy(cheat_state->actor.coords, OnFootData.fPosition);

			OnFootData.fPosition[0] += cam_matrix[4] * 6.0f;
			OnFootData.fPosition[1] += cam_matrix[5] * 6.0f;
			OnFootData.fPosition[2] += cam_matrix[6] * 2.0f;

			OnFootData.fMoveSpeed[0] = cam_matrix[4] * 7.5f;
			OnFootData.fMoveSpeed[1] = cam_matrix[5] * 7.5f;
			OnFootData.fMoveSpeed[2] = cam_matrix[6] * 7.5f;

			SendOnFootFullSyncData(i, &OnFootData);
		}

		if(g_pBotManager->BotManagerSettings.iGroupAction == 4 && cheat_state->state != CHEAT_STATE_NONE)
		{
			struct actor_info *self = actor_info_get(ACTOR_SELF, 0);

			if(self != NULL)
			{
				float rotation = + 7.9f;

				if(!iLineState)
					rotation = + 29.9f;

				iLineState ^= 1;

				float distance = g_pBotManager->BotManagerSettings.fLineDistance;
				float *coord = (cheat_state->state == CHEAT_STATE_VEHICLE) ? cheat_state->vehicle.coords : cheat_state->actor.coords;

				int iCurrentMultiplier = iLineState ? iLineLeftMultiplier : iLineRightMultiplier;

				stOnFootData OnFootData;

				memset(&OnFootData, 0, sizeof(stOnFootData));

				if(cheat_state->state == CHEAT_STATE_ACTOR)
					vect4_copy(g_Players->pLocalPlayer->onFootData.fQuaternion, OnFootData.fQuaternion);

				OnFootData.byteHealth = 1;
				OnFootData.byteArmor = 0;

				OnFootData.sCurrentAnimationID = 301;

				OnFootData.fPosition[0] = coord[0] + iCurrentMultiplier * (distance * -sin(-self->fCurrentRotation-rotation));
				OnFootData.fPosition[1] = coord[1] + iCurrentMultiplier * (distance * -cos(-self->fCurrentRotation-rotation));
				OnFootData.fPosition[2] = coord[2];

				SendOnFootFullSyncData(i, &OnFootData);

				if(iLineState)
					iLineLeftMultiplier++;
				else
					iLineRightMultiplier++;
			}
		}

		i++;

		dwLastBotProcessTick = GetTickCount();
	}

find_another_bot:
	for(i; i < 500; i++)
	{
		if(i == 0)
		{
			iFollowMultiplier = 1;

			iLineLeftMultiplier = 1;
			iLineRightMultiplier = 1;
		}

		if(m_Bots[i].bIsInited && m_Bots[i].bIsJoined)
			break;
	}

	if ( i >= 499 )
	{
		i = 0;
	}
}

void CBots::ProcessNetwork()
{
	if(!g_pBotManager)
		return;

	static DWORD dwLastBotUpdateNetworkTick = GetTickCount();

	if(GetTickCount() - dwLastBotUpdateNetworkTick >= g_pBotManager->BotManagerSettings.dwNetworkProcessingRate)
	{
		for(int i = 0; i < 500; i++)
		{
			if(!m_Bots[i].bIsInited)
				continue;

			iProcessedBotID = i;

			UpdateNetwork(i);
		}

		dwLastBotUpdateNetworkTick = GetTickCount();
	}
}

void CBots::Process()
{
	ProcessCheats();
	ProcessNetwork();
}

void CBots::Error(int iBotID, char* szError)
{
	if(!m_Bots[iBotID].bIsInited)
		return;

	Log("[BOT:ERROR] BotID: %d | %s", iBotID, szError);
	addMessageToChatWindow("[BOT:ERROR] BotID: %d | %s", iBotID, szError);
	addMessageToConsole("[BOT:ERROR] BotID: %d | %s", iBotID, szError);

	Destroy(iBotID, 0);
}