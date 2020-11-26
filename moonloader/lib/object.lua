if proxy == nil then
	proxy = dofile(getRakBotPath()..'\\scripts\\libs\\luaAddons\\proxy.lua')
end
local objs = {}
function proxy.Object(id, data, size)
	if id == 44 then
		local bs = bitStreamInit(data, size)
		local data = {}
		local objectId = bitStreamReadWord(bs)
		data.modelId = bitStreamReadDWord(bs)
		local px = bitStreamReadFloat(bs)
		local py = bitStreamReadFloat(bs)
		local pz = bitStreamReadFloat(bs)
		data.position = {x=px,y=py,z=pz}
		local rx = bitStreamReadFloat(bs)
		local ry = bitStreamReadFloat(bs)
		local rz = bitStreamReadFloat(bs)
		data.rotation = {x=rx,y=ry,z=rz}
		data.drawDistance = bitStreamReadFloat(bs)
		data.noCameraCol = bitStreamReadByte(bs) ~= 0
		data.attachToVehicleId = bitStreamReadWord(bs)
		data.attachToObjectId = bitStreamReadWord(bs)
		if data.attachToVehicleId ~= 65535 or data.attachToPlayerId ~= 65535 then
			local aox = bitStreamReadFloat(bs)
			local aoy = bitStreamReadFloat(bs)
			local aoz = bitStreamReadFloat(bs)
			data.attachOffsets = {x=aox,y=aoy,z=aoz}
			local arx = bitStreamReadFloat(bs)
			local ary = bitStreamReadFloat(bs)
			local arz = bitStreamReadFloat(bs)
			data.attachRotation = {x=arx,y=ary,z=arz}
			data.syncRotation = bitStreamReadByte(bs) ~= 0
		end
		data.texturesCount = bitStreamReadByte(bs)
		bitStreamDelete(bs)
		objs[objectId] = data
		if type(onObjectCreate) == 'function' then
			onObjectCreate(objectId,data)
		end
	end
	if id == 45 then
		local bs = bitStreamInit(data, size)
		local data = {}
		local objectId = bitStreamReadWord(bs)
		local px = bitStreamReadFloat(bs)
		local py = bitStreamReadFloat(bs)
		local pz = bitStreamReadFloat(bs)
		data.position = {x=px,y=py,z=pz}
		if objs[objectId] ~= nil then
			objs[objectId].position = data.position
		end
		if type(onSetObjectPosition) == 'function' then
			onSetObjectPosition(objectId, data.position)
		end
		bitStreamDelete(bs)
	end
	if id == 46 then
		local bs = bitStreamInit(data, size)
		local data = {}
		local objectId = bitStreamReadWord(bs)
		local rx = bitStreamReadFloat(bs)
		local ry = bitStreamReadFloat(bs)
		local rz = bitStreamReadFloat(bs)
		data.rotation = {x=rx,y=ry,z=rz}
		if objs[objectId] ~= nil then
			objs[objectId].rotation = data.rotation
		end
		if type(onSetObjectPosition) == 'function' then
			onSetObjectPosition(objectId, data.rotation)
		end
		bitStreamDelete(bs)
	end
	if id == 47 then
		local bs = bitStreamInit(data, size)
		local data = {}
		local objectId = bitStreamReadWord(bs)
		objs[objectId] = nil
		bitStreamDelete(bs)
	end
end

local function check(id,e)
	id = tonumber(id)
	if objs[id] == nil then
		return nil
	end
	if e then
		return objs[id][e]
	end
	return objs[id]
end

function getAllObjects()
	return objs
end

function getObjectData(id)
	return check(id)
end

function getObjectCoordinates(id)
	data = check(id, 'position')
	if data ~= nil then
		return {true, data.x, data.y, data.z}
	end
	return {false, 0,0,0}
end

function doesObjectExist(id)
	data = check(id)
	if data ~= nil then
		return true
	end
	return false
end