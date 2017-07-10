local core = require "silly.core"
local np = require "netpacket"
local token = require "token"
local db = require "db"
local cproto = require "protocol.client"
local sproto = require "protocol.server"
local errno = require "protocol.errno"
local master = require "cluster.master"
local hub = require "channelhub"
local tinsert = table.insert
local tremove = table.remove
local unpack = string.unpack
local pack = string.pack

local M = {}
local mt = {__index = M}

local notify_logout

------------agent router
local CMD = {}
local function regclient(cmd, func)
	cmd = cproto:querytag(cmd)
	CMD[cmd] = func
end

local function regserver(cmd, func)
	cmd = sproto:querytag(cmd)
	CMD[cmd] = func
end

local function protowrapper(proto, cb)
	return function(self, cmd, data)
		data = data:sub(8 + 1)
		local pk = proto:decode(cmd, data)
		cb(self, pk)
	end
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
		coord_x = false,
		coord_z = false,
		gatefd = gatefd,
	}
	setmetatable(obj, mt)
	return obj
end


local function agent_create(self, gatefd)
	local a = tremove(agentpool)
	if not a then
		a = agent_new(self, gatefd)
	else
		a.gatefd = gatefd
	end
	return a
end

local function agent_free(self)
	if self.uid then
		db.updatecoord(self.uid, self.coord_x, self.coord_z)
	end
	for k, _ in pairs(self) do
		self[k] = false
	end
	return tinsert(agentpool, self)
end

local function agent_logout(self)
	if self.uid then
		notify_logout(self)
	end
	hub.logout(self)
	agent_free(self)
end

local function agent_kickout(self)
	if self.uid then
		notify_logout(self)
	end
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
	print("agent_slavedata:", #data - 4)
	local cb = CMD[cmd]
	if cb then
		data = data:sub(8 + 1)
		local req = cproto:decode(cmd, data)
		cb(self, req)
	else
		master.sendmaster(self.gatefd, data:sub(4+1))
	end
end

------------protocol
local s_login = {
	coord_x = false,
	coord_z = false,
}

local s_logout = {}

local function notify_login(self)
	s_login.coord_x = self.coord_x
	s_login.coord_z = self.coord_z
	hub.sendscene(self, "s_login", s_login)
end

notify_logout = function (self)
	hub.sendscene(self, "s_logout", s_logout)
end

local a_gatelogin = {
	coord_x = false,
	coord_z = false,
}
local function r_login(self, req)
	local ok = token.validate(req.uid, req.token)
	if not ok then
		return errorclient(self.gatefd, "a_gatelogin",
			errno.ACCOUNT_TOKEN_INVALID);
	end
	local uid = req.uid
	self.uid = uid
	local x, z = db.coord(uid)
	self.coord_x, self.coord_z = x, z
	a_gatelogin.coord_x = x
	a_gatelogin.coord_z = z
	hub.login(uid, self)
	notify_login(self)
	print("r_login", self, self.gatefd)
	return sendclient(self.gatefd, "a_gatelogin", a_gatelogin)
end

local function s_forcepoint(self, req)
	self.coord_x = req.coord_x
	self.coord_z = req.coord_z
end

regclient("r_gatelogin", protowrapper(cproto, r_login))
regserver("s_forcepoint", protowrapper(sproto, s_forcepoint))

-----------interface
--[[ agent interface
agent {
	create	-- create agent[used by master]
	logout  -- logout [used by master]
	kickout	-- kickout [used by channelhub]
	masterdata -- master data process [used by master]
	slavedata -- slave data process [used by channelhub]
	uid	-- roleid [used by channelhub]
	gatefd  -- masterfd [used by channelhub]
}
]]--

M.create = agent_create
M.logout = agent_logout
M.kickout = agent_kickout
M.masterdata = agent_masterdata
M.slavedata = agent_slavedata
return M

