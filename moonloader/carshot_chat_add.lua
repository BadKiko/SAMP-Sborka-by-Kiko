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

	wait(800)
	sendMessage("Created {464446}by{850AB9} 00DD00 {464446}&{850AB9} NN-NoName")
	sendMessage("Chat Add {464446}by{850AB9} Kiko")
	sendMessage("{464446}Активация - {850AB9}/cs в машине")
end


function sendMessage(text)
	tag = '{464446}[Car{850AB9}Shoot{464446}]: {850AB9}'
	sampAddChatMessage(tag .. text, -1)
end
