local core = require "silly.core"
local np = require "netpacket"
local token = require "token"
local sproto = require "protocol.server"
local master = require "cluster.master"
local pack = string.pack
local unpack = string.unpack

----------------socket
local function sendserver(fd, uid, cmd, ack)
	cmd = sproto:querytag(cmd)
	local hdr = pack("<I4I4", uid, cmd)
	local dat = sproto:encode(cmd, ack)
	return master.sendslave(fd, hdr .. dat)
end

local function forwardserver(fd, uid, dat)
	local hdr = pack("<I4", uid)
	return master.sendslave(fd, hdr .. dat)
end

----------------channel router
local NIL = {}
local CMD = {}
local readonly = {__newindex = function() assert("read only table") end}
local router_handler = {}
local function router_regserver(cmd, func)
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

----------------online
local LOGIN_TYPE = 1 * 10000
local SCENE_TYPE = 3 * 10000
local SCENE_KEY = "sscene"
local agent_serverkey = {
	[LOGIN_TYPE] = "slogin",
	[SCENE_TYPE] = "sscene",
}
local online_agent = {}
local function online_login(uid, agent)
	online_agent[uid] = agent
	agent.slogin = 1
	agent.srole = 1
	agent.sscene = 1
end

local function online_logout(uid)
	local a = online_agent[uid]
	if not a then
		return
	end
	a.slogin = false
	s.srole = false
	online_agent[uid] = nil
end

local function online_kickout(uid)
	local a = online_agent[uid]
	if not a then
		return
	end
	a.slogin = false
	a.srole = false
	a:kickout()
	online_agent[uid] = nil
end

--------------channel forward
local SCENE_NAME = "scene"
local channel_type_key = {
	["login"] = LOGIN_TYPE,
	[SCENE_NAME] = SCENE_TYPE,
}

local channel_fd_typeid = {
	--[fd] = 'channel_type_key[type] + serverid'
}

local channel_typeid_fd = {
	--[channel_type_key[type] + serverid] = fd
}
local channel_cmd_typeid = {
	--[cmd] = typeid
}

local function channel_regclient(typ, id, fd, list_cmd)
	local typeid = assert(channel_type_key[typ], typ)
	for _, v in pairs(list_cmd) do
		local typ = channel_cmd_typeid[v]
		if typ then
			assert(typ == typeid)
		else
			channel_cmd_typeid[v] = typeid
		end
	end
	typeid = typeid + id
	channel_fd_typeid[fd] = typeid
	channel_typeid_fd[typeid] = fd
end

local function channel_clear(fd)
	local typeid = channel_fd_typeid[fd]
	if not typeid then
		return
	end
	channel_fd_typeid[fd] = nil
	channel_typeid_fd[typeid] = nil
end

local function channel_tryforward(agent, cmd, dat) --dat:[cmd][packet]
	local typeid = channel_cmd_typeid[cmd]
	if not typeid then
		return false
	end
	local key = agent_serverkey[typeid]
	local id = agent[key]
	if not id then
		return false
	end
	typeid = typeid + id
	local fd = channel_typeid_fd[typeid]
	if not fd then
		return false
	end
	return forwardserver(fd, agent.uid, dat)
end

local function channel_sendscene(agent, cmd, req)
	local id = agent[SCENE_KEY]
	local typeid = id + SCENE_TYPE
	local fd = channel_typeid_fd[typeid]
	if not fd then
		return false
	end
	return sendserver(fd, agent.uid, cmd, req)
end

----------------protocol

local function sr_register(uid, req, fd)
	print("[gate] sr_register:", req.typ, req.id)
	for _, v in pairs(req.handler) do
		print(string.format("[gate] sr_register %s", v))
	end
	channel_regclient(req.typ, req.id, fd, req.handler)
	if req.typ == SCENE_NAME then
		local l = {}
		for uid, agent in pairs(online_agent) do
			if agent[SCENE_KEY] == req.id then
				l[#l + 1] = uid
			end
		end
		req.online = l
	end
	return sendserver(fd, uid, "sa_register", req)
end

local function sr_fetchtoken(uid, req, fd)
	local tk = token.fetch(uid)
	req.token = tk
	print("[gate] fetch token", uid, tk)
	return sendserver(fd, uid, "sa_fetchtoken", req)
end

local function sr_kickout(uid, req, fd)
	online_kickout(uid)
	print("[gate]fetch kickout uid:", uid, "gatefd", gatefd)
	return sendserver(fd, uid, "sa_kickout", req)
end

local function s_multicast(uid, req, fd)
	local uids = req.uid
	local dat = req.data
	local count = #uids
	print("muticast", count)
	if count == 1 then
		local agent = online_agent[uids[1]]
		if not agent then
			return
		end
		return master.sendmaster(agent.gatefd, dat)
	end
	local pk, sz = np.pack(dat)
	local mp = core.packmulti(pk, sz, #uids)
	np.drop(pk)
	for _, uid in pairs(uids) do
		local agent = online_agent[uid]
		if not agent then
			core.freemulti(mp, sz)
		else
			master.multicastmaster(agent.gatefd, mp, sz)
		end
	end
end

router_regserver("sr_register", sr_register)
router_regserver("sr_fetchtoken", sr_fetchtoken)
router_regserver("sr_kickout", sr_kickout)
router_regserver("s_multicast", s_multicast)

--------------entry

local M = {
login = online_login,
logout = online_logout,
tryforward = channel_tryforward,
sendscene = channel_sendscene,
--event
accept = function(fd, addr)
end,
close = function(fd, errno)
	channel_clear(fd)
end,
data = function(fd, d, sz)
	local dat = core.tostring(d, sz)
	np.drop(d)
	local uid, cmd = unpack("<I4I4", dat)
	local func = CMD[cmd]
	if func then
		func(uid, dat, fd)
		return
	end
	local a = online_agent[uid]
	if not a then
		print("[gate] broker data uid:", uid, " logout")
		return
	end
	a:slavedata(cmd, dat)
end,

}

return M

