local core = require "silly.core"
local env = require "silly.env"
local channel = require "channel"
local np = require "netpacket"
local logind = require "logind"
local rpccmd = require "protocol.rpc"
local db = require "dbinst"
local tool = require "tool"
local unpack = string.unpack

local EVENT = {
	connected = function(gateid)
	end,
	close = function(gateid)
	end,
}

core.start(function()
	local l = tool.hublist()
	for k, v in pairs(l) do
		print(string.format("[login] gateid:%s port:%s", k, v))
	end
	db.start()
	logind.start(env.get("loginport"))
	channel.start {
		channelid = 1,
		channeltype = "login",
		hublist = l,
		event = EVENT,
		rpccmd = rpccmd,
	}
	print("[login] server start")
end)

