local db = require "db"
local const = require "const"
local channel = require "channel"
local M = {}

function M.attack(atk, def, skill)
	local hp = atk[skill.atkp] * skill.atkv // const.PERCENT100
	hp = hp - def[skill.defp]
	if hp < 0 then
		return false
	end
	local res = def.hp - hp
	if res < 0 then
		hp = hp + res
		def.hp = 0
	else
		def.hp = res
	end
	return true
end

return M

