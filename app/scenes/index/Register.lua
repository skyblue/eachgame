local Register = class("Register",display.newNode)
	
function Register:ctor(callback)
	self.callback = callback
	self.data = {sex = 0}
	self.parts = {}
	local mask = cc.LayerColor:create(cc.c4b(0,0,0,0))
            :addTo(self)
    mask:setContentSize(display.width,display.height)
    mask:setOpacity(150)
	self:setContentSize(display.width,display.height)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT,self:onTouch())
	local bg = display.newSprite("img/myinfo-bg.png",display.cx,display.cy)
        :addTo(self)
    self.bg = bg

	self:setTouchEnabled(true)
	cc.ui.UILabel.new({text = "用户注册", size = 65, font = "Helvetica-Bold"})
		:align(display.CENTER,bg:getContentSize().width/2 ,bg:getContentSize().height-70)
        :addTo(bg)

	cc.ui.UIPushButton.new("#common/close_icon.png")
            :pos(bg:getContentSize().width,bg:getContentSize().height)
            :onButtonPressed(function(event,sprite)
                event.target:runAction(cc.TintTo:create(0,128,128,128))
            end)
            :onButtonRelease(function(event)
                event.target:runAction(cc.TintTo:create(0,255,255,255))
            end)
            :onButtonClicked(function (event)
                    self:hide()
            end)
            :addTo(bg)
    self.parts["input"] = {}
    
    local size,input = cc.size(701,74)
    local yy =  bg:getContentSize().height - 186
    local err = cc.ui.UILabel.new({
            UILabelType = 2,
            text = "",
            size = 30,
            color = cc.c3b(255,0,0),
            })
            :align(display.CENTER,bg:getContentSize().width/2,bg:getContentSize().height-130)
            :addTo(bg)
    for i=1,5 do
        if i == 4 then
        	input = cc.ui.UIInput.new({
	    		image = "#login/reg-input.png",
	    		x = bg:getContentSize().width/2 - 60,
	    		y = yy,
	    		size = size,
	    		listener = function ( event, editbox )
	    			-- body
	    		end
	    	}):addTo(bg)
	    	input:setPlaceholderFontColor(cc.c3b(200,200,200))
	    	input:setMaxLength(6)

        	cc.ui.UIPushButton.new("#common/verifycode.png",{scale9 = true})
        		:setButtonSize(140, 64)
        		:setButtonLabel(cc.ui.UILabel.new({text = "验证码", size = 36, font = "Helvetica",color = cc.c3b(1,78,122)}))
	            :align(display.CENTER,bg:getCascadeBoundingBox().width - 240,yy)
	            :onButtonPressed(function(event,sprite)
	                event.target:runAction(cc.TintTo:create(0,128,128,128))
	            end)
	            :onButtonRelease(function(event)
	                event.target:runAction(cc.TintTo:create(0,255,255,255))
	            end)
	            :onButtonClicked(function (event)
	            		local acc = string.trim(self.parts["input"][1]:getText())
	            		local params = {user_name = acc,send_type = 1}
	            		params.sign = utils.genSig(params)
	                    utils.http(CONFIG.EachGame_URL .. "user/sendverifycode",params,function ( data )
	                   		if data.s ~= 0 then
	                   			err:setString(data.m)
	                   		end
	                   end,"POST")
	            end)
	            :addTo(bg)
        elseif i == 5 then
        	local sex0,sex1
        	sex1 =  display.newFilteredSprite("#login/female.png", "GRAY", {0.2, 0.3, 0.5, 0.1})
					:align(display.CENTER, bg:getContentSize().width/2 - 130,yy)
					:addTo(bg)
        	sex1:addNodeEventListener(cc.NODE_TOUCH_EVENT,function ( event )
				 if event.name == "began" then
		            return true
				elseif event.name == "ended" then
					self.data.sex = 1
					sex1:clearFilter()
					sex0:setFilter(filter.newFilter("GRAY",{0.2, 0.3, 0.5, 0.1}))
				end
			end)
			sex1:setTouchEnabled(true)

			sex0 =  display.newSprite("#login/male.png",nil,nil,{class=cc.FilteredSpriteWithOne})
					:align(display.CENTER, bg:getContentSize().width/2 + 130,yy)
					:addTo(bg)
        	sex0:addNodeEventListener(cc.NODE_TOUCH_EVENT,function ( event )
				 if event.name == "began" then
		            return true
				elseif event.name == "ended" then
					self.data.sex = 0
					sex0:clearFilter()
					sex1:setFilter(filter.newFilter("GRAY",{0.2, 0.3, 0.5, 0.1}))
				end
			end)
			sex0:setTouchEnabled(true)
        else

	    	input = cc.ui.UIInput.new({
	    		image = "#login/reg-input.png",
	    		x = bg:getContentSize().width/2 - 60,
	    		y = yy,
	    		size = size,
	    		listener = function ( event, editbox )
	    			-- body
	    		end
	    	}):addTo(bg)
	    	

	    	input:setPlaceholderFontColor(cc.c3b(200,200,200))
	    	input:setMaxLength(20)
	    	if i == 3 then
	    		input:setInputFlag(0)
	    	elseif i == 1 then
	    		input:setMaxLength(11)
	    	end
	    end
	    self.parts["input"][i] = input
    	yy = yy - 100
    end
    cc.ui.UIPushButton.new("#login/ok-btn.png",{scale9 = true})
	            :align(display.CENTER,bg:getContentSize().width/2,yy - 40)
	            :onButtonPressed(function(event,sprite)
	                event.target:runAction(cc.TintTo:create(0,128,128,128))
	            end)
	            :onButtonRelease(function(event)
	                event.target:runAction(cc.TintTo:create(0,255,255,255))
	            end)
	            :onButtonClicked(function (event)
	            		local acc = self.parts["input"][1]:getText()
	            		if #acc < 11 then
	            			err:setString("请您输入11位手机号码哦!")
	            			return
	            		end
	            		local pwd = self.parts["input"][3]:getText()
	            		if #pwd < 6 then
	            			err:setString("密码长度最少6位!")
	            			return
	            		end
	            		local nickname = self.parts["input"][2]:getText()
	            		if #nickname < 1 then
	            			err:setString("请您输入昵称哦!")
	            			return
	            		end
	            		local verify_code = self.parts["input"][4]:getText()
	            		if #verify_code < 1 then
	            			err:setString("请您输入验证码哦!")
	            			return
	            		end
	            		pwd = crypto.md5(pwd)
	            		pwd = string.sub(pwd,1,32)
			            local params = {user_nick = nickname,account_type = 2, user_name = acc,verify_code = verify_code,
					            user_pwd = pwd,source = CONFIG.appName,sex = self.data.sex,
			                    platform = device.platform == "ios" and 1 or 2,game_id = CONFIG.gameId}
			            		params.sign = utils.genSig(params)
		                utils.http(CONFIG.EachGame_URL .. "user/register",params,function ( data )
		                	if data.s == 0 then
		                		utils.dialog("", "注册成功！",{"确定"})
		                		self:hide()
		                	else
		                		err:setString(data.m)
		                	end
		              --   	SendCMD:register(
		            		-- self.parts["acc"]:getText(),
		            		-- self.parts["pwd"]:getText(),
		            		-- self.data.sex,
		            		-- self.parts["nickname"]:getText(),
		            		-- self.parts["sign"]:getText())

	                    end,"POST")
	            end)
	                    	
	            :addTo(bg)
	self:show()
end


function Register:onTouch()
    local layer = self
    return function(event)
        local touched = self.bg:getCascadeBoundingBox():containsPoint(cc.p(event.x,event.y))
        if not touched then
            self:hide()
        end
        return true
    end
end

function Register:show()
	self.bg:setScale(0.4)
    transition.scaleTo(self.bg,{
        time   = 0.25,
        scale  = 1,
        easing = "BACKOUT",
        onComplete = function (  )
        	local lables = {"手机号","昵称","密码","验证码"}
        	for i,v in ipairs(lables) do
        		self.parts["input"][i]:setPlaceHolder("请输入"..v)
        	end
        end
    })
    self:setTouchEnabled(true)

end

function Register:hide()
	for i=1,4 do
		self.parts["input"][i]:setPlaceHolder("")
	end
    self:setTouchEnabled(false)
    transition.scaleTo(self.bg,{
        time = 0.2,
        scale = 0,
        easing = "BACKIN",
        onComplete = function(  )
            if self.callback then
            	self.callback()
            end
            self:removeSelf(true)
        end
    })
end



return Register