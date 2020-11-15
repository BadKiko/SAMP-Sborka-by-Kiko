script_name("POMOYKAMod")
script_author("S E V E N")

local samp = require "samp.events"
local act = false

function main()
    repeat wait(1500) until isSampAvailable()
		sendMessage("Created {464446}by{850AB9} S E V E N.")
		sendMessage("{464446}Активация - {850AB9}/pomoyka")
    sampRegisterChatCommand("pomoyka", cmd)
end

function samp.onSendUnoccupiedSync(data)
    if act then
        -- wtf ?!
        data.moveSpeed.x = math.random(-2.0, 2.0)
        data.moveSpeed.y = math.random(-2.0, 2.0)
        printStringNow("~p~PIZDA VSEMU", 100)
    end
end

function cmd()
    act = not act
    sampAddChatMessage(act and "{464446}[Pomoyka{850AB9}Mod{464446}]: {850AB9}Включена." or "{464446}[Pomoyka{850AB9}Mod{464446}]: {850AB9}Отключена", -1)
end

function sendMessage(text)
	tag = '{464446}[Pomoyka{850AB9}Mod{464446}]: {850AB9}'
	sampAddChatMessage(tag .. text, -1)
end
