local name = ...
local line = 0
local key = {}
local desc = {}
local typ = {}
local clientxml = {}
local serverxml = {}
local split = {}
local format = string.format
local upper = string.upper

local function insertxml(val)
	table.insert(clientxml, val)
	table.insert(serverxml, val)
end

local keyword = "([^\t \r\n]+)"

local function pushtable(l, tbl)
	local k = 0
	for w in string.gmatch(l, keyword) do
		k = k + 1
		print(w)
		tbl[k] = w
	end
end

local function buildit(list)
	for k = 1, #split do
		local t = split[k]
		if t == "A" or t == "S" then
			table.insert(serverxml, format("%s\t", list[k]))
		end
		if t == "A" or t == "C" then
			table.insert(clientxml, format("%s\t", list[k]))
		end
	end
end

local function buildhead()
	insertxml("<!--\n")
	buildit(desc)
	insertxml("\n")
	buildit(typ)
	insertxml("\n")
	insertxml("-->\n")
	insertxml(format("<%s>\n", name))
end

local function cookline(l)
	if line == 1 then	--name
		pushtable(l, key)
	elseif line == 2 then --desc
		pushtable(l, desc)
	elseif line == 3 then --type
		pushtable(l, typ)
	elseif line == 4 then --C/S
		pushtable(l, split)
		buildhead()
	else
		local k = 0
		insertxml("<l ")
		for w in l:gmatch(keyword) do
			k = 1 + k
			local v = format('%s="%s" ', assert(key[k], k), w)
			local t = upper(split[k])
			print("xxx", t, v)
			if t == "A" then
				insertxml(v)
			elseif t == "C" then
				table.insert(clientxml, v)
			else
				table.insert(serverxml, v)
			end
		end
		insertxml("/>\n")
	end
end
insertxml('<?xml version="1.0" encoding="utf-8"?>\n')
for l in io.stdin:lines() do
	line = line + 1
	cookline(l)
end
insertxml(format("\n</%s>\n", name))

local function write(xml, path)
	local out = table.concat(xml, "")
	local f = io.open(format("%s/%s.xml", path, name), "w+")
	f:write(out)
	f:flush()
	f:close()
end

write(clientxml, "client")
write(serverxml, "server")

