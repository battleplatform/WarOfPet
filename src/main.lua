
local Common = require("common")

local function main()

    print("Welcom to War Of Pet!!!")

    require('wage')

    
    Unit:create(Player:get(0), FourCC("Hpal"), -668.0, 150.0, 270.000)

end

Timer:after(0.1, main)
