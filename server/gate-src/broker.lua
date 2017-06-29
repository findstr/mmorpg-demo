local core = require "silly.core"
local np = require "netpacket"
local online = require "online"
local sproto = require "protocol.server"
local master = require "cluster.master"
local pack = string.pack
local unpack = string.unpack
local M = {}

--------router
local CMD = {}
local NIL = {}
local forward_func
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

local function reg_forward(func)
	local cb = function(uid, dat, fd)
		func(uid, dat:sub(8 + 1), cmd)
	end
	forward_func = cb
end

--------slave router
local POWER = 10000
local slave_type_key = {
	--login
	["login"] = 1 * POWER,
	[1 * POWER] = "login",
	--role
	["role"] = 2 * POWER,
	[2 * POWER] = "role"
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
	forward_func(uid, dat, fd)
end

--------interface
local function send_server(fd, uid, cmd, ack)
	cmd = sproto:querytag(cmd)
	local hdr = pack("<I4I4", uid, cmd)
	local dat = sproto:encode(cmd, ack)
	master.sendslave(fd, hdr .. dat)
end

function M.forward(fd, uid, dat)
	local hdr = pack("<I4", uid)
	master.sendslave(fd, hdr .. dat)
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
	print("fetch token")
end

local function sr_kickout(uid, req, fd)
	print("fetch kickout")
end

local function s_multicast(uid, req, fd)
	print("muticast")
end

reg_server("sr_register", sr_register)
reg_server("sr_fetchtoken", sr_fetchtoken)
reg_server("sr_kickout", sr_kickout)
reg_server("s_multicast", s_multicast)

return M

