script_author('LUCHARE')

local inicfg = require 'inicfg'
local samem = require 'SAMemory'
local imgui = require 'imgui'
local key = require 'vkeys'
samem.require 'CTrain'

local config = inicfg.load(
	{
		general = {
			limit = 1.25,
			mult = 1.02,
			timestep = 0.03,
			safe_train_speed = true,
			key = '18';
		}
	},
	'UltraFuck/Scripts/SpeedHack'
)
function da()
	while true do wait(0)
		mainini = inicfg.load({
			config =
			{
			speedhackalt = false,
		
			}
			}, "UltraFuck/UltraFuck")
		speedhackalt = imgui.ImBool(mainini.config.speedhackalt)
end end


local options = config.general
local player_vehicle = samem.cast('CVehicle **', samem.player_vehicle)
local ImBuffer = imgui.ImBuffer
local ImFloat = imgui.ImFloat
local ImBool = imgui.ImBool

local draw_options = ImBool(false)
local input_key = ImBuffer(''.. options.key, 64)
local slider_mult = ImFloat(options.mult)
local slider_limit = ImFloat(options.limit)
local slider_timestep = ImFloat(options.timestep)



function imgui.OnDrawFrame()
	if draw_options.v then
		local x, y = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(x/2, y/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(400, 200), imgui.Cond.FirstUseEver)
		imgui.Begin('SpeedHack', draw_options, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
		if imgui.InputText('Activation [ALT]', input_key) then
				options.key = input_key.v
			inicfg.save(config, 'UltraFuck/Scripts/SpeedHack')
		end
		if imgui.SliderFloat('Mult', slider_mult, 0.01, 7.0) then
			options.mult = slider_mult.v
		end
		if imgui.SliderFloat('Limit', slider_limit, 0.01, 7.0) then
			options.limit = slider_limit.v
		end
		if imgui.SliderFloat('Time step', slider_timestep, 0.0, 1.0) then
			options.timestep = slider_timestep.v
		end
		if imgui.Checkbox('Safe train speed', ImBool(options.safe_train_speed)) then
			options.safe_train_speed = not options.safe_train_speed
		end
		imgui.End()
	end
end

local timer = {
	prev_time = 0;
}

function timer:process(timestep)
	local curr_time = os.clock()
	if (curr_time - self.prev_time) >= timestep then
		self.prev_time = curr_time
		return true
	end
	return false
end



function main()
	sampRegisterChatCommand('speedhack', function() draw_options.v = not draw_options.v end)
	sampRegisterChatCommand('speedhackunload', function() thisScript():unload() end)
	lua_thread.create(da)
	while true do


		local veh = player_vehicle[0]
		if veh ~= samem.nullptr then
			if isKeyDown(input_key.v) and speedhackalt.v then
				if timer:process(options.timestep) then

					if veh.nVehicleClass == 6 then
						local train = samem.cast('CTrain *', veh)

						while train ~= samem.nullptr do
							local new_speed = train.fTrainSpeed * options.mult

							if options.safe_train_speed then
								if new_speed >= 0.99 then
									new_speed = 0.9
								end
							end

							if new_speed <= options.limit then
								train.fTrainSpeed = new_speed
							end

							train = train.pNextCarriage
						end

					else

						while veh ~= samem.nullptr do
							local new_speed = veh.vMoveSpeed * options.mult

							if new_speed:magnitude() <= options.limit then
								veh.vMoveSpeed = new_speed
							end

							veh = veh.pTrailer
						end

					end
				end
			end
		end
		imgui.Process = draw_options.v
		wait(0)
	end
end

function onScriptTerminate(script, quitGame)
	if script == thisScript() then
		inicfg.save(config, 'UltraFuck/Scripts/SpeedHack.ini')
	end
end


function theme1()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4
	local ImVec2 = imgui.ImVec2
	style.FramePadding = ImVec2(5, 5)
	style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
	style.WindowPadding = ImVec2(8, 8)
	style.ChildWindowRounding = 9.0
	style.FrameRounding = 6.0

	colors[clr.Text] = ImVec4(0.95, 0.96, 0.98, 1.00)
	colors[clr.TextDisabled] = ImVec4(0.36, 0.42, 0.47, 1.00)
	colors[clr.WindowBg] = ImVec4(0.11, 0.15, 0.17, 1.00)
	colors[clr.ChildWindowBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
	colors[clr.PopupBg] = ImVec4(0.08, 0.08, 0.08, 0.94)
	colors[clr.Border] = ImVec4(0.43, 0.43, 0.50, 0.50)
	colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.FrameBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
	colors[clr.FrameBgHovered] = ImVec4(0.12, 0.20, 0.28, 1.00)
	colors[clr.FrameBgActive] = ImVec4(0.09, 0.12, 0.14, 1.00)
	colors[clr.TitleBg] = ImVec4(0.09, 0.12, 0.14, 0.65)
	colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.00, 0.00, 0.51)
	colors[clr.TitleBgActive] = ImVec4(0.08, 0.10, 0.12, 1.00)
	colors[clr.MenuBarBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
	colors[clr.ScrollbarBg] = ImVec4(0.02, 0.02, 0.02, 0.39)
	colors[clr.ScrollbarGrab] = ImVec4(0.20, 0.25, 0.29, 1.00)
	colors[clr.ScrollbarGrabHovered] = ImVec4(0.18, 0.22, 0.25, 1.00)
	colors[clr.ScrollbarGrabActive] = ImVec4(0.09, 0.21, 0.31, 1.00)
	colors[clr.ComboBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
	colors[clr.CheckMark] = ImVec4(0.28, 0.56, 1.00, 1.00)
	colors[clr.SliderGrab] = ImVec4(0.28, 0.56, 1.00, 1.00)
	colors[clr.SliderGrabActive] = ImVec4(0.37, 0.61, 1.00, 1.00)
	colors[clr.Button] = ImVec4(0.20, 0.25, 0.29, 1.00)
	colors[clr.ButtonHovered] = ImVec4(0.28, 0.56, 1.00, 1.00)
	colors[clr.ButtonActive] = ImVec4(0.06, 0.53, 0.98, 1.00)
	colors[clr.Header] = ImVec4(0.20, 0.25, 0.29, 0.55)
	colors[clr.HeaderHovered] = ImVec4(0.26, 0.59, 0.98, 0.80)
	colors[clr.HeaderActive] = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.ResizeGrip] = ImVec4(0.26, 0.59, 0.98, 0.25)
	colors[clr.ResizeGripHovered] = ImVec4(0.26, 0.59, 0.98, 0.67)
	colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
	colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
	colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
	colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
	colors[clr.PlotLines] = ImVec4(0.61, 0.61, 0.61, 1.00)
	colors[clr.PlotLinesHovered] = ImVec4(1.00, 0.43, 0.35, 1.00)
	colors[clr.PlotHistogram] = ImVec4(0.90, 0.70, 0.00, 1.00)
	colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
	colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
	colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
end
theme1()
