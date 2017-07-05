local channel = require "channel"
local errno = require "protocol.errno"

local function s_login(uid, req, fd)

end

local function sr_logout(uid, req, fd)

end

local function r_movedir(uid, req, fd)

end

local function r_movepoint(uid, req, fd)

end

local function r_movestop(uid, req, fd)

end

local function r_movesync(uid, req, fd)

end


channel.regserver("s_login", s_login)
channel.regserver("sr_logout", sr_logout)
channel.regclient("r_movedir", r_movedir)
channel.regclient("r_movepoint", r_movepoint)
channel.regclient("r_movestop", r_movestop)
channel.regclient("r_movesync", r_movesync)

