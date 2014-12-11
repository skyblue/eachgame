local HallMenu  =  class("HallMenu",display.newNode)

function HallMenu:ctor()
	SocketEvent:addEventListener(CMD.RSP_IN_TABLE .. "back", function(event)
        _.Hall:exit()
        _.Room = Room.new()
        _.Room:initRoomWithData(event.data)
        display.replaceScene(_.Room)
    end)

    SocketEvent:addEventListener(CMD.RSP_SCENES_LIST .. "back", function(event)
        _.Hall:exit()
        _.SelectRoom = SelectRoom.new()
        display.replaceScene(_.SelectRoom)
    end)
	local toroom = cc.ui.UIPushButton.new("#hall/to-room.png")
                :pos(display.width - 264 ,display.cy + 74)
                :onButtonPressed(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,-128,-128,-128))
                end)
                :onButtonRelease(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,255,255,255))
                end)
                :onButtonClicked(self:toSelectTable())
                :addTo(self)
	local togame = cc.ui.UIPushButton.new("#hall/to-game.png")
                :pos(display.width - 264 ,display.cy - 150)
                :onButtonPressed(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,-128,-128,-128))
                end)
                :onButtonRelease(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,255,255,255))
                end)
                :onButtonClicked(self:toGame())
                :addTo(self)
end


function HallMenu:toSelectTable()
	return function ( event )
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
        -- dump("in table")
        SendCMD:toGame(2)
	end
end

function HallMenu:exit( ... )
    SocketEvent:removeEventListenersByEvent(CMD.RSP_IN_TABLE .. "back")
    SocketEvent:removeEventListenersByEvent(CMD.RSP_SCENES_LIST .. "back")
end

return HallMenu