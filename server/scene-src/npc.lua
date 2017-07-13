local aoi = require "aoi"
local xml = require "XML"
local M = {}

local NPC = {}

local function npc_sense(npcid, actid, action)
	--print("npc", npcid, "actid", actid,  action)
end

function M.info(uid)
	return NPC[uid]
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
			matk = v.matk,
			mdef = v.mdef,
			coord_x = x,
			coord_z = z,
		}
		aoi.enter(k, x, z, "sense", 0, npc_sense)
		NPC[k] = obj
		print(k, v.Name, v.Model)
	end
end

return M


