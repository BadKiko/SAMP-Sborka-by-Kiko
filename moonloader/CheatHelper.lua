script_name("CheatHelper")
script_version("0.0.1")
script_author("Kiko")

local sampev = require("lib.samp.events")
local imgui = require("imgui")
local encoding = require("encoding")
local sw, sh = getScreenResolution()
local inicfg  = require 'inicfg'


local dlstatus = require("moonloader").download_status

encoding.default = "CP1251"
u8 = encoding.UTF8




update_status = false

local script_vers = 10
local script_vers_text = "1.03.6"

local update_url = "https://raw.githubusercontent.com/BadKiko/SAMP-Sborka-by-Kiko/main/moonloader/updateCheatHelp.ini"
local update_path = getWorkingDirectory().."/updateCheatHelp.ini"

local script_url = "https://raw.githubusercontent.com/BadKiko/SAMP-Sborka-by-Kiko/main/moonloader/CheatHelper.lua"
local script_path = thisScript().path




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
	


	--UPDATE

	downloadUrlToFile(update_url, update_path, function(id, status)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			updateIni = inicfg.load(nil,update_path)
			if tonumber(updateIni.script_info.vers) > script_vers then
				sendMessage("Dungeon Master ����� ����������! ��������� {464446}<CheatHelper>{850AB9} �� ������:{464446} "..updateIni.script_info.vers_text)
				update_status = true
			else
				sendMessage("Slave, �� ��������, � ���� ��������� ������ {464446}<CheatHelper> - "..updateIni.script_info.vers_text.."!")
			end
			os.remove(update_path)
		end
	end)



	sampRegisterChatCommand("chelp", function()
		menu_window_state.v = not menu_window_state.v
		imgui.Process =  menu_window_state.v
	end)

	while true do
		wait(0)
		--������ ���������� ������
		if menu_window_state.v == false then
			imgui.ShowCursor = false
		else
			imgui.ShowCursor = true
		end
		
		if(isKeyJustPressed(72) and isKeyJustPressed(18)) then
			menu_window_state.v = not menu_window_state.v
			imgui.Process =  menu_window_state.v
		end


		--Update

		if update_status then
			downloadUrlToFile(script_url, script_path, function(id, status)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then
					sendMessage("Dungeon Master ������� ������� {464446}<CheatHelper>!")
					thisScript():reload()
				end
			end)
			break
		end

	end
end

local rcactivated = true -- ����������� �� ���������
local arvanka = true
local pomoyka = true
local air = true
local egun = true
local invis = true
local jopotrah = true
local entercrasher = true
local stopcars = true
local butilka = true
local carshooter = true
local ecar = true
local ecaron = true
local cra = false
local rvx = true
local bpfly = true
local rcds = true
local wd = true
local sdmg = true

--������ ����
function imgui.OnDrawFrame()
	--Main ����
	if menu_window_state.v then
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2) + 300, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin("[CheatHelper] by Kiko | Version: "..script_vers_text, menu_window_state, imgui.WindowFlags.AlwaysAutoResize)
		apply_custom_style()
		imgui.Text(u8'��� ������, ��� ��� ������:')
		imgui.Separator()

		if (imgui.TreeNode(u8"��� ����")) then
			imgui.Separator()


			if (imgui.TreeNode(u8"Kiko Cheats:")) then
				----------------------------------------------------    RAINBOW CLIST BY KIKO
				imgui.Separator()
				if (imgui.TreeNode(u8"1) RainbowClist - �������� ���.")) then
					if imgui.Button(u8"���������") then
						sampProcessChatInput("/rcm")
					end
					imgui.Separator()
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
				imgui.Separator()
				if (imgui.TreeNode(u8"2) VCrashModify - ����������� ������� [vcrash.lua by MrCreepTon].")) then
					imgui.Text(u8"      [ LCTRL + Z ] - ����� ���� ��� �����.")
					imgui.Text(u8"      [ LCTRL + X ] - ������� ������ ���������� ���� ������.")
					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"3) AntiSpamForMaksQSpammer - ���� ������� �� ����� ������ MaksQ.")) then
					if imgui.Button(u8"������� ����") then
						sampProcessChatInput("/antispam")
					end
					imgui.TreePop()
				end

				imgui.Separator()
				if (imgui.TreeNode(u8"4) SpamMer - ������� ������� �������, ������� � ������ � ����� ��� ���������� ��������.")) then
					if imgui.Button(u8"/spammer [id]") then
						sampSetChatInputText("/spammer ")
						sampSetChatInputEnabled(true)
					end
					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"5) StopPer - �� ������ ���� � ��, �������� ������ ���� ������ ������������� ������ � ��, ������ ���� ��� � ������.")) then
						if imgui.Button(u8"������ �������") then
							sampProcessChatInput("/st")
						end
					
					imgui.Separator()

					if imgui.Button(u8"���������") then
						sampProcessChatInput("/smn")
					end
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

				imgui.Separator()
				if (imgui.TreeNode(u8"3) EGun - ������ ������, �� ��������� �������� ��������.")) then
					if egun then
						if imgui.Button(u8"������������") then
							egun = false
							sampProcessChatInput("/egun")
						end
					else
						if imgui.Button(u8"���������") then
							egun = true
							sampProcessChatInput("/egun")
						end
					end
					imgui.TreePop()
				end

				imgui.Separator()
				if (imgui.TreeNode(u8"4) ByPasser OLD - ����� �� ������ ��� ����������� (������).")) then
					if imgui.Button(u8"������������") then
						sampProcessChatInput("/bp")
					end

					if imgui.Button(u8"������ ������ ������") then
						sampProcessChatInput("/bp2")
					end
					imgui.TreePop()
				end

				imgui.Separator()
				if (imgui.TreeNode(u8"5) ByPasser NEW - ����� �� ������ ��� ����������� (�����).")) then
					imgui.Text(u8'��������� ��� ���-��� - BP')

					if imgui.Button(u8"- ��������� ����� ����. (/lname)") then
						sampSetChatInputText("/lname ")
						sampSetChatInputEnabled(true)
					end
					imgui.TreePop()
				end

				imgui.Separator()
				if (imgui.TreeNode(u8"6) Syncer - ������ � ������.")) then
					if imgui.Button(u8"������� ����") then
						sampProcessChatInput("/syncer")
					end
					imgui.TreePop()
				end

				imgui.Separator()
				if (imgui.TreeNode(u8"7) Invisible - ���������� ��� ��� �����, � ���� ���� ��, ��� ��� ������!")) then
					if invis then
						if imgui.Button(u8"������������") then
							invis = false
							sampProcessChatInput("/invis")
						end
					else
						if imgui.Button(u8"���������") then
							invis = true
							sampProcessChatInput("/invis")
						end
					end
					imgui.Separator()
					if imgui.Button(u8"���������") then
						sampProcessChatInput("/invismenu")
					end
					imgui.TreePop()
				end

				imgui.Separator()
				if (imgui.TreeNode(u8"8) JopoTrah - ������ ����, ������������ � ���������.")) then
					if jopotrah then
						if imgui.Button(u8"���������") then
							jopotrah = false
							sampProcessChatInput("/jt")
						end
					else
						if imgui.Button(u8"������������") then
							jopotrah = true
							sampProcessChatInput("/jt")
						end
					end
					imgui.TreePop()
				end

				imgui.Separator()
				if (imgui.TreeNode(u8"9) SPoka - �������.")) then
					if imgui.Button(u8"/spoka [id ������]") then
						sampSetChatInputText("/spoka ")
						sampSetChatInputEnabled(true)
					end

					imgui.Separator()
					if imgui.Button(u8"���������") then
						sampProcessChatInput("/spoka.menu")
					end
					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"10) Butilka - ��� ����� ���������, ������ ������ ����� ��� �������� ����� � �/�.")) then
					if butilka then
						if imgui.Button(u8"��������") then
							butilka = false
							sampProcessChatInput("/butilka")
						end
					else
						if imgui.Button(u8"���������") then
							butilka = true
							sampProcessChatInput("/butilka")
						end
					end

					imgui.Separator()
					if imgui.Button(u8"���������") then
						sampProcessChatInput("/butilka.menu")
					end
					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"11) UndergroundDeath - ���������� ������ ��� �����, �����, ������������� � ������.")) then
					if imgui.Button(u8"/ud [id ������]") then
						sampSetChatInputText("/ud ")
						sampSetChatInputEnabled(true)
					end
					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"12) ASTeleportCheckpoint - ��������, ����� �������� ��� ����� ���� � �����-������ ��������� � ����� �� ���� ����� �����!.")) then
					if imgui.Button(u8"�������� �� �����") then
						sampProcessChatInput("/astpch")
					end
					if imgui.Button(u8"�������� �� ��������� �����") then
						sampProcessChatInput("/astpnch")
					end
					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"13) ASTeleport - ���� ��������, ����� ���� ������ � �����, ���� ����� ���� �� �� ���� ������.")) then
					if imgui.Button(u8"�������� �� �����") then
						sampProcessChatInput("/astp")
					end
					if imgui.Button(u8"�������� �� ��������� �����") then
						sampProcessChatInput("/astpn")
					end
					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"14) Knockdown - �� ������� �����, �������� � ������ ����� � ���������� ��� � ������.")) then
					if imgui.Button(u8"/knock [id ��] [id ������]") then
						sampSetChatInputText("/knock ")
						sampSetChatInputEnabled(true)
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
						if imgui.Button(u8"��������") then
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
				if (imgui.TreeNode(u8"6) Cordmaster ITP - ���������� by damag.")) then
					if imgui.Button(u8"/itp") then
						sampProcessChatInput("/itp")
					end

					imgui.TreePop()
				end

				imgui.Separator()
				if (imgui.TreeNode(u8"7) Slapper [�������� RAGE] - ������� ������ ����� � ����� ��������� � ���� �� �����, ���������� �������.")) then
					if imgui.Button(u8"/slp [id]") then
						sampSetChatInputText("/slp ")
						sampSetChatInputEnabled(true)
					end
					imgui.Separator()
					if imgui.Button(u8"���������") then
						sampProcessChatInput("/slp.menu")
					end

					imgui.TreePop()
				end


				imgui.Separator()
				if (imgui.TreeNode(u8"8) FPS UP - ������� ����� �� ������ �������, ������� ������.")) then
					if imgui.Button(u8"������� ����") then
						sampProcessChatInput("/ufps")
					end

					imgui.TreePop()
				end

				imgui.Separator()
				if (imgui.TreeNode(u8"9) InCarTP - �������� � ������.")) then
					if imgui.Button(u8"�������� �� �����") then
						sampProcessChatInput("/itp")
					end
					imgui.Separator()
					if imgui.Button(u8"�������� �� ��������") then
						sampProcessChatInput("/itpc")
					end
					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"10) UltraFUCK - ������������� ���.")) then
					if imgui.Button(u8"������� ������������ ������") then
						sampProcessChatInput("/ff")
					end
					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"11) Megaladon ��������� - ��� ��� �����.")) then
					if imgui.Button(u8"������� ����") then
						sampProcessChatInput("/ca")
					end
					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"12) EnterCrasher - �� �� ����� ��� � ������� �� MrCreepTon.")) then
					if entercrasher then
						if imgui.Button(u8"��������") then
							entercrasher = false
							sampProcessChatInput("/ecrash")
						end
					else
						if imgui.Button(u8"���������") then
							entercrasher = true
							sampProcessChatInput("/ecrash")
						end
					end

					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"13) StopCars - ��������� ���� ����� � ������, ������� �������� � EnterCrasher.")) then
					if stopcars then
						if imgui.Button(u8"��������") then
							stopcars = false
							sampProcessChatInput("/stopcars")
						end
					else
						if imgui.Button(u8"���������") then
							stopcars = true
							sampProcessChatInput("/stopcars")
						end
					end
					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"14) SCar - ���� Gacar, �� ������ ��� 1 ������, ����� ������� ���������.")) then
					if imgui.Button(u8"/scar [id �����] [id ������]") then
						sampSetChatInputText("/scar ")
						sampSetChatInputEnabled(true)
					end

					imgui.TreePop()
				end

				imgui.Separator()
				if (imgui.TreeNode(u8"15) CarShooter - ��� ��������, ������ � ����� ��������.")) then
					if carshooter then
						if imgui.Button(u8"��������") then
							carshooter = false
							sampProcessChatInput("/cs")
						end
					else
						if imgui.Button(u8"���������") then
							carshooter = true
							sampProcessChatInput("/cs")
						end
					end

					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"16) EnterCarDRP - ����� � ���� ����, ������ ��� ������, �.�, �� �� ��������!.")) then
					if ecar then
						if imgui.Button(u8"�������� bypass") then
							ecar = false
							sampProcessChatInput("/ecar")
						end
					else
						if imgui.Button(u8"��������� bypass") then
							ecar = true
							sampProcessChatInput("/ecar")
						end
					end

					imgui.Separator()

					if ecaron then
						if imgui.Button(u8"�������� ���� �� ����") then
							ecaron = false
							sampProcessChatInput("/ecaron")
						end
					else
						if imgui.Button(u8"��������� ���� �� ����") then
							ecaron = true
							sampProcessChatInput("/ecaron")
						end
					end
					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"17) KickASS - ���� ������ ������, � ��� �� �� ����� ��� � Underground Death.")) then
					if imgui.Button(u8"/cra [id ������]") then
						sampSetChatInputText("/cra ")
						cra = true
						sampSetChatInputEnabled(true)
					end
					imgui.Separator()
					if imgui.Button(u8"������� ���� � ���� ������") then
						cra = true
						sampProcessChatInput("/cra all")
					end

					if cra then
						imgui.Separator()
						if imgui.Button(u8"���������") then
							cra = false
							sampProcessChatInput("/crs")
						end
					end
					imgui.Separator()
					if rvx then
						if imgui.Button(u8"!�������� ����� ������ ������!") then
							rvx = false
							sampProcessChatInput("/rvx")
						end
					else
						if imgui.Button(u8"!��������� ����� ������ ������!") then
							rvx = true
							sampProcessChatInput("/rvx")
						end
					end
					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"18) FlyBypass - ��������� ������������ ���� �� ��������� ��������.")) then
					if bpfly then
						if imgui.Button(u8"��������") then
							bpfly = false
							sampProcessChatInput("/bpfly")
						end
					else
						if imgui.Button(u8"���������") then
							bpfly = true
							sampProcessChatInput("/bpfly")
						end
					end

					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"19) SkinC - ����� ����� ��������!")) then
					if imgui.Button(u8"������� ����") then
						sampProcessChatInput("/skinc")
					end

					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"20) Dammager - ������� ��������, ������� �����.")) then
					if imgui.Button(u8"/admg [id ������]") then
						sampSetChatInputText("/admg ")
						sampSetChatInputEnabled(true)
					end

					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"21) RollCrasher - ������, ����� ��������� ����� ����� ������� �����.")) then
					if rcds then
						if imgui.Button(u8"��������") then
							rcds = false
							sampProcessChatInput("/rcds")
						end
					else
						if imgui.Button(u8"���������") then
							rcds = true
							sampProcessChatInput("/rcds")
						end
					end

					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"22) WheelDestroyer - �������� �������� ����� � ����, ����� �������� ������ �� �� ��� �����.")) then
					if imgui.Button(u8"/wd [id ����]") then
						sampSetChatInputText("/wd ")
						sampSetChatInputEnabled(true)
					end

					imgui.Separator()
					imgui.Text(u8'�������� �� ��� ����� � ������� �� ��������')
					if wd then
						if imgui.Button(u8"��������") then
							wd = false
							sampProcessChatInput("/wda")
						end
					else
						if imgui.Button(u8"���������") then
							wd = true
							sampProcessChatInput("/wda")
						end
					end

					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"23) SDMG - ������ �������, ��������� ��������.")) then
					if sdmg then
						if imgui.Button(u8"��������") then
							sdmg = false
							sampProcessChatInput("/sdmg")
						end
					else
						if imgui.Button(u8"���������") then
							sdmg = true
							sampProcessChatInput("/sdmg")
						end
					end
					imgui.Separator()
					imgui.Text(u8'�������� � ������, ����� ���� ������ � ������, ����� �������� ������� R')
					if imgui.Button(u8"/sdmg_kid [id]") then
						sampSetChatInputText("/sdmg_kid ")
						sampSetChatInputEnabled(true)
					end
					imgui.Separator()
					imgui.Text(u8'�� ������ ����������� ��������� ������� � ����� _***')
					if imgui.Button(u8"/sdmg_") then
						sampSetChatInputText("/sdmg_")
						sampSetChatInputEnabled(true)
					end
					imgui.Text(u8'/sdmg_mode 0-3 - ����� ������')
					imgui.Text(u8'/sdmg_frac - ����� ������� ������ frac ������� �������� aztec,vagos,rifa,ballas,grove (���� �������� - all)')
					imgui.Text(u8'/sdmg_time - ���������� �������� ����� ����������')
					imgui.Text(u8'/sdmg_gun - ������� ��� ��� ������')
					imgui.Text(u8'/sdmg_radius - ���������� ������ ������')
					imgui.Text(u8'/sdmg_miss - ���������/���������� �������')
					imgui.Text(u8'/sdmg_smiss - ���������� ����� ����� ������ ������ ������')
					imgui.Text(u8'/sdmg_antiwrn - ����������� �� �������� ����')
					imgui.Text(u8'/sdmg_bl [id] - �������� � ���� ���� (������ ����� �������� ��������, � ����� �������� �� �������)')
					imgui.Text(u8'/sdmg_dbl - ������ �� ���� �����')
					imgui.Text(u8'/sdmg_ig id - �������� � ����� ���� (�� ����� �������� ������� ������� � ����� �����)')
					imgui.Text(u8'/sdmg_dig - ������ � ����� �����')
					imgui.Text(u8'/sdmg_nokill - �������� �� ����')
					imgui.Text(u8'/sdmg_snokill - �� ��� �� �����')
					imgui.Text(u8'/sdmg_antifrac - �������� ���� ����� �������� �������')
					imgui.Text(u8'/sdmg_dmg - ��� �� id ������')
					imgui.Text(u8'/sdmg_none - �������� ������� �� none')
					imgui.Text(u8'/sdmg_kid [id] - ����� ������� �� ���')
					imgui.Text(u8'/sdmg_kt - ����� ������� ��� ������������ �� ������')
					imgui.Text(u8'/sdmg_pos - ������� ������� ������� (������ ��� ��� ���������� �������)')
					imgui.Text(u8'/sdmg_save - ��������� ������� ��������� (������ /sdmg_save test)')
					imgui.Text(u8'/sdmg test - ��������� ��������� "test" (����� �������� ����� �������� �� ���������)')
					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"24) CarFuncsLUA_0.3.3 - �������� ��������.")) then
					if imgui.Button(u8"������� ����") then
						sampProcessChatInput("/cf.menu")
					end

					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"25) CarFuncsCLEO - �������� ��������.")) then
					imgui.Text(u8'/bc - �������� ������� ������ �� ������, ��� SCar')
					if imgui.Button(u8"/bc [id ����]") then
						sampSetChatInputText("/bc ")
						sampSetChatInputEnabled(true)
					end
					imgui.Separator()
					imgui.Text(u8'/bcc - ������� �����')
					if imgui.Button(u8"/bcc [id ����]") then
						sampSetChatInputText("/bcc ")
						sampSetChatInputEnabled(true)
					end
					imgui.Separator()
					imgui.Text(u8'/ctp - ������� ������ � ������ ��� �������� ����� � ����')
					if imgui.Button(u8"/ctp [id ����]") then
						sampSetChatInputText("/ctp  ")
						sampSetChatInputEnabled(true)
					end
					imgui.Separator()
					imgui.Text(u8'/crp - �������� ������')
					if imgui.Button(u8"/crp [id ����]") then
						sampSetChatInputText("/crp  ")
						sampSetChatInputEnabled(true)
					end
					imgui.Separator()
					imgui.Text(u8'/mrp  - �������� ������ � ������� �� ������')
					if imgui.Button(u8"/mrp  [id ����]") then
						sampSetChatInputText("/mrp   ")
						sampSetChatInputEnabled(true)
					end
					imgui.Separator()
					if imgui.Button(u8"������ �������") then
						sampProcessChatInput("/cinfo")
					end
					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"26) WattiWeaponCheat - ������ ������ �� �� ��������� ������ ��� �������������.")) then
					if imgui.Button(u8"������ �������") then
						sampProcessChatInput("/whelp")
					end

					imgui.TreePop()
				end





				imgui.TreePop()
			end
			imgui.TreePop()
		end
		if imgui.TreeNode(u8"������") then
			imgui.Text(u8'���� �� ����������� ������, �� � ��� ����� ����������� ������ �����, �� ������ �������� ������.')
			imgui.Separator()
			if imgui.Button(u8'������ ��� ����� ������� ��� ����') then
				os.execute("start https://github.com/BadKiko/SAMP-Sborka-by-Kiko/releases")
			end
			imgui.Separator()
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
