local Hall = class("Hall", function()
    return display.newScene("Hall")
end)
local HallMenu = require("app.scenes.hall.HallMenu")


function Hall:ctor()
    self.parts ={}
	display.addSpriteFrames("img/hall.plist","img/hall.png")
	local bg = display.newSprite("img/hall-bg.png",display.cx,display.cy)
		:addTo(self)
    if display.height > 960 then
        bg:setScale(display.height/960)
    end
    local head = utils.makeAvatar({border = "#hall/head-bg.png",mask_choose = 1,size = cc.size(140, 140),callback = function(succ, texture, sprite)
        if not succ then return end
        scheduler.performWithDelayGlobal(function()
            if not sprite or tolua.isnull(sprite) then return end
            local opacity = sprite:getOpacity()
            sprite:stopAllActions()
            opacity = opacity or 255
            sprite:setOpacity(20)
            sprite:setTexture(texture)
            transition.fadeTo(sprite,{
                time = 0.2,
                opacity = opacity
            })
        end, 0.5)
    end})
    head:setPosition(90, display.top -  90)
    head:addTo(self)

    head:addNodeEventListener(cc.NODE_TOUCH_EVENT,function ( event )
        utils.playSound("click")
        if _.UserInfo == nil or tolua.isnull(_.UserInfo) then 
            _.UserInfo = UserInfo.new():addTo(self)
        end
        _.UserInfo:show(USER)
    end)
    head:setTouchEnabled(true)

	local uname = cc.ui.UILabel.new({
            UILabelType = 2,
            text = USER.uname,
            font = "Helvetica-Bold",
            size = 30})
            :align(display.CENTER,225,display.top - 50)
            :addTo(self)
    display.newSprite("#hall/dollar.png",180, display.top -  100)
		:addTo(self)      
    local uchips = cc.ui.UILabel.new({
            UILabelType = 2,
            text = USER.uchips,
            font = "Helvetica-Bold",
            color = cc.c3b(254,221,70),
            size = 30})
            :align(display.CENTER,270,display.top - 100)
            :addTo(self)
    local hallMenu = HallMenu.new()
    self:addChild(hallMenu)
    self.parts["hallMenu"] = hallMenu
    SocketEvent:addEventListener(CMD.RSP_BUY .. "back", function(event)
        uchips:setString(USER.uchips .. "")
    end)
    SocketEvent:addEventListener(CMD.RSP_CHANGE_UNAME .. "back", function(event)
        uname:setString(USER.uname .. "")
    end)
    utils.playMusic("bg",true)
end

function Hall:exit()
    SocketEvent:removeEventListenersByEvent(CMD.RSP_BUY .. "back")
    SocketEvent:removeEventListenersByEvent(CMD.RSP_CHANGE_UNAME .. "back")
    SocketEvent:removeEventListenersByEvent(CMD.RSP_BUY .. "back")
	display.removeSpriteFrameByImageName("img/hall-bg.png")
	display.removeSpriteFramesWithFile("img/hall.plist","img/hall.png")
    self.parts["hallMenu"]:exit()
    _.Hall = nil
end


return Hall