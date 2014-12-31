MinMission = class("MinMission",display.newNode)

function MinMission:ctor()
    local bg = display.newSprite("#room/menu-bg.png",display.cx,display.cy)
        :addTo(self)
    self.bg = bg
    self:setContentSize(display.width,display.height)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT,self:onTouch())
    self:init()
    self:show()
end

function MinMission:show()
	self.bg:setScale(0.4)
    transition.scaleTo(self.bg,{
        time   = 0.25,
        scale  = 1,
        easing = "BACKOUT"
    })
    self:setTouchEnabled(true)

end

function MinMission:hide()
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

function MinMission:init(data)
	data = {
            {title = "任务任务任务任务",content = "sdfa",chips = 1000,complete=1,need_complete= 10},
            {title = "任务任务",content = "苦功afas压根堙要要模压模仿wfasd会想人解体顶起结圾持基建" ,chips = 1000,complete=9,need_complete= 10},
            {title = "任务任务",content = "苦功羁左边国找泊害枯萎仍共fafas压根堙要要泡泡糖炒炒炒械塔顶栽ewfsad模压模仿wfasd会想人解体顶起结圾持基建" ,chips = 1000,complete=10,need_complete= 10},
            {title = "任务任务",content = "苦功羁左边国找泊害枯萎仍共faf国找泊害枯萎仍共fafas国找泊害枯萎仍共fafas国找泊害枯萎仍共fafas国找泊害枯萎仍共fafas国找泊害枯萎仍共fafasas压根堙要要泡泡糖 炒炒 炒械塔顶栽 ewfsad 模压模仿wfasd会想人解体顶起结圾持基建" ,chips = 1000,complete=10,need_complete= 100},
            {title = "任务任务",content = "苦功羁左边国找泊害枯萎仍共fafas压根堙要要泡泡糖炒炒炒械塔顶栽ewfsad模压模仿wfasd会想人解体顶起结圾持基建" ,chips = 1000,complete=10,need_complete= 10},
            {title = "任务任务",content = "苦功羁左边国找泊害枯萎仍共fafas压根堙要要泡泡糖炒炒炒械塔顶栽ewfsad模压模仿wfasd会想人解体顶起结圾持基建" ,chips = 1000,complete=10,need_complete= 10},
            {title = "任务1",content = "苦功羁左边国找泊害枯萎仍共fafas压根堙要要泡泡糖炒炒炒械塔顶栽ewfsad模压模仿wfasd会想人解体顶起结圾持基建" ,chips = 1000,complete=10,need_complete= 101},
            {title = "任务1",content = "苦功羁左边国找泊害枯萎仍共fafas压根堙要要泡泡糖炒炒炒械塔顶栽ewfsad模压模仿wfasd会想人解体顶起结圾持基建" ,chips = 1000,complete=10,need_complete= 10},
            {title = "任务1",content = "苦功羁左边国找泊害枯萎仍共fafas压根堙要要泡泡糖炒炒炒械塔顶栽ewfsad模压模仿wfasd会想人解体顶起结圾持基建" ,chips = 1000,complete=10,need_complete= 10},
            {title = "任务1",content = "苦功羁左边国找泊害枯萎仍共fafas压根堙要要泡泡糖压模仿wfasd会想人解体顶起结圾持基建" ,chips = 1000,complete=10,need_complete= 10},
            {title = "任务任务",content = "苦功羁左边国找泊害枯萎仍共fafas压根堙要要泡泡糖压模仿wfasd会想人解体顶起结圾持基建" ,chips = 1000,complete=10,need_complete= 10},
            {title = "任务1",content = "苦功羁左边国找泊害枯萎仍共fafas压根堙要要泡泡模仿wfasd会想人解体顶起结圾持基建" ,chips = 1000,complete=10,need_complete= 10},
            {title = "任务1",content = "苦功羁左边国找泊害枯萎仍共fafas压根堙要要泡泡模仿wfasd会想人解体顶起结圾持基建" ,chips = 1000,complete=10,need_complete= 10},
            {title = "任务1",content = "苦功羁左边国找泊害枯萎仍共fafas压根堙要要泡泡模仿wfasd会想人解体顶起结圾持基建" ,chips = 1000,complete=10,need_complete= 10},
            }
	local bg = self.bg
	self.list = cc.ui.UIListView.new {
            viewRect = cc.rect(0,4, bg:getContentSize().width, bg:getContentSize().height-8),
            direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
            }
        :addTo(bg)
	local height,item,line,content,text = 120
    for k,v in pairs(data) do
        item = self.list:newItem()
        item.id = v.id
        content = display.newNode()
        line = display.newSprite("#common/line.png",0,height/2)
            :addTo(content)
        line:setScaleX(0.5)
        display.newSprite("#chip-blue.png", -bg:getContentSize().width/2 + 30,-32)
                :addTo(content)
        cc.ui.UILabel.new({text = v.title, 
            size = 40,
            dimensions = cc.size(200, 0)})
            :align(display.LEFT_CENTER,-bg:getContentSize().width/2 + 10,25)
            :addTo(content)
        cc.ui.UILabel.new({text = "$".. utils.numAbbr(v.chips), color = cc.c3b(254,221,70), size = 40})
            :align(display.CENTER,-bg:getContentSize().width/2 + 120,-30)
            :addTo(content)
        item.completeBtn = cc.ui.UIPushButton.new("#common/verifycode.png",{scale9 = true})
	            :setButtonSize(120, 70)
	            :setButtonLabel(cc.ui.UILabel.new({text = "领取", size = 40, font = "Helvetica-Bold"}))
	            :align(display.CENTER,bg:getContentSize().width/2 -80,0)
	            :onButtonPressed(function(event)
	                    -- sprite:runAction(cc.TintBy:create(0,-128,-128,-128))
	            end)
	            :onButtonRelease(function(event)
	                    -- sprite:runAction(cc.TintBy:create(0,255,255,255))
	            end)
	            :onButtonClicked(function (event)
                   SendCMD:completeMission(v.id)
	            end)
	            :addTo(content)

		item.content = content
        item:addContent(content)
        item:setItemSize(bg:getContentSize().width,height)
        self.list:addItem(item)
    end
    self.list:reload()
end

function MinMission:onTouch()
    local layer = self
    return function(event)
        local touched = self.bg:getCascadeBoundingBox():containsPoint(cc.p(event.x,event.y))
        if not touched then
            self:hide()
        end
        return true
    end
end

return MinMission