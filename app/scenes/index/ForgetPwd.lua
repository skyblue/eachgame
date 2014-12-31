local ForgetPwd = class("ForgetPwd",display.newNode)
	
function ForgetPwd:ctor(callback)
    self.callback = callback
    self:setContentSize(display.width, display.height)
    self.data = {}
    self.parts = {}
    local mask = cc.LayerColor:create(cc.c4b(0,0,0,0))
            :addTo(self)
    mask:setContentSize(display.width,display.height)
    mask:setOpacity(150)
    local bg = display.newSprite("img/myinfo-bg.png",display.cx,display.cy)
        :addTo(self)
    self.bg = bg
    self:setContentSize(display.width,display.height)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT,function ( event )
        if not bg:getCascadeBoundingBox():containsPoint(cc.p(event.x,event.y)) then
            self:hide()
        end
    end)
    self:setTouchEnabled(true)
    cc.ui.UILabel.new({text = "找回密码", size = 65, font = "Helvetica-Bold"})
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
    local xx,yy,size = bg:getContentSize().width/2 ,bg:getContentSize().height - 200,cc.size(701,74)
    local err = cc.ui.UILabel.new({
            UILabelType = 2,
            text = "",
            size = 30,
            color = cc.c3b(255,0,0),
            })
            :align(display.CENTER,xx,bg:getContentSize().height-130)
            :addTo(bg)
    self.parts["input"] = {}
    local input
    for i=1,4 do
		if i == 4 then
        	input = cc.ui.UIInput.new({
	    		image = "#login/reg-input.png",
	    		x = xx,
	    		y = yy,
	    		size = size,
	    		listener = function ( event, editbox )
	    			-- body
	    		end})
                :addTo(bg)
            input:setMaxLength(6)
        	cc.ui.UIPushButton.new("#common/verifycode.png",{scale9 = true})
        		:setButtonSize(140, 64)
                :setButtonLabel(cc.ui.UILabel.new({text = "验证码", size = 36, font = "Helvetica",color = cc.c3b(1,78,122)}))
                :align(display.CENTER,bg:getCascadeBoundingBox().width - 180,yy)
                :onButtonPressed(function(event)
                        -- sprite:runAction(cc.TintBy:create(0,-128,-128,-128))
                end)
                :onButtonRelease(function(event)
                        -- sprite:runAction(cc.TintBy:create(0,255,255,255))
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
        else
        	input = cc.ui.UIInput.new({
	    		image = "#login/reg-input.png",
	    		x = xx,
	    		y = yy,
	    		size = size,
	    		listener = function ( event, editbox )
	    			-- body
	    		end})
                :addTo(bg)
            input:setMaxLength(20)
            if i ~= 1 then
    		  input:setInputFlag(0)
            end
        end
        input:setPlaceholderFontColor(cc.c3b(200,200,200))
        self.parts["input"][i] = input
    	yy = yy - 104
    end
    cc.ui.UIPushButton.new("#login/ok-btn.png",{scale9 = true})
        		:align(display.CENTER,xx,bg:getContentSize().height * 0.15)
	            :onButtonPressed(function(event)
	                    -- sprite:runAction(cc.TintBy:create(0,-128,-128,-128))
	            end)
	            :onButtonRelease(function(event)
	                    -- sprite:runAction(cc.TintBy:create(0,255,255,255))
	            end)
	            :onButtonClicked(function (event)
	                   local acc = self.parts["input"][1]:getText()
                        if #acc < 1 then
                            err:setString("请输入手机号!")
                            return
                        end
                        local newPwd = self.parts["input"][2]:getText()
                        if #newPwd < 6 then
                            err:setString("密码长度最少6位!")
                            return
                        end
                        local pwd = self.parts["input"][3]:getText()
                        if #pwd < 6 then
                            err:setString("密码长度最少6位!")
                            return
                        end
                        if pwd ~= newPwd then
                            err:setString("两次密码输入不一致!")
                            return
                        end
                        local verify_code = self.parts["input"][4]:getText()
                        if #verify_code < 1 then
                            err:setString("请您输入验证码哦!")
                            return
                        end
                        pwd = crypto.md5(pwd)
                        local params = {user_name = acc,verify_code = verify_code,user_pwd = pwd,source = CONFIG.appName,
                                platform = device.platform == "ios" and 1 or 2,game_id = CONFIG.gameId}
                                params.sign = utils.genSig(params)
                        utils.http(CONFIG.EachGame_URL .. "user/modifypwd",params,function ( data )
                            if data.s == 0 then
                                utils.dialog("", "修改成功",{"确定"})
                                self:hide()
                            else
                                err:setString(data.m)
                            end
                        end,"POST")
	            end)
	            :addTo(bg)
    self:show()
end

function ForgetPwd:show()
    self.bg:setScale(0.4)
    transition.scaleTo(self.bg,{
        time   = 0.25,
        scale  = 1,
        easing = "BACKOUT",
        onComplete = function (  )
            local lables = {"帐号","新密码","确认密码","验证码"}
            for i,v in ipairs(lables) do
                self.parts["input"][i]:setPlaceHolder("请输入"..v)
            end
        end
    })
    self:setTouchEnabled(true)

end

function ForgetPwd:hide()
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

return ForgetPwd