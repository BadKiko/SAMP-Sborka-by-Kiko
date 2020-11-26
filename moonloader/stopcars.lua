local state = false
local isCar = false

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then
		return
	end
	while not isSampAvailable() do wait(100) end

	sampRegisterChatCommand("stopcars", function() state = not state if state then sampAddChatMessage("{464446}Включен", 0x778899, -1) else sampAddChatMessage("{464446}Выключен", 0x778899, -1) end end)

	while true do wait(0)
		if state then
			for carid = 0, 1000	do
				local result, car = sampGetCarHandleBySampVehicleId(carid)
				if result then
					if getDriverOfCar(car) ~= -1 then
						if not isCharInAnyCar(PLAYER_PED) then
							if not isCar then
								sampSendEnterVehicle(carid, false)
								wait(150)
							end
						else
							if isCar then
								isCar = false
							end
						end
					end
				end
			end
		end
	end
end

function onSendRpc(id, bitStream, priority, reliability, orderingChannel, shiftTs)
	if state then
		isCar = false
		if id == 26 then
			isCar = true
		end
	end
end

function sendMessage(text)
	tag = '{464446}[Stop{850AB9}Car{464446}]: {850AB9}'
	sampAddChatMessage(tag .. text, -1)
end