local Native = require("lib.native.native")
local console
local consoleEditBox
local consoleShow = false
local consoleTrig
local consoleTextArea

local function Toggle(forceHide)
    if forceHide then
        if not consoleShow then
            return
        end
        consoleShow = true
    end
    if console then
        consoleShow = not consoleShow
        Native.BlzFrameSetVisible(console, consoleShow)
        Native.BlzFrameSetFocus(consoleEditBox, consoleShow)
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
    local showTrigger = Native.CreateTrigger()
    Native.TriggerAddAction(showTrigger, OnShortcuts)
    local hideTrigger = Native.CreateTrigger()
    Native.TriggerAddAction(hideTrigger, OnShortcutsHide)
    for i = 0, 23 do
        Native.BlzTriggerRegisterPlayerKeyEvent(showTrigger, Native.Player(i), Native.OSKEY_F1, 4, true)
        Native.BlzTriggerRegisterPlayerKeyEvent(hideTrigger, Native.Player(i), Native.OSKEY_ESCAPE, 0, true)
    end
end

local function AddText(text)
    if consoleTextArea then
        Native.BlzFrameSetText(consoleTextArea, text)
    end
end

local function OnEditBoxEnter()
    local txt = Native.BlzFrameGetText(consoleEditBox)
    if not txt or txt == "" then
        return
    end
    if not string.endswith(txt, ";", true) then
        return
    end
    local script = string.sub(txt, 0, string.len(txt) - 1)
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
    Native.BlzFrameSetFocus(consoleEditBox, true)
    Native.BlzFrameSetText(consoleEditBox, "")
end

local function Init()
    if not Native.BlzLoadTOCFile("UI\\DzConsole.toc") then
        print("Load toc failed")
        return
    end

    local gameui = Native.BlzGetOriginFrame(Native.ORIGIN_FRAME_GAME_UI, 0)
    console = Native.BlzCreateFrame("DzConsole", gameui, 10, 0)
    if console then
        -- hide && position
        Native.BlzFrameSetVisible(console, false)
        Native.BlzFrameSetPoint(console, Native.FRAMEPOINT_TOPLEFT, gameui, Native.FRAMEPOINT_TOPLEFT, 0, 0)
        Native.BlzFrameSetPoint(console, Native.FRAMEPOINT_TOPRIGHT, gameui, Native.FRAMEPOINT_TOPRIGHT, 0, 0)

        -- events
        consoleEditBox = Native.BlzGetFrameByName("DzConsoleEditBox", 0)
        consoleTrig = Native.CreateTrigger()
        Native.TriggerAddAction(consoleTrig, OnEditBoxEnter)
        Native.BlzTriggerRegisterFrameEvent(consoleTrig, consoleEditBox, Native.FRAMEEVENT_EDITBOX_TEXT_CHANGED)

        consoleTextArea = Native.BlzGetFrameByName('DzConsoleTextArea', 0)

        InitShortcuts()
    end
end

local function main()
    print("console main")
    Init()
end

main()
