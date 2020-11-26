local ev = require('lib.samp.events')
local ini = require('inicfg')
local effil = require('effil')
local md5 = require('md5')
local imgui = require('imgui')
local encoding = require('encoding')
local vk = require('vkeys')
encoding.default = 'CP1251'
local u8 = encoding.UTF8
local protect = false



function ev.onSendEnterVehicle()
    lua_thread.create(function()
        protect = true
        wait(2000)
        protect = false
    end)
end

function ev.onUnoccupiedSync()
    if protect then return false end
end

function samp_create_jopa_data(sync_type, copy_from_player)
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

local key = '................................'
local state = false
local menu = imgui.ImBool(false)
local log = imgui.ImBool(true)
local line = imgui.ImBool(true)
-- local log_posing = false
-- local log_x, log_y = 50, 50
-- local log_text = {
-- 	'Готов к логгированию',
-- 	'',
-- 	'',
-- 	'',
-- 	'',
-- 	'',
-- 	'',
-- 	'',
-- 	'',
-- }
local priv = false
local dissync = false
local max = imgui.ImInt(50)

function imgui.OnDrawFrame()
    if menu.v then
        local xw, yw = getScreenResolution()
        imgui.SetNextWindowPos(imgui.ImVec2(xw/2, yw/2), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowSize(imgui.ImVec2(500, 170), imgui.Cond.FirstUseEver)
        imgui.Begin(u8'Бутыльный разрыватель | Автор: MrCreepTon | Тема: Kiko', menu, imgui.WindowFlags.AlwaysAutoResize)
        if state then
            if imgui.Button(u8'Выключить', imgui.ImVec2(-0.1, 20)) then
                sampProcessChatInput('/butilka')
            end
        else
            if imgui.Button(u8'Включить', imgui.ImVec2(-0.1, 20)) then
                sampProcessChatInput('/butilka')
            end
        end
        if imgui.Button(u8'Сохранить настройки', imgui.ImVec2(-0.1, 20)) then
            saveIni()
        end
        imgui.Separator()
        imgui.BeginChild(u8'##window1', imgui.ImVec2(275, 70), false)
        imgui.Checkbox(u8'Включить логгирование', log)
        -- if log.v then
        -- 	if imgui.Button(u8'Изменить местоположение окна') then
        -- 		log_posing = true
        -- 	end
        -- end
        imgui.Checkbox(u8'Включить линии к жертвам', line)
        imgui.EndChild()
        imgui.SameLine()
        imgui.BeginChild(u8'##window2', imgui.ImVec2(200, 70), false)
        imgui.PushItemWidth(50)
        imgui.InputInt(u8'Радиус', max, 0, 0)
        imgui.EndChild()
        imgui.End()
    end
    -- if log.v then
    -- 	imgui.SetNextWindowPos(imgui.ImVec2(log_x, log_y))
    -- 	imgui.SetNextWindowSize(imgui.ImVec2(350, 200))
    -- 	imgui.Begin(u8'Butilka Logging', false, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
    -- 	imgui.TextColoredRGB(log_text[1])
    -- 	imgui.TextColoredRGB(log_text[2])
    -- 	imgui.TextColoredRGB(log_text[3])
    -- 	imgui.TextColoredRGB(log_text[4])
    -- 	imgui.TextColoredRGB(log_text[5])
    -- 	imgui.TextColoredRGB(log_text[6])
    -- 	imgui.TextColoredRGB(log_text[7])
    -- 	imgui.TextColoredRGB(log_text[8])
    -- 	imgui.TextColoredRGB(log_text[9])
    -- 	imgui.End()
    -- end
end







local a = {
    'a',
    'b',
    'c',
    'd',
    'e',
    'f',
    'g',
    'h',
    'i',
    'j',
    'k',
    'l',
    'm',
    'n',
    'p',
    'q',
    'r',
    's',
    't',
    'u',
    'v',
    'w',
    'x',
    'y',
    'z'
}



local c = {
    'а',
    'б',
    'в',
    'г',
    'д',
    'е',
    'ё',
    'ж',
    'з',
    'и',
    'й',
    'к',
    'л',
    'м',
    'н',
    'о',
    'п',
    'р',
    'с',
    'т',
    'у',
    'ф',
    'х',
    'ц',
    'ч',
    'ш',
    'щ',
    'ъ',
    'ы',
    'ь',
    'э',
    'ю',
    'я'
}





local e = {
    'А',
    'Б',
    'В',
    'Г',
    'Д',
    'Е',
    'Ё',
    'Ж',
    'З',
    'И',
    'Й',
    'К',
    'Л',
    'М',
    'Н',
    'О',
    'П',
    'Р',
    'С',
    'Т',
    'У',
    'Ф',
    'Х',
    'Ц',
    'Ч',
    'Ш',
    'Щ',
    'Ъ',
    'Ы',
    'Ь',
    'Э',
    'Ю',
    'Я'
}



function renderTarget(id)
    local t = lua_thread.create(function()
        local _, ped = sampGetCharHandleBySampPlayerId(id)
        local gx, gy, gz = 0, 0, 0
        if _ then
            gx, gy, gz = getCharCoordinates(ped)
        else
            return false
        end
        while _ and state do
            wait(10)

            _, ped = sampGetCharHandleBySampPlayerId(id)
            if _ then
                local mx, my, mz = getCharCoordinates(PLAYER_PED)
                local x, y, z = getCharCoordinates(ped)
                if not isCharInArea3d(ped, gx - 5, gy - 5, gz - 5, gx + 5, gy + 5, gz + 5, false) then
                    break
                end
                local mxw, myw = convert3DCoordsToScreen(mx, my, mz)
                local xw, yw = convert3DCoordsToScreen(x, y, z)
                if isCharOnScreen(ped) then
                    renderDrawLine(mxw, myw, xw, yw, 2, 0xFF941DB5)
                end
            end
        end
    end)
    --t:terminate()
end

function main()
    repeat wait(0) until isSampAvailable()
    wait(2000)
    loadIni()
    sampAddChatMessage('{464446}[Бутыльный {850AB9}разрыватель{464446}]: {850AB9}Успешно загрузились!', -1)
    sampRegisterChatCommand('butilka.menu', function()
        menu.v = not menu.v
    end)
    sampRegisterChatCommand('butilka', function()
        state = not state
        if state then return sampAddChatMessage('{464446}[Бутыльный {850AB9}разрыватель{464446}]: Включен!', -1) end
        return sampAddChatMessage('{464446}[Бутыльный {850AB9}разрыватель{464446}]: Выключен!', -1)
    end)
    while true do
        wait(0)
        -- if log_posing then
        -- 	if isKeyDown(vk.VK_LBUTTON) then
        -- 		log_posing = false
        -- 		sampToggleCursor(false)
        -- 		sampAddChatMessage('{FF5656}[Бутыльный разрыватель]: {FFFFFF}Успешно установлены новые координаты!', -1)
        -- 		sampAddChatMessage('{FF5656}[Бутыльный разрыватель]: {FFFFFF}Если после закрытия меню вы заморозитесь, прожмите {FF5656}ESC', -1)
        -- 	end
        -- 	sampToggleCursor(true)
        -- 	local xw, yw = getCursorPos()
        -- 	log_x, log_y = xw + 20, yw
        -- end
        imgui.Process = menu.v
    end
end



function loadIni()
    local settings = ini.load(nil, 'nabutilku1.1')
    if settings == nil then
        saveIni()
    else
        max.v = settings.settings.radius
        log.v = settings.settings.log
        line.v = settings.settings.line
    end
end

function zapros(method, url, args, resolve, reject)
    local request_thread = effil.thread(function (method, url, args)
        local requests = require 'requests'
        local result, response = pcall(requests.request, method, url, args)
        if result then
            response.json, response.xml = nil, nil
            return true, response
        else
            return false, response
        end
    end)(method, url, args)
    -- Если запрос без функций обработки ответа и ошибок.
    if not resolve then resolve = function() end end
    if not reject then reject = function() end end
    -- Проверка выполнения потока
    local t = lua_thread.create(function()
        local runner = request_thread
        while true do
            local status, err = runner:status()
            if not err then
                if status == 'completed' then
                    local result, response = runner:get()
                    if result then
                        resolve(response)
                    else
                        reject(response)
                    end
                    return
                elseif status == 'canceled' then
                    return reject(status)
                end
            else
                return reject(err)
            end
            wait(0)
        end
    end)
    return false
end




function saveIni()
    ini.save({
        settings = {
            radius = max.v,
            log = log.v,
            line = line.v
        }
    }, 'nabutilku1.1')
end



function ev.onPlayerEnterVehicle(id, vehid, pass)
    if state and not dissync then
        local _, veh = sampGetCarHandleBySampVehicleId(vehid)
        if _ then
            if getDriverOfCar(veh) == -1 or not pass and isCharOnFoot(PLAYER_PED) then
                local x, y, z = getCharCoordinates(PLAYER_PED)
                local cx, cy, cz = getCarCoordinates(veh)
                local dist = getDistanceBetweenCoords3d(x, y, z, cx, cy, cz)
                if dist <= max.v then
                    local t = lua_thread.create(function()
                        local _, ped = sampGetCharHandleBySampPlayerId(id)
                        if _ then
                            local px, py, pz = getCharCoordinates(ped)
                            dist = getDistanceBetweenCoords3d(cx, cy, cz, px, py, pz)
                            if log.v then
                                printStringNow('~y~Attention:~n~~w~Player ~r~'..sampGetPlayerNickname(id)..'['..id..'] ~w~is entering vehicle...', 3000)
                            end
                            while dist > 3 do
                                wait(0)

                                if dist > 5 then
                                    if log.v then
                                        printStringNow('~r~Error:~n~~w~Player ~r~'..sampGetPlayerNickname(id)..'['..id..'] ~w~ne sel v avto', 3000)
                                    end
                                    break
                                end
                                _, ped = sampGetCharHandleBySampPlayerId(id)
                                if _ then
                                    px, py, pz = getCharCoordinates(ped)
                                    dist = getDistanceBetweenCoords3d(cx, cy, cz, px, py, pz)
                                else
                                    if log.v then
                                        printStringNow('~r~Error:~n~~w~Player left', 3000)
                                        break
                                    end
                                    break
                                end
                            end
                        else
                            if log.v then
                                printStringNow('~r~Error:~n~~w~Player left', 3000)
                            end
                        end
                        wait(300)
                        dissync = true
                        local x, y, z = getCharCoordinates(PLAYER_PED)
                        local angle = getHeadingFromVector2d(cx - x, cy - y)
                        local dist = getDistanceBetweenCoords2d(cx, cy, x, y)
                        while dist > 6 do
                            x = x + 5 * math.sin(-math.rad(angle))

                            y = y + 5 * math.cos(-math.rad(angle))
                            local sync = samp_create_jopa_data('player')
                            sync.position.x, sync.position.y, sync.position.z = x, y, cz

                            sync.moveSpeed.z = -1
                            sync.send()
                            dist = getDistanceBetweenCoords2d(cx, cy, x, y)
                        end
                        local sync = samp_create_jopa_data('player')
                        sync.position.x, sync.position.y, sync.position.z = cx, cy, cz
                        -- sync.surfingVehicleId = vehid
                        -- sync.surfingOffsets.z = -1
                        sync.moveSpeed.z = -1
                        sync.send()
                        wait(10)
                        for i = 1, 3 do
                            local sync = samp_create_jopa_data('unoccupied')
                            sync.vehicleId = vehid
                            sync.seatId = 0
                            --sync.vehicleHealth = 1000
                            sync.position.x, sync.position.y, sync.position.z = cx, cy, cz - 0.2
                            sync.send()
                            wait(10)
                        end
                        x, y, z = getCharCoordinates(PLAYER_PED)
                        dist = getDistanceBetweenCoords2d(cx, cy, x, y)
                        while dist > 6 do
                            angle = getHeadingFromVector2d(x - cx, y - cy)
                            cx = cx + 5 * math.sin(-math.rad(angle))
                            cy = cy + 5 * math.cos(-math.rad(angle))
                            local sync = samp_create_jopa_data('player')
                            sync.position.x, sync.position.y, sync.position.z = cx, cy, z
                            sync.moveSpeed.z = -1
                            sync.send()
                            dist = getDistanceBetweenCoords2d(cx, cy, x, y)
                        end
                        wait(30)
                        dissync = false
                        sampForceOnfootSync()
                        if log.v then
                            printStringNow('~g~Success:~n~~w~Player ~r~'..sampGetPlayerNickname(id)..'['..id..'] ~w~sel na butilku', 3000)
                        end
                        if id ~= nil and line.v then
                            renderTarget(id)
                        end
                    end)
                    --t:terminate()
                end
            end
        end
    end
end



function ev.onSetPlayerPos()
    if dissync then return false end
end



function ev.onSendPlayerSync(data)
    if dissync then return false end
end



function imgui.TextColoredRGB(text)
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4
    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end

    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImColor(r, g, b, a):GetVec4()
    end

    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else imgui.Text(u8(w)) end
        end
    end
    render_text(text)
end



-- function writeLog(text)
-- 	if text ~= log_text[1] then
-- 		for i = 9, 2, -1 do
-- 			log_text[i] = log_text[i - 1]
-- 		end
-- 		log_text[1] = text
-- 	end
-- end

function apply_custom_style()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4

	style.WindowPadding = imgui.ImVec2(15, 15)
	style.WindowRounding = 1.5
	style.FramePadding = imgui.ImVec2(5, 5)
	style.FrameRounding = 4.0
	style.ItemSpacing = imgui.ImVec2(12, 8)
	style.ItemInnerSpacing = imgui.ImVec2(8, 6)
	style.IndentSpacing = 25.0
	style.ScrollbarSize = 15.0
	style.ScrollbarRounding = 9.0
	style.GrabMinSize = 5.0
	style.GrabRounding = 3.0

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

	colors[clr.Separator] = ImVec4(0.1, 0.09, 0.11, 1.00)
end

apply_custom_style()