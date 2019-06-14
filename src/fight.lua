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
    Rect:fromUd(gg_rct_bfEnemy3),
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

---@type Unit[]
local units = {}

local stage = {
    Start = function(rope, ev)
        -- 对战开始
        Native.PanCameraToTimed(BattleCenter:getCenterX(), BattleCenter:getCenterY(), 1.0)
        rope:wait(1)
        local tag = TextTag:create()
        tag:setColor(0, 255, 0, 1)
        tag:setPos(BattleCenter:getCenterX(), BattleCenter:getCenterY(), 0)
        tag:setVisibility(true)
        tag:setText("准备战斗", 15 * 0.0023)
        rope:wait(1)
        print(ev.type)
        for i = 5, 1, -1 do
            tag:setText(i, 15 * 0.0023)
            rope:wait(1)
        end
        tag:setText("开始战斗", 15 * 0.0023)
        tag:setVisibility(false)
        tag:destroy()
    end,
    Unit = function(rope, ev)
        -- 上场 team, petId, entityId
        local pos = unitPosition[ev.entityId]
        if not pos then
            print("单位位置错误")
            return
        end
        local isMy = ev.team == 1
        local u = Unit:create(Player:get(isMy and 0 or 1), ev.petId, pos:getCenterX(), pos:getCenterY(), isMy and 90 or 270)
        u:pauseEx(true)
        local data = Common.getUnitData(ev.petId)
        u:setMaxHP(data.health)
        u:setState(UnitState.Life, data.health)
        u:addAbility(FourCC(Common.UnitSpell[data.attack]))
        units[ev.entityId] = u
        rope:wait(2)
    end,
    Round = function(rope, ev)
        -- 回合数 round
    end,
    Attack = function(rope, ev)
        -- 攻击事件 source target
    end,
    Damage = function(rope, ev)
        -- 受到伤害 source damage
    end,
    Death = function(rope, ev)
        -- 死亡 source
    end,
    End = function(rope, ev)
        -- 胜利 winner
    end
}

local function startFight(rope)
    for i, v in ipairs(fightData) do
        if stage[v.type] then
            stage[v.type](rope, v)
        end
    end
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
end

Timer:after(0.1, main)
