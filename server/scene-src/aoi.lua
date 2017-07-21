local c = require "aoi.c"
local M = {}
local AOI
local USER_X = {}
local USER_Z = {}
local USER_FILTER = {}

local function update_user(id, x, z, enter, leave)
	local e, l = c.update(AOI, id, x, z, enter, leave);
	for i = 1, e do
		local x = enter[i]
		USER_FILTER[x][id] = true
		USER_FILTER[id][x] = true
	end
	for i = 1, l do
		local x = leave[i]
		USER_FILTER[x][id] = nil
		USER_FILTER[id][x] = nil
	end
	return e > 0 or l > 0
end

function M.start(x, z)
	AOI = c.start(x, z)
end

function M.enter(id, x, z, enter)
	USER_X[id] = x
	USER_Z[id] = z
	USER_FILTER[id] = {}
	--because first enter can't be leave
	--so pass nil of 'leave' param is harmless
	update_user(id, x, z, enter)
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

M.move = update_user

return M

