local Register = class("Register",display.newNode)
	
function Register:ctor()
	self.data = {sex = 0}
	self.parts = {}
	local bg = display.newSprite("img/myinfo-bg.png",display.cx,display.cy)
        :addTo(self)
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT,function ( event )
		if not bg:getCascadeBoundingBox():containsPoint(cc.p(event.x,event.y)) then
			self:hide()
		end
	end)
	self:setTouchEnabled(true)
	cc.ui.UILabel.new({text = "用户注册", size = 65, font = "Helvetica-Bold"})
		:align(display.CENTER,bg:getContentSize().width/2 ,bg:getContentSize().height-70)
        :addTo(bg)

	cc.ui.UIPushButton.new("#common/close_icon.png")
            :pos(bg:getContentSize().width,bg:getContentSize().height)
            :onButtonClicked(function (event)
                    self:hide()
            end)
            :addTo(bg)


    local lables = {"手机号","昵称","密码","验证码","性别"}
    local items = {"acc","nickname","pwd","sign"}
    local input
    local yy =  bg:getContentSize().height - 186
    local err = cc.ui.UILabel.new({
            UILabelType = 2,
            text = "",
            size = 30,
            color = cc.c3b(255,0,0),
            })
            :align(display.CENTER,bg:getContentSize().width/2,bg:getContentSize().height-130)
            :addTo(bg)
    for i,v in ipairs(lables) do
        if i == 4 then
        	input = cc.ui.UIInput.new({
	    		image = "#common/reg-input.png",
	    		x = bg:getContentSize().width/2 - 60,
	    		y = yy,
	    		size = cc.size(622,74),
	    		listener = function ( event, editbox )
	    			-- body
	    		end
	    	}):addTo(bg)
	    	input:setPlaceHolder(lables[i])
	    	input:setPlaceholderFontColor(cc.c3b(200,200,200))
	    	input:setMaxLength(6)

        	cc.ui.UIPushButton.new("#common/verifycode.png",{scale9 = true})
        		:setButtonSize(140, 64)
        		:setButtonLabel(cc.ui.UILabel.new({text = "验证码", size = 36, font = "Helvetica",color = cc.c3b(1,78,122)}))
	            :align(display.CENTER,bg:getCascadeBoundingBox().width/1.3,yy)
	            :onButtonPressed(function(event)
	                    -- sprite:runAction(cc.TintBy:create(0,-128,-128,-128))
	            end)
	            :onButtonRelease(function(event)
	                    -- sprite:runAction(cc.TintBy:create(0,255,255,255))
	            end)
	            :onButtonClicked(function (event)
	            		local params = {user_name = string.trim(self.parts["acc"]:getText()),send_type = 1}
	            		params.sign = utils.genSig(params)
	                   utils.http(CONFIG.EachGame_URL .. "user/sendverifycode",params,function ( data )
	                   end,"POST")
	            end)
	            :addTo(bg)
            self.parts[items[i]] = input
        elseif i == 5 then
        	local sex0,sex1
        	sex1 =  display.newFilteredSprite("#common/female.png", "GRAY", {0.2, 0.3, 0.5, 0.1})
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

			sex0 =  display.newSprite("#common/male.png",nil,nil,{class=cc.FilteredSpriteWithOne})
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
	    		image = "#common/reg-input.png",
	    		x = bg:getContentSize().width/2 - 60,
	    		y = yy,
	    		size = cc.size(622,74),
	    		listener = function ( event, editbox )
	    			-- body
	    		end
	    	}):addTo(bg)
	    	input:setPlaceHolder("请输入"..lables[i])
	    	-- input:setPlaceholderFontSize(40)
	    	input:setPlaceholderFontColor(cc.c3b(200,200,200))
	    	input:setMaxLength(20)
	    	self.parts[items[i]] = input
	    	if i == 3 then
	    		input:setInputFlag(0)
	    	elseif i == 1 then
	    		input:setMaxLength(11)
	    	end
	    end
    	yy = yy - 100
    end
    cc.ui.UIPushButton.new("#common/reg-btn.png",{scale9 = true})
	            :align(display.CENTER,bg:getContentSize().width/2,yy - 40)
	            :onButtonPressed(function(event)
	                    -- sprite:runAction(cc.TintBy:create(0,-128,-128,-128))
	            end)
	            :onButtonRelease(function(event)
	                    -- sprite:runAction(cc.TintBy:create(0,255,255,255))
	            end)
	            :onButtonClicked(function (event)
	            		local acc = self.parts["acc"]:getText()
	            		if #acc < 11 then
	            			err:setString("请您输入11位手机号码哦!")
	            			return
	            		end
	            		local pwd = self.parts["pwd"]:getText()
	            		if #pwd < 6 then
	            			err:setString("密码长度最少6位!")
	            			return
	            		end
	            		local nickname = self.parts["nickname"]:getText()
	            		if #nickname < 1 then
	            			err:setString("请您输入昵称哦!")
	            			return
	            		end
	            		local verify_code = self.parts["sign"]:getText()
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
end


function Register:show( ... )

end

function Register:hide( ... )
	if display.getRunningScene().parts["acc"] then
		display.getRunningScene().parts["acc"]:setEnabled(true)
	end
	if display.getRunningScene().parts["pwd"] then
		display.getRunningScene().parts["pwd"]:setEnabled(true)
	end
	self:removeSelf()
	_.ForgetPwd = nil
end

return Register