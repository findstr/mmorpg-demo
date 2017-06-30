local M = {}

local online_fd = {}
local online_agent = {}
function M.login(uid, gatefd, agent)
	online_fd[uid] = gatefd
	online_agent[uid] = agent
end

function M.logout(uid)
	online_fd[uid] = nil
	online_agent[uid] = nil
end

function M.gatefd(uid)
	return online_fd[uid]
end

function M.agent(uid)
	return online_agent[uid]
end

return M

