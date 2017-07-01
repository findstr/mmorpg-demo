local core = require "silly.core"
local env = require "silly.env"
local msg = require "saux.msg"
local np = require "netpacket"
local crypt = require "crypt"
local const = require "const"
local channel = require "channel"
local proto = require "protocol.client"
local errno = require "protocol.errno"
local db = require "dbinst"
local sformat = string.format

local S
local M = {}
local CMD = {}
local challenge_key = {}
local uid_online_gate = {}

-------------------logic
local ERR = {
	cmd = 0,
	err = 0
}

local function cmd_send(fd, cmd, ack)
	local cmd = proto:querytag(cmd)
	local hdr = string.pack("<I4", cmd)
	local body = proto:encode(cmd, ack)
	return S:send(fd, hdr .. body)
end

local function cmd_error(fd, cmd, err)
	ERR.cmd = proto:querytag(cmd)
	ERR.err = err
	return cmd_send(fd, "a_error", ERR)
end

local function reg(cmd, func)
	CMD[proto:querytag(cmd)] = func
end

--[[
	account:idx [int]
	account:set [name -> id]
	account:[uid]:name [string]
	account:[uid]:passwd [string]
]]--

local account_idx = "account:idx"
local account_set = "account:set"
local account_name = "account:%s:name"
local account_passwd = "account:%s:passwd"

local function get_account_passwd(user)
	local ok, uid = db.inst:hget(account_set, user)
	if not ok then
		return
	end
	local ok, passwd = db.inst:get(sformat(account_passwd, uid))
	if not ok then
		return
	end
	return passwd, uid
end

local a_accountcreate = {
	uid = false,
}
reg("r_accountcreate", function(fd, req)
	local name = req.user
	local passwd = req.passwd
	local ok, uid = db.inst:hget(account_set, name)
	print("logind hget:", ok, uid)
	if ok then
		a_accountcreate.uid = tonumber(uid)
		cmd_send(fd, "a_accountcreate", a_accountcreate)
		print("[logind] r_accountcreate", name, uid)
		return
	end
	local ok, uid = db.inst:incr(account_idx)
	print("create", ok, uid)
	if not ok then
		print("[logind] create user fail", uid)
		return cmd_error(fd, cmd, errno.ACCOUNT_CREATE)
	end
	db.inst:hset(account_set, name, uid)
	db.inst:set(sformat(account_name, uid), name)
	db.inst:set(sformat(account_passwd, uid), passwd)
	a_accountcreate.uid = tonumber(uid)
	cmd_send(fd, "a_accountcreate", a_accountcreate)
	print("[logind] r_accountcreate", name, uid)
end)

local a_accountchallenge = {
	randomkey = false,
}
reg("r_accountchallenge", function(fd, req)
	local key = crypt.randomkey()
	a_accountchallenge.randomkey = key
	challenge_key[fd] = key
	cmd_send(fd, "a_accountchallenge", a_accountchallenge)
	print("[logind] r_accountchallenge",fd, key)
end)

local sr_kickout = {
	rpc = false,
}

local sr_fetchtoken = {
	rpc = false,
}

local a_accountlogin = {
	uid = false,
	token = false,
}

local function auth(fd, user, passwd)
	local key = challenge_key[fd]
	if not key then
		return nil, errno.ACCOUNT_NO_CHALLENGE
	end
	challenge_key[fd] = nil
	local md5 , uid = get_account_passwd(user)
	if not md5 or not uid then
		return nil, errno.ACCOUNT_NO_USER
	end
	local hmac = crypt.hmac(md5 , key)
	if hmac ~= passwd then
		return nil, errno.ACCOUNT_NO_PASSWORD
	end
	uid = tonumber(uid)
	local kick_gate = uid_online_gate[uid]
	print("online uid", uid, "kick gate", kick_gate)
	if not kick_gate then
		return uid
	end
	sr_kickout.uid = uid
	local ack = channel.call(kick_gate, uid, "sr_kickout", sr_kickout)
	if not ack then
		return nil, errno.ACCOUNT_KICK_TIMEOUT
	end
	return uid
end

reg("r_accountlogin", function(fd, req)
	local uid, err = auth(fd, req.user, req.passwd)
	if not uid then
		return cmd_error(fd, "a_accountlogin", err)
	end
	local gateid = req.gateid
	local ack = channel.call(gateid, uid, "sr_fetchtoken", sr_fetchtoken)
	print("[logind] r_accountlogin", uid, ack)
	if not ack then
		return cmd_error(fd, "a_accountlogin", errno.ACCOUNT_TOKEN_TIMEOUT)
	end
	a_accountlogin.uid = uid
	a_accountlogin.token = ack.token
	cmd_send(fd, "a_accountlogin", a_accountlogin)
end)

------------------start
function M.start(port)
	S = msg.createserver {
		addr = port,
		accept = function(fd, addr)
			print("accept", fd, addr)
		end,
		close = function(fd, errno)
			print("close", fd, errno)
		end,
		data = function(fd, d, sz)
			local str = core.tostring(d, sz)
			np.drop(d)
			local len = #str
			assert(len >= 4)
			local data
			local cmd = string.unpack("<I4", str)
			if len > 4 then
				data = proto:decode(cmd, str:sub(4+1))
			else
				data =  const.EMPTY
			end
			assert(CMD[cmd], cmd)(fd, data)
		end
	}
	local ok = S:start()
	print("[logind] start", ok)
end

return M

