local ev = require('lib.samp.events')

local state = true

function main()
	wait(550)
	sendMessage("Created {464446}by {850AB9}MrCreepTon")
	sendMessage("Chat Added {464446}by {850AB9}Kiko")
	sendMessage("Âêëþ÷èòü/Îòêëþ÷èòü ÀíòèÐâàíêó - /antirv")

	sampRegisterChatCommand('antirv', function()
		state = not state
		if state then return sendMessage('AntiRvanka: {464446}Âêëþ÷åíà.', -1) end
		return sendMessage('AntiRvanka: {464446}Îòêëþ÷åíà.', -1)
	end)
	wait(-1)
end

function ev.onPlayerSync(id, data)
	if state then
		local x, y, z = getCharCoordinates(PLAYER_PED)
		if x - data.position.x > -1.5 and x - data.position.x < 1.5 then
			if (data.moveSpeed.x >= 1.5 or data.moveSpeed.x <= -1.5) or (data.moveSpeed.y >= 1.5 or data.moveSpeed.y <= -1.5) or (data.moveSpeed.z >= 0.5 or data.moveSpeed.z <= -0.5) then
				data.moveSpeed.x, data.moveSpeed.y, data.moveSpeed.z = 0, 0, 0
			end
		end
	end
	return {id, data}
end

function ev.onVehicleSync(id, vehid, data)
	if state then
		local x, y, z = getCharCoordinates(PLAYER_PED)
		if x - data.position.x > -1.5 and x - data.position.x < 1.5 then
			if (data.moveSpeed.x >= 1.5 or data.moveSpeed.x <= -1.5) or (data.moveSpeed.y >= 1.5 or data.moveSpeed.y <= -1.5) or (data.moveSpeed.z >= 0.5 or data.moveSpeed.z <= -0.5) then
				data.moveSpeed.x, data.moveSpeed.y, data.moveSpeed.z = 0, 0, 0
				data.position.x = data.position.x - 5
			end
		end
	end
	return {id, vehid, data}
end

--ÐµÐ±Ð°Ð» Ñ…ÑƒÐ¹Ð½ÑŽ Ð½Ð¸Ð¶Ðµ Ð² Ñ€Ð¾Ñ‚
-- function ev.onUnoccupiedSync(id, data)
-- 	if state then
-- 		local x, y, z = getCharCoordinates(PLAYER_PED)
-- 		if x - data.position.x > -1.5 and x - data.position.x < 1.5 then
-- 			if (data.moveSpeed.x >= 1.5 or data.moveSpeed.x <= -1.5) or (data.moveSpeed.y >= 1.5 or data.moveSpeed.y <= -1.5) or (data.moveSpeed.z >= 1.5 or data.moveSpeed.z <= -1.5) then
-- 				data.moveSpeed.x, data.moveSpeed.y, data.moveSpeed.z = 1, 1, 0
-- 				data.position.x = data.position.x - 5
-- 			end
-- 		end
-- 	end
-- 	return {tonumber(id), tonumber(data)}
-- end


function sendMessage(text)
	tag = '{464446}[Anti{850AB9}Rvanka{464446}]: {850AB9}'
	sampAddChatMessage(tag .. text, -1)
end
