local ForgetPwd = class("ForgetPwd",display.newNode)
	
function ForgetPwd:ctor()
	self.data = {}
	local bg = display.newSprite("#common/userinfo-bg.png",display.cx,display.cy)
	    :addTo(self)
	bg:setScaleY(1.4)
	bg:setScaleX(1.2)
	cc.ui.UIPushButton.new("#login/title-bg.png")
        		:setButtonLabel(cc.ui.UILabel.new({text = "忘记密码", size = 45, font = "Helvetica-Bold"}))
	            :align(display.CENTER,display.cx ,display.height - 150)
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
    local lables = {"原密码","新密码","确认"}
    local input
    local xx,yy,size = 450 ,display.height - 320,cc.size(491,95)
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
    	yy = yy - 120
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


function ForgetPwd:show( ... )

end

function ForgetPwd:hide( ... )
	self:removeSelf()
	_.ForgetPwd = nil
end

return ForgetPwd