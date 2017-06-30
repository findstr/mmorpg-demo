local core = require "silly.core"
local slave = require "cluster.slave"
local router = require "router"
local sproto = require "protocol.server"
local cproto = require "protocol.client"
local pack = string.pack

local M = {}

local SERVER
local TIMEOUT = 10000
local TIMER = 1000
local socket = {
	--['fd'] = {
	--	suspend = {}
	--	wheel = {}
	--}
}

local socket_send = slave.send

local function wheel(time)
	local wheel = time % TIMEOUT
	return wheel // TIMER
end

local function wakeupall(socket)
	local rpc_suspend = socket.suspend
	for k, co in pairs(rpc_suspend) do
		core.wakeup(co)
		rpc_suspend[k] = nil
	end
end

local function initwheel(socket)
	local wheel = {}
	for i = 0, TIMEOUT // TIMER do
		wheel[i] = {}
	end
	socket.wheel = wheel
end

local function waitfor(socket, id)
	local co = core.running()
	local w = wheel(core.current() + TIMEOUT)
	socket.suspend[id] = co
	local expire = socket.wheel[w]
	expire[#expire + 1] = id
	return core.wait()
end

local function timer(now, socket)
	local w = wheel(now)
	local expire = socket.wheel[w]
	local suspend = socket.suspend
	for k, session in pairs(expire) do
		local co = suspend[session]
		if co then
			print("[rpc] timeout session:", session)
			suspend[session] = nil
			core.wakeup(co)
		end
		expire[k] = nil
	end
end

local function timer_wrapper()
	local now = core.current()
	for _, s in pairs(socket) do
		local ok ,err = core.pcall(timer, now, s)
		if not ok then
			print(err)
		end
	end
	core.timeout(TIMER, timer_wrapper)
end

local function rpc_ack(uid, ack, fd)
	local s = socket[fd]
	if not s then
		print("[rpc] socket close:", fd)
	end
	local rpc = assert(ack.rpc, "rpc_ack need field 'rpc'")
	local co = s.suspend[rpc]
	if not co then
		print("[rpc] session timout:", rpc)
		return
	end
	core.wakeup(co, ack)
	s.suspend[rpc] = nil
end

local function send(proto, gateid, uid, cmd, ack)
	cmd = proto:querytag(cmd)
	local hdr = pack("<I4I4", uid, cmd)
	local dat = proto:encode(cmd, ack)
	return socket_send(gateid, hdr .. dat)
end

local function sendserver(gateid, uid, cmd, ack)
	return send(sproto, gateid, uid, cmd, ack)
end

function M.call(fd, uid, cmd, req)
	local s = socket[fd]
	if not s then
		return
	end
	local rpc = core.genid()
	req.rpc = rpc
	local ok = sendserver(fd, uid, cmd, req)
	if not ok then
		return
	end
	return waitfor(s, rpc)
end

function M.send_client(gateid, uid, cmd, ack)
	return send(cproto, gateid, uid, cmd, ack)
end

local ERR = {
	cmd = false,
	err = false,
}

function M.send_error(gateid, uid, cmd, err)
	ERR.cmd = cproto:querytag(cmd)
	ERR.err = err
	return send(cproto, gateid, uid, "a_error", ERR)
end

function M.reg(cmd)
	router.regserver(cmd, rpc_ack)
end

M.send_server = sendserver
---------------event
function M.connected(fd)
	local s = {
		wheel = false,
		suspend = {},
	}
	initwheel(s)
	socket[fd] = s
end

function M.close(fd)
	local s = socket[fd]
	if not s then
		return
	end
	wakeupall(s)
	socket[fd] = nil
end

------------start

function M.start()
	timer_wrapper()
end

return M

