local ev = require('lib.samp.events')
local imgui = require('imgui')
local vk = require('vkeys')

local encoding = require('encoding')
encoding.default = 'CP1251'
local u8 = encoding.UTF8

local state = imgui.ImBool(false)
local otos = imgui.ImBool(false)
local gamestates = {'None', 'Wait Connect', 'Await Join', 'Connected', 'Restarting', 'Disconnected'}
local gamestate = imgui.ImInt(0)
local server = {
	ip = '95.216.6.122',
	port = 7228,
	cur = {
		ip = '',
		port = 0
	}
}
local nops = {
	spectator = imgui.ImBool(false),
	health = imgui.ImBool(false),
	givegun = imgui.ImBool(false),
	resetgun = imgui.ImBool(false),
	setgun = imgui.ImBool(false),
	spawn = imgui.ImBool(false),
	death = imgui.ImBool(false),
	psync = imgui.ImBool(false),
	requestclass = imgui.ImBool(false),
	requestspawn = imgui.ImBool(false),
	applyanimation = imgui.ImBool(false),
	clearanimation = imgui.ImBool(false),
	showdialog = imgui.ImBool(false),
	clicktextdraw = imgui.ImBool(false),
	selecttextdraw = imgui.ImBool(false),
	forceclass = imgui.ImBool(false),
	facingangle = imgui.ImBool(false),
	togglecontrol = imgui.ImBool(false)
}
local send = {
	requestclass = imgui.ImInt(0),
	sendpickup = imgui.ImInt(1)
}
local weapon = imgui.ImInt(1)
local weapons = {
	[0] = '##',
	[1] = 'Brass Knuckles',
	[2] = 'Golf Club',
	[3] = 'Nightstick',
	[4] = 'Knife',
	[5] = 'Baseball Bat	',
	[6] = 'Shovel',
	[7] = 'Pool Cue',
	[8] = 'Katana',
	[9] = 'Chainsaw',
	[10] = 'Purple Dildo',
	[11] = 'Dildo',
	[12] = 'Vibrator',
	[13] = 'Silver Vibrator',
	[14] = 'Flowers',
	[15] = 'Cane',
	[16] = 'Grenade',
	[17] = 'Tear Gas',
	[18] = 'Molotov Cocktail',
	[19] = '##',
	[20] = '##',
	[21] = '##',
	[22] = 'Pistol',
	[23] = 'Silent Pistol',
	[24] = 'Desert Eagle',
	[25] = 'Shotgun',
	[26] = 'Sawnoff Shotgun',
	[27] = 'Combat Shotgun',
	[28] = 'Micro SMG/Uzi',
	[29] = 'MP5',
	[30] = 'AK-47',
	[31] = 'M4',
	[32] = 'Tec-9',
	[33] = 'Contry Riffle',
	[34] = 'Sniper Riffle',
	[35] = 'RPG',
	[36] = 'HS Rocket',
	[37] = 'Flame Thrower',
	[38] = 'Minigun',
	[39] = 'Satchel charge',
	[40] = 'Detonator',
	[41] = 'Spraycan',
	[42] = 'Fire Extiguisher',
	[43] = 'Camera',
	[44] = 'Nigh Vision Goggles',
	[45] = 'Thermal Goggles',
	[46] = 'Parachute'
}

function imgui.OnDrawFrame()
	if state.v then
		local xw, yw = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(xw / 2 - 200, yw / 2), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowSize(imgui.ImVec2(1000, 360), imgui.Cond.FirstUseEver)
		imgui.Begin(u8'Bypasser', state, imgui.WindowFlags.NoResize)
		imgui.Text(u8'                                                       Нопы:                                                                                                                        Отправка:')
		imgui.BeginChild('##nops', imgui.ImVec2(490, 150), true)
		imgui.Checkbox(u8'TogglePlayerSpectating', nops.spectator)
		imgui.SameLine()
		imgui.Checkbox(u8'SetPlayerHealth ', nops.health)
		imgui.SameLine()
		imgui.Checkbox(u8'GivePlayerWeapon', nops.givegun)
		imgui.Checkbox(u8'ResetPlayerWeapons    ', nops.resetgun)
		imgui.SameLine()
		imgui.Checkbox(u8'ShowDialog         ', nops.showdialog)
		imgui.SameLine()
		imgui.Checkbox(u8'ApplyAnimation', nops.applyanimation)
		imgui.Checkbox(u8'ClearAnimation            ', nops.clearanimation)
		imgui.SameLine()
		imgui.Checkbox(u8'SetArmedWeapon', nops.setgun)
		imgui.SameLine()
		imgui.Checkbox(u8'Spawn', nops.spawn)
		imgui.Checkbox(u8'Death                           ', nops.death)
		imgui.SameLine()
		imgui.Checkbox(u8'Player Sync         ', nops.psync)
		imgui.SameLine()
		imgui.Checkbox(u8'RequestClass', nops.requestclass)
		imgui.Checkbox(u8'RequestSpawn', nops.requestspawn)
		imgui.SameLine()
		imgui.Checkbox(u8'ClickTextdraw', nops.clicktextdraw)
		imgui.SameLine()
		imgui.Checkbox(u8'SelectTextdraw', nops.selecttextdraw)
		imgui.SameLine()
		imgui.Checkbox(u8'ForceClassSelection', nops.forceclass)
		imgui.Checkbox(u8'ToggleControllable', nops.togglecontrol)
		imgui.SameLine()
		imgui.Checkbox(u8'FacingAngle', nops.facingangle)
		imgui.EndChild()
		imgui.SameLine()
		imgui.BeginChild(u8'##send', imgui.ImVec2(490, 150), true)
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'##requestclass', send.requestclass, 0, 0)
		imgui.SameLine()
		if imgui.Button(u8'Send RequestClass') then
			sampRequestClass(send.requestclass.v)
		end
		imgui.InputInt(u8'##sendpickup', send.sendpickup, 0, 0)
		imgui.SameLine()
		if imgui.Button(u8'Send Pickup') then
			sampRequestClass(send.sendpickup.v)
		end
		if imgui.Button(u8'Request Spawn') then
			sampSendRequestSpawn()
		end
		imgui.Text(u8'Ваш текущий Gamestate: '..gamestates[sampGetGamestate() + 1])
		imgui.PushItemWidth(200)
		imgui.Combo(u8'Gamestates', gamestate, gamestates)
		imgui.SameLine()
		if imgui.Button(u8'Сменить') then
			sampSetGamestate(gamestate.v)
		end
		imgui.Checkbox(u8'Onfoot Sync -> Spectator Sync', otos)
		imgui.EndChild()
		imgui.Text(u8'                                                                                          ')
		imgui.SameLine()
		if imgui.Button(u8'Выйти из спектатора', imgui.ImVec2(300, 20)) then
			emul_rpc('onTogglePlayerSpectating', {false})
		end
		imgui.Text(u8'                                                                                          ')
		imgui.SameLine()
		if imgui.Button(u8'Заспавниться', imgui.ImVec2(300, 20)) then
			sampSpawnPlayer()
			restoreCameraJumpcut()
		end
		imgui.Text(u8'                                                                                          ')
		imgui.SameLine()
		if imgui.Button(u8'Заспавниться (Эмуляция)', imgui.ImVec2(300, 20)) then
			emul_rpc('onRequestSpawnResponse', {true})
			emul_rpc('onSetSpawnInfo', {0, 74, 0, {0, 0, 0}, 0, {0}, {0}})
			restoreCameraJumpcut()
		end
		imgui.Text(u8'                                                                 ')
		imgui.SameLine()
		if imgui.Button(u8'Скрыть диалог', imgui.ImVec2(240, 20)) then
			enableDialog(false)
		end
		imgui.SameLine()
		if imgui.Button(u8'Показать диалог', imgui.ImVec2(240, 20)) then
			enableDialog(true)
		end
		imgui.Separator()
		imgui.Text(u8'                                                                           ')
		imgui.SameLine()
		imgui.PushItemWidth(200)
		imgui.Combo(u8'##weapons', weapon, weapons)
		imgui.SameLine()
		if imgui.Button(u8'Выдать оружие') then
			giveGun(weapon.v)
		end
		imgui.SameLine()
		if imgui.Button(u8'Забрать оружие') then
			removeWeaponFromChar(PLAYER_PED, weapon.v)
		end
		imgui.Text(u8'                                                                           ')
		imgui.SameLine()
		if imgui.Button(u8'Забрать ВСЕ оружие', imgui.ImVec2(410, 20)) then
			for i = 1, 46 do
				removeWeaponFromChar(PLAYER_PED, i)
			end
		end
		imgui.End()
	end
end

function main()
	repeat wait(0) until isSampAvailable()
	sampRegisterChatCommand('lname', function(param)
		sampSetLocalPlayerName(param)
		sampAddChatMessage('set local name: '..param, -1)
	end)
	while true do
		wait(0)
		imgui.Process = state.v
		if testCheat('BP') then
			state.v = not state.v
		end
		if wasKeyPressed(vk.VK_OEM_5) and not sampIsChatInputActive() then
			restoreCameraJumpcut()
			freezeCharPosition(PLAYER_PED, false)
			lockPlayerControl(false)
			local bs = raknetNewBitStream()
			raknetBitStreamWriteBool(bs, true)
			raknetEmulRpcReceiveBitStream(15, bs)
			raknetDeleteBitStream(bs)
		end
	end
end

function ev.onSendPlayerSync(data)
	if otos.v then
		local sync = samp_create_sync_data('spectator')
		sync.position = data.position
		sync.send()
		return false
	end
end

function onSendPacket(id, bitStream, priority, reliability, orderingChannel)
	if nops.psync.v and id == 207 then return false end
end

function onReceiveRpc(id, bs)
	if nops.selecttextdraw.v and id == 83 then return false end
	if nops.health.v and id == 14 then return false end
	if nops.givegun.v and id == 22 then return false end
	if nops.resetgun.v and id == 21 then return false end
	if nops.setgun.v and id == 67 then return false end
	if nops.spectator.v and id == 124 then return false end
	if nops.requestclass.v and id == 128 then return false end
	if nops.requestspawn.v and id == 129 then return false end
	if nops.applyanimation.v and id == 86 then return false end
	if nops.clearanimation.v and id == 87 then return false end
	if nops.showdialog.v and id == 61 then return false end
	if nops.forceclass.v and id == 74 then return false end
	if nops.facingangle.v and id == 19 then return false end
	if nops.togglecontrol.v and id == 15 then return false end
end

function onSendRpc(id, bitStream, priority, reliability, orderingChannel, shiftTs)
	if nops.requestclass.v and id == 128 then return false end
	if nops.requestspawn.v and id == 129 then return false end
	if nops.spawn.v and id == 52 then return false end
	if nops.death.v and id == 55 then return false end
	if nops.clicktextdraw.v and id == 83 then return false end
end

function giveGun(id)
	local model = getWeapontypeModel(id)
	requestModel(model)
	loadAllModelsNow()
	giveWeaponToChar(PLAYER_PED, id, 5000)
end

function enableDialog(bool)
    local memory = require 'memory'
    memory.setint32(sampGetDialogInfoPtr()+40, bool and 1 or 0, true)
    sampToggleCursor(bool)
end

function apply_custom_style()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4

    style.WindowRounding = 2.0
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.84)
    style.ChildWindowRounding = 2.0
    style.FrameRounding = 2.0
    style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
    style.ScrollbarSize = 13.0
    style.ScrollbarRounding = 0
    style.GrabMinSize = 8.0
    style.GrabRounding = 1.0

    colors[clr.FrameBg]                = ImVec4(0.48, 0.16, 0.16, 0.54)
    colors[clr.FrameBgHovered]         = ImVec4(0.98, 0.26, 0.26, 0.40)
    colors[clr.FrameBgActive]          = ImVec4(0.98, 0.26, 0.26, 0.67)
    colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.48, 0.16, 0.16, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.CheckMark]              = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.88, 0.26, 0.24, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.Button]                 = ImVec4(0.98, 0.26, 0.26, 0.40)
    colors[clr.ButtonHovered]          = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.98, 0.06, 0.06, 1.00)
    colors[clr.Header]                 = ImVec4(0.98, 0.26, 0.26, 0.31)
    colors[clr.HeaderHovered]          = ImVec4(0.98, 0.26, 0.26, 0.80)
    colors[clr.HeaderActive]           = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.Separator]              = colors[clr.Border]
    colors[clr.SeparatorHovered]       = ImVec4(0.75, 0.10, 0.10, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.75, 0.10, 0.10, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.98, 0.26, 0.26, 0.25)
    colors[clr.ResizeGripHovered]      = ImVec4(0.98, 0.26, 0.26, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.98, 0.26, 0.26, 0.95)
    colors[clr.TextSelectedBg]         = ImVec4(0.98, 0.26, 0.26, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg]                = colors[clr.PopupBg]
    colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end

apply_custom_style()

function samp_create_sync_data(sync_type, copy_from_player)
    local ffi = require 'ffi'
    local sampfuncs = require 'sampfuncs'
    -- from SAMP.Lua
    local raknet = require 'samp.raknet'
    --require 'samp.synchronization'

    copy_from_player = copy_from_player or true
    local sync_traits = {
        player = {'PlayerSyncData', raknet.PACKET.PLAYER_SYNC, sampStorePlayerOnfootData},
        vehicle = {'VehicleSyncData', raknet.PACKET.VEHICLE_SYNC, sampStorePlayerIncarData},
        passenger = {'PassengerSyncData', raknet.PACKET.PASSENGER_SYNC, sampStorePlayerPassengerData},
        aim = {'AimSyncData', raknet.PACKET.AIM_SYNC, sampStorePlayerAimData},
        trailer = {'TrailerSyncData', raknet.PACKET.TRAILER_SYNC, sampStorePlayerTrailerData},
        unoccupied = {'UnoccupiedSyncData', raknet.PACKET.UNOCCUPIED_SYNC, nil},
        bullet = {'BulletSyncData', raknet.PACKET.BULLET_SYNC, nil},
        spectator = {'SpectatorSyncData', raknet.PACKET.SPECTATOR_SYNC, nil}
    }
    local sync_info = sync_traits[sync_type]
    local data_type = 'struct ' .. sync_info[1]
    local data = ffi.new(data_type, {})
    local raw_data_ptr = tonumber(ffi.cast('uintptr_t', ffi.new(data_type .. '*', data)))
    -- copy player's sync data to the allocated memory
    if copy_from_player then
        local copy_func = sync_info[3]
        if copy_func then
            local _, player_id
            if copy_from_player == true then
                _, player_id = sampGetPlayerIdByCharHandle(PLAYER_PED)
            else
                player_id = tonumber(copy_from_player)
            end
            copy_func(player_id, raw_data_ptr)
        end
    end
    -- function to send packet
    local func_send = function()
        local bs = raknetNewBitStream()
        raknetBitStreamWriteInt8(bs, sync_info[2])
        raknetBitStreamWriteBuffer(bs, raw_data_ptr, ffi.sizeof(data))
        raknetSendBitStreamEx(bs, sampfuncs.HIGH_PRIORITY, sampfuncs.UNRELIABLE_SEQUENCED, 1)
        raknetDeleteBitStream(bs)
    end
    -- metatable to access sync data and 'send' function
    local mt = {
        __index = function(t, index)
            return data[index]
        end,
        __newindex = function(t, index, value)
            data[index] = value
        end
    }
    return setmetatable({send = func_send}, mt)
end

function emul_rpc(hook, parameters)
    local bs_io = require 'samp.events.bitstream_io'
    local handler = require 'samp.events.handlers'
    local extra_types = require 'samp.events.extra_types'
    local hooks = {

        --[[ Outgoing rpcs
        ['onSendEnterVehicle'] = { 'int16', 'bool8', 26 },
        ['onSendClickPlayer'] = { 'int16', 'int8', 23 },
        ['onSendClientJoin'] = { 'int32', 'int8', 'string8', 'int32', 'string8', 'string8', 'int32', 25 },
        ['onSendEnterEditObject'] = { 'int32', 'int16', 'int32', 'vector3d', 27 },
        ['onSendCommand'] = { 'string32', 50 },
        ['onSendSpawn'] = { 52 },
        ['onSendDeathNotification'] = { 'int8', 'int16', 53 },
        ['onSendDialogResponse'] = { 'int16', 'int8', 'int16', 'string8', 62 },
        ['onSendClickTextDraw'] = { 'int16', 83 },
        ['onSendVehicleTuningNotification'] = { 'int32', 'int32', 'int32', 'int32', 96 },
        ['onSendChat'] = { 'string8', 101 },
        ['onSendClientCheckResponse'] = { 'int8', 'int32', 'int8', 103 },
        ['onSendVehicleDamaged'] = { 'int16', 'int32', 'int32', 'int8', 'int8', 106 },
        ['onSendEditAttachedObject'] = { 'int32', 'int32', 'int32', 'int32', 'vector3d', 'vector3d', 'vector3d', 'int32', 'int32', 116 },
        ['onSendEditObject'] = { 'bool', 'int16', 'int32', 'vector3d', 'vector3d', 117 },
        ['onSendInteriorChangeNotification'] = { 'int8', 118 },
        ['onSendMapMarker'] = { 'vector3d', 119 },
        ['onSendRequestClass'] = { 'int32', 128 },
        ['onSendRequestSpawn'] = { 129 },
        ['onSendPickedUpPickup'] = { 'int32', 131 },
        ['onSendMenuSelect'] = { 'int8', 132 },
        ['onSendVehicleDestroyed'] = { 'int16', 136 },
        ['onSendQuitMenu'] = { 140 },
        ['onSendExitVehicle'] = { 'int16', 154 },
        ['onSendUpdateScoresAndPings'] = { 155 },
        ['onSendGiveDamage'] = { 'int16', 'float', 'int32', 'int32', 115 },
        ['onSendTakeDamage'] = { 'int16', 'float', 'int32', 'int32', 115 },]]

        -- Incoming rpcs
        ['onInitGame'] = { 139 },
        ['onPlayerJoin'] = { 'int16', 'int32', 'bool8', 'string8', 137 },
        ['onPlayerQuit'] = { 'int16', 'int8', 138 },
        ['onRequestClassResponse'] = { 'bool8', 'int8', 'int32', 'int8', 'vector3d', 'float', 'Int32Array3', 'Int32Array3', 128 },
        ['onRequestSpawnResponse'] = { 'bool8', 129 },
        ['onSetPlayerName'] = { 'int16', 'string8', 'bool8', 11 },
        ['onSetPlayerPos'] = { 'vector3d', 12 },
        ['onSetPlayerPosFindZ'] = { 'vector3d', 13 },
        ['onSetPlayerHealth'] = { 'float', 14 },
        ['onTogglePlayerControllable'] = { 'bool8', 15 },
        ['onPlaySound'] = { 'int32', 'vector3d', 16 },
        ['onSetWorldBounds'] = { 'float', 'float', 'float', 'float', 17 },
        ['onGivePlayerMoney'] = { 'int32', 18 },
        ['onSetPlayerFacingAngle'] = { 'float', 19 },
        --['onResetPlayerMoney'] = { 20 },
        --['onResetPlayerWeapons'] = { 21 },
        ['onGivePlayerWeapon'] = { 'int32', 'int32', 22 },
        --['onCancelEdit'] = { 28 },
        ['onSetPlayerTime'] = { 'int8', 'int8', 29 },
        ['onSetToggleClock'] = { 'bool8', 30 },
        ['onPlayerStreamIn'] = { 'int16', 'int8', 'int32', 'vector3d', 'float', 'int32', 'int8', 32 },
        ['onSetShopName'] = { 'string256', 33 },
        ['onSetPlayerSkillLevel'] = { 'int16', 'int32', 'int16', 34 },
        ['onSetPlayerDrunk'] = { 'int32', 35 },
        ['onCreate3DText'] = { 'int16', 'int32', 'vector3d', 'float', 'bool8', 'int16', 'int16', 'encodedString4096', 36 },
        --['onDisableCheckpoint'] = { 37 },
        ['onSetRaceCheckpoint'] = { 'int8', 'vector3d', 'vector3d', 'float', 38 },
        --['onDisableRaceCheckpoint'] = { 39 },
        --['onGamemodeRestart'] = { 40 },
        ['onPlayAudioStream'] = { 'string8', 'vector3d', 'float', 'bool8', 41 },
        --['onStopAudioStream'] = { 42 },
        ['onRemoveBuilding'] = { 'int32', 'vector3d', 'float', 43 },
        ['onCreateObject'] = { 44 },
        ['onSetObjectPosition'] = { 'int16', 'vector3d', 45 },
        ['onSetObjectRotation'] = { 'int16', 'vector3d', 46 },
        ['onDestroyObject'] = { 'int16', 47 },
        ['onPlayerDeathNotification'] = { 'int16', 'int16', 'int8', 55 },
        ['onSetMapIcon'] = { 'int8', 'vector3d', 'int8', 'int32', 'int8', 56 },
        ['onRemoveVehicleComponent'] = { 'int16', 'int16', 57 },
        ['onRemove3DTextLabel'] = { 'int16', 58 },
        ['onPlayerChatBubble'] = { 'int16', 'int32', 'float', 'int32', 'string8', 59 },
        ['onUpdateGlobalTimer'] = { 'int32', 60 },
        ['onShowDialog'] = { 'int16', 'int8', 'string8', 'string8', 'string8', 'encodedString4096', 61 },
        ['onDestroyPickup'] = { 'int32', 63 },
        ['onLinkVehicleToInterior'] = { 'int16', 'int8', 65 },
        ['onSetPlayerArmour'] = { 'float', 66 },
        ['onSetPlayerArmedWeapon'] = { 'int32', 67 },
        ['onSetSpawnInfo'] = { 'int8', 'int32', 'int8', 'vector3d', 'float', 'Int32Array3', 'Int32Array3', 68 },
        ['onSetPlayerTeam'] = { 'int16', 'int8', 69 },
        ['onPutPlayerInVehicle'] = { 'int16', 'int8', 70 },
        --['onRemovePlayerFromVehicle'] = { 71 },
        ['onSetPlayerColor'] = { 'int16', 'int32', 72 },
        ['onDisplayGameText'] = { 'int32', 'int32', 'string32', 73 },
        --['onForceClassSelection'] = { 74 },
        ['onAttachObjectToPlayer'] = { 'int16', 'int16', 'vector3d', 'vector3d', 75 },
        ['onInitMenu'] = { 76 },
        ['onShowMenu'] = { 'int8', 77 },
        ['onHideMenu'] = { 'int8', 78 },
        ['onCreateExplosion'] = { 'vector3d', 'int32', 'float', 79 },
        ['onShowPlayerNameTag'] = { 'int16', 'bool8', 80 },
        ['onAttachCameraToObject'] = { 'int16', 81 },
        ['onInterpolateCamera'] = { 'bool', 'vector3d', 'vector3d', 'int32', 'int8', 82 },
        ['onGangZoneStopFlash'] = { 'int16', 85 },
        ['onApplyPlayerAnimation'] = { 'int16', 'string8', 'string8', 'bool', 'bool', 'bool', 'bool', 'int32', 86 },
        ['onClearPlayerAnimation'] = { 'int16', 87 },
        ['onSetPlayerSpecialAction'] = { 'int8', 88 },
        ['onSetPlayerFightingStyle'] = { 'int16', 'int8', 89 },
        ['onSetPlayerVelocity'] = { 'vector3d', 90 },
        ['onSetVehicleVelocity'] = { 'bool8', 'vector3d', 91 },
        ['onServerMessage'] = { 'int32', 'string32', 93 },
        ['onSetWorldTime'] = { 'int8', 94 },
        ['onCreatePickup'] = { 'int32', 'int32', 'int32', 'vector3d', 95 },
        ['onMoveObject'] = { 'int16', 'vector3d', 'vector3d', 'float', 'vector3d', 99 },
        ['onEnableStuntBonus'] = { 'bool', 104 },
        ['onTextDrawSetString'] = { 'int16', 'string16', 105 },
        ['onSetCheckpoint'] = { 'vector3d', 'float', 107 },
        ['onCreateGangZone'] = { 'int16', 'vector2d', 'vector2d', 'int32', 108 },
        ['onPlayCrimeReport'] = { 'int16', 'int32', 'int32', 'int32', 'int32', 'vector3d', 112 },
        ['onGangZoneDestroy'] = { 'int16', 120 },
        ['onGangZoneFlash'] = { 'int16', 'int32', 121 },
        ['onStopObject'] = { 'int16', 122 },
        ['onSetVehicleNumberPlate'] = { 'int16', 'string8', 123 },
        ['onTogglePlayerSpectating'] = { 'bool32', 124 },
        ['onSpectatePlayer'] = { 'int16', 'int8', 126 },
        ['onSpectateVehicle'] = { 'int16', 'int8', 127 },
        ['onShowTextDraw'] = { 134 },
        ['onSetPlayerWantedLevel'] = { 'int8', 133 },
        ['onTextDrawHide'] = { 'int16', 135 },
        ['onRemoveMapIcon'] = { 'int8', 144 },
        ['onSetWeaponAmmo'] = { 'int8', 'int16', 145 },
        ['onSetGravity'] = { 'float', 146 },
        ['onSetVehicleHealth'] = { 'int16', 'float', 147 },
        ['onAttachTrailerToVehicle'] = { 'int16', 'int16', 148 },
        ['onDetachTrailerFromVehicle'] = { 'int16', 149 },
        ['onSetWeather'] = { 'int8', 152 },
        ['onSetPlayerSkin'] = { 'int32', 'int32', 153 },
        ['onSetInterior'] = { 'int8', 156 },
        ['onSetCameraPosition'] = { 'vector3d', 157 },
        ['onSetCameraLookAt'] = { 'vector3d', 'int8', 158 },
        ['onSetVehiclePosition'] = { 'int16', 'vector3d', 159 },
        ['onSetVehicleAngle'] = { 'int16', 'float', 160 },
        ['onSetVehicleParams'] = { 'int16', 'int16', 'bool8', 161 },
        --['onSetCameraBehind'] = { 162 },
        ['onChatMessage'] = { 'int16', 'string8', 101 },
        ['onConnectionRejected'] = { 'int8', 130 },
        ['onPlayerStreamOut'] = { 'int16', 163 },
        ['onVehicleStreamIn'] = { 164 },
        ['onVehicleStreamOut'] = { 'int16', 165 },
        ['onPlayerDeath'] = { 'int16', 166 },
        ['onPlayerEnterVehicle'] = { 'int16', 'int16', 'bool8', 26 },
        ['onUpdateScoresAndPings'] = { 'PlayerScorePingMap', 155 },
        ['onSetObjectMaterial'] = { 84 },
        ['onSetObjectMaterialText'] = { 84 },
        ['onSetVehicleParamsEx'] = { 'int16', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 24 },
        ['onSetPlayerAttachedObject'] = { 'int16', 'int32', 'bool', 'int32', 'int32', 'vector3d', 'vector3d', 'vector3d', 'int32', 'int32', 113 }

    }
    local handler_hook = {
        ['onInitGame'] = true,
        ['onCreateObject'] = true,
        ['onInitMenu'] = true,
        ['onShowTextDraw'] = true,
        ['onVehicleStreamIn'] = true,
        ['onSetObjectMaterial'] = true,
        ['onSetObjectMaterialText'] = true
    }
    local extra = {
        ['PlayerScorePingMap'] = true,
        ['Int32Array3'] = true
    }
    local hook_table = hooks[hook]
    if hook_table then
        local bs = raknetNewBitStream()
        if not handler_hook[hook] then
            local max = #hook_table-1
            if max > 0 then
                for i = 1, max do
                    local p = hook_table[i]
                    if extra[p] then extra_types[p]['write'](bs, parameters[i])
                    else bs_io[p]['write'](bs, parameters[i]) end
                end
            end
        else
            if hook == 'onInitGame' then handler.on_init_game_writer(bs, parameters)
            elseif hook == 'onCreateObject' then handler.on_create_object_writer(bs, parameters)
            elseif hook == 'onInitMenu' then handler.on_init_menu_writer(bs, parameters)
            elseif hook == 'onShowTextDraw' then handler.on_show_textdraw_writer(bs, parameters)
            elseif hook == 'onVehicleStreamIn' then handler.on_vehicle_stream_in_writer(bs, parameters)
            elseif hook == 'onSetObjectMaterial' then handler.on_set_object_material_writer(bs, parameters, 1)
            elseif hook == 'onSetObjectMaterialText' then handler.on_set_object_material_writer(bs, parameters, 2) end
        end
        raknetEmulRpcReceiveBitStream(hook_table[#hook_table], bs)
        raknetDeleteBitStream(bs)
    end
end
