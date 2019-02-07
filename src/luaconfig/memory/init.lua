-- luaconfig memory driver

local luaconfig = require("luaconfig")

local memory = setmetatable({}, { __index = luaconfig })
memory.__index = memory

function memory:_set(key, value)
    self.storage[self.prefix..key] = value
end

function memory:_get(key)
    return self.storage[self.prefix..key]
end

function memory:keys()
    local keys = {}
    for k in pairs(self.storage) do
        table.insert(keys, k:sub(1 + self.prefix:len()))
    end
    return keys
end

function memory:rawvalues()
    local values = {}
    for _, v in pairs(self.storage) do
        table.insert(values, v)
    end
    return values
end

return function (options)
    options = options or {}
    local t = {}
    t.storage = options.storage or {}
    t.prefix = options.prefix or ""
    return setmetatable(t, memory)
end
