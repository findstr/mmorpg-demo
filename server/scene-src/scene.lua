local const = require "const"
local db = require "db"
local aoi = require "aoi"
local channel = require "channel"
local npc

local M = {}


local a_moveenter = {
	uid = false,
	name = false,
	hp = false,
	coord_x = false,
	coord_z = false,
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
	if uid < const.UIDSTART then
		local r = npc.get(uid)
		return {
			uid = uid,
			coord_x = r.coord_x,
			coord_z = r.coord_z,
			hp = r.hp,
		}
	else
		local r = db.roleget(uid)
		assert(r, uid)
		return {
			uid = uid,
			coord_x = r.coord_x,
			coord_z = r.coord_z,
			name = r.name,
			hp = r.hp,
		}
	end
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
end

local function notifyenter(uid, role, coord_x, coord_z, enter)
	fill_a_moveenter(uid, role)
	return channel.multicastarrclr("a_moveenter", a_moveenter, enter)
end

local function role_movesync(uid, coord_x, coord_z)
	local role = db.roleload(uid)
	if coord_x < 0 then
		coord_x = 0.0
	end
	if coord_z < 0 then
		coord_z = 0.0
	end
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
	notifyenter(uid, role, coord_x, coord_z, enter_buffer)
	assert(#enter_buffer == 0)
	assert(#leave_buffer == 0)
end

local function r_movepoint(uid, req, fd)
	--print("r_movepoint", uid, req.src_coord_x, req.src_coord_z)
	role_movesync(uid, req.src_coord_x, req.src_coord_z)
	local watch = aoi.filter(uid)
	req.uid = uid
	return channel.multicastmap("a_movepoint", req, watch)
end


local function r_movesync(uid, req, fd)
	--print("r_movesync", uid, req.coord_x, req.coord_z)
	role_movesync(uid, req.coord_x, req.coord_z)
end

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

function M.enter(uid, coordx, coordz, mode, radius, ud)
	print("scene.enter", uid)
	aoi.enter(uid, coordx, coordz, enter_buffer)
	assert(uid < const.UIDSTART)
	local info = fillinfoone(uid)
	local watch = aoi.filter(uid)
	fill_a_moveenter(uid, info)
	channel.multicastarr("a_moveenter", a_moveenter, enter_buffer)
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

function M.multicast(uid, cmd, req)
	local watch = aoi.filter(uid)
	return channel.multicastmap("a_attack", req, watch)
end

channel.regclient("r_movepoint", r_movepoint)
channel.regclient("r_movesync", r_movesync)

function M.start(n)
	npc = n
end

return M

