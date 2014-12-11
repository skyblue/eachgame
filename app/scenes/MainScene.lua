
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
    display.addSpriteFrames("img/common.plist","img/common.png")
    display.addSpriteFrames("img/poker.plist","img/poker.png")
    display.addSpriteFrames("img/chip.plist","img/chip.png")
    -- cc.ui.UILabel.new({
    --         UILabelType = 2, text = "Hello, World", size = 64})
    --     :align(display.CENTER, display.cx, display.cy)
    --     :addTo(self)
        Event         = require("app.net.Event")
        Event:init()
        Room = require("app.scenes.Room")
        display.replaceScene(Room.new(),"Fade",0.2)
    --     local url = CONFIG.API_URL .. "GameMember.load?"
    --     local request = network.createHTTPRequest(function(event)
    --         dump(event)
    --         if event.name == "completed" then
    --             dump(event.getResponseString())
    --         end
    -- end, url, "GET")

end
	
function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene
