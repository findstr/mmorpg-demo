local core = require "silly.core"
local np = require "netpacket"
local token = require "token"
local online = require "online"
local sproto = require "protocol.server"
local master = require "cluster.master"
local pack = string.pack
local unpack = string.unpack
local M = {}

--------router
local CMD = {}
local NIL = {}
local readonly_mt = {__newindex = function() assert("read only") end}
setmetatable(NIL, readonly_mt)

local function reg_server(cmd, func)
	local cmd = sproto:querytag(cmd)
	local cb = function(uid, dat, fd)
		local req
		if #dat > 8 then
			dat = dat:sub(8 + 1)
			req = sproto:decode(cmd, dat)
		else
			req = NIL
		end
		func(uid, req, fd)
	end
	CMD[cmd] = cb
end

--------slave router

local LOGIN_TYPE = 1 * 10000
local ROLE_TYPE = 2 * 10000
local slave_type_key = {
	--login
	["login"] = LOGIN_TYPE,
	[LOGIN_TYPE] = "login",
	--role
	["role"] = ROLE_TYPE,
	[ROLE_TYPE] = "role"
}

local slave_fd_typeid = {
	--[fd] = 'slave_type_key[type] + serverid'
}

local slave_typeid_fd = {
	--[slave_type_key[type] + serverid] = fd
}
local slave_cmd_typeid = {
	--[cmd] = typeid
}

local function slave_reg(typ, id, fd, list_cmd)
	local typeid = assert(slave_type_key[typ], typ)
	for _, v in pairs(list_cmd) do
		local typ = slave_cmd_typeid[v]
		if typ then
			assert(typ == typeid)
		else
			slave_cmd_typeid[v] = typeid
		end
	end
	typeid = typeid + id
	slave_fd_typeid[fd] = typeid
	slave_typeid_fd[typeid] = fd
end

local function slave_clear(fd)
	local typeid = slave_fd_typeid[fd]
	if not typeid then
		return
	end
	slave_fd_typeid[fd] = nil
	slave_typeid_fd[typeid] = nil
end

---------event

function M.accept(fd, addr)

end

function M.close(fd, errno)
	slave_clear(fd)
end

function M.data(fd, d, sz)
	local dat = core.tostring(d, sz)
	np.drop(d)
	local uid, cmd = unpack("<I4I4", dat)
	local func = CMD[cmd]
	if func then
		func(uid, dat, fd)
		return
	end
	local a = online.agent(uid)
	if not a then
		print("[gate] broker data uid:", uid, " logout")
		return
	end
	a:slavedata(cmd, dat)
end

--------interface
local function send_server(fd, uid, cmd, ack)
	cmd = sproto:querytag(cmd)
	local hdr = pack("<I4I4", uid, cmd)
	local dat = sproto:encode(cmd, ack)
	master.sendslave(fd, hdr .. dat)
end

local function forward(fd, uid, dat)
	local hdr = pack("<I4", uid)
	master.sendslave(fd, hdr .. dat)
end

local SERVER_KEY = {
	[LOGIN_TYPE] = "logins",
	[ROLE_TYPE] = "roles",
}

function M.tryforward(agent, cmd, dat) --dat:[cmd][packet]
	local typeid = slave_cmd_typeid[cmd]
	if not typeid then
		return false
	end
	local key = SERVER_KEY[typeid]
	local id = agent[key]
	typeid = typeid + id
	local fd = slave_typeid_fd[typeid]
	if not fd then
		return false
	end
	return forward(fd, agent.uid, dat)
end

M.reg_server = reg_server
M.reg_forward = reg_forward
M.send = send_server

---------handler

local function sr_register(uid, req, fd)
	print("[gate] sr_register:", req.typ)
	for k, _ in pairs(req.handler) do
		print(string.format("[gate] sr_register %s", k))
	end
	slave_reg(req.typ, req.id, fd, req.handler)
	send_server(fd, uid, "sa_register", req)
end

local function sr_fetchtoken(uid, req, fd)
	local tk = token.fetch(uid)
	req.token = tk
	send_server(fd, uid, "sa_fetchtoken", req)
	print("[gate] fetch token", uid, tk)
end

local function sr_kickout(uid, req, fd)
	local gatefd = online.gatefd(uid)
	if gatefd then
		master.kickmaster(gatefd)
	end
	send_server(fd, uid, "sa_kickout", req)
	print("[gate]fetch kickout uid:", uid, "gatefd", gatefd)
end

local function s_multicast(uid, req, fd)
	print("muticast")
end

reg_server("sr_register", sr_register)
reg_server("sr_fetchtoken", sr_fetchtoken)
reg_server("sr_kickout", sr_kickout)
reg_server("s_multicast", s_multicast)

return M

