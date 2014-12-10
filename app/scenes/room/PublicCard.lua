local PublicCard = class("PublicCard",display.newNode)

function PublicCard:ctor()
	self.cards ={}
	for i=1,5 do
		self.cards[i] = Card.new()
		self.cards[i]:setPositionX(130 * (i-1))
		self.cards[i]:setVisible(false)
		self:addChild(self.cards[i])
	end
end

function PublicCard:showCard(from,to,val)
	if to >= 5 then to = 5 end
	self.val = val
	local card
	local delay = 0
	for i=from,to do
		card = self.cards[i]
		card:setVisible(true)
		if card.value ~= val[i] then
			card:changeVal(val[i])
		end
	end
end

function PublicCard:moveCard(from,to,val)
	if to >= 5 then to = 5 end
	local card
	local delay = 0
	for i=from,to do
		card = self.cards[i]
		card:changeVal(val[i], true)
	    local seq = transition.sequence({
	        cc.DelayTime:create(delay),
	        cc.MoveTo:create(0.3, cc.p(137 * (i-1),-125))
	    })
	    card:runAction(seq)
		delay = delay + 0.1
	end
end


function PublicCard:reset()
	for i,v in ipairs(self.cards) do
		v:setVisible(false)
		v:changeVal(0)
	end
end



return PublicCard