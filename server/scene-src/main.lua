local core = require "silly.core"
local env = require "silly.env"
local channel = require "channel"
local rpccmd = require "protocol.rpc"
local tool = require "tool"
local xml = require "XML"
local unpack = string.unpack

require "logic"

local slaveid = tonumber(env.get("sceneid"))
local slavetype = "scene"
local xmlpath = env.get("xmlconfig")

local EVENT = {
	connected = function(gateid)
	end,
	close = function(gateid)
	end,
}

core.start(function()
	local l = tool.hublist()
	for k, v in pairs(l) do
		print(string.format("[role] gateid:%s port:%s", k, v))
	end
	local cmd = string.format("find %s -name '*.xml'", xmlpath)
	local ok = channel.start {
		channelid = slaveid,
		channeltype = slavetype,
		hublist = l,
		event = EVENT,
		rpccmd = rpccmd,
	}
	print("[role] server start", ok)
end)

