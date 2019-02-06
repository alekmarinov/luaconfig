

-----------------------------------------------------------------------
-- local constants ----------------------------------------------------
-----------------------------------------------------------------------
local keypattern = "%w_%-/"

-----------------------------------------------------------------------
-- private functions --------------------------------------------------
-----------------------------------------------------------------------

--
-- validates a key if conforms key pattern
--
local function validatekey(key)
	assert(string.match(key, "["..keypattern.."]+"),
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
			local deref = self.get(key, false, history)
			if not deref then
				error("can't substitute reference "..key)
			end
			return deref
		end)
	until c == 0
	return value
end


local function doget(self, key, nosubst, history)
	validatekey(key)
    local value = self.driver._get(key)
    if type(value) == "string" then
        -- try substitude value references 
        value = (not nosubst and subst(self, value, history)) or value
    end
    -- try number value
    value = tonumber(value) or value

	return value
end

function new(driver)

    local t = {}
    t.driver = driver

    function t.set(key, value)
        if type(value) == "nil" then
            for line in key:gmatch("[^\n]+") do
                -- strip comments
                line = string.gsub(line, "(%-%-.*)", "")
                -- trim
                line = string.gsub(line, "^%s*(.-)%s*$", "%1")
                -- unescape
                line = string.gsub(line, "\\(.)", "%1")
                line:gsub("(.-)=(.*)", function(key, value)
                    driver._set(key, value)
                end)
            end
        else
            driver._set(key, value)
        end
    end

    --
    -- get configuration property value
    --
    function t.get(key, nosubst, history)
        history = history or {}
        for i, v in ipairs(history) do
            if v == key then
                local errmsg = {"Cyclic substitution detected by key "..key}
                for _, h in ipairs(history) do
                    table.insert(errmsg, h)
                end
                error(table.concat(errmsg, "\n"))
            end
        end
        table.insert(history, key)
        local value = doget(t, key, nosubst, history)
        table.remove(history)
        return value
    end

    function t.values()
        local values = {}
        for _, key in ipairs(driver.keys()) do
            table.insert(values, t.get(key))
        end
        return values
    end

    return setmetatable(t, { __index = driver })
end

return new
