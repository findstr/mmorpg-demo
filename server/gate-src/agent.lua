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
local NIL = {}

local notify_logout

------------agent router
local CMD = {}
local function regclient(cmd, func)
	cmd = cproto:querytag(cmd)
	CMD[cmd] = func
end

local function regclientproto(cmd, func)
	cmd = cproto:querytag(cmd)
	local cb = function(self, cmd, dat)
		local req = cproto:decode(cmd, dat, 4)
		func(self, req)
	end
	CMD[cmd] = cb
end

local function protowrapper(proto, cb)
	return function(self, cmd, data)
		local pk
		if #data > 8 then
			req = proto:decode(cmd, data, 8)
		else
			req = NIL
		end
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
		start = false,
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
	print("agent_create", gatefd, a)
	return a
end

local function agent_free(self)
	print("agent_free", self)
	if self.uid and self.start then
		db.updatecoord(self.uid, self.coord_x, self.coord_z)
	end
	for k, _ in pairs(self) do
		self[k] = false
	end
	return tinsert(agentpool, self)
end

local function agent_logout(self)
	local uid = self.uid
	if uid then
		notify_logout(self)
		hub.logout(uid)
	end
	agent_free(self)
end

local a_gatekick = {}
local function agent_kickout(self)
	if self.uid then
		print("[agent] agent_kickout", self.uid)
		sendclient(self.gatefd, "a_gatekick", a_gatekick)
		notify_logout(self)
	end
	master.kickmaster(self.gatefd)
	agent_free(self)
end

local function agent_masterdata(self, fd, d, sz)
	local dat = np.tostring(d, sz)
	local cmd = unpack("<I4", dat);
	local func = CMD[cmd]
	if not func then
		return hub.tryforward(self, cmd, dat)
	else
		return func(self, cmd, dat)
	end
end

local function agent_coord(self)
	return self.coord_x, self.coord_z
end

------------protocol
local s_logout = {}

notify_logout = function (self)
	print("notify_logout", self.start)
	if not self.start then
		return
	end
	hub.sendscene(self, "s_logout", s_logout)
end

local a_gatelogin = {}
local function r_login(self, req)
	print("r_login", self)
	local ok = token.validate(req.uid, req.token)
	if not ok then
		return errorclient(self.gatefd, "a_gatelogin",
			errno.ACCOUNT_TOKEN_INVALID);
	end
	local uid = req.uid
	self.uid = uid
	hub.login(uid, self)
	return sendclient(self.gatefd, "a_gatelogin", a_gatelogin)
end

local s_login = {
	coord_x = false,
	coord_z = false,
}
local function r_startgame(self, req)
	print("r_startgame", self.uid, self.gatefd)
	self.start = true
	local x, z = db.coord(self.uid)
	self.coord_x, self.coord_z = x, z
	s_login.coord_x = x
	s_login.coord_z = z
	hub.sendscene(self, "s_login", s_login)
end

local function r_movesync(self, cmd, packet)
	local req = cproto:decode(cmd, dat, 4)
	self.coord_x = req.coord_x
	self.coord_z = req.coord_z
	return hub.tryforward(self, cmd, packet)
end

local function s_forcepoint(self, req)
	self.coord_x = req.coord_x
	self.coord_z = req.coord_z
end

regclientproto("r_gatelogin", r_login)
regclientproto("r_startgame", r_startgame)
regclient("r_movesync", r_movesync)
hub.regagent(sproto, "s_forcepoint", s_forcepoint)

-----------interface
--[[ agent interface
agent {
	create	-- create agent[used by master]
	logout  -- logout [used by master]
	kickout	-- kickout [used by channelhub]
	masterdata -- master data process [used by master]
	coord	-- coord of agent[used by channelhub]
	uid	-- roleid [used by channelhub]
	gatefd  -- masterfd [used by channelhub]
}
]]--

M.create = agent_create
M.logout = agent_logout
M.kickout = agent_kickout
M.masterdata = agent_masterdata
M.coord = agent_coord


return M

