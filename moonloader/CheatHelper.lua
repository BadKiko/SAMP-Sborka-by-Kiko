script_name("CheatHelper")
script_version("0.0.1")
script_author("Kiko")

local sampev = require("lib.samp.events")
local imgui = require("imgui")
local encoding = require("encoding")
local sw, sh = getScreenResolution()

encoding.default = "CP1251"
u8 = encoding.UTF8

local menu_window_state = imgui.ImBool(false) --������ main ����

function main()

	repeat wait(0) until isSampLoaded() and isSampAvailable()

	wait(0)
	sampAddChatMessage(" ")
	sendMessage("Created {464446}by{850AB9} Kiko")
	sendMessage("{464446}������� ���� ��������� - {850AB9}/chelp")
	sampAddChatMessage(" ")
	sampAddChatMessage("{464446}------------------------------------------------")
	sampAddChatMessage("{850AB9}                      Cheats By {c105ff}Kiko")
	sampAddChatMessage("{464446}------------------------------------------------")
	wait(150)
	sampAddChatMessage(" ")
	sampAddChatMessage("{464446}------------------------------------------------")
	sampAddChatMessage("{850AB9}              Cheats By {c105ff}MrCreepTon{850AB9}")
	sampAddChatMessage("{464446}------------------------------------------------")
	sampAddChatMessage(" ")
	wait(300)

	sampAddChatMessage(" ")
	sampAddChatMessage("{464446}------------------------------------------------")
	sampAddChatMessage("{850AB9}                    Cheats By {c105ff}Other{850AB9}")
	sampAddChatMessage("{464446}------------------------------------------------")
	sampAddChatMessage(" ")

	wait(700)
	sampAddChatMessage("{464446}[{850AB9}Invisible{464446}]:{850AB9} Created {464446}by{850AB9} quesada {464446}&{850AB9} S E V E N")
	sampAddChatMessage("{464446}[{850AB9}Invisible{464446}]:{850AB9} ������������ - /invis")

	sampAddChatMessage("{464446}[{850AB9}Gagarin{464446}]:{850AB9} Created {464446}by{850AB9} unknown")
	sampAddChatMessage("{464446}[{850AB9}Gagarin{464446}]:{850AB9} ������������ - /gg [id]")

	sampAddChatMessage("{464446}[Ga{850AB9}Car{464446}]:{850AB9} Created {464446}by{850AB9} unknown")
	sampAddChatMessage("{464446}[Ga{850AB9}Car{464446}]:{850AB9} ������������ - /gacar [id]")

	imgui.Process = true
	imgui.Process =  menu_window_state.v


	while true do

		wait(0)
		sampRegisterChatCommand("chelp", function()
			menu_window_state.v = not menu_window_state.v
			imgui.Process =  menu_window_state.v
		end)
		--������ ���������� ������
		if menu_window_state.v == false then
			imgui.ShowCursor = false
		else
			imgui.ShowCursor = true
		end
	end
end

local rcactivated = true -- ����������� �� ���������
local arvanka = true
local pomoyka = true
local air = true

--������ ����
function imgui.OnDrawFrame()
	--Main ����
	if menu_window_state.v then
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin("[CheatHelper] by Kiko", menu_window_state, imgui.WindowFlags.AlwaysAutoResize)
		apply_custom_style()
		if (imgui.TreeNode(u8"��� ����")) then
			imgui.Separator()


			if (imgui.TreeNode(u8"Kiko Cheats:")) then
				----------------------------------------------------    RAINBOW CLIST BY KIKO
				imgui.Separator()
				if (imgui.TreeNode(u8"1) RainbowClist - �������� ���.")) then
					if imgui.Button(u8"���������") then
						sampProcessChatInput("/rcm")
					end
					if rcactivated then
						if imgui.Button(u8"������������") then
							rcactivated = false
							sampProcessChatInput("/rc")
						end
					else
						if imgui.Button(u8"���������") then
							rcactivated = true
							sampProcessChatInput("/rc")
						end
					end
					imgui.TreePop()
				end

				----------------------------------------------------
				----------------------------------------------------    VCRASH BY MRCREEPTON MODIFY BY KIKO
				imgui.Separator()
				if (imgui.TreeNode(u8"2) VCrashModify - ����������� ������� [vcrash.lua by MrCreepTon].")) then
					imgui.Text(u8"      [ SHIFT + Z ] - ����� ���� ��� �����.")
					imgui.Text(u8"      [ SHIFT + X ] - ������� ������ ���������� ���� ������.")
					imgui.TreePop()
				end
				imgui.TreePop()

			end
			----------------------------------------------------
			----------------------------------------------------    VCRASH BY MRCREEPTON MODIFY BY KIKO
			imgui.Separator()
			if (imgui.TreeNode(u8"MrCreepTon Cheats:")) then
				imgui.Separator()
				if (imgui.TreeNode(u8"1) AntiRvanka - ���� ������.")) then
					if arvanka then
						if imgui.Button(u8"���������") then
							arvanka = false
							sampProcessChatInput("/antirv")
						end
					else
						if imgui.Button(u8"������������") then
							arvanka = true
							sampProcessChatInput("/antirv")
						end
					end
					imgui.TreePop()
				end

				imgui.Separator()
				if (imgui.TreeNode(u8"2) Airbrake - ������� ��������.")) then
					if air then
						if imgui.Button(u8"������������") then
							air = false
							sampProcessChatInput("/air")
						end
					else
						if imgui.Button(u8"���������") then
							air = true
							sampProcessChatInput("/air")
						end
					end
					imgui.TreePop()
				end

				imgui.TreePop()

			end

			imgui.Separator()
			if (imgui.TreeNode(u8"Other Cheats:")) then
				imgui.Separator()
				if (imgui.TreeNode(u8"1) F-CAR - ������� ��� �����.")) then
					imgui.Text(u8"[ CTRL + X ] - ������� ����.")

					if imgui.Button(u8"- ������. (/frv)") then
						sampSetChatInputText("/frv ")
						sampSetChatInputEnabled(true)
					end
					if imgui.Button(u8"- �������� �� ������������ �����. (/fs)") then
						sampSetChatInputText("/fs ")
						sampSetChatInputEnabled(true)
					end
					if imgui.Button(u8"- �������� �� ������������ �����. (/fss)") then
						sampSetChatInputText("/fss ")
						sampSetChatInputEnabled(true)
					end
					if imgui.Button(u8"- �����. (/fkk)") then
						sampSetChatInputText("/fkk ")
						sampSetChatInputEnabled(true)
					end


					imgui.TreePop()
				end

				imgui.Separator()
				if (imgui.TreeNode(u8"2) PomoykaMod - ������ ��� � ���.")) then
					imgui.Text(u8"�������������: ������� � ������ �/� � ������ ������ ������ � ��� �/�")

					if pomoyka then
						if imgui.Button(u8"������������") then
							pomoyka = false
							sampProcessChatInput("/pomoyka")
						end
					else
						if imgui.Button(u8"���������") then
							pomoyka = true
							sampProcessChatInput("/pomoyka")
						end
					end


					imgui.TreePop()
				end

				imgui.Separator()
				if (imgui.TreeNode(u8"3) GaCar - ������ ��������� ����� �� ������.")) then
					if imgui.Button(u8"/gacar [id]") then
						sampSetChatInputText("/gacar ")
						sampSetChatInputEnabled(true)
					end

					imgui.TreePop()
				end

				imgui.Separator()
				if (imgui.TreeNode(u8"4) Gagarin - ������ ������ ���� ����� �� ������, ������� press F.")) then
					if imgui.Button(u8"/gg [id]") then
						sampSetChatInputText("/gg ")
						sampSetChatInputEnabled(true)
					end

					imgui.TreePop()
				end

				imgui.Separator()
				if (imgui.TreeNode(u8"5) CarSlapper - ������ ������ � �����.")) then
					if imgui.Button(u8"/cslap [id]") then
						sampSetChatInputText("/cslap ")
						sampSetChatInputEnabled(true)
					end

					imgui.TreePop()
				end

				imgui.Separator()
				if (imgui.TreeNode(u8"5) Cordmaster ITP - ���������� by damag.")) then
					if imgui.Button(u8"/itp") then
						sampProcessChatInput("/itp")
					end

					imgui.TreePop()
				end



				imgui.TreePop()

			end

			imgui.TreePop()

		end
		----------------------------------------------------
		imgui.End()
	end
end


--Orange �����
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
	tag = '{464446}[Cheat{850AB9}Helper{464446}]: {850AB9}'
	sampAddChatMessage(tag .. text, -1)
end
