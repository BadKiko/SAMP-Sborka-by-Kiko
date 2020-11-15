local ev = require('lib.samp.events')

local state = false
local isHooked = false
local ignore = false

local target = 0
local lastPos = {x = 0, y = 0, z = 0}

function main()
    repeat wait(500) until isSampAvailable()
		sendMessage('Created by MrCreepTon.')
    sendMessage('Загружен.')
    sampRegisterChatCommand('vcrash', function(param)
        ignore = false
        if state then
            state = false
            forceMe()
            sendMessage('Выключен')
        else
            if not isCharOnFoot(PLAYER_PED) then
                local veh = getCarCharIsUsing(PLAYER_PED)
                local _, vid = sampGetVehicleIdByCarHandle(veh)
                if _ then
                    if getDriverOfCar(veh) == PLAYER_PED then
                        if param:match('%d+') then
                            target = tonumber(param)
                            local _, ped = sampGetCharHandleBySampPlayerId(target)
                            if _ then
                                local x, y, z = getCharCoordinates(ped)
                                lastPos = {x = x, y = y, z = z}
                                isHooked = false
                                state = true
                                sendMessage('Включен')
                            else
                                sendMessage('Игрока нет в зоне стрима')
                            end
                        else
                            sendMessage('Используйте: /vcrash [id игрока]')
                        end
                    else
                        sendMessage('Нужно быть водителем')
                    end
                else
                    sendMessage('Не смогли получить ваше авто')
                end
            else
                sendMessage('Нужно быть в авто на водительском месте')
            end
        end
    end)
    while true do
        wait(0)
        if state then
            if not isCharOnFoot(PLAYER_PED) then
                local veh = getCarCharIsUsing(PLAYER_PED)
                local _, vid = sampGetVehicleIdByCarHandle(veh)
                if _ then
                    if getDriverOfCar(veh) == PLAYER_PED then
                        local _, ped = sampGetCharHandleBySampPlayerId(target)
                        if _ then
                            local x, y, z = getCharCoordinates(ped)
                            lastPos = {x = x, y = y, z = z}
                            if isHooked then
                                forceMe()
                                ignore = true
                                sampSendEnterVehicle(vid, false)
                                lua_thread.create(function()
                                    while ignore do
                                        pcall(sampForceOnfootSync)
                                        wait(10)
                                        pcall(sampForceUnoccupiedSyncSeatId, vid, 0)
                                        wait(10)
                                    end
                                end)
                                wait(1000)
                                ignore = false
                                state = false
                                sendMessage('Готово')
                            else
                                pcall(sampForceVehicleSync, vid)
                            end
                        else
                            sendMessage('Игрок пропал из зоны стрима, скрипт выключен')
                            state = false
                        end
                    else
                        sendMessage('Нужно быть водителем, скрипт выключен')
                        state = false
                    end
                else
                    sendMessage('Не смогли получить ваше авто, скрипт выключен')
                    state = false
                end
            else
                sendMessage('Вы вышли из авто, скрипт выключен')
                state = false
            end
        end
    end
end

function ev.onSendVehicleSync(data)
    if ignore then return false end
    if state then
        if not isHooked then
            data.position = lastPos
            data.position.z = data.position.z - 1
        else
            data.moveSpeed.z = -1
        end
    end
end

function onReceiveRpc(id, bitStream)
    if state then
        if id == 86 or id == 87 then return false end
    end
end

function ev.onPlayerSync(playerid, data)
    if state then
        if playerid == target then
            if data.surfingVehicleId == getMyVehicleId() and not isHooked then
                isHooked = true
            end
        end
    end
end

function ev.onSendUnoccupiedSync(data)
    if state and isHooked then
        data.position = lastPos
        data.position.z = data.position.z + 2
        data.roll = {x = 0e+1000, y = 0e+1000, z = 0e+1000}
        printStringNow('SENT', 1000)
    end
end

function getMyVehicleId()
    if not isCharOnFoot(PLAYER_PED) then
        local veh = getCarCharIsUsing(PLAYER_PED)
        local _, vid = sampGetVehicleIdByCarHandle(veh)
        if _ then
            return vid
        end
    end
    return -1
end

function sendMessage(text)
	tag = '{464446}[V{850AB9}Crash{464446}]: {850AB9}'
	sampAddChatMessage(tag .. text, -1)
end

function forceMe()
    if isCharOnFoot(PLAYER_PED) then
        sampForceOnfootSync()
    else
        local veh = getCarCharIsUsing(PLAYER_PED)
        local _, vid = sampGetVehicleIdByCarHandle(veh)
        if _ then
            if getDriverOfCar(veh) == PLAYER_PED then
                sampForceVehicleSync(vid)
            end
        end
    end
end
