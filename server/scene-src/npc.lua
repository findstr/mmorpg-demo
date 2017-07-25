local core = require "silly.core"
local scene = require "scene"
local xml = require "XML"
local db = require "db"
local aoi = require "aoi"
local channel = require "channel"
local aux = require "aux.c"

local EQ = aux.eq
local NEQ = aux.neq
local FOLLOW = aux.follow

local TIMEOUT = 10 * 1000

local M = {}
local follow = {}
local relive = {}
local following = {}

local a_movepoint = {
	uid = false,
	coord_x = false,
	coord_z = false,
	moveto_x = false,
	moveto_z = false,
	movetime = false,
}

local function try_follow(npc, role)
	local clock = core.monotonic()
	following[npc] = role
	npc.moveto_x = role.coord_x
	npc.moveto_z = role.coord_z
	npc.movetime = clock
	a_movepoint.uid = npc.uid
	a_movepoint.coord_x = npc.coord_x
	a_movepoint.coord_z = npc.coord_z
	a_movepoint.moveto_x = npc.moveto_x
	a_movepoint.moveto_z = npc.moveto_z
	a_movepoint.movetime = clock
	local watch = aoi.filter(npc.uid)
	return channel.multicastmap("a_movepoint", a_movepoint, watch)
end

local function npc_sense(npcid, actid, action)
	if not follow[npcid] then
		return
	end
	if action == "enter" then
		local npc = db.roleget(npcid)
		local role = db.roleget(actid)
		try_follow(npc, role)
	else
		local npc = db.roleget(npcid)
		following[npc] = "back"
	end
	print("npc", npcid, "actid", actid,  action)
end

function M.kill(uid)
	print("[npc] kill", uid)
	scene.npcleave(uid)
	local n = db.npcdel(uid)
	local now = core.monotonic() + TIMEOUT
	relive[now] = n
end

local function relive_timer(now)
	for t, n in pairs(relive) do
		print("[npc] relive now:", now, " relive", t, n)
		if t <= now then
			db.npcadd(n.uid, n)
			scene.npcenter(n.uid, n.coord_x, n.coord_z)
			relive[t] = nil
		end
	end
end

local a_movepoint = {
	src_coord_x = false,
	src_coord_z = false,
	dst_coord_x = false,
	dst_coord_z = false,
	uid = false
}

local function update_follow(npc, role, clock)
	local from_x, from_z = npc.coord_x, npc.coord_z
	local follow_x, follow_z = npc.moveto_x, role.moveto_z
	print('follow update', role.uid, npc.uid, from_x, from_z, follow_x, follow_z)
	if NEQ(from_x, follow_x) or NEQ(from_z, follow_z) then
		print("follow")
		npc.coord_x, npc.coord_z = FOLLOW(from_x, from_z,
			follow_x, follow_z, npc.speed, clock - npc.movetime)
		npc.movetime = clock
		scene.npcmove(npc.uid, npc.coord_x, npc.coord_z)
		if NEQ(follow_x, role.coord_x) or NEQ(follow_z, role.coord_z) then
			try_follow(npc, role)
		end
	else
		print("unfollow")
	end
end


local function follow_timer()
	local abs = math.abs
	local sqrt = math.sqrt
	local clock = core.monotonic()
	for npc, role in pairs(following) do
		if role == "back" then
		else
			update_follow(npc, role, clock)
		end
	end
end

local function timer_1hz()
	local now = core.monotonic()
	local ok, err = core.pcall(relive_timer, now)
	if not ok then
		print(err)
	end
	local ok, err = core.pcall(follow_timer, now)
	if not ok then
		print(err)
	end
	core.timeout(1000, timer_1hz)
end

function M.start()
	local cfg = xml.get("NPC.xml")
	scene.npcwatch(npc_sense)
	local clock = core.monotonic()
	for k, v in pairs(cfg) do
		local coord = v.coord
		local x = coord[1]
		local z = coord[2]
		local t = v.type
		local obj = {
			uid = k,
			type = t,
			hp = v.hp,
			atk = v.atk,
			def = v.def,
			exp = v.exp,
			matk = v.matk,
			mdef = v.mdef,
			coord_x = x,
			coord_z = z,
			moveto_x = x,
			moveto_z = z,
			movetime = clock,
			speed = v.speed
		}
		db.npcadd(k, obj)
		scene.npcenter(k, x, z)
		if t == 2 then
			follow[k] = true
		end
	end
	timer_1hz()
end

return M


