local M = {}

local regionx
local regionz

--GRID = RESOLUTION * CELL
local GRID = 10
local XPOWER = 1000

--TODO:split tower into threee global table'watch, sense, entity'
local map = {}
local entities = {}

local function clamp(x, radius, region)
	local start = x - radius
	local stop = x + radius
	if start < 0 then
		start = 0
	elseif stop > region then
		stop = region
	end
	return start, stop
end

local MARK_LEAVE = 1
local MARK_ENTER = 2
local MARK_KEEP = 3
local mark_buffer = {}
local function mark(towerx, towerz, radius, markvalue)
	local startx, stopx = clamp(towerx, radius, regionx)
	local startz, stopz = clamp(towerz, radius, regionz)
	for x = startx, stopx do
		local xi = x * XPOWER
		for z = startz, stopz do
			local mi = xi + z
			if not mark_buffer[mi] then
				mark_buffer[mi] = markvalue
			else
				mark_buffer[mi] = MARK_KEEP
			end
		end
	end
end

local function collectentity(mi, tbl)
	local entity = map[mi].entity
	local i = 1
	for id, v in pairs(entity) do
		assert(v == mi)
		tbl[i] = id
		i = i + 1
	end
end

local function senseaction(actid, mi, action)
	local sense = map[mi].sense
	for id, cb in pairs(sense) do
		cb(id, actid, action)
	end
end

function M.move(id, coordx, coordz, enter, leave)
	local p = entities[id]
	local towerx = p.towerx
	local towerz = p.towerz
	local ntowerx = coordx // GRID
	local ntowerz = coordz // GRID
	if ntowerx == towerx and ntowerz == towerz then
		return false
	end
	local ti = towerx * XPOWER + towerz
	local nti = ntowerx * XPOWER + ntowerz
	local mode = p.mode
	local radius = p.radius
	mark(ntowerx, ntowerz, radius, MARK_ENTER)
	mark(towerx, towerz, radius, MARK_LEAVE)
	p.towerx = ntowerx
	p.towerz = ntowerz
	for k, v in pairs(mark_buffer) do
		if v == MARK_LEAVE then
			collectentity(k, leave)
			map[k][mode][id] = nil
			senseaction(id, k, "leave")
		elseif v == MARK_ENTER then
			collectentity(k, enter)
			map[k][mode][id] = true
			senseaction(id, k, "enter")
		elseif v == MARK_KEEP then
			senseaction(id, k, "move")
		end
		mark_buffer[k] = nil
	end
	map[ti].entity[id] = nil
	map[nti].entity[id] = nti
	return true
end

function M.watcher(id)
	local p = entities[id]
	local ti = p.towerx * XPOWER + p.towerz
	return map[ti].watch
end

function M.enter(id, coordx, coordz, mode, radius, ud)
	local towerx = coordx // GRID
	local towerz = coordz // GRID
	ud = ud or true
	assert(towerx <= regionx)
	assert(towerz <= regionz)
	local mi = towerx * XPOWER + towerz
	local p = {
		towerx = coordx,
		towerz = coordz,
		mode = mode,	--'sense, watch'
		radius = radius,
	}
	map[mi].entity[id] = mi
	entities[id] = p
	local startx, stopx = clamp(towerx, radius, regionx)
	local startz, stopz = clamp(towerz, radius, regionz)
	for x = startx, stopx do
		local xi = x * XPOWER
		for z = startz, stopz do
			local mi = xi + z
			local tower = map[mi]
			tower[p.mode][id] = ud
		end
	end
	senseaction(id, mi, "enter")
end


function M.leave(id)
	local p = entities[id]
	if not p then
		return
	end
	entities[id] = nil
	local radius = p.radius
	local towerx = p.towerx
	local towerz = p.towerz
	local ti = towerx * XPOWER + towerz
	local startx, stopx = clamp(towerx, radius, regionx)
	local startz, stopz = clamp(towerz, radius, regionz)
	for x = startx, stopx do
		local xi = x * XPOWER
		for z = startz, stopz do
			local mi = xi + z
			local tower = map[mi]
			tower[p.mode][id] = nil
		end
	end
end

function M.start(x, z)
	regionx = x // GRID
	regionz = z // GRID
	print("[aoi] start regionx, regionz", regionx, regionz)
	for i = 0.0, regionx do
		for j = 0.0, regionz do
			local ti = i * XPOWER + j
			map[ti] = {
				entity = {},
				watch = {},
				sense = {},
			}
		end
	end
end

return M

