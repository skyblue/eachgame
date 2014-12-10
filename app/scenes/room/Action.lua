local Action = class("Action",display.newNode)

function Action:ctor()
	self.parts = {}
    self.steps ={}
    self:initBtn()
    self:initRaise()
    self:initHandCard()
end

function Action:action(actionCode)
	return function ( event )
		dump(actionCode)
        if actionCode ==  CON__USER_FOLD then
            self:fold()
        else

        end
        SendCMD:chipinAction(0,actionCode)
	end
end

function Action:showRaise()
    self.parts["raise_mask"]:setVisible(true)
end

function Action:hideRaise()
    self.parts["cycle-raise"]:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("common/green-btn.png"))
    self.parts["raise_mask"]:setVisible(false)
end

function Action:initRaise()
    local raiseLayer = display.newNode()
        :pos(display.cx-160,326)
        :addTo(self)
    self.parts["raiseLayer"] = raiseLayer
    local raise = display.newSprite("#common/green-btn.png",0,-266)
        :addTo(raiseLayer)
    raise:setVisible(false)
    self.parts["cycle-raise"] = raise
    local mask = display.newSprite("#room/jiama-bg.png")
        :addTo(raiseLayer)
    self.parts["raise_mask"] = mask
    cc.ui.UILabel.new({text = "加注", size = 40, font = "Helvetica-Bold"})
        :align(display.CENTER, 140, 60)
        :addTo(raise)
    mask:setVisible(false)
    raiseLayer:setTouchEnabled(true)
    raiseLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT,self:raise())

    local chipin =display.newSprite("#room/raise-handle.png",154,104)
        :addTo(mask)
    chipin.lable = cc.ui.UILabel.new({
            text = "$ 900", 
            size = 30,
            color = cc.c3b(255,255,255),
            font = "Helvetica-Bold"})
        :align(display.CENTER,  - 140,chipin:getContentSize().height/1.8)
        :addTo(chipin)
    self.parts["chipin"] = chipin

end

function Action:raise()
    self.options ={
        max_raise = 2000,
        checkints_allin = true
    }
    local raise_val,changeY = 0,0
    local _start_line,max_line = 104,580
    local steps,divi_len,_new_y,idx
    return function (event)
        -- event.y = event.y
        -- dump(event.y)
        if event.name == "began" then
            self.parts["cycle-raise"]:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("room/anniu-2.png"))
            self.parts["raise_mask"]:setVisible(true)
            steps = self:genSteps(2000 , 20)
            steps_len = math.max(1,#steps)
            divi_len = ((max_line - _start_line) / steps_len);
            return true
        elseif event.name=='moved' then
            if event.y <= _start_line then
                raise_val = 0 
                self.parts["chipin"]:setPositionY(_start_line)
            elseif event.y >= max_line then
                raise_val = self.options.max_raise
                self.parts["chipin"]:setPositionY(max_line)
            else
                self.parts["chipin"]:setPositionY(event.y)
                changeY = event.y - _start_line
                idx = math.min(steps_len,math.ceil(changeY/divi_len))
                raise_val = steps[idx]
                -- dump("idx:",idx,changeY,divi_len,#steps)
                if event.y >= max_line then
                    idx = steps_len + 1
                    raise_val = self.options.max_raise
                end
                -- dump(raise_val)
                --判断是否allin
            end
            local is_allin = (self.options.checkints_allin and (checkint(raise_val) >= checkint(self.options.max_raise)))
            -- 显示ALL IN
            if is_allin then
                self.parts["chipin"].lable:setColor(cc.c3b(255,0,0))
            else
                self.parts["chipin"].lable:setColor(cc.c3b(255,255,255))
            end
            self.parts["chipin"].lable:setString("$".. utils.numAbbr(raise_val))
        elseif event.name=='ended' then
            if raise_val > 0 then
                --发送socket消息
                SendCMD:chipinAction(raise_val,actionCode)
                --发送完消息重置下ui
                self:hideRaise()
                self.parts["chipin"]:setPositionY(_start_line)
                self.parts["chipin"].lable:setString("$0")
                raise_val = 0
            end
        end
        
    end
end


function Action:initBtn()
	local parts = self.parts
    parts["cycle-check"] = cc.ui.UIPushButton.new("#common/green-btn.png", {scale9 = true})
                :setButtonSize(280, 104)
                :setButtonLabel(cc.ui.UILabel.new({text = "看牌", size = 40, font = "Helvetica-Bold"}))
                :pos(110  ,60)
                :onButtonPressed(function(event)
                	-- sprite:runAction(cc.TintBy:create(0,-128,-128,-128))
                end)
                :onButtonRelease(function(event)
                	-- sprite:runAction(cc.TintBy:create(0,255,255,255))
                end)
                :onButtonClicked(self:action(CON__USER_CHECK))
                :addTo(self)
    parts["cycle-check"]:setVisible(false)

    parts["cycle-fold"] = cc.ui.UIPushButton.new("#common/green-btn.png", {scale9 = true})
                :setButtonSize(280, 104)
                :setButtonLabel(cc.ui.UILabel.new({text = "弃牌", size = 40, font = "Helvetica-Bold"}))
                :pos(display.cx - 450 ,60)
                :onButtonPressed(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,-128,-128,-128))
                end)
                :onButtonRelease(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,255,255,255))
                end)
                :onButtonClicked(self:action(CON__USER_FOLD))
                :addTo(self)
    parts["cycle-fold"]:setVisible(false)
    parts["cycle-call"] = cc.ui.UIPushButton.new("#common/green-btn.png", {scale9 = true})
                 :setButtonSize(280, 104)
                :setButtonLabel(cc.ui.UILabel.new({text = "跟注", size = 40, font = "Helvetica-Bold"}))
                :pos(display.cx - 450 ,60)
                :onButtonPressed(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,-128,-128,-128))
                end)
                :onButtonRelease(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,255,255,255))
                end)
                :onButtonClicked(self:action(CON__USER_CALL))
                :addTo(self)
    parts["cycle-call"]:setVisible(false)
                -- :setColor(cc.c3b())
end


function Action:startChipin(data,seat)
    self:hideAction()
    self.parts['cycle-fold']:setVisible(true)

    self.seat = seat
    -- utils.playSound("轮到玩家");
    self._activating = true
    self._touched = false
    data.buying = checkint(seat.model.buying)
    data.chipin = checkint(seat.model.chipin)
    data.min_raise = checkint(data.min_raise)
    data.max_raise = checkint(data.max_raise)
    data._can_check = ( (data.need_call == 0)  or  (data.need_call == data.chipin) ); --是否允许看牌
    data.checkints_allin = (data.buying <= (data.max_raise - data.chipin)); --最大值是否是allin
    local _allchips = data.buying + data.chipin;
    data._can_raise =  (data.min_raise > 0) and (_allchips > data.need_call)
    data.max_raise = math.min(data.max_raise, data.chipin + data.buying)
    self.options = data

    self._steps = self:genSteps(data.buying + data.chipin , data.b_blind)
    self.steps = {data.min_raise}
    for i,v in ipairs(self._steps) do
        if v >= data.max_raise then break end
        if v > data.min_raise  then
            table.insert(self.steps,v)
        end
    end

    -- if data.checkints_allin then
    --     self.parts['cycle-allin']:setVisible(true)
    -- end
    if(data._can_check) then
        self.parts['cycle-check']:setVisible(true)
        self.parts['cycle-raise']:getButtonLabel():setString("下注")
        --也许有必要设置下颜色
        self.parts['cycle-raise'].action = "bet"
    else
        self.parts['cycle-call']:setVisible(true)
        local val = data.need_call - data.chipin
        if val <= 0 then
            val =  data.need_call
        end
        if(val >= data.buying) then
            val = data.buying
        end
        self.parts['cycle-call'].value = val
        self.parts["cycle-call"].callNum:getButtonLabel():setString(utils.numAbbr(val))

        if self.parts['cycle-raise'].action == "bet" then
            self.parts['cycle-raise'].action = "raise"
            self.parts['cycle-raise']:getButtonLabel():setString("加注")
        end
    end

    if(data._can_raise) then
        self.parts['cycle-raise']:setVisible(true)
    end
    self.seat.startChipin(data)
    -- self.parts["clock"]:start(data.gap_sec, true)
    -- local sec = self.parts["clock"].second
    self._tid_vibrate = scheduler.performWithDelayGlobal(function ( )
        device.vibrate()
    end,data.gap_sec*0.5)
end

function Action:hideAction()
     local hides = {
        "cycle-raise",
        "cycle-check",
        "cycle-call",
        "cycle-fold",
    }
    for _,p in ipairs(hides) do
        self.parts[p]:setVisible(false)
    end
end

function Action:stopChipin()
    self._activating = false
    self:hideAction()
    -- self.parts["clock"]:stop()
    self.seat:stopChipin()
    if self._tid_vibrate then
        scheduler.unscheduleGlobal(self._tid_vibrate)
        self._tid_vibrate = nil
    end
end

function Action:genSteps(max,step)
    if checkint(step) <= 0 then step = 2 end
    local steps = {}
    for v = step,step*10,step do
        table.insert(steps,v)
    end
    local next_ = steps[#steps]
    local n_step = step
    local i = 1
    while next_ < max do
        n_step = 10^(#(tostring(next_))-1) * 0.5
        next_ = next_ + n_step
        table.insert(steps,next_)
        i = i+1
        if i > 10000 then table.insert(steps,max) break end
    end
    -- dump(#steps)
    -- dump(table.concat(steps,","))
    return steps
end

function Action:fold(  )
    local card1,card2 = self.parts["hand_cards"].card1,self.parts["hand_cards"].card2
    transition.stopTarget(card1)
    transition.stopTarget(card2)
    local t = 0.4
    local a11 = cc.MoveTo:create(t,cc.p(0,display.top + 200))
    local a12 = cc.RotateTo:create(t,-200)
    local card1_action = cc.Spawn:create({a11,a12})
    card1:runAction(card1_action)

    local a21 = cc.DelayTime:create(0.05)
    local a22 = cc.MoveTo:create(t,cc.p( 80,display.top + 200))
    local a23 = cc.RotateTo:create(t,120)
    local card2_action = transition.sequence({a21,cc.Spawn:create({a22,a23})})
    card2:runAction(card2_action)
end

function Action:resetHandCard()
    local card1,card2 = self.parts["hand_cards"].card1,self.parts["hand_cards"].card2
    -- card1:setRotation(card1._origin_rotation)
    -- card2:setRotation(card2._origin_rotation)
    card1:setPosition(card1._origin_pos.x,card1._origin_pos.y)
    card2:setPosition(card2._origin_pos.x,card2._origin_pos.y)
end

function Action:initHandCard( )
    local hand_cards = display.newNode()
    local card1,card2 = Card.new(0),Card.new(0)
    hand_cards.card1,hand_cards.card2 = card1,card2
    hand_cards:addChild(card1)
    hand_cards:addChild(card2)
    card1._origin_pos = { x = - 20, y = 0}
    card2._origin_pos = { x = 20, y = 0}
    -- card1._origin_rotation = -10
    -- card2._origin_rotation = 10
    self.parts["hand_cards"] = hand_cards
    card1:setVisible(false)
    card2:setVisible(false)
    hand_cards:setScale(0.8)
    hand_cards:pos(190,230)
    self:addChild(hand_cards,19)
    self:resetHandCard()
end 

function Action:changeCard(vals)
    local hand_cards = self.parts["hand_cards"]
    local card1 , card2 = hand_cards.card1,hand_cards.card2
    if type(vals) ~= "table"  or not checkint(vals[1]) or not checkint(vals[2])  then
        card1:setVisible(false)
        card2:setVisible(false)
        card1:changeVal(0)
        card2:changeVal(0)
    else
        card1:setVisible(true)
        card2:setVisible(true)
        card1:changeVal(vals[1])
        card2:changeVal(vals[2])
        if self.seat then
            self.seat.model.cards = vals
            --弃牌
            if self.seat.model.status == 1 then
                    transition.fadeTo(self.seat ,{
                        opacity = 255*0.45,
                        time = 0.3
                    })
            end
        end
    end
    
end

return Action