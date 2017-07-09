local channel = require "channel"
local xml = require "XML"
local property = require "protocol.property"
local db = require "db"
local errno = require "protocol.errno"

local function r_roleinfo(uid, req, fd)
	print("r_roleinfo", uid)
	local info = db.roleload(uid)
	if not info then
		return channel.errorclient(fd, uid, "a_roleinfo", errno.ROLE_NONEXIST)
	end
	print("r_roleinfo", uid, info.bag)
	return channel.sendclient(fd, uid, "a_roleinfo", info)
end

local function r_rolecreate(uid, req, fd)
	print("r_rolecreate", uid, req.name)
	local info = db.roleload(uid)
	if info then
		return channel.sendclient(fd, uid, "a_rolecreate", info)
	end
	info = db.rolecreate(uid, req.name)
	print("realy create", info)
	return channel.sendclient(fd, uid, "a_rolecreate", info)
end

local a_itemuse = {
	hp = false,
}
local function r_itemuse(uid, req, fd)
	local id = req.id
	local count = req.count
	local info = db.roleload(uid)
	for k, v in pairs(info.bag) do
		print('itemuse bag', k, v)
	end
	local item = info.bag[id]
	print("itemuse", id, item)
	if not item or item.count < count then
		return channel.errorclient(fd, uid, "a_itemuse", errno.ROLE_NOITEM)
	end
	local x = xml.getkey("ItemUse.xml", id)
	print("r_itemuse", uid, id, count)
	item.count = item.count - count;
	local prop = info.prop
	for k, v in pairs(x.Prop) do
		prop[k].count = prop[k].count + v
	end
	db.roleupdate(uid)
	a_itemuse.hp = assert(prop[property.HP].count)
	return channel.sendclient(fd, uid, "a_itemuse", a_itemuse)
end

channel.regclient("r_roleinfo", r_roleinfo)
channel.regclient("r_rolecreate", r_rolecreate)
channel.regclient("r_itemuse", r_itemuse)

