local RoomMenu  =  class("RoomMenu",display.newNode)

function RoomMenu:ctor(room)
    self.room = room
	self.parts ={}
    self:setContentSize(display.width, display.height)
    
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT,function ( event )
        self.parts["menus"]:setVisible(false)
        self:setTouchEnabled(false)
    end)

    
    cc.ui.UIPushButton.new("#room/menu.png")
            :pos(81,display.top - 81)
            :onButtonPressed(function(event,sprite)
                event.target:runAction(cc.TintTo:create(0,128,128,128))
            end)
            :onButtonRelease(function(event)
                event.target:runAction(cc.TintTo:create(0,255,255,255))
            end)
            :onButtonClicked(function (event)
                utils.playSound("click")
                self:setTouchEnabled(true)
                self.parts["menus"]:setVisible(true)
            end)
            :addTo(self)
    cc.ui.UIPushButton.new("#room/shop.png")
            :pos(display.width - 81,display.top - 81)
            :onButtonPressed(function(event,sprite)
                event.target:runAction(cc.TintTo:create(0,128,128,128))
            end)
            :onButtonRelease(function(event)
                event.target:runAction(cc.TintTo:create(0,255,255,255))
            end)
            :onButtonClicked(function (event)
                utils.playSound("click")
                    display:getRunningScene():addChild(MyStore.new(),22)
            end)
            :addTo(self)

    local menuBg = display.newSprite("#room/menu-bg.png",224,display.top - 220)
            :addTo(self)

    local menuText = {"返回","换桌","站起"}
     menuText = {"返回大厅","重新换桌","立刻站起"}
    local menuImg,btn = {"return","change-table","stand"}
    for k,v in pairs(menuText) do
        btn = cc.ui.UIPushButton.new("#common/1px.png",{scale9 = true})
            :setButtonSize(menuBg:getCascadeBoundingBox().width, 100)
            :setButtonLabel(cc.ui.UILabel.new({
                    text = menuText[k], 
                    size = 42, 
                    font = "Helvetica",
                    align = display.LEFT_CENTER,
                    color = cc.c3b(216,186,108),
                    -- dimensions = cc.size(355, 60)
                    })
                    )
            :pos(180, 350 + (k-1) * - 90)
            :onButtonPressed(function(event,sprite)
                event.target:runAction(cc.TintTo:create(0,128,128,128))
            end)
            :onButtonRelease(function(event)
                event.target:runAction(cc.TintTo:create(0,255,255,255))
            end)
            :onButtonClicked(function (event)
                    self:setTouchEnabled(false)
                    self.parts["menus"]:setVisible(false)
                    utils.playSound("click")
                    self["fun"..k](self)
                    -- self.parts["menus"]:setVisible(false)
            end)
            :addTo(menuBg)   
        display.newSprite("#room/"..menuImg[k]..".png",-130,0)
            :addTo(btn)
        menuBg:setVisible(false)
        self.parts["menus"] = menuBg
    end
    local input = display.newSprite("#room/input.png",270,60)
    :addTo(self)

    self.parts["chatMsg"] = cc.ui.UILabel.new({
                text = "", 
                size = 42, 
                x = 90,
                y = 54,
                font = "Helvetica",
                align = cc.ui.TEXT_ALIGN_LEFT,
                })
    :addTo(input)
    -- input:setVisible(false)
    cc.ui.UIPushButton.new("#room/msg.png")
                :pos( 50 ,60)
                :onButtonPressed(function(event,sprite)
                    event.target:runAction(cc.TintTo:create(0,128,128,128))
                end)
                :onButtonRelease(function(event)
                    event.target:runAction(cc.TintTo:create(0,255,255,255))
                end)
                :onButtonClicked(function(event)
                    if not _.Chat then
                        _.Chat = Chat.new()
                        display.getRunningScene():addChild(_.Chat,20)
                    else
                        _.Chat:show()
                    end
                end)
                :addTo(input)
                -- :setVisible(false)
   cc.ui.UIPushButton.new("#room/cardtype.png")
                :pos( 60 ,180)
                :onButtonPressed(function(event,sprite)
                    event.target:runAction(cc.TintTo:create(0,128,128,128))
                end)
                :onButtonRelease(function(event)
                    event.target:runAction(cc.TintTo:create(0,255,255,255))
                end)
                :onButtonClicked(function(event)
                    self.room:showCardsType()
                end)
                :addTo(self)
    
end

local function check(data,callback)
    local status = 10
    if checkint(USER.seatid) > 0 then
        status = _.Room.parts["seats"][USER.seatid].model.status
    end
    if status ~= 10 and status ~= 1 then
       utils.dialog(data.title, data.msg,data.btns, function(e)
            if e.buttonIndex == 1 then
                callback()
            end
        end)
    else
        callback()
    end

end

function RoomMenu:fun1()
    check({title = "", msg = "确认退出牌桌?",btns = {"立刻退出", "继续游戏"}},function ()
        SendCMD:outTable(1)
    end)
end

local function changeTable( )
    _.Room:exit()
    _.Loading = Loading:new()
    display.replaceScene(_.Loading)
    SocketEvent:addEventListener(CMD.RSP_IN_TABLE .. "back", function(event)
        SocketEvent:removeEventListenersByEvent(CMD.RSP_IN_TABLE .. "back")
        _.Loading:setProgress(0.3)
        scheduler.performWithDelayGlobal(function (  )
            if _.Loading then
                _.Loading:hide()
                _.Loading = nil
            end
            _.Room = Room.new()
            _.Room:initRoomWithData(event.data)
            display.replaceScene(_.Room)
        end,0.3)
    end)
    --换桌，直接进游戏不传tid 和 type
    SendCMD:toGame()
end

function RoomMenu:fun2()
    check({title = "", msg = "确认换个牌桌?",btns = {"确定", "继续游戏"}},function ()
        changeTable()
    end)
end


function RoomMenu:fun3()
    if checkint(USER.seatid) <= 0 then  return end
    check({title = "", msg = "确认站起观看?",btns = {"确定", "继续游戏"}},function ()
        SendCMD:userStand(1)
    end)
end

return RoomMenu