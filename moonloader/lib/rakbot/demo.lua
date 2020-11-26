NAME = 'LUA - demo'
FINDSTR = 'админ'

function onScriptStart()
	printLog('[RAKBOT] [' .. NAME .. '] Данный скрипт показывает основы скриптинга в RakBot')
end

function onScriptExit()
	printLog('[RAKBOT] [' .. NAME .. '] Выход из скрипта')
end

function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function onDialogShow(id, style, title, btn1, btn2, data)
	printLog('[RAKBOT] [' .. NAME .. '] Показан диалог #' .. id .. ' с заголовком ' .. title)

	if id == 22 then
		if title == 'MainMenu' then
			sendDialog(22, 1, 3, '')
			return true
		elseif title == 'Информация' then
			sendDialog(22, 1, 0, '')
			return true
		elseif title == 'Статистика персонажа' then
			s = split(data, "\n")
			for key, value in pairs(s) do
				if string.len(value) > 0 then
					printLog('[RAKBOT] [' .. NAME .. '] ' .. string.gsub(value, "\t", " "))
				end
			end
			return true
		end
	end

	return false
end

function onPrintLog(msg)
	if string.match(msg, FINDSTR) then
		printLog('[RAKBOT] [' .. NAME .. '] Слово \'' .. FINDSTR .. '\' найдено')
	end
end

function onRunCommand(cmd)
	if cmd == '!luatest' then
		runCommand('/mm')
		return true
	elseif cmd == '!luagetinfo' then
		info = getBotInfo()
		s = split(info, "\n")
		for key, value in pairs(s) do
			if string.len(value) > 0 then
				printLog('[RAKBOT] [' .. NAME .. '] ' .. string.gsub(value, "\t", " "))
			end
		end
		return true
	end
end

function onSetMoney(money)
	printLog('[RAKBOT] Баланс изменен на ' .. money .. '$')
end

function onSetHealth(health)
	printLog('[RAKBOT] Здоровье изменено на ' .. health .. 'ХП')
end

function onGameInited()
	printLog('[RAKBOT] Игра инициализирована')
end

function onConnect()
	printLog('[RAKBOT] Бот подключен к серверу')
end