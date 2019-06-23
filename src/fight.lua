local Common = require("common")
local co = require("co")
local bundle = co()

---@type Rect
local BattleCenter = Rect:fromUd(gg_rct_battlecenter)

---@type Rect[]
local unitPosition = {
    Rect:fromUd(gg_rct_bfFriend1),
    Rect:fromUd(gg_rct_bfFriend2),
    Rect:fromUd(gg_rct_bfFriend3),
    Rect:fromUd(gg_rct_bfEnemy1),
    Rect:fromUd(gg_rct_bfEnemy2),
    Rect:fromUd(gg_rct_bfEnemy3)
}

local FightController = Observer:new()
local fightData

local myPet = {}
local targetPet = {}
local currentAction = 1
local StartCountDown = TextTag:create()
---@type Timer
local worldUpdate
local worldUpdateInterval = 0.03
local skipRound = false

---@type TextTag
local worldTextTag = TextTag:create()
worldTextTag:setVisibility(false)
worldTextTag:setPos(BattleCenter:getCenterX(), BattleCenter:getCenterY(), 0)

local function showWorldText(rope, duration, text, r, g, b)
    r = r or 0
    g = g or 255
    b = b or 0
    worldTextTag:setColor(0, 255, 0, 1)
    worldTextTag:setVisibility(true)
    worldTextTag:setText(text, 15 * 0.0023)
    worldTextTag:setPos(BattleCenter:getCenterX() - #tostring(text) / 2.0 * 25, BattleCenter:getCenterY(), 0)
    rope:wait(duration)
    worldTextTag:setVisibility(false)
end

---@type Unit[]
local units = {}

---@class ReplyAttack
---@field source integer
---@field target integer

---@class ReplyDamage
---@field source integer
---@field damage integer

local stage = {
    Start = function(rope, ev)
        -- 对战开始
        Native.PanCameraToTimed(BattleCenter:getCenterX(), BattleCenter:getCenterY(), 1.0)
        rope:wait(1)
        showWorldText(rope, 1, "准备战斗")
        print(ev.type)
        for i = 2, 1, -1 do
            showWorldText(rope, 1, i)
        end
        showWorldText(rope, 1, "开始战斗")
        worldTextTag:setVisibility(false)
    end,
    Unit = function(rope, ev)
        -- 上场 team, petId, entityId
        local pos = unitPosition[ev.entityId]
        if not pos then
            print("单位位置错误")
            return
        end
        local isMy = ev.team == 1
        print(isMy)
        local u =
            Unit:create(Player:get(isMy and 0 or 1), ev.petId, pos:getCenterX(), pos:getCenterY(), isMy and 90 or 270)
        -- u:addAbility(FourCC('Aro1'))
        -- u:addAbility(FourCC('Avul'))
        local data = Common.getUnitData(ev.petId)
        u.hp = data.health
        u.abil = FourCC(Common.UnitSpell[data.attack])
        u:setMaxHP(data.health)
        u:setState(UnitState.Life, data.health)
        u:addAbility(u.abil)
        u:disableAbility(u.abil, true, false)
        u:pause(true)
        units[ev.entityId] = u
        -- rope:wait(2)
    end,
    Round = function(rope, ev)
        -- 回合数 round
        showWorldText(rope, 1, "第" .. ev.round .. "回合")
    end,
    ---@param ev ReplyAttack
    Attack = function(rope, ev)
        -- 攻击事件 source target

        local u = units[ev.source]
        local pos = unitPosition[ev.source]
        local t = units[ev.target]
        local isMy = ev.source <= 3

        u:setPosition(BattleCenter:getCenterX(), BattleCenter:getCenterY() + (isMy and -200 or 200))
        u:pause(false)
        u:disableAbility(u.abil, false, false)
        u:issueTargetOrder("chainlightning", t)
        rope:wait(0.5)

        u:pause(true)
        u:disableAbility(u.abil, true, false)
        u:setPosition(pos:getCenterX(), pos:getCenterY())
    end,
    ---@param ev ReplyDamage
    Damage = function(rope, ev)
        -- 受到伤害 source damage

        local u = units[ev.source]
        local hp = u.hp - ev.damage
        u.hp = hp
        u:setState(UnitState.Life, hp)
        rope:wait(1)
    end,
    Death = function(rope, ev)
        -- 死亡 source
        local u = units[ev.source]
        u:kill()
        rope:wait(0.5)
    end,
    End = function(rope, ev)
        local isWin = ev.winner == 1
        if isWin then
            showWorldText(rope, 3, "YOU WIN!")
        else
            showWorldText(rope, 3, "YOU LOSE!", 255, 0, 0)
        end
        for k, v in pairs(units) do
            v:remove()
        end
        units = {}
    end
}

local function startFight(rope)
    for i, v in ipairs(fightData) do
        if not skipRound or v.type == "End" then
            if stage[v.type] then
                stage[v.type](rope, v)
            end
        end
    end
    skipRound = false
end

local function startMatch()
    if worldUpdate then
        print("正在进行战斗")
        return
    end
    local ok, res = Common.Request("battle")
    if ok then
        fightData = res.battle

        bundle(
            function(rope)
                startFight(rope)
                worldUpdate:destroy()
                worldUpdate = nil
            end
        )

        worldUpdate = Timer:create()
        worldUpdate:start(
            worldUpdateInterval,
            true,
            function()
                bundle:update(worldUpdate:getElapsed())
            end
        )
    else
        print(res)
    end
end

local function main()
    FightController:registerEvent(Events.START_MATCH, startMatch)
    FightController:registerEvent(
        Events.SKIP_ROUND,
        function()
            skipRound = true
        end
    )
end

Timer:after(0.1, main)
