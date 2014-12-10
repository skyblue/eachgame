
-- -- DEBUG = DEBUG or 0
-- -- APPID = APPID or 1
-- -- if DEBUG == 0 then
-- --     CCLuaLoadChunksFromZip("res/game.zip")
-- -- end
require("app.config")
require("framework.init")
math.newrandomseed()
utils         = require("app.tools.utils")
require("app.tools.libext")
-- if device.platform == "android" then
--     luaj = require(cc.PACKAGE_NAME .. ".luaj")
-- elseif device.platform == "ios" then
    luaoc = require(cc.PACKAGE_NAME .. ".luaoc")
-- end
require("app.tools.update")


-- function __G__TRACKBACK__(errorMessage)
--     print("----------------------------------------")
--     print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
--     print(debug.traceback("", 2))
--     print("----------------------------------------")
-- end

-- require("app.MyApp").new():run()
