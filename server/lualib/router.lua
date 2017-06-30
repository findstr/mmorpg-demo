local sproto = require "protocol.server"
local cproto = require "protocol.client"
local core = require "silly.core"
local pack = string.pack

local M = {}
local obj = {}
local client = {}
local mt = { __index = M }
setmetatable(obj, mt)

local function register(proto, cmd, func)
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

function M.regserver(cmd, func)
	local cmd = sproto:querytag(cmd)
	register(sproto, cmd, func)
end

function M.regclient(cmd, func)
	local cmd = cproto:querytag(cmd)
	register(cproto, cmd, func)
	client[cmd] = true
end

M.client = client

return obj

