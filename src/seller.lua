local Common = require("common")

local data = {
    {petId = "hpea", price = 50, attack = 20, health = 100, speed = 5},
    {petId = "hfoo", price = 50, attack = 20, health = 100, speed = 5},
    {petId = "hkni", price = 50, attack = 20, health = 100, speed = 5},
    {petId = "hrif", price = 50, attack = 20, health = 100, speed = 5},
    {petId = "hmtm", price = 50, attack = 20, health = 100, speed = 5},
    {petId = "hmpr", price = 100, attack = 40, health = 200, speed = 10},
    {petId = "hsor", price = 100, attack = 40, health = 200, speed = 10},
    {petId = "hmtt", price = 100, attack = 40, health = 200, speed = 10},
    {petId = "hspt", price = 100, attack = 40, health = 200, speed = 10},
    {petId = "nbee", price = 100, attack = 40, health = 200, speed = 10},
    {petId = "nbel", price = 150, attack = 60, health = 300, speed = 15},
    {petId = "nchp", price = 150, attack = 60, health = 300, speed = 15},
    {petId = "hhdl", price = 150, attack = 60, health = 300, speed = 15},
    {petId = "njks", price = 150, attack = 60, health = 300, speed = 15},
    {petId = "hrdh", price = 150, attack = 60, health = 300, speed = 15},
    {petId = "nhym", price = 200, attack = 80, health = 400, speed = 20},
    {petId = "nmed", price = 200, attack = 80, health = 400, speed = 20},
    {petId = "nhea", price = 200, attack = 80, health = 400, speed = 20},
    {petId = "nhem", price = 200, attack = 80, health = 400, speed = 20},
    {petId = "nhef", price = 200, attack = 80, health = 400, speed = 20},
    {petId = "nemi", price = 250, attack = 100, health = 500, speed = 25},
    {petId = "hcth", price = 250, attack = 100, health = 500, speed = 25},
    {petId = "hhes", price = 250, attack = 100, health = 500, speed = 25},
    {petId = "ogrk", price = 250, attack = 100, health = 500, speed = 25},
    {petId = "nw2w", price = 250, attack = 100, health = 500, speed = 25}
}

local spell = {
    [20] = "Agj1",
    [40] = "Agj2",
    [60] = "Agj3",
    [80] = "Agj4",
    [100] = "Agj5"
}

local SellerController = Observer:new()

local npcs = {}
local npcTags = {}

local pets = {}
local petsUnit = {}
local petTags = {}

local teams = {}

local sellArea = Rect:fromUd(gg_rct_sellarea)
local petsArea = Rect:fromUd(gg_rct_petsarea)

local selectedSellUnit
local selectedPetUnit
local petTrigger

---getPosition
---@param rt Rect
---@param col integer
---@param count integer
---@return float, float, float, float
local function getPosition(rt, col, count)
    local minX = rt:getMinX()
    local minY = rt:getMinY()

    local width = rt:getMaxX() - minX
    local height = rt:getMaxY() - minY

    local padX = math.floor(width / col)
    local padY = math.floor(height / math.ceil(count * 1.0 / col))

    return minX, minY, padX, padY
end

local function getData(id)
    for i, v in ipairs(data) do
        if FourCC(v.petId) == id then
            return v
        end
    end
end

function SellerController.updatePet()
    local ok, res = Common.Request("pets")
    if ok then
        for i, v in ipairs(res.pets) do
            if npcs[v] then
                ---@type TextTag
                local tag = npcTags[npcs[v]]
                tag:setText("已拥有", 9 * 0.0023)
                tag:setColor(0, 255, 0, 100)
                ---@type Unit
                local u = pets[v]
                if not u then
                    u = Unit:create(Player:get(0), v, 0, 0, 250)
                    u:setUserData(v)
                    u:pauseEx(true)

                    local d = getData(v)
                    u:addAbility(FourCC(spell[d.attack]))

                    pets[v] = u
                    table.insert(petsUnit, u)
                    petTrigger:registerUnitEvent(u, UnitEvent.Selected)

                    local tag = TextTag:create()
                    tag:setPermanent(true)
                    tag:setText("出战", 9 * 0.0023)
                    tag:setVisibility(false)
                    petTags[u] = tag
                end
            end
        end

        local col = 5
        local minX, minY, padX, padY = getPosition(petsArea, col, #petsUnit)

        minX = minX + 150
        local x = minX
        local y = minY + 150

        local i = 1
        ---@param u Unit
        for i, u in ipairs(petsUnit) do
            u:setPosition(x, y)

            if teams[u:getUserData()] ~= nil then
                petTags[u]:setVisibility(true)
                petTags[u]:setPos(x - 50, y - 50, 0)
            else
                petTags[u]:setVisibility(false)
            end

            if i % col == 0 then
                x = minX
                y = y + padY
            else
                x = x + padX
            end
            i = i + 1
        end
    else
        print(res)
    end
end

function SellerController.updateTeam()
    local ok, res = Common.Request("team")
    if ok then
        teams = {}
        for i, v in ipairs(res.team) do
            if npcs[v] then
                teams[i] = v
                teams[v] = i
            end
        end
    else
        print(res)
    end
end

function SellerController.updateSellArea()
    local trig = Trigger:create()
    trig:addAction(SellerController.buy)

    local col = 5
    local minX, minY, padX, padY = getPosition(sellArea, col, #data)

    minX = minX + 150
    local x = minX
    local y = minY + 150

    local i = 1
    for i, v in ipairs(data) do
        local uid = FourCC(v.petId)
        local u = Unit:create(Player:get(Native.GetBJPlayerNeutralVictim()), uid, x, y, 250)
        u:setUserData(uid)
        u:setMaxHP(v.health)
        u:setState(UnitState.Life, v.health)
        u:setName(u:getName() .. string.format("（售价：%s金）", v.price))
        trig:registerUnitEvent(u, UnitEvent.Selected)
        npcs[uid] = u

        local tag = TextTag:create()
        tag:setPermanent(true)
        tag:setText("未拥有", 9 * 0.0023)
        tag:setPos(x - 50, y - 50, 0)
        tag:setVisibility(true)
        npcTags[u] = tag

        if i % col == 0 then
            x = minX
            y = y + padY
        else
            x = x + padX
        end
        i = i + 1
    end
end

function SellerController.buy()
    ---@type Unit
    local u = Unit:fromUd(Native.GetTriggerUnit())
    local pet = pets[u:getUserData()]
    selectedPetUnit = nil
    if not selectedSellUnit or selectedSellUnit ~= u then
        selectedSellUnit = u
        if pet then
            print("已拥有该宠物")
        else
            print("双击购买宠物")
        end
        return
    end
    if pet then
        print("已拥有该宠物，无法购买")
        return
    end
    local ok, res = Common.Request("pet_buy", "id=" .. u:getUserData())
    if ok then
        selectedSellUnit = nil
        SellerController.updatePet()
        SellerController:fireEvent(Events.GOLD_UPDATE)
    else
        print(res)
    end
end

function SellerController.petClick()
    selectedSellUnit = nil
    local u = Unit:fromUd(Native.GetTriggerUnit())
    local uid = u:getUserData()

    if selectedPetUnit ~= u then
        selectedPetUnit = u
        if teams[uid] ~= nil then
            print("双击取消出战")
        else
            print("双击设置出战")
        end
        return
    end

    if teams[uid] ~= nil then
        table.remove(teams, teams[uid])
    elseif #teams >= 3 then
        print("出战宠物不能大于三个")
        return
    else
        table.insert(teams, uid)
        teams[uid] = #teams
    end

    local ok, res = Common.Request("set_team", string.format("team=%s", table.concat(teams, ",")))
    if ok then
        selectedPetUnit = nil
        SellerController.updateTeam()
        SellerController.updatePet()
    else
        print(err)
    end
end

local function main()
    petTrigger = Trigger:create()
    petTrigger:addAction(SellerController.petClick)

    SellerController.updateSellArea()
    SellerController.updateTeam()
    SellerController.updatePet()
end

Timer:after(0.1, main)
