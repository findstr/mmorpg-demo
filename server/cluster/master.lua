local core = require "silly.core"
local msg = require "saux.msg"
local np = require "netpacket"
local spack = string.pack
local sunpack = string.unpack
local tremove = table.remove
local tinsert = table.insert
local sformat = string.format
local AGENT

local M = {}

local master_inst
local slave_inst

local masterfd_agent = {}

--[[

master.start {
	'openport' = client connect port,
	'slaveport' = slave connect port,
	'slave' = SLAVE , --handler for slave
	'agent' = AGENT,
}

AGENT {
	'create' = function(self, fd)
	'init' = function(self, fd)
	'kick' = function(self)
	'masterdata' = function(self, fd, d, sz)
}

SLAVE {
	'accept' = function(fd, addr),
	'data' = function(fd, d, sz)
	'close' = function(fd, errno)
}

]]--

local agent_pool = {}
local weak_mt = {__mode = "kv"}
setmetatable(agent_pool, weak_mt)
local function createagent(masterfd)
	local a = tremove(agent_pool)
	if not a then
		a = AGENT:create(masterfd)
	else
		a:init(masterfd)
	end
	return a
end

local function freeagent(a)
	a:kick()
	tinsert(agent_pool, a)
end

M.sendslave = function(fd, data)
	slave_inst:send(fd, data)
end

M.sendmaster = function(fd, data)
	master_inst:send(fd, data)
end

M.kickmaster = function(fd, data)
	local a = masterfd_agent[fd]
	masterfd_agent[masterfd] = nil
	freeagent(a)
	master_inst:close(fd)
end

function M.start(config)
	AGENT = assert(config.agent, "need agent")
	local slave = config.slave
	master_inst = msg.createserver {
		addr = config.openport,
		accept = function(fd, addr)
			print("[master] client accept", fd, addr)
			masterfd_agent[fd] = createagent(fd)
		end,
		close = function(fd, errno)
			print("[master] client close", fd, errno)
			local a = masterfd_agent[fd]
			masterfd_agent[fd] = nil
			freeagent(a)
		end,
		data = function(fd, d, sz)
			print("[master] client data", fd)
			local a = assert(masterfd_agent[fd], fd)
			a:masterdata(fd, d, sz)
		end
	}
	slave_inst = msg.createserver {
		addr = config.slaveport,
		accept = function(fd, addr)
			print("[master] slave accept", fd, addr)
			slave.accept(fd, addr)
		end,
		close = function(fd, errno)
			print("[master] slave close", fd, errno)
			slave.close(fd, errno)
		end,
		data = function(fd, d, sz)
			print("[master] slave data", fd)
			slave.data(fd, d, sz)
		end
	}
	local master_ok = master_inst:start();
	if not master_ok then
		print(sformat("[master] listen %s fail", config.openport))
		return master_ok
	end
	local slave_ok = slave_inst:start()
	if not slave_ok then
		print(sformat("[master] listen %s fail", config.slaveport))
		return slave_ok
	end
	return true
end

return M

