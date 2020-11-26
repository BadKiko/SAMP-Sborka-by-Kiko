local event = require('lib.samp.events')
local vk = require('vkeys')

local state = false
local step = 0.1
local visota = 2.3

function main()
	repeat wait(0) until isSampAvailable()
	wait(2000)
	sampRegisterChatCommand('knock', knock)
	sampAddChatMessage('{FF5656}[Knockdown]: {FFFFFF}Загружен!', -1)
	sampAddChatMessage('{FF5656}[Knockdown]: {FFFFFF}Автор: {FF5656}MrCreepTon', -1)
	sampAddChatMessage('{FF5656}[Knockdown]: {FFFFFF}Группа ВК: {FF5656}vk.com/hackmysamp', -1)
	while true do
		wait(0)
	end
end

function knock(param)
	if state then
		sampAddChatMessage('{FF5656}[Knockdown]: {FFFFFF}Пожалуйста, подождите, когда скрипт закончит работу!', -1)
	elseif param:match('%d+ %d+') then
		local carid, targetid = param:match('(%d+) (%d+)')
		carid, targetid = tonumber(carid), tonumber(targetid)
		local _, veh = sampGetCarHandleBySampVehicleId(carid)
		if not _ then
			sampAddChatMessage('{FF5656}[Knockdown]: {FFFFFF}Указанного авто нет в зоне стрима!', -1)
		else
			local _, ped = sampGetCharHandleBySampPlayerId(targetid)
			if not _ then
				sampAddChatMessage('{FF5656}[Knockdown]: {FFFFFF}Указанного игрока нет в зоне стрима!', -1)
			else
				lua_thread.create(function()
					state = true
					sampAddChatMessage('{FF5656}[Knockdown]: {FFFFFF}Процесс начат...', -1)
					local data = samp_create_sync_data('player')
					data.health = getCharHealth(PLAYER_PED)
					data.armor = getCharArmour(PLAYER_PED)
					data.position.x, data.position.y, data.position.z = getCharCoordinates(PLAYER_PED)
					data.keys.enterExitCar = 1
					data.specialAction = 3
					data.send()
					sampSendEnterVehicle(carid, true)
					wait(1500)
					local _, veh = sampGetCarHandleBySampVehicleId(carid)
					if not _ then
						state = false
						sampAddChatMessage('{FF5656}[Knockdown]: {FFFFFF}Авто пропало из зоны стрима!', -1)
					else
						local _, ped = sampGetCharHandleBySampPlayerId(targetid)
						if not _ then
							state = false
							sampAddChatMessage('{FF5656}[Knockdown]: {FFFFFF}Игрок пропал из зоны стрима!', -1)
						else
							local mx, my, mz = getCharCoordinates(PLAYER_PED)
							local tx, ty, tz = getCharCoordinates(ped)
							local dist = getDistanceBetweenCoords3d(mx, my, mz, tx, ty, tz)
							while dist > 2 do
								if mx > tx then
									mx = mx - step
								else
									mx = mx + step
								end
								if my > ty then
									my = my - step
								else
									my = my + step
								end
								if mz > tz then
									mz = mz - step
								else
									mz = mz + step
								end
								local data = samp_create_sync_data('player')
								data.health = getCharHealth(PLAYER_PED)
								data.armor = getCharArmour(PLAYER_PED)
								data.position.x, data.position.y, data.position.z = mx, my, mz
								data.send()
								tx, ty, tz = getCharCoordinates(ped)
								dist = getDistanceBetweenCoords3d(mx, my, mz, tx, ty, tz)
							end
							local data = samp_create_sync_data('player')
							data.health = getCharHealth(PLAYER_PED)
							data.armor = getCharArmour(PLAYER_PED)
							data.position.x, data.position.y, data.position.z = tx, ty, tz
							data.send()
							wait(100)
							for i = 1, 5 do
								local _, ped = sampGetCharHandleBySampPlayerId(targetid)
								if _ then
									tx, ty, tz = getCharCoordinates(ped)
								end
								setCarCoordinates(veh, tx, ty, tz)
								for i = 1, 5 do
									sampForceVehicleSync(carid)
									wait(100)
								end
							end
							local driver = getDriverOfCar(veh)
							if driver ~= -1 then
								mx, my, mz = getCharCoordinates(PLAYER_PED)
								tx, ty, tz = getCharCoordinates(ped)
								local dist = getDistanceBetweenCoords3d(mx, my, mz, tx, ty, tz)
								while dist > 2 do
									if tx > mx then
										tx = tx - step
									else
										tx = tx + step
									end
									if ty > my then
										ty = ty - step
									else
										ty = ty + step
									end
									if tz > mz then
										tz = tz - step
									else
										tz = tz + step
									end
									local data = samp_create_sync_data('player')
									data.health = getCharHealth(PLAYER_PED)
									data.armor = getCharArmour(PLAYER_PED)
									data.position.x, data.position.y, data.position.z = tx, ty, tz
									data.send()
									mx, my, mz = getCharCoordinates(PLAYER_PED)
									dist = getDistanceBetweenCoords3d(mx, my, mz, tx, ty, tz)
								end
								local data = samp_create_sync_data('player')
								data.health = getCharHealth(PLAYER_PED)
								data.armor = getCharArmour(PLAYER_PED)
								data.position.x, data.position.y, data.position.z = mx, my, mz
								data.send()
								wait(100)
								state = false
								sampAddChatMessage('{FF5656}[Knockdown]: {FFFFFF}У водителя стоит AntiEject, скрипт выключен!', -1)
								sampAddChatMessage('{FF5656}[Knockdown]: {FFFFFF}(Попробуйте использовать авто без водителя)', -1)
							else
								wait(500)
								for i = 1, 5 do
									local _, ped = sampGetCharHandleBySampPlayerId(targetid)
									if not _ then
										break
									else
										tx, ty, tz = getCharCoordinates(ped)
										for i = 0.5, -0.5, step do
											setCarCoordinates(veh, tx, ty, tz - i)
											sampForceVehicleSync(carid)
											wait(2)
										end
										setCarHealth(veh, 0)
										setCarRotationVelocity(veh, 50, 70, 10)
										--sampForceVehicleSync(carid)
										--wait(50)
										--setCarForwardSpeed(veh, 50)
										for i = 1, 5 do
											sampForceVehicleSync(carid)
											wait(10)
										end
									end
								end
								local _, ped = sampGetCharHandleBySampPlayerId(targetid)
								if _ then
									tx, ty, tz = getCharCoordinates(ped)
								end
								mx, my, mz = getCharCoordinates(PLAYER_PED)
								local dist = getDistanceBetweenCoords3d(tx, ty, tz, mx, my, mz)
								while dist > 2 do
									if tx > mx then
										tx = tx - step
									else
										tx = tx + step
									end
									if ty > my then
										ty = ty - step
									else
										ty = ty + step
									end
									if tz > mz then
										tz = tz - step
									else
										tz = tz + step
									end
									local data = samp_create_sync_data('player')
									data.health = getCharHealth(PLAYER_PED)
									data.armor = getCharArmour(PLAYER_PED)
									data.position.x, data.position.y, data.position.z = tx, ty, tz
									data.send()
									mx, my, mz = getCharCoordinates(PLAYER_PED)
									dist = getDistanceBetweenCoords3d(mx, my, mz, tx, ty, tz)
								end
								local data = samp_create_sync_data('player')
								data.health = getCharHealth(PLAYER_PED)
								data.armor = getCharArmour(PLAYER_PED)
								data.position.x, data.position.y, data.position.z = mx, my, mz
								data.send()
								wait(300)
								state = false
								sampForceOnfootSync()
								sampAddChatMessage('{FF5656}[Knockdown]: {FFFFFF}Авто успешно сделало пару сальтух!', -1)
							end
						end
					end
				end)
			end
		end
	elseif param:match('%d+') then
		local carid = param:match('(%d+)')
		carid = tonumber(carid)
		local _, veh = sampGetCarHandleBySampVehicleId(carid)
		if not _ then
			sampAddChatMessage('{FF5656}[Knockdown]: {FFFFFF}Указанного авто нет в зоне стрима!', -1)
		else
			lua_thread.create(function()
				state = true
				sampAddChatMessage('{FF5656}[Knockdown]: {FFFFFF}Процесс начат...', -1)
				local data = samp_create_sync_data('player')
				data.health = getCharHealth(PLAYER_PED)
				data.armor = getCharArmour(PLAYER_PED)
				data.position.x, data.position.y, data.position.z = getCharCoordinates(PLAYER_PED)
				data.keys.enterExitCar = 1
				data.specialAction = 3
				data.send()
				sampSendEnterVehicle(carid, true)
				wait(1500)
				local _, veh = sampGetCarHandleBySampVehicleId(carid)
				if not _ then
					state = false
					sampAddChatMessage('{FF5656}[Knockdown]: {FFFFFF}Авто пропало из зоны стрима!', -1)
				else
					local mx, my, mz = getCharCoordinates(PLAYER_PED)
					local cx, cy, cz = getCarCoordinates(veh)
					local dist = getDistanceBetweenCoords3d(mx, my, mz, cx, cy, cz)
					while dist > 2 do
						if mx > cx then
							mx = mx - step
						else
							mx = mx + step
						end
						if my > cy then
							my = my - step
						else
							my = my + step
						end
						if mz > cz then
							mz = mz - step
						else
							mz = mz + step
						end
						local data = samp_create_sync_data('player')
						data.health = getCharHealth(PLAYER_PED)
						data.armor = getCharArmour(PLAYER_PED)
						data.position.x, data.position.y, data.position.z = mx, my, mz
						data.send()
						cx, cy, cz = getCarCoordinates(veh)
						dist = getDistanceBetweenCoords3d(mx, my, mz, cx, cy, cz)
					end
					local data = samp_create_sync_data('player')
					data.health = getCharHealth(PLAYER_PED)
					data.armor = getCharArmour(PLAYER_PED)
					data.position.x, data.position.y, data.position.z = cx, cy, cz
					data.send()
					wait(100)
					local driver = getDriverOfCar(veh)
					for i = 1, 10 do
						sampForceVehicleSync(carid)
						wait(100)
					end
					local driver2 = getDriverOfCar(veh)
					if driver2 ~= -1 then
						mx, my, mz = getCharCoordinates(PLAYER_PED)
						cx, cy, cz = getCarCoordinates(veh)
						local dist = getDistanceBetweenCoords3d(mx, my, mz, cx, cy, cz)
						while dist > 2 do
							if cx > mx then
								cx = cx - step
							else
								cx = cx + step
							end
							if cy > my then
								cy = cy - step
							else
								cy = cy + step
							end
							if cz > mz then
								cz = cz - step
							else
								cz = cz + step
							end
							local data = samp_create_sync_data('player')
							data.health = getCharHealth(PLAYER_PED)
							data.armor = getCharArmour(PLAYER_PED)
							data.position.x, data.position.y, data.position.z = cx, cy, cz
							data.send()
							mx, my, mz = getCharCoordinates(PLAYER_PED)
							dist = getDistanceBetweenCoords3d(mx, my, mz, cx, cy, cz)
						end
						local data = samp_create_sync_data('player')
						data.health = getCharHealth(PLAYER_PED)
						data.armor = getCharArmour(PLAYER_PED)
						data.position.x, data.position.y, data.position.z = mx, my, mz
						data.send()
						wait(100)
						state = false
						sampAddChatMessage('{FF5656}[Knockdown]: {FFFFFF}У водителя стоит AntiEject, скрипт выключен!', -1)
					else
						wait(500)
						local dx, dy, dz = 0, 0, 0
						for i = 1, 5 do
							if driver ~= -1 then
								dx, dy, dz = getCharCoordinates(driver)
							else
								dx, dy, dz = getCarCoordinates(veh)
							end
							for i = 0.5, -0.5, step do
								setCarCoordinates(veh, dx, dy, dz - i)
								sampForceVehicleSync(carid)
								wait(2)
							end
							setCarHealth(veh, 0)
							setCarRotationVelocity(veh, 50, 70, 10)
							--sampForceVehicleSync(carid)
							--wait(50)
							--setCarForwardSpeed(veh, 50)
							for i = 1, 5 do
								sampForceVehicleSync(carid)
								wait(10)
							end
							wait(300)
						end
						mx, my, mz = getCharCoordinates(PLAYER_PED)
						local dist = getDistanceBetweenCoords3d(mx, my, mz, dx, dy, dz)
						while dist > 2 do
							if dx > mx then
								dx = dx - step
							else
								dx = dx + step
							end
							if dy > my then
								dy = dy - step
							else
								dy = dy + step
							end
							if dz > mz then
								dz = dz - step
							else
								dz = dz + step
							end
							local data = samp_create_sync_data('player')
							data.health = getCharHealth(PLAYER_PED)
							data.armor = getCharArmour(PLAYER_PED)
							data.position.x, data.position.y, data.position.z = dx, dy, dz
							data.send()
							mx, my, mz = getCharCoordinates(PLAYER_PED)
							dist = getDistanceBetweenCoords3d(mx, my, mz, dx, dy, dz)
						end
						local data = samp_create_sync_data('player')
						data.health = getCharHealth(PLAYER_PED)
						data.armor = getCharArmour(PLAYER_PED)
						data.position.x, data.position.y, data.position.z = mx, my, mz
						data.send()
						wait(500)
						state = false
						sampForceOnfootSync()
						sampAddChatMessage('{FF5656}[Knockdown]: {FFFFFF}Авто сделало пару сальтух!', -1)
					end
				end
			end)
		end
	else
		sampAddChatMessage('{FF5656}[Knockdown]: {FFFFFF}-----------------------------------------', -1)
		sampAddChatMessage('{FF5656}[Knockdown]: {FFFFFF}Используйте:', -1)
		sampAddChatMessage('{FF5656}[Knockdown]: {FFFFFF}1) {FF5656}/knock [VehicleID] [PlayerID]', -1)
		sampAddChatMessage('{FF5656}[Knockdown]: {FFFFFF}2) {FF5656}/knock [VehicleID]', -1)
		sampAddChatMessage('{FF5656}[Knockdown]: {FFFFFF}-----------------------------------------', -1)
	end
end

function event.onSendPlayerSync(data)
	if state then
		return false
	end
end

function event.onSendVehicleSync(data)
	if state then
		data.moveSpeed.z = -1
	end
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
