local env = require "silly.env"
local zproto = require "zproto"
local redis = require "redis"

local M = {}

local dbproto = zproto:parse [[
	roleinfo {
		item {
			.id:integer 1
			.count:integer 2
		}
		.uid:integer 1
		.name:string 2
		.level:integer 3
		.bag:item[] 4
	}
]]

local dbinst
local roleinfo_dbkey = "role:info"
local roleinfo_proto = "roleinfo"

local rolecache = {}

function M.roleload(uid)
	local ok, dat = dbinst:hget(roleinfo_dbkey, uid)
	if not ok then
		return
	end
	local info = dbproto:decode(roleinfo_proto, dat)
	assert(info, roleinfo_proto)
	rolecache[uid] = info
	return info
end

function M.roleupdate(uid)
	local info = rolecache[uid]
	if not info then
		return
	end
	local dat = dbproto:encode(roleinfo_proto, info)
	return dbinst:hset(roleinfo_dbkey, uid, dat)
end

function M.roleland(uid)
	M.roleupdate(uid)
	rolecache[uid] = nil
end

function M.rolecreate(uid, name)
	local role = {
		name = name,
		level = 1,
		bag = {},
	}
	rolecache[uid] = role
	M.roleupdate(uid)
	return role
end

function M.start()
	local err
	dbinst, err = redis:connect {
		addr = env.get("dbport")
	}
	return dbinst and true or false
end

return M

