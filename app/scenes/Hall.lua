local Hall = class("Hall", function()
    return display.newScene("Hall")
end)
local HallMenu = require("app.scenes.hall.HallMenu")


function Hall:ctor()
    self.parts ={}
	display.addSpriteFrames("img/hall.plist","img/hall.png")
	local bg = display.newSprite("img/hall-bg.png",display.cx,display.cy)
		:addTo(self)
    local menuBg = display.newSprite("#hall/menu-bg.png",display.cx,120)
        :addTo(self)
    if display.height > 960 then
        bg:setScale(display.height/960)
        menuBg:setScale(display.height/960)
    end
    local head = utils.makeAvatar({udata = USER,border = "#common/bolder.png",mask_choose = 1,size = cc.size(140, 140)})
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
            size = 45})
            :align(display.CENTER_LEFT,180,display.top - 50)
            :addTo(self)
    display.newSprite("#chip-red.png",200, display.top -  120)
		:addTo(self)      

    local uchips = cc.ui.UILabel.new({
            UILabelType = 2,
            text = USER.uchips,
            font = "Helvetica-Bold",
            color = cc.c3b(191,251,240),
            size = 38})
            :align(display.CENTER_LEFT,230,display.top - 115)
            :addTo(self)
    local hallMenu = HallMenu.new()
    self:addChild(hallMenu)
    self.parts["hallMenu"] = hallMenu
    SocketEvent:addEventListener(CMD.RSP_BUY .. "back", function(event)
        uchips:setString(USER.uchips .. "")
    end)
    SocketEvent:addEventListener(CMD.RSP_CHANGE_UNAME .. "back", function(event)
        uname:setString(USER.uname)
    end)
    SocketEvent:addEventListener(CMD.RSP_CHANGE_PIC .. "back", function(event)
        -- local key = crypto.md5(USER.upic)
        -- local save_path = device.writablePath.."/" .. key
        -- os.execute("rm " .. save_path)
        utils.loadRemote(head.pic,USER.upic)
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