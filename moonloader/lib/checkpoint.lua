if proxy == nil then
	proxy = dofile(getRakBotPath()..'\\scripts\\libs\\luaAddons\\proxy.lua')
end
function proxy.Checkpoint(id,data,size)
	if id == 38 then
		local bs = bitStreamInit(data, size)
		local px = bitStreamReadFloat(bs)
		local py = bitStreamReadFloat(bs)
		local pz = bitStreamReadFloat(bs)
		local position = {x=px,y=py,z=pz}
		local radius = bitStreamReadFloat(bs)
		if type(onSetCheckpoint) == 'function' then
			onSetCheckpoint(position, radius)
		end
		bitStreamDelete(bs)
	end
	if id == 107 then
		local bs = bitStreamInit(data, size)
		local t = bitStreamReadByte(bs)
		local px = bitStreamReadFloat(bs)
		local py = bitStreamReadFloat(bs)
		local pz = bitStreamReadFloat(bs)
		local position = {x=px,y=py,z=pz}
		local npx = bitStreamReadFloat(bs)
		local npy = bitStreamReadFloat(bs)
		local npz = bitStreamReadFloat(bs)
		local nextPosition = {x=npx,y=npy,z=npz}
		local size = bitStreamReadFloat(bs)
		if type(onSetRaceCheckpoint) == 'function' then
			onSetRaceCheckpoint(t, position, nextPosition, size)
		end
		bitStreamDelete(bs)
	end
end