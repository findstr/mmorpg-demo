local const = require "const"
local db = require "db"
local aoi = require "aoi"
local channel = require "channel"
local scene = require "scene"

local M = {}




















channel.regclient("r_movepoint", r_movepoint)
channel.regclient("r_movesync", r_movesync)
-------------------logic

function M.login(uid, req)
	local role = db.roleget(uid)
	if not role then
		return
	end
	channel.senduid(uid, "a_startgame", req)
	local x, z = req.coord_x, req.coord_z
	print("start game", uid, x, z)
	aoi.leave(uid)
	aoi.enter(uid, x, z, enter_buffer)
	a_movediff.enter = fillinfo(enter_buffer)
	a_movediff.leave = nil
	channel.senduid(uid, "a_movediff", a_movediff)
	notifyenter(uid, role, x, z, enter_buffer)
	assert(#enter_buffer == 0)
end


return M
