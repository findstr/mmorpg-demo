local core = require "silly.core"
local const = require "const"
local db = require "db"
local aoi = require "aoi"
local channel = require "channel"
local npcmgr = require "npcmgr"

local M = {}

local a_movediff = {
	enter = false,
	leave = false,
}

local enter_buffer = {}
local leave_buffer = {}

local function fillinfo(enter)
	local add = {}
	for i = 1, #enter do
		local uid = enter[i]
		local r
		if (uid >= const.UIDSTART) then
			r = db.roleget(uid)
		else
			r = npcmgr.get(uid)
		end
		add[i] = r
	end
	return add
end

local function notifyenter(uid, role, enter)
	fill_a_moveenter(uid, role)
end

local function role_movesync(role, coord_x, coord_z, movetime)
	local uid = role.uid
	if coord_x < 0 then
		coord_x = 0.0
	end
	if coord_z < 0 then
		coord_z = 0.0
	end
	print("***role_movesync", coord_x, coord_z, movetime)
	role.coord_x = coord_x
	role.coord_z = coord_z
	role.movetime = movetime
	local move = aoi.move(uid, coord_x, coord_z, enter_buffer, leave_buffer)
	if not move then
		return
	end
	--notify myself
	a_movediff.enter = fillinfo(enter_buffer)
	a_movediff.leave = leave_buffer
	channel.senduid(uid, "a_movediff", a_movediff)
	--notify leave
	channel.multicastarrclr("a_moveleave", role,  leave_buffer)
	--notify enter
	channel.multicastarrclr("a_moveenter", role, enter_buffer)
	assert(#enter_buffer == 0)
	assert(#leave_buffer == 0)
end

local function r_movepoint(uid, req, fd)
	--print("r_movepoint", uid, req.src_coord_x, req.src_coord_z)
	local role = db.roleload(uid)
	role_movesync(role, req.coord_x, req.coord_z, req.movetime)
	role.moveto_x = req.moveto_x
	role.moveto_z = req.moveto_z
	local watch = aoi.filter(uid)
	req.uid = uid
	return channel.multicastmap("a_movepoint", req, watch)
end


local function r_movesync(uid, req, fd)
	print("******************r_movesync", uid, req.coord_x, req.coord_z)
	local role = db.roleload(uid)
	role_movesync(role, req.coord_x, req.coord_z, req.movetime)
end

function M.login(uid, req)
	local role = db.roleget(uid)
	if not role then
		return
	end
	local clock= core.monotonic()
	req.clock = clock
	channel.senduid(uid, "a_startgame", req)
	local x, z = req.coord_x, req.coord_z
	print("start game", uid, x, z)
	role.coord_x = x
	role.coord_z = z
	role.moveto_x = x
	role.moveto_z = z
	role.movetime = clock
	aoi.leave(uid)
	aoi.enter(uid, x, z, enter_buffer)
	a_movediff.enter = fillinfo(enter_buffer)
	a_movediff.leave = nil
	channel.senduid(uid, "a_movediff", a_movediff)
	channel.multicastarrclr("a_moveenter", role, enter_buffer)
	assert(#enter_buffer == 0)
end

function M.leave(uid)
	local role = db.roleget(uid)
	if not role then
		return
	end
	local watch = aoi.filter(uid)
	if not watch then
		return
	end
	channel.multicastmap("a_moveleave", role,  watch)
	aoi.leave(uid)
end
channel.regclient("r_movepoint", r_movepoint)
channel.regclient("r_movesync", r_movesync)

return M

