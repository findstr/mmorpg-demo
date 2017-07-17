local core = require "silly.core"
local env = require "silly.env"
local zproto = require "zproto"
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
		.magic:integer 7
	}
	role_bag {
		.list:idcount[id] 1
	}
	role_prop {
		.atk:integer 1
		.def:integer 2
		.matk:integer 3
		.mdef:integer 4
	}
	role_skill {
		skill {
			.skillid:integer 1
			.skilllv:integer 2
		}
		.active:skill[skillid] 2
		.passive:skill[skillid] 3
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
	local basic = {
		uid = uid,
		name = name,
		exp = 0,
		level = 0,
		gold = 100,
		hp = 90,
		magic = 100,
		coord_x = 10,
		coord_z = 10,
	}
	local bag = {
		list = {
			[10000] = {
				id = 10000,
				count = 100
			},
			[10001] = {
				id = 10001,
				count = 101,
			}
		}
	}
	local prop = {
		atk = 99,
		def = 98,
		matk = 89,
		mdef = 88,
	}
	local skill = {
		active = {
			[10000000] = {
				skillid = 10000000,
				skilllv = 1,
			},
			[10001000] = {
				skillid = 10001000,
				skilllv = 1,
			},
		}
	}
	role = {
		basic = basic,
		bag = bag,
		prop = prop,
		skill = skill,
	}
	rolecache[uid] = role
	roledirty[uid] = DIRTY_ALL
	print("db.rolecreate")
	return role
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
		dat[k] = info
	end
	return dat
end

function M.roleget(uid)
	return rolecache[uid]
end

local function roleupdate(uid, role, dirty)
	local count = 0
	local k = format(dbk_role, uid)
	print("roleupdate", dirty)
	for k, flag in pairs(part_flag) do
		if (dirty & flag) ~= 0 then
			count = count + 1
			cmdbuffer[count] = k
			count = count + 1
			print("roleupdate", uid, k)
			cmdbuffer[count] = dbproto:encode(part_proto[k], role[k])
		end
	end
	if count == 0 then
		return
	end
	local ok, err = dbinst:hmset(k, tunpack(cmdbuffer, 1, count))
	for i = 1, count do
		cmdbuffer[i] = nil
	end
	if not ok then
		print("roleupdate", err)
	end
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
	for uid, dirty in pairs(roledirty) do
		local role = rolecache[uid]
		roledirty[uid] = nil
		print("roleupdate dirty", dirty)
		roleupdate(uid, role, dirty)
		if (dirty & DIRTY_LAND) ~= 0 then
			roledirty[uid] = nil
		end
	end
end

local function try_get(dbk)
	return function(uid)
		local role = rolecache[uid]
		if not role then
			return nil
		end
		return role[dbk]
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

M.rolebasic = try_get(dbk_role_basic)
M.rolebag = try_get(dbk_role_bag)
M.roleprop = try_get(dbk_role_prop)
M.roleskill = try_get(dbk_role_skill)
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

