local Pot  =  class("Pot",display.newNode)

function Pot:ctor(roomdata)
    local tip = cc.ui.UILabel.new({
        UILabelType = 2,
        text = "$ " ..roomdata.s_blind .."/" .. roomdata.b_blind,
        font = "Helvetica",
        color = cc.c3b(119,192,138),
        size = 30})
        :align(display.CENTER,0,60)
        :addTo(self)
    tip:setOpacity(170)
    local label_bg = display.newSprite("#room/chouma-bg.png")
        :addTo(self)
    local potLable = ""
    if roomdata.pots > 0 then
        potLable = roomdata.pots ..""
    end
    local label = cc.ui.UILabel.new({
        UILabelType = 2,
        text = potLable,
        color = cc.c3b(254,221,70),
        size = 36})
        :align(display.CENTER,109,25)
        :addTo(label_bg)
    
    label_bg:setVisible(false)
    self.label = label
    self.label_bg = label_bg
	self.batchChip = Chip:getBatchNode(20)
    label_bg:addChild(self.batchChip)
    self.chip = Chip.new(nil,math.random(1,4),0,25,self.batchChip)
end

function Pot:changeVal(data)
    local val = checkint(data.bottom_pots)
    self:clear()
    -- self.label:setVisible(true)
    
    if not val or val <= 0 then
        self.val = 0
        self.label_bg:setVisible(false)
        self.label:setString("")
    else
        self.val = val
        self.label_bg:setVisible(true)
        self.label:setString(utils.numAbbr(val))
        -- for i=1,5,1 do
        --     -- local c = Chip.new(nil,math.random(1,4),math.random(-10,10),math.random(-25,25),self.batchChip)
        --     local c = Chip.new(nil,math.random(1,4),-109,0,self.batchChip)
        --     table.insert(self.chips,1,c)
        -- end
    end
end

function Pot:clear()
    self.val = 0
    self.label:setString("")
    self.label_bg:setVisible(false)
end

function Pot:moveToSeat(seat,val)
    
    local to_pos = seat:convertToWorldSpace(cc.p(88,48))
          to_pos = self:convertToNodeSpace(to_pos)

    local _incr = 0.05
    local t = 0.5
    local delay,a1,a2,action
    local c = Chip.new(nil,math.random(1,4),0,20,self.batchChip)
    -- for i,c in ipairs(chips) do
        -- delay = cc.DelayTime:create(i*_incr) -- 延时可能需要根据筹码个数来
        a1 = cc.MoveTo:create(t,to_pos)
        a2 = cc.FadeOut:create(t*1.8)
       	-- action = transition.sequence(cc.Spawn:create({a1,a2}))
        action = cc.Spawn:create({a1,a2})
        transition.execute(c,action,{onComplete = function ( ) --以前没移除筹码
            c:removeSelf(true)
            
        end})
    -- end
    -- Chip.new(nil,math.random(1,4),-109,0,self.batchChip)

    self:performWithDelay(function()
    		self:changeVal({bottom_pots = val})
    	end,0.5)
    utils.playSound("move_chips")
end

return Pot