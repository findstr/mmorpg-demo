local core = require "silly.core"
local pack = string.pack

local M = {}
local obj = {}
local mt = { __index = M }
setmetatable(obj, mt)

function M.register(proto, cmd, func)
	local cmd = proto:querytag(cmd)
	local cb = function(uid, dat, fd)
		local req
		if #dat > 0 then
			req = proto:decode(cmd, dat)
		else
			req = NIL
		end
		func(uid, req, fd)
	end
	obj[cmd] = cb
end

return obj

