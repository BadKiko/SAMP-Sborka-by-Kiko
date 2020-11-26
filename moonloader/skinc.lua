script_name("skinc")
script_author("McLore")

local imgui = require 'imgui'
local encoding = require 'encoding'
local sp  = require 'lib.samp.events'
local dlstatus = require('moonloader').download_status
encoding.default = 'CP1251'
u8 = encoding.UTF8
require "lib.sampfuncs"

local MODEL = 0
local skinpng = {}
local skinc = imgui.ImBool(false)

function main()
    if not isSampfuncsLoaded() or not isSampLoaded() then return end
    while not isSampAvailable() do wait(100) end 
    if not doesDirectoryExist("moonloader\\config\\peds") then
        createDirectory("moonloader\\config\\peds")
    end
    for i = 0, 311, 1 do
        if not doesFileExist("moonloader\\config\\peds\\skin_" .. i .. ".png") then
            downloadUrlToFile("https://kak-tak.info/wp-content/uploads/2020/05/skin_" .. i .. ".png", "moonloader\\config\\peds\\skin_" .. i .. ".png", function (id, status, p1, p2)
                if status == dlstatus.STATUSEX_ENDDOWNLOAD then
                    print("[Skinc] {FFFFFF}Загружен файл Skin_" ..i.. ".png")
                end
            end)
        end
        skinpng[i] = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\config\\peds\\skin_" .. i .. ".png")
    end
    sampRegisterChatCommand("skinc",function() skinc.v = not skinc.v end)
    while true do
        wait(0)
        imgui.Process = skinc.v
    end
end

function imgui.CenterText(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end

function imgui.OnDrawFrame()
    ScreenX, ScreenY = getScreenResolution()
    if skinc.v then
        imgui.SetNextWindowPos(imgui.ImVec2(ScreenX / 2 , ScreenY / 2), imgui.Cond.FirsUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8("ID Скинов"), skinc, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoSavedSettings + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize)
        apply_custom_style()
            kl = 0
            posvehx = 5
            posvehy = 95
            postextx = 10
            postexty = 95
            imgui.CenterText(u8"Выберите нужный вам скин кликом ЛКМ")
            imgui.CenterText(u8"Если у вас нету изображения - подожмите минуту и перезапустите скрипт")
            imgui.CenterText(u8"Прогресс можете отслеживать в консоли SAMPFUNCS")
            imgui.Separator()
            for i = 0, 311, 1 do
                imgui.SetCursorPos(imgui.ImVec2(posvehx, posvehy))
                imgui.BeginChild("##12dsgpokd" .. i, imgui.ImVec2(80, 95))
                imgui.EndChild()    

                if imgui.IsItemClicked() then
                    MODEL = i
                    _, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
                    set_player_skin(id, MODEL)
                    skinc.v = false
                    sampAddChatMessage(string.format("[Skinc] {FFFFFF} Вы выбрали скин под ID [%d]",MODEL) ,0x6495ED)
                end

                imgui.SetCursorPos(imgui.ImVec2(posvehx, posvehy))
                imgui.Image(skinpng[i], imgui.ImVec2(80, 95))

                postextx = postextx + 100
                posvehx = posvehx + 100
                kl = kl + 1
                if kl > 10 then
                    kl = 0
                    posvehx = 5
                    postextx = 10
                    posvehy = posvehy + 120
                    postexty = posvehy + 90
                end
            end
        imgui.End()
    end
end

function sp.onSetPlayerPos(x,y,z)
	if MODEL > 0 then
		_, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
		set_player_skin(id, MODEL)
	end
end
function set_player_skin(id, skin)
	local BS = raknetNewBitStream()
	raknetBitStreamWriteInt32(BS, id)
	raknetBitStreamWriteInt32(BS, skin)
	raknetEmulRpcReceiveBitStream(153, BS)
	raknetDeleteBitStream(BS)
end

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