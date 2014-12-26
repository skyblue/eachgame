local ForgetPwd = class("ForgetPwd",display.newNode)
	
function ForgetPwd:ctor()
    self:setContentSize(display.width, display.height)
    self.data = {}
    self.parts = {}
    local bg = display.newSprite("#common/userinfo-bg.png",display.cx,display.cy)
        :addTo(self)
    bg:setScaleY(1.4)
    bg:setScaleX(0.9)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT,function ( event )
        if not bg:getCascadeBoundingBox():containsPoint(cc.p(event.x,event.y)) then
            self:hide()
        end
    end)
    self:setTouchEnabled(true)
    cc.ui.UILabel.new({text = "找回密码", size = 65, font = "Helvetica-Bold"})
        :align(display.CENTER,display.cx ,display.height - 140)
        :addTo(self)

	cc.ui.UIPushButton.new("#common/close_icon.png")
            :align(display.CENTER,bg:getContentSize().width+120,display.height-94)
            :onButtonPressed(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,-128,-128,-128))
            end)
            :onButtonRelease(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,255,255,255))
            end)
            :onButtonClicked(function (event)
                    self:hide()
            end)
            :addTo(self)
     local err = cc.ui.UILabel.new({
            UILabelType = 2,
            text = "",
            size = 30,
            color = cc.c3b(255,0,0),
            })
            :align(display.CENTER,display.cx,display.height-220)
            :addTo(self)

    local lables = {"帐号","新密码","确认密码","验证码"}
    local items = {"acc","newPwd","pwd","sign"}
    local input
    local xx,yy,size = 300 ,display.height - 300,cc.size(491,95)
    for i,v in ipairs(lables) do
    	 -- cc.ui.UILabel.new({
      --       UILabelType = 2,
      --       text = lables[i],
      --       size = 45,
      --       font = "Helvetica-Bold",
      --       color = cc.c3b(254,221,70),
      --       })
      --       :align(display.LEFT_CENTER,xx,yy)
      --       :addTo(self)

	    	-- input = cc.ui.UIInput.new({
	    	-- 	image = "#login/input.png",
	    	-- 	x = xx + 560,
	    	-- 	y = yy,
	    	-- 	size = size,
	    	-- 	listener = function ( event, editbox )
	    	-- 		-- body
	    	-- 	end
	    	-- }):addTo(self)
	    	-- input:setPlaceHolder("请输入"..lables[i]
    		-- input:setInputFlag(0)


		if i == 4 then
        	size = cc.size(246,95)
        	input = cc.ui.UIInput.new({
	    		image = "#login/input.png",
	    		x = xx + 440,
	    		y = yy,
	    		size = size,
	    		listener = function ( event, editbox )
	    			-- body
	    		end})
                :addTo(self)
            input:setPlaceHolder(lables[i])
            input:setMaxLength(6)
        	cc.ui.UIPushButton.new("#common/green-btn.png",{scale9 = true})
        		:setButtonSize(226, 77)
        		:setButtonLabel(cc.ui.UILabel.new({text = "发送验证码", size = 36, font = "Helvetica"}))
                :align(display.CENTER,xx + 700,yy)
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
                           dump(data)
                       end)
                end)
                :addTo(self)
        else
        	input = cc.ui.UIInput.new({
	    		image = "#login/input.png",
	    		x = xx + 560,
	    		y = yy,
	    		size = size,
	    		listener = function ( event, editbox )
	    			-- body
	    		end})
                :addTo(self)
	    	input:setPlaceHolder("请输入"..lables[i])
            input:setMaxLength(20)
            if i ~= 1 then
    		  input:setInputFlag(0)
            end
        end
        self.parts[items[i]] = input
    	yy = yy - 104
    end
    cc.ui.UIPushButton.new("#common/green-btn.png",{scale9 = true})
        		:setButtonSize(311, 139)
        		:setButtonLabel(cc.ui.UILabel.new({text = "确定", size = 60, font = "Helvetica-Bold"}))
	            :align(display.CENTER,display.cx,200)
	            :onButtonPressed(function(event)
	                    -- sprite:runAction(cc.TintBy:create(0,-128,-128,-128))
	            end)
	            :onButtonRelease(function(event)
	                    -- sprite:runAction(cc.TintBy:create(0,255,255,255))
	            end)
	            :onButtonClicked(function (event)
	                   local acc = self.parts["acc"]:getText()
                        if #acc < 1 then
                            err:setString("请输入帐号!")
                            return
                        end
                        local newPwd = self.parts["newPwd"]:getText()
                        if #newPwd < 6 then
                            err:setString("密码长度最少6位!")
                            return
                        end
                        local pwd = self.parts["pwd"]:getText()
                        if #pwd < 6 then
                            err:setString("密码长度最少6位!")
                            return
                        end
                        if pwd ~= newPwd then
                            err:setString("两次密码输入不一致!")
                            return
                        end
                        local verify_code = self.parts["sign"]:getText()
                        if #verify_code < 1 then
                            err:setString("请您输入验证码哦!")
                            return
                        end
                        pwd = crypto.md5(pwd)
                        pwd = string.sub(pwd,1,32)
                        local params = {user_name = acc,verify_code = verify_code,user_pwd = pwd,source = CONFIG.appName,
                                platform = device.platform == "ios" and 1 or 2,game_id = CONFIG.gameId}
                                params.sign = utils.genSig(params)
                        utils.http(CONFIG.EachGame_URL .. "user/modifypwd",params,function ( data )
                            dump(data)
                            if data.s == 0 then
                                utils.dialog("", "修改成功",{"确定"})
                                self:hide()
                            else
                                err:setString(data.m)
                            end
                        end,"POST")
	            end)
	            :addTo(self)
end


function ForgetPwd:show( ... )

end

function ForgetPwd:hide( ... )
    if display.getRunningScene().parts["acc"] then
        display.getRunningScene().parts["acc"]:setVisible(true)
    end
    if display.getRunningScene().parts["pwd"] then
        display.getRunningScene().parts["pwd"]:setVisible(true)
    end
	self:removeSelf()
	_.ForgetPwd = nil
end

return ForgetPwd