local Tips = class("Tips",display.newNode)


function Tips:ctor(msg,x,y)
	local bg = display.newSprite("#common/tip.png",x,y)
        :addTo(self)
    self.bg = bg
    self:setContentSize(display.width,display.height)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT,self:onTouch())
    local text = cc.ui.UILabel.new({
    		text = msg,
	    	size = 40,
	        dimensions = cc.size(350, 0),
	        align = display.CENTER,
	        x = 34,
	        y = bg:getContentSize().height * 0.57,
    	})
    	:addTo(bg)
   	-- text:setPositionY(text:getPositionY())
    self:show()
end

function Tips:onTouch()
    local layer = self
    return function(event)
        -- local touched = self.bg:getCascadeBoundingBox():containsPoint(cc.p(event.x,event.y))
        -- if not touched then
            self:hide()
        -- end
    end
end

function Tips:show()
	self.bg:setScale(0.4)
    transition.scaleTo(self.bg,{
        time   = 0.25,
        scale  = 1,
        easing = "BACKOUT"
    })
    self:setTouchEnabled(true)

end

function Tips:hide()
    self:setTouchEnabled(false)
    transition.scaleTo(self.bg,{
        time = 0.2,
        scale = 0,
        easing = "BACKIN",
        onComplete = function(  )
            self:removeSelf(true)
        end
    })
end

return Tips


