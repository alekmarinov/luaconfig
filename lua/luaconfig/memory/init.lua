local luaconfig = require("luaconfig")

local function new(options)
    options = options or {}
    local t = {}
    t.storage = options.storage or {}
    t.prefix = options.prefix or ""

    function t._set(key, value)
        t.storage[t.prefix..key] = value
    end

    function t._get(key)
        return t.storage[t.prefix..key]
    end

    function t.keys()
        local keys = {}
        for k in pairs(t.storage) do
            table.insert(keys, k:sub(1 + t.prefix:len()))
        end
        return keys
    end

    function t.rawvalues()
        local values = {}
        for _, v in pairs(t.storage) do
            table.insert(values, v)
        end
        return values
    end

    return luaconfig(t)
end

return new
