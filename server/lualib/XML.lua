local SLAXML = require 'slaxml'
local log = require "log"
local POWER = 10000
local config = {}

config.null = {}

local XML = {}

local T = {}

T["INT"] = function (tbl, name, value)
	value = assert(tonumber(value), "invalid field 'int' of " .. name)
        tbl[name] = value
	return value
end

T["STRING"] = function (tbl, name, value)
	value = assert(value, "invalid field 'string' of " .. name)
        tbl[name] = value
	return value
end

function config.tolistint(tbl, name, value)
        if string.upper(value) == "NULL" then
                tbl[name] = config.null
		return
        end
        local res = {}
        for n in string.gmatch(value, "(%d+)") do
                res[#res + 1] = assert(tonumber(n), "invalid field 'listint' of " .. name)
        end
        tbl[name] = res
end

T["LIST:INT"] = config.tolistint

function config.tolistidcnt(tbl, name, value)
        if string.upper(value) == "NULL" then
		tbl[name] = config.null
		tbl[name .. "_list"] = config.null
		return
        end
        local res = {}
	local list = {}
        for id, cnt in string.gmatch(value, "(%d+):(%d+)") do
                id = assert(tonumber(id), "invalid field 'listidcount::id' of " .. name)
		cnt = assert(tonumber(cnt), "invalide field 'listcount::count' of " .. name)
		list[#list + 1] = {id = id, count = cnt}
                if not res[id] then
                        res[id] = cnt
                else
                        res[id] = res[id] + cnt
                end
        end
	tbl[name] = res
	tbl[name .. "_list"] = list
        return res
end

T["LIST:IDCOUNT"] = config.tolistidcnt

local function parseone(file)
        local f, err = io.open(file)
        if not f then
                log.print("[config] parseone", file, err)
                return
        end
        local fname = string.match(file, "([^/]+)$")
        local myxml = f:read('*all')
        local typetbl = {}
        local typeidx = 0
        local data = {}
        local current
        local parser = SLAXML:parser {
                comment = function(content)
                        local title = string.match(content, "[^\n]+[^\n]+\n+([^\n]+)\n")
                        for typ in string.gmatch(title, "([%a%p]+)") do
                                typetbl[#typetbl + 1] = typ
                        end
                end, -- comments

                startElement = function(name,nsURI,nsPrefix)
                        typeidx = 1
                        current = {}
                end, -- When "<foo" or <x:foo is seen

                attribute    = function(name,value,nsURI,nsPrefix)
                        local typ = assert(typetbl[typeidx],
                                string.format("[config] %s:name:%s has no type", file, name))
                        typeidx = typeidx + 1
                        typ = string.upper(typ)
                        local trans = assert(T[typ], "[config] unsupport type " .. typ .. name)
                        local v = trans(current, name, value)
                        if typeidx == 2 then
                                --assert(string.upper(typetbl[typeidx - 1]) == "INT", "[config] first field must be int")
                                data[v] = current
                        end
                end, -- attribute found on current element

                closeElement = function(name,nsURI)
                        if current.Key then
                                data[current.Key] = current
				if current.Key1 and current.Key2 then
					local k1, k2 = current.Key1, current.Key2
					assert(type(k1) == "integer")
					assert(type(k2) == "integer")
					local sub = data._subkey
					if not sub then
						sub = {}
						data._subkey = sub
					end
					assert(k2 < POWER)
					sub[k1 * POWER + k2] = current
				end
                        end
                end, -- When "</foo>" or </x:foo> or "/>" is seen
                text         = function(text)
                end, -- text and CDATA nodes
                pi           = function(target,content)
                end, -- processing instructions e.g. "<?yes mon?>"
        }
        parser:parse(myxml,{stripWhitespace=true})
        XML[fname] = data
end

function config.parselist(folder)
        for _, v in pairs(folder) do
                parseone(v)
        end
end

function config.get(name)
        return XML[name]
end

function config.getkey(name, key)
        local t = XML[name]
        if not t then
                return nil
        end
        return t[key]
end

function config.getkey2(name, key1, key2)
	local t = XML[name]
	if not t then
		return nil
	end
	local k = key1 * POWER + key2
	return t[k]
end

return config
