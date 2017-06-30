local rpc = require "rpc"
local errno = require "protocol.errno"
local router = require "router"

local function r_roleinfo(uid, req, fd)
	print("r_roleinfo")
	rpc.send_error(fd, uid, "a_roleinfo", errno.ROLE_NONEXIST)
end

local function r_createrole(uid, req, fd)
	print("r_createrole")
end

router.regclient("r_roleinfo", r_roleinfo)
router.regclient("r_createrole", r_createrole)

