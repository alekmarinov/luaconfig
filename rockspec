package = "luaconfig"
version = ""
source = {
  url = "git://github.com/alekmarinov/luaconfig.git",
  tag = ""
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
    ["luaconfig"] = "src/luaconfig.lua"
  }
}
