local event = require('lib.samp.events')

local dissync = false
local state = false

function main()
	repeat wait(0) until isSampAvailable()
	sampRegisterChatCommand('bp', resp)
	sampRegisterChatCommand('bp2', bp)
end

function bp()
	state = not state
	if state then
		sampAddChatMessage('включен', -1)
	else
		sampAddChatMessage('выключен', -1)
	end
end

function resp()
	lua_thread.create(function()
		dissync = true
		local x, y, z = getCharCoordinates(PLAYER_PED)
		local bs = raknetNewBitStream()
		raknetBitStreamWriteBool(bs, false)
		raknetEmulRpcReceiveBitStream(124, bs)
		raknetDeleteBitStream(bs)
		printStringNow('~y~1', 1000)
		wait(1000)
		for i = 1, 5 do
			sampSpawnPlayer()
			wait(10)
		end
		wait(50)
		setCharCoordinates(PLAYER_PED, x, y, z)
		freezeCharPosition(PLAYER_PED, true)
		restoreCameraJumpcut()
		printStringNow('~r~2', 1000)
		wait(1000)
		dissync = false
		enableDialog(false)
		freezeCharPosition(PLAYER_PED, false)
		printStringNow('~g~bypassed', 1000)
	end)
end

 function onReceiveRpc(id, bitStream)
	if dissync and id == 124 then return false end
end

function event.onSendSpawn()
	if dissync then
		return false
	end
end

function event.onSendRequestSpawn()
	if dissync then
		return false
	end
end

function event.onSendDeathNotification()
	if dissync then
		return false
	end
end

function event.onSendPlayerSync(data)
	if dissync then
		return false
	end
	if state then
		data.keysData = 0
		data.keys.specialCtrlUp = 0
		data.keys.specialCtrlDown = 0
		data.keys.specialCtrlLeft = 0
		data.keys.specialCtrlRight = 0
	end
end

function event.onSendVehicleSync(data)
	if state then
		data.keysData = 0
		data.keys.specialCtrlUp = 0
		data.keys.specialCtrlDown = 0
		data.keys.specialCtrlLeft = 0
		data.keys.specialCtrlRight = 0
	end
end

function event.onSendPassengerSync(data)
	if state then
		data.keysData = 0
		data.keys.specialCtrlUp = 0
		data.keys.specialCtrlDown = 0
		data.keys.specialCtrlLeft = 0
		data.keys.specialCtrlRight = 0
	end
end

function event.onSetPlayerHealth()
	if state then return false end
end

function enableDialog(bool)
    local memory = require 'memory'
    memory.setint32(sampGetDialogInfoPtr()+40, bool and 1 or 0, true)
    sampToggleCursor(bool)
end
