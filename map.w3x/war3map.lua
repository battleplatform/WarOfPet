gg_rct_sellarea = nil
gg_rct_petsarea = nil
gg_rct_bfFriend1 = nil
gg_rct_bfFriend2 = nil
gg_rct_bfFriend3 = nil
gg_rct_bfEnemy1 = nil
gg_rct_bfEnemy2 = nil
gg_rct_bfEnemy3 = nil
gg_rct_battlecenter = nil
function InitGlobals()
end

function CreateRegions()
    local we
    gg_rct_sellarea = Rect(-2144.0, 288.0, -672.0, 1376.0)
    gg_rct_petsarea = Rect(-2144.0, -1248.0, -640.0, -160.0)
    gg_rct_bfFriend1 = Rect(512.0, -480.0, 736.0, -288.0)
    gg_rct_bfFriend2 = Rect(896.0, -480.0, 1152.0, -288.0)
    gg_rct_bfFriend3 = Rect(1280.0, -480.0, 1536.0, -288.0)
    gg_rct_bfEnemy1 = Rect(1280.0, 544.0, 1536.0, 736.0)
    gg_rct_bfEnemy2 = Rect(896.0, 544.0, 1152.0, 736.0)
    gg_rct_bfEnemy3 = Rect(512.0, 544.0, 768.0, 736.0)
    gg_rct_battlecenter = Rect(1024.0, 96.0, 1056.0, 128.0)
end

function InitCustomPlayerSlots()
    SetPlayerStartLocation(Player(0), 0)
    SetPlayerColor(Player(0), ConvertPlayerColor(0))
    SetPlayerRacePreference(Player(0), RACE_PREF_HUMAN)
    SetPlayerRaceSelectable(Player(0), false)
    SetPlayerController(Player(0), MAP_CONTROL_USER)
    SetPlayerStartLocation(Player(1), 1)
    SetPlayerColor(Player(1), ConvertPlayerColor(1))
    SetPlayerRacePreference(Player(1), RACE_PREF_HUMAN)
    SetPlayerRaceSelectable(Player(1), false)
    SetPlayerController(Player(1), MAP_CONTROL_COMPUTER)
end

function InitCustomTeams()
    SetPlayerTeam(Player(0), 0)
    SetPlayerTeam(Player(1), 1)
end

function InitAllyPriorities()
    SetStartLocPrioCount(1, 1)
end

function main()
    SetCameraBounds(-3328.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), -3584.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 3328.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), 3072.0 - GetCameraMargin(CAMERA_MARGIN_TOP), -3328.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), 3072.0 - GetCameraMargin(CAMERA_MARGIN_TOP), 3328.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), -3584.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM))
    SetDayNightModels("Environment\\DNC\\DNCFelwood\\DNCFelwoodTerrain\\DNCFelwoodTerrain.mdl", "Environment\\DNC\\DNCFelwood\\DNCFelwoodUnit\\DNCFelwoodUnit.mdl")
    NewSoundEnvironment("lake")
    SetAmbientDaySound("LordaeronSummerDay")
    SetAmbientNightSound("LordaeronSummerNight")
    SetMapMusic("Music", true, 0)
    CreateRegions()
    InitBlizzard()
    InitGlobals()
end

function config()
    SetMapName("TRIGSTR_001")
    SetMapDescription("")
    SetPlayers(2)
    SetTeams(2)
    SetGamePlacement(MAP_PLACEMENT_USE_MAP_SETTINGS)
    DefineStartLocation(0, -128.0, 128.0)
    DefineStartLocation(1, -128.0, 128.0)
    InitCustomPlayerSlots()
    InitCustomTeams()
    InitAllyPriorities()
end

