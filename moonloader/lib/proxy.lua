local et = {}
function onRecvRpc(id, data, size)
	if type(onRRpc) == 'function' then
		onRRpc(id,data,size)
	end
	for k,v in pairs(et) do
		v(id,data,size)
	end
end

return et