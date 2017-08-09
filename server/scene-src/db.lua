local core = require "silly.core"
local env = require "silly.env"
local zproto = require "zproto"
local xml = require "XML"
local property = require "protocol.property"
local redis = require "redis"
local format = string.format
local tunpack = table.unpack

local M = {}

local dbproto = zproto:parse [[
	idcount {
		.id:integer 1
		.count:integer 2
	}
	role_basic {
		.uid:integer 1
		.name:string 2
		.exp:integer 3
		.level:integer 4
		.gold:integer 5
		.hp:integer 6
		.mp:integer 7
	}
	role_prop {
		.atk:integer 1
		.def:integer 2
		.matk:integer 3
		.mdef:integer 4
	}
	role_bag {
		.bag:idcount[id] 1
	}

	role_skill {
		skill {
			.skillid:integer 1
		}
		.skills:skill[skillid] 1
	}
]]

local dbinst

local proto_role_basic = "role_basic"
local proto_role_bag = "role_bag"
local proto_role_prop = "role_prop"
local proto_role_skill = "role_skill"

local dbk_role = "role:%s"
local dbk_role_basic = "basic"
local dbk_role_bag = "bag"
local dbk_role_prop = "prop"
local dbk_role_skill = "skill"

local DIRTY_BASIC = 0x01
local DIRTY_BAG = 0x02
local DIRTY_PROP = 0x04
local DIRTY_SKILL = 0x08
local DIRTY_LAND = 0x10
local DIRTY_ALL = DIRTY_BASIC | DIRTY_BAG | DIRTY_PROP | DIRTY_SKILL

local rolecache = {}
local roledirtycount = 0
local roledirty = {}

local part_proto = {
	[dbk_role_basic] = proto_role_basic,
	[dbk_role_bag] = proto_role_bag,
	[dbk_role_prop] = proto_role_prop,
	[dbk_role_skill] = proto_role_skill,
}
local part_flag = {
	[dbk_role_basic] = DIRTY_BASIC,
	[dbk_role_bag] = DIRTY_BAG,
	[dbk_role_prop] = DIRTY_PROP,
	[dbk_role_skill] = DIRTY_SKILL,
}

function M.rolecreate(uid, name)
	local level = assert(xml.getkey("RoleLevel.xml", 1), "RoleLevel.xml")
	local create = assert(xml.get("RoleCreate.xml"), "RoleCreate.xml")
	local bag = {}
	local skills = {}
	for _, v in pairs(create.bag.value_list) do
		bag[v.id] = {
			id = v.id,
			count = v.count
		}
	end
	for _, v in pairs(create.skill.value_list) do
		skills[v.count] = {
			skillid = v.count,
		}
	end
	local role = {
		--basic
		uid = uid,
		name = name,
		exp = assert(create.exp.value[1]),
		level = 1,
		gold = assert(create.gold.value[1]),
		hp = assert(level.hp),
		mp = assert(level.mp),
		--prop
		atk = level.atk,
		def = level.def,
		matk = level.matk,
		mdef = level.mdef,
		--skills
		skills = skills,
		--bag
		bag = bag,
		--memory
		coord_x = false,
		coord_z = false,

	}
	rolecache[uid] = role
	roledirty[uid] = DIRTY_ALL
	print("db.rolecreate")
	return role
end

local function merge(dst, src)
	for k, v in pairs(src) do
		dst[k] = v
	end
end
local cmdbuffer = {}
function M.roleload(uid)
	local role = rolecache[uid]
	if role then
		local dirty = roledirty[uid]
		if dirty then
			roledirty[uid] = dirty & (~DIRTY_LAND)
		end
		return role
	end
	local k = format(dbk_role, uid)
	local ok, dat = dbinst:hgetall(k)
	if not ok or #dat == 0 then
		return
	end
	rolecache[uid] = dat
	for i = 1, #dat, 2 do
		local j = i + 1
		local k = dat[i]
		local v = dat[j]
		dat[i] = nil
		dat[j] = nil
		local protok = part_proto[k]
		local info = dbproto:decode(protok, v)
		merge(dat, info)
	end
	return dat
end

function M.roleget(uid)
	return rolecache[uid]
end

local function roleupdate(uid, role, dirty)
	local t = format(dbk_role, uid)
	local cmd = {
		"hmset",
		t,
	}
	local i = 2
	print("roleupdate", k, dirty)
	for k, flag in pairs(part_flag) do
		if (dirty & flag) ~= 0 then
			i = i + 1
			cmd[i] = k
			i = i + 1
			cmd[i] = dbproto:encode(part_proto[k], role)
			print("roleupdate", t, k)
		end
	end
	if i == 0 then
		return
	end
	return cmd
end

function M.roleland(uid)
	local role = rolecache[uid]
	if not role then
		return
	end
	local dirty = roledirty[uid]
	if not dirty then
		rolecache[uid] = nil
		return
	end
	if dirty == 0 then
		rolecache[uid] = nil
		roledirty[uid] = nil
		return
	end
	roledirty[uid] = dirty | DIRTY_LAND
end

local function writedb()
	roledirtycount = 0
	local i = 0
	for uid, dirty in pairs(roledirty) do
		local role = rolecache[uid]
		roledirty[uid] = nil
		local cmd = roleupdate(uid, role, dirty)
		if cmd then
			i = i + 1
			cmdbuffer[i] = cmd
		end
		if (dirty & DIRTY_LAND) ~= 0 then
			roledirty[uid] = nil
		end
	end
	if i ~= 0 then
		dbinst:pipeline(cmdbuffer)
		for j = 1, i do
			cmdbuffer[j] = nil
		end
	end
end

local function try_getf(dbk)
	return function(uid)
		local role = rolecache[uid]
		if not role then
			return nil
		end
		return role[dbk]
	end
end

local function try_get()
	return function(uid)
		return rolecache[uid]
	end
end


local function role_dirty(flag)
	return function(uid)
		local origin = roledirty[uid]
		if not origin then
			roledirty[uid] = flag
		else
			roledirty[uid] = origin | flag
		end
		roledirtycount = roledirtycount + 1
		if roledirtycount > 300 then
			roledirtycount = 0
			core.fork(writedb)
		end
	end
end

M.rolebag = try_getf("bag")
M.roleprop = try_get()
M.roleskill = try_getf("skills")

M.roledirtybasic = role_dirty(DIRTY_BASIC)
M.roledirtybag = role_dirty(DIRTY_BAG)
M.roledirtyprop = role_dirty(DIRTY_PROP)
M.roledirtyskill = role_dirty(DIRTY_SKILL)
local timer_sec = 10000
local function dbtimer()
	local ok, err = core.pcall(writedb)
	if not ok then
		print(err)
	end
	core.timeout(timer_sec, dbtimer)
end

function M.start()
	local err
	dbinst, err = redis:connect {
		addr = env.get("dbport")
	}
	dbinst:select(9)
	dbtimer()
	return dbinst and true or false
end

return M

