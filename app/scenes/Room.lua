local Room = class("Room", function()
    return display.newScene("Room")
end)
Pot = require("app.scenes.room.Pot")
PublicCard  = require("app.scenes.room.PublicCard")
HandCard    = require("app.scenes.room.HandCard")
RoomMenu    = require("app.scenes.room.RoomMenu")
Action      = require("app.scenes.room.Action")
Seat        = require("app.scenes.room.Seat")
Event       = require("app.scenes.room.Event")
CardsType   =require("app.scenes.room.CardsType")


function Room:ctor()
    self.seat_coords5 = {cc.p(display.cx,display.height*0.25),cc.p(175,display.height*0.38),cc.p(278,display.height*0.77),cc.p(1412,display.height*0.77),cc.p(1529,display.height*0.38)}
    self.seat_coords9 = {cc.p(display.cx,display.height*0.25),cc.p(500,display.height*0.25),cc.p(175,display.height*0.38),cc.p(278,display.height*0.77),cc.p(583,display.height*0.85),cc.p(1129,display.height*0.85),cc.p(1412,display.height*0.77),cc.p(1529,display.height*0.38),cc.p(1218,display.height*0.25)}
    self.dealer_coords5 = {cc.p(980,display.height*0.375),cc.p(320,display.height*0.395),cc.p(400,display.height*0.65),cc.p(1290,display.height*0.67),cc.p(1400,display.height*0.42)}
    self.dealer_coords9 = {cc.p(980,display.height*0.375),cc.p(630,display.height*0.375),cc.p(320,display.height*0.395),cc.p(400,display.height*0.65),cc.p(670,display.height*0.71),cc.p(1020,display.height*0.7),cc.p(1290,display.height*0.67),cc.p(1400,display.height*0.42),cc.p(1350,display.height*0.375)}
    self.model ={
        -- max_player = 5,
        lookUser ={},
        users = {},

    }
    display.addSpriteFrames("img/room.plist","img/room.png")
	self.parts={}
    local bg = display.newSprite("img/hall-bg.png",display.cx,display.cy)
    :addTo(self)
    display.newSprite("img/table-bg.png",display.cx,display.cy+100)
    :addTo(self)
    if display.height > 960 then
        bg:setScale(display.height/960)
    end
    -- display.newSprite("#room/heguan.png",display.cx,display.cy + display.cy * 0.72)
    -- :addTo(self)
	_.Event = Event.new()  
	self:initPublicCard()
    self:initDealer()
	self:initRoomMenu()
    self:initAction()
    utils.stopMusic()
    self.parts["cards-type"] = CardsType.new():addTo(self,20)
end

function Room:showCardsType()
    self.parts["cards-type"]:show()
end

function Room:initRoomWithData(data)
    dump(data)
    utils.__merge(self.model,data)
    data = self.model
    self.model._resetSeats = false
    cc.ui.UILabel.new({
            UILabelType = 2,
            text = "桌号："..data.tid,
            font = "Helvetica-Bold",
            size = 30})
            :align(display.CENTER,240,display.top - 81)
            :addTo(self)
    self:initPot(data)
    self:initChips()
    self:initSeats()
    self:setDealer(data.dealer)
    local seat
    for id,u in pairs(data.users) do
        seat = self.parts["seats"][u.seatid]
        if u.uid == USER.uid then
            self.model._resetSeats = true
            u._quickResetPos = true
            self.parts["action"].seat = seat
            seat:resetSeats(seat.model.id,true)
        end
        seat:changeUser(u)
    end
    if #data.public_cards > 0 then
        self.parts["public_cards"]:showCard(1,#data.public_cards,data.public_cards)
    end
    if data.currPlayer then
        self:performWithDelay(function ( )
            if data.currPlayer.uid ==  USER.uid then
                self.parts["action"]:startChipin(data.currPlayer,self.parts["seats"][data.currPlayer.seatid])
            else
                self.parts["seats"][data.currPlayer.seatid]:startChipin(data.currPlayer)
            end
        end, 0.5)
    end
    self.load = true
    _.Event:init(self)
end

function Room:initChips()
    local batchNode = Chip:getBatchNode()
    self:addChild(batchNode,50)
    self.parts["batch-chips"] =  batchNode
    self.parts["chips"] ={}
    for i= 1, self.model.max_player * 5 do
        local coin = CONFIG.coinList[math.random(1,10)]
        -- local c = Chip:create(coin,1, seat.x , seat.y, batchNode)
        local c = Chip.new(nil,math.random(1,4),0,0,batchNode)
        c:setScale(0.8)
        c:setOpacity(0)
        table.insert(self.parts["chips"],c)
    end
end

function Room:setDealer(seatid)
    if seatid == 0 then return end
    local dealer = self.parts["dealer"];
    dealer:setVisible(true)
    local xx,yy = 210,180
    if self.parts["seats"][seatid].model.pos_id == 5 then --
    	xx = -20
    end
    transition.moveTo(dealer,{
        time = 0.5,
        x = xx,
        y = yy,
        easing = "INOUT"
    })
end

function Room:initAction( )
    local action = Action.new()
    self:addChild(action,20)
    action:setPositionX(display.cx)
    self.parts["action"] = action
end

function Room:initDealer( )
    local dealer = display.newSprite("#room/dealer.png")
    dealer:setVisible(false)
    self.parts["dealer"] = dealer
    self:addChild(dealer,10)
end

function Room:setDealer(seatid)
    if seatid > 0  and seatid < 10 then
        local seat = self.parts["seats"][seatid]
        local coord =  self["dealer_coords"..self.model.max_player][seat.model.pos_id]
        local dealer = self.parts["dealer"];
        dealer:setVisible(true)
        if dealer:getPositionY() == 0  then
            dealer:setPosition(coord.x,coord.y)
        else
            transition.moveTo(dealer,{
                time = 0.5,
                x = coord.x,
                y = coord.y,
                easing = "INOUT"
            })
        end
    end
end

function Room:initPot()
    local pot = Pot.new(self.model)
    pot:setPosition(display.cx,display.height * 0.66)
    self:addChild(pot)
    self.parts["pot"] = pot
    -- pot:changeVal()
end

function Room:moveToPot()
    utils.playSound("move_chips")
    local pot = cc.p(self.parts["pot"]:getPositionX(),self.parts["pot"]:getPositionY())
    local chips = self.parts["chips"]
    local t,pos,start,c,delay,a1a2,action = 0.3

    for k,seat in ipairs(self.parts["seats"]) do
        if checkint(seat.model.chipin) > 0 then
            seat:changeChipin(0)
            pos = seat.parts["chipin"]:convertToWorldSpace(cc.p(0,0))
            pos = self:convertToNodeSpace(pos)
            start = (seat.model.pos_id - 1) * 5  + 1
            for i = start, start + 4 do
                c = chips[i]
                c:setOpacity(200)
                c:setPosition(pos.x,pos.y)
                delay = cc.DelayTime:create(( i- start + 1 ) * 0.05 )
                a1 = transition.newEasing(cc.MoveTo:create(t,pot),"OUT")
                a2 = transition.newEasing(cc.FadeTo:create(t*1.5,0),"OUT")
                action = transition.sequence({delay,cc.Spawn:create({a1,a2})})
                c:runAction(action)
            end
        end
    end
end

function Room:initPublicCard()
	local publiCard = PublicCard.new()
	publiCard:setPosition(588,display.cy+40)
	self:addChild(publiCard,19)
    self.parts["public_cards"] = publiCard
end

function Room:initRoomMenu()
	local RoomMenu = RoomMenu.new(self)
	self:addChild(RoomMenu,13)
	self.parts["roomMenu"] = RoomMenu
end

function Room:initSeats()
    local max = self.model["max_player"]
    self.parts["seats"]= {}
    -- local second = self.model["gap_sec"]
    local seats = {}
    local pos_ids = table.slice({1,2,3,4,5,6,7,8,9},1,max)
    for i=1, #pos_ids, 1 do
        local seat = Seat.new(i,max,self.model.gap_sec)
        local coord = self["seat_coords"..max][i]
        seat:setPosition(coord.x,coord.y)
        seats[i] = seat
        self:addChild(seat,i)
        seat:setTouchEnabled(true)
        seat:addNodeEventListener(cc.NODE_TOUCH_EVENT,self:onSeatTap(seat))
    end
    self.parts["seats"] = seats
end

function Room:onSeatTap(seat)
	return function (event)

        if event.name == "began" then
            utils.playSound("click")
            return true
		elseif event.name == "ended" then
		    if checkint(seat.model.uid) > 0 then

		        -- 显示用户信息
                SendCMD:getUserInfo(seat.model.uid)
		        return
		    else
                -- dump(checkint(USER.seatid))
                if checkint(USER.seatid) > 0 then return end
		        --发送socket
                SendCMD:userSit(seat.model.id,self.model.min_buying,1)
                -- self:resetSeats(seat.model.id)
                -- self:resetSeats(seat.model.id,seat.model.pos_id)
		    end
		end
    end
end

function Room:resetSeats(base_id, quick)
    -- dump("base_id:"..base_id)
    if not base_id then return end
    local max = self.model.max_player or 9
    local coords = table.clone(self["seat_coords"..max])
    local pos_ids = table.slice({1,2,3,4,5,6,7,8,9},1,max)
    local seats = self.parts["seats"]
    local t = quick and 0 or 0.7

    local move,moveEnd
    moveEnd = function()
        local of =  table.indexof(pos_ids,base_id);
        local s1,s2 = table.slice(pos_ids,of),table.slice(pos_ids,1,of-1)
        local new_pos_ids = table.append(s1,s2)
        for i, seatid in ipairs(new_pos_ids) do
            local seat = seats[seatid]
            local pos = pos_ids[i]
            transition.moveTo(seat,{
                x = coords[pos].x,
                y = coords[pos].y,
                time = t,
                easing = "BACKOUT",
            })
            seat:changePos(pos)
            -- if seat.model.uid == 0 then
                seat:changeSitStatus(1)
            -- end
        end
    end
    moveEnd()
   
    -- local base_ids = {}
    -- if pos_id > (max+1)/2 then
    --     for i = max,pos_id,-1 do
    --         table.insert(base_ids, i)
    --     end
    -- else
    --     for i=2 ,pos_id do
    --         table.insert(base_ids, i)
    --     end
    -- end
    -- local roundNum = #base_ids
    -- dump("roundNum   "..roundNum)
    -- dump(base_ids)
    -- local index = 1
    -- move = function(id)
    --     local of =  table.indexof(pos_ids,id)
    --     dump("id    " .. id)
    --     local s1,s2 = table.slice(pos_ids,of),table.slice(pos_ids,1,of-1)
    --     local new_pos_ids = table.append(s1,s2)
    --     for i, seatid in ipairs(new_pos_ids) do
    --         local seat = seats[seatid]
    --         local pos = pos_ids[i]
    --         transition.moveTo(seat,{
    --             x = coords[pos].x,
    --             y = coords[pos].y,
    --             time = t/roundNum,
    --             onComplete =function()
    --                 if i == #new_pos_ids then
    --                     index = index + 1
    --                     if index + 1 < #base_ids then
    --                         move(base_ids[index])
    --                     else
    --                         moveEnd()
    --                     end
    --                 end
    --             end
    --         })
    --     end
    -- end
    -- if #base_ids == 1 then
    --     moveEnd()
    -- else
        -- move(base_ids[index])
    -- end
end

--游戏开始时发牌动画
function Room:startDealCard(roomdata,cards)
    local data = {}
    for i,v in ipairs(roomdata.users) do
        data[i] = v.seatid
    end
    local start_seat = roomdata.sSeat
    table.sort(data)
    local data_arr = {}
    for i=start_seat,#data do
        data_arr[#data_arr +1 ] = data[i]
    end
    for i=1,start_seat-1 do
        data_arr[#data_arr +1 ] = data[i]
    end
    data = data_arr
    local batch = display.newBatchNode("img/poker.png",10)
    batch:setPosition(display.cx,display.height-270)
    self:addChild(batch,20)
    local fun = function(cardcheckintum)
        for j=1,#data do
            self:performWithDelay(function (  )
                local seatid = data[j]
                local to_seat = self.parts["seats"][seatid]
                local card = display.newSprite("#cover-small.png")
                if to_seat.model.uid ==  USER.uid then
                    card = display.newSprite("#cover.png")
                end
                batch:addChild(card)
                local c_p = cc.p(0,0)
                local start_point = card:convertToNodeSpace(c_p)
                local small_cards = to_seat.parts["small_cards"]
                local time = 0.3
                local card_rotation = 0
                local card_round_rotation = 360
                local a21
                local conver_end_point  = cc.p(4,0)
                if cardcheckintum == 1 then
                    conver_end_point = cc.p(-2,4)
                    card_rotation = -4
                else
                    conver_end_point = cc.p(4,-2)
                    card_rotation = 6
                end
                local convert_sp = small_cards["card"..cardcheckintum]
                local c_p_end = convert_sp:convertToWorldSpace(conver_end_point)
                if to_seat.model.uid == USER.uid then
                    if cardcheckintum == 1 then
                        c_p_end = cc.p(to_seat:getPositionX() + 78 ,to_seat:getPositionY()-96)
                        card_round_rotation = 184
                    else
                        c_p_end = cc.p(to_seat:getPositionX() + 108 ,to_seat:getPositionY()-96)
                        card_round_rotation = 174
                    end
                    
                end
                local end_point = card:convertToNodeSpace(c_p_end)
                a21 =  cc.RotateBy:create(time,card_round_rotation)
                card:setRotation(card_rotation)

                local action = cc.MoveTo:create(time,end_point)
                local a11 = cc.EaseSineOut:create(action)
                local action1 = cc.Spawn:create({a21,a11})
                if to_seat.model.uid ==  USER.uid then
                    card:setScale(0.3)
                    transition.scaleTo(card,{time = time,scale = 0.8})
                end
                transition.execute(card,action1,{onComplete = function ( )
                    if to_seat.model.uid ~=  USER.uid then
                        card:removeSelf(true)
                        small_cards["card"..cardcheckintum]:setVisible(true)
                        else
                            self.parts["action"].parts["hand_cards"]["card"..cardcheckintum]:setVisible(true)
                    end
                    if j == #data and cardcheckintum == 2 then
                        self:performWithDelay(function()
                            batch:removeSelf(true)
                            if cards then
                                self.parts["action"]:changeCard(cards)
                                self:showCardLine()
                            end
                        end, 0.1)
                    end
                end})
            end,j*0.2)
         end
        end
    self:performWithDelay(function ( )
        fun(2)
    end,(#data+1) * 0.2 )
    fun(1)

end

function Room:chipin(seat)
    local pos = seat.parts["chipin"]:convertToWorldSpace(cc.p(0,0))
          pos = self:convertToNodeSpace(pos)
    local t = 0.25
    for i=1 , math.random(2,4) do
        local c = self.parts["chips"][i]
        c:setPosition(seat:getPositionX(),seat:getPositionY())
        c:setOpacity(150)
        local delay = cc.DelayTime:create((i-1)*0.07)
        local a1 = cc.MoveTo:create(t,pos)
        local a2 = cc.FadeTo:create(t*1.5,0)
        local action = transition.sequence({delay,cc.Spawn:create({a1,a2})})
        c:runAction(action)
    end
end

function Room:showCardLine()
    local  hand_cards = self.parts["action"].parts["hand_cards"]
    if hand_cards.card1.value > 0 then
        local all_cards = self:hideCardLine()
        
        local allcard_vals = {}
        for i,c in ipairs(all_cards) do
            if c.value > 0 then
                table.insert(allcard_vals,c.value)
            end
        end
        local cardtype,highcards = Card.getCardType(allcard_vals)
        if cardtype >= 2 then
            for i, c in ipairs(all_cards) do
                if table.indexOf(highcards,c.value) then
                    c:showline()
                end
            end
        end

    end
end

function Room:hideCardLine()
    local  hand_cards = self.parts["action"].parts["hand_cards"]
    local all_cards = {}
    local hand_cards_cards = {hand_cards.card1,hand_cards.card2}
    table.append(all_cards,hand_cards_cards)
    table.append(all_cards,self.parts['public_cards'].cards)
    for i, c in ipairs(all_cards) do
        c:hideline()
    end
    return all_cards
end

function Room:exit(removeImage)
    USER.tid = 0
    USER.seatid = 0
    _.Event:exit()
    if removeImage then
        display.removeSpriteFrameByImageName("img/table-bg.png")
        display.removeSpriteFramesWithFile("img/room.plist","img/room.png")
    end
    _.Room = nil
end

return Room