local Login = class("Login",display.newNode)
	
function Login:ctor()
	self.data = {sex = 0}
	self.parts = {}
	self:setContentSize(display.width,display.height)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT,self:onTouch())
	local bg = display.newSprite("img/myinfo-bg.png",display.cx,display.cy)
        :addTo(self)
    self.bg = bg

	self:setTouchEnabled(true)
	cc.ui.UILabel.new({text = "用户登陆", size = 65, font = "Helvetica-Bold"})
		:align(display.CENTER,bg:getContentSize().width/2 ,bg:getContentSize().height-60)
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


    local err = cc.ui.UILabel.new({
            UILabelType = 2,
            text = "",
            size = 30,
            color = cc.c3b(255,0,0),
            })
            :align(display.CENTER,bg:getContentSize().width/2,bg:getContentSize().height-130)
            :addTo(bg)
    local acc = cc.ui.UIInput.new({
    		image = "#login/reg-input.png",
    		x = display.width - 320,
    		y = display.top - 190,
    		size = cc.size(622,74),
    		listener = function ( event, editbox )
    			-- body
    		end
    	}):addTo(bg)
	acc:setPlaceHolder("请输入手机号")
	acc:setMaxLength(11)

	local pwd = cc.ui.UIInput.new({
    		image = "#login/reg-input.png",
    		x = display.width - 320,
    		y = display.top - 300,
    		size = cc.size(622,74),
    		listener = function ( event, editbox )
    			-- body
    		end
    	}):addTo(bg)
	pwd:setInputFlag(0)
	pwd:setPlaceHolder("请输入密码")
	pwd:setMaxLength(20)

    cc.ui.UIPushButton.new("#login/login-btn.png",{scale9 = true})
	            :align(display.CENTER,bg:getContentSize().width/2,yy - 40)
	            :onButtonPressed(function(event,sprite)
                    event.target:runAction(cc.TintTo:create(0,128,128,128))
                end)
                :onButtonRelease(function(event)
                    event.target:runAction(cc.TintTo:create(0,255,255,255))
                end)
	            :onButtonClicked(function (event)
                        err:setString("")
	            		local acc = self.parts["acc"]:getText()
	            		if #acc < 11 then
	            			err:setString("帐号长度是11位的手机号码哦！")
	            			return
	            		end
	            		local pwd = self.parts["pwd"]:getText()
	            		if #pwd < 6 then
	            			err:setString("您输入的密码不能小于6位哦！")
	            			return
	            		end
                        dump(11)
                        device.showActivityIndicator("登陆中…")
	                    SendCMD:login(acc,pwd,2)
                        -- _.Loading = Loading:new()
                        -- display.replaceScene(_.Loading)
	            end)
	                    	
	            :addTo(bg)
    
   SocketEvent:addEventListener(CMD.RSP_GAME_SERVER .. "back", function(event)
        device.hideActivityIndicator()
        -- if _.Loading then
        --     _.Loading:hide()
        --     _.Loading = nil
        -- end
        -- _.Hall = Hall.new()
        -- display.replaceScene(_.Hall)
        SocketEvent:removeEventListenersByEvent(CMD.RSP_GAME_SERVER .. "back")
        if checkint(USER.tid) > 0 then
            SendCMD.toGame(USER.tid)
        end
    end)
	self:show()
end


function Login:onTouch()
    local layer = self
    return function(event)
        local touched = self.bg:getCascadeBoundingBox():containsPoint(cc.p(event.x,event.y))
        if not touched then
            self:hide()
        end
        return true
    end
end

function Login:show()
	self.bg:setScale(0.4)
    transition.scaleTo(self.bg,{
        time   = 0.25,
        scale  = 1,
        easing = "BACKOUT",
        onComplete = function (  )
        	local lables = {"手机号","昵称","密码","验证码","性别"}
        	for i,v in ipairs(lables) do
        		self.parts["input"][i]:setPlaceHolder("请输入"..v)
        	end
        end
    })
    self:setTouchEnabled(true)

end

function Login:hide()
	for i=1,4 do
		self.parts["input"][i]:setPlaceHolder("")
	end
    self:setTouchEnabled(false)
    transition.scaleTo(self.bg,{
        time = 0.2,
        scale = 0,
        easing = "BACKIN",
        onComplete = function(  )
            self:removeSelf(true)
        end
    })
end



return Login