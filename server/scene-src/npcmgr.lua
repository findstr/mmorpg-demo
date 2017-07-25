local core = require "silly.core"
local xml = require "XML"
local db = require "db"
local aoi = require "aoi"
local npc = require "npc"
local channel = require "channel"

local M = {}

local DB = {}
local TIMEOUTS = 10

local sense_npc = {}
local reliving_npc = {}
local thinking_npc = {}

local function npc_sense(nid, uid, action)
	print("npc", nid, "uid", uid,  action, sense_npc[nid])
	if not sense_npc[nid] then
		return
	end
	if action == "enter" then
		local npc = DB[nid]
		npc:visible(uid)
		if npc.think then
			thinking_npc[npc] = true
		end
	else
		npc:invisible(uid)
		if not npc.think then
			thinking_npc[npc] = nil
		end
	end
end

local function reliving_timer(now)
	now = now // 1000
	now = now % TIMEOUTS
	local wheel = reliving_npc[now]
	for k, npc in pairs(wheel) do
		wheel[k] = nil
		print("[npc] relive now:", now, " relive", npc.uid)
		DB[npc.uid] = n
		n:relive()
	end
end

local function think_timer()
	local clock = core.monotonic()
	for npc, _ in pairs(thinking_npc) do
		npc:think(clock)
		if (not npc.think) then
			thinking_npc[npc] = nil
		end
	end
end

local function timer_1hz()
	local now = core.monotonic()
	local ok, err = core.pcall(reliving_timer, now)
	if not ok then
		print(err)
	end
	local ok, err = core.pcall(think_timer, now)
	if not ok then
		print(err)
	end
	core.timeout(1000, timer_1hz)
end

function M.kill(nid, uid)
	print("[npc] user:", uid, " kill", nid)
	local npc = DB[nid]
	npc:killedby(uid)
	aoi.npcleave(nid)
	thinking_npc[npc] = nil
	DB[nid] = nil
	local now = (core.monotonic() // 1000 + TIMEOUTS) % TIMEOUTS
	local wheel = reliving_npc[now]
	wheel[#wheel + 1] = npc
end

function M.get(nid)
	return DB[nid]
end

function M.start()
	local cfg = xml.get("NPC.xml")
	aoi.npcwatch(npc_sense)
	local clock = core.monotonic()
	for k, v in pairs(cfg) do
		local obj = npc:create(k, clock, v)
		DB[k] = obj
		if v.type == 2 then
			sense_npc[k] = true
		end
	end
	local count = TIMEOUT
	for i = 0, TIMEOUTS do
		reliving_npc[i] = {}
	end
	timer_1hz()
end

return M


