script_name("Spammer")
script_version("0.0.1")
script_author("Kiko")

scriptWorking = false

function main()

    repeat
        wait(0)
    until isSampLoaded() and isSampAvailable()

    wait(150)
    sendMessage("Created {464446}by{850AB9} Kiko")
    sendMessage("{464446}��������� - {850AB9}/spam")

    sampRegisterChatCommand('spam', spam)

    while true do
        wait(0)
    end
end

function spam(pId)
    lua_thread.create(function()
        if pId ~= "" then
            scriptWorking = true -- ��� ����� Slav� ����, � ������ �������� ������
            havePed, ped = sampGetCharHandleBySampPlayerId(pId) -- �������� ��� ������ �� �������� ����� ��������� �������
            if havePed then
                while scriptWorking do -- ��������� ��� ��� ��������
                    wait(65)
                    checkPlayerInStream, _ = sampGetCharHandleBySampPlayerId(pId) -- �������� ��� ������ �� �������� ����� ��������� �������

                    if checkPlayerInStream then -- ���� ����� ��� � ������ ���������� �������
                        PedX, PedY, PedZ = getCharCoordinates(ped) -- �������� ���������� ��� ��������� �� �������
                        setCharCoordinates(playerPed, PedX, PedY, PedZ) -- ��������� ������� � ������, ����� �� ����� ��� �������
                        --sampSendChat("/pay " .. pId .. " 1")
                        sampSendChat("/pass " .. pId)
                        wait(100)
                        --sampSendChat("/sms " .. pId .." Hi Sir, ��� ����, ����� �� �� ��� Cumming? ������� ��������� �������� � Dungeon ��������")

                    else -- ���� ����� �������� � ��������, �� �� �� ��� � ������� ��������� ������� /goto, ���� �� ������, �� ��� �� ���� :)
                        if sampGetPlayerNickname(pId) ~= nil then -- ���� ����� ��� �� ������� ����� /goto
                            sendMessage("��� ���� �������, � �� �� ���, ������ ���� ���������� ����� ����� ��� ����� ��������?!")
                            sampSendChat('/goto ' .. pId) -- �� ����� ������ :(
                            checkPlayerInStream = sampGetCharHandleBySampPlayerId(pId) -- �� ��� ����� ����� ������?
                        else -- ��� ������... ����� �������
                            _, myId = sampGetPlayerIdByCharHandle(playerPed) -- ��������� ��� ������ ���� ����� ��� ����������
                            sendMessage("��� ��������, Dungeon Master - " .. sampGetPlayerNickname(myId) ..", ������� ������ ��� ���� Slave!") -- ����������� ������ Dungeona
                        end
                    end
                end
            else
                sendMessage("�� �� �����, ��� ID'� " .. pId .. ", � ������...") -- ���� ��� ��� � ������
            end
        else
            sendMessage("���, Dungeon Master, ������� ���� ID Slave'a, ����� ������ �� ���� Cumming")
        end
    end)
end

function sendMessage(text)
    tag = '{464446}[Spam{850AB9}Mer{464446}]: {850AB9}'
    sampAddChatMessage(tag .. text, -1)
end
