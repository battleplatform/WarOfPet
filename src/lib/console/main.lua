require("lib.oop")
require("lib.oop.enum")

local Native = require("lib.native.native")

---@type Frame
local console
---@type Frame
local consoleEditBox
---@type Frame
local consoleTextArea

---@type boolean
local consoleShow = false

---@type Trigger
local consoleTrig

local function Toggle(forceHide)
    if forceHide then
        if not consoleShow then
            return
        end
        consoleShow = true
    end
    if console then
        consoleShow = not consoleShow
        console:setVisible(consoleShow)
        consoleEditBox:setFocus(consoleShow)
    end
end

local function OnShortcuts()
    if Native.GetTriggerPlayer() ~= Native.GetLocalPlayer() then
        return
    end
    Toggle(false)
end

local function OnShortcutsHide()
    if Native.GetTriggerPlayer() ~= Native.GetLocalPlayer() then
        return
    end
    Toggle(true)
end

local function InitShortcuts()
    local trigShow = Trigger:create()
    trigShow:addAction(OnShortcuts)

    local trigHide = Trigger:create()
    trigHide:addAction(OnShortcutsHide)

    for i = 0, 23 do
        trigShow:registerPlayerKeyEvent(Player:get(i), OsKeyType.F1, 4, true)
        trigHide:registerPlayerKeyEvent(Player:get(i), OsKeyType.Escape, 0, true)
    end
end

local orgPring = print
local function AddText(text)
    if consoleTextArea then
        consoleTextArea:addText(text)
    else
        orgPring(text)
    end
end

_G.print = function(...)
    AddText(table.concat({...}, " "))
end

local function OnEditBoxEnter()
    local script = Native.BlzGetTriggerFrameText()
    if not script or script == "" then
        return
    end

    local f, err = load(script)
    if not f then
        AddText(err)
        return
    end
    local ok, r = pcall(f)
    if not ok then
        AddText(r)
        return
    end
    consoleEditBox:setFocus(true)
    consoleEditBox:setText("")
end

local function Init()
    if not Native.BlzLoadTOCFile("UI\\_console.toc") then
        print("|cffff0000Load console toc failed|r")
        return
    end

    local gameui = Frame:getOrigin(OriginFrameType.GameUi, 0)

    console = Frame:create("__console", gameui, 10, 0)
    if not console then
        print("|cffff0000Create console failed|r")
        return
    end

    console:setVisible(false)
    console:setPoint(FramePointType.Topleft, gameui, FramePointType.Topleft, 0, 0)
    console:setPoint(FramePointType.Topright, gameui, FramePointType.Topright, 0, 0)

    -- events
    consoleEditBox = Frame:getByName("__consoleEditBox", 0)

    consoleTrig = Trigger:create()
    consoleTrig:registerFrameEvent(consoleEditBox, FrameEventType.EditboxEnter)
    consoleTrig:addAction(OnEditBoxEnter)

    consoleTextArea = Frame:getByName("__consoleTextArea", 0)

    InitShortcuts()
end

local function main()
    print("|cff00ff00Console Loaded!!!|r press |cffff0000Alt+F12|r to toggle")
    Init()
end

main()
