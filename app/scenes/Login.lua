local Login = class("Login", function()
    return display.newScene("Login")
end)
local Register = require("app.scenes.index.Register")
local ForgetPwd = require("app.scenes.index.ForgetPwd")
-- local ChangePwd = require("app.scenes.index.ChangePwd")



function Login:ctor()
	display.addSpriteFrames("img/login.plist","img/login.png")
	local bg = display.newSprite("img/login-bg.png",display.cx,display.cy)
	:addTo(self)
	if display.height > 960 then
        bg:setScale(display.height/960)
    end
	
	display.newSprite("#login/account.png",display.cx + 270,display.top - 70)
	:addTo(self)
    cc.ui.UILabel.new({
            UILabelType = 2,
            text = "帐号",
            size = 65,
            font = "Helvetica-Bold",
            color = cc.c3b(254,221,70),
            })
            :align(display.LEFT_CENTER,display.cx + 140,display.top - 190)
            :addTo(self)
    display.newSprite("#login/input.png",display.width - 320,display.top - 190)
    	:addTo(self)
    local acc = cc.ui.UIInput.new({
    		image = "img/1px.png",
    		x = display.width - 320,
    		y = display.top - 190,
    		size = cc.size(491,95),
    		listener = function ( event, editbox )
    			-- body
    		end
    	}):addTo(self)
	acc:setPlaceHolder("请输入帐号")
	-- acc:setPlaceholderFontColor(cc.c3b(221,194,148))
	acc:setMaxLength(20)
	-- acc:setInputMode(3)
 --    acc:setReturnType(0)

 local err = cc.ui.UILabel.new({
            UILabelType = 2,
            text = "",
            size = 30,
            color = cc.c3b(255,0,0),
            })
            :align(display.CENTER,display.width- 340,display.top - 380)
            :addTo(self)

    cc.ui.UILabel.new({
            UILabelType = 2,
            text = "密码",
            size = 65,
            font = "Helvetica-Bold",
            color = cc.c3b(254,221,70),
            })
            :align(display.LEFT_CENTER,display.cx + 140,display.top - 300)
            :addTo(self)
    display.newSprite("#login/input.png",display.width - 320,display.top - 300)
    	:addTo(self)
	local pwd = cc.ui.UIInput.new({
    		image = "img/1px.png",
    		x = display.width - 320,
    		y = display.top - 300,
    		size = cc.size(491,95),
    		listener = function ( event, editbox )
    			-- body
    		end
    	}):addTo(self)
	pwd:setInputFlag(0)
	pwd:setPlaceHolder("请输入密码")
	-- pwd:setPlaceholderFontColor(cc.c3b(221,194,148))
	pwd:setMaxLength(20)
	-- pwd:setInputMode(1)
 --    pwd:setReturnType(1)

	self.parts = {}
	self.parts["pwd"] = pwd
	self.parts["acc"] = acc
    cc.ui.UIPushButton.new("#login/login-btn.png")
	            :align(display.CENTER,display.width-220,display.cy)
	            :onButtonPressed(function(event)
	                    -- sprite:runAction(cc.TintBy:create(0,-128,-128,-128))
	            end)
	            :onButtonRelease(function(event)
	                    -- sprite:runAction(cc.TintBy:create(0,255,255,255))
	            end)
	            :onButtonClicked(function (event)
	            		local acc = self.parts["acc"]:getText()
	            		if #acc < 1 then
	            			err:setString("您输入的帐号长度不对哦！")
	            			return
	            		end
	            		local pwd = self.parts["pwd"]:getText()
	            		if #pwd < 1 then
	            			err:setString("您输入的密码长度不对哦！")
	            			return
	            		end
	                    SendCMD:login(acc,pwd,2)
	              --       pwd = crypto.md5(pwd)
	              --       local params = {user_name = acc,accout_type = 2,user_pwd = pwd,source = CONFIG.appName,
	              --       platform = device.platform == "ios" and 1 or 2,game_id = CONFIG.gameId}
	            		-- params.sign = utils.genSig(params)
	              --       utils.http(CONFIG.EachGame_URL .. "user/login",params,function ( data )
	              --       	dump(data)
	              --       end)
	            end)
	            :addTo(self) 

	cc.ui.UIPushButton.new("#login/login-play.png")
	            :align(display.CENTER,display.cx + 260,display.cy)
	            :onButtonPressed(function(event)
	                    -- sprite:runAction(cc.TintBy:create(0,-128,-128,-128))
	            end)
	            :onButtonRelease(function(event)
	                    -- sprite:runAction(cc.TintBy:create(0,255,255,255))
	            end)
	            :onButtonClicked(function (event)
	                    SendCMD:login("","",1)

	            end)
	            :addTo(self)
 

   	cc.ui.UIPushButton.new("img/1px.png")
			:setButtonLabel(cc.ui.UILabel.new({
		                    text = "忘记密码", 
		                    size = 45, 
		                    -- font = "ArialMT",
		                    align = cc.ui.TEXT_ALIGN_RIGHT,
		                    color =  cc.c3b(221,194,148),
		                    dimensions = cc.size(355, 60)
		                    })
		                    )
            :align(display.CENTER,display.width - 300 ,display.cy-130)
            :onButtonPressed(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,-128,-128,-128))
            end)
            :onButtonRelease(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,255,255,255))
            end)
            :onButtonClicked(function (event)
            	self.parts["acc"]:setEnabled(false)
            	self.parts["pwd"]:setEnabled(false)
	            self:addChild(ForgetPwd.new())
            end)
            :addTo(self) 

	cc.ui.UIPushButton.new("img/1px.png")
			:setButtonLabel(cc.ui.UILabel.new({
		                    text = "注册", 
		                    size = 45, 
		                    -- font = "Arial-ItalicMT",
		                    align = cc.ui.TEXT_ALIGN_RIGHT,
		                    color =  cc.c3b(221,194,148),
		                    dimensions = cc.size(355, 60)
		                    })
		                    )
            :align(display.CENTER,display.cx + 122,display.cy-130)
            :onButtonPressed(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,-128,-128,-128))
            end)
            :onButtonRelease(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,255,255,255))
            end)
            :onButtonClicked(function (event)
            	self.parts["acc"]:setEnabled(false)
            	self.parts["pwd"]:setEnabled(false)

                self:addChild(Register.new())
            end)
            :addTo(self) 

	display.newSprite("#login/other-login.png",display.cx + 320,240)
	:addTo(self)
    local loginImgs ={"sina","qq","fqa"}
    local xx = display.cx + 220
    for i=1,3 do
    	cc.ui.UIPushButton.new("#login/"..loginImgs[i]..".png")
	            :align(display.CENTER,xx + (i-1) * 230,100)
	            :onButtonPressed(function(event)
	                    -- sprite:runAction(cc.TintBy:create(0,-128,-128,-128))
	            end)
	            :onButtonRelease(function(event)
	                    -- sprite:runAction(cc.TintBy:create(0,255,255,255))
	            end)
	            :onButtonClicked(function (event)
	                    utils.playSound("click")
				        if _.UserInfo == nil or tolua.isnull(_.UserInfo) then 
				            _.UserInfo = UserInfo.new():addTo(self)
				        end
				        _.UserInfo:show(USER)
	            end)
	            :addTo(self) 
    end
    
end

return Login