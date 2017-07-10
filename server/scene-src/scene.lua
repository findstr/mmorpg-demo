local db = require "db"
local property = require "protocol.property"
local channel = require "channel"

local M = {}

--GRID = RESOLUTION * CELL
local regionx
local regionz

local GRID = 100
local XPOWER = 100
local EMPTY = {}
local DEFAULT_MOVEPOINT = {
	dst_coord_x = 0,
	dst_coord_z = 0,
}

local scenegrid = {}
local playergrid = {}
local playercoordx = {}
local playercoordz = {}

local function around(uid, gi, func)
	local z = gi % XPOWER
	local x = gi - z
	for i = x - XPOWER, x + XPOWER, XPOWER do
		for j  = z - 1, z + 1 do
			local idx = i + j
			func(idx, uid)
		end
	end
end

local function unsubscribe(gi, uid)
	local g = scenegrid[gi]
	if not g then
		return
	end
	g.subscribe[uid] = nil
end

local function subscribe(gi, uid)
	local g = scenegrid[gi]
	if not g then
		return
	end
	g.subscribe[uid] = uid
end

local function sceneleave(uid)
	local gi = playergrid[uid]
	if not gi then
		return
	end
	around(uid, gi, unsubscribe)
	local g = scenegrid[gi]
	g.home[uid] = nil
	playergrid[uid] = nil
end

M.leave = sceneleave

local move_buffer = {}
--1 -> origin, 2 --> new 3 -> same
local function markorigin(idx, uid)
	print("markorigin", idx)
	if move_buffer[idx] then
		assert(move_buffer[idx] == 2)
		move_buffer[idx] = 3
		return
	end
	local g = scenegrid[idx]
	if g then
		move_buffer[idx] = 1
		g.subscribe[uid] = nil
	end
end
local function marknew(idx, uid)
	print("marknew", idx)
	local g = scenegrid[idx]
	if g then
		move_buffer[idx] = 2
		g.subscribe[uid] = true
	end
end

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

local visible_array = {}
local invasible_array = {}
function M.movesync(uid, coord_x, coord_z)
	playercoordx[uid] = coord_x
	playercoordz[uid] = coord_z
	local x = coord_x // GRID
	local z = coord_z // GRID
	local ngi = x * XPOWER + z
	local gi = playergrid[uid]
	if gi then
		if gi == ngi then
			return
		end
		around(uid, gi, markorigin)
		print("gi", gi)
		print("gi lo", scenegrid[gi])
		print("gi home", scenegrid[gi].home)
		print("scenegrid:", scenegrid[gi], scenegrid[gi].home, uid)
		scenegrid[gi].home[uid] = nil
	end
	around(uid, ngi, marknew)
	local g = scenegrid[ngi]
	assert(g, ngi)
	g.home[uid] = true
	playergrid[uid] = ngi
	--multicast
	local add = {}
	local invasible_array = {}
	for k, v in pairs(move_buffer) do
		if v == 1 then
			local home = scenegrid[k].home
			for uid, _ in pairs(home) do
				invasible_array[#add + 1] = uid
			end
		elseif v == 2 then
			local home = scenegrid[k].home
			for uid, _ in pairs(home) do
				local r = db.rolebasic(uid)
				print("basic:", r)
				local idx = playergrid[uid]
				local x = playercoordx[uid]
				local z = playercoordz[uid]
				add[#add + 1] = {
					uid = uid,
					coord_x = x,
					coord_z = z,
					name = r.name,
					hp = r.hp,
				}
				visible_array[#visible_array + 1] = uid
			end
		end
		move_buffer[k] = nil
	end
	--notify main role
	a_movediff.enter = add
	a_movediff.leave = invasible_array
	channel.senduid(uid, "a_movediff", a_movediff)
	--notify invasible person
	if #invasible_array > 0 then
		a_moveleave.uid = uid
		channel.multicastarrclr("a_moveleave", a_moveleave, invasible_array)
	end
	--notify vasible person addition
	local r = db.rolebasic(uid)
	a_moveenter.uid = uid
	a_moveenter.name = r.name
	a_moveenter.hp = r.hp
	a_moveenter.coord_x = coord_x
	a_moveenter.coord_z = coord_z
	return channel.multicastarrclr("a_moveenter", a_moveenter, visible_array)
end

function M.grid(uid)
	local gi = playergrid[uid]
	local g = scenegrid[gi]
	if not g then
		return nil
	end
	return g.subscribe
end

function M.start(region_x, region_z)
	regionx = region_x / GRID
	regionz = region_z / GRID
	for i = 0, regionx do
		for j = 0, regionz do
			scenegrid[i * XPOWER + j] = {
				home = {},
				subscribe = {}
			}
		end
	end
	print("scene region", regionx, regionz)
end

function M.onlinepatch(list)
	for uid, typ in pairs(list) do
		if typ == "offline" then
			sceneleave(uid)
		end
	end
end

return M

