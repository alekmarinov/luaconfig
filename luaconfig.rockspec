package = "luaconfig"
version = "0.1.0-0"
source = {
  url = "https://github.com/alekmarinov/luaconfig/archive/luaconfig-"..version..".tar.gz",
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
