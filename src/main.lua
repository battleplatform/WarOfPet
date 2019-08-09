require("lib")

local Common = require('common')
Common.initMLS()

local function main(rope)
    print("Welcome to WarOfPet!!!")

    Native.FogMaskEnable(false)
    Native.FogEnable(false)

    Common.Connect()

    rope:wait(2)

    local result = Common.RequestAsync(rope, 'login', {userId = 1000245})

    print(result)

    require("eventids")

    require("wage")
    require("seller")
    require("fight")

    Timer:create():start(0.01, function()
        Native.SetCameraField(CameraField.TargetDistance, 2500.0, 0)
        Native.SetCameraField(CameraField.AngleOfAttack, -50.0, 0)
    end)
end

Timer:after(2, function()
    Common.bundle(main)
end)
