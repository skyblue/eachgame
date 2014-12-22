local Clock  =  class("Clock",display.newNode)

function Clock:ctor(second)
    self.second = second
    local progress = cc.ProgressTimer:create(display.newSprite("#room/daojishi-chang.png"))
    progress:setType(display.PROGRESS_TIMER_RADIAL)
    self:addChild(progress)
    self.arc = progress
    self.arc:setReverseDirection(true)
end


function Clock:_timer(val)
    return function()
        val = val - 1
        if val == 0 then
            -- self:trigger("timeout")
            self:setVisible(true)
            self:stop()
            self.arc:setPercentage(100)
        end
        if val < -1 then
            self:setVisible(false)
            self:stop()
        end

        local str = val
        if val < 10 and val > 0 then
            str = "0" .. str
        end
        self.num:setString(str)
    end
end

function Clock:start(second,isshow_num)
    second = second or 10
    self:setVisible(true)
    color1 = 38
    color2 =230
    local is_delay = second/self.second

    self.arc:getSprite():setColor(cc.c3b(color1,color2,0))
    local a1 = cc.ProgressFromTo:create(second,is_delay * 100,0);
    self.arc:runAction(a1)
    self.step = 8
    if second < 15 then
        self.step = 10
    end
    if is_delay ~= 1 then
        self.step = self.step * self.second / second
    end
    if not self.set_color_id then
        self.set_color_id = self:schedule(self:_setColor(),0.3)
    end
end

local color1 = 38
local color2 = 230
function Clock:_setColor( )
    return function ()
        -- dump(self.step)
        self.arc:getSprite():setColor(cc.c3b(color1,color2,0))
        if color1 >= 240 then
            self.step = - math.abs(self.step)
            color1= 255
        end
        if self.step < 0 then
            color2 = color2 + self.step
            if color2 <= 0 then
                color2 = 0
            end
        else
            color1 = color1 + self.step
        end
    end

end

function Clock:stop()
    color1 = 38
    color2 =230
    self.arc:getSprite():setColor(cc.c3b(color1,color2,0))
    if self.set_color_id then
        transition.removeAction(self.set_color_id)
        self.set_color_id = nil
    end
    transition.stopTarget(self.arc)
    self:setVisible(false)
end


return Clock