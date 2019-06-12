
local Common = require("common")

---@type Unit
local wage

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
        local ok, res = Common.Request("wage")
        if ok then
            wager:setStringField(UnitStringField.Name, string.format("可领工资：%s", res.wage))
            refreshGold()
        else
            print(res)
        end
    end
end

local function refreshWage()
    local ok, res = Common.Request("look_wage")
    if ok then
        wager:setStringField(UnitStringField.Name, string.format("可领工资：%s", res.wage))
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

Timer:after(0.1, main)
