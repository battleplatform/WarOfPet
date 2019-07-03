local json = require("json")
local Event = require('lib.stdlib.oop.event')
local co = require("co")

local Common = {host = "http://192.168.112.85:9527", mls = true}
Common.bundle = co()

function Common.Request(route, data)
    local res = Native.RequestExtraStringData(53, nil, string.format("%s/%s?%s", Common.host, route, data or ""), "",
                                              false, 0, 0, 0)
    -- print(res, data)
    local ok, res = pcall(json.decode, res)
    ok = ok and not res.error
    return ok, ok and res.body or res.message or res
end

local mlsCallId = {}
local callId = 0
local mlsTimeout = 5
local function onMLS()
    local ok, res = pcall(json.decode, Event:getTriggerSyncData())
    if not ok or not res or not res.callId then
        print('invalid mls message, ', Event:getTriggerSyncData(), res)
        return
    end

    local t = mlsCallId[res.callId]
    t.result = res
    t.ok = ok and not res.error
    t.rope:signal(res.callId)
end

function Common.initMLS()
    if not Common.mls then
        return
    end

    local t = Trigger:create()
    t:registerPlayerSyncEvent(Player:get(0), 'MLSP', true)
    t:addAction(onMLS)

    local t = Timer:create()
    Common.ts = 0
    t:start(0.03, function()
        Common.ts = Common.ts + t:getElapsed()
        Common.bundle:update(t:getElapsed())
        for k, v in pairs(mlsCallId) do
            if Common.ts - v.ts > mlsTimeout then
                v.ok = false
                v.result = 'timeout'
                Common.bundle:resume(v.rope)
            end
        end
    end)
end

function Common.RequestAsync(rope, route, data)
    local id = callId
    local t = {route = route, data = data, callId = id}
    mlsCallId[id] = t
    callId = callId + 1
    Native.RequestExtraBooleanData(53, Player:get(0):getUd(), json.encode(t), '', false, 0, 0, 0)
    mlsCallId[id].rope = rope
    mlsCallId[id].ts = Common.ts
    rope:listen(id)
    t = mlsCallId[id]
    mlsCallId[id] = nil
    return t.ok, t.ok and t.result.body or t.result.message or t.result
end

---@class UnitData
---@field petId string
---@field price integer
---@field attack integer
---@field health integer
---@field speed integer
Common.UnitData = {
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
    {petId = "nw2w", price = 250, attack = 100, health = 500, speed = 25},
}

Common.UnitSpell = {[20] = "Agj1", [40] = "Agj2", [60] = "Agj3", [80] = "Agj4", [100] = "Agj5"}

---@return UnitData
function Common.getUnitData(id)
    for i, v in ipairs(Common.UnitData) do
        if FourCC(v.petId) == id then
            return v
        end
    end
end

return Common
