
local json = require("json")

local Common = {
    host = "http://192.168.101.55:9527"
}

function Common.Request(route, data)
    local res =
        Native.RequestExtraStringData(53, nil, string.format("%s/%s", Common.host, route), data or "", false, 0, 0, 0)
    print(res)
    local ok, res = pcall(json.decode, res)
    ok = ok and not res.error
    return ok, ok and res.body or res.message or res
end

return Common
