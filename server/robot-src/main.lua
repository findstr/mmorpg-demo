local core = require "silly.core"
local env = require "silly.env"
local crypt = require "crypt"
local cproto = require "protocol.client"
local np = require "netpacket"
local db = require "scene-src.db"
local msg = require "saux.msg"
local unpack = string.unpack
local pack = string.pack


local function encodeproto(cmd, pk)
	cmd = cproto:querytag(cmd)
	local dat = cproto:encode(cmd, pk)
	return pack("<I4", cmd) .. dat
end

local SPEED = 1.0
local REGIONX = 100
local REGIONZ = 100
local EMPTY = {}
local Achallenge = cproto:querytag("a_accountchallenge")
local Alogin = cproto:querytag("a_accountlogin")
local Agate = cproto:querytag("a_gatelogin")
local Arole = cproto:querytag("a_rolecreate")
local Astart = cproto:querytag("a_startgame")

local function oneuser(i)
	local login, client
	local gate
	local randomkey
	local uid, token
	local coordx, coordz
	local waitco = core.running()
	print("run", i, waitco)
	local r_movepoint = {
		coord_x = false,
		coord_z = false,
		moveto_x = false,
		moveto_z = false,
	}

	login = msg.createclient {
		addr = env.get("loginport"),
		data = function(f, d, sz)
			local str = np.tostring(d, sz)
			local cmd = unpack("<I4", str)
			print("login", cmd)
			if cmd == Achallenge then
				local ack = cproto:decode(cmd, str:sub(4+1))
				randomkey = ack.randomkey
				core.wakeup(waitco)
				print("randomkey", ack.randomkey)
				print("[WAKEUP] randomkey", i)
			elseif cmd == Alogin then
				local ack = cproto:decode(cmd, str:sub(4+1))
				uid = ack.uid
				token = ack.token
				print("accountlogin", uid, token)
				print("[WAKEUP] accountlogin", i)
				core.wakeup(waitco)
			end
		end,
		close = function(fd, errno)
			print(fd, "close")
		end
	}
	client = msg.createclient {
		addr = env.get("openport_1"),
		data = function(f, d, sz)
			local str = np.tostring(d, sz)
			local cmd = unpack("<I4", str)
			if cmd == Agate then
				local ack = cproto:decode(cmd, str:sub(4+1))
				coordx, coordz = 10.0, 10.0
				print("[WAKEUP] gatelogin", i, f)
				core.wakeup(waitco)
			elseif cmd == Arole then
				print("[WAKEUP] rolecreate", i, f)
				core.wakeup(waitco)
			elseif cmd == Astart then
				print("[WAKEUP] startgame", i, f)
				core.wakeup(waitco)
			end
		end,
		close = function(fd, errno)
			print(fd, "close")
		end
	}
	-------login account
	local ok = login:connect()
	print("connect", ok)
	login:send(encodeproto("r_accountchallenge", EMPTY))
	print("[WAIT] challenge", i)
	core.wait()
	local sha1 = crypt.sha1("123456")
	local hmac = crypt.hmac(sha1, randomkey)
	local r_accountlogin = {
		gateid = 1,
		user = "robot" .. i,
		passwd = hmac,
	}
	login:send(encodeproto("r_accountlogin", r_accountlogin))
	print("[WAIT] account", i)
	core.wait()
	login:close()
	--------login gate
	local ok = client:connect()
	local r_gatelogin = {
		uid = uid,
		token = token
	}
	client:send(encodeproto("r_gatelogin", r_gatelogin))
	core.wait()
	print("logingate", coordx, coordz)
	-------create role
	local r_rolecreate = {
		name = "我是机器人"
	}
	client:send(encodeproto("r_rolecreate", r_rolecreate))
	core.wait()
	client:send(encodeproto("r_startgame", EMPTY))
	core.wait()
	---------test logic
	local last = core.monotonic()
	while true do
		local now = core.monotonic()
		local delta = now - last
		local x = math.random(-SPEED, SPEED) * delta
		local z = math.random(-SPEED, SPEED) * delta
		r_movepoint.movetime = now
		r_movepoint.coord_x = coordx
		r_movepoint.coord_z = coordz
		coordx = x + coordx
		coordz = z + coordz
		if coordx > REGIONX then
			coordx = REGIONX
		elseif coordx < 0 then
			coordx = 0
		end
		if coordz > REGIONZ then
			coordz = REGIONZ
		elseif coordz < 0 then
			coordz = 0
		end
		r_movepoint.moveto_x = coordx
		r_movepoint.moveto_z = coordz
		client:send(encodeproto("r_movepoint", r_movepoint))
		last = now
		core.sleep(math.random(300, 800))
	end
end

local function test(i)
	for i = 1, 1024 do
		print(i)
		core.sleep(100)
	end
end

core.start(function()
	local id = 1
	for j = 1, 50 do
		for i = 1, 10 do
			core.fork(function()
				oneuser(id)
			end)
			id = id + 1
			core.sleep(300)
		end
		core.sleep(300)
	end
	print("=============================")
end)

