local RoomMenu  =  class("RoomMenu",display.newNode)

function RoomMenu:ctor()
	self.parts ={}
    self:setContentSize(display.width, display.height)
    
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT,function ( event )
        self.parts["menus"]:setVisible(false)
        self:setTouchEnabled(false)
    end)

    
    cc.ui.UIPushButton.new("#room/menu.png")
            :pos(81,display.top - 81)
            :onButtonPressed(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,-128,-128,-128))
            end)
            :onButtonRelease(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,255,255,255))
            end)
            :onButtonClicked(function (event)
                utils.playSound("click")
                self:setTouchEnabled(true)
                self.parts["menus"]:setVisible(true)
            end)
            :addTo(self)
    cc.ui.UIPushButton.new("#room/shop.png")
            :pos(display.width - 81,display.top - 81)
            :onButtonPressed(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,-128,-128,-128))
            end)
            :onButtonRelease(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,255,255,255))
            end)
            :onButtonClicked(function (event)
                utils.playSound("click")
                    _.MyStore = MyStore.new()
                    self:addChild(_.MyStore,20)
                    _.MyStore:show()
            end)
            :addTo(self)

    local menuBg = display.newSprite("#room/menu-bg.png")
            :pos(196,display.top - 260)
            :addTo(self)
    local menuText = {"返回","换桌","站起"}
     menuText = {"返回大厅","重新换桌","立刻站起"}
    local menuImg = {"return","change-table","stand"}
    for k,v in pairs(menuText) do
        cc.ui.UIPushButton.new("#room/"..menuImg[k]..".png")
            :setButtonLabel(cc.ui.UILabel.new({
                    text = menuText[k], 
                    size = 42, 
                    font = "Helvetica",
                    align = cc.ui.TEXT_ALIGN_RIGHT,
                    color = cc.c3b(216,186,108),
                    dimensions = cc.size(355, 60)
                    })
                    )
            :setButtonLabelOffset(44,0)
            :pos(80, 350 + (k-1) * - 90)
            :onButtonPressed(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,-128,-128,-128))
            end)
            :onButtonRelease(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,255,255,255))
            end)
            :onButtonClicked(function (event)
                    self:setTouchEnabled(false)
                    self.parts["menus"]:setVisible(false)
                    utils.playSound("click")
                    self["fun"..k]()
                    -- self.parts["menus"]:setVisible(false)
            end)
            :addTo(menuBg)   
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
                -- :setButtonSize(360, 104)
                -- :setButtonLabel(cc.ui.UILabel.new({text = "全下", size = 40, font = "Helvetica-Bold"}))
                :pos( 50 ,60)
                :onButtonPressed(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,-128,-128,-128))
                end)
                :onButtonRelease(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,255,255,255))
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
                -- :setButtonSize(360, 104)
                -- :setButtonLabel(cc.ui.UILabel.new({text = "全下", size = 40, font = "Helvetica-Bold"}))
                :pos( 60 ,160)
                :onButtonPressed(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,-128,-128,-128))
                end)
                :onButtonRelease(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,255,255,255))
                end)
                :onButtonClicked(function(event)
                    self:showPokerType()
                end)
                :addTo(self)
                :setVisible(false)

    -- cc.ui.UIPushButton.new("#room/cardtype.png")
    --             :pos( 60 ,160)
    --             :onButtonClicked(function(event)
    --                 display:getRunningScene():addChild(require("app.scenes.room.MinMission").new())
    --             end)
    --             :addTo(self)
    
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
            _.Room = Room.new()
            _.Room:initRoomWithData(event.data)
            display.replaceScene(_.Room)
        end,0.3)
    end)
    --换桌，直接进游戏不传tid 和 type
    SendCMD:toGame()
end

function RoomMenu:fun2()
    if not _.UserInfo then
        _.UserInfo = UserInfo.new(U)
        display:getRunningScene():addChild(_.UserInfo)
    end
    _.UserInfo:show(USER)
    -- check({title = "", msg = "确认换个牌桌?",btns = {"确定", "继续游戏"}},function ()
    --     changeTable()
    -- end)
end


function RoomMenu:fun3()
    check({title = "", msg = "确认站起观看?",btns = {"确定", "继续游戏"}},function ()
        SendCMD:userStand(1)
    end)
end

return RoomMenu