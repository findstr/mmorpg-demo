local core = require "silly.core"
local const = require "const"
local db = require "db"
local aoi = require "aoi"
local channel = require "channel"

local M = {}


local a_moveenter = {
	uid = false,
	name = false,
	hp = false,
	coord_x = false,
	coord_z = false,
	moveto_x = false,
	moveto_z = false,
	movetime = false,
}

local a_moveleave = {
	uid = false,
}

local a_movediff = {
	enter = false,
	leave = false,
}

local enter_buffer = {}
local leave_buffer = {}

local function fillinfoone(uid)
	local r = db.roleget(uid)
	assert(r, uid)
	return {
		uid = uid,
		name = r.name,
		hp = r.hp,
		coord_x = r.coord_x,
		coord_z = r.coord_z,
		moveto_x = r.moveto_x,
		moveto_z = r.moveto_z,
		movetime = r.movetime,
	}
end

local function fillinfo(enter)
	local add = {}
	for i = 1, #enter do
		local uid = enter[i]
		--print("enter", uid)
		add[i] = fillinfoone(uid)
	end
	return add
end

local function fill_a_moveenter(uid, role)
	a_moveenter.uid = uid
	a_moveenter.name = role.name
	a_moveenter.hp = role.hp
	a_moveenter.coord_x = role.coord_x
	a_moveenter.coord_z = role.coord_z
	a_moveenter.moveto_x = role.moveto_x
	a_moveenter.moveto_z = role.moveto_z
	a_moveenter.movetime = role.movetime
	return a_moveenter
end

local function notifyenter(uid, role, enter)
	fill_a_moveenter(uid, role)
	return channel.multicastarrclr("a_moveenter", a_moveenter, enter)
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
	a_moveleave.uid = uid
	channel.multicastarrclr("a_moveleave", a_moveleave,  leave_buffer)
	--notify enter
	notifyenter(uid, role, enter_buffer)
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
	role.coord_x = x
	role.coord_z = z
	role.moveto_x = x
	role.moveto_z = z
	role.movetime = clock
	aoi.leave(uid)
	print("start game", uid, role.coord_x, role.coord_z)
	aoi.enter(uid, x, z, enter_buffer)
	a_movediff.enter = fillinfo(enter_buffer)
	a_movediff.leave = nil
	channel.senduid(uid, "a_movediff", a_movediff)
	notifyenter(uid, role, enter_buffer)
	assert(#enter_buffer == 0)
end

function M.npcwatch(func)
	aoi.npcwatch(func)
end

function M.npcenter(uid, coordx, coordz)
	print("scene.enter", uid)
	assert(uid < const.UIDSTART)
	aoi.npcenter(uid, coordx, coordz, enter_buffer)
	fill_a_moveenter(uid, db.roleget(uid))
	channel.multicastarrclr("a_moveenter", a_moveenter, enter_buffer)
end

function M.npcmove(uid, coordx, coordz)
	local move = aoi.npcmove(uid, coordx, coordz, enter_buffer, leave_buffer)
	if not move then
		return
	end
	--notify leave
	a_moveleave.uid = uid
	channel.multicastarrclr("a_moveleave", a_moveleave,  leave_buffer)
	--notify enter
	fill_a_moveenter(uid, db.roleget(uid))
	channel.multicastarrclr("a_moveenter", a_moveenter, enter_buffer)
	assert(#leave_buffer == 0)
	assert(#enter_buffer == 0)
end


function M.leave(uid)
	a_moveleave.uid = uid
	local watch = aoi.filter(uid)
	if not watch then
		return
	end
	channel.multicastmap("a_moveleave", a_moveleave,  watch)
	aoi.leave(uid)
end

M.npcleave = M.leave

function M.multicast(uid, cmd, req)
	local watch = aoi.filter(uid)
	return channel.multicastmap("a_attack", req, watch)
end

channel.regclient("r_movepoint", r_movepoint)
channel.regclient("r_movesync", r_movesync)

return M

