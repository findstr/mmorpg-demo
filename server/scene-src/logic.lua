local channel = require "channel"
local db = require "db"
local xml = require "XML"
local const = require "const"
local errno = require "protocol.errno"
local scene = require "scene"

local function s_login(uid, req, fd)
	print("xxlogin", uid, fd, req.coord_x, req.coord_z)
	channel.onlineattach(uid, fd)
end

local function s_logout(uid, req, fd)
	print("logout")
	channel.onlinedetach(uid)
	scene.leave(uid)
end

local function r_attack(uid, req)
	local target = req.target
	local atk_role = db.roleload(uid)
	local def_role = db.roleload(target)
	print("r_attack", target, def_role)
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
channel.regclient("r_attack", r_attack)

