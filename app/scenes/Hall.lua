local Hall = class("Hall", function()
    return display.newScene("Hall")
end)
local HallMenu = require("app.scenes.hall.HallMenu")


function Hall:ctor()
    self.parts ={}
	display.addSpriteFrames("img/hall.plist","img/hall.png")
	display.newSprite("img/hall-bg.png",display.cx,display.cy)
		:addTo(self)
	local headBg = display.newSprite("#hall/head-bg.png",81, display.top -  81)
		:addTo(self)
     
    local head = utils.makeAvatar(nil,cc.size(136, 136),120,nil,1)
    head:setPosition(68, 68)
    headBg:addChild(head)

    headBg:addNodeEventListener(cc.NODE_TOUCH_EVENT,function ( event )
        if not _.UserInfo then
            _.UserInfo = UserInfo.new():addTo(self)
        end
        _.UserInfo:show(USER)
    end)
    headBg:setTouchEnabled(true)

	 cc.ui.UILabel.new({
            UILabelType = 2,
            text = USER.uname,
            font = "Helvetica-Bold",
            size = 30})
            :align(display.CENTER,205,display.top - 50)
            :addTo(self)
    display.newSprite("#hall/dollar.png",180, display.top -  100)
		:addTo(self)      
    cc.ui.UILabel.new({
            UILabelType = 2,
            text = USER.uchips,
            font = "Helvetica-Bold",
            color = cc.c3b(254,221,70),
            size = 30})
            :align(display.CENTER,250,display.top - 100)
            :addTo(self)
    local hallMenu = HallMenu.new()
    self:addChild(hallMenu)
    self.parts["hallMenu"] = hallMenu
    -- UserInfo.new():addTo(self)

end

function Hall:exit()
	display.removeSpriteFrameByImageName("img/hall-bg.png")
	display.removeSpriteFramesWithFile("img/hall.plist","img/hall.png")
    self.parts["hallMenu"]:exit()
    _.Hall = nil
end


return Hall