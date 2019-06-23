local Common = require("common")

local WageController = Observer:new()

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
    local spell = Native.GetSpellAbilityId()
    if spell == FourCC("Agz1") then
        local ok, res = Common.Request("wage")
        if ok then
            wager:setStringField(UnitStringField.Name, string.format("可领工资：%s", res.wage))
            refreshGold()
        else
            print(res)
        end
    elseif spell == FourCC("Amat") then
        WageController:fireEvent(Events.START_MATCH)
    elseif spell == FourCC("Acj1") then
        WageController:fireEvent(Events.LOTTERY)
    elseif spell == FourCC("Askp") then
        WageController:fireEvent(Events.SKIP_ROUND)
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
    wager = Unit:create(Player:get(0), FourCC("Hgz1"), -132.0, 158.0, 270.000)
    Player:get(0):setState(PlayerState.ResourceFoodCap, 200)

    -- 领取工资
    local w = Trigger:create()
    w:registerUnitEvent(wager, UnitEvent.SpellEndcast)
    w:addAction(getWage)

    -- 刷新工资
    local r = Trigger:create()
    r:registerUnitEvent(wager, UnitEvent.Selected)
    r:addAction(refreshWage)

    refreshGold()

    WageController:registerEvent(Events.GOLD_UPDATE, refreshGold)
end

Timer:after(0.1, main)
