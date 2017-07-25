local c = require "aoi.c"
local const = require "const"
local M = {}
local AOI
local USER_X = {}
local USER_Z = {}
local USER_FILTER = {}
local npc_watch = {}

local function update_user(id, x, z, enter, leave)
	local e, l = c.update(AOI, id, x, z, enter, leave)
	for i = 1, e do
		local x = enter[i]
		if x >= const.UIDSTART then
			USER_FILTER[id][x] = true
			USER_FILTER[x][id] = true
		else
			USER_FILTER[x][id] = true
			npc_watch(x, id, "enter")
		end
	end
	for i = 1, l do
		local x = leave[i]
		if x >= const.UIDSTART then
			USER_FILTER[x][id] = nil
			USER_FILTER[id][x] = nil
		else
			npc_watch(x, id, "leave")
		end
	end
	return e > 0 or l > 0
end

local function update_npc(id, x, z, enter, leave)
	local e, l = c.update(AOI, id, x, z, enter, leave)
	for i = 1, e do
		local x = enter[i]
		if x >= const.UIDSTART then
			USER_FILTER[x][id] = true
			USER_FILTER[id][x] = true
			npc_watch(id, x, "enter")
		end
	end
	for i = 1, l do
		local x = leave[i]
		leave[i] = nil
		if x >= const.UIDSTART then
			USER_FILTER[x][id] = nil
			USER_FILTER[id][x] = nil
			npc_watch(id, x, "leave")
		end
	end
	return e > 0 or l > 0
end

local function enter_by(update)
	return function(id, x, z, enter)
		USER_X[id] = x
		USER_Z[id] = z
		USER_FILTER[id] = {}
		--because first enter can't be leave
		--so pass nil of 'leave' param is harmless
		update(id, x, z, enter)
	end
end

function M.start(x, z)
	AOI = c.start(x, z)
end

function M.leave(id)
	USER_X[id] = nil
	USER_Z[id] = nil
	USER_FILTER[id] = nil
	c.leave(AOI, id)
end

function M.filter(id)
	return USER_FILTER[id]
end

function M.npcwatch(func)
	npc_watch = func
end

M.enter = enter_by(update_user)
M.npcenter = enter_by(update_npc)
M.move = update_user
M.npcmove = update_npc

return M

