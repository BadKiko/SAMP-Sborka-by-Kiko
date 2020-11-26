script_name("AntiSpamForMaksQSpam")
script_version("0.0.1")
script_author("Kiko")

local sampev = require("lib.samp.events")
local imgui = require("imgui")
local encoding = require("encoding")
local sw, sh = getScreenResolution()

local isAntiSpamWork = false

encoding.default = "CP1251"
u8 = encoding.UTF8

local dungeonWord = imgui.ImBuffer("", 256)
local menu_window_state = imgui.ImBool(false) --статус main окна

function main()

	repeat wait(0) until isSampLoaded() and isSampAvailable()

	wait(500)
	sampAddChatMessage(" ")
	sendMessage("AntiSpamForMaksQSpammer {464446}by{850AB9} Kiko")
	sendMessage("Created {464446}by{850AB9} Kiko")


	imgui.Process = true
	imgui.Process =  menu_window_state.v
	
	sampRegisterChatCommand("antispam", function()
		menu_window_state.v = not menu_window_state.v
		imgui.Process =  menu_window_state.v
	end)
	

	while true do

		wait(0)
		--прячем показываем курсор
		if menu_window_state.v == false then
			imgui.ShowCursor = false
		else
			imgui.ShowCursor = true
		end
	end
end

--Рисуем меню
function imgui.OnDrawFrame()
	--Main меню
	if menu_window_state.v then
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin("[AntiSpamForMaksQSpam] by Kiko", menu_window_state, imgui.WindowFlags.AlwaysAutoResize)
		apply_custom_style()

		imgui.Text(u8'Анти Спаммер для РакБот Спаммера от MaksQ')
		imgui.Separator()
		if isAntiSpamWork then
			if imgui.Button(u8'Выключить Авто-Режим') then
				isAntiSpamWork = not isAntiSpamWork
			end
		else
			if imgui.Button(u8'Включить Авто-Режим') then
				isAntiSpamWork = not isAntiSpamWork
			end
		end
		----------------------------------------------------
		imgui.Separator()
		if (imgui.TreeNode(u8"Дополнительная хуйня:")) then
			imgui.Text(u8'Отсекать по Dungeon слову:')
			imgui.InputText(u8'- Введите ваш Fisting', dungeonWord)
			imgui.TreePop()
		end
		imgui.End()
	end
end

function Work()
	
end

--Orange стиль
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


function sendMessage(text)
	tag = '{464446}[AntiSpam{850AB9}ForMaksQSpam{464446}]: {850AB9}'
	sampAddChatMessage(tag .. text, -1)
end

function sampev.onChatMessage(playerId, text)
	if text:find('MaksQ') or text:find('maksQ') or text:find('maksq') or text:find('maksQ') and isAntiSpamWork then return false end
	if text:find('Мать') or text:find('мать') and isAntiSpamWork then return false end
	if text:find('Ебал') or text:find('ебал') and isAntiSpamWork then return false end
	if text:find('Kiko') or text:find('kiko') and isAntiSpamWork then return false end
	if text:find('Dungeon') or text:find('dungeon') and isAntiSpamWork then return false end
	if text:find('Fisting') or text:find('fisting') and isAntiSpamWork then return false end

	if dungeonWord.v ~= "" and text:find(dungeonWord.v) then return false end
end