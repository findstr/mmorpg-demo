local channel = require "channel"
local errno = require "protocol.errno"
local scene = require "scene"

local function s_login(uid, req, fd)
	print("xxlogin", uid, fd, req.coord_x, req.coord_z)
	channel.onlineattach(uid, fd)
	--scene.movesync(uid, req.coord_x, req.coord_z)
end

local function s_logout(uid, req, fd)
	print("logout")
	channel.onlinedetach(uid)
	scene.leave(uid)
end

local function r_movepoint(uid, req, fd)
	scene.movesync(uid, req.src_coord_x, req.src_coord_z)
	local grid = scene.grid(uid)
	req.uid = uid
	channel.multicastmap("a_movepoint", req, grid)
end

local function r_movesync(uid, req, fd)
	scene.movesync(uid, req.coord_x, req.coord_z)
	print("movesync")
end


channel.regserver("s_login", s_login)
channel.regserver("s_logout", s_logout)
channel.regclient("r_movepoint", r_movepoint)
--channel.regclient("r_movedir", r_movedir)
--channel.regclient("r_movestop", r_movestop)
channel.regclient("r_movesync", r_movesync)

