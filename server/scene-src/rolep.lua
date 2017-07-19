local channel = require "channel"
local M = {}

local a_rolepoint = {
	level = false,
	exp = false,
	mp = false,
	hp = false,
}

function M.rolepoint(uid, level_add, exp_add, mp_add, hp_add)
	a_rolepoint.level = level_add
	a_rolepoint.exp = exp_add
	a_rolepoint.mp = mp_add
	a_rolepoint.hp = hp_add
	return channel.senduid(uid, "a_rolepoint", a_rolepoint)
end


return M

