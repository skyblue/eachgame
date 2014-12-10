
require("app.config")
require("framework.init")

local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
end

function MyApp:run()
	if device.platform == "android" then
	    luaj = require(cc.PACKAGE_NAME .. ".luaj")
	elseif device.platform == "ios" then
	    luaoc = require(cc.PACKAGE_NAME .. ".luaoc")
	end
    cc.FileUtils:getInstance():addSearchPath("res/")
    display.addSpriteFrames("img/common.plist","img/common.png")
    display.addSpriteFrames("img/poker.plist","img/poker.png")
    display.addSpriteFrames("img/chip.plist","img/chip.png")
    scheduler = require("framework.scheduler")
    -- Analytics       = require("app.net.analytics")
    ParseSocket     = require("app.net.ParseSocket")

    Chat            = require("app.scenes.room.Chat")
    Card            = require("app.scenes.room.Card")
    Chip            = require("app.scenes.room.Chip")
    Hall            = require("app.scenes.Hall")   
    Room            = require("app.scenes.Room")
    SelectRoom      = require("app.scenes.SelectRoom")
    Login           = require("app.scenes.Login")

    UserInfo        = require("app.common.UserInfo")
    MyStore         = require("app.common.MyStore")
    Loading         = require("app.common.Loading")

    LANG            = require("app.tools.lang")

    _.ParseSocket = ParseSocket.new()
    
self:enterScene("SelectRoom")
-- 
-- self:enterScene("Hall")

    -- self:enterScene("Login")
    SocketEvent:addEventListener(CMD.RSP_GAME_SERVER .. "back", function(event)
        _.Hall = Hall.new()
        display.replaceScene(_.Hall)
        -- self:enterScene("Hall")
        SocketEvent:removeEventListenersByEvent(CMD.RSP_GAME_SERVER .. "back")
    end)

    
end

return MyApp
