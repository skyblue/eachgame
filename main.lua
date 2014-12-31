
function __G__TRACKBACK__(errorMessage)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
    print(debug.traceback("", 2))
    print("----------------------------------------")
end

package.path = package.path .. ";src/"
cc.FileUtils:getInstance():setPopupNotify(false)
require("app.MyApp").new():run()


-- require("app.config")
-- require("cocos.init")
-- require("framework.init")

-- math.newrandomseed()
-- utils         = require("app.tools.utils")
-- require("app.tools.libext")
-- if device.platform == "android" then
--     luaj = require(cc.PACKAGE_NAME .. ".luaj")
-- elseif device.platform == "ios" then
--     luaoc = require(cc.PACKAGE_NAME .. ".luaoc")
-- end

-- package.path = package.path .. ";src/"
-- cc.FileUtils:getInstance():setPopupNotify(false)
-- require("app.tools.update")