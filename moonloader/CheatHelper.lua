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




local menu_window_state = imgui.ImBool(false) --статус main окна

function main()

	repeat wait(0) until isSampLoaded() and isSampAvailable()

	wait(0)
	sampAddChatMessage(" ")
	sendMessage("Created {464446}by{850AB9} Kiko")
	sendMessage("{464446}Открыть окно помощника - {850AB9}/chelp")
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
	sampAddChatMessage("{464446}[{850AB9}Invisible{464446}]:{850AB9} Активировать - /invis")

	sampAddChatMessage("{464446}[{850AB9}Gagarin{464446}]:{850AB9} Created {464446}by{850AB9} unknown")
	sampAddChatMessage("{464446}[{850AB9}Gagarin{464446}]:{850AB9} Активировать - /gg [id]")

	sampAddChatMessage("{464446}[Ga{850AB9}Car{464446}]:{850AB9} Created {464446}by{850AB9} unknown")
	sampAddChatMessage("{464446}[Ga{850AB9}Car{464446}]:{850AB9} Активировать - /gacar [id]")

	imgui.Process = true
	imgui.Process =  menu_window_state.v
	


	--UPDATE

	downloadUrlToFile(update_url, update_path, function(id, status)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			updateIni = inicfg.load(nil,update_path)
			if tonumber(updateIni.script_info.vers) > script_vers then
				sendMessage("Dungeon Master нашел обновление! Обновляем {464446}<CheatHelper>{850AB9} до версии:{464446} "..updateIni.script_info.vers_text)
				update_status = true
			else
				sendMessage("Slave, ты красавец, у тебя последняя версия {464446}<CheatHelper> - "..updateIni.script_info.vers_text.."!")
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
		--прячем показываем курсор
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
					sendMessage("Dungeon Master успешно обновил {464446}<CheatHelper>!")
					thisScript():reload()
				end
			end)
			break
		end

	end
end

local rcactivated = true -- Активирован ли рэинклист
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

--Рисуем меню
function imgui.OnDrawFrame()
	--Main меню
	if menu_window_state.v then
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2) + 300, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin("[CheatHelper] by Kiko | Version: "..script_vers_text, menu_window_state, imgui.WindowFlags.AlwaysAutoResize)
		apply_custom_style()
		imgui.Text(u8'Хай сучара, вот все читики:')
		imgui.Separator()

		if (imgui.TreeNode(u8"Все читы")) then
			imgui.Separator()


			if (imgui.TreeNode(u8"Kiko Cheats:")) then
				----------------------------------------------------    RAINBOW CLIST BY KIKO
				imgui.Separator()
				if (imgui.TreeNode(u8"1) RainbowClist - радужный ник.")) then
					if imgui.Button(u8"Настройки") then
						sampProcessChatInput("/rcm")
					end
					imgui.Separator()
					if rcactivated then
						if imgui.Button(u8"Активировать") then
							rcactivated = false
							sampProcessChatInput("/rc")
						end
					else
						if imgui.Button(u8"Отключить") then
							rcactivated = true
							sampProcessChatInput("/rc")
						end
					end
					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"2) VCrashModify - модификация крашера [vcrash.lua by MrCreepTon].")) then
					imgui.Text(u8"      [ LCTRL + Z ] - Выбор цели для краша.")
					imgui.Text(u8"      [ LCTRL + X ] - Сменить способ обновления зоны стрима.")
					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"3) AntiSpamForMaksQSpammer - Анти спаммер от ботов пидора MaksQ.")) then
					if imgui.Button(u8"Открыть меню") then
						sampProcessChatInput("/antispam")
					end
					imgui.TreePop()
				end

				imgui.Separator()
				if (imgui.TreeNode(u8"4) SpamMer - Попытка сделать спаммер, тпшится в игрока и дохуя раз показывает пасспорт.")) then
					if imgui.Button(u8"/spammer [id]") then
						sampSetChatInputText("/spammer ")
						sampSetChatInputEnabled(true)
					end
					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"5) StopPer - Вы должны быть в ЗЗ, работает только если игроку высвечивается диалог в ЗЗ, стопит всех кто в стриме.")) then
						if imgui.Button(u8"Начать веселье") then
							sampProcessChatInput("/st")
						end
					
					imgui.Separator()

					if imgui.Button(u8"Настройки") then
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
				if (imgui.TreeNode(u8"1) AntiRvanka - анти рванка.")) then
					if arvanka then
						if imgui.Button(u8"Отключить") then
							arvanka = false
							sampProcessChatInput("/antirv")
						end
					else
						if imgui.Button(u8"Активировать") then
							arvanka = true
							sampProcessChatInput("/antirv")
						end
					end
					imgui.TreePop()
				end

				imgui.Separator()
				if (imgui.TreeNode(u8"2) Airbrake - обычный аирбрейк.")) then
					if air then
						if imgui.Button(u8"Активировать") then
							air = false
							sampProcessChatInput("/air")
						end
					else
						if imgui.Button(u8"Отключить") then
							air = true
							sampProcessChatInput("/air")
						end
					end
					imgui.TreePop()
				end

				imgui.Separator()
				if (imgui.TreeNode(u8"3) EGun - выдача оружия, на некоторых серверах работает.")) then
					if egun then
						if imgui.Button(u8"Активировать") then
							egun = false
							sampProcessChatInput("/egun")
						end
					else
						if imgui.Button(u8"Отключить") then
							egun = true
							sampProcessChatInput("/egun")
						end
					end
					imgui.TreePop()
				end

				imgui.Separator()
				if (imgui.TreeNode(u8"4) ByPasser OLD - заход на сервер без авторизации (СТАРЫЙ).")) then
					if imgui.Button(u8"Активировать") then
						sampProcessChatInput("/bp")
					end

					if imgui.Button(u8"Второй способ обхода") then
						sampProcessChatInput("/bp2")
					end
					imgui.TreePop()
				end

				imgui.Separator()
				if (imgui.TreeNode(u8"5) ByPasser NEW - заход на сервер без авторизации (НОВЫЙ).")) then
					imgui.Text(u8'Активация как чит-код - BP')

					if imgui.Button(u8"- Локальная смена ника. (/lname)") then
						sampSetChatInputText("/lname ")
						sampSetChatInputEnabled(true)
					end
					imgui.TreePop()
				end

				imgui.Separator()
				if (imgui.TreeNode(u8"6) Syncer - Работа с НОПами.")) then
					if imgui.Button(u8"Открыть меню") then
						sampProcessChatInput("/syncer")
					end
					imgui.TreePop()
				end

				imgui.Separator()
				if (imgui.TreeNode(u8"7) Invisible - Утаскивает вас под землю, у кого есть ВХ, тот вас спалит!")) then
					if invis then
						if imgui.Button(u8"Активировать") then
							invis = false
							sampProcessChatInput("/invis")
						end
					else
						if imgui.Button(u8"Отключить") then
							invis = true
							sampProcessChatInput("/invis")
						end
					end
					imgui.Separator()
					if imgui.Button(u8"Настройки") then
						sampProcessChatInput("/invismenu")
					end
					imgui.TreePop()
				end

				imgui.Separator()
				if (imgui.TreeNode(u8"8) JopoTrah - рванит жопы, использовать с пассажира.")) then
					if jopotrah then
						if imgui.Button(u8"Отключить") then
							jopotrah = false
							sampProcessChatInput("/jt")
						end
					else
						if imgui.Button(u8"Активировать") then
							jopotrah = true
							sampProcessChatInput("/jt")
						end
					end
					imgui.TreePop()
				end

				imgui.Separator()
				if (imgui.TreeNode(u8"9) SPoka - слаппер.")) then
					if imgui.Button(u8"/spoka [id жертвы]") then
						sampSetChatInputText("/spoka ")
						sampSetChatInputEnabled(true)
					end

					imgui.Separator()
					if imgui.Button(u8"Настройки") then
						sampProcessChatInput("/spoka.menu")
					end
					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"10) Butilka - она самая бутылОчка, крашит игрока когда тот пытается войти в т/с.")) then
					if butilka then
						if imgui.Button(u8"Включить") then
							butilka = false
							sampProcessChatInput("/butilka")
						end
					else
						if imgui.Button(u8"Выключить") then
							butilka = true
							sampProcessChatInput("/butilka")
						end
					end

					imgui.Separator()
					if imgui.Button(u8"Настройки") then
						sampProcessChatInput("/butilka.menu")
					end
					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"11) UndergroundDeath - утаскивает чувака под землю, кикер, использование с машины.")) then
					if imgui.Button(u8"/ud [id жертвы]") then
						sampSetChatInputText("/ud ")
						sampSetChatInputEnabled(true)
					end
					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"12) ASTeleportCheckpoint - Телепорт, чтобы сработал вам нужно быть в каком-нибудь интерьере и выйти из него через пикап!.")) then
					if imgui.Button(u8"Телепорт на метку") then
						sampProcessChatInput("/astpch")
					end
					if imgui.Button(u8"Телепорт на серверную метку") then
						sampProcessChatInput("/astpnch")
					end
					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"13) ASTeleport - Тупа телепорт, нужно либо сидеть в тачке, либо чтобы куда вы тп была машина.")) then
					if imgui.Button(u8"Телепорт на метку") then
						sampProcessChatInput("/astp")
					end
					if imgui.Button(u8"Телепорт на серверную метку") then
						sampProcessChatInput("/astpn")
					end
					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"14) Knockdown - Оч веселая штука, забирает у игрока тачку и отправляет его в космос.")) then
					if imgui.Button(u8"/knock [id тс] [id жертвы]") then
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
				if (imgui.TreeNode(u8"1) F-CAR - Функции для каров.")) then
					imgui.Text(u8"[ CTRL + X ] - Открыть меню.")

					if imgui.Button(u8"- Рванка. (/frv)") then
						sampSetChatInputText("/frv ")
						sampSetChatInputEnabled(true)
					end
					if imgui.Button(u8"- Телепорт на Водительское место. (/fs)") then
						sampSetChatInputText("/fs ")
						sampSetChatInputEnabled(true)
					end
					if imgui.Button(u8"- Телепорт на Пассажирское место. (/fss)") then
						sampSetChatInputText("/fss ")
						sampSetChatInputEnabled(true)
					end
					if imgui.Button(u8"- Кикер. (/fkk)") then
						sampSetChatInputText("/fkk ")
						sampSetChatInputEnabled(true)
					end


					imgui.TreePop()
				end

				imgui.Separator()
				if (imgui.TreeNode(u8"2) PomoykaMod - Хуячит все и вся.")) then
					imgui.Text(u8"Использование: Подойти к любому т/с и просто начать бежать в это т/с")

					if pomoyka then
						if imgui.Button(u8"Включить") then
							pomoyka = false
							sampProcessChatInput("/pomoyka")
						end
					else
						if imgui.Button(u8"Отключить") then
							pomoyka = true
							sampProcessChatInput("/pomoyka")
						end
					end


					imgui.TreePop()
				end

				imgui.Separator()
				if (imgui.TreeNode(u8"3) GaCar - Кидаем подожённые тачки на игрока.")) then
					if imgui.Button(u8"/gacar [id]") then
						sampSetChatInputText("/gacar ")
						sampSetChatInputEnabled(true)
					end

					imgui.TreePop()
				end

				imgui.Separator()
				if (imgui.TreeNode(u8"4) Gagarin - Хуячит игрока вниз вверх до смерти, Гагарин press F.")) then
					if imgui.Button(u8"/gg [id]") then
						sampSetChatInputText("/gg ")
						sampSetChatInputEnabled(true)
					end

					imgui.TreePop()
				end

				imgui.Separator()
				if (imgui.TreeNode(u8"5) CarSlapper - Хуячит игрока в тачке.")) then
					if imgui.Button(u8"/cslap [id]") then
						sampSetChatInputText("/cslap ")
						sampSetChatInputEnabled(true)
					end

					imgui.TreePop()
				end

				imgui.Separator()
				if (imgui.TreeNode(u8"6) Cordmaster ITP - Кордмастер by damag.")) then
					if imgui.Button(u8"/itp") then
						sampProcessChatInput("/itp")
					end

					imgui.TreePop()
				end

				imgui.Separator()
				if (imgui.TreeNode(u8"7) Slapper [Чпокалка RAGE] - Херачит чувака вверх а потом разбивает к хуям об землю, улучшенный Гагарин.")) then
					if imgui.Button(u8"/slp [id]") then
						sampSetChatInputText("/slp ")
						sampSetChatInputEnabled(true)
					end
					imgui.Separator()
					if imgui.Button(u8"Настройки") then
						sampProcessChatInput("/slp.menu")
					end

					imgui.TreePop()
				end


				imgui.Separator()
				if (imgui.TreeNode(u8"8) FPS UP - Убирает нахер не нужные объекты, повышая фепесы.")) then
					if imgui.Button(u8"Открыть меню") then
						sampProcessChatInput("/ufps")
					end

					imgui.TreePop()
				end

				imgui.Separator()
				if (imgui.TreeNode(u8"9) InCarTP - Телепорт в машине.")) then
					if imgui.Button(u8"Телепорт на метку") then
						sampProcessChatInput("/itp")
					end
					imgui.Separator()
					if imgui.Button(u8"Телепорт на чекпоинт") then
						sampProcessChatInput("/itpc")
					end
					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"10) UltraFUCK - Универсальный чит.")) then
					if imgui.Button(u8"Открыть божественный портал") then
						sampProcessChatInput("/ff")
					end
					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"11) Megaladon мультичит - Чит для машин.")) then
					if imgui.Button(u8"Открыть меню") then
						sampProcessChatInput("/ca")
					end
					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"12) EnterCrasher - То же самое что и бутылка от MrCreepTon.")) then
					if entercrasher then
						if imgui.Button(u8"Включить") then
							entercrasher = false
							sampProcessChatInput("/ecrash")
						end
					else
						if imgui.Button(u8"Отключить") then
							entercrasher = true
							sampProcessChatInput("/ecrash")
						end
					end

					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"13) StopCars - Остановка всех машин в стриме, отлично работает с EnterCrasher.")) then
					if stopcars then
						if imgui.Button(u8"Включить") then
							stopcars = false
							sampProcessChatInput("/stopcars")
						end
					else
						if imgui.Button(u8"Отключить") then
							stopcars = true
							sampProcessChatInput("/stopcars")
						end
					end
					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"14) SCar - Типо Gacar, но кидает ток 1 машину, менее палится античитом.")) then
					if imgui.Button(u8"/scar [id тачки] [id жертвы]") then
						sampSetChatInputText("/scar ")
						sampSetChatInputEnabled(true)
					end

					imgui.TreePop()
				end

				imgui.Separator()
				if (imgui.TreeNode(u8"15) CarShooter - Как жопторах, только с места водителя.")) then
					if carshooter then
						if imgui.Button(u8"Включить") then
							carshooter = false
							sampProcessChatInput("/cs")
						end
					else
						if imgui.Button(u8"Отключить") then
							carshooter = true
							sampProcessChatInput("/cs")
						end
					end

					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"16) EnterCarDRP - Сесть в люое авто, только для рванок, т.к, вы оч палитесь!.")) then
					if ecar then
						if imgui.Button(u8"Включить bypass") then
							ecar = false
							sampProcessChatInput("/ecar")
						end
					else
						if imgui.Button(u8"Отключить bypass") then
							ecar = true
							sampProcessChatInput("/ecar")
						end
					end

					imgui.Separator()

					if ecaron then
						if imgui.Button(u8"Включить езду на авто") then
							ecaron = false
							sampProcessChatInput("/ecaron")
						end
					else
						if imgui.Button(u8"Отключить езду на авто") then
							ecaron = true
							sampProcessChatInput("/ecaron")
						end
					end
					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"17) KickASS - Типа мощная рванка, а так то же самое что и Underground Death.")) then
					if imgui.Button(u8"/cra [id челика]") then
						sampSetChatInputText("/cra ")
						cra = true
						sampSetChatInputEnabled(true)
					end
					imgui.Separator()
					if imgui.Button(u8"Рванить всех в зоне стрима") then
						cra = true
						sampProcessChatInput("/cra all")
					end

					if cra then
						imgui.Separator()
						if imgui.Button(u8"Отключить") then
							cra = false
							sampProcessChatInput("/crs")
						end
					end
					imgui.Separator()
					if rvx then
						if imgui.Button(u8"!Включить более мощную рванку!") then
							rvx = false
							sampProcessChatInput("/rvx")
						end
					else
						if imgui.Button(u8"!Выключить более мощную рванку!") then
							rvx = true
							sampProcessChatInput("/rvx")
						end
					end
					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"18) FlyBypass - Разрешает использовать флай на некоторых серверах.")) then
					if bpfly then
						if imgui.Button(u8"Включить") then
							bpfly = false
							sampProcessChatInput("/bpfly")
						end
					else
						if imgui.Button(u8"Отключить") then
							bpfly = true
							sampProcessChatInput("/bpfly")
						end
					end

					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"19) SkinC - Выбор скина локально!")) then
					if imgui.Button(u8"Открыть меню") then
						sampProcessChatInput("/skinc")
					end

					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"20) Dammager - Херовый даммагер, убивает людей.")) then
					if imgui.Button(u8"/admg [id жертвы]") then
						sampSetChatInputText("/admg ")
						sampSetChatInputEnabled(true)
					end

					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"21) RollCrasher - Крашер, чтобы закрашить нужно телом двигать тачку.")) then
					if rcds then
						if imgui.Button(u8"Включить") then
							rcds = false
							sampProcessChatInput("/rcds")
						end
					else
						if imgui.Button(u8"Отключить") then
							rcds = true
							sampProcessChatInput("/rcds")
						end
					end

					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"22) WheelDestroyer - Взрывает покрышки тачек к хуям, нужно выкинуть чувака из тс для актив.")) then
					if imgui.Button(u8"/wd [id авто]") then
						sampSetChatInputText("/wd ")
						sampSetChatInputEnabled(true)
					end

					imgui.Separator()
					imgui.Text(u8'Включить на все тачки в которые вы садитесь')
					if wd then
						if imgui.Button(u8"Включить") then
							wd = false
							sampProcessChatInput("/wda")
						end
					else
						if imgui.Button(u8"Отключить") then
							wd = true
							sampProcessChatInput("/wda")
						end
					end

					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"23) SDMG - Крутой дамагер, раскройте описание.")) then
					if sdmg then
						if imgui.Button(u8"Включить") then
							sdmg = false
							sampProcessChatInput("/sdmg")
						end
					else
						if imgui.Button(u8"Отключить") then
							sdmg = true
							sampProcessChatInput("/sdmg")
						end
					end
					imgui.Separator()
					imgui.Text(u8'Дамажить с кулака, нужно быть близко к игроку, чтобы дамажить зажмите R')
					if imgui.Button(u8"/sdmg_kid [id]") then
						sampSetChatInputText("/sdmg_kid ")
						sampSetChatInputEnabled(true)
					end
					imgui.Separator()
					imgui.Text(u8'Вы можете настраивать прибавляя перфикс в конце _***')
					if imgui.Button(u8"/sdmg_") then
						sampSetChatInputText("/sdmg_")
						sampSetChatInputEnabled(true)
					end
					imgui.Text(u8'/sdmg_mode 0-3 - режим дамага')
					imgui.Text(u8'/sdmg_frac - выбор фракции вместо frac вводить например aztec,vagos,rifa,ballas,grove (всех дамажить - all)')
					imgui.Text(u8'/sdmg_time - установить задержку между выстрелами')
					imgui.Text(u8'/sdmg_gun - выбрать ган для дамага')
					imgui.Text(u8'/sdmg_radius - установить радиус дамага')
					imgui.Text(u8'/sdmg_miss - включение/выключение промаха')
					imgui.Text(u8'/sdmg_smiss - установить через какой патрон делать промах')
					imgui.Text(u8'/sdmg_antiwrn - антиварнинг на прострел стен')
					imgui.Text(u8'/sdmg_bl [id] - добавить в блек лист (сперва будет дамажить блеклист, а после перейдет на фракцию)')
					imgui.Text(u8'/sdmg_dbl - убрать из блек листа')
					imgui.Text(u8'/sdmg_ig id - добавить в игнор лист (не будет дамажить игроков которые в игнор листе)')
					imgui.Text(u8'/sdmg_dig - убрать с игнор листа')
					imgui.Text(u8'/sdmg_nokill - включить но килл')
					imgui.Text(u8'/sdmg_snokill - хп для но килла')
					imgui.Text(u8'/sdmg_antifrac - дамажить всех кроме выбраной фракции')
					imgui.Text(u8'/sdmg_dmg - дмг по id игрока')
					imgui.Text(u8'/sdmg_none - сбросить фракцию на none')
					imgui.Text(u8'/sdmg_kid [id] - дамаг кулаком по иду')
					imgui.Text(u8'/sdmg_kt - дамаг кулаком при прицеливание по игроку')
					imgui.Text(u8'/sdmg_pos - сменить позицию менюшки (нажать лкм для сохранение позиции)')
					imgui.Text(u8'/sdmg_save - сохранить текущие настройки (пример /sdmg_save test)')
					imgui.Text(u8'/sdmg test - загрузить настройки "test" (после загрузки будут грузится по умолчанию)')
					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"24) CarFuncsLUA_0.3.3 - Троллинг машинами.")) then
					if imgui.Button(u8"Открыть меню") then
						sampProcessChatInput("/cf.menu")
					end

					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"25) CarFuncsCLEO - Троллинг машинами.")) then
					imgui.Text(u8'/bc - Сбросить горящую машину на игрока, как SCar')
					if imgui.Button(u8"/bc [id авто]") then
						sampSetChatInputText("/bc ")
						sampSetChatInputEnabled(true)
					end
					imgui.Separator()
					imgui.Text(u8'/bcc - Поджечь тачку')
					if imgui.Button(u8"/bcc [id авто]") then
						sampSetChatInputText("/bcc ")
						sampSetChatInputEnabled(true)
					end
					imgui.Separator()
					imgui.Text(u8'/ctp - Украсть машину у челика или телепорт тачки к себе')
					if imgui.Button(u8"/ctp [id авто]") then
						sampSetChatInputText("/ctp  ")
						sampSetChatInputEnabled(true)
					end
					imgui.Separator()
					imgui.Text(u8'/crp - Починить машину')
					if imgui.Button(u8"/crp [id авто]") then
						sampSetChatInputText("/crp  ")
						sampSetChatInputEnabled(true)
					end
					imgui.Separator()
					imgui.Text(u8'/mrp  - Починить машину в которой вы сидите')
					if imgui.Button(u8"/mrp  [id авто]") then
						sampSetChatInputText("/mrp   ")
						sampSetChatInputEnabled(true)
					end
					imgui.Separator()
					if imgui.Button(u8"Список комманд") then
						sampProcessChatInput("/cinfo")
					end
					imgui.TreePop()
				end
				imgui.Separator()
				if (imgui.TreeNode(u8"26) WattiWeaponCheat - Выдает оружие но на несколько секунд при прицеливвании.")) then
					if imgui.Button(u8"Список комманд") then
						sampProcessChatInput("/whelp")
					end

					imgui.TreePop()
				end





				imgui.TreePop()
			end
			imgui.TreePop()
		end
		if imgui.TreeNode(u8"Другое") then
			imgui.Text(u8'Если не открывается ссылка, то у вас стоит антистиллер скорее всего, он блочит открытие ссылок.')
			imgui.Separator()
			if imgui.Button(u8'Ссылка где можно скачать все читы') then
				os.execute("start https://github.com/BadKiko/SAMP-Sborka-by-Kiko/releases")
			end
			imgui.Separator()
			imgui.TreePop()
		end
		----------------------------------------------------
		imgui.End()
	end
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
	tag = '{464446}[Cheat{850AB9}Helper{464446}]: {850AB9}'
	sampAddChatMessage(tag .. text, -1)
end
