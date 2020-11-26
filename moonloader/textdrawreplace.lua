script_name("CSChatAdd")
script_version("0.0.1")
script_author("Kiko")

local sampev = require("lib.samp.events")
local imgui = require("imgui")
local encoding = require("encoding")
local sw, sh = getScreenResolution()

encoding.default = "CP1251"
u8 = encoding.UTF8

function main()

	repeat wait(0) until isSampLoaded() and isSampAvailable()

	wait(2000)
	text = sampTextdrawGetString(0)

	if text:find('HackMySoft') then
		sampTextdrawSetString(0, 'GachiMuchiServer')
	end
end


function sendMessage(text)
	tag = '{464446}[Car{850AB9}Shoot{464446}]: {850AB9}'
	sampAddChatMessage(tag .. text, -1)
end
