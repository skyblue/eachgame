Event = class("Event")

function Event:ctor()
	self.model ={}
end

function Event:init(room)
	self.room = room
	local seats =  room.parts["seats"]
	SocketEvent:addEventListener(ROOM_CMD.NTF_GAME_START .. "back", function(event)
		local data = event.data
		room.model = data
		room.model._resetSeats = false
		--清理下状态
		for i,seat in ipairs(seats) do
	        seat:changeCard(0)
	        seat:changeChipin(0)
	        seat:changeStatus(0)
	        seat:setCardsVisible(false)
	        local uid = checkint(seat.model.uid)
	        if uid == 0 then
	            seat:changeBuying(false)
	        end
	    end

        -- 更新buying和处理台费
	    for k, v in pairs(data.users)  do
	        local seat = seats[v.seatid]
	        -- if seat.model.uid > 0 then
	        if seat.model.uid == v.uid then
	            seat:changeBuying(v.buying)
	        end
	        if v.seatid == data.sSeat then --自己处理小盲
	        	scheduler.performWithDelayGlobal(function (  )
	        		seat:changeBuying(v.buying - data.s_blind)
	        		seat:changeChipin(data.s_blind)
	        		seat:changeStatus(CON__USER_BET)
	        		room:chipin(seat)
	        	end,1)
	        elseif v.seatid == data.bSeat then --自己处理大盲
	        	scheduler.performWithDelayGlobal(function (  )
	        		seat:changeBuying(v.buying - data.b_blind)
	        		seat:changeChipin(data.b_blind)
	        		seat:changeStatus(CON__USER_BET)
	        		room:chipin(seat)
	        	end,2)
	        end
	    end
	    
	    room.parts["public_cards"]:reset() --重置公共牌
	    room.parts["action"]:changeCard()	--重置手牌
	    room.parts["pot"]:clear()
	    if checkint(USER.seatid) == 0 then --如果是旁观者，没手牌，所以需要直接演示发牌动画，显示其它人的盖着的手牌
	    	room:startDealCard(data,nil)
	    end
    end)

    SocketEvent:addEventListener(ROOM_CMD.RSP_RIVER .. "back", function(event)
    	room.parts["public_cards"]:showCard(1,#event.data,event.data)
    	room:showCardLine()
    end)

    SocketEvent:addEventListener(ROOM_CMD.RSP_FINAL_ROUND .. "back", function(event)
    	local data = event.data
    	local seats = room.parts["seats"]
    	if checkint(data.round_pot) == 0 then return end

    	scheduler.performWithDelayGlobal(function (  )
    		-- local s = {2,3,4,6,7,8}   --  {1,5,10} 不清除状态
	     --    for i,seat in ipairs(seats) do
	     --        local status = seat.model.status
	     --        if  seat.model.uid and status > 0 and table.indexOf(s, status) then
	     --            seat:changeStatus(0)
	     --        end
	     --    end
	     	room:moveToPot()
	     	scheduler.performWithDelayGlobal(function ()
	     		room.parts["pot"]:changeVal(data)
     		end,0.3)
    	end,data.round < 5  and 0.6 or 0.8)
    end)

    SocketEvent:addEventListener(ROOM_CMD.RSP_FINAL_GAME .. "back", function(event)
    	room.parts["action"]:stopChipin()
	    local seats = room.parts["seats"]
	    local users = data.users
	    table.sort(users,function(a,b)
	        return a._type > b._type
	    end)
	    local winner = {}
	    local hand_cards
	    for i,u in ipairs(users) do
	        local seat = seats[u.seatid]
            seat.parts["clock"]:stop()
            if data.type == 1 and u.seatid ~= USER.seatid and #(_t(u.cards)) > 0  then
	            seat:moveCard(u.seatid)
	            seat:changeCard(u.cards)
	        end
	        hand_cards = seat.model.imd == USER.uid
	        			and action_layer.parts["hand_cards"]
	        			or seat.parts["hand_cards"]
	        if data.type == 0 and u.win > 0 then
	            table.insert(winner,u)
	            seat:setCardsVisible(false)
	            -- seat:changeWinStatus(0,u.win,u.hightcards)
	        elseif data.type == 1 then
	        	if u.win > 0 then
	                table.insert(winner,u)
	            else
	                hand_cards.card1:gray()
	                hand_cards.card2:gray()
	            end
	            -- seat:changeWinStatus(u.type,u.win,u.hightcards)
	        end
	    end
        local public_cards_val = room.parts['public_cards'].val
        -- self:changeCardType(false) --隐藏所有牌的亮边
        local pot = room.parts["pot"]
        if #users > 0 then
        	self._tid_finalGame = scheduler.performWithDelayGlobal(function (  )
        		for i,u in ipairs(users) do
	                local seat = seats[u.seatid]
	                if seat.model.status ~= 1 then --不是弃牌都改为等待状态
	                    seat:changeStatus(0)
	                end
	            end
	            -- 弃牌赢 
        		if data.type == 0 then
        			local u = winner[1]
                    local seat = seats[u.seatid]
                    pot:moveToSeat(seat,pot.val - u.win)
                    if  not seat.model.uid  then return end
                	seat:changeBuying(u.buying)
                	if seat.model.uid == USER.uid then
                		--播放赢的动画
                		seat.showWin()
                    end
        		else
        			for i,u in ipairs(winner) do
		                local seat = seats[u.seatid]
		                scheduler.performWithDelayGlobal(function()
		                	if seat.model.uid == USER.uid then
	                    		--播放赢的动画
	                    		seat.showWin()
		                    end
		                     --移动筹码
		                    pot:moveToSeat(seat, pot.val - u.win)
		                    if seat.model.uid  then
		                        seat:changeBuying(u.buying)
		                    end
		                    -- 亮高牌
		                    local hand_cards = seat.model.imd == USER.uid
		                                            and action_layer.parts["hand_cards"]
		                                            or seat.parts["hand_cards"]
		                    local all_cards = {}
		                    local hand_cards_cards = {hand_cards.card1,hand_cards.card2}
		                    table.append(all_cards,hand_cards_cards)
		                    table.append(all_cards,room.parts['public_cards'].cards)
		                    for i,card in ipairs(all_cards) do
		                        if table.indexOf(u.hightcards,card.value) then
		                            card:normal()
		                        else
		                            card:gray()
		                        end
		                    end
		                    if i ~= #winner then
		                        scheduler.performWithDelayGlobal(function( )
		                            hand_cards.card1:gray()
		                            hand_cards.card2:gray()
		                        end,3.8)
		                    end
		                end,i*4 - 4)
					end
        		end
        	end,1.4)
	        local wait_time = 4 * #winner + 1.2
		    scheduler.performWithDelayGlobal(function()
		        self.parts["pot"]:clearAll()
		    end,wait_time)
		     -- 清理全部
		    self._tid_clearup = scheduler.performWithDelayGlobal(function()
		        room.parts['public_cards']:reset()
		        for i,u in ipairs(users) do
		            local seat = seats[u.seatid]
		            seat:changeStatus(0)
		            seat:changeChipin(0)
		            if u.seatid == USER.seatid then
		                room.parts["action"]:changeCard(0)
		            else
		                seat:changeCard(0)
		            end
		            seat:changeWinStatus(false)
		        end
		    end,6 * #winner + 4)

	    end
   	end)

   	SocketEvent:addEventListener(ROOM_CMD.NTF_OUT_TABLE .. "back", function(event)
    	-- Room:exit()
    	-- display.replaceScene(_.Hall)
    	dump(event.data)
    	for i,v in ipairs(room.parts["seats"]) do
    		if v.model.uid == event.data then
    			v:changeUser(nil)
    		end
    	end

   	end)

    SocketEvent:addEventListener(ROOM_CMD.NTF_BUYING .. "back", function(event)
    	local seat = room.parts["seats"][data.seatid]
    	seat:changeBuying("取筹码")
	    if data.buying > 0 then   --自动buyin 有bug ,需要屏蔽
	        scheduler.performWithDelayGlobal(function()
	            seat:changeBuying(data.buying)
	        end, 2)
	    end
        seat.model.uchips = data.chips
    end)

    SocketEvent:addEventListener(ROOM_CMD.NTF_USER_STAND .. "back", function(event)
    	local data = event.data
    	local seat = room.parts["seats"][data.seatid]
    	if USER.uid == data.uid then
    		USER.seatid = 0
    		room.parts["action"]:stopChipin()
    		for i, seat in ipairs(room.parts['seats']) do
	            seat:changeSitStatus(0)
	        end
	        USER.uchips =  USER.uchips + seat.model.buying
    	end
    	seat:changeUser(nil)
    end)

    SocketEvent:addEventListener(ROOM_CMD.NTF_CHIP_ACTION .. "back", function(event)
    	local data = event.data
		dump(data)
		local seat = room.parts["seats"][data.seatid]
		if data.uid == USER.uid then
			room.parts["action"]:stopChipin()
		else
			seat:stopChipin(data.type)
		end
		seat:changeBuying(data.buying)
	    seat:changeChipin(data.chipin)
	    seat:changeStatus(data.type)
	    if data.type   == 1 then  -- 弃牌
	        -- utils.playSound("弃牌")
	        if seat.model.uid == USER.uid then
	            room.parts["action"]:fold()
        	end
        elseif data.type == 2 then
        	-- utils.playSound("看牌")
        elseif data.type > 2 and data.type < 9  then
	        if data.type ~= 6 and data.type ~= 7 then
	            -- utils.playSound("加注")
	        end
	        room:chipin(seat)
	    end
    end)

    SocketEvent:addEventListener(ROOM_CMD.NTF_START_ACTION .. "back", function(event)
		local data = event.data
		
		dump(data)
		data.gap_sec = data.gap_sec or room.model.gap_sec
		local seat = room.parts["seats"][data.seatid]
		dump(room.parts["seats"])
		if data.uid == USER.uid then
			if seat.model.status == 1 then return end --已弃牌则不处理
			if data.chipin>0 then
	            seat.model.chipin = data.chipin
	        end
	        dump(seat.model)
	        room.parts["action"]:startChipin(data,seat)
		else
			dump(seat.model)
			seat:startChipin(data)
		end
		-- 清除上次状态
		seat:changeStatus(0)
	end)

    SocketEvent:addEventListener(ROOM_CMD.NTF_USER_SIT .. "back", function(event)
		local data = event.data
		local seatid = checkint(data.seatid)
	    local seat = room.parts["seats"][seatid]
	    if not seat or checknumber(seat.model.uid) > 0 then return end
		data.status = data.status or 10

		if USER.uid == data.uid then
        	-- if checkint(USER.seatid) > 0 then return end
        	room:resetSeats(seat.model.id, data._quickResetPos)
        	room.parts["action"].seat = seat
        	data._quickResetPos = nil
        end
		seat:changeUser(data)
	end)

	SocketEvent:addEventListener(ROOM_CMD.RSP_HAND_CARDS .. "back", function(event)
		local cards = event.data
		room.parts["action"].seat.model.cards = cards
	    if (room.model._resetSeats) then
	        room.parts["action"]:changeCard(cards)
	    else
	        --发牌动画
	        room:startDealCard(room.model,cards)
	    end

	end)


end

function Event:exit()
	dump("Event:exit()")
	SocketEvent:removeEventListenersByEvent(ROOM_CMD.RSP_HAND_CARDS .. "back")
	SocketEvent:removeEventListenersByEvent(ROOM_CMD.NTF_USER_SIT .. "back")
	SocketEvent:removeEventListenersByEvent(ROOM_CMD.NTF_START_ACTION .. "back")
	SocketEvent:removeEventListenersByEvent(ROOM_CMD.NTF_CHIP_ACTION .. "back")
	SocketEvent:removeEventListenersByEvent(ROOM_CMD.NTF_USER_STAND .. "back")
	SocketEvent:removeEventListenersByEvent(ROOM_CMD.NTF_BUYING .. "back")
	SocketEvent:removeEventListenersByEvent(ROOM_CMD.RSP_FINAL_GAME .. "back")
	SocketEvent:removeEventListenersByEvent(ROOM_CMD.NTF_OUT_TABLE .. "back")
	SocketEvent:removeEventListenersByEvent(ROOM_CMD.NTF_GAME_START .. "back")
	SocketEvent:removeEventListenersByEvent(ROOM_CMD.RSP_FINAL_ROUND .. "back")
	SocketEvent:removeEventListenersByEvent(ROOM_CMD.RSP_RIVER .. "back")
end

return Event