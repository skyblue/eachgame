local RoomMenu  =  class("RoomMenu",display.newNode)

function RoomMenu:ctor()
	self.parts ={}
    self:setContentSize(display.width, display.height)
    
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT,function ( event )
        self.parts["menus"]:setVisible(false)
        self:setTouchEnabled(false)
    end)

    
    cc.ui.UIPushButton.new("#room/xiangxiajiantou.png")
            :pos(81,display.top - 81)
            :onButtonPressed(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,-128,-128,-128))
            end)
            :onButtonRelease(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,255,255,255))
            end)
            :onButtonClicked(function (event)
                    self:setTouchEnabled(true)
                    self.parts["menus"]:setVisible(true)
            end)
            :addTo(self)
    cc.ui.UIPushButton.new("#room/libao.png")
            :pos(display.width - 81,display.top - 81)
            :onButtonPressed(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,-128,-128,-128))
            end)
            :onButtonRelease(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,255,255,255))
            end)
            :onButtonClicked(function (event)
                    dump("menu clicked")
            end)
            :addTo(self)

    local menuBg = display.newSprite("#room/menu-bg.png")
            :pos(196,display.top - 260)
            :addTo(self)
    local menuText = {"返回大厅","重新换桌","立刻站起","暂时离开","游戏设置"}
    local menuImg = {"xialaxiang-fanhui","xialaxiang-huanzhuo","xialaxiang-zhanqi","xialaxiang-zhanqi","seting"}
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
            :pos(80, 424 + (k-1) * - 90)
            :onButtonPressed(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,-128,-128,-128))
            end)
            :onButtonRelease(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,255,255,255))
            end)
            :onButtonClicked(function (event)
                    self.parts["menus"]:setVisible(false)
                    dump("menu clicked")
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

    cc.ui.UIPushButton.new("#room/xiaoxi.png")
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
                         dump(1)
                        _.Chat = Chat.new()
                        self:addChild(_.Chat)
                    else
                        _.Chat:show()
                        dump(2)
                    end
                end)
                :addTo(input)
   cc.ui.UIPushButton.new("#room/xialaxiang-paixing.png")
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


    SocketEvent:addEventListener(ROOM_CMD.NTF_START_ACTION .. "back", function(event)

    end)
end

function RoomMenu:fun1()
    local status = 10
    if checkint(USER.seatid) > 0 then
        status = _.Room.parts["seats"][USER.seatid].model.status
    end
    if status ~= 10 and status ~= 1 then
       utils.dialog("", "确认退出牌桌?",{"立刻退出", "本局结束后"}, function(e)
            if e.buttonIndex == 1 then
                SendCMD:outTable(1)
            elseif e.buttonIndex == 2 then
                SendCMD:outTable(2)
            end
        end)
    else
        SendCMD:outTable(1)
    end
end

function RoomMenu:fun2()
    --换桌，直接进游戏不传tid 和 type
    SendCMD:toGame()
end

function RoomMenu:fun3()
    SendCMD:userStand(1)
end

function RoomMenu:fun4()
    SendCMD:userStand(2)
end

return RoomMenu