local Chat = class("Chat",display.newNode)
	
function Chat:ctor()
	-- self:setContentSize(display.width, display.height)
    display.newColorLayer(cc.c4b(0,0,0,0))
        :addTo(self)
        :setOpacity(150)
    local mask = display.newColorLayer(cc.c4b(0,0,0,0))
        :addTo(self)
    mask:setContentSize(display.width,display.cy)
    mask:setOpacity(190)
    -- mask:addNodeEventListener(cc.NODE_TOUCH_EVENT,function ( event )
    --    self:hide()
    -- end)
    -- mask:setTouchEnabled(true)

	self.parts ={}
	local imputImg = cc.ui.UIImage.new("#room/chat-input.png", {scale9 = true})
        :setLayoutSize(display.width - 360, 100)
        :align(display.CENTER, display.cx-180 , display.cy)
        :addTo(self)
    self.send = true
	local input = cc.ui.UIInput.new({
	    		image = "img/1px.png",
	    		x = display.cx-176,
	    		y = 52,
	    		size = cc.size(display.width - 390, 90),
	    		listener = function ( event, editbox )
	    			-- dump(event)
                    if event == "ended" then
                        --关闭聊天
                        self:hide()
                    elseif event == "return" then
                        if self.send then
                            self.send =  false
                            --发送聊天消息
                            SendCMD:chat(string.trim(self.parts["input"]:getText()),0)
                            self:performWithDelay(function ( ... )
                               self.send = true
                            end,2)
                        end
                    end

	    		end
	    	}):addTo(imputImg)
 	input:setReturnType(3)
    input:setMaxLength(40)
    -- input:setEnabled(false)
    self.parts["input"] = input
    self.parts["input"]:setEnabled(false)
 	
    local qucikChat = display.newNode():addTo(self)
    self.parts["quickChat"] = qucikChat
    qucikChat:setPosition(0,display.cy)
    local quick = {"快捷语言","快捷语言","快捷语言","快捷语言","快捷语言","快捷语言","砖家 你好  砖家 再见 ","我给你们带了辣椒酱和陈年豆腐乳"}
    local xx,yy =  display.cx/2 + 20 ,-100
    for i,v in ipairs(quick) do
    	cc.ui.UIPushButton.new("#room/quick-chat-bg.png")
    			 :setButtonLabel(cc.ui.UILabel.new({
                    text = v, 
                    size = 36, 
                    font = "Helvetica",
                    color = cc.c3b(0,0,0),
                    align = cc.ui.CENTER,
                    })
                    )
                :align(display.CENTER ,xx,yy)
                :onButtonPressed(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,-128,-128,-128))
                end)
                :onButtonRelease(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,255,255,255))
                end)
                :onButtonClicked(function(event)
                    SendCMD:chat(v,1)
                end)
                :addTo(qucikChat)
        yy =  yy - 100
        if i ==  4 then
            xx = xx + display.cx -30
            yy = -100
        end
    end
    -- qucikChat:setVisible(false)

    cc.ui.UIPushButton.new("#room/quick-chat-btn.png")
                :pos( display.width-280 ,display.cy)
                :onButtonPressed(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,-128,-128,-128))
                end)
                :onButtonRelease(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,255,255,255))
                end)
                :onButtonClicked(function(event)
                    self.parts["quickChat"]:setVisible(true)
                    self.parts["expression"]:setVisible(false)
                end)
                :addTo(self)

    
    self:initMsg()
    self:initExpression()
end

function Chat:initExpression(event)
    local expression = display.newNode():addTo(self)
    expression:setPosition(0,display.cy)
    self.parts["expression"] = expression
    self.parts["expression"]:setVisible(false)
    local xx,yy = 100,-80
    local index = 1
    for i=1,4 do
        xx = 100
        for n=1,10 do
            cc.ui.UIPushButton.new("#room/expression/"..index..".png")
                :pos(xx,yy)
                :onButtonPressed(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,-128,-128,-128))
                end)
                :onButtonRelease(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,255,255,255))
                end)
                :onButtonClicked(function(event)
                    SendCMD:chat(index,2)
                end)
                :addTo(expression)
            index =  index + 1
            xx = xx + 130
        end
        yy = yy -114
    end


    local expressionBtn = cc.ui.UIPushButton.new("#room/expression-btn.png")
                :pos(display.width-100 ,display.cy)
                :onButtonPressed(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,-128,-128,-128))
                end)
                :onButtonRelease(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,255,255,255))
                end)
                :onButtonClicked(function(event)
                    self.parts["expression"]:setVisible(true)
                    self.parts["quickChat"]:setVisible(false)
                end)
                :addTo(self)
end

function Chat:touchListener(event)
    -- dump(event)
    local yy = 0
    if event.name == "began" then
        yy = event.y
    elseif event.name == "moved" then

    elseif event.name == "ended"  then
        if math.abs(event.y - yy) < 10 then
            --被点击了，关闭聊天窗口
            self:hide()
        end
    elseif event.name == "clicked" then
        --被点击了，关闭聊天窗口
        self:hide()
    end
end

function Chat:initMsg(msg)
    msg = msg or {}
    self.list = cc.ui.UIListView.new {
            viewRect = cc.rect(0,530, display.width, 420),
            direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
            }
            :onTouch(handler(self, self.touchListener))
        :addTo(self)
    -- msg = {"紫华仙子：田诚贱人","紫华仙子：有妹子还抢妹子","紫华仙子：天天只会泡妞","紫华仙子：子：脑壳里除了女人就子：脑壳里除了女人就是里除了女人就是屎紫华里除了女人就是屎紫华仙仙里除了女人就是屎紫华仙里除了女人就是屎紫华仙屎紫华仙子：脑壳里除了女人就是屎紫华仙子：脑壳里除了女人就是屎","只会泡妞","紫华仙子：子："}
    msg =  {"紫华仙子：田诚"}
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
    local xx = -display.cx + 30
    local text 
    for k,v in pairs(msg) do
        item = self.list:newItem()
        content = display.newNode()
        name = cc.ui.UILabel.new({
                    text = "名字：", 
                    size = 36, 
                    font = "Helvetica",
                    align = cc.ui.TEXT_ALIGN_LEFT,
                    valign = cc.ui.TEXT_VALIGN_TOP,
                    color = nameColor,
                    x = xx,
                    y = 0,
                    })
            :addTo(content)
        -- dump(name:getContentSize().width)
        text = cc.ui.UILabel.new({
                    text = v, 
                    size = 36, 
                    font = "Helvetica",
                    align = cc.ui.TEXT_ALIGN_LEFT,
                    valign = cc.ui.TEXT_VALIGN_TOP,
                    x = xx + name:getContentSize().width,
                    y =0,
                    color = msgColor,
                    dimensions = cc.size(display.width - name:getContentSize().width - 30, 0),
                    })
            :addTo(content)
        -- dump(text:getContentSize().height)
        -- name:setPositionY(text:getContentSize().height/2)
        -- text:setPositionY(text:getContentSize().height/2)
        item:addContent(content)
        item:setItemSize(display.width,text:getContentSize().height + 8)
        self.list:addItem(item)

    end
    self.list:reload()
    SocketEvent:addEventListener(CMD.CHAT_NTF .. "back", handler(self, self.addNewMsg))
end

function Chat:addNewMsg(event)
    local msg = event.data.msg
    -- _.Room.parts["chatMsg"]:setString(msg)
end

function Chat:show(  )
    self:setVisible(true)
    self.parts["input"]:setEnabled(true)
    self.parts["quickChat"]:setVisible(true)
    self.parts["expression"]:setVisible(false)
end

function Chat:hide(  )
    self.parts["input"]:setEnabled(false)
    self:setVisible(false)
end

return Chat