require "lib.sampfuncs"
require "lib.moonloader"
local events = require 'lib.samp.events'

local rv = false
local victimPed = -1

local lastX = 0
local lastY = 0
local lastZ = 0

local rvTime = 5
local rvSpeedX = 0
local rvSpeedY = 0
local rvSpeedZ = 100
local rvSpreadA = 0.5
local rvSpreadB = 0.05

local count = 0

function reset()
	rv = false
	lastX = 0
	lastY = 0
	lastZ = 0
end

function getClosestPlayerId()
	local minDist = 9999
	local closestId = -1
	local x, y, z = getCharCoordinates(PLAYER_PED)
	for i = 0, 999 do
		local streamed, pedID = sampGetCharHandleBySampPlayerId(i)
		if streamed then
			local xi, yi, zi = getCharCoordinates(pedID)
			local dist = math.sqrt( (xi - x) ^ 2 + (yi - y) ^ 2 + (zi - z) ^ 2 )
			if dist < minDist then
				minDist = dist
				closestId = i
			end
		end
	end
	return closestId
end

function main()
    while not isSampAvailable() do wait(0) end
	
	sampRegisterChatCommand("gg", function (id)
		if rv then
			reset()
			return sampAddChatMessage("LUA: Рванка выключена вручную.", 0x007FFF)
		end
		if isCharInAnyCar(PLAYER_PED) then
			return sampAddChatMessage("LUA: Вы не можете использовать этот режим, находясь в транспорте.", 0x007FFF)
		end
		if not rv and id == "" then
			id = getClosestPlayerId()
			if id == -1 then
				return sampAddChatMessage("LUA: В зоне стрима никого нет.", 0x007FFF)
			end
		end
		local f, ped = sampGetCharHandleBySampPlayerId(id)
		if f then
			local px, py, pz = getCharCoordinates(ped)
			local ax, ay, az = getCharCoordinates(PLAYER_PED)
			local dist = math.sqrt( (ax - px) ^ 2 + (ay - py) ^ 2 + (az - pz) ^ 2 )
				
			if dist > 50 then
				return sampAddChatMessage("LUA: Игрок находится слишком далеко.", 0x007FFF)
			end
				
			rv = true
			count = count + 1
			victimPed = ped
			sampAddChatMessage(	"LUA: Рванка активирована на {FFFF00}" .. rvTime .. "{007FFF} сек. за игроком {FFFF00}" ..
								sampGetPlayerNickname(id) .. "{007FFF} [ID {FFFF00}" .. id .. "{007FFF}].", 0x007FFF)
		else
			return sampAddChatMessage("LUA: Игрока с указанным ID не найдено в зоне стрима.", 0x007FFF)
		end
		local c_count = count
		lua_thread.create(function ()
			wait(rvTime * 1000)
			if rv and c_count == count then
				sampAddChatMessage("LUA: Рванка выключена автоматически.", 0x007FFF)
				reset()
			end
		end)
	end)
	
	sampRegisterChatCommand("ggset", function (params)
		local	new_rvTime = params:match("time=(%d+)")
		local	new_rvSpeedX = params:match("speed=(%d+),%d+,%d+")
		local	new_rvSpeedY = params:match("speed=%d+,(%d+),%d+")
		local	new_rvSpeedZ = params:match("speed=%d+,%d+,(%d+)")
		local	new_rvSpreadA = params:match("spread=(%d+),%d+")
		local	new_rvSpreadB = params:match("spread=%d+,(%d+)")
		
		if new_rvTime then rvTime = new_rvTime end
		
		if new_rvSpeedX then rvSpeedX = new_rvSpeedX end
		if new_rvSpeedY then rvSpeedY = new_rvSpeedY end
		if new_rvSpeedZ then rvSpeedZ = new_rvSpeedZ end
		
		if new_rvSpreadA then rvSpreadA = new_rvSpreadA / 100 end
		if new_rvSpreadB then rvSpreadB = new_rvSpreadB / 100 end
		
		local rvPlainSpeed = math.floor( math.sqrt( rvSpeedX ^ 2 + rvSpeedY ^ 2 + rvSpeedZ ^ 2 ) )
		
		sampAddChatMessage("LUA: Настройки рванки были успешно изменены на следующие:", 0x007FFF)
		sampAddChatMessage(	"LUA: Время: {FFFF00}" .. rvTime .. "{007FFF} сек. | Скорость: {FFFF00}" .. rvPlainSpeed .. " (" .. rvSpeedX ..
							" / " .. rvSpeedY .. " / " .. rvSpeedZ .. "){007FFF} | Разброс: {FFFF00}" .. rvSpreadA .. " <> " .. rvSpreadB, 0x007FFF)
	end)
	
	function events.onSendVehicleSync()
		if rv then
			reset()
			sampAddChatMessage("LUA: Вы сели в транспорт, рванка автоматически выключена.", 0x007FFF)
		end
	end
	
	function events.onSendPlayerSync(data)
		if not rv then
			return
		end
		if not doesCharExist(victimPed) then
			reset()
			return sampAddChatMessage("LUA: Игрок недоступен, рванка автоматически выключена.", 0x007FFF)
		end
		local divAtoB = rvSpreadA / rvSpreadB
		local divBtoA = rvSpreadB / rvSpreadA
		local px, py, pz = getCharCoordinates(victimPed)
		
		local ax, ay, az = getCharCoordinates(PLAYER_PED)
		
		--local dist = math.sqrt( (px - lastX) ^ 2 + (py - lastY) ^ 2 + (pz - lastZ) ^ 2 )
		local dist = math.sqrt( (ax - px) ^ 2 + (ay - py) ^ 2 + (az - pz) ^ 2 )
		if lastX ~= 0 and lastY ~= 0 and lastZ ~= 0 and dist > 50 then
			reset()
			return sampAddChatMessage("LUA: Игрок сместился слишком далеко, рванка автоматически выключена.", 0x007FFF)
		end
		
		lastX = px
		lastY = py
		lastZ = pz
		
		data.moveSpeed.x = rvSpeedX / 140
		data.moveSpeed.y = rvSpeedY / 140
		data.moveSpeed.z = rvSpeedZ / 140
		data.position.x = px + math.random(-divAtoB, divAtoB) * (divBtoA / 2)
		data.position.y = py + math.random(-divAtoB, divAtoB) * (divBtoA / 2)
		data.position.z = pz + math.random(-divAtoB, divAtoB) * (divBtoA / 2)
		--setCharCoordinates(PLAYER_PED, data.position.x, data.position.y, data.position.z)
	end
	
	while true do
		wait(100)
		if rv then sampForceOnfootSync() end
	end
	
end