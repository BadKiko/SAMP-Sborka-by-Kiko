script_author("Royan_Millans")
require 'lib.moonloader'
local sampevcheck, sampev = pcall(require, "lib.samp.events")

function main()
	if sampevcheck == false then
		print("Внимание, отсутствует библиотека SAMP.lua, скрипт завершил работу.", -1)
		print("Скачать её можно в гугле, нужно закинуть в папку moonloader/lib", -1)
		thisScript():unload()
	end
	if not isSampfuncsLoaded() or not isSampLoaded() then return end
	while not isSampAvailable() do
		wait(0)
	end
	while true do
		wait(0)
	end
end

function comma_value(n)
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

function separator(text)
	if text:find("$") then
	    for S in string.gmatch(text, "%$%d+") do
	    	local replace = comma_value(S)
	    	text = string.gsub(text, S, replace)
	    end
	    for S in string.gmatch(text, "%d+%$") do
	    	S = string.sub(S, 0, #S-1)
	    	local replace = comma_value(S)
	    	text = string.gsub(text, S, replace)
	    end
	end
	return text
end

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
	text = separator(text)
	title = separator(title)
	return {dialogId, style, title, button1, button2, text}
end

function sampev.onServerMessage(color, text)
	text = separator(text)
	return {color, text}
end

function sampev.onCreate3DText(id, color, position, distance, testLOS, attachedPlayerId, attachedVehicleId, text)
	text = separator(text)
	return {id, color, position, distance, testLOS, attachedPlayerId, attachedVehicleId, text}
end

function sampev.onTextDrawSetString(id, text)
	text = separator(text)
	return {id, text}
end