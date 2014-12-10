local Chat = class("Chat",display.newNode)
	
function Chat:ctor()
	-- self:setContentSize(display.width, display.height)
    display.newColorLayer(cc.c4b(0,0,0,0))
        :addTo(self)
        :setOpacity(190)
    local mask = display.newColorLayer(cc.c4b(0,0,0,0))
        :addTo(self)
    mask:setContentSize(display.width,display.cy)
    mask:setOpacity(190)
    -- mask:setPositionX(display.cx)


	self.parts ={}
	local yy = display.cy
	local imputImg = cc.ui.UIImage.new("#room/chat-input.png", {scale9 = true})
        :setLayoutSize(display.width - 200, 100)
        :align(display.CENTER, display.cx-100 , yy)
        :addTo(self)
    self.send = true
	local input = cc.ui.UIInput.new({
	    		image = "img/1px.png",
	    		x = display.cx-90,
	    		y = 46,
	    		size = cc.size(display.width - 200, 100),
	    		listener = function ( event, editbox )
	    			dump(event)
                    if event == "ended" then
                        --关闭聊天
                    elseif event == "return" then
                        if self.send then
                            self.send =  false
                            --发送聊天消息
                            self:performWithDelay(function ( ... )
                               self.send = true
                            end,2)
                        end
                    end

	    		end
	    	}):addTo(imputImg)
	self.parts["input"] = input
 	self.parts["input"]:setReturnType(3)
 	
    local qucikChat = display.newNode():addTo(self)
    yy = yy -100
    qucikChat:setPosition(60,yy)
    yy = 30
    local quick = {"快捷语言","快捷语言","快捷语言","快捷语言","快捷语言","快捷语言"}
    -- local xx,yy = 
    for i,v in ipairs(quick) do
    	cc.ui.UIPushButton.new("#room/quick-chat-bg.png")
    			 :setButtonLabel(cc.ui.UILabel.new({
                    text = v, 
                    size = 36, 
                    font = "Helvetica",
                    align = cc.ui.TEXT_ALIGN_LEFT,
                    })
                    )
    			:setButtonLabelOffset(30,0)
                :pos(0 ,yy)
                :onButtonPressed(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,-128,-128,-128))
                end)
                :onButtonRelease(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,255,255,255))
                end)
                :onButtonClicked(function(event)
                   dump(v)
                end)
                :addTo(qucikChat)
    	
        yy =  yy - 60
    end
    qucikChat:setVisible(false)

    cc.ui.UIPushButton.new("#room/quick-chat-btn.png")
                :pos( display.width-80 ,display.cy)
                :onButtonPressed(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,-128,-128,-128))
                end)
                :onButtonRelease(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,255,255,255))
                end)
                :onButtonClicked(function(event)
                  	qucikChat:setVisible(true)
                end)
                :addTo(self)
    cc.ui.UIPushButton.new("#room/expression-btn.png")
                :pos( display.width-150 ,display.cy)
                :onButtonPressed(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,-128,-128,-128))
                end)
                :onButtonRelease(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,255,255,255))
                end)
                :onButtonClicked(function(event)
                    qucikChat:setVisible(true)
                end)
                :addTo(self)
    self:initMsg()
end

function Chat:touchListener(event)
    dump(event)
    local yy 
    if event.name == "began" then
        yy = event.y
    elseif event.name == "moved" then

    elseif event.name == "ended"  then
        if math.abs(event.y - yy) < 10 then
            --被点击了，关闭聊天窗口
        end
    elseif event.name == "clicked" then
        --被点击了，关闭聊天窗口
    end
end

function Chat:initMsg(msg)
    msg = msg or {}
    self.list = cc.ui.UIListView.new {
            viewRect = cc.rect(-display.cx + 20,530, display.width, 420),
            direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
            }
            :onTouch(handler(self, self.touchListener))
        :addTo(self)
    msg = {"紫华仙子：田诚贱人","紫华仙子：有妹子还抢妹子","紫华仙子：天天只会泡妞","紫华仙子：脑壳里除了女人就是屎"}
    -- msg =  {"紫华仙子：田诚贱人"}
    local nameColor,msgColor,nilItemNum,height,item,name =  display.COLOR_WHITE,display.COLOR_WHITE,8 - #msg,50
    if msg.id and msg.id == 0 then
        nameColor = display.COLOR_RED
        msgColor = display.COLOR_RED
    end
    for i=1,nilItemNum do
        item = self.list:newItem()
        content = display.newNode()
        item:addContent(display.newNode())
        item:setItemSize(display.width,height)
        self.list:addItem(item)
    end
    for k,v in pairs(msg) do
        item = self.list:newItem()
        content = display.newNode()
        name = cc.ui.UILabel.new({
                    text = "名字：", 
                    size = 36, 
                    font = "Helvetica",
                    align = cc.ui.TEXT_ALIGN_LEFT,
                    color = nameColor
                    })
            :addTo(content)
        -- dump(name:getContentSize().width)
        cc.ui.UILabel.new({
                    text = v, 
                    size = 36, 
                    font = "Helvetica",
                    align = cc.ui.TEXT_ALIGN_LEFT,
                    x = name:getContentSize().width,
                    y =0,
                    color = msgColor
                    })
            :addTo(content)
        item:addContent(content)
        item:setItemSize(display.width,height)
        self.list:addItem(item)

    end
    self.list:reload()
end

function Chat:addNewMsg(msg)

end

return Chat