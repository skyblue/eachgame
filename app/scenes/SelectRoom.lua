local SelectRoom = class("SelectRoom", function()
    return display.newScene("SelectRoom")
end)

function SelectRoom:ctor()
	display.addSpriteFrames("img/selectroom.plist","img/selectroom.png")
	self.parts={}
    display.newSprite("img/select-room-bg.png",display.cx,display.cy)
    :addTo(self)
    SocketEvent:addEventListener(CMD.RSP_IN_TABLE .. "back", function(event)
        dump(event.data)
        _.Room = Room.new()
        _.Room:initRoomWithData(event.data)
        display.replaceScene(_.Room)
    end)
	cc.ui.UIPushButton.new("#selectroom/back.png")
            :setButtonLabel(cc.ui.UILabel.new({
                    text = "返回", 
                    size = 42, 
                    font = "Helvetica",
                    align = cc.ui.TEXT_ALIGN_RIGHT,
                    color = cc.c3b(216,186,108),
                    })
                    )
            :setButtonLabelOffset(30,13)
            :align(display.LEFT_CENTER,10,display.top-62)
            :onButtonPressed(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,-128,-128,-128))
            end)
            :onButtonRelease(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,255,255,255))
            end)
            :onButtonClicked(function (event)
                    self:exit()
                    _.Hall = Hall.new()
                    display.replaceScene(_.Hall)
            end)
            :addTo(self)   
    local startX,xx = 320,0
    local item 
    for i,v in ipairs(CONFIG.selectRoom) do
    	item = display.newSprite("#selectroom/Light_"..i..".png",startX + (i-1)*530,display.cy-10)
    	:addTo(self)
        if i == 3 or i == 1 then
            xx = 30
        end
    	cc.ui.UIPushButton.new("#selectroom/MM"..i..".png")
            :align(display.LEFT_CENTER,xx,360)
            :onButtonPressed(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,-128,-128,-128))
            end)
            :onButtonRelease(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,255,255,255))
            end)
            :onButtonClicked(function (event)
                    SendCMD:toGame(0,1)
            end)
            :addTo(item)  
        cc.ui.UILabel.new({
            UILabelType = 2,
            text = v.name,
            font = "Helvetica-Bold",
            -- color = cc.c3b(255,255,255),
            size = 50})
            :align(display.LEFT_CENTER,180,140)
            :addTo(item)
        cc.ui.UILabel.new({
            UILabelType = 2,
            text = "盲注：" .. v.min_b .."——"..v.max_b,
            size = 30})
            :align(display.LEFT_CENTER,180,60)
            :addTo(item)
        cc.ui.UILabel.new({
            UILabelType = 2,
            text = "带入筹码："..v.min_buying.."——"..v.max_buying,
            size = 30})
            :align(display.LEFT_CENTER,180,0)
            :addTo(item)
    end
end

function SelectRoom:exit()
    display.removeSpriteFrameByImageName("img/select-room-bg.png")
    display.removeSpriteFramesWithFile("img/hall.plist","img/hall.png")
    SocketEvent:removeEventListenersByEvent(CMD.RSP_IN_TABLE .. "back")
    _.SelectRoom = nil
end

return SelectRoom