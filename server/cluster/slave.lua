local core = require "silly.core"
local env = require "silly.env"
local msg = require "saux.msg"

local M = {}
--[[
slave.start {
	masters = { --list
		'masterid' = connect port
	}
	event = {
		connected = function(masterid),
		close = function(masterid),
		data = function(masterid, fd, d, sz)
	}
}
]]--

local master_connect = {}
local master_count = 0

function M.send(masterid, data)
	local g = master_connect[masterid]
	if not g then
		return false, "disconnect"
	end
	return g:send(data)
end

function M.validate(masterid)
	if master_connect[masterid] then
		return true
	end
	return false
end

local function createmaster(masterid, addr, event)
	local client
	local function checkconnect()
		local t = 1000
		while true do
			local ok = client:connect()
			print("[slave] connect masterid", masterid, ok)
			if ok then
				assert(event.connected)(masterid)
				return
			end
			core.sleep(t)
		end
	end
	client = msg.createclient {
		addr = addr,
		close = function(fd, errno)
			print("[slave] close", fd, errno)
			core.fork(checkconnect)
		end,
		data = function(fd, d, sz)
			event.data(masterid, d, sz)
		end
	}
	client.masterid = masterid
	client.checkconnect = checkconnect
	master_connect[masterid] = client
	return client
end

function M.start(config)
	local event = config.event
	for masterid, addr in pairs(config.masters) do
		master_count = master_count + 1
		local g = createmaster(masterid, addr, event)
		local ok = g:connect()
		if ok then
			event.connected(masterid)
		else
			core.fork(g.checkconnect)
		end
	end
	return true
end

return M

