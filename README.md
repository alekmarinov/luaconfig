# LuaConfig

Lua module providing advance configuration functionality.

# Install
luarocks install luaconfig

# Usage

```lua
local conf = require("luaconfig.memory")() -- 
conf:set("dir", "/root")
print(conf:get("dir")) -- /root

conf:set("file", "$(dir)/file")
print(conf:get("file")) -- /dir/file

conf:set([[
host.os=linux
host.arch=x86_64
host.linux.x86_64.cflags=-m64
gcc.cflags=$(host.$(host.os).$(host.arch).cflags)
]])

print(conf:get("gcc.cflags")) -- -m64

```
