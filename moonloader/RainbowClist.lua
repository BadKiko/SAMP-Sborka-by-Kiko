script_name("RainbowClist")
script_version("0.0.1")
script_author("Kiko")

local sampev = require("lib.samp.events")
local imgui = require("imgui")
local inicfg = require("inicfg")
local encoding = require("encoding")
local sw, sh = getScreenResolution()

local directini = "moonloader\\rc_settings.ini"

local mainIni = inicfg.load(nil, directini)

encoding.default = "CP1251"
u8 = encoding.UTF8

local menu_window_state = imgui.ImBool(false) --статус main окна
local use_numbers = imgui.ImBool(mainIni.rc_settings.useNumbers) --использовать ли числа или нужно открывать диалоговое окно
local debugUI = imgui.ImBool(false)

showDialogID = false

local setDialoge = false

local clistDialogID = imgui.ImBuffer(""..mainIni.rc_settings.clistDialogID, 256)
local buttonDialogID = imgui.ImBuffer(""..mainIni.rc_settings.clistButtonID, 256)
local rainbowDelay = imgui.ImBuffer(""..mainIni.rc_settings.delay, 256)
local maxColors = imgui.ImBuffer(""..mainIni.rc_settings.maxColors, 256)
delay = 0
local nowclist = 0
isRainbowClistWork = false --работает ли рэйнбоу клист
openedDialog = false
isPickUP = false

function main()

	repeat wait(0) until isSampLoaded() and isSampAvailable()

	wait(50)
	sendMessage("{850AB9}RainbowClist{464446} by {850AB9}Kiko")
	sendMessage("{850AB9}/rcm{464446} - Настройки радужного клиста, {850AB9}/rc{464446} - вкл/выкл радужного клиста.")


	imgui.Process = true
	imgui.Process =  menu_window_state.v


	while true do

		wait(0)
		sampRegisterChatCommand("rcm", function()
			menu_window_state.v = not menu_window_state.v
			imgui.Process =  menu_window_state.v
		end)
		sampRegisterChatCommand("rc", function()
			BeginRainbow()
			setDialoge = true
			sampSendChat("/clist "..nowclist)
		end)
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
		imgui.Begin("[RainbowClistOptions] by Kiko", menu_window_state, imgui.WindowFlags.AlwaysAutoResize)
		apply_custom_style()
		imgui.SetCursorPosX(50)
		imgui.Text(u8"Настройки RainbowClist")
		imgui.Separator()
		if imgui.InputText(u8"Задержка в смене клистов: ", rainbowDelay) then
			mainIni.rc_settings.delay = rainbowDelay.v
			inicfg.save(mainIni, directini)
		end

		if imgui.InputText(u8"Максимальное количество цветов в клисте: ", maxColors) then
			mainIni.rc_settings.maxColors = maxColors.v
			inicfg.save(mainIni, directini)
		end

		if imgui.TreeNode(u8"Дополнительно") then

			imgui.Separator()
			if imgui.Checkbox(u8"Использовать числа? (/clist число)", use_numbers) then
				mainIni.rc_settings.useNumbers = use_numbers.v
				inicfg.save(mainIni, directini)
			end
			imgui.Separator()


			if imgui.InputText(u8"ID Диалога клиста: ", clistDialogID) then
				mainIni.rc_settings.clistDialogID = clistDialogID.v
				inicfg.save(mainIni, directini)
			end
			if imgui.InputText(u8"ID Кнопки в диалоге: ", buttonDialogID) then
				mainIni.rc_settings.clistButtonID = buttonDialogID.v
				inicfg.save(mainIni, directini)
			end
			if imgui.Checkbox(u8"Просмотр ID диалогов", debugUI) then
				showDialogID = debugUI.v
			end
			imgui.TreePop()
		end

		imgui.End()
	end
end

function BeginRainbow()
	lua_thread.create(function()
		if isRainbowClistWork == true then
			isRainbowClistWork = false

			sendMessage("{464446} Выключен.")

		else
			isRainbowClistWork = true

			sendMessage("{464446} Включен.")

		end


		while isRainbowClistWork == true do--
			isChatInput = sampIsChatInputActive()
			if isChatInput == false then---
				if openedDialog == false then----
					if isPickUP == false then-----
						wait(rainbowDelay.v)
						if use_numbers.v then  -- если используем прост цифры ------
							nowclist = nowclist + 1
							sampSendChat("/clist "..nowclist)

							if nowclist == mainIni.rc_settings.maxColors then-------
								nowclist = 0
							end-------

						else------
							nowclist = nowclist + 1
							sampSendChat("/clist")
							if nowclist == mainIni.rc_settings.maxColors then-------
								nowclist = 0
							end-------
						end------
					else
						wait(2000)
						isPickUP = false
					end
				else
					wait(750)
				end
			else
				wait(750)
			end---

		end--
	end)
end

--neon стиль
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
	colors[clr.Separator] = ImVec4(0.52, 0.04, 0.73, 1)
end


function sampev.onShowDialog(dialogId)

	if isPickUP and dialogId == mainIni.rc_settings.clistDialogID then
		sampSendDialogResponse(clistDialogID.v, buttonDialogID.v, nowclist, "")
		return false
	end

	if dialogId ~= mainIni.rc_settings.clistDialogID then
		openedDialog = true
	end

	if openedDialog and dialogId == mainIni.rc_settings.clistDialogID and isPickUP == false then
		sampSendDialogResponse(clistDialogID.v, buttonDialogID.v, nowclist, "")
		return false
	end

	if setDialoge then
		mainIni.rc_settings.clistDialogID = dialogId
		inicfg.save(mainIni, directini)
		clistDialogID = imgui.ImBuffer(""..dialogId, 256)
		mainIni = inicfg.load(nil, directini)
		setDialoge = false
	end

	if dialogId == mainIni.rc_settings.clistDialogID and use_numbers.v == false and isRainbowClistWork == true and openedDialog == false and isPickUP == false then
		sampSendDialogResponse(clistDialogID.v, buttonDialogID.v, nowclist, "")
		return false
	end
end

function sampev.onSendDialogResponse(dialogId, button, listboxId, input)
	openedDialog = false
	if showDialogID then
		sendMessage("ID Диалога - "..dialogId..", Кнопка - "..button..", ListBOX ID - "..listboxId..", Input - "..input)
	end
end

function sampev.onSendPickedUpPickup(pickUpId)
	if isRainbowClistWork then
		isPickUP = true
	end
end

function sendMessage(text)
	tag = '{464446}[Rainbow{850AB9}Clist{464446}]: {850AB9}'
	sampAddChatMessage(tag .. text, -1)
end

--если чат открыт остановить и потом продолжить
--если открылся другой диалог тоже остановить и потом продолжить
