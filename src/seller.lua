local Common = require("common")

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

local function getPets(data, _rope)
    if data then
        return true, {pets = data}
    end
    if _rope then
        return Common.RequestAsync(_rope, "pets")
    end
    return Common.Request("pets")
end

function SellerController.updatePet(data, _rope)
    local ok, res = getPets(data, _rope)

    if ok then
        for i, v in ipairs(res.pets) do
            if npcs[v] then
                ---@type TextTag
                local tag = npcTags[npcs[v]]
                tag:setText("已拥有", 9 * 0.0023)
                tag:setColor(0, 255, 0, 100)
                tag:setVisibility(true)
                ---@type Unit
                local u = pets[v]
                if not u then
                    u = Unit:create(Player:get(0), v, 0, 0, 250)
                    u:setUserData(v)
                    u:pauseEx(true)
                    local d = Common.getUnitData(v)
                    u:setMaxHP(d.health)
                    u:setState(UnitState.Life, d.health)

                    u:addAbility(FourCC(Common.UnitSpell[d.attack]))

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
        for _, u in ipairs(petsUnit) do
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

function SellerController.updateTeam(_rope)
    local ok, res
    if _rope then
        ok, res = Common.RequestAsync(_rope, "team")
    else
        ok, res = Common.Request("team")
    end
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
    -- trig:addAction(SellerController.buy)

    local col = 5
    local minX, minY, padX, padY = getPosition(sellArea, col, #Common.UnitData)

    minX = minX + 150
    local x = minX
    local y = minY + 150

    local i = 1
    for _, v in ipairs(Common.UnitData) do
        local uid = FourCC(v.petId)
        local u = Unit:create(Player:get(Native.GetBJPlayerNeutralVictim()), uid, x, y, 250)
        u:setUserData(uid)
        u:setMaxHP(v.health)
        u:setState(UnitState.Life, v.health)
        -- u:setName(u:getName() .. string.format("（售价：%s金）", v.price))
        trig:registerUnitEvent(u, UnitEvent.Selected)
        npcs[uid] = u

        local tag = TextTag:create()
        tag:setPermanent(true)
        tag:setText("未拥有", 9 * 0.0023)
        tag:setPos(x - 50, y - 50, 0)
        tag:setVisibility(false)
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
        if not pet then
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

function SellerController.lottery(_rope)
    local ok, res
    if _rope then
        ok, res = Common.RequestAsync(_rope, "pet_lottery")
    else
        ok, res = Common.Request("pet_lottery")
    end
    if ok then
        local u = npcs[res.petId]
        if u then
            local msg = Dialog:create()
            msg:addButton("确定", 0)
            msg:setMessage(string.format("恭喜获得宠物 %s", u:getName()))
            Player:get(0):dialogDisplay(msg, true)
            local trig = Trigger:create()
            trig:addAction(function()
                trig:delete()
                Player:get(0):dialogDisplay(msg, false)
                msg:delete()
            end)
            trig:registerDialogEvent(msg)
        end
        SellerController.updatePet(res.pets)
        SellerController:fireEvent(Events.GOLD_UPDATE)
    else
        print(res)
    end
end

function SellerController.petClick(_rope)
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

    local ok, res
    if _rope then
        ok, res = Common.RequestAsync(_rope, "set_team", string.format("team=%s", table.concat(teams, ",")))
    else
        ok, res = Common.Request("set_team", string.format("team=%s", table.concat(teams, ",")))
    end

    if ok then
        selectedPetUnit = nil
        SellerController.updateTeam(_rope)
        SellerController.updatePet(_rope)
    else
        print(err)
    end
end

local function main(_rope)
    petTrigger = Trigger:create()
    if Common.mls then
        petTrigger:addAction(function()
            Common.bundle(SellerController.petClick)
        end)
        SellerController:registerEvent(Events.LOTTERY, function()
            Common.bundle(SellerController.lottery)
        end)
    else
        petTrigger:addAction(SellerController.petClick)
        SellerController.updateTeam()
        SellerController.updatePet()
        SellerController:registerEvent(Events.LOTTERY, SellerController.lottery)
    end

    SellerController.updateSellArea()
    SellerController.updateTeam(_rope)
    SellerController.updatePet(nil, _rope)

end

Timer:after(0.1, function()
    if Common.mls then
        Common.bundle(main)
    else
        main()
    end
end)
