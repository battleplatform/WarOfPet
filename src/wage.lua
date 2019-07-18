local Common = require("common")

local WageController = Observer:new()

---@type Unit
local wage

local function refreshGold(_rope)
    local ok, res
    if _rope then
        ok, res = Common.RequestAsync(_rope, "gold")
    else
        ok, res = Common.Request("gold")
    end
    if ok then
        Player:get(0):setState(PlayerState.ResourceGold, res.gold)
    else
        print(res)
    end
end

local function getWage(_rope, spell)
    if not spell then
        spell = Native.GetSpellAbilityId()
    end
    if spell == FourCC("Agz1") then
        local ok, res
        if _rope then
            ok, res = Common.RequestAsync(_rope, "wage")
        else
            ok, res = Common.Request("wage")
        end
        if ok then
            wager:setStringField(UnitStringField.Name, string.format("可领工资：%s", res.wage))
            refreshGold(_rope)
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

local function refreshWage(_rope)
    local ok, res
    if _rope then
        ok, res = Common.RequestAsync(_rope, "look_wage")
    else
        ok, res = Common.Request("look_wage")
    end
    if ok then
        wager:setStringField(UnitStringField.Name, string.format("可领工资：%s", res.wage))
    else
        print(res)
    end
end

local function main(_rope)
    wager = Unit:create(Player:get(0), FourCC("Hgz1"), -132.0, 158.0, 270.000)
    Player:get(0):setState(PlayerState.ResourceFoodCap, 200)

    -- 领取工资
    local w = Trigger:create()
    w:registerUnitEvent(wager, UnitEvent.SpellEndcast)

    -- 刷新工资
    local r = Trigger:create()
    r:registerUnitEvent(wager, UnitEvent.Selected)

    refreshGold(_rope)

    if _rope then
        WageController:registerEvent(Events.GOLD_UPDATE, function()
            Common.bundle(refreshGold)
        end)
        w:addAction(function()
            local spell = Native.GetSpellAbilityId()
            Common.bundle(function(r)
                getWage(r, spell)
            end)
        end)
        r:addAction(function()
            Common.bundle(refreshWage)
        end)
    else
        WageController:registerEvent(Events.GOLD_UPDATE, refreshGold)
        w:addAction(getWage)
        r:addAction(refreshWage)
    end

end

Timer:after(0.1, function()
    if Common.mls then
        Common.bundle(main)
    else
        main()
    end
end)
