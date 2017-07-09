local core = require "silly.core"
local env = require "silly.env"
local channel = require "channel"
local rpccmd = require "protocol.rpc"
local tool = require "tool"
local db = require "db"
local scene = require "scene"
local xml = require "XML"
local unpack = string.unpack

require "role"
require "logic"

local slaveid = tonumber(env.get("sceneid"))
local slavetype = "scene"
local xmlpath = env.get("xmlconfig")

local EVENT = {
	connected = function(fd, online)
		local tbl = {}
		for i = 1, #online do
			local uid = online[i]
			tbl[uid] = "online"
			print("[scene] online", uid)
		end
		channel.onlinepatch(tbl)
		scene.onlinepatch(tbl)
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
	xml.parselist {
		xmlpath .. "/ItemUse.xml",
	}
	scene.start(1000, 1000)
	local dbok = db.start()
	local channelok = channel.start {
		channelid = slaveid,
		channeltype = slavetype,
		hublist = l,
		event = EVENT,
		rpccmd = rpccmd,
	}
	print("[role] server start, dbstart", dbok, "channelstart", channelok)
end)

