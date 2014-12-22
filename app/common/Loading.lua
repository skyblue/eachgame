local Loading = class("Loading", function()
    return display.newScene("Loading")
end)

function Loading:ctor(time,num)
	num = num or 100
	time = time or 0.5
	local bg = display.newSprite("img/loading-bg.png",display.cx,display.cy)
    :addTo(self)
    if display.height > 960 then
        bg:setScale(display.height/960)
    end
    display.newSprite("#common/l-progress-bg.png",display.cx,display.height * 0.2)
    :addTo(self)
	local progress = display.newProgressTimer("#common/l-progress.png",display.PROGRESS_TIMER_BAR)
	progress:setMidpoint(cc.p(0,0.5))
	progress:setBarChangeRate(cc.p(1.0,0))
	progress:setPosition(display.cx,display.height * 0.2)
	self:addChild(progress)
	local a1 = cc.ProgressFromTo:create(0.5,0,num);
    progress:runAction(a1)
    self.progress = progress
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
	display.removeSpriteFrameByImageName("img/loading-bg.png")
	_.Loading = nil
end

return Loading