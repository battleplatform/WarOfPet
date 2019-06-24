require("lib")

local function main()
    print("Welcome to WarOfPet!!!")

    Native.FogMaskEnable(false)
    Native.FogEnable(false)

    require("eventids")

    require("wage")
    require("seller")
    require("fight")

    Timer:create():start(
        0.01,
        true,
        function()
            Native.SetCameraField(CameraField.TargetDistance, 2500.0, 0)
            Native.SetCameraField(CameraField.AngleOfAttack, -50.0, 0)
        end
    )
end

Timer:after(2, main)
