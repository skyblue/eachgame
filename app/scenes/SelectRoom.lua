local SelectRoom = class("SelectRoom", function()
    return display.newScene("SelectRoom")
end)

function SelectRoom:ctor()
	display.addSpriteFrames("img/selectroom.plist","img/selectroom.png")
	self.parts={}
    local bg = display.newSprite("img/hall-bg.png",display.cx,display.cy)
        :addTo(self)
    display.newSprite("#selectroom/menu-bg.png",display.cx,120)
        :addTo(self)


    if display.height > 960 then
        bg:setScale(display.height/960)
    end
    SocketEvent:addEventListener(CMD.RSP_IN_TABLE .. "back", function(event)
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
            :onButtonPressed(function(event,sprite)
                event.target:runAction(cc.TintTo:create(0,128,128,128))
            end)
            :onButtonRelease(function(event)
                event.target:runAction(cc.TintTo:create(0,255,255,255))
            end)
            :onButtonClicked(function (event)
                utils.playSound("click")
                self:exit()
                _.Hall = Hall.new()
                display.replaceScene(_.Hall,"flipAngular")
            end)
            :addTo(self)   

    self.list = cc.ui.UIListView.new {
                viewRect = cc.rect(0,100, display.width, display.height-200),
                direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL,
            }
            :onTouch(handler(self, self.touchListener))
            :addTo(self)

    local item 
    for i,v in ipairs(CONFIG.selectRoom) do
        item = self.list:newItem()
        content = display.newNode()
             -- :align(display.CENTER)
        display.newSprite("#selectroom/Light_"..i..".png")
            :align(display.CENTER,0,display.cy * 0.1)
            :addTo(content)
    	cc.ui.UIPushButton.new("#selectroom/MM"..i..".png")
            :align(display.CENTER,0,display.cy * 0.1)
            :onButtonPressed(function(event,sprite)
                event.target:runAction(cc.TintTo:create(0,128,128,128))
            end)
            :onButtonRelease(function(event)
                event.target:runAction(cc.TintTo:create(0,255,255,255))
            end)
            -- :onButtonClicked(function (event)
            --         SendCMD:toGame(0,i)
            -- end)
            :addTo(content)  
            :setTouchSwallowEnabled(false)
        display.newSprite("#selectroom/text-bg.png",0,-display.cy * 0.54)
            :addTo(content)
            :setScaleY(0.6)
        cc.ui.UILabel.new({
            UILabelType = 2,
            text = v.name,
            font = "Helvetica-Bold",
            -- color = cc.c3b(255,255,255),
            size = 50})
            :align(display.CENTER,0,-display.cy * 0.41)
            :addTo(content)
        cc.ui.UILabel.new({
            UILabelType = 2,
            text = "盲注：" .. utils.numAbbr(v.min_b) .."—"..utils.numAbbr(v.max_b),
            size = 30})
            :align(display.CENTER,0,-display.cy * 0.57)
            :addTo(content)
        cc.ui.UILabel.new({
            UILabelType = 2,
            text = "筹码要求："..utils.numAbbr(v.min_buying).."—"..utils.numAbbr(v.max_buying),
            size = 30})
            :align(display.CENTER,0,-display.cy * 0.69)
            :addTo(content)
        item:addContent(content)
        item:setItemSize(566,content:getContentSize().height)
        self.list:addItem(item)
    end
    self.list:reload()
end

local time = 0

function SelectRoom:touchListener(event)
    local yy,tid = 0
    if event.name == "began" then
        yy = event.y
        tid = self:performWithDelay(function ( )
           self:showRoomList()
        end, 1)
    elseif event.name == "moved" then

    elseif event.name == "ended"  then
        transition.removeAction(tid)
    elseif event.name == "clicked" then
        utils.playSound("click")
        transition.removeAction(tid)
        if time+1 > os.time() then
            SendCMD:toGame(0,event.itemPos)
        else
            self:showRoomList()
        end
    end
end

function SelectRoom:showRoomList()
    dump(12312)
    
end

function SelectRoom:exit()
    display.removeSpriteFrameByImageName("img/select-room-bg.png")
    display.removeSpriteFramesWithFile("img/hall.plist","img/hall.png")
    SocketEvent:removeEventListenersByEvent(CMD.RSP_IN_TABLE .. "back")
    _.SelectRoom = nil
end

return SelectRoom