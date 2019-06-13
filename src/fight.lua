local Common = require("common")

---@type Rect
local BattleCenter = Rect:fromUd(gg_rct_battlecenter)

---@type Rect
local bfFriend1 = Rect:fromUd(gg_rct_bfFriend1)
---@type Rect
local bfFriend2 = Rect:fromUd(gg_rct_bfFriend2)
---@type Rect
local bfFriend3 = Rect:fromUd(gg_rct_bfFriend3)

---@type Rect
local bfEnemy1 = Rect:fromUd(gg_rct_bfEnemy1)
---@type Rect
local bfEnemy2 = Rect:fromUd(gg_rct_bfEnemy2)
---@type Rect
local bfEnemy3 = Rect:fromUd(gg_rct_bfEnemy3)

local FightController = Observer:new()
local fightData

local myPet = {}
local targetPet = {}
local currentAction = 1
local StartCountDown = TextTag:create()

local stage = {
    Start = function(ev)
        -- 对战开始
        print(ev.type)
        local countDown = 5
        local function startCountDown(count)
            if count >= 0 then
                Timer:after(1, startCountDown)
            else
            end
        end
    end,
    Unit = function(ev)
        -- 上场 team, petId, entityId
        print(ev.type)
    end,
    Round = function(ev)
        -- 回合数 round
        print(ev.type)
    end,
    Attack = function(ev)
        -- 攻击事件 source target
        print(ev.type)
    end,
    Damage = function(ev)
        -- 受到伤害 source damage
        print(ev.type)
    end,
    Death = function(ev)
        -- 死亡 source
        print(ev.type)
    end,
    End = function(ev)
        -- 胜利 winner
        print(ev.type)
    end
}

local function startFight()
    for i, v in ipairs(fightData) do
        if stage[v.type] then
            stage[v.type](v)
        end
    end
end

local function startMatch()
    local ok, res = Common.Request("battle")
    if ok then
        fightData = res.battle
        startFight()
    else
        print(res)
    end
end

local function main()
    FightController:registerEvent(Events.START_MATCH, startMatch)
end

Timer:after(0.1, main)
