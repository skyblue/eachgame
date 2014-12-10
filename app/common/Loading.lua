local Loading = class("Loading",display.newNode)

function Loading:ctor()
	display.newSprite("img/loading-bg.png",display.cx,display.cy)
    :addTo(self)
    display.newSprite("img/jiazaijindu01(1).png",display.cx,display.cy)
    :addTo(self)
	local progress = display.newProgressTimer("img/jiazaijindu01(1).png",display.PROGRESS_TIMER_BAR)
	progress:setMidpoint(cc.p(0,0.5))
	progress:setBarChangeRate(cc.p(1.0,0))
	progress:setPosition(display.cx,display.cy)
	progress:setPosition(display.cx,40)
	self:addChild(progress)
	local a1 = cc.ProgressFromTo:create(2,0,100);
    progress:runAction(a1)
    self.progress = progress
end

function Loading:show(user)
	
end

function Loading:setProgress( num )
	-- self.progress:setPercentage(num)

	local a1 = cc.ProgressFromTo:create(0.1,0,100);
    self.progress:runAction(a1)
end

function Loading:hide()
	display.removeSpriteFrameByImageName("img/loading-bg.png")
end

return Loading