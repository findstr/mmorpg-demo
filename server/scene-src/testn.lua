--testo.lua
package.path = package.path .. ";scene-src/?.lua"
package.cpath = package.cpath .. ";luaclib/?.so"
local aoi = require "aoi"
local REGIONX = 100
local REGIONZ = 100

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

local enter = {}
local leave = {}
local function clear(tbl)
	for k, v in pairs(tbl) do
		tbl[k] = nil
	end
end

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
	aoi.enter(i, x, z, enter)
	clear(enter)
end

for i = 1, 4 do
	for j = 1, 5000 do
		local x = math.random(0, REGIONX)
		local z = math.random(0, REGIONZ)
		--print("pc i:", i, "x:", x, "z:", z)
		aoi.move(i, x, z, enter, leave)
		clear(enter)
		clear(leave)
	end
end


