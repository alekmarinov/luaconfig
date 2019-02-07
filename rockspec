package = "luaconfig"
tag = "0.1.0"
version = tag.."-0"
source = {
  url = "git://github.com/alekmarinov/luaconfig.git",
  tag = tag
}
description = {
  summary = "Lua module providing advance configuration functionality",
  homepage = "https://github.com/alekmarinov/luaconfig",
  license = "MIT",
  maintainer = "Alexander Marinov <alekmarinov@gmail.com>"
}
dependencies = {
  "lua >= 5.1",
}
build = {
  type = "builtin",
  modules = {
    ["luaconfig"] = "src/luaconfig.lua",
    ["luaconfig.memory"] = "src/luaconfig/memory/init.lua"
  }
}
