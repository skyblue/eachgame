
require("app.config")
require("framework.init")

local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
end

function MyApp:run()
	-- if device.platform == "android" then
	--     luaj = require(cc.PACKAGE_NAME .. ".luaj")
	-- elseif device.platform == "ios" then
	--     luaoc = require(cc.PACKAGE_NAME .. ".luaoc")
	-- end

   

    -- device.deviceID = "2014-16-20-14:16:07-5433569"

    -- device.deviceID = "2014-01-19-19:01:57-62151587"

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

    Store = require("framework.cc.sdk.Store")

    _.ParseSocket = ParseSocket.new()
    
    _.Loading = Loading:new()
    display.replaceScene(_.Loading)
    -- self:enterScene("Room")
    -- self:enterScene("Hall")

    SocketEvent:addEventListener(CMD.RSP_GAME_SERVER .. "back", function(event)
        if _.Loading then
            _.Loading:hide()
        end
        _.Hall = Hall.new()
        display.replaceScene(_.Hall)
        SocketEvent:removeEventListenersByEvent(CMD.RSP_GAME_SERVER .. "back")
        if checkint(USER.tid) > 0 then
            SendCMD.toGame(USER.tid)
        end

        SendCMD:getShoplist()
        MyStore.initStore()
        SocketEvent:addEventListener(CMD.RSP_SHOPLIST .. "back", function(event)
            SocketEvent:removeEventListenersByEvent(CMD.RSP_SHOPLIST .. "back")
            MyStore.products = {}
            MyStore.data = event.data
            MyStore.loadProducts(MyStore.data)
        end)
        
    end)
    

end

return MyApp
