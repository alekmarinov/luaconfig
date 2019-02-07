
local luaconfig = {}

--
-- validates a key if conforms key pattern
--
local function validatekey(key)
    assert(key)
	assert(key:match("[%w_%-/]+"),
		   "invalid config key ("..tostring(key)..")")
end

--
-- substitute reference
--
local function subst(self, value, history)
	local c
	repeat
		value, c = string.gsub(value, "(%$%b())", function(key)
			key = key:sub(3, -2)
			while key:find("%$%(") do
				key = subst(self, key, history)
			end
			local deref = self:get(key, false, history)
			if not deref then
				error("can't substitute reference "..key)
			end
			return deref
		end)
	until c == 0
	return value
end

function luaconfig:set(key, value)
	validatekey(key)
    local multiline = key
    if type(value) ~= "nil" then
        -- in case the value is given interpret single line config setter
        multiline = string.format("%s=%s", key, tostring(value))
    end
    for line in multiline:gmatch("[^\n]+") do
        -- strip comments
        line = string.gsub(line, "(%-%-.*)", "")
        -- trim
        line = string.gsub(line, "^%s*(.-)%s*$", "%1")
        -- unescape
        line = string.gsub(line, "\\(.)", "%1")
        line:gsub("(.-)=(.*)", function(key, value)
            -- set value with type as a string
            self:_set(key, tostring(value))
        end)
    end
end

--
-- get configuration property value
--
function luaconfig:get(key, nosubst, history)
    -- check for cyclic references in get history
    history = history or {}
    for i, v in ipairs(history) do
        if v == key then
            error(string.format("Cyclic substitution detected by key `%s':\n%s", key, table.concat(history)))
        end
    end
    table.insert(history, key)

    -- get value from driver
    local value = self:_get(key)

    if value then
        -- try substitude value references 
        value = (not nosubst and subst(self, value, history)) or value

        -- guess value type
        value = tonumber(value) or value
        
        if value == "true" then
            value = true
        elseif value == "false" then
            value = false
        end
    end
    table.remove(history)
    return value
end

function luaconfig:values()
    local values = {}
    for _, key in ipairs(self:keys()) do
        table.insert(values, self:get(key))
    end
    return values
end

return luaconfig
