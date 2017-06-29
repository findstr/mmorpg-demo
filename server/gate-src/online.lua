local M = {}

local online = {}

function M.login(uid, gatefd)
	online[uid] = gatefd
end

function M.logout(uid)
	online[uid] = gatefd
end

function M.gatefd(uid)
	return online[uid]
end

return M

