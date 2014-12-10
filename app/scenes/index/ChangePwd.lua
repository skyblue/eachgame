local ChangePwd = class("ChangePwd",display.newNode)
	
function ChangePwd:ctor()
	self.data = {}
	local bg = display.newSprite("#common/userinfo-bg.png",display.cx,display.cy)
	    :addTo(self)
	bg:setScaleY(1.4)
	bg:setScaleX(1.2)
	cc.ui.UIPushButton.new("#login/title-bg.png")
        		:setButtonLabel(cc.ui.UILabel.new({text = "修改密码", size = 45, font = "Helvetica-Bold"}))
	            :align(display.CENTER,display.cx ,display.height - 140)
	            :addTo(self)

	cc.ui.UIPushButton.new("#common/close_icon.png")
            :align(display.CENTER,display.width-340,display.height-94)
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
    local lables = {"原密码","新密码","确认","验证码"}
    local items = {"oldPwd","newPwd","pwd","sign"}
    local input
    local xx,yy,size = 450 ,display.height - 300,cc.size(491,95)
    for i,v in ipairs(lables) do
    	 cc.ui.UILabel.new({
            UILabelType = 2,
            text = lables[i],
            size = 45,
            font = "Helvetica-Bold",
            color = cc.c3b(254,221,70),
            })
            :align(display.LEFT_CENTER,xx,yy)
            :addTo(self)

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
	    		end
	    	}):addTo(self)
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
            		local params = {user_name = USER.account,send_type = 1}
            		params.sign = utils.genSig(params)
                   dump("发送验证码")
                   utils.http(CONFIG.EachGame_URL .. "user/sendverifycode",params)
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
	    		end
	    	}):addTo(self)
	    	input:setPlaceHolder("请输入"..lables[i])
    		input:setInputFlag(0)
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
	                   dump("注册")
	            end)
	            :addTo(self)
end


function ChangePwd:show( ... )

end

function ChangePwd:hide( ... )
    if display.getRunningScene().parts["acc"] then
        display.getRunningScene().parts["acc"]:setEnabled(true)
    end
    if display.getRunningScene().parts["pwd"] then
        display.getRunningScene().parts["pwd"]:setEnabled(true)
    end
	self:removeSelf()
	_.ChangePwd = nil
end

return ChangePwd