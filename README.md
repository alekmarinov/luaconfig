# LuaConfig

Lua module providing advance configuration functionality.

# Install
luarocks install luaconfig

# Usage

```lua
local conf = require("luaconfig.memory")()

-- set/get simple value
conf:set("dir", "/root")
print(conf:get("dir")) -- /root

-- setting a value with reference to another config
conf:set("file", "$(dir)/file")
print(conf:get("file")) -- /root/file

-- setting multiple configurations, convenient when loading from file
conf:set([[
host.os=linux
-- lua style comments and empty lines are allowed

host.arch=x86_64
host.linux.x86_64.cflags=-m64
gcc.cflags=$(host.$(host.os).\ -- multiline
    $(host.arch).cflags) -- reference contains a reference
]])

print(conf:get("gcc.cflags")) -- -m64

```

