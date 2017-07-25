local core = require "silly.core"
local xml = require "XML"
local db = require "db"
local aoi = require "aoi"
local aux = require "aux.c"
local channel = require "channel"

local M = {}
local mt = {__index = M}

local EQ = aux.eq
local NEQ = aux.neq
local FOLLOW = aux.follow

local enter_buffer = {}
local leave_buffer = {}

--------------------------------protocol

local function npc_move(self, x, z)
	local move = aoi.move(self.uid, x, z, enter_buffer, leave_buffer)
	if not move then
		return
	end
	--notify leave/enter
	channel.multicastarrclr("a_moveleave", self,  leave_buffer)
	channel.multicastarrclr("a_moveenter", self, enter_buffer)
	assert(#enter_buffer == 0)
	assert(#leave_buffer == 0)
end

----------think behavior

local function think_follow(self, clock)
	local role = self.follow
	local from_x, from_z = self.coord_x, self.coord_z
	local follow_x, follow_z = self.moveto_x, self.moveto_z
	if NEQ(from_x, follow_x) or NEQ(from_z, follow_z) then
		local x, z = FOLLOW(from_x, from_z, follow_x, follow_z,
				self.speed, clock - self.movetime)
		self.coord_x, self.coord_z = x, z
		self.movetime = clock
		npc_move(self, x, z)
		local r_x, r_z = role.coord_x, role.coord_z
		if NEQ(follow_x, r_x) or NEQ(follow_z, r_z) then
			self.moveto_x = r_x
			self.moveto_z = r_z
			local watch = aoi.filter(self.uid)
			return channel.multicastmap("a_movepoint", self, watch)
		end
	end
end

-----------------------------------logic

function M.create(self, uid, clock, cfg)
	local coord = cfg.coord
	local x = coord[1]
	local z = coord[2]
	local obj = {
		uid = uid,
		type = cfg.type,
		hp = cfg.hp,
		atk = cfg.atk,
		def = cfg.def,
		exp = cfg.exp,
		matk = cfg.matk,
		mdef = cfg.mdef,
		speed = cfg.speed,
		---logic data
		state = "idle",
		think = false,
		follow = false,
		movetime = clock,
		coord_x = x,
		coord_z = z,
		moveto_x = x,
		moveto_z = z,
	}
	setmetatable(obj, mt)
	aoi.npcenter(uid, x, z, enter_buffer)
	channel.multicastarrclr("a_moveenter", obj, enter_buffer)
	return obj
end

function M.killedby(self, uid)
	local nid = self.uid
	local filter = aoi.filter(nid)
	channel.multicastmap("a_moveleave", self, filter)
	aoi.leave(nid)
end

function M.relive(self)
	local nid = self.uid
	local cfg = xml.getkey("NPC.xml", nid)
	local coord = cfg.coord
	local x, z = coord[0], coord[1]
	self.think = false
	self.coord_x = x
	self.coord_z = z
	self.moveto_x = x
	self.moveto_z = z
	self.movetime = core.monotonic()
	aoi.npcenter(self.uid, coord[0], coord[1], enter_buffer)
	channel.multicastarrclr("a_moveenter", self, enter_buffer)
end

function M.visible(self, uid)
	print("visible", self.uid, uid)
	if self.follow then
		return
	end
	--try follow
	local clock = core.monotonic()
	local role = db.roleget(uid)
	self.follow = role
	self.moveto_x = role.coord_x
	self.moveto_z = role.coord_z
	self.movetime = clock
	self.think = think_follow
	local watch = aoi.filter(self.uid)
	return channel.multicastmap("a_movepoint", self, watch)
end

function M.invisible(self, uid)
	print("invisible")
end

return M

