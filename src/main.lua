require("lib.native.compat")
require("lib.console")
require("lib.oop.enum")

local Native = require("lib.native.native")
local Player = require("lib.oop.player")
local Unit = require("lib.oop.unit")
local Trigger = require("lib.oop.trigger")

local Common = require("common")

print("Welcom to War Of Pet!!!")

local wager  -- 雇主NPC

local function refreshGold()
    local ok, res = Common.Request("gold")
    if ok then
        Player:get(0):setState(PlayerState.ResourceGold, res.gold)
    else
        print(res)
    end
end

local function getWage()
    if Native.GetSpellAbilityId() == FourCC("Agz1") then
        Common.Request("wage")
        refreshGold()
    end
end

local function refreshWage()
    local ok, res = Common.Request("look_wage")
    if ok then
        print("待领工资", res.wage)
    else
        print(res)
    end
end

local function main()
    wager = Unit:create(Player:get(0), FourCC("hgz1"), -768.0, 640.0, 270.000)

    -- 领取工资
    local w = Trigger:create()
    w:registerUnitEvent(wager, UnitEvent.SpellEndcast)
    w:addAction(getWage)

    -- 刷新工资
    local r = Trigger:create()
    r:registerUnitEvent(wager, UnitEvent.Selected)
    r:addAction(refreshWage)

    refreshGold()
end

Common.doAfter(0.1, main)

