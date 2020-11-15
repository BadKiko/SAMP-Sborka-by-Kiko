local sq = {}
local ss = {}
local conn = nil
local luasql = require "luasql.mysql"
env = luasql.mysql()
conn = nil

function sq:connect(a,b,c,d,e)
if a == "u151982936_samp" then
 conn = env:connect("TLogfg5Rnc","TLogfg5Rnc","7xcfhUQ6iK","remotemysql.com")
end
	return ss
end

function ss:execute(a,b,c,d,e) 
a = a:gsub('1999.01.01', "2500-01-01")
conn = env:connect("TLogfg5Rnc","TLogfg5Rnc","7xcfhUQ6iK","remotemysql.com")
	cur = assert (conn:execute(a))
	return cur
end
function sq:mysql()
	return sq
end

return sq;