function onDialogShow(id, style, title, btn1, btn2, data)
	if (string.match(getServerName(), 'Diamond Role Play')) then
		printLog('[RAKBOT] Получен диалог ' .. id)
	
		if id == 8 then
			sendDialog(id, 1, 0, '')
			return true
		end

		if id == 9 then
			sendDialog(id, 1, 0, getPassword())
			return true
		end

		if id == 582 then
			sendDialog(id, 1, 0, getPassword())
			return true
		end

		if id == 10 then
			sendDialog(id, 1, 0, getMail())
			return true
		end

		if id == 14 then
			sendDialog(id, getSex(), 0, '')
			return true
		end

		if id == 15 then
			sendDialog(id, 1, 0, '')
			return true
		end

		if id == 16 then
			sendDialog(id, 1, 3, '')
			return true
		end

		if id == 17 then
			sendDialog(id, 1, 0, 22)
			return true
		end

		if id == 18 then
			sendDialog(id, 0, 0, getReferer())
			return true
		end
	end
end

function onPrintLog(msg)
	if (string.match(msg, 'Выбрать скин')) then
		runCommand('!press S')
	end
end

function onGameInited()
	if (string.match(getServerName(), 'Diamond Role Play')) then
		printLog('[RAKBOT] Включена собственная авторегистрация')
		setOwnAutoReg(true)
	end
end