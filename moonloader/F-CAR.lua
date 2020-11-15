local imgui = require 'imgui'
local key = require 'vkeys'
require('moonloader')
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8
local event = require('lib.samp.events')
local memory = require 'memory'

local SwitchPlayerSync = false
local SwitchVehicleSync = false
local frvs = false
local Ot3d = false
local fkkss = false

local main_window_state = imgui.ImBool(false)
local CarFire = imgui.ImBool(false)
local Water = imgui.ImBool(false)
local CarGm = imgui.ImBool(false)
local Collision = imgui.ImBool(false)

local InputCarFireId = imgui.ImBuffer(256)
local InputCharFireID = imgui.ImBuffer(256)
local CarCreateModelID = imgui.ImBuffer(256)
local RvankaVictimID = imgui.ImBuffer(256)

function main()
    repeat wait(1200) until isSampAvailable()

		sendMessage("Created {464446}by{850AB9} withay.")
		sendMessage("{464446}Активация - {850AB9}[ CTRL + X ], остальное в CheatHelper.")

    sampRegisterChatCommand('frv', frv)
    sampRegisterChatCommand('fs', fs)
    sampRegisterChatCommand('fss', fss)
    sampRegisterChatCommand('fkk', fkk)
    while true do
        wait(0)
        if wasKeyPressed(key.VK_X) and wasKeyPressed(17) then
            main_window_state.v = not main_window_state.v
        end
        imgui.Process = main_window_state.v
        if CarFire.v == true and isCharInAnyCar(1) then
            nop(false, true)
            CarFireVeh = storeCarCharIsInNoSave(PLAYER_PED)
            CarFireResult, CarFireId = sampGetVehicleIdByCarHandle(CarFireVeh)
            sampSendExitVehicle(CarFireId)
            wait(800)
            sampSendEnterVehicle(CarFireId, true)
            wait(1000)
            VehicleFire()
            nop(false, false)
            CarFire.v = false
        end
        if isCharInCar(PLAYER_PED, CreateVeh) then
            local data = samp_create_sync_data('player', true)
			local FixX, FixY, FixZ = getCharCoordinates(PLAYER_PED)
			data.position = {x = FixX, y = FixY, z = FixZ}
			data.moveSpeed.x = 0.3
			data.moveSpeed.y = 0
			data.moveSpeed.z = -1
			data.send()
        end
    end
end

function fs(id)
    if not isCharInAnyCar(PLAYER_PED) and tonumber(id) then
        SeatBool, SeatHand = sampGetCarHandleBySampVehicleId(id)
        if SeatBool then
            lua_thread.create(function()
                sampSendEnterVehicle(id, true)
                wait(1000)
                warpCharIntoCar(PLAYER_PED, SeatHand)
            end)
        end
    end
end

function fss(id)
    if not isCharInAnyCar(PLAYER_PED) and tonumber(id) then
        SeatBool, SeatHand = sampGetCarHandleBySampVehicleId(id)
        if SeatBool then
            lua_thread.create(function()
                nop(true, true)
                sampSendEnterVehicle(id, false)
                wait(1000)
                warpCharIntoCarAsPassenger(1, SeatHand, 1)
                nop(false, false)
            end)
        end
    end
end

function frv(id)
    frvs = not frvs
    lua_thread.create(function()
        if frvs == true and isCharInAnyCar(1) then
            rvmyHand = storeCarCharIsInNoSave(PLAYER_PED)
            rvbools, idcarv = sampGetVehicleIdByCarHandle(rvmyHand)
            if not tonumber(id) or not sampIsPlayerConnected(id) then
                sampAddChatMessage('Игрока не существует.', -1)
                frvs = false
                return
            end
            rvBool, rvHand = sampGetCharHandleBySampPlayerId(id)
            if not rvBool then
                sampAddChatMessage('Игрок не в зоне стрима.', -1)
                frvs = false
                return
            end
            RvX, RvY, RvZ = getCharCoordinates(rvHand)
            RvDistance = getDistanceBetweenCoords3d(RvX, RvY, RvZ, getCharCoordinates(1))
            if RvDistance > 70 then
                sampAddChatMessage('Игрок не в радиусе действия Рванки. (70)', -1)
                frvs = false
                return
            end
            while getDistanceBetweenCoords3d(RvX, RvY, RvZ, getCharCoordinates(1)) < 70 do
                wait(1)
                RvX, RvY, RvZ = getCharCoordinates(rvHand)
                local data = samp_create_sync_data("vehicle", true)
                data.vehicleId = tonumber(idcarv)
                data.position = {x = RvX + math.random(-4, 4) * 0.25 / 2, y = RvY + math.random(-4, 4) * 0.25 / 2, z = RvZ + math.random(-5, 5) * 0.25 / 2}
                data.moveSpeed = {x = 0.1, y = 0, z = -0.1}
                data.send()
                if not frvs then return end
            end
        elseif not frvs then
            sampAddChatMessage('Завершаем работу Рванки.', -1)
        end
    end)
end

function event.onVehicleSync(datas)
    if SwitchVehicleSync then
        return false
    end
end

function event.onPlayerSync(datas)
	if SwitchPlayerSync then
		return false
	end
end

function imgui.OnDrawFrame()
    if main_window_state.v then
        imgui.SetNextWindowPos(imgui.ImVec2(imgui.GetIO().DisplaySize.x / 2, imgui.GetIO().DisplaySize.y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(-0.72, -0.549))
		imgui.SetNextWindowSize(imgui.ImVec2(300, 195), imgui.Cond.FirstUseEver)
        imgui.Begin('F-Car by withay.', main_window_state, 2)
        if imgui.Checkbox(u8' Езда по воде.##Water', Water) then
            if Water.v == true and isCharInAnyCar(PLAYER_PED) then
                memory.write(9867602, 1, 4)
            else
                memory.write(9867602, 0, 4)
            end
        end
        imgui.Checkbox(u8' Поджог Машины##CarFire', CarFire)
        if imgui.Checkbox(' GM Car##CarGm', CarGm) then
            if CarGm.v == true and isCharInAnyCar(PLAYER_PED) then
                setCarProofs(storeCarCharIsInNoSave(PLAYER_PED), true, true, true, true, true)
            elseif isCharInAnyCar(PLAYER_PED) then
                setCarProofs(storeCarCharIsInNoSave(PLAYER_PED), false, false, false, false, false)
            end
        end
        if imgui.Button(u8("Отрисовка ID##3dCarID"), imgui.ImVec2(140, 19)) then
            Ot3d = not Ot3d
            if Ot3d then
                lua_thread.create(function()
                    while true do
                        if not Ot3d then return end
                        for i, k in ipairs(getAllVehicles()) do
                            if not Ot3d then return end
                            renderbool, idcarrnd = sampGetVehicleIdByCarHandle(k)
                            sampDestroy3dText(idcarrnd)
                            wait(5)
                            sampCreate3dText('{FFFFFF}ID: '.. idcarrnd, -1, 0, 0, 1, 150, true, -1, idcarrnd)
                            sampDestroy3dText(idcarrnd)
                        end
                    end
                end)
            else
                for i = 1, 2000 do
                    sampDestroy3dText(i)
                end
            end
        end
        imgui.SameLine()
        if imgui.Button(u8("Починить Авто.##repair"), imgui.ImVec2(140, 19)) then
            if isCharInAnyCar(PLAYER_PED) then
                repairbool, idrepair = sampGetVehicleIdByCarHandle(storeCarCharIsInNoSave(PLAYER_PED))
                local data = samp_create_sync_data('vehicle', tonumber(idrepair))
                data.vehicleId = tonumber(idrepair)
                data.vehicleHealth = math.random(980, 1000)
                data.send()
                setCarHealth(storeCarCharIsInNoSave(PLAYER_PED), math.random(980, 1000))
                fixCar(storeCarCharIsInNoSave(PLAYER_PED))
            end
        end
        imgui.Text(u8"Car ID:")
        imgui.SameLine()
        imgui.PushItemWidth(30)
        imgui.InputText("##caridfire", InputCarFireId, imgui.InputTextFlags.EnterReturnsTrue)
        imgui.PopItemWidth()
        imgui.SameLine()
        imgui.Text(u8"Ped ID:")
        imgui.SameLine()
        imgui.PushItemWidth(30)
        imgui.InputText("##charidfire", InputCharFireID, imgui.InputTextFlags.EnterReturnsTrue)
        imgui.PopItemWidth()
        imgui.SameLine()
        imgui.SetCursorPos(imgui.ImVec2(180, 100))
        if imgui.Button(u8("Выполнить"), imgui.ImVec2(95, 19)) then
            if tonumber(InputCarFireId.v) and tonumber(InputCharFireID.v) then
                InputIdCar = InputCarFireId.v
                InputChar = InputCharFireID.v
                lua_thread.create(FairsCar)
            end
        end
        imgui.Text(u8("Создать Машину:"))
        imgui.SameLine()
        imgui.PushItemWidth(30)
        imgui.InputText("##carcreate", CarCreateModelID, imgui.InputTextFlags.EnterReturnsTrue)
        imgui.PopItemWidth()
        imgui.SameLine()
        imgui.SetCursorPos(imgui.ImVec2(180, 120))
        if imgui.Button(u8("Выполнить##CreCar"), imgui.ImVec2(95, 19)) then
            if tonumber(CarCreateModelID.v) and not isCharInAnyCar(PLAYER_PED) then
                if tonumber(CarCreateModelID.v) < 612 and tonumber(CarCreateModelID.v) > 399 then
                    if not hasModelLoaded(CarCreateModelID.v) then
                        requestModel(CarCreateModelID.v)
                        loadAllModelsNow()
                    end
                    local MyX, MyY, MyZ = getCharCoordinates(PLAYER_PED)
                    CreateVeh = createCar(CarCreateModelID.v, MyX, MyY + 1, MyZ)
                    warpCharIntoCar(1, CreateVeh)
                end
            end
        end
        imgui.SetCursorPos(imgui.ImVec2(6, 145))
        if imgui.Button(u8("Удалить Машину##CreCar"), imgui.ImVec2(290, 19)) then
            clearCharTasksImmediately(1)
            deleteCar(CreateVeh)
        end
        imgui.SetCursorPos(imgui.ImVec2(6, 170))
        if imgui.Button(u8("Перевернуться##rollCar"), imgui.ImVec2(290, 19)) then
            if isCharInAnyCar(PLAYER_PED) then
                setCarRoll(storeCarCharIsInNoSave(PLAYER_PED), 0, 0, 0)
            end
        end
        imgui.End()
    end
end


function FairsCar()
    stbool, FireHand = sampGetCarHandleBySampVehicleId(InputIdCar)
    PedFireBool, FirePed = sampGetCharHandleBySampPlayerId(InputChar)
    if stbool and PedFireBool then
        nop(true, true)
        FireCarX, FireCarY, FireCarZ = getCarCoordinates(FireHand)
        local FirePlayerData = samp_create_sync_data('player', true)
        FirePlayerData.position = {x = FireCarX, y = FireCarY, z = FireCarZ}
        FirePlayerData.send()
        sampSendEnterVehicle(InputIdCar, true)
        wait(1000)
        local VicX, VicY, VicZ = getCharCoordinates(FirePed)
        local FireVehicleData = samp_create_sync_data('vehicle', tonumber(InputIdCar))
        FireVehicleData.vehicleId = tonumber(InputIdCar)
        FireVehicleData.position = {x = VicX, y = VicY, z = VicZ}
        setCarCoordinates(FireHand, VicX, VicY, VicZ)
        FireVehicleData.vehicleHealth = math.random(100, 200)
        FireVehicleData.send()
        nop(false, false)
    end
end

function fkk(id)
    fkkss = not fkkss
    if fkkss and isCharInAnyCar(PLAYER_PED) then
        kkbool, kkidcar = sampGetVehicleIdByCarHandle(storeCarCharIsInNoSave(PLAYER_PED))
        lua_thread.create(function()
            if not sampIsPlayerConnected(id) or not tonumber(id) then
                sampAddChatMessage('Игрока не существует.', -1)
                fkkss = false
                return
            end
            kkresult, kkhand = sampGetCharHandleBySampPlayerId(id)
            if not kkresult then
                sampAddChatMessage('Игрок не в зоне стрима', -1)
                fkkss = false
                return
            end
            kkX, kkY, kkZ = getCharCoordinates(kkhand)
            KkDistance = getDistanceBetweenCoords3d(kkX, kkY, kkZ, getCharCoordinates(1))
            if KkDistance > 40 then
                sampAddChatMessage('Игрок в не действия кикера (40)', -1)
                fkkss = false
                return
            end
            while getDistanceBetweenCoords3d(kkX, kkY, kkZ, getCharCoordinates(1)) < 40 do
                wait(0)
                if sampIsPlayerConnected(id) then
                    kkX, kkY, kkZ = getCharCoordinates(kkhand)
                    local data = samp_create_sync_data("vehicle", true)
                    data.vehicleId = tonumber(kkidcar)
                    data.position = {x = kkX, y = kkY, z = kkZ - 1}
                    data.moveSpeed.z = -0.1
                    data.send()
                else
                    fkkss = false
                    sampAddChatMessage('Игрок кикнут.', -1)
                    return
                end
                if not fkkss then return end
            end
        end)
    elseif not fkkss then
        sampAddChatMessage('Завершаю работу', -1)
    end
end

function nop(player, vehicle)
    if player == true then SwitchPlayerSync = true else SwitchPlayerSync = false end
    if vehicle == true then SwitchVehicleSync = true else SwitchVehicleSync = false end
end

function VehicleFire()
    local data = allocateMemory(63)
    local _, myId = sampGetPlayerIdByCharHandle(PLAYER_PED)
    sampStorePlayerIncarData(myId, data)
    setStructFloatElement(data, 48, math.random(100, 200), false)
    sampSendIncarData(data)
    freeMemory(data)
end

function samp_create_sync_data(sync_type, copy_from_player)
    local ffi = require 'ffi'
    local sampfuncs = require 'sampfuncs'
    -- from SAMP.Lua
    local raknet = require 'lib.samp.raknet'
    require 'lib.samp.synchronization'

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

function CherryTheme()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    local ImVec2 = imgui.ImVec2


    style.WindowPadding = ImVec2(6, 4)
    style.WindowRounding = 0.0
    style.FramePadding = ImVec2(5, 2)
    style.FrameRounding = 3.0
    style.ItemSpacing = ImVec2(7, 1)
    style.ItemInnerSpacing = ImVec2(1, 1)
    style.TouchExtraPadding = ImVec2(0, 0)
    style.IndentSpacing = 6.0
    style.ScrollbarSize = 12.0
    style.ScrollbarRounding = 16.0
    style.GrabMinSize = 20.0
    style.GrabRounding = 2.0

    style.WindowTitleAlign = ImVec2(0.5, 0.5)

		colors[clr.Text] = ImVec4(0.52, 0.04, 0.73, 1)
		colors[clr.TextDisabled] = ImVec4(0.24, 0.23, 0.29, 1.00)
		colors[clr.WindowBg] = ImVec4(0.06, 0.05, 0.07, 1.00)
		colors[clr.ChildWindowBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
		colors[clr.PopupBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
		colors[clr.Border] = ImVec4(0.80, 0.80, 0.83, 0.88)
		colors[clr.BorderShadow] = ImVec4(0.92, 0.91, 0.88, 0.00)
		colors[clr.FrameBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
		colors[clr.FrameBgHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
		colors[clr.FrameBgActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
		colors[clr.TitleBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
		colors[clr.TitleBgCollapsed] = ImVec4(1.00, 0.98, 0.95, 0.75)
		colors[clr.TitleBgActive] = ImVec4(0.07, 0.07, 0.09, 1.00)
		colors[clr.MenuBarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
		colors[clr.ScrollbarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
		colors[clr.ScrollbarGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
		colors[clr.ScrollbarGrabHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
		colors[clr.ScrollbarGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
		colors[clr.ComboBg] = ImVec4(0.19, 0.18, 0.21, 1.00)
		colors[clr.CheckMark] = ImVec4(0.80, 0.80, 0.83, 0.31)
		colors[clr.SliderGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
		colors[clr.SliderGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
		colors[clr.Button] = ImVec4(0.10, 0.09, 0.12, 1.00)
		colors[clr.ButtonHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
		colors[clr.ButtonActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
		colors[clr.Header] = ImVec4(0.10, 0.09, 0.12, 1.00)
		colors[clr.HeaderHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
		colors[clr.HeaderActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
		colors[clr.ResizeGrip] = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.ResizeGripHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
		colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
		colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
		colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
		colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
		colors[clr.PlotLines] = ImVec4(0.40, 0.39, 0.38, 0.63)
		colors[clr.PlotLinesHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
		colors[clr.PlotHistogram] = ImVec4(0.40, 0.39, 0.38, 0.63)
		colors[clr.PlotHistogramHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
		colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
		colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
  end
  CherryTheme()

	function sendMessage(text)
		tag = '{464446}[{850AB9}F{464446}-{850AB9}CAR{464446}]: {850AB9}'
		sampAddChatMessage(tag .. text, -1)
	end
