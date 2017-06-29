local core = require "silly.core"
local env = require "silly.env"
local master = require "cluster.master"
local broker = require "broker"
local agent = require "agent"

core.start(function()
	local gateid = env.get("gateid")
	local openport = env.get("openport_" .. gateid)
	local brokerport = env.get("brokerport_" .. gateid)
	print(string.format("gateid:%s, openport:%s brokerport:%s",
		gateid, openport, brokerport))
	local ok = master.start {
		masterid = tonumber(gateid),
		openport = openport,
		slaveport = brokerport,
		slave = broker,
		agent = agent,
	}
	print("gate start:", ok)
end)
