local CardsType = class("CardsType",display.newNode)

function CardsType:ctor()
	 local mask = cc.LayerColor:create(cc.c4b(0,0,0,0))
        :addTo(self)
    mask:setContentSize(display.cx/2,display.height)
    mask:setOpacity(190)
    mask:setPositionX(-display.cx/2)
    local card_type = display.newSprite("#room/cards-type.png",102,display.cy)
    	:addTo(mask)
    local yy = 50
	for i,v in ipairs(CONFIG.cardtypes) do
        if i > 1 then
    		cc.ui.UILabel.new({
                UILabelType = 2,
                text = v,
                size = 40,
                })
                :align(display.CENTER,306,yy)
                :addTo(card_type)
            yy = yy + 106
        end
	end
    self.mask = mask
    -- self:show()
    self:setContentSize(display.width,display.height)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT,self:onTouch())
end

function CardsType:onTouch()
    local layer = self
    return function(event)
        local touched = self.mask:getCascadeBoundingBox():containsPoint(cc.p(event.x,event.y))
        if not touched then
            self:hide()
        end
    end
end

function CardsType:show()
    self:setTouchEnabled(true)
    transition.moveTo(self, {
        x = display.cx/2,
        easing = "BACKOUT",
        time = 0.3,
        })
end


function CardsType:hide()
    self:setTouchEnabled(false)
     transition.moveTo(self, {
        x = -display.cx/2,
        easing = "BACKIN",
        time = 0.3,
        })
end

return CardsType