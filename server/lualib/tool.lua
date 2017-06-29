local env = require "silly.env"
local M = {}

function M.gatelist()
	local l = {}
	for gatei = 1, 100 do
		port = env.get("brokerport_" .. gatei)
		l[gatei] = port
	end
	return l
end


return M

