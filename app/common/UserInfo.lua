local UserInfo = class("UserInfo",display.newNode)

function UserInfo:ctor()
	self.parts={}
	self.parts["props"] ={}
	local mask = display.newColorLayer(cc.c4b(0,0,0,0))
        :addTo(self)
    mask:setContentSize(display.width,display.height)
    mask:setOpacity(150)
    mask:setTouchEnabled(false)
    self.parts["mask"] = mask
	self:initMyInfo()
	self:initPublicInfo()
	self:setContentSize(display.width,display.height)
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT,self:onTouch())
end


function UserInfo:onTouch()
    local layer = self
    return function(event)
        local touched = self.parts["bg"]:getCascadeBoundingBox():containsPoint(cc.p(event.x,event.y))
        if not touched then
            self:hide()
        end
        return true
    end
end


function UserInfo:initAnima(bg )
	self.parts["line"] = display.newSprite("#common/line.png",bg:getContentSize().width/2,140):
		addTo(bg)
	local propsImg,propsBg = {"flower","bomb","beer","egg","304"}
	for i=1,7 do
        -------------------------互动道具--------------------------
	    propsBg = display.newSprite("#room/animation/goods_background.png",180+(i-1)*140,70)
	        	:addTo(bg)
		self.parts["props"][i] = propsBg
	    if propsImg[i] then
	        cc.ui.UIPushButton.new("#room/animation/"..propsImg[i]..".png")
	            :align(display.LEFT_CENTER,0,62)
	            :onButtonPressed(function(event)
	                    -- sprite:runAction(cc.TintBy:create(0,-128,-128,-128))
	            end)
	            :onButtonRelease(function(event)
	                    -- sprite:runAction(cc.TintBy:create(0,255,255,255))
	            end)
	            :onButtonClicked(function (event)
                    SendCMD:animation(self.user.uid,i)
	            end)
	            :addTo(propsBg)
	    end
	end
end

function UserInfo:reset( ... )
	local bg = self.parts["bg"]
	if self.parts["props"] then
		for i,v in ipairs(self.parts["props"]) do
			v:setVisible(false)
		end
	end
	if self.parts["menu"] then
		for i,v in ipairs(self.parts["menu"]) do
			v:setVisible(false)
		end
	end
	if self.parts["line"] then
		self.parts["line"]:setVisible(false)
		self.parts["info-line"]:setScale(1)
	end
	self:setTouchEnabled(true)
	self.parts["mask"]:setVisible(true)
	self.parts["pokerIcon"]:pos(436,300)
end

function UserInfo:show(user)
	user.uid= 10
	local bg = self.parts["bg"]
	bg:setVisible(true)
	self.user = user
	self:reset()
	local xx,yy,height = 500,700,100
	if user.uid ==  USER.uid then
	-- if user.uid ~=  USER.uid then
		self.parts["uname"]:setEnabled(true)
		self.parts["uname"]:setVisible(true)
		for i,v in ipairs(self.parts["menu"]) do
			v:setVisible(true)
		end
	else
		self.parts["uname"]:setEnabled(false)
		self.parts["uname"]:setVisible(false)
		self.user.seatid = 1
		if checkint(self.user.seatid) > 0 then
			if bg.line == nil then
				self:initAnima(bg)
			end
			for i,v in ipairs(self.parts["props"]) do
				v:setVisible(true)
			end
			self.parts["line"]:setVisible(true)
			self.parts["info-line"]:setScale(0.9)
		end

	end
	bg:setScale(0.4)
	transition.scaleTo(bg,{
        time   = 0.25,
        scale  = 1,
        easing = "BACKOUT",
        onComplete = function ( )
	        if user.uid ==  USER.uid then
	        	self.parts["uname"]:setPlaceHolder(user.uname)
	        end
        end
    })
	bg.uid:setString("ID：" .. user.uid)
	if #user.upic > 0 then
		utils.loadRemote(bg.head.pic,user.upic)
	end
	
	local win = user.win_count / user.play_count
	if user.play_count == 0 then 
		win = 0
	end
	local textInfo = {user.uname , utils.numAbbr(user.uchips) , "LV："..user.level,user.city,
		utils.numAbbr(user.win_max) ,  utils.numAbbr(user.win_total) , 
		user.win_count.."胜"..user.play_count.."局 - %" .. win .."胜率"}
	for i,v in pairs(textInfo) do
		if i == 5 then
    		yy = 600
        	xx = xx + 320
        end
		if i > 1 then   
			self.parts["text"][i]:setString(v)
			self.parts["textIcon"][i-1]:pos(xx-64,yy)
			self.parts["textIcon"][i-1]:setButtonLabelOffset(self.parts["text"][i]:getContentSize().width/2 + 50,0)
		else
			self.parts["sexIcon"]:pos(xx-64,yy +10)
			if user.uid ==  USER.uid then
			-- if user.uid ~=  USER.uid then
				self.parts["text"][i]:setString("")
				-- bg.uname:setPlaceHolder(v)
			else
				self.parts["text"][i]:pos(xx,yy+10)
				self.parts["text"][i]:setString(v)
			end
		end
		yy = yy - height
	end
	if user.best_cards then
		for i,v in ipairs(user.best_cards) do
			self.parts["cards"][i]:changeVal(v)
			self.parts["cards"][i]:setPosition(550 + (i-1)*110, yy - 70)
		end
	end
	if user.sex ==1 then
		self.parts["sexIcon"]:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("common/female.png"))
	else
		self.parts["sexIcon"]:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("common/male.png"))
	end
end

function UserInfo:hide()
	self:setTouchEnabled(false)
	self.parts["uname"]:setPlaceHolder("")
	transition.scaleTo(self.parts["bg"],{
        time = 0.2,
        scale = 0,
        easing = "BACKIN",
        onComplete = function(  )
        	self.parts["bg"]:setVisible(false)
        	self.parts["mask"]:setVisible(false)
            -- return self:removeSelf(true)
			self.parts["uname"]:setVisible(false)
			self.parts["uname"]:setEnabled(false)
			self.parts["uname"]:setText("")
        end
    })
end


function UserInfo:initMyInfo()
	local bg = display.newSprite("img/myinfo-bg.png",display.cx,display.cy)
    	:addTo(self)
    local head = utils.makeAvatar({udata = USER,border = "#common/bolder1.png",mask_choose = 1,size = cc.size(278, 278)})
	head:setPosition(166,bg:getContentSize().height*0.7)
	bg:addChild(head)	
	self.parts["bg"] = bg
	self.parts["head"] = head

	head:addNodeEventListener(cc.NODE_TOUCH_EVENT,function ( event )
		if not self.users or checkint(self.users.uid) ~= USER.uid then return end
        utils.playSound("click")
        utils.callStaticMethod("ImagePickerBridge","showPicker",{callback = function (data)
        	-- if type(data) == "string" then
         --            data = json.decode(data)
         --    end
         --    data = checktable(data)
         --    if not data.success then return end
        	network.uploadFile(function(evt)
					if evt.name == "completed" then
						local request = evt.request
						-- printf("REQUEST getResponseStatusCode() = %d", request:getResponseStatusCode())
						-- printf("REQUEST getResponseHeadersString() =\n%s", request:getResponseHeadersString())
			 		-- 	printf("REQUEST getResponseDataLength() = %d", request:getResponseDataLength())
			   --          printf("REQUEST getResponseString() =\n%s", request:getResponseString())
			            if request:getResponseStatusCode() == 200  then
			            	SendCMD:changePic(request:getResponseString())
			            else
			            	
			            end
					end

				end,
				"http://192.168.1.175/texas/uploadTexasPhotos.php",
				{
					fileFieldName="buffer",
					-- filePath=data.filepath,
					filePath=data,
					contentType = "multipart/form-data",
					extra={
						{"mid", USER.uid},
					}
				}
			)
        end})
    end)
    head:setTouchEnabled(true)
    bg.uid = cc.ui.UILabel.new({
            UILabelType = 2,
            text = "",
            size = 56,
            font = "Helvetica-Bold",
            })
            :align(display.CENTER,180,bg:getContentSize().height * 0.45)
            :addTo(bg)
    local ok = cc.ui.UIPushButton.new("#common/input.png")
            :align(display.CENTER,bg:getContentSize().width - 195,bg:getContentSize().height-104)
            :onButtonClicked(function (event)
            	utils.playSound("click")
            	local name = string.trim(self.parts["uname"]:getText())
            	if #name > 2 then
            		SendCMD:changeUname(name)
            	end
            end)
            :addTo(bg)
    ok:setVisible(false)
    display.newSprite("#common/ok.png")
    	:addTo(ok)
    local unok = cc.ui.UIPushButton.new("#common/input.png")
            :align(display.CENTER,bg:getContentSize().width-100,bg:getContentSize().height-104)
            :onButtonPressed(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,-128,-128,-128))
            end)
            :onButtonRelease(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,255,255,255))
            end)
            :onButtonClicked(function (event)
            	utils.playSound("click")
                self.parts["uname"]:setText("")
            end)
            :addTo(bg)  
    display.newSprite("#common/unok.png")
    	:addTo(unok)
    unok:setVisible(false)
    local uname = cc.ui.UIInput.new({
	    		image = "#common/input.png",
	    		-- image = "img/1px.png",
	    		x = bg:getContentSize().width-480,
	    		-- y = bg:getContentSize().height-104,
	    		y = bg:getContentSize().height-90,
	    		size = cc.size(452,90),
	    		font 	="Helvetica",
	    		listener = function ( event, editbox )
	    			if #editbox:getText() > 1 then
		    			ok:setVisible(true)
		    			unok:setVisible(true)
		    		else
		    			ok:setVisible(false)
		    			unok:setVisible(false)
		    		end
	    		end
	    	}):addTo(bg)
    uname:setMaxLength(12)
    uname:setPlaceholderFont("Helvetica",40)
    uname:setPlaceholderFontColor(cc.c3b(255,255,255))
    self.parts["uname"] = uname
    cc.ui.UIPushButton.new("#common/close_icon.png")
            :align(display.CENTER,bg:getContentSize().width,bg:getContentSize().height)
            :onButtonClicked(function (event)
            	utils.playSound("click")
                self:hide()
            end)
            :addTo(bg)
    display.newSprite("#common/edit.png",bg:getContentSize().width - 288,bg:getContentSize().height-100)
    	:addTo(bg)
	self.parts["menu"] ={}
    self.parts["menu"][5] = display.newSprite("#common/btn-list.png",bg:getContentSize().width/2,43)
    	:addTo(bg)
    
	local menuText = {"基本资料","详细记录","   物品","   成就"}
	local group = cc.ui.UICheckBoxButtonGroup.new()
		:onButtonSelectChanged(function(event)
            printf("Option %d selected, Option %d unselected", event.selected, event.last)
        end)
        :align(display.CENTER, 0,-31)
        :addTo(bg)
	
	for i=1,4 do
		self.parts["menu"][i] = cc.ui.UICheckBoxButton.new({on = "#common/btn-select.png", off = "img/1px.png"},{scale9 = true})
            :setButtonLabel(cc.ui.UILabel.new({
                    text = menuText[i], 
                    size = 42, 
                    font = "Helvetica-Bold",
                    dimensions = cc.size(294, 84)
                    }))
            :setButtonSize(294, 84)
            :setButtonLabelOffset(-70, -20)
            :setButtonEnabled(i == 1 and true or false)
            group:addButton(self.parts["menu"][i])

	end
	group:getButtonAtIndex(1):setButtonSelected(true)

	SocketEvent:addEventListener(CMD.RSP_CHANGE_PIC .. "back", function(event)
        utils.loadRemote(head.pic,USER.upic)
    end)
	SocketEvent:addEventListener(CMD.RSP_CHANGE_UNAME .. "back", function(event)
        self.parts["bg"].text[1]:setString(USER.uname)
    end)
	
end


function UserInfo:initPublicInfo()
	local bg = self.parts["bg"]
	local msg = {"当前拥有的筹码","当前等级","你的地址","一局游戏里，赢取最多的筹码","输赢累计相加获得的筹码","胜利局数/总局数-输赢率"}
	self.parts["info-line"] = display.newSprite("#common/info-line.png",336,bg:getContentSize().height * 0.56)
    	:addTo(bg)
	self.parts["cards"] ={}
	self.parts["text"] = {}
	self.parts["textIcon"] = {}
	for i=1,7 do
		self.parts["text"][i] = cc.ui.UILabel.new({
            UILabelType = 2,
            text = "",
            size = i == 1 and 63 or 35,
            color = table.indexof({2,3,7},i) and cc.c3b(254,221,70) or cc.c3b(255,255,255),
            })
        if i > 1 then    
	        self.parts["textIcon"][i-1] = cc.ui.UIPushButton.new("#common/icon_"..(i-1)..".png")
				:setButtonLabel(self.parts["text"][i])
	            :onButtonClicked(function (event)
	                display:getRunningScene():addChild(require("app.common.Tips").new(msg[i-1],event.x+100,event.y+150))
	            end)
	            :addTo(bg)
	    else
	    	self.parts["text"][i]:addTo(bg)
	    	self.parts["sexIcon"] = display.newSprite("#common/female.png")
	        	:addTo(bg)
	    end
	end
	self.parts["pokerIcon"] = display.newSprite("#common/icon_8.png")
	        	:addTo(bg)
	cc.ui.UIPushButton.new("img/1px.png",{scale9 = true})
				:align(display.LEFT_CENTER,bg:getContentSize().width/2-140,240)
				:setButtonSize(600, 150)
	            :onButtonClicked(function (event)
	                display:getRunningScene():addChild(require("app.common.Tips").new("最好的手牌",event.x+100,event.y+150))
	            end)
	            :addTo(bg)
	for i=1,5 do
		self.parts["cards"][i] = Card.new()
		self.parts["cards"][i]:setScale(0.8)
		bg:addChild(self.parts["cards"][i])
	end
end

return UserInfo