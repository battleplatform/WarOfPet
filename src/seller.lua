local Common = require("common")

local data = {
    "hpea",
    "hfoo",
    "hkni",
    "hrif",
    "hmtm",
    "hmpr",
    "hsor",
    "hmtt",
    "hspt",
    "nbee",
    "nbel",
    "nchp",
    "hhdl",
    "njks",
    "hrdh",
    "nhym",
    "nmed",
    "nhea",
    "nhem",
    "nhef",
    "nemi",
    "hcth",
    "hhes"
}

local SellerController = Observer:new()

local npcs = {}
local pets = {}
local petsUnit = {}

local sellArea = Rect:fromUd(gg_rct_sellarea)
local petsArea = Rect:fromUd(gg_rct_petsarea)

local selectedSellUnit
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

function SellerController.updatePet()
    local ok, res = Common.Request("pets")
    if ok then
        for i, v in ipairs(res.pets) do
            if npcs[v] then
                local u = pets[v]
                if not u then
                    u = Unit:create(Player:get(0), v, 0, 0, 250)
                    u:setUserData(v)
                    pets[v] = u
                    table.insert(petsUnit, u)
                    petTrigger:registerUnitEvent(u, UnitEvent.Selected)
                end
            end
        end

        local col = 5
        local minX, minY, padX, padY = getPosition(petsArea, col, #data)

        minX = minX + 150
        local x = minX
        local y = minY + 150

        local i = 1
        ---@param u Unit
        for i, u in ipairs(petsUnit) do
            u:setPosition(x, y)
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
        local uid = FourCC(v)
        local u = Unit:create(Player:get(Native.GetBJPlayerNeutralVictim()), uid, x, y, 250)
        u:setUserData(uid)
        trig:registerUnitEvent(u, UnitEvent.Selected)
        npcs[uid] = u

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
        SellerController.updatePet()
        SellerController:fireEvent(Events.GOLD_UPDATE)
    else
        print(res)
    end
end

function SellerController.petClick()
    selectedSellUnit = nil
end

local function main()
    petTrigger = Trigger:create()
    petTrigger:addAction(SellerController.petClick)

    SellerController.updateSellArea()
    SellerController.updatePet()
end

Timer:after(0.1, main)
