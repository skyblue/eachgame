local Clock  =  class("Clock",display.newNode)

function Clock:ctor()
    self.round = display.newSprite("#room/daojishi-chang.png")

    local progress = cc.ProgressTimer:create(self.round)
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
    second = second or 15
    -- second = 15
    self.second = second
    self:setVisible(true)
    -- self.num:setString(_s(second))
    color1 = 38
    color2 =230
    local a1 = cc.ProgressFromTo:create(second,100,0);
    self.arc:runAction(a1)
    -- if isshow_num == true then
    --     self.num:setVisible(true)
    --     self.tid = self:schedule(self:_timer(second),1)
    -- end
    local step = 0.08
    if second < 15 then
        step = 0.12
    end
    -- self.set_color_id = self:schedule(self:_setColor(1),0.1) --手动设置颜色值
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, self:_setColor(step))
    self:scheduleUpdate()
end
local color1 = 38
local color2 = 230
function Clock:_setColor( step )
    return function ()
        self.round:setColor(cc.c3b(color1,color2,0))
        if color1 >= 240 then
            step = - math.abs(step)
            color1= 255
        end
        if step < 0 then
            color2 = color2 + step
            if color2 <= 0 then
                color2 = 0
            end
        else
            color1 = color1 + step
        end
    end

end

function Clock:stop()
    color1 = 38
    color2 =230
    self.round:setColor(ccc3(color1,color2,0))
    self:unscheduleUpdate()
    transition.stopTarget(self.arc)
    self:setVisible(false)
end


return Clock