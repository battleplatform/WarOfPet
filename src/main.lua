
require('lib')

local function main()

    print("Welcome to WarOfPet!!!")

    Native.FogMaskEnable(false)
    Native.FogEnable(false)

    require('eventids')

    dofile('wage.lua')
    dofile('seller.lua')
    dofile('fight.lua')


    Unit:create(Player:get(0), FourCC("Hpal"), -668.0, 150.0, 270.000):pause(true)

end

Timer:after(2, main)
