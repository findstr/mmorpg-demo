local channel = require "channel"
local db = require "db"
local errno = require "protocol.errno"

local function r_roleinfo(uid, req, fd)
	print("r_roleinfo", uid)
	local info = db.roleload(uid)
	if not info then
		return channel.errorclient(fd, uid, "a_roleinfo", errno.ROLE_NONEXIST)
	end
	return channel.sendclient(fd, uid, "a_roleinfo", info)
end

local function r_rolecreate(uid, req, fd)
	print("r_rolecreate", uid, req.name)
	local info = db.roleload(uid)
	if info then
		return channel.sendclient(fd, uid, "a_rolecreate", info)
	end
	info = db.rolecreate(uid, req.name)
	print("realy create", info)
	return channel.sendclient(fd, uid, "a_rolecreate", info)
end

channel.regclient("r_roleinfo", r_roleinfo)
channel.regclient("r_rolecreate", r_rolecreate)

