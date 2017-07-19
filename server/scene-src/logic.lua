local channel = require "channel"
local db = require "db"
local xml = require "XML"
local const = require "const"
local errno = require "protocol.errno"
local npc = require "npc"
local battle = require "battle"
local scene = require "scene"
local rolep = require "rolep"

local function s_logout(uid, req, fd)
	print("logout start", uid)
	scene.leave(uid)
	channel.onlinedetach(uid)
	db.roleland(uid)
	print("logout stop", uid)
end

local function s_login(uid, req, fd)
	local x = req.coord_x
	local z = req.coord_z
	print("login", uid, fd, x, z)
	channel.onlineattach(uid, fd)
	scene.login(uid, req)
end


local function r_attack(uid, req, fd)
	local target = req.target
	local skillid = req.skillid
	print("r_attack", uid, target, skillid)
	local atk, def
	atk = db.roleget(uid)
	if not atk.skills[skillid] then
		print("[r_attack] error incorrect skillid:", skillid, uid)
		return
	end
	local skill = xml.getkey("Skill.xml", skillid)
	if skill.mp > atk.mp then
		print("[r_attack] need magci", effect.magic, "has magic", magic)
		return
	end
	atk.mp = atk.mp - skill.mp
	if target < const.UIDSTART then
		def = npc.get(target)
	else
		def = db.roleget(target)
	end
	battle.attack(atk, def, skill)
	req.attacker = uid
	req.targethp = def.hp
	scene.multicast(uid, "a_attack", req)
	if def.hp > 0 then
		return
	end
	if target < const.UIDSTART then
		npc.kill(target)
		local atk_level = atk.level
		local exp = atk.exp + def.exp
		local lv = atk_level + 1
		local x = xml.getkey("RoleLevel.xml", lv)
		print("kill", exp, x.exp)
		if exp > x.exp then
			exp = exp - x.exp
			atk.level = atk_level + 1
		end
		local exp_add = exp - atk.exp
		atk.exp = exp
		db.roledirtybasic(uid)
		rolep.rolepoint(uid, nil, exp_add)
	end
end

channel.regserver("s_login", s_login)
channel.regserver("s_logout", s_logout)
channel.regclient("r_attack", r_attack)

