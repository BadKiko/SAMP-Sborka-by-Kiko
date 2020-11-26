function onSendPacket(id, data, size)
	-- printLog(id)
end

function onRecvRPC(id, data, size)
	if id == 93 then
		local bs = bitStreamInit(data, size)
		bitStreamIgnore(bs, 4)
		local size = bitStreamReadDWord(bs)
		local str = bitStreamReadString(bs, size)
		printLog(str)
		bitStreamDelete(bs)
	end
	-- printLog(id)
end

function onSendRPC(id, data, size)
	-- printLog(id)
end

function onRunCommand(cmd)
	if (string.match(cmd, 'lolkek')) then
		-- sendRPC(52, 0)
		
		local bs = bitStreamNew()
		local length = 8;
		bitStreamWriteByte(bs, length)
		bitStreamWriteString(bs, 'лолкеков', length)
		-- sendPacket(bs)
		sendRPC(101, bs)
		bitStreamDelete(bs)
		return true
	end
end

function onBotSpawn()
	-- runCommand('!badpos')
end