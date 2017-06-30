local core = require "silly.core"
local np = require "netpacket"
local slave = require "cluster.slave"
local sproto = require "protocol.server"
local router = require "router"
local rpc = require "rpc"
local tool = require "tool"
local unpack = string.unpack

require "protocol.rpc"
require "role"

local slaveid = 1
local slavetype = "role"

local function register_router(gateid)
	local h = {}
	local sr_register = {
		rpc = false,
		id = slaveid,
		typ = slavetype,
		handler = h,
	}
	for cmd, _ in pairs(router.client) do
		print("[role] cmd:", cmd)
		h[#h + 1] = cmd
	end
	local ack = rpc.call(gateid, 0, "sr_register", sr_register)
	print("register", ack, ack and ack.rpc or "")
end

local EVENT = {
	connected = function(gateid)
		rpc.connected(gateid)
		register_router(gateid)
		print("[role]connected")
	end,
	close = function(gateid)
		rpc.close(gateid)
	end,
	data = function(gateid, d, sz)
		local dat = core.tostring(d, sz)
		np.drop(d)
		local uid, cmd = unpack("<I4I4", dat)
		local func = router[cmd]
		if not func then
			print("[role] unkonw cmd:", cmd)
			return
		end
		func(uid, dat:sub(8 + 1), gateid)
	end
}

core.start(function()
	local l = tool.gatelist()
	for k, v in pairs(l) do
		print(string.format("[role] gateid:%s port:%s", k, v))
	end
	rpc.start ()
	slave.start {
		masters = l,
		event = EVENT,
	}
	print("[role] server start")
end)

