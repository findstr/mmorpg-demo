local M = {}

local mt = {__index = M}

function M.init(self, gatefd)
	print('agent init')
end

function M.create(self)
	local obj = {

	}
	setmetatable(obj, mt)
	print('agent create')
	return obj
end

function M.kick(self)
	print('agent kick')
end

function M.masterdata(self, fd, d, sz)
	print('agent data')
end

return M

