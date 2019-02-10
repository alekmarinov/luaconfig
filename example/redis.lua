
local redis = require("redis")
local config = require("luaconfig")

local rcli = redis.connect({
    host = '127.0.0.1',
    port = 6379,
})

local conf = config({
    _set = function(self, name, value)
        rcli:set(name, value)
    end,
    _get = function(self, name)
        return rcli:get(name)
    end,
    _keys = function(self)
        return rcli:keys("*")
    end
})

conf:set([[
host.os=linux
-- lua style comments and empty lines are allowed

host.arch=x86_64
host.linux.x86_64.cflags=-m64
gcc.cflags=$(host.$(host.os).\ -- multiline
    $(host.arch).cflags) -- reference contains a reference
]])

print(conf:get("gcc.cflags")) -- -m64
print(rcli:get("gcc.cflags")) -- $(host.$(host.os).$(host.arch).cflags)
