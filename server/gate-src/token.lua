local M = {}

local uid_token = {}

function M.fetch(uid)
	local token = uid_token[uid]
	if not token then
		token = math.random(1, 1000)
		uid_token[uid] = token
	end
	return token
end

function M.kick(uid)
	uid_token[uid] = nil
end

function M.validate(uid, token)
	local tk = uid_token[uid]
	if not tk then
		return false
	end
	if tk == token then
		uid_token[uid] = tk + 1
		return true
	end
	return false
end

return M

