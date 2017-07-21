local M = {}

local regionx
local regionz

--GRID = RESOLUTION * CELL
local GRID = 1
local XPOWER = 1000

local map = {}
local tower_watch = {}
local tower_sense = {}
local tower_entity = {}
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
local MARK_KEEP = nil
local mark_buffer = {}
local function mark(towerx, towerz, radius, markvalue)
	local startx, stopx = clamp(towerx, radius, regionx)
	local startz, stopz = clamp(towerz, radius, regionz)
	for x = startx, stopx do
		local xi = x * XPOWER
		for z = startz, stopz do
			local ti = xi + z
			if not mark_buffer[ti] then
				mark_buffer[ti] = markvalue
			else
				mark_buffer[ti] = MARK_KEEP
			end
		end
	end
end

local function collectentity(ti, tbl)
	local entity = assert(tower_entity[ti], ti)
	for id, v in pairs(entity) do
		assert(v == ti)
		tbl[#tbl + 1] = id
	end
end

local function senseaction(actid, ti, action)
	local sense = tower_sense[ti]
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
	assert(#enter == 0)
	assert(#leave == 0)
	local ti = towerx * XPOWER + towerz
	local nti = ntowerx * XPOWER + ntowerz
	local mode = p.mode
	local radius = p.radius
	mark(ntowerx, ntowerz, radius, MARK_ENTER)
	mark(towerx, towerz, radius, MARK_LEAVE)
	p.towerx = ntowerx
	p.towerz = ntowerz
	local monitor = mode == "watch" and tower_watch or tower_sense
	for k, v in pairs(mark_buffer) do
		if v == MARK_LEAVE then
			collectentity(k, leave)
			monitor[k][id] = nil
			senseaction(id, k, "leave")
		elseif v == MARK_ENTER then
			collectentity(k, enter)
			monitor[k][id] = true
			senseaction(id, k, "enter")
		else
			--senseaction(id, k, "move")
		end
		mark_buffer[k] = nil
	end
	tower_entity[ti][id] = nil
	tower_entity[nti][id] = nti
	return true
end

function M.around(id, enter)
	local p = entities[id]
	if not p then
		return
	end
	local towerx = p.towerx
	local towerz = p.towerz
	local radius = p.radius
	local startx, stopx = clamp(towerx, radius, regionx)
	local startz, stopz = clamp(towerz, radius, regionz)
	for x = startx, stopx do
		local xi = x * XPOWER
		for z = startz, stopz do
			local ti = xi + z
			collectentity(ti, enter)
		end
	end
end
local EMPTY = {}
function M.watcher(id)
	local p = entities[id]
	if not p then
		return EMPTY
	end
	local ti = p.towerx * XPOWER + p.towerz
	return tower_watch[ti]
end

function M.enter(id, coordx, coordz, mode, radius, ud)
	local towerx = coordx // GRID
	local towerz = coordz // GRID
	ud = ud or true
	assert(towerx <= regionx)
	assert(towerz <= regionz)
	local ti = towerx * XPOWER + towerz
	local p = {
		towerx = towerx,
		towerz = towerz,
		mode = mode,	--'sense, watch'
		radius = radius,
	}
	tower_entity[ti][id] = ti
	assert(not entities[id], id)
	entities[id] = p
	local startx, stopx = clamp(towerx, radius, regionx)
	local startz, stopz = clamp(towerz, radius, regionz)
	local monitor = mode == "watch" and tower_watch or tower_sense
	for x = startx, stopx do
		local xi = x * XPOWER
		for z = startz, stopz do
			local ti = xi + z
			monitor[ti][id] = ud
		end
	end
	senseaction(id, ti, "enter")
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
	tower_entity[ti][id] = nil
	local startx, stopx = clamp(towerx, radius, regionx)
	local startz, stopz = clamp(towerz, radius, regionz)
	local monitor = p.mode == "watch" and tower_watch or tower_sense
	for x = startx, stopx do
		local xi = x * XPOWER
		for z = startz, stopz do
			local ti = xi + z
			monitor[ti][id] = nil
		end
	end
	senseaction(id, ti, "enter")
end

function M.start(x, z)
	regionx = x // GRID
	regionz = z // GRID
	print("[aoi] start regionx, regionz", regionx, regionz)
	for i = 0.0, regionx do
		for j = 0.0, regionz do
			local ti = i * XPOWER + j
			tower_watch[ti] = {}
			tower_sense[ti] = {}
			tower_entity[ti] = {}
		end
	end
end

return M

