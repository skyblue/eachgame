Mission = class("Mission",display.newNode)

function Mission:ctor()
    local mask = cc.LayerColor:create(cc.c4b(0,0,0,0))
            :addTo(self)
    mask:setContentSize(display.width,display.height)
    mask:setOpacity(150)
    
	local bg = display.newSprite("img/myinfo-bg.png",display.cx,display.cy)
        :addTo(self)
    self.parts ={}
    self.parts["bg"] = bg
    self.title = {"任务","邮件","活动"}
    cc.ui.UILabel.new({text = self.title[1] , size = 60})
                :align(display.CENTER,bg:getContentSize().width/2,bg:getContentSize().height-60)
                :addTo(bg)
    cc.ui.UIPushButton.new("#common/close_icon.png")
        :align(display.CENTER,bg:getContentSize().width,bg:getContentSize().height)
        :onButtonPressed(function(event,sprite)
            event.target:runAction(cc.TintTo:create(0,128,128,128))
        end)
        :onButtonRelease(function(event)
            event.target:runAction(cc.TintTo:create(0,255,255,255))
        end)
        :onButtonClicked(function (event)
                self:hide()
                utils.playSound("click")
        end)
        :addTo(bg)
    display.newSprite("#common/btn-list.png",bg:getContentSize().width/2,40)
    :addTo(bg)
    local group = cc.ui.UICheckBoxButtonGroup.new()
        :onButtonSelectChanged(function(event)
            printf("Option %d selected, Option %d unselected", event.selected, event.last)
        end)
        :align(display.CENTER, 0,-28)
        :addTo(bg)
    
    for i=1,#self.title do
        self.parts["menu"..i] = cc.ui.UICheckBoxButton.new({on = "#common/btn-select.png", off = "#common/1px.png"},{scale9 = true})
            :setButtonLabel(cc.ui.UILabel.new({
                    text = self.title[i], 
                    size = 42, 
                    font = "Helvetica-Bold",
                    }))
            :setButtonSize(392, 84)
            :setButtonLabelOffset(-90, -6)
            -- :setButtonEnabled(i == 1 and true or false)
            group:addButton(self.parts["menu"..i])

    end
    group:getButtonAtIndex(1):setButtonSelected(true)

    SendCMD:getMissionlist()
    SocketEvent:addEventListener(CMD.RSP_MISSIONLIST .. "back", function(event)
    	SocketEvent:removeEventListenersByEvent(CMD.RSP_MISSIONLIST .. "back")
    	self:initMission(event.data)
    end)
    -- self:initMission()
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT,self:onTouch())
    self.parts["bg"]:setScale(0.4)
    transition.scaleTo(self.parts["bg"],{
        time   = 0.25,
        scale  = 1,
        easing = "BACKOUT"
    })
    self:setTouchEnabled(true)
end

function Mission:onTouch()
    local layer = self
    return function(event)
        local touched = self.parts["bg"]:getCascadeBoundingBox():containsPoint(cc.p(event.x,event.y))
        if not touched or event.y < 150 or event.y > 970 then
            self:hide()
        end
        return true
    end
end

function Mission:initAction(data)
    
end

function Mission:initMission(data)
    -- data = {}
    -- data = {
    --         {title = "任务任务",content = "sdfa",chips = 1000,complete=1,need_complete= 10},
    --         title = "任务任务",content = "苦功羁左边国找泊害枯萎仍共fafas压根堙要要泡泡糖压模仿wfasd会想人解体顶起结圾持基建" ,chips = 1000,complete=10,need_complete= 10},
    --         {title = "任务1",content = "苦功羁左边国找泊害枯萎仍共fafas压根堙要要泡泡模仿wfasd会想人解体顶起结圾持基建" ,chips = 1000,complete=10,need_complete= 10},
    --         {title = "任务1",content = "苦功羁左边国找泊害枯萎仍共fafas压根堙要要泡泡模仿wfasd会想人解体顶起结圾持基建" ,chips = 1000,complete=10,need_complete= 10},
    --         {title = "任务1",content = "苦功羁左边国找泊害枯萎仍共fafas压根堙要要泡泡模仿wfasd会想人解体顶起结圾持基建" ,chips = 1000,complete=10,need_complete= 10},
    --         }
    local bg = self.parts["bg"]
	self.list = cc.ui.UIListView.new {
            viewRect = cc.rect(0,86, bg:getContentSize().width, bg:getContentSize().height-200),
            direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
            }
        :addTo(bg)
	local height,item,line,content,text  
    for k,v in pairs(data) do
        item = self.list:newItem()
        item.id = v.id
        content = display.newNode()
        text = cc.ui.UILabel.new({text = v.content , 
                size = 36,
                align = cc.ui.TEXT_ALIGN_LEFT,
                valign = cc.ui.TEXT_VALIGN_TOP,
                x = -bg:getContentSize().width/4,
                y = 0,
                dimensions = cc.size(500, 0),
                })
            :addTo(content)
        height = text:getContentSize().height + 20
        line = display.newSprite("#common/line.png",0,height/2)
            :addTo(content)
        line:setScaleX(1.2)
        cc.ui.UILabel.new({text = v.title, 
            size = 40,
            dimensions = cc.size(200, 0)})
            :align(display.LEFT_CENTER,-bg:getContentSize().width/2+30,0)
            :addTo(content)
        
        
        cc.ui.UILabel.new({text = "$".. utils.numAbbr(v.chips), color = cc.c3b(254,221,70), size = 40})
            :align(display.CENTER,320,0)
            :addTo(content)
----------------------------------------------------------------------------
		if v.complete < v.need_complete then
	        item.complete = cc.ui.UILabel.new({text = v.complete.."/"..v.need_complete, size = 40, color = cc.c3b(254,221,70)})
	            :pos(460,0)
	            :addTo(content)
		else
	        item.completeBtn = cc.ui.UIPushButton.new("#common/verifycode.png",{scale9 = true})
	            :setButtonSize(140, 74)
	            :setButtonLabel(cc.ui.UILabel.new({text = "领取", size = 40, font = "Helvetica-Bold",color = cc.c3b(1,78,122)}))
	            :align(display.CENTER,500,0)
	            :onButtonPressed(function(event,sprite)
                    event.target:runAction(cc.TintTo:create(0,128,128,128))
                end)
                :onButtonRelease(function(event)
                    event.target:runAction(cc.TintTo:create(0,255,255,255))
                end)
	            :onButtonClicked(function (event)
                   SendCMD:completeMission(v.id)
	            end)
	            :addTo(content)
		end
		item.content = content
        item:addContent(content)
        item:setItemSize(bg:getContentSize().width,height)
        self.list:addItem(item)
    end
    self.load = true
    self.list:reload()
end

function Mission:updateItem(id,data)
    for k,v in pairs(self.list.items_) do
    	if v.id == id then
    		if data.complete <= data.need_complete then
    			item.complete:setString("完成度："..v.complete.."/"..v.need_num)
    		else
    			if data.complete then
    				data.complete:removeSelf()
    			end
				if not item.completeBtn then
    				item.completeBtn = cc.ui.UIPushButton.new("#common/green-btn.png",{scale9 = true})
		            :setButtonSize(226, 82)
		            :setButtonLabel(cc.ui.UILabel.new({text = "领取", size = 40, font = "Helvetica-Bold"}))
		            :align(display.CENTER,560,0)
		            :onButtonPressed(function(event)
		                    -- sprite:runAction(cc.TintBy:create(0,-128,-128,-128))
		            end)
		            :onButtonRelease(function(event)
		                    -- sprite:runAction(cc.TintBy:create(0,255,255,255))
		            end)
		            :onButtonClicked(function (event)
		            	SendCMD:completeMission(v.id)
		            end)
		            :addTo(item.content)
		        end
    		end
    	end
    end

end

function Mission:removeItem(id)
    for k,v in pairs(self.list.items_) do
    	if v.id == id then
    		self.list:removeItem(v,true)
    	end
    end
end

function Mission:hide()
    self:setTouchEnabled(false)
    transition.scaleTo(self.parts["bg"],{
        time = 0.2,
        scale = 0,
        easing = "BACKIN",
        onComplete = function(  )
            self:removeSelf(true)
        end
    })
end


return Mission