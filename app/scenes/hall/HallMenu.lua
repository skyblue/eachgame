local HallMenu  =  class("HallMenu",display.newNode)

function HallMenu:ctor()
	SocketEvent:addEventListener(CMD.RSP_IN_TABLE .. "back", function(event)
        self:exit()
        _.Hall:exit()
        _.Room = Room.new()
        _.Room:initRoomWithData(event.data)
        display.replaceScene(_.Room)
    end)

    SocketEvent:addEventListener(CMD.RSP_SCENES_LIST .. "back", function(event)
        self:exit()
        _.Hall:exit()
        _.SelectRoom = SelectRoom.new()
        display.replaceScene(_.SelectRoom,"flipAngular")
    end)
	local toroom = cc.ui.UIPushButton.new("#hall/to-selectroom.png")
                :pos(display.width - 264 ,display.height * 0.75)
                :onButtonPressed(function(event,sprite)
                    event.target:runAction(cc.TintTo:create(0,128,128,128))
                end)
                :onButtonRelease(function(event)
                    event.target:runAction(cc.TintTo:create(0,255,255,255))
                end)
                :onButtonClicked(self:toSelectTable())
                :addTo(self)
	local togame = cc.ui.UIPushButton.new("#hall/to-game.png")
                :pos(display.width - 264 ,display.height * 0.40)
                :onButtonPressed(function(event,sprite)
                    event.target:runAction(cc.TintTo:create(0,128,128,128))
                end)
                :onButtonRelease(function(event)
                    event.target:runAction(cc.TintTo:create(0,255,255,255))
                end)
                :onButtonClicked(self:toGame())
                :addTo(self)

    local xx,images,text,btn = 300,{"friend","action","shop","more"},{"好友","信息","商城","更多"}
    -- xx = -20
    for i=1,4 do
        btn = cc.ui.UIPushButton.new({normal = "#hall/"..images[i]..".png",disabled = "#hall/"..images[i].."-disable.png"})
         -- btn = cc.ui.UIPushButton.new({normal = "#hall/"..images[i]..".png", pressed = "#hall/"..images[i].."-disable.png",disabled = "#hall/"..images[i].."-disable.png"})
            :pos(xx ,80)
            :setButtonLabel(cc.ui.UILabel.new({text = text[i], size = 46, font = "Helvetica-Bold",
                color = table.indexof({2,3,4},i) and cc.c3b(254,221,70) or cc.c3b(255,255,255)
                -- color = table.indexof({3},i) and cc.c3b(254,221,70) or cc.c3b(255,255,255)
                }))
            :setButtonLabelOffset(0,-50)
            :onButtonPressed(function(event,sprite)
                    event.target:runAction(cc.TintTo:create(0,128,128,128))
                end)
            :onButtonRelease(function(event)
                    event.target:runAction(cc.TintTo:create(0,255,255,255))
                end)
            :onButtonClicked(function (event)
                utils.playSound("click")
                self["fun"..i](self)
            end)
            :addTo(self)
        if i == 1 then
            -- btn:setVisible(false)
        -- end
        -- if table.indexof({1,2,4},i) then
            btn:setButtonEnabled(false)
        end
        xx = xx + 376
        -- xx = xx + 450
    end

end

function HallMenu:fun1()
        -- utils.dialog("HallMenu", "SocketEvent:removeEventListenersByEvent(CMD.RSP_BUY .. )",{"确定","取消"})
end

function HallMenu:fun2()
    display:getRunningScene():addChild(require("app.scenes.Mission").new())
end

function HallMenu:fun3()
    display:getRunningScene():addChild(MyStore.new())
end

function HallMenu:fun4()
    display:getRunningScene():addChild(require("app.scenes.index.Seting").new())

end

function HallMenu:toSelectTable()
	return function ( event )
        utils.playSound("click")
        -- if CONFIG.selectRoom then
        --     _.SelectRoom = SelectRoom.new()
        --     display.replaceScene(_.SelectRoom)
        -- else
            SendCMD:getSceneList()
        -- end
	end
end

function HallMenu:toGame()
	return function ( event )
        utils.playSound("click")
        SendCMD:toGame()
	end
end

function HallMenu:exit( ... )
    SocketEvent:removeEventListenersByEvent(CMD.RSP_SCENES_LIST .. "back")
    SocketEvent:removeEventListenersByEvent(CMD.RSP_IN_TABLE .. "back")
    
end

return HallMenu