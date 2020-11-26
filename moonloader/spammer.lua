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
    sendMessage("{464446}Активация - {850AB9}/spam")

    sampRegisterChatCommand('spam', spam)

    while true do
        wait(0)
    end
end

function spam(pId)
    lua_thread.create(function()
        if pId ~= "" then
            scriptWorking = true -- Все такой Slavе есть, а значит начинаем работу
            havePed, ped = sampGetCharHandleBySampPlayerId(pId) -- Получаем пед игрока на которого хотим натравить спаммер
            if havePed then
                while scriptWorking do -- Циклируем всю эту преблуду
                    wait(65)
                    checkPlayerInStream, _ = sampGetCharHandleBySampPlayerId(pId) -- Получаем пед игрока на которого хотим натравить спаммер

                    if checkPlayerInStream then -- Если чувак еще в стриме продолжаем веселье
                        PedX, PedY, PedZ = getCharCoordinates(ped) -- Получаем координаты для телепорта за игроком
                        setCharCoordinates(playerPed, PedX, PedY, PedZ) -- Постоянно ТПшимся в игрока, чтобы мы могли ему спамить
                        --sampSendChat("/pay " .. pId .. " 1")
                        sampSendChat("/pass " .. pId)
                        wait(100)
                        --sampSendChat("/sms " .. pId .." Hi Sir, как дела, давно же ты тут Cumming? Советую побыстрее вступить в Dungeon братство")

                    else -- Если чувак ахуевший и тпхнулся, то мы за ним с помощью серверной команды /goto, если не сможем, то вот он ЧОРТ :)
                        if sampGetPlayerNickname(pId) ~= nil then -- Этот чторт еще на сервере тогда /goto
                            sendMessage("Вот чорт ебанный, а ну за ним, откуда этот малолетний пидор знает что такое телепорт?!")
                            sampSendChat('/goto ' .. pId) -- Тп через сервер :(
                            checkPlayerInStream = sampGetCharHandleBySampPlayerId(pId) -- Мы уже возле этого пидора?
                        else -- Лох сдался... Конец скрипта
                            _, myId = sampGetPlayerIdByCharHandle(playerPed) -- Получение ида вашего педа чтобы вас поздравить
                            sendMessage("Лох оффнулся, Dungeon Master - " .. sampGetPlayerNickname(myId) ..", одержал победу над этим Slave!") -- Поздравляем нашего Dungeona
                        end
                    end
                end
            else
                sendMessage("Ты шо тупой, нет ID'а " .. pId .. ", в стриме...") -- Если ида нет в стриме
            end
        else
            sendMessage("Бля, Dungeon Master, введите хоть ID Slave'a, чтобы начать на него Cumming")
        end
    end)
end

function sendMessage(text)
    tag = '{464446}[Spam{850AB9}Mer{464446}]: {850AB9}'
    sampAddChatMessage(tag .. text, -1)
end
