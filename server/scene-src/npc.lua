local core = require "silly.core"
local scene = require "scene"
local xml = require "XML"

local TIMEOUT = 10 * 1000

local M = {}
local NPC = {}
local relive = {}

local function npc_sense(npcid, actid, action)
	--print("npc", npcid, "actid", actid,  action)
end

function M.get(uid)
	return NPC[uid]
end

function M.kill(uid)
	print("[npc] kill", uid)
	scene.leave(uid)
	local n = NPC[uid]
	NPC[uid] =  nil
	local now = core.current() + TIMEOUT
	relive[now] = n
end

local function relive_timer()
	local now = core.current()
	for t, n in pairs(relive) do
		print("[npc] relive now:", now, " relive", t, n)
		if t <= now then
			NPC[n.uid] = n
			scene.enter(n.uid, n.coord_x, n.coord_z,
				"sense", 0, npc_sense)
			relive[t] = nil
		end
	end
end

local function safe_timer()
	local ok, err = core.pcall(relive_timer)
	if not ok then
		print(err)
	end
	core.timeout(1000, safe_timer)
end

function M.start()
	local cfg = xml.get("NPC.xml")
	for k, v in pairs(cfg) do
		local coord = v.coord
		local x = coord[1]
		local z = coord[2]
		local obj = {
			uid = k,
			type = v.type,
			hp = v.hp,
			atk = v.atk,
			def = v.def,
			exp = v.exp,
			matk = v.matk,
			mdef = v.mdef,
			coord_x = x,
			coord_z = z,
		}
		NPC[k] = obj
		scene.enter(k, x, z, "sense", 0, npc_sense)
	end
	safe_timer()
end

return M


