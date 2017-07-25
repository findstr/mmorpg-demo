--testaux.lua
package.path = package.path .. ";scene-src/?.lua"
package.cpath = package.cpath .. ";luaclib/?.so"

local testcount = 1024 * 1024 * 64
local aux = require "aux"
local abs = math.abs
local sqrt = math.sqrt
local function testeq_c()
	--2.58s
	local a = 0.35
	local b = 0.35
	local eq = aux.eq
	for i = 1, testcount do
		local c = eq(a, b)
	end
end

local function eq_l(a, b)
	return (abs(a - b) < 0.0001)
end

local function testeq_l()
	--5.40s
	local a = 0.35
	local b = 0.35
	for i = 1, testcount do
		c = abs(a, b) < 0.0001
	end
end

local function testdist_c()
	local x1 = 0.35
	local y1 = 0.36
	local x2 = 0.99
	local y2 = 0.99
	--3.83s
	local dist = aux.dist
	for i = 1, testcount do
		local c = dist(x1, y1, x2, y2)
	end
end

local function dist_l(x1, y1, x2, y2)
	local dx = x1 - x2
	local dy = y1 - y2
	return sqrt(dx * dx + dy * dy)
end

local function testdist_l()
	--5.09s
	local x1 = 0.35
	local y1 = 0.36
	local x2 = 0.99
	local y2 = 0.99
	for i = 1, testcount do
		local c = dist_l(x1, y1, x2, y2)
	end
end

local function testfollow_x(follow)
	local x1 = 0.7
	local y1 = 0.8

	local x2 = 6.9
	local y2 = 7.6

	--aux.follow 5.45s
	--follow_l 8.46s

	for i = 1, testcount do
		local nx, ny = follow(x1, y1, x2, y2, 1, 500);
	end
end

local function testfollow_l()
	local x1 = 0.7
	local y1 = 0.8

	local x2 = 6.9
	local y2 = 7.6
	local speed = 1.0
	local time = 500
	--aux.follow 5.45s
	--follow_l 8.46s

	for i = 1, testcount do
		local dx = x2 - x1
		local dy = y2 - y1
		local dist = sqrt(dx * dx + dy * dy)
		local move = dist / (speed * time / 1000)
		if move > 1.0 then
			move = 1.0
		end
		local nx, ny = (x1 + dx * move), (y1 + dy * move)
	end
end

testfollow_x(aux.follow)

