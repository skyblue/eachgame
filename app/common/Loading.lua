local Loading = class("Loading", function()
    return display.newScene("Loading")
end)

function Loading:ctor(time,num)
	display.addSpriteFrames("img/loading.plist","img/loading.png")
	num = num or 100
	time = time or 0.5
	local bg = display.newSprite("img/hall-bg.png",display.cx,display.cy)
    :addTo(self)
    if display.height > 960 then
        bg:setScale(display.height/960)
    end
    display.newSprite("#loading/bg.png",display.cx,display.cy)
    	:addTo(self)
	local progress = display.newProgressTimer("#loading/progress.png",display.PROGRESS_TIMER_RADIAL)
	-- progress:setMidpoint(cc.p(0,0.5))
	-- progress:setBarChangeRate(cc.p(1.0,0))
	progress:setPosition(display.cx,display.cy)
	progress:setReverseDirection(true)
	self:addChild(progress)
	local a1 = cc.ProgressFromTo:create(0.5,0,num)
    progress:runAction(a1)
    self.progress = progress
    display.newSprite("#loading/girl.png",display.cx,display.cy)
    	:addTo(self)
end

function Loading:show(user)
	
end

function Loading:setProgress(time,num )
	-- self.progress:setPercentage(num)
	time = time or 0.01
	num =  num or 100
	local a1 = cc.ProgressFromTo:create(time, self.progress:getPercentage(),num);
    self.progress:runAction(a1)
end

function Loading:hide()
	self:removeSelf()
	display.removeSpriteFramesWithFile("img/loading.plist","img/loading.png")
	display.removeSpriteFrameByImageName("img/loading-bg.png")
end

return Loading