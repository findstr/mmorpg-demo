local core = require "silly.core"
local np = require "netpacket"
local token = require "token"
local cproto = require "protocol.client"
local errno = require "protocol.errno"
local master = require "cluster.master"
local hub = require "channelhub"
local tinsert = table.insert
local tremove = table.remove
local unpack = string.unpack
local pack = string.pack

local M = {}
local mt = {__index = M}

------------agent router
local CMD = {}
local function register(cmd, func)
	cmd = cproto:querytag(cmd)
	CMD[cmd] = func
end
-----------socket
local ERR = {
	cmd = false,
	err = false,
}

local function sendclient(fd, cmd, ack)
	local cmd = cproto:querytag(cmd);
	local hdr = pack("<I4", cmd);
	local dat = cproto:encode(cmd, ack);
	return master.sendmaster(fd, hdr .. dat);
end

local function errorclient(fd, cmd, err)
	ERR.cmd = cproto:querytag(cmd)
	ERR.err = err
	return sendclient(fd, "a_error", ERR)
end

----------agent interface
local agentpool = {}
local weakmt = {__mode = "kv"}
setmetatable(agentpool, weakmt)

local function agent_new(self, gatefd)
	local obj = {
		srole = false,	--role server id
		slogin = false,	--login server id
		uid = false,
		gatefd = gatefd,
	}
	setmetatable(obj, mt)
	return obj
end


local function agent_create(self, gatefd)
	local a = tremove(agentpool)
	if not a then
		a = agent_new(gatefd)
	else
		a.gatefd = gatefd
	end
	return a
end

local function agent_free(self)
	for k, _ in pairs(self) do
		self[k] = false
	end
	return tinsert(agentpool, self)
end

local function agent_logout(self)
	hub.logout(self)
	agent_free(self)
end

local function agent_kickout(self)
	master.kickmaster(self)
	agent_free(self)
end

local function agent_masterdata(self, fd, d, sz)
	local dat = core.tostring(d, sz)
	np.drop(d);
	local cmd = unpack("<I4", dat);
	local ok = hub.tryforward(self, cmd, dat)
	if ok then
		return
	end
	local dat = dat:sub(4 + 1)
	local req = cproto:decode(cmd, dat)
	local func = CMD[cmd]
	if not func then
		print("[gate] forward fail cmd:", cmd)
		return
	end
	func(self, req)
end

local function agent_slavedata(self, cmd, data)
	master.sendmaster(self.gatefd, data:sub(4+1))
end

------------protocol

local a_gatelogin = {}
local function r_login(self, req)
	local ok = token.validate(req.uid, req.token)
	if not ok then
		return errorclient(self.gatefd, "a_gatelogin",
			errno.ACCOUNT_TOKEN_INVALID);
	end
	local uid = req.uid
	self.uid = uid
	hub.login(uid, self)
	print("r_login", self.gatefd)
	sendclient(self.gatefd, "a_gatelogin", a_gatelogin)
end

register("r_gatelogin", r_login)

-----------interface
--[[ agent interface
agent {
	create	-- create agent[used by master]
	logout  -- logout [used by master]
	kickout	-- kickout [used by channelhub]
	masterdata -- master data process [used by master]
	slavedata -- slave data process [used by channelhub]
	uid	-- roleid [used by channelhub]
}
]]--

M.create = agent_create
M.logout = agent_logout
M.kickout = agent_kickout
M.masterdata = agent_masterdata
M.slavedata = agent_slavedata

return M

