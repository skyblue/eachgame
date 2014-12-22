Mission = class("Mission",display.newNode)

function Mission:ctor()
	local bg = display.newSprite("img/myinfo-bg.png",display.cx,display.cy)
        :addTo(self)
    cc.ui.UIPushButton.new("#common/close_icon.png")
        :align(display.CENTER,bg:getContentSize().width-150,bg:getContentSize().height-92)
        :onButtonPressed(function(event)
                -- sprite:runAction(cc.TintBy:create(0,-128,-128,-128))
        end)
        :onButtonRelease(function(event)
                -- sprite:runAction(cc.TintBy:create(0,255,255,255))
        end)
        :onButtonClicked(function (event)
                self:hide()
                utils.playSound("click")
        end)
        :addTo(bg)
    SendCMD:getMissionlist()
    SocketEvent:addEventListener(CMD.RSP_MISSIONLIST .. "back", function(event)
    	SocketEvent:removeEventListenersByEvent(CMD.RSP_MISSIONLIST .. "back")
    	self:init()
    end)
end

function Mission:init(data)
	self.list = cc.ui.UIListView.new {
            viewRect = cc.rect(30,60, 1600, 680),
            direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
            }
        :addTo(bg)
    cc.ui.UILabel.new({text = "任务" , size = 60})
            :align(display.CENTER,display.cx,bg:getContentSize().height-120)
            :addTo(bg)

	local height,item,line,content = 200  
    for k,v in pairs(data) do
        item = self.list:newItem()
        item.id = v.id
        content = display.newNode()
        line = display.newSprite("#common/line.png",0,height/2)
            :addTo(content)
        line:setScaleX(1.5)
        display.newSprite("#chip-blue.png",-bg:getContentSize().width/2 +200,0)
            :addTo(content)
        cc.ui.UILabel.new({text = v.title , size = 50})
            :align(display.CENTER,-200,0)
            :addTo(content)
        cc.ui.UILabel.new({text = v.content , size = 50})
            :align(display.CENTER,-200,50)
            :addTo(content)
        cc.ui.UILabel.new({text = "$".. utils.numAbbr(v.chips), color = cc.c3b(254,221,70), size = 40})
            :align(display.CENTER,200,0)
            :addTo(content)
----------------------------------------------------------------------------
		if v.complete <= v.need_complete then
	        item.complete = cc.ui.UILabel.new({text = "完成度："..v.complete.."/"..v.need_num, size = 50, color = cc.c3b(254,221,70)})
	            :align(560,0)
	            :addTo(content)
		else
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
    			item.complete:setString(text = "完成度："..v.complete.."/"..v.need_num)
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

function Mission:exit()
    self:removeSelf()

end


return Mission