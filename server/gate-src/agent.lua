local core = require "silly.core"
local np = require "netpacket"
local broker = require "broker"
local token = require "token"
local online = require "online"
local cproto = require "protocol.client"
local errno = require "protocol.errno"
local master = require "cluster.master"
local unpack = string.unpack
local pack = string.pack

local M = {}
local mt = {__index = M}

local CMD = {}

----------interface

function M.init(self, gatefd)
	self.roles = false
	self.uid = false
	self.logins = false
	self.gatefd = gatefd
end

function M.create(self, gatefd)
	local obj = {
		roles = false,	--role server id
		uid = false,
		logins = false,	--login server id
		gatefd = gatefd,
	}
	setmetatable(obj, mt)
	print('agent create')
	return obj
end

function M.kick(self)
	self.roles = false
	self.uid = false
	self.gatefd = false
	self.logins = false
	print('agent kick')
end

function M.masterdata(self, fd, d, sz)
	local dat = core.tostring(d, sz)
	np.drop(d);
	local cmd = unpack("<I4", dat);
	local ok = broker.tryforward(self, cmd, dat)
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

function M.slavedata(self, cmd, data)
	master.sendmaster(self.gatefd, data:sub(4+1))
end

------------protocol

local function register(cmd, func)
	cmd = cproto:querytag(cmd)
	CMD[cmd] = func
end

local function sendclient(fd, cmd, ack)
	local cmd = cproto:querytag(cmd);
	local hdr = pack("<I4", cmd);
	local dat = cproto:encode(cmd, ack);
	return master.sendmaster(fd, hdr .. dat);
end

local ERR = {
	cmd = false,
	err = false,
}
local function senderror(fd, cmd, err)
	ERR.cmd = cproto:querytag(cmd)
	ERR.err = err
	return sendclient(fd, "a_error", ERR)
end

------------

local a_gatelogin = {}
local function r_login(self, req)
	local ok = token.validate(req.uid, req.token)
	if not ok then
		return senderror(self.gatefd, "a_gatelogin",
			errno.ACCOUNT_TOKEN_INVALID);
	end
	--TODO:init roleserver, loginserver
	local uid = req.uid
	self.uid = uid
	self.roles = 1
	online.login(uid, self.gatefd, self)
	sendclient(self.gatefd, "a_gatelogin", a_gatelogin)
end



-----------

register("r_gatelogin", r_login)

return M

