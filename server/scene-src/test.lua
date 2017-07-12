local core
local aoi = require "aoi"
local REGIONX = 1000 * 10
local REGIONZ = 1000 * 10

local index = {}
local entity = {
	--'[id]' = { mode, coordx, coordz }
}

aoi.start(REGIONX, REGIONZ)

local function monstersense(npc, actid, action)
	--print("sense", npc, "actid",  actid, "action", action)
end
--[[
for i = 5, 10 do
	local x = math.random(0, REGIONX)
	local z = math.random(0, REGIONZ)
	entity[i] = {
		mode = "watch",
		coordx = x,
		coordz = z
	}
	aoi.enter(i, x, z, "sense", 1, monstersense)
	--print("npc i:", i, "x:", x, "z:", z)
end
]]--
print("character eneter")
for i = 1, 5 do
	local x = math.random(0, REGIONX)
	local z = math.random(0, REGIONZ)
	entity[i] = {
		mode = "watch",
		coordx = x,
		coordz = z
	}
	--print("pc i:", i, "x:", x, "z:", z)
	aoi.enter(i, x, z, "watch", 1)
end

local enter = {}
local leave = {}
for i = 1, 4 do
	for j = 1, 5000 do
		local x = math.random(0, REGIONX)
		local z = math.random(0, REGIONZ)
		--print("pc i:", i, "x:", x, "z:", z)
		aoi.move(i, x, z, enter, leave)
	end
end


