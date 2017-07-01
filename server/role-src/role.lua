local channel = require "channel"
local errno = require "protocol.errno"

local function r_roleinfo(uid, req, fd)
	print("r_roleinfo")
	channel.errorclient(fd, uid, "a_roleinfo", errno.ROLE_NONEXIST)
end

local function r_createrole(uid, req, fd)
	print("r_createrole")
end

channel.regclient("r_roleinfo", r_roleinfo)
channel.regclient("r_createrole", r_createrole)

