local ev = require('lib.samp.events')

local state = false
local dissync = false
local teleporting = false
local found_car = false

local server = -1
local join = 0
local x, y, z = 0, 0, 0

function main()
    repeat wait(0) until isSampAvailable()
    sampAddChatMessage("{464446}[AsTp{850AB9}Checkpoint{464446}]:{850AB9} Телепорт для АРЗ/Evolve загружен (от MrCreepTon | vk.com/hackmysoftware)")
    sampRegisterChatCommand('astp', function()
        if state then return sampAddChatMessage("{464446}[AsTp{850AB9}Checkpoint{464446}]:{850AB9} Сейчас использовать команду невозможно (возможно вы уже телепортируетесь)") end
        found_car = false
        _, x, y, z = getTargetBlipCoordinatesFixed()
        if not _ then return sampAddChatMessage("{464446}[AsTp{850AB9}Checkpoint{464446}]:{850AB9} Поставь метку") end
        --if not isCharOnFoot(PLAYER_PED) then return sampAddChatMessage("{464446}[AsTp{850AB9}Checkpoint{464446}]:{850AB9} Вы должны быть не в авто") end
        lua_thread.create(teleport)
        --mode = 1
        --sampAddChatMessage("{464446}[AsTp{850AB9}Checkpoint{464446}]:{850AB9} Включен. Теперь вам нужно зайти в интерьер и выйти из него.")
    end)
    sampRegisterChatCommand('astpn', function()
        if state then return sampAddChatMessage("{464446}[AsTp{850AB9}Checkpoint{464446}]:{850AB9} Сейчас использовать команду невозможно (возможно вы уже телепортируетесь)") end
        found_car = false
        _, x, y, z = SearchMarker()
        if not _ then return sampAddChatMessage("{464446}[AsTp{850AB9}Checkpoint{464446}]:{850AB9} Не обнаружили серверного маркера") end
        --if not isCharOnFoot(PLAYER_PED) then return sampAddChatMessage("{464446}[AsTp{850AB9}Checkpoint{464446}]:{850AB9} Вы должны быть не в авто") end
        --mode = 1
        --sampAddChatMessage("{464446}[AsTp{850AB9}Checkpoint{464446}]:{850AB9} Включен. Теперь вам нужно зайти в интерьер и выйти из него.")
        lua_thread.create(teleport)
    end)
    wait(-1)
end

-- function ev.onSetInterior(interior)
--     if interior == 0 and mode ~= 0 then
--         lua_thread.create(teleport)
--     end
-- end

function teleport()
    if isCharOnFoot(PLAYER_PED) then
        state = true
        lockPlayerControl(true)
        teleporting = true
        local ticks = 0
        while not found_car do
            wait(1000)
            ticks = ticks + 1
            if ticks >= 3 then
                state = false
                teleporting = false
                --mode = 0
                sampSendInteriorChange(getActiveInterior() + 1)
                wait(10)
                sampForceOnfootSync()
                wait(10)
                sampSendInteriorChange(getActiveInterior())
                sampAddChatMessage("{464446}[AsTp{850AB9}Checkpoint{464446}]:{850AB9} Не нашли авто в нужном вам месте")
                lockPlayerControl(false)
                break
            end
        end
        if found_car then
            state = false
            sampSendInteriorChange(getActiveInterior() + 1)
            wait(10)
            sampForceOnfootSync()
            wait(10)
            sampSendInteriorChange(getActiveInterior())
            wait(100)
            state = true
            local vehs = getAllVehicles()
            local found = false
            for k, veh in pairs(vehs) do
                local _, vid = sampGetVehicleIdByCarHandle(veh)
                if _ and getCarDoorLockStatus(veh) == 0 and getDriverOfCar(veh) == -1 and getMaximumNumberOfPassengers(veh) > 0 then
                    --sampSendEnterVehicle(vid, true)
                    dissync = true
                    state = false
                    local got = false
                    while not got do
                        wait(0)
                        if pcall(getCarCoordinates, veh) then
                            got = true
                            local cx, cy, cz = getCarCoordinates(veh)
                            setCharCoordinates(PLAYER_PED, cx, cy, cz)
                            sampAddChatMessage("{464446}[AsTp{850AB9}Checkpoint{464446}]:{850AB9} Один момент, мистер, не шевелитесь!")
                            for i = 1, 30 do
                                sampSendInteriorChange(getActiveInterior() + 1)
                                wait(10)
                                sampForcePassengerSyncSeatId(vid, 1)
                                wait(10)
                                sampSendInteriorChange(getActiveInterior())
                                wait(100)
                            end
                            dissync = false
                            found = true
                            sampSendInteriorChange(getActiveInterior() + 1)
                            wait(10)
                            sampForceOnfootSync()
                            wait(10)
                            sampSendInteriorChange(getActiveInterior())
                            sampAddChatMessage("{464446}[AsTp{850AB9}Checkpoint{464446}]:{850AB9} Готово")
                            break
                        end
                    end
                    if got then break end
                end
            end
            if not found then
                state = false
                sampAddChatMessage("{464446}[AsTp{850AB9}Checkpoint{464446}]:{850AB9} Не нашли авто в нужном вам месте")
            end
            teleporting = false
            lockPlayerControl(false)
        end
    else
        local veh = getCarCharIsUsing(PLAYER_PED)
        if getDriverOfCar(veh) == PLAYER_PED then
            state = true
            dissync = true
            setCarCoordinates(veh, x, y, z)
            wait(100)
            dissync = false
            sampForceVehicleSync()
            wait(1000)
            state = false
            sampAddChatMessage("{464446}[AsTp{850AB9}Checkpoint{464446}]:{850AB9} Готово!")
        else
            sampAddChatMessage("{464446}[AsTp{850AB9}Checkpoint{464446}]:{850AB9} Невозможно телепортироваться. Вы должны быть либо водителем авто, либо не в авто.")
        end
    end
end

function ev.onVehicleStreamIn(vehid, data)
    if state and teleporting and not found_car then
        if getDistanceBetweenCoords3d(x, y, z, data.position.x, data.position.y, data.position.z) <= 300 then
            found_car = true
        end
    end
end

function ev.onSendVehicleSync(data)
    if dissync then return false end
    if state then
        local interior = getActiveInterior()
        local sync = samp_create_sync_data('spectator')
        if teleporting then
            sync.position = {x = x, y = y, z = z}
        else
            sync.position = data.position
        end
        sync.send()
        sampSendInteriorChange(interior + 1)
        lua_thread.create(function() 
            wait(10)
            sampSendInteriorChange(interior)
        end)
    end
end


function ev.onSendPlayerSync(data)
    if dissync then return false end
    if state then
        local sync = samp_create_sync_data('spectator')
        if teleporting then
            sync.position = {x = x, y = y, z = z}
        else
            sync.position = data.position
        end
        sync.send()
        return false
    end
end

function ev.onTogglePlayerSpectating(toggle)
    if toggle == false and join == 2 then
        if server == 2 then join = 3 end
        lua_thread.create(function() 
            sampSpawnPlayer()
            sampForceOnfootSync()
            wait(1500)
            join = 0
            sampSendSpawn()
            sampForceOnfootSync()
            wait(100)
            --sampSendRequestSpawn()
            wait(100)
            state = false
            sampForceOnfootSync()
            sampSendInteriorChange(getActiveInterior() + 1)
            wait(10)
            sampSendInteriorChange(getActiveInterior())
            sampAddChatMessage("{464446}[AsTp{850AB9}Checkpoint{464446}]:{850AB9} Эксплоит сработал!")
        end)
    end
    if not toggle then toggle = 0 
    else toggle = 1 end
    return {toggle}
end

function ev.onSendRequestSpawn()
    if (join == 2 and server == 1) or (join == 3 and server == 2) then
        return false
    end
end

function ev.onSendSpawn()
    if (join == 2 and server == 1) or (join == 3 and server == 2) then
        return false
    end
end

function ev.onShowDialog(dialogid, style, title, btn1, btn2, text)
    if server == -1 then
        local hostname = sampGetCurrentServerName()
        sampfuncsLog(hostname)
        server = 0
        if hostname:find('Arizona') then server = 1 end
        if hostname:find('Evolve') then server = 2 end
        if server ~= 0 then
            state = true
            join = 1
        else
            server = -1
        end
    end
    if state then
        if (server == 1) or (server == 2 and text:find('зарегистрирован')) then
            if join == 1 then join = 2 end
        else
            sampAddChatMessage("{464446}[AsTp{850AB9}Checkpoint{464446}]:{850AB9} Что-то пошло не так.")
            sampAddChatMessage("{464446}[AsTp{850AB9}Checkpoint{464446}]:{850AB9} Если вы на Evolve, то закончите регистрацию аккаунта и перезайдите на сервер")
            sampAddChatMessage("{464446}[AsTp{850AB9}Checkpoint{464446}]:{850AB9} Если же вы не на Evolve, и не на Аризоне, то знайте, телепорт только для них!")
            state = false
            join = 0
        end
    end
end

function ev.onSendClientJoin()
    server = -1
end

function getTargetBlipCoordinatesFixed()
    local bool, x, y, z = getTargetBlipCoordinates(); if not bool then return false end
    requestCollision(x, y); loadScene(x, y, z)
    local bool, x, y, z = getTargetBlipCoordinates()
    return bool, x, y, z
end

function SearchMarker(posX, posY, posZ)
    local ret_posX = 0.0
    local ret_posY = 0.0
    local ret_posZ = 0.0
    local isFind = false
    for id = 0, 31 do
        local MarkerStruct = 0
        MarkerStruct = 0xC7F168 + id * 56
        local MarkerPosX = representIntAsFloat(readMemory(MarkerStruct + 0, 4, false))
        local MarkerPosY = representIntAsFloat(readMemory(MarkerStruct + 4, 4, false))
        local MarkerPosZ = representIntAsFloat(readMemory(MarkerStruct + 8, 4, false))
        if MarkerPosX ~= 0.0 or MarkerPosY ~= 0.0 or MarkerPosZ ~= 0.0 then
            ret_posX = MarkerPosX
            ret_posY = MarkerPosY
            ret_posZ = MarkerPosZ
            isFind = true
        end
    end
    return isFind, ret_posX, ret_posY, ret_posZ
end

function samp_create_sync_data(sync_type, copy_from_player)
    local ffi = require 'ffi'
    local sampfuncs = require 'sampfuncs'
    -- from SAMP.Lua
    local raknet = require 'samp.raknet'
    --require 'samp.synchronization'

    copy_from_player = copy_from_player or true
    local sync_traits = {
        player = {'PlayerSyncData', raknet.PACKET.PLAYER_SYNC, sampStorePlayerOnfootData},
        vehicle = {'VehicleSyncData', raknet.PACKET.VEHICLE_SYNC, sampStorePlayerIncarData},
        passenger = {'PassengerSyncData', raknet.PACKET.PASSENGER_SYNC, sampStorePlayerPassengerData},
        aim = {'AimSyncData', raknet.PACKET.AIM_SYNC, sampStorePlayerAimData},
        trailer = {'TrailerSyncData', raknet.PACKET.TRAILER_SYNC, sampStorePlayerTrailerData},
        unoccupied = {'UnoccupiedSyncData', raknet.PACKET.UNOCCUPIED_SYNC, nil},
        bullet = {'BulletSyncData', raknet.PACKET.BULLET_SYNC, nil},
        spectator = {'SpectatorSyncData', raknet.PACKET.SPECTATOR_SYNC, nil}
    }
    local sync_info = sync_traits[sync_type]
    local data_type = 'struct ' .. sync_info[1]
    local data = ffi.new(data_type, {})
    local raw_data_ptr = tonumber(ffi.cast('uintptr_t', ffi.new(data_type .. '*', data)))
    -- copy player's sync data to the allocated memory
    if copy_from_player then
        local copy_func = sync_info[3]
        if copy_func then
            local _, player_id
            if copy_from_player == true then
                _, player_id = sampGetPlayerIdByCharHandle(PLAYER_PED)
            else
                player_id = tonumber(copy_from_player)
            end
            copy_func(player_id, raw_data_ptr)
        end
    end
    -- function to send packet
    local func_send = function()
        local bs = raknetNewBitStream()
        raknetBitStreamWriteInt8(bs, sync_info[2])
        raknetBitStreamWriteBuffer(bs, raw_data_ptr, ffi.sizeof(data))
        raknetSendBitStreamEx(bs, sampfuncs.HIGH_PRIORITY, sampfuncs.UNRELIABLE_SEQUENCED, 1)
        raknetDeleteBitStream(bs)
    end
    -- metatable to access sync data and 'send' function
    local mt = {
        __index = function(t, index)
            return data[index]
        end,
        __newindex = function(t, index, value)
            data[index] = value
        end
    }
    return setmetatable({send = func_send}, mt)
end