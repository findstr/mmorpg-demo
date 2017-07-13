local channel = require "channel"
local db = require "db"
local xml = require "XML"
local const = require "const"
local errno = require "protocol.errno"
local aoi = require "aoi"
local npc = require "npc"

local function s_login(uid, req, fd)
	local x = req.coord_x
	local z = req.coord_z
	print("login", uid, fd, x, z)
	channel.onlineattach(uid, fd)
	local role = db.roleload(uid)
	if not role then
		return
	end
	role.basic.coord_x = x
	role.basic.coord_z = z
end

local function s_logout(uid, req, fd)
	print("logout")
	aoi.leave(uid)
	channel.onlinedetach(uid)
	db.roleland(uid)
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

local enter = {}
local leave = {}

local function fillinfo(enter)
	local add = {}
	for i = 1, #enter do
		local uid = enter[i]
		--print("enter", uid)
		if uid < const.UIDSTART then
			local r = npc.info(uid)
			add[i] = {
				uid = uid,
				coord_x = r.coord_x,
				coord_z = r.coord_z,
				hp = r.hp,
			}
		else
			local r = db.rolebasic(uid)
			add[i] = {
				uid = uid,
				coord_x = r.coord_x,
				coord_z = r.coord_z,
				name = r.name,
				hp = r.hp,
			}
		end
	end
	return add
end

local function notifyenter(uid, base, coord_x, coord_z, enter)
	a_moveenter.uid = uid
	a_moveenter.name = base.name
	a_moveenter.hp = base.hp
	a_moveenter.coord_x = coord_x
	a_moveenter.coord_z = coord_z
	return channel.multicastarrclr("a_moveenter", a_moveenter, enter)
end

local function r_startgame(uid, req, fd)
	--print("start game", uid)
	local role = db.roleget(uid)
	local basic = role.basic
	local x = basic.coord_x or 1.0
	local z = basic.coord_z or 1.0
	aoi.enter(uid, x, z, "watch", 1)
	aoi.around(uid, enter)
	a_movediff.enter = fillinfo(enter)
	a_movediff.leave = nil
	channel.senduid(uid, "a_movediff", a_movediff)
	notifyenter(uid, basic, x, z, enter)
	assert(#enter == 0)
end

local function role_movesync(uid, coord_x, coord_z)
	local role = db.roleload(uid)
	if coord_x < 0 then
		coord_x = 0.0
	end
	if coord_z < 0 then
		coord_z = 0.0
	end
	local move = aoi.move(uid, coord_x, coord_z, enter, leave)
	if not move then
		return
	end
	--notify myself
	a_movediff.enter = fillinfo(enter)
	a_movediff.leave = leave
	channel.senduid(uid, "a_movediff", a_movediff)
	--notify leave
	a_moveleave.uid = uid
	channel.multicastarrclr("a_moveleave", a_moveleave,  leave)
	--notify enter
	notifyenter(uid, role.basic, coord_x, coord_z, enter)
	assert(#enter == 0)
	assert(#leave == 0)
end

local function r_movepoint(uid, req, fd)
	--print("r_movepoint", uid, req.src_coord_x, req.src_coord_z)
	role_movesync(uid, req.src_coord_x, req.src_coord_z)
	local watch = aoi.watcher(uid)
	req.uid = uid
	return channel.multicastmap("a_movepoint", req, watch)
end


local function r_movesync(uid, req, fd)
	--print("r_movesync", uid, req.coord_x, req.coord_z)
	role_movesync(uid, req.coord_x, req.coord_z)
end

local function r_attack(uid, req)
	local target = req.target
	local atk_role = db.roleload(uid)
	local def_role = db.roleload(target)
	--print("r_attack", target, def_role)
	local atk_basic, atk_prop = atk_role.basic, atk_role.prop
	local def_basic, def_prop = def_role.basic, def_role.prop
	local atk_skill = atk_role.skill.active[req.skillid]
	atk_skill = atk_skill.skillid + atk_skill.skilllv
	print("attack skill id", atk_skill)
	local effect = xml.getkey("SkillEffect.xml", atk_skill)
	local magic = effect.magic
	if magic > atk_basic.magic then
		print("need magci", effect.magic, "has magic", magic)
		return
	end
	if magic > 0 then
		atk_basic.magic = atk_basic.magic - magic
		db.roledirtybasic(uid)
	end
	local atk_val = atk_prop[effect.atkp] * effect.atkv // const.PERCENT100
	local def_val = def_prop[effect.defp]
	atk_val = atk_val - def_val
	local hpsub = def_basic.hp
	if atk_val > 0 then
		hpsub = hpsub - atk_val
		if hpsub < 0 then
			--TODO:rebirth
			hpsub = 0
		end
		def_basic.hp = hpsub
		db.roledirtybasic(uid)
	end
	print("target hp", atk_val, hpsub)
	req.attacker = uid
	req.targethp = hpsub
	return scene.publish(uid, "a_attack", req)
end

channel.regserver("s_login", s_login)
channel.regserver("s_logout", s_logout)
channel.regclient("r_startgame", r_startgame)
channel.regclient("r_movepoint", r_movepoint)
channel.regclient("r_movesync", r_movesync)
channel.regclient("r_attack", r_attack)

