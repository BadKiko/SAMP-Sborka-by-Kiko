script_name("VCrashModify")
script_version("0.0.1")
script_author("Kiko")

require "lib.moonloader"

local sampev = require("lib.samp.events")

local keys = require("vkeys")

local inicfg = require("inicfg")
local encoding = require("encoding")
local sw, sh = getScreenResolution()

encoding.default = "CP1251"
u8 = encoding.UTF8

local tpMethod = false -- false кордмастер, true - обычный тп
local playersInStream = {}
local ignoreChat = false
local isTP = false
local isWork = false
local mainID

function main()

	repeat wait(0) until isSampLoaded() and isSampAvailable()

	wait(55)
	sendMessage("{850AB9}Модифицировано{464446} by {850AB9}Kiko")
	sendMessage("[{464446} LSHIFT + Z {850AB9}] - Активация модификации.")
	sendMessage("[{464446} LSHIFT + X {850AB9}] - Сменить тип телепорта.")


	while true do
		wait(0)

		oldStr = ''
		--в бесконечном цикле
		str = select(1, sampGetChatString(99)) --получаем последнюю строку из чата
		if str ~= oldStr then --делаем проверку на то изменилась ли строка
			oldStr = str -- если изменилась то присваиваем новое значение

			if isWork then
				local __, ids = sampGetPlayerIdByCharHandle(playerPed)
				if oldStr:find("Готово") and not oldStr:find(ids) then
					isTP = true
					teleport()
					isWork = false
				end
			end
		end


		if isKeyJustPressed(90) and isKeyJustPressed(16) then
			--получение игроков
			sampAddChatMessage(" ")
			sampAddChatMessage("{850AB9}Выберите игрока {464446}(CTRL +0 для отмены)    ")
			sampAddChatMessage("{464446}---------------------------------")
			getStreamPlayers()
			sampAddChatMessage("{464446}---------------------------------")
			sampProcessChatInput("/pagesize 40")
			--включение игнорирования чата
			ignoreChat = true
		end


		if isKeyJustPressed(88) and isKeyJustPressed(16) then --shift + Z
			tpMethod = not tpMethod

			if tpMethod then
				sendMessage("Обычный телепорт. Самый быстрый способ, обычно кикает.")
			else
				sendMessage("Корд-мастер. Телепортирует шагами, медленный способ, меньше шанс кика.")
			end
		end



		if ignoreChat then

			if isKeyJustPressed(48) and isKeyJustPressed(17) then --ctrl + 0
				sendMessage("Отменено")
				sampProcessChatInput("/pagesize 15")

				ignoreChat = false
			end
		end

	end
end


function sendMessage(text)
	tag = '{464446}[VCrash{850AB9}Modify{464446}]: {850AB9}'
	sampAddChatMessage(tag .. text, -1)
end

function getStreamPlayers()
	for k, v in ipairs(getAllChars()) do
		local __, ids = sampGetPlayerIdByCharHandle(playerPed)
		local res, id = sampGetPlayerIdByCharHandle(v)
		if id == ids then
		else
			if res then
				playersInStream[id] = id
				sendMessage(sampGetPlayerNickname(id).." | ID: "..playersInStream[id])
				--sampAddChatMessage(sampGetPlayerNickname(id), -1)
				--sampAddChatMessage(playersInStream[i])
			end
		end
	end
end


function sampev.onSendChat(text)-- при отправке номера игрока
	if ignoreChat then
		if text == "0" then
			sendMessage("Отменено")
			ignoreChat = false
			sampProcessChatInput("/pagesize 15")

			return false
		else
			mainID = playersInStream[tonumber(text)] --перевод из стринг в инт)

			--ПРОДОЛЖЕНИЕ 43 СТРОКИ
			--Активация чита
			sampProcessChatInput("/pagesize 15")

			sampProcessChatInput("/vcrash "..mainID)
			isWork = true

			ignoreChat = false
			return false
		end
	end
end

function teleport()
	lua_thread.create(function()


		local firstTP = false

		wait(0)

		if tpMethod == false then
			oldposX, oldposY, oldposZ = getCharCoordinates(playerPed)
			if firstTP then
				oldX = oldposX - 500						---------------------------    РАССТОЯНИЕ В СТРИМ
			else
				oldX = oldposX + 500            ------------------- РАССТОЯНИЕ ВПЕРЕД ИЗ СТРИМА
			end

			while isTP do
				wait(0)



				wait(300)-------------------------------------------------ОЖИДАНИЕ СЛЕДУЮЩЕГО "ПРЫЖКА"


				positionX,  positionY,  positionZ = getCharCoordinates(playerPed)




				positionX = positionX + 35        -----------------------РАССТОЯНИЕ ШАГА ПО ШИРИНЕ
				positionZ = positionZ -  1.25				-----------------------РАССТОЯНИЕ ШАГА ВВЕРХ




				setCharCoordinates(playerPed, positionX, positionY, positionZ)

				if positionX >= oldX then
					isTP = false
					firstTP = true
				end
			end

			while firstTP do
				wait(0)
				wait(300)-------------------------------------------------ОЖИДАНИЕ СЛЕДУЮЩЕГО "ПРЫЖКА"

				positionX,  positionY,  positionZ = getCharCoordinates(playerPed)


				positionX = positionX - 35-----------------------РАССТОЯНИЕ ШАГА ПО ШИРИНЕ (В ОБРАТКУ)
				positionZ = positionZ + 1.75-----------------------РАССТОЯНИЕ ШАГА ВВЕРХ (В ОБРАТКУ)

				setCharCoordinates(playerPed, positionX, positionY, positionZ)

				if positionX <= oldX - 500 then  ---------------------------    -500 ЭТО РАССТОЯНИЕ В СТРИМ
					firstTP = false
					sendMessage("Конец телепорта. VCrashMod закончил работу!")
				end
			end

		else
			posX, posY, posZ = getCharCoordinates(playerPed)
			setCharCoordinates(playerPed, posX + 500, posY, posZ + 500)
			wait(500)
			setCharCoordinates(playerPed, posX, posY, posZ)
			isTP = false

		end
	end)
end
