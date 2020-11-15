local q = require 'lib.samp.events'

function main()
	repeat wait(1250) until isSampAvailable()
	sendMessage("Created {464446}by{850AB9} romkacaddy {464446}&{850AB9} alex_sudakov00")
	sendMessage("{464446}Уйти в инвиз - {850AB9}/invi")

	sampRegisterChatCommand('invi', function()

		Activate = not Activate

		if Activate then
			sendMessage("Инвиз включен.")
		else
			sendMessage("Инвиз выключен.")
		end
	end)
	while true do
		wait(0)
		if Activate then
			local qx, qy = convertGameScreenCoordsToWindowScreenCoords(40, 430)
			renderDrawBox(qx, qy, 3, 3, 0xFFFF0000)
		end
	end
end

function q.onSendPlayerSync(data)
	if Activate then data.surfingVehicleId = 2001 end
end

function sendMessage(text)
	tag = '{464446}[In{850AB9}Vi{464446}]: {850AB9}'
	sampAddChatMessage(tag .. text, -1)
end
