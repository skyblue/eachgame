--[[
分多个事件传入一个handler对象?
listener = {
    show = func
    beforeshow = func
    beforehide =
    hide
    click
}
]]
local Dialog = class("Dialog",display.newLayer)


function Dialog:ctor(title, msg, labels, listener, params)
    -- colors = colors or  {"white","green"}
    self:setContentSize(display.width, display.height)
    self.listener = listener or function() return end

    local dialog = display.newNode()
    dialog:setPosition(display.cx,display.cy)
    local bg = display.newSprite("#common/bg-dialog.png")
    dialog:addChild(bg)
    dialog._size = bg:getContentSize()
    self.bg = bg
    params = checktable(params)
    self.params = params
    params.textAlign = params.textAlign or cc.ui.TEXT_ALIGN_CENTER
    -- if params.mask then
    --     self.mask = utils.mask()
    --     self:addChild(self.mask)
    --     self.mask:show()
    -- end
    if not params.titleSize then
        params.titleSize = 42
    end
    if not params.msgSize then
        params.msgSize = 32
    end

    if #tostring(title) >0 then
        cc.ui.UILabel.new({
            UILabelType = 2,
            text = title,
            font = "Helvetica-Bold",
            size = params.titleSize,
            })
            :align(display.CENTER, 0, dialog._size.height * 0.3)
            :addTo(dialog)
    end


    if #tostring(msg) >0 then
        cc.ui.UILabel.new({
            UILabelType = 2,
            text = msg,
            size = params.msgSize,
            dimensions = cc.size(dialog._size.width - 60,0),
            })
            :align(display.CENTER, dialog._size.width/4 +30, (#tostring(title) > 0) and 50 or 70)
            :addTo(dialog)
    end


    local btns = {}
    local x = dialog._size.width / #labels
    local startX  = #labels  == 1 and 0  or -140
    local startY  = -100
    for i, b in ipairs(labels) do
        local btn = cc.ui.UIPushButton.new(string.format("#common/btn%s.png",i))
            :setButtonLabel(cc.ui.UILabel.new({
                    text = b, 
                    size = 36, 
                    align = cc.ui.TEXT_ALIGNMENT_CENTER,
                    })
                    )
            :align(display.CENTER,startX + 300 * (i-1), startY)
            :onButtonPressed(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,-128,-128,-128))
            end)
            :onButtonRelease(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,255,255,255))
            end)
            :onButtonClicked(function (event)
                local e = {buttonIndex = i,target = btn, name="click"}
                local status, ret = pcall(self.listener, e) --报错的情况
                if status == false then
                    self:hide()
                elseif ret ~= false then
                    self:hide()
                end
            end)
            :addTo(dialog)   
    end
    self.dialog = dialog
    self:addChild(dialog)

    self:addNodeEventListener(cc.NODE_TOUCH_EVENT,self:onTouch())
    self:setTouchEnabled(true)

    dialog:setScale(0.4)
    transition.scaleTo(dialog,{
        time   = 0.25,
        scale  = 1,
        easing = "BACKOUT"
        -- easing = "BOUNCEOUT",
    })
    display.getRunningScene():addChild(self,30)


    if device.platform == "android" then
        self:addNodeEventListener(cc.KEYPAD_EVENT, function(event)
            print(event.name)
        end)
    end

    return self
end

function Dialog:onTouch()
    local layer = self
    return function(event)
        if not self.dialog then return end
        local touched = self.bg:getCascadeBoundingBox():containsPoint(cc.p(event.x,event.y))
        if not touched then
            local status, ret = pcall(function()
                return self.listener({name="cancel", buttonIndex = -1, target = self})
            end)
            self:hide()
        end
        return true
    end
end


function Dialog:hide()
    utils.playSound("click")

    self:setTouchEnabled(false)
    transition.scaleTo(self.dialog,{
        time = 0.2,
        scale = 0,
        easing = "BACKIN",
        onComplete = function(  )
            -- self:removeEventListener()
            return self:removeSelf(true)
        end
    })
end




return Dialog