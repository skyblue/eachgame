local Seat = class("Seat",display.newNode)
local Clock = require("app.scenes.room.Clock")

function Seat:ctor(id,maxPlayer,gap_sec)
    self.chipinPos5 = {cc.p(0,170),cc.p(140,90),cc.p(-20,-170),cc.p(-100,-150),cc.p(-130,140)}
    self.chipinPos9 = {cc.p(0,170),cc.p(0,170),cc.p(140,90),cc.p(-20,-170),cc.p(-20,-170),cc.p(-20,-170),cc.p(-100,-150),cc.p(-130,140),cc.p(0,170)}
	self.chipinPos = self["chipinPos"..maxPlayer]
    self.parts ={}
	self.model = {
                uid = 0,
                id = id,
                pos_id = id,
				upic = "",
                uname = "",
				sex = 0}
	self._size = cc.size(176,236)
    self:setContentSize(self._size)

    local bg = display.newSprite("#room/touxiang-bg.png")
        :addTo(self)

    local chipin = Chip:getBatchNode(20)
    chipin:setPosition(self["chipinPos"][id])
    self:addChild(chipin)
    Chip.new(nil,math.random(1,4),0,0,chipin)

    local chipin_val = cc.ui.UILabel.new({
        UILabelType = 2,
        text = "",
        size = 36,
        x = self["chipinPos"][id].x + 30,
        y = self["chipinPos"][id].y,
        textAlign = cc.ui.TEXT_ALIGNMENT_LEFT,
        color = cc.c3b(254,221,70),
        font = "Helvetica",
        })
        :addTo(self)
    chipin.label = chipin_val
    self.parts["chipin"] = chipin
    chipin:setVisible(false)

	self:initHead(gap_sec)
	local sit = cc.ui.UILabel.new({
		UILabelType = 2,
		text = "坐下",
        font = "Helvetica",
		size = 36,
        })
		:align(display.CENTER,0,60)
		:addTo(self,5)
	self.parts["sit"] = sit
    self.parts['sit_arr'] = display.newSprite("#room/sit-arr.png",0,-30)
        :addTo(self,4)

	local uname = cc.ui.UILabel.new({
		UILabelType = 2,
		text = "",
        font = "Helvetica",
		size = 32,
        })
		:align(display.CENTER, 0, 90)
		:addTo(self)
	self.parts["uname"] = uname

    self.parts["win"] = display.newSprite("#room/win.png",0,90)
        :addTo(self)
    self.parts["win"]:setVisible(false)

    local frames = display.newFrames("room/win%1d.png", 1, 2)
    display.setAnimationCache("anim_win", display.newAnimation(frames, 1.5 / 12))
    self.parts["anim_win"] = display.newSprite()
        :addTo(self,20)
        
	local buying = cc.ui.UILabel.new({
		UILabelType = 2,
		text = "",
        color = cc.c3b(254,221,70),
        font = "Helvetica",
		size = 32,
        })
		:align(display.CENTER, 0, -94)
		:addTo(self)
	self.parts["buying"] = buying
	self:initSmallCard()
	self:initHandCard()
end

function Seat:initHead( gap_sec)
    local head = utils.makeAvatar()
    head:setVisible(false)
    local clock = Clock.new(gap_sec)
    clock:setPosition(head._size.width/2, head._size.height/2-1)
    head:addChild(clock, 10)
    -- clock:start()
    self.parts["clock"] = clock
    self:addChild(head)
    self.parts["head"]  = head
    -- self:startChipin()
end

function Seat:changeChipin(val)
    local chipin = self.parts["chipin"]
    if checknumber(val) == 0 then
        chipin.label:setString("")
        chipin:setVisible(false)
        self.model.chipin = 0
    else
        chipin.label:setString(utils.numAbbr(val))
        chipin:setVisible(true)
        self.model.chipin = val
    end
    -- transition.moveTo(chipin,{x=chipinPos[self.model.pos_id].x,y = chipinPos[self.model.pos_id].y,time = 0.3})
end

function Seat:changePic(pic_path)
    if #self.model.upic > 0 then
    	utils.loadRemote(self.parts["head"].pic,pic_path)
    end
end

function Seat:initHandCard()
	local hand_cards = display.newNode()
    hand_cards:setScale(0.8)
    hand_cards.card1 = Card.new(0)
    hand_cards.card2 = Card.new(0)
    hand_cards:addChild(hand_cards.card1)
    hand_cards:addChild(hand_cards.card2)
    hand_cards.card1:setPosition(-18,0)
    hand_cards.card2:setPosition(18,0)
    -- hand_cards:setPositionY(7)
    self:addChild(hand_cards)
    self.parts["hand_cards"] = hand_cards
    hand_cards:setVisible(false)
end

function Seat:initSmallCard()
	local small_cards = display.newNode()
    small_cards:setPosition(80,-20)
    small_cards.card1 = display.newSprite("#cover-small.png",0,4)
    small_cards.card1._x = 0
    small_cards.card1._y = 4
    small_cards.card2 = display.newSprite("#cover-small.png",18,-4)
    small_cards.card2._x = 8
    small_cards.card2._y = -4
    small_cards.card1:setRotation(-4)
    small_cards.card2:setRotation(6)
    small_cards._size = small_cards.card1:getContentSize()
    small_cards:addChild(small_cards.card1)
    small_cards:addChild(small_cards.card2)
    self:addChild(small_cards)
    self.parts["small_cards"] = small_cards
    self:setCardsVisible(false)
end

function Seat:moveCard(seatid)
    local time = 0.05
    transition.scaleTo(self.parts["small_cards"],{
        time = time,
        scale=2,
        onComplete = function ()
            self.parts["small_cards"]:setScale(1)
        end,
        })
    local _x = -10
    local _y = 10
    transition.moveTo(self.parts["small_cards"],{
        time = time,
        x = _x,
        y = _y,
        onComplete = function ()
            self.parts["small_cards"]["card1"]:setVisible(false)
            self.parts["small_cards"]["card2"]:setVisible(false)
            self.parts["small_cards"]:setPosition(80,-20)
        end
    })
end

function Seat:changeBuying(val,anim,time)
    local buying = self.parts["buying"]
    if type(val) == "string" then
        return buying:setString(val)
    end
    if not val or utils.empty(self.model.uid) then
        self.model.buying = 0
        buying:setVisible(false)
        return
    end
    if val < 0 then  val = 0 end
    buying:setVisible(true)
    local digit = val> 1e8 and 0 or 1
    buying:setString(utils.numAbbr(val,digit))
    self.model.buying = val

    if self.model.uid == USER.uid then
        USER.buying = val
    end

end

function Seat:changeStatus(status)
    status = checknumber(status)
    local cache = cc.Director:getInstance():getTextureCache()
    local _isfold = self.model._isfold
    if _isfold  then
        -- self.parts["head"].pic:setOpacity(255)
        self:setOpacity(255)
        self.model._isfold = false
    end
    -- 弃牌状态
    if status == 1 or (self.model.uid ~= USER.uid and status == 10) then
        -- self.parts["head"].pic:setOpacity(100)
        self:setOpacity(100)
        self.model._isfold = true
        --弃牌了，把牌隐藏
        if (self.model.uid ~= USER.uid) then
            self:otherFlod()
        end
    end
    if status == 0 or status == 10 or self.model._pre_status == 10 then
        if self.model.uid then
            -- self.parts["uname"]:setString(utils.suffixStr(self.model.uid.."",5))
            self.parts["uname"]:setString(utils.suffixStr(self.model.uname,5))
        end
    end
    if status > 0  and status < 6 or status == 8 then
       self.parts["uname"]:setString(CONFIG.status[status])
    end
    self.model.status = status
    self.model._pre_status = status
end

function Seat:otherFlod()
    self:setOpacity(100)

    -- local card1 = self.parts["small_cards"].card1
    -- local card2 = self.parts["small_cards"].card2
    -- local ccp1 = card1:convertToNodeSpace(cc.p(display.cx,display.height+150))
    -- local ccp2 = ccp1
    -- local distance = utils.distancePoints(ccp1,cc.p(0,0))
    -- local t = distance /1500
    -- local a11 = cc.MoveTo:create(t,cc.p(ccp1.x,ccp1.y))
    -- local a12 = cc.RotateTo:create(t,-200)
    -- local card1_action = cc.Spawn:create({a11,a12})
    -- card1:runAction(card1_action)

    -- local a21 = cc.DelayTime:create(0.05)
    -- local a22 = cc.MoveTo:create(t,cc.p(ccp2.x,ccp2.y))
    -- local a23 = cc.RotateTo:create(t,120)
    -- local card2_action = transition.sequence({a21,cc.Spawn:create({a22,a23})})
    -- card2:runAction(card2_action)
    -- self:performWithDelay(function ( ... )
    --     transition.stopTarget(card2)
    --     transition.stopTarget(card1)
    --     card1:setVisible(false)
    --     card1:setPosition(card1._x,card1._y)
    --     card1:setRotation(8)
    --     card2:setVisible(false)
    --     card2:setPosition(card2._x,card2._y)
    --     card2:setRotation(22)
    -- end,1)

end

function Seat:changeName(name)
    if not name or (name == "") then
        self.parts["uname"]:setString("")
        return
    end
    self.parts["uname"]:setString(utils.suffixStr(name,5))
end

function Seat:emptySit()
    self:hideWin()
    self.model.uid = nil
    self:stopChipin()
    self:changeStatus(0)
    self:changeName("")
    self:changeBuying(false)
    -- 清理掉头像
    if self.parts["head"] then
        self.parts["head"]:setVisible(false)
    end
    if checkint(USER.seatid) > 0 then
        self:changeSitStatus(1)
    else
        self.parts["sit"]._open = true
        self:changeSitStatus(0)
    end
    if self.model.uid == USER.uid then
        self:changeCard(0)
    end
    self:setCardsVisible(false)  --清空座位隐藏牌
    if self.parts["clock"] then
        self.parts["clock"]:setVisible(false)
        self.parts["clock"]:stop()
    end
end

function Seat:changeCard(vals)
    local hand_cards = self.parts["hand_cards"]
    local card1 , card2 = hand_cards.card1,hand_cards.card2
    if type(vals) ~= "table"  or not checkint(vals[1]) or not checkint(vals[2])  then
        -- self:setCardsVisible(false)
        -- card1:changeVal(0)
        -- card2:changeVal(0)
        hand_cards:setVisible(false)
        self.model.cards = nil
    else
        -- self:setCardsVisible(true)
        hand_cards:setVisible(true)
        card1:changeVal(vals[1])
        card2:changeVal(vals[2])
        self.model.cards = vals
    end
    if self.model.uid == USER.uid then
        self:setCardsVisible(false)
    end
end

function Seat:setCardsVisible(flag)
    self.parts["small_cards"].card1:setVisible(flag)
    self.parts["small_cards"].card2:setVisible(flag)
end

function Seat:changePos(pos_id,isself)
    self.model.pos_id = pos_id
    local chipin = self.parts["chipin"]
    local small_cards = self.parts["small_cards"]

    local _size = cc.size(192, 192)
    chipin:setPosition(self.chipinPos[pos_id])
    chipin.label:setPositionY(self.chipinPos[pos_id].y)
    chipin.label:setPositionX(self.chipinPos[pos_id].x + 30)
    if table.indexOf({4,5},pos_id) then
    	small_cards:setPositionX(-80)
    	small_cards:setRotation(-30)
    else
        small_cards:setPositionX(80)
        small_cards:setRotation(0)
    end

    if isself then
    	small_cards:setVisible(false)
    end
end

function Seat:showWin(_type,win)
    self.parts["anim_win"]:setVisible(true)
    if _type == 0 then
        self.parts["win"]:setVisible(true)
    end
    self.parts["uname"]:setString(CONFIG.cardtypes[_type])
    self.parts["anim_win"]:playAnimationForever(display.getAnimationCache("anim_win"))
    if self.model.uid == USER.uid then
        utils.playSound("win")
    end
end

function Seat:hideWin( )
    self.parts["win"]:setVisible(false)
    self.parts["anim_win"]:setVisible(false)
    self.parts["anim_win"]:stopAllActions()
end

function Seat:changeSitStatus(status) -- 0 坐下 1 空位 3 清空
    local sit = self.parts["sit"]
    if status == 0 and sit._open then
        if checkint(self.model.uid) > 0 then return end
        sit:setString("坐下")
        self.parts['sit_arr']:setVisible(true)
        sit._open = false
        transition.fadeTo(sit,{
            opacity = 255,
            time = 0.3
        })
    elseif status == 1 and not sit._open then
        if checkint(self.model.uid) > 0 then return end
        self.parts['sit_arr']:setVisible(true)
        self:setOpacity(150)
        sit:setString("空位")
        sit._open = true
        transition.fadeTo(sit,{
            opacity = 255*0.45,
            time = 0.3
        })
    elseif status == 3 then
        self.parts['sit_arr']:setVisible(false)
        sit:setString("")
    end
end

function Seat:changeUser(udata)
    if not (udata and udata.uid and udata.buying) then
        self:emptySit()
        return false
    end
    self.parts["head"]:setVisible(true)
    self:setVisible(true)
    -- self:changeName(udata.uname)
    self:changeName(udata.uid .."")
    table.merge(self.model,udata)
    if USER.uid ~= udata.uid then
        if udata.status == nil or table.indexOf({0,1,10}, udata.status) then --如果有牌，玩家坐下
            self:setCardsVisible(false)  --隐藏牌
        else
            self:setCardsVisible(true)  --显示牌
        end
    end
    self:changeSitStatus(3)
    self:changeBuying(udata.buying)
    self:changeChipin(udata.chipin)
    self:changePic(udata.upic)
    self:changeStatus(udata.status)
    self:changePos(self.model.pos_id)  -- bu quedingd d1
end

function Seat:startChipin(data)
    if self.parts["clock"] then
        -- self.parts["clock"]:setCardsVisible(true)
        self.parts["clock"]:start(data.gap_sec)
    end
end

function Seat:stopChipin()
    if self.parts["clock"] then
        self.parts["clock"]:setVisible(false)
        self.parts["clock"]:stop()
    end
end

function Seat:animation(id)
    self.parts["anim_win"]:setVisible(true)
    local ids = {13,13,11,10,11}
    if not  display.getAnimationCache("interact_anim_"..id) then
        local frames = display.newFrames("room/animation/"..id.."%02d.png", 1, ids[id])
        display.setAnimationCache("interact_anim_"..id, display.newAnimation(frames, 1.5 / 12))
    end

    self.parts["anim_win"]:playAnimationOnce(display.getAnimationCache("interact_anim_"..id),false,function (  )
        self.parts["anim_win"]:stopAllActions()
        self.parts["anim_win"]:setVisible(false)
    end)
end

return Seat