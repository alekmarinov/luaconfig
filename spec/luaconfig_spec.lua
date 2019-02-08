local config = require("luaconfig.memory")

local function assert_equal_sets(set1, set2)
    assert.are.same(#set1, #set2)

    local t = {}
    for _, v in ipairs(set1) do
        t[v] = true
    end
    for _, v in ipairs(set2) do
        assert.truthy(t[v])
    end
end

describe("new config", function()
    it("is empty", function()
        local conf = config()
        assert.are.same({}, conf:keys())
        assert.are.same({}, conf:values())
    end)
    it("with custom storage is empty", function()
        local conf = config{storage={}, prefix="foo.bar"}
        assert.are.equal("foo.bar", conf.prefix)
        assert.are.same({}, conf:keys())
        assert.are.same({}, conf:values())
    end)
end)

describe("set and get values", function()
    it("can get what is set", function()
        local conf = config()
        conf:set("foo.bar", "value")
        assert.are.same("value", conf:get("foo.bar"))
    end)
    it("custom storage contain what is set", function()
        local conf = config{storage={}}
        conf:set("foo.bar", "value")
        assert.are.same({ ["foo.bar"] = "value" }, conf.storage)
    end)
    it("keys in custom storage have prefix", function()
        local conf = config{storage={}, prefix="boo."}
        conf:set("foo.bar", "value")
        assert.are.same({ ["boo.foo.bar"] = "value" }, conf.storage)
    end)
    it("get is guessing the type set", function()
        local conf = config()
        conf:set("foo.bar", "value")
        assert.are.same("string", type(conf:get("foo.bar")))
        conf:set("foo.bar", 1)
        assert.are.same("number", type(conf:get("foo.bar")))
        conf:set("foo.bar", true)
        assert.are.same("boolean", type(conf:get("foo.bar")))
        conf:set("foo.bar", false)
        assert.are.same("boolean", type(conf:get("foo.bar")))
    end)
    it("support references $(x.y.z)", function()
        local conf = config()
        conf:set("foo.bar", "value")
        conf:set("zar", "$(foo.bar)")
        assert.are.same("value", conf:get("zar"))
    end)
    it("support nested references $(x.$(y).z)", function()
        local conf = config()
        conf:set("foo.bar", "bar")
        conf:set("zar", "$(foo.$(foo.bar))")
        assert.are.same("bar", conf:get("zar"))
    end)
    it("by string", function()
        local conf = config()
        conf:set("foo.bar=value")
        assert.are.same("value", conf:get("foo.bar"))
    end)
    it("by multi-line string", function()
        local conf = config()
        conf:set("foo.bar=value1")
        conf:set("foo.zar=value2")
        assert.are.same("value1", conf:get("foo.bar"))
        assert.are.same("value2", conf:get("foo.zar"))
    end)
    it("reference can reference", function()
        local conf = config()
        conf:set([[
            host.os=linux
            host.arch=x86_64
            host.linux.x86_64.cflags=-m64
            gcc.cflags=$(host.$(host.os).$(host.arch).cflags)
            ]])
        assert.are.same("-m64", conf:get("gcc.cflags"))
    end)
    it("value can continue to the next line", function()
        local conf = config()
        conf:set([[
            name=multi\
                 line\
                 value
            dummy = \
                bummy
            foo=bar\
                ba\
        ]])
        assert.are.same("multilinevalue", conf:get("name"))
        assert.are.same("barba", conf:get("foo"))
        assert.are.same("bummy", conf:get("dummy"))
    end)
    it("spaces are allowed around the equals sign", function()
        local conf = config()
        conf:set([[
            name =              value   
        ]])
        assert.are.same("value", conf:get("name"))
    end)
    it("throws error on cyclic references", function()
        local conf = config()
        conf:set([[
            ref1=$(ref2)
            ref2=$(ref3)
            ref3=$(ref1)
        ]])
        assert.has_error(function() conf:get("ref2") end, "Cyclic substitution detected by key `ref2':\nref2,ref3,ref1")
    end)
    it("throws error on undefined reference", function()
        local conf = config()
        conf:set([[
            ref=$(undef)
        ]])
        assert.has_error(function() conf:get("ref") end, "can't substitute reference `undef''")
    end)
    it("escape", function()
        local conf = config()
        conf:set([[
            dir=c:\\a\\b
        ]])
        assert.are.same("c:\\a\\b", conf:get("dir"))
    end)

end)

describe("enumerate", function()
    it("keys", function()
        local conf = config()
        conf:set("foo.bar", "value")
        conf:set("foo.zar", 2)
        assert_equal_sets({ "foo.zar", "foo.bar" }, conf:keys())
    end)
    it("value keys dispite prefix", function()
        local conf = config{prefix="foo.bar"}
        conf:set("key1", "value1")
        conf:set("key2", "value2")
        assert_equal_sets({ "key1", "key2" }, conf:keys())
    end)
    it("basic values", function()
        local conf = config()
        conf:set("k1", "value1")
        conf:set("k2", "value2")
        assert_equal_sets({ "value1", "value2" }, conf:values())
    end)
    it("values with references", function()
        local conf = config()
        conf:set("foo.bar", "bar")
        conf:set("zar", "$(foo.$(foo.bar))")
        assert_equal_sets({ "bar", "bar" }, conf:values())
    end)
    it("values without computing references", function()
        local conf = config()
        conf:set("foo.bar", "bar")
        conf:set("zar", "$(foo.$(foo.bar))")
        assert_equal_sets({ "bar", "$(foo.$(foo.bar))" }, conf:rawvalues())
    end)
end)
