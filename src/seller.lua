local Common = require("common")

local data = {
    {FourCC("hpea"), -1999.6, 1209.7, 43.848},
    {FourCC("hfoo"), -1856.3, 1196.5, 89.629},
    {FourCC("hkni"), -1694.1, 1176.7, 77.621},
    {FourCC("hrif"), -1521.0, 1187.7, 66.810},
    {FourCC("hmtm"), -1357.2, 1216.4, 71.227},
    {FourCC("hmpr"), -2004.5, 967.4, 123.985},
    {FourCC("hsor"), -1847.2, 945.4, 309.824},
    {FourCC("hmtt"), -1656.7, 941.4, 354.342},
    {FourCC("hspt"), -1395.6, 945.4, 235.279},
    {FourCC("nbee"), -1206.0, 1211.9, 87.608},
    {FourCC("nbel"), -1230.0, 953.4, 196.617},
    {FourCC("nchp"), -1065.6, 1209.7, 255.396},
    {FourCC("hhdl"), -1077.8, 975.4, 348.025},
    {FourCC("njks"), -911.0, 1223.0, 207.923},
    {FourCC("hrdh"), -904.0, 995.6, 272.348},
    {FourCC("nhym"), -922.2, 786.0, 263.834},
    {FourCC("nmed"), -1094.0, 758.4, 22.764},
    {FourCC("nhea"), -1262.6, 754.7, 338.653},
    {FourCC("nhem"), -1400.5, 734.7, 80.258},
    {FourCC("nhef"), -1519.6, 720.2, 345.926},
    {FourCC("nemi"), -1642.1, 736.5, 244.310},
    {FourCC("hcth"), -1806.8, 718.4, 33.235},
    {FourCC("hhes"), -1974.6, 711.2, 345.805}
}

local npcs = {}
local SellerController = Observer:new()

local function buy()
    ---@type Unit
    local u =  Unit:fromUd(Native.GetTriggerUnit())
    Common.Request('pet_buy', "id=" .. u:getUserData())
    SellerController:fireEvent(Events.GOLD_UPDATE)
end

local function main()
    local trig = Trigger:create()
    trig:addAction(buy)

    for i, v in ipairs(data) do
        local u = Unit:create(Player:get(Native.GetBJPlayerNeutralVictim()), table.unpack(v))
        u:setUserData(v[1])
        table.insert(npcs, u)
        trig:registerUnitEvent(u, UnitEvent.Selected)
    end
end

Timer:after(0.1, main)
