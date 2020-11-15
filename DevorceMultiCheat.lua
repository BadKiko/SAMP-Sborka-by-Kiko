script_name("DevorceMultiCheat")
script_version("0.0.1")
script_author("Kiko")

local memory = require("memory")
local sampev = require("lib.samp.events")
local imgui = require("imgui")
local inicfg = require("inicfg")
local encoding = require("encoding")
local sw, sh = getScreenResolution()

local directini = "moonloader\\dmc_settings.ini"

local mainIni = inicfg.load(nil, directini)

encoding.default = "CP1251"
u8 = encoding.UTF8

local main_window_state = imgui.ImBool(false)
local daac_window_state = imgui.ImBool(false)
local dkp_window_state = imgui.ImBool(false)
local dar_window_state = imgui.ImBool(false)
local dal_window_state = imgui.ImBool(false)
local dareg_window_state = imgui.ImBool(false)
local dach_window_state = imgui.ImBool(false)
local dsp_window_state = imgui.ImBool(false)

local funfitches_window_state = imgui.ImBool(false)

--DKP
local cherez_skok_povtor_dkp = imgui.ImBuffer(""..mainIni.dkp_settings.millisecond_repeat, 256)
local skok_povtorovdelat = imgui.ImBuffer(""..mainIni.dkp_settings.skok_povtorovdelat, 256)
local kick_id_player = imgui.ImBuffer(256)

--DAR
local checkbox_dar = imgui.ImBool(mainIni.dar_settings.autorelog)
--DAL
local checkbox_dal = imgui.ImBool(mainIni.dal_settings.autologin)
local dal_password = imgui.ImBuffer(""..mainIni.dal_settings.dal_password, 256)
--DAREG
local checkbox_dareg = imgui.ImBool(mainIni.dareg_settings.autoregistration)
local dareg_password = imgui.ImBuffer(""..mainIni.dareg_settings.dareg_password, 256)
local dareg_email = imgui.ImBuffer(""..mainIni.dareg_settings.dareg_email, 256)

--FF
local rainbow_clist_check = imgui.ImBool(false)
nowcolor = 0
local rainbow_skin_check = imgui.ImBool(false)
nowskin = 0 -- 1- 189  / 2 - 22 / 3 - 20  / 4 - 107 / 5 - 177 / 6 - 119 / 7 - 296
whatskin = 0

checkAdm = imgui.ImBool(false)

	local pizdec_vzrivcars = imgui.ImBool(false)

function main()

	dname = {"Joseph", "Timothy", "Kyle", "Mark", "Alexandr", "Solon", "Marko", "Kol", "John", "Mino", "Kon", "Alex", "Ase", "Xeo", "Noe", "Nom", "Kolya", "Leo", "Moche", "Irl", "Ques"}
	dname2 = {"Adam", "Reynold", "Aizek", "Rig", "Rick", "Ricky", "Aik", "Jorjh", "Alan", "Donald", "Rudy", "Ruby", "Dunkan", "Scott", "David", "Spenser", "Duke", "Stiph", "Stephe", "Indie", "Alester"}
	dname3 = {"Caster", "Stanford", "Archi", "Cvantin", "Butt", "Samuel", "Bart", "Tim", "Tom", "Ton", "Ken", "Kan", "Todd", "Tuedd", "Ouell", "Walley", "Cristopher", "Walt", "Barney", "Indi", "Jay"}
	dname4 = {"Mikle", "Bill", "Max", "Blake", "Fredd", "Maxwell", "Marwin", "Fredder", "Frider", "Marlone", "Bob", "Bruce", "Ben", "Walter", "Fester", "Phester", "Filipp", "Aren", "Redclif", "Gordom", "Nir"}
	dname5 = {"Charley", "Olbi", "Willmark", "Charlez", "Sheldon", "Shon", "Garry", "Adan", "Eden", "Addan", "Perry", "Pirce", "Pitter", "Harwi", "Niko", "Kiko", "Nikolas", "Casper", "Indo", "Gordon", "Lie "}

	dsurname = {"Jers", "Mon", "Dian", "Dhen", "Chen", "Sinse", "Rodrigez", "Melson", "Size", "Sixly", "Konse", "Aque", "Hose", "Yore", "Wars", "Legi", "Outlike", "Janda", "Poni", "Horse", "Maker"}
	dsurname2 = {"Johnson", "Williams", "Brown", "Miller", "Davis", "Taylor", "Thommas", "More", "Moore", "Martini", "Jackson", "White", "Lopez", "Lii", "Lavis", "Robinson", "Hell", "Hall", "Young", "Harryson", "Smith"}
	dsurname3 = {"King", "Baker", "Adams", "Nelson", "Hill", "Rem", "Robberts", "Ran", "Karter", "Awans", "Torner", "Torrent", "Parker", "Collens", "Flores", "Morris", "Cook", "Morgan", "Hondon", "Charter", "Koore"}
	dsurname3 = {"Kalley", "Socks", "Koks", "Wood", "Price", "Carpt", "Long", "Rolls", "Rouse", "House", "Pawell", "Buttler", "Fisher", "Saimon", "Lee", "Harris", "Klark", "Cklark", "Gokie", "Federsonph", "Chers"}
	dsurname4 = {"Sinons", "Kim", "Ramos", "Gripher", "Griphen", "Simspon", "West", "Call", "Allan", "Kopper", "Cooper", "Kooper", "Rid", "Read", "Bell", "Kingston", "Malvin", "Mole", "Moole", "Grigger", "Rocker"}
	dsurname5 = {"Kaule", "Caule", "Ford", "McDonald", "Allson", "Ollson", "Hunter", "Black", "Morgan", "Kopper", "Cooper", "Kooper", "Rid", "Read", "Bell", "Goor", "Gor", "Gol", "Foolon", "Fommas", "Kollen"}
	--
	randname = 0
	randsurname = 0
	randblokname = 0
	randbloksurname = 0
	mname = ""
	msurname = ""
	fullname = ""

--DAAC
	scriptIsEnabled = true
	daacregit = false
	daacregit_forcheck = false
	mainProcess = false;
	markerSet = false
--DKP
	needRelog = false
	whosinCar = 0
	playerID = 0

	devorcepizdecbool = false

	administr = u8""

	repeat wait(0) until isSampLoaded() and isSampAvailable()

	wait(3000)
	sampAddChatMessage("{56de47}[DevorceMultiCheat]{7ce670}: Активирован!")
	sampAddChatMessage("{56de47}[DevorceMultiCheat]{7ce670}: /dmc - открыть окно мультичита.")
	sampAddChatMessage("{56de47}Made by {7ce670}Kiko")
	result, pped = sampGetPlayerIdByCharHandle(playerPed)

	imgui.Process = true
	imgui.Process =  main_window_state.v
	while true do
	wait(0)

		local zpos1, zpos2, zpos3 = getCharCoordinates(playerPed)

		if zpos1 == 264.14 and zpos2 == 77.47 and zpos3 == 1001.04 then

				if randblokname == 1 then
					mname = dname[randname]
				end
				if randblokname == 2 then
					mname = dname2[randname]
				end
				if randblokname == 3 then
					mname = dname3[randname]
				end
				if randblokname == 4 then
					mname = dname4[randname]
				end
				if randblokname == 5 then
					mname = dname5[randname]
				end



				if randbloksurname == 1 then
					msurname = dsurname[randsurname]
				end
				if randbloksurname == 2 then
					msurname = dsurname2[randsurname]
				end
				if randbloksurname == 3 then
					msurname = dsurname3[randsurname]
				end
				if randbloksurname == 4 then
					msurname = dsurname4[randsurname]
				end
				if randbloksurname == 5 then
					msurname = dsurname5[randsurname]
				end

				fullname = mname.."_"..msurname
				sampAddChatMessage("{ff2e2e}[DevorceAutoRelog]{ff6161}: Делаем перезаход с новым ником -"..fullname..".", -1)

				sampSetLocalPlayerName(fullname)
				i, p = sampGetCurrentServerAddress()
				sampConnectToServer(i, p)

		end

		if main_window_state.v == false then
				imgui.ShowCursor = false
			else
				imgui.ShowCursor = true
		end


		if checkAdm.v then
			sampSendChat("/admins")
		end
		--FF
		if rainbow_clist_check.v then
			nowcolor = nowcolor + 1
			sampSendChat("/clist")
			wait(1000)
		end

		if checkbox_dar.v then
		randblokname = math.random(1, 5)
		randbloksurname = math.random(1, 5)

		randname = math.random(1, 21)
		randsurname = math.random(1, 21)
		end

		--FF
		if rainbow_skin_check.v then
			nowskin = nowskin + 1
			 -- 1- 189 пїЅпїЅ / 2 - 22 пїЅпїЅ / 3 - 20 пїЅпїЅ / 4 - 107 / 5 - 177 / 6 - 119 / 7 - 296
			if nowskin == 1 then
				whatskin = 189
			elseif nowskin == 2 then
				whatskin = 22
			elseif nowskin == 3 then
				whatskin = 20
			elseif nowskin == 4 then
				whatskin = 107
			elseif nowskin == 5 then
				whatskin = 177
			elseif nowskin == 6 then
				whatskin = 119
			elseif nowskin == 7 then
				whatskin = 296
			end

				if nowskin >= 7 then
					nowskin = 0
				end
			sampSendChat("/donate")
			wait(1000)
		end

		sampRegisterChatCommand("dmc", function()
		main_window_state.v = not main_window_state.v
		imgui.Process =  main_window_state.v
		end)
	end
end

function imgui.OnDrawFrame()
	if main_window_state.v then
		imgui.SetNextWindowSize(imgui.ImVec2(260, 360), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin("[DevorceMultiCheat] by Kiko", main_window_state, imgui.WindowFlags.NoResize)
		apply_custom_style()
		imgui.SetCursorPosX(62.5)
		imgui.Text(u8"Мультичит by Kiko")
		imgui.Separator()
		imgui.SetCursorPosX(62.5)
		if imgui.Button("DevorceAntiAntiCheat") then
			daac_window_state.v = not daac_window_state.v
		end
		imgui.Separator()
		imgui.SetCursorPosX(62.5)
		if imgui.Button("DevorceKickPassanger") then
			dkp_window_state.v = not dkp_window_state.v
		end

		imgui.Separator()
		imgui.SetCursorPosX(62.5)
		if imgui.Button("DevorceAutoRelog") then
			dar_window_state.v = not dar_window_state.v
		end

		imgui.Separator()
		imgui.SetCursorPosX(62.5)
		if imgui.Button("DevorceAutoLogin") then
			dal_window_state.v = not dar_window_state.v
		end

		imgui.Separator()
		imgui.SetCursorPosX(62.5)
		if imgui.Button("DevorceAutoRegistration") then
			dareg_window_state.v = not dar_window_state.v
		end

		imgui.Separator()
		imgui.SetCursorPosX(62.5)
		if imgui.Button(u8"DevorceAdminChecker") then
			dach_window_state.v = not dach_window_state.v
		end

		imgui.Separator()
		imgui.SetCursorPosX(62.5)
		if imgui.Button(u8"Прикольные фитчи") then
			funfitches_window_state.v = not funfitches_window_state.v
		end
		imgui.End()
	end

	if daac_window_state.v then
			imgui.SetNextWindowSize(imgui.ImVec2(250, 100), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin("[DevorceAntiAntiCheat] by Kiko", daac_window_state, imgui.WindowFlags.NoResize)
			imgui.Separator()
			imgui.SetCursorPosX(56.25)
			if imgui.Button(u8"Отключить античит") then
				daacregit = true
				daac_window_state = imgui.ImBool(false)
				DevorceAntiAntiCheat()
			end
				imgui.Separator()
			imgui.End()
	end

	if dkp_window_state.v then
			imgui.SetNextWindowSize(imgui.ImVec2(350, 300), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin("[DevorceKickPassanger] by Kiko", dkp_window_state, imgui.WindowFlags.NoResize)
			imgui.Separator()
			imgui.SetCursorPosX(85)
			imgui.Text(u8"Кик игрока в вашей машине.")
			imgui.SetCursorPosX(135)
			if imgui.Button(u8"Начать кик") then
				DevorceKickPassanger()
				--playersInMyCar()
			end
				imgui.Separator()
				imgui.PushItemWidth(50)
				if imgui.InputText(u8"Через сколько миллисикунд делать повтор?", cherez_skok_povtor_dkp) then
					mainIni.dkp_settings.millisecond_repeat = cherez_skok_povtor_dkp.v
					inicfg.save(mainIni, directini)
				end
				if imgui.InputText(u8"Сколько раз повторять?", skok_povtorovdelat) then
					mainIni.dkp_settings.skok_povtorovdelat = skok_povtorovdelat.v
					inicfg.save(mainIni, directini)
				end
				imgui.Separator()
				imgui.SetCursorPosX(120)
				imgui.Text(u8"Кик игрока на ногах вы в машине.")


				imgui.InputText(u8"ИД игрока для кика", kick_id_player)
				if imgui.Button(u8"Кикнуть игрока с ИД - "..kick_id_player.v) then
					DevorceKickOnFoot()
				end
			imgui.End()
	end


	if dar_window_state.v then
			imgui.SetNextWindowSize(imgui.ImVec2(350, 100), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin("[DevorceAutoRelog] by Kiko", dar_window_state, imgui.WindowFlags.NoResize)
			imgui.Separator()
			imgui.SetCursorPosX(74.5)
			if imgui.Checkbox(u8"Делать авто-релог?", checkbox_dar) then
				inicfg.save(mainIni, directini)
			end
			imgui.Separator()
			imgui.End()
	end

	if dal_window_state.v then
			imgui.SetNextWindowSize(imgui.ImVec2(450, 125), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin("[DevorceAutoLogin] by Kiko", dal_window_state, imgui.WindowFlags.NoResize)
			imgui.Separator()
			imgui.SetCursorPosX(145)
			if imgui.Checkbox(u8"Делать авто-логин?", checkbox_dal) then
				inicfg.save(mainIni, directini)
			end
			imgui.Separator()
			if imgui.InputText(u8"Введите ваш пароль", dal_password) then
				mainIni.dal_settings.dal_password = dal_password.v
				inicfg.save(mainIni, directini)
			end
			imgui.End()
	end

	if dareg_window_state.v then
			imgui.SetNextWindowSize(imgui.ImVec2(450, 160), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin("[DevorceAutoRegistration] by Kiko", dareg_window_state, imgui.WindowFlags.NoResize)
			imgui.Separator()
			imgui.SetCursorPosX(145)
			if imgui.Checkbox(u8"Делать авто-регистрацию?", checkbox_dareg) then
				inicfg.save(mainIni, directini)
			end
			imgui.Separator()
			if imgui.InputText(u8"Введите пароль.", dareg_password) then
				mainIni.dareg_settings.dareg_password = dareg_password.v
				inicfg.save(mainIni, directini)
			end
			imgui.Separator()
			if imgui.InputText(u8"Введите E-Mail", dareg_email) then
				mainIni.dareg_settings.dareg_email = dareg_email.v
				inicfg.save(mainIni, directini)
			end
			imgui.End()
	end

	if funfitches_window_state.v then
			imgui.SetNextWindowSize(imgui.ImVec2(450, 125), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin("[FunFitches] by Kiko", funfitches_window_state, imgui.WindowFlags.NoResize)
			imgui.Separator()
			imgui.Checkbox(u8"Радужный клист", rainbow_clist_check)
			imgui.Checkbox(u8"Радужный скин", rainbow_skin_check)
			imgui.End()
	end

	if dach_window_state.v then
			imgui.SetNextWindowSize(imgui.ImVec2(450, 125), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin("[DevorceAdminChecker] by Kiko", dach_window_state)
			imgui.Separator()
			imgui.Checkbox(u8"Включить админ чекер", checkAdm)
			if checkAdm.v then
				imgui.Text(u8(administr))
			end
			imgui.Separator()
			imgui.End()
	end
end

function DevorceAntiAntiCheat()

	lua_thread.create(function()
		if devorcepizdecbool then
			pizdec_vzrivcars =  imgui.ImBool(false)
			wait(8000)
			daacregit = true
			local pos1, pos2, pos3 = getCharCoordinates(playerPed)
			local result, car = findAllRandomVehiclesInSphere(pos1, pos2, pos3, 300, false, true)
			if result == true then
				daacregit = true
				local res2, id = sampGetVehicleIdByCarHandle(car)
				taskWarpCharIntoCarAsDriver(playerPed, car)
				sampAddChatMessage("{56de47}[DevorceAntiAntiCheat]{7ce670}: Начал авто-работу.")
				wait(2000)
				setCharCoordinates(playerPed, pos1, pos2, pos3)
				wait(5000)
				daacregit = false
				daacregit_forcheck = true
				wait(500)
				daacregit_forcheck = false
				taskLeaveAnyCar(playerPed)
				wait(2000)
				explodeCar(car)
				setCharHealth(playerPed, 100)
				pizdec_vzrivcars =  imgui.ImBool(true)
			else
				sampAddChatMessage("{ff2e2e}[DevorceAntiAntiCheat]{ff6161}: Машин нет рядом. Античит отключен не будет!")
			end

		else
				daacregit = true
				local pos1, pos2, pos3 = getCharCoordinates(playerPed)
				local result, car = findAllRandomVehiclesInSphere(pos1, pos2, pos3, 300, true, true)
				if result == true then
					daacregit = true
					local res2, id = sampGetVehicleIdByCarHandle(car)
					taskWarpCharIntoCarAsDriver(playerPed, car)
					sampAddChatMessage("{56de47}[DevorceAntiAntiCheat]{7ce670}: Начал работу.")
					wait(2000)
					setCharCoordinates(playerPed, pos1, pos2, pos3)
					wait(5000)
					daacregit = false
					daacregit_forcheck = true
					wait(500)
					daacregit_forcheck = false
					wait(2000)
					explodeCar(car)
					setCharHealth(playerPed, 100)
				else
					sampAddChatMessage("{ff2e2e}[DevorceAntiAntiCheat]{ff6161}: Машин нет рядом. Античит отключен не будет!")
				end
			end

		end)
end

function DevorceKickPassanger()
	lua_thread.create(function()
		pos1, pos2, pos3 = getCharCoordinates(playerPed)
  	for i = 0, skok_povtorovdelat.v - 1 do
			setCharCoordinates(playerPed, 0,0,0)
			wait(cherez_skok_povtor_dkp.v)
			setCharCoordinates(playerPed, pos1,pos2,pos3)
			wait(cherez_skok_povtor_dkp.v)
		end
	end)
end

function DevorceKickOnFoot()
	lua_thread.create(function()
	pos1, pos2, pos3 = getCharCoordinates(playerPed)
	local target_result, target_ped = sampGetCharHandleBySampPlayerId(kick_id_player.v)
	sampAddChatMessage("target_ped"..target_ped, -1)
	if target_result then
		target_pos1, target_pos2, target_pos3 = getCharCoordinates(target_ped)
		setCharCoordinates(playerPed, target_pos1, target_pos2, target_pos3 - 1.5)
		wait(1000)
		setCharCoordinates(playerPed, 0, 0, 0)
		wait(3000)
		setCharCoordinates(playerPed, pos1, pos2, pos3)
	end
end)
end

function sampev.onSendVehicleSync()
	if  daacregit == true then
			return false
	end
end

function apply_custom_style()
	imgui.SwitchContext()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4
	local ImVec2 = imgui.ImVec2

	style.WindowPadding = ImVec2(15, 15)
	style.WindowRounding = 6.0
	style.FramePadding = ImVec2(5, 5)
	style.FrameRounding = 4.0
	style.ItemSpacing = ImVec2(12, 8)
	style.ItemInnerSpacing = ImVec2(8, 6)
	style.IndentSpacing = 25.0
	style.ScrollbarSize = 15.0
	style.ScrollbarRounding = 9.0
	style.GrabMinSize = 5.0
	style.GrabRounding = 3.0
	colors[clr.Text] = ImVec4(0.80, 0.80, 0.83, 1.00)
	colors[clr.TextDisabled] = ImVec4(0.24, 0.23, 0.29, 1.00)
	colors[clr.WindowBg] = ImVec4(0.06, 0.05, 0.07, 1.00)
	colors[clr.ChildWindowBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
	colors[clr.PopupBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
	colors[clr.Border] = ImVec4(0.80, 0.80, 0.83, 0.88)
	colors[clr.BorderShadow] = ImVec4(0.92, 0.91, 0.88, 0.00)
	colors[clr.FrameBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.FrameBgHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
	colors[clr.FrameBgActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
	colors[clr.TitleBg] = ImVec4(0.76, 0.31, 0.00, 1.00)
	colors[clr.TitleBgCollapsed] = ImVec4(1.00, 0.98, 0.95, 0.75)
	colors[clr.TitleBgActive] = ImVec4(0.80, 0.33, 0.00, 1.00)
	colors[clr.MenuBarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.ScrollbarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.ScrollbarGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
	colors[clr.ScrollbarGrabHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
	colors[clr.ScrollbarGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
	colors[clr.ComboBg] = ImVec4(0.19, 0.18, 0.21, 1.00)
	colors[clr.CheckMark] = ImVec4(1.00, 0.42, 0.00, 0.53)
	colors[clr.SliderGrab] = ImVec4(1.00, 0.42, 0.00, 0.53)
	colors[clr.SliderGrabActive] = ImVec4(1.00, 0.42, 0.00, 1.00)
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

function sampev.onServerMessage(color, text)
	if text:match("[Античит AC]") and text:match("Код события") then
		lua_thread.create(function()
			if daacregit_forcheck or checkbox_dar then
			wait(1)
			if daacregit_forcheck then
				sampAddChatMessage("{ff2e2e}[DevorceAntiAntiCheat]{ff6161}: Что-то пошло не так, перезаход!", -1)
			else
				sampAddChatMessage("{ff2e2e}[DevorceAutoRelog]{ff6161}: Перезаходим.", -1)
			end
			i, p = sampGetCurrentServerAddress()
			sampConnectToServer(i, p)
			daacregit_forcheck = false
			end
		end)
	end


		if checkAdm.v then

			if string.find (text, "В сети всего ", 1, true) then
				administr = string.sub(text, 9)
				return false
			end

			if string.find(text, "LVL:", 1, true) and string.find(text, "Выговоры", 1, true) then
				return false
			end
			if string.find(text, "Админ", 1, true) and string.find(text, "..::", 1, true) then
				return {-1, ""}
			end
		end

	if text:match("Вы помещены в форт ДеМорган") or text:match("забанил "..sampGetPlayerNickname(pped)) or text:match("Вас посадили в тюрьму") then
		lua_thread.create(function()
			if checkbox_dar then
			wait(1)



			if randblokname == 1 then
				mname = dname[randname]
			end
			if randblokname == 2 then
				mname = dname2[randname]
			end
			if randblokname == 3 then
				mname = dname3[randname]
			end
			if randblokname == 4 then
				mname = dname4[randname]
			end
			if randblokname == 5 then
				mname = dname5[randname]
			end



			if randbloksurname == 1 then
				msurname = dsurname[randsurname]
			end
			if randbloksurname == 2 then
				msurname = dsurname2[randsurname]
			end
			if randbloksurname == 3 then
				msurname = dsurname3[randsurname]
			end
			if randbloksurname == 4 then
				msurname = dsurname4[randsurname]
			end
			if randbloksurname == 5 then
				msurname = dsurname5[randsurname]
			end

			fullname = mname.."_"..msurname
			sampAddChatMessage("{ff2e2e}[DevorceAutoRelog]{ff6161}: Делаем перезаход с новым ником -"..fullname..".", -1)

			sampSetLocalPlayerName(fullname)
			i, p = sampGetCurrentServerAddress()
			sampConnectToServer(i, p)

			if devorcepizdecbool then

			end
			end
		end)
	end

		if text:match("Пожалуйста, не флудите.") then
			return false
		end

		if text:match("Добро пожаловать на") and devorcepizdecbool then
			DevorceAntiAntiCheat()
			return {-1, "Добро пожаловать нахуй"}
		end

		if text:match("Ваш скин изменен") then
			if rainbow_skin_check.v then
					return false
			end
		end
end

function sampev.onShowDialog(dialogId)
	if dialogId == 2 and checkbox_dal.v then
		sampAddChatMessage("{56de47}[DevorceAutoLogin]{7ce670}: Авто-Логин.", -1)
		sampSendDialogResponse(2, 1, 0, mainIni.dal_settings.dal_password)
		return false
	end
	if checkbox_dareg then
		if dialogId == 1 then
			sampSendDialogResponse(1, 1, 0, mainIni.dareg_settings.dareg_password)
			return false
		end
		if dialogId == 3 then
			sampSendDialogResponse(3, 1, 0, mainIni.dareg_settings.dareg_email)
			return false
		end
		if dialogId == 7 then
			sampSendDialogResponse(7, 0, 0, "")
			return false
		end
		if dialogId == 4 then
			sampSendDialogResponse(4, 1, 0, "")
			return false
		end
		if dialogId == 0 then
			sampSendDialogResponse(0, 1, 0, "")
			sampAddChatMessage("{56de47}[DevorceAutoRegistration]{7ce670}: Авто-Регистрация.", -1)
			return false
		end
	end

--FF
	if rainbow_clist_check.v then
		if dialogId == 56 then
			if nowcolor >= 31 then
				nowcolor = 1
			end
			sampSendDialogResponse(56, 1, nowcolor, "")
			return false
		end
	end

	--FF
		if rainbow_skin_check.v then
			if dialogId == 2233 then
				sampSendDialogResponse(2233, 1, 0, "")
				return false
			end
			if dialogId == 26363 then
				sampSendDialogResponse(26363, 1, 6, "")
				return false
			end
			if dialogId == 5563 then
				sampSendDialogResponse(5563, 1, 0, whatskin)
				return false
			end
		end
end

--[[function sampev.onSendCommand(command)
	lua_thread.create(function()
		if rainbow_clist_check.v then
		if command:match("clist") then
		else
			rainbow_clist_check = imgui.ImBool(false)
			wait(1000)
			sampSendChat(command)
			rainbow_clist_check = imgui.ImBool(true)
			return false
		end
	end
	end)
end

function sampev.onSendChat(message)
	lua_thread.create(function()
		if rainbow_clist_check.v then
			rainbow_clist_check = imgui.ImBool(false)
			wait(1000)
			rainbow_clist_check = imgui.ImBool(true)
			return false
		end
	end)
end
]]
--[[function playersInMyCar()

	local vehicleHandle = getCarCharIsUsing(playerPed)
	for i=0, sampGetPlayerCount(true) - 1 do
		local result, ped = sampGetCharHandleBySampPlayerId(i)
		if result then
		 inCar = isCharInCar(ped, vehicleHandle)
		 if inCar then
			 whosinCar = whosinCar + 1
			 playerID = i
		 end
		end
		if condition then

		end
	end
end
]]
