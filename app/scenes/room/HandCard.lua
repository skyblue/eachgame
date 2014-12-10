local HandCard = class("HandCard",display.newNode)

function HandCard:ctor()
	local card1 = Card.new()
	local card2 = Card.new()
	self.card1 = card1
	self.card2 = card2
	self:addChild(card1)
	self:addChild(card2)
	card1._origin_pos = {x=-18,y=0}
    card2._origin_pos = {x=18,y=0}
    card1._origin_rotation = -5
    card2._origin_rotation = 5
    card1:setRotation(card1._origin_rotation)
    card2:setRotation(card2._origin_rotation)
    card1:setPosition(card1._origin_pos.x,card1._origin_pos.y)
    card2:setPosition(card2._origin_pos.x,card2._origin_pos.y)
end

return HandCard