script_name("kickASS v2.1")
script_author("L1ckt0r")

local hook = require 'lib.samp.events'

local found,plyid,all,st,extracheat = false,0,false,false,false

function GetNearestCoord(Array)
    local x, y, z = getCharCoordinates(PLAYER_PED)
    local distance = {}
    for k, v in pairs(Array) do
        distance[k] = {distance = math.floor(getDistanceBetweenCoords3d(v[1], v[2], v[3], x, y, z)), id = v[4], vx=v[1],vy=v[2],vz=v[3]}
	end
    table.sort(distance, function(a, b) return a.distance < b.distance end)
	if #distance ~= 0 then
		local n = distance[1]
		local id = n.id
		return id
	end
end

function hook.onSendVehicleSync(data)
	if found and not st then
		local res,ped = sampGetCharHandleBySampPlayerId(plyid)
		if res then
			local x,y,z = getCharCoordinates(ped)
			math.randomseed(os.time())
			if extracheat then
				if isCharInAnyCar(ped) then
					data.position.y = y
					data.position.x = x
					data.position.z = z + 2.35
					data.moveSpeed.z = -1.3
				else
					data.position.y = y
					data.position.x = x
					data.position.z = z - 1
					data.moveSpeed.z = 1.3
				end
			else
				if isCharInAnyCar(ped) then
					data.position.y = y
					data.position.x = x
					data.position.z = z + 2
					data.moveSpeed.z = -1.15
				else
					data.position.y = y
					data.position.x = x
					data.position.z = z - 2
					data.moveSpeed.z = 1.15
				end
			end
		end
	elseif st then
		st = false
		found = false
	end
end

function hook.onPlayerQuit(pid,r)
    if pid == plyid and found and not all then
		found = false
			sampAddChatMessage("{464446}[{850AB9}KickASS{464446}]:{850AB9} Игроку сделали fisting, и он вышел!",-1)
    end
end

function hook.onPlayerDeath(pid)
    if pid == plyid and found and not all then
        found = false
			sampAddChatMessage("{464446}[{850AB9}KickASS{464446}]:{850AB9} Игрок стал slave и теперь он в больнице!",-1)
    end
end

function main()
	while not isSampAvailable() do wait(0) end
	sampRegisterChatCommand("cra", kick)
	sampRegisterChatCommand("crs", stop)
	sampRegisterChatCommand("rvx", extra)
	wait(1240)
		sampAddChatMessage("{464446}[{850AB9}KickASS{464446}]:{850AB9} KickASS успешно загрузился!",-1)
		sampAddChatMessage("{464446}[{850AB9}KickASS{464446}]:{850AB9} Команды: /kickass {id}!",-1)
		sampAddChatMessage("{464446}[{850AB9}KickASS{464446}]:{850AB9} Автор:{464446} Lackt0r",-1)
	while true do
		wait(0)
		if found then
			if all then
				local Ar = {}
				if #getAllChars() ~= 0 then
					for _,v in pairs(getAllChars()) do
						if v ~= PLAYER_PED then
							local result, pli = sampGetPlayerIdByCharHandle(v)
							local x,y,z = getCharCoordinates(PLAYER_PED)
							local a,b,c = getCharCoordinates(v)
							if getDistanceBetweenCoords3d(a,b,c,x,y,z) < 75 then
								table.insert(Ar,{a,b,c,pli})
							end
						end
					end
					plyid = GetNearestCoord(Ar)
				end
			end
			if getDistanceBetweenCoords3d(a,b,c,x,y,z) > 75 and not all then
					sampAddChatMessage("{464446}[{850AB9}KickASS{464446}]:{850AB9} Игрок слишком далеко убежал!",-1)
				found = false
			end
			if plyid ~= nil then
				printStringNow("Kicking ASS id"..plyid.."!",1)
			end
		end
	end
end

function extra()
	extracheat = not extracheat
	if extracheat then
			sampAddChatMessage("{464446}[{850AB9}KickASS{464446}]:{850AB9} СВЕРХ ЕБАНУТЫЙ РЕЖИМ ВКЛЮЧЕН!",-1)
			sampAddChatMessage("{464446}[{850AB9}KickASS{464446}]:{850AB9} МОЖЕТ КИКАТЬ ЗА СПИДХАК!",-1)
			sampAddChatMessage("{464446}[{850AB9}KickASS{464446}]:{850AB9} ЧТОБЫ ТЕПЕРЬ РВАНИТЬ, ВАМ НУЖНО НАБРАТЬ СКОРОСТЬ НА МОПЕДЕ, И ТОГДА ВЫ СМОЖЕТЕ РВАНИТЬ!",-1)
	else
			sampAddChatMessage("{464446}[{850AB9}KickASS{464446}]:{850AB9} Фух... Это был жесткий fisting!",-1)
	end
end

function stop()
	all = false
	st = true
		sampAddChatMessage("{464446}[{850AB9}KickASS{464446}]:{850AB9} Остановлен!",-1)
end

function kick(arg)
	found = false
	if arg == "all" then
			sampAddChatMessage("{464446}[{850AB9}KickASS{464446}]:{850AB9} Начинаем делать fisting for 300$!",-1)
		local Ar = {}
		if #getAllChars() ~= 0 then
			for _,v in pairs(getAllChars()) do
				if v ~= PLAYER_PED then
					local result, pli = sampGetPlayerIdByCharHandle(v)
					local x,y,z = getCharCoordinates(PLAYER_PED)
					local a,b,c = getCharCoordinates(v)
					if getDistanceBetweenCoords3d(a,b,c,x,y,z) < 75 then
						table.insert(Ar,{a,b,c,pli})
					end
				end
			end
			plyid = GetNearestCoord(Ar)
		end
		found = true
		all = true
	else
		arg = tonumber(arg)
		if sampIsPlayerConnected(arg) then
			for _,v in pairs(getAllChars()) do
				local result, pli = sampGetPlayerIdByCharHandle(v)
				if pli == arg then
					found = true
				end
			end
			if found then
					sampAddChatMessage("{464446}[{850AB9}KickASS{464446}]:{850AB9} Игрок найден, начинаем fisting!",-1)
				plyid = arg
				name = sampGetPlayerNickname(id)
			else
					sampAddChatMessage("{464446}[{850AB9}KickASS{464446}]:{850AB9} Игрок не найден!",-1)
			end
		else
				sampAddChatMessage("{464446}[{850AB9}KickASS{464446}]:{850AB9} Игрок не на сервере!",-1)
		end
	end
end