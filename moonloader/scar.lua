local sampev = require 'lib.samp.events'
local offOnFoot = false
local offInCar = false

local function samp_create_sync_data(sync_type, copy_from_player)
    local ffi = require 'ffi'
    local sampfuncs = require 'sampfuncs'
    -- from SAMP.Lua
    local raknet = require 'lib.samp.raknet'
    require 'lib.samp.synchronization'

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

local function scar(arg)
	lua_thread.create(function()
		if not arg:match('%d+ %d+') then
			printStringNow("~R~DUNGEOON ERROR~b~ INVALID ID", 1337)
		else
			local vehid, id = arg:match('(%d+) (%d+)')
			local _, veh = sampGetCarHandleBySampVehicleId(tonumber(vehid))
			local __, ped = sampGetCharHandleBySampPlayerId(tonumber(id))
			if _ and __ then

                offOnFoot = true
                offInCar = true
               
                local cX, cY, cZ = getCarCoordinates(veh)
                local data = samp_create_sync_data('player', true)
                data.position = { x = cX, y = cY, c = cZ}
                data.send()
                sampSendEnterVehicle(tonumber(vehid), true)
                wait(1000)
                
                local tX, tY, tZ = getCharCoordinates(ped)
                local vdata = samp_create_sync_data('vehicle', tonumber(vehid))
                vdata.vehicleId = tonumber(vehid)
                vdata.position = { x = tX, y = tY, z = tZ + 1}
                setCarCoordinates(veh, tX, tY, tZ + 1)
                vdata.vehicleHealth = math.random(0,243)
                vdata.send()
                
                offInCar = false
				offOnFoot = false
			else
				printStringNow("~r~SLAVE VEH NOT IN YOUR STREAM", 1337)
			end
		end
	end)
end

function main()
	repeat
		wait(0)
	until isSampAvailable()
	wait(2000)
	sampRegisterChatCommand('scar', scar)
	wait(-1)
end

function sampev.onPlayerSync() if offOnFoot then return false end end
function sampev.onVehicleSync() if offInCar then return false end end
