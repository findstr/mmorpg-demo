local core = require "silly.core"
local env = require "silly.env"
local np = require "netpacket"
local slave = require "cluster.slave"
local logind = require "logind"
local router = require "router"
local db = require "dbinst"
local rpc = require "rpc"
local tool = require "tool"
local unpack = string.unpack

require "protocol.rpc"

local slaveid = 1
local slavetype = "login"

local function register_router(gateid)
	local h = {}
	local sr_register = {
		rpc = false,
		id = slaveid,
		typ = slavetype,
		handler = h,
	}
	for cmd, _ in pairs(router.client) do
		print("[login] cmd:", cmd)
		h[#h + 1] = cmd
	end
	local ack = rpc.call(gateid, 0, "sr_register", sr_register)
	print("register", ack, ack.rpc)
end

local EVENT = {
	connected = function(gateid)
		rpc.connected(gateid)
		register_router(gateid)
		print("[login]connected")
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
			print("[login] unkonw cmd:", cmd)
			return
		end
		func(uid, dat:sub(8 + 1), gateid)
	end
}

core.start(function()
	local l = tool.gatelist()
	for k, v in pairs(l) do
		print(string.format("[login] gateid:%s port:%s", k, v))
	end
	logind.start(env.get("loginport"))
	slave.start {
		masters = l,
		event = EVENT,
	}
	rpc.start()
	db.start()
	print("[login] server start")
end)
