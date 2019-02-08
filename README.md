[![Build Status](https://travis-ci.org/alekmarinov/luaconfig.svg?branch=master)](https://travis-ci.org/alekmarinov/luaconfig)
[![Coverage Status](https://coveralls.io/repos/github/alekmarinov/luaconfig/badge.svg?branch=master)](https://coveralls.io/github/alekmarinov/luaconfig?branch=master)
[![License](http://img.shields.io/badge/License-MIT-brightgreen.svg)](LICENSE)

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

