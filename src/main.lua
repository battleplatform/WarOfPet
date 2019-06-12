require("lib.native.compat")
require("lib.console")

local Native = require("lib.native.native")
local Player = require("lib.oop.player")
local Unit = require("lib.oop.unit")
local Trigger = require("lib.oop.trigger")
local Timer = require("lib.oop.timer")

local json = require("json")

print("Welcom to War Of Pet!!!")

-----------------------------------------------------------------
--- COMMON
local host = "http://192.168.101.55:9527"

local function Request(route, data)
    return Native.RequestExtraStringData(53, nil, string.format("%s/%s", host, route), data or "", false, 0, 0, 0)
end

local function doAfter(sec, cb)
    local t = Timer:create()
    t:start(
        sec,
        false,
        function()
            cb()
            t:destroy()
        end
    )
end

-----------------------------------------------------------------
--- Logic

local function getWage()
    if Native.GetSpellAbilityId() == FourCC("Agz1") then
        print(123)
    end
end

local function refreshWage()
    local res = Request("look_wage")
    local j = json.decode(res)
    print(res, j['body'])
end

local function initUnit()
    local wager = Unit:create(Player:get(0), FourCC("hgz1"), -768.0, 640.0, 270.000)

    -- 领取工资
    local w = Trigger:create()
    w:registerUnitEvent(wager, Native.ConvertUnitEvent(293))
    w:addAction(getWage)

    -- 刷新工资
    local r = Trigger:create()
    r:registerUnitEvent(wager, Native.ConvertUnitEvent(57))
    r:addAction(
        function()
            doAfter(1.0, refreshWage)
        end
    )
end

initUnit()
