
require('eventids')

local Common = require("common")

local function main()

    print("Welcom to War Of Pet!!!")

    Native.FogMaskEnable(false)
    Native.FogEnable(false)

    require('wage')
    require('seller')
    require('fight')

    
    Unit:create(Player:get(0), FourCC("Hpal"), -668.0, 150.0, 270.000):pause(true)

end

Timer:after(0.1, main)
