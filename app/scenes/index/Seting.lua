local Seting = class("Seting",display.newNode)


function Seting:ctor(msg,x,y)
    display.addSpriteFrames("img/login.plist","img/login.png")
	self.parts = {}
    local mask = cc.LayerColor:create(cc.c4b(0,0,0,0))
            :addTo(self)
    mask:setContentSize(display.width,display.height)
    mask:setOpacity(150)
    self.parts["mask"] = mask
    local bg = display.newSprite("img/myinfo-bg.png",display.cx,display.cy)
        :addTo(self)
    self.bg = bg
    self:setContentSize(display.width,display.height)
    size = bg:getContentSize()
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT,self:onTouch())
    display.newSprite("#common/btn-list.png",bg:getContentSize().width/2,43)
        :addTo(bg)
    cc.ui.UIPushButton.new("#common/close_icon.png")
            :pos(size.width,size.height)
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
    self.parts["menu"] = {}
    self.titles = {"   设置","   反馈","切换帐号"}
    self.title = cc.ui.UILabel.new({text = string.trim(self.titles[1]) , size = 60})
                :align(display.CENTER,bg:getContentSize().width/2,bg:getContentSize().height-60)
                :addTo(bg)
    local group = cc.ui.UICheckBoxButtonGroup.new()
        :onButtonSelectChanged(function(event)
            printf("Option %d selected, Option %d unselected", event.selected, event.last)
            self["fun"..event.selected](self,1)
        end)
        :align(display.CENTER, 0,-26)
        :addTo(bg)
    for i=1,3 do
        self.parts["menu"][i] = cc.ui.UICheckBoxButton.new({on = "#common/btn-select.png", off = "#common/1px.png"},{scale9 = true})
            :setButtonLabel(cc.ui.UILabel.new({
                    text = self.titles[i], 
                    size = 42, 
                    font = "Helvetica-Bold",
                    }))
            :setButtonSize(392, 84)
            :setButtonLabelOffset(-80,-6)
            -- :setButtonEnabled(i == 1 and true or false)
            group:addButton(self.parts["menu"][i])

    end
    
    group:getButtonAtIndex(1):setButtonSelected(true)


    self:show()
end


function Seting:fun1()
    local title = string.trim(self.titles[1])
    self.title:setString(title)
   self:fun2hide()
   self:fun3hide()
end

function Seting:fun2()
    if not self.parts["feed"] then
        self:initFeed()
    end
    local title = string.trim(self.titles[2])
    self.title:setString(title)
    self.parts["feed-input"]:setPlaceHolder("感谢您在这里留言，我们会非常认真对待～")
    self.parts["feed-input"]:setVisible(true)
    self.parts["feed-input"]:setEnabled(true)
    self.parts["feed"]:setVisible(true)
    self:fun3hide()
end

function Seting:fun2hide()
    if self.parts["feed"] then
        self.parts["feed-input"]:setText("")
        self.parts["feed-input"]:setPlaceHolder("")
        self.parts["feed-input"]:setEnabled(false)
        self.parts["feed-input"]:setVisible(false)
        self.parts["feed"]:setVisible(false)
    end
end

function Seting:fun3()
    if not self.parts["account"] then
        self:initChangeAcc()
    end
    self:fun2hide()
    self.parts["pwd"]:setPlaceHolder("请输入密码")
    self.parts["acc"]:setPlaceHolder("请输入手机号")
    self.title:setString(self.titles[3])
        
    self.parts["pwd"]:setVisible(true)
    self.parts["pwd"]:setEnabled(true)
    self.parts["acc"]:setVisible(true)
    self.parts["acc"]:setEnabled(true)
    self.parts["account"]:setVisible(true)
end   

function Seting:fun3hide()
    if self.parts["account"] then
        self.parts["pwd"]:setText("")
        self.parts["pwd"]:setPlaceHolder("")
        self.parts["acc"]:setText("")
        self.parts["acc"]:setPlaceHolder("")
        
        self.parts["pwd"]:setVisible(false)
        self.parts["pwd"]:setEnabled(false)
        self.parts["acc"]:setVisible(false)
        self.parts["acc"]:setEnabled(false)
        self.parts["account"]:setVisible(false)
    end
end

function Seting:onTouch()
    local layer = self
    return function(event)
        local touched = self.bg:getCascadeBoundingBox():containsPoint(cc.p(event.x,event.y))
        if not touched then
            self:hide()
        end
    end
end

function Seting:show()
	self.bg:setScale(0.4)
    transition.scaleTo(self.bg,{
        time   = 0.25,
        scale  = 1,
        easing = "BACKOUT"
    })
    self:setTouchEnabled(true)

end

function Seting:hide(time)
    time = time or 0.2
    if self.parts["account"] then
        self.parts["pwd"]:setPlaceHolder("")
        self.parts["acc"]:setPlaceHolder("")
    end
    if self.parts["feed"] then
        self.parts["feed-input"]:setPlaceHolder("")
    end
    self:setTouchEnabled(false)
    transition.scaleTo(self.bg,{
        time = time,
        scale = 0,
        easing = "BACKIN",
        onComplete = function(  )
            self:removeSelf(true)
        end
    })
end

function Seting:initFeed()
    local bg = display.newSprite("#login/feed-bg.png",self.bg:getContentSize().width/2,self.bg:getContentSize().height/2)
        :addTo(self.bg)
    bg:setVisible(false)
    self.parts["feed"] = bg
    self.parts["feed-input"] = cc.ui.UIInput.new({
            image = "#common/1px.png",
            x = bg:getContentSize().width/2,
            y = bg:getContentSize().height/2,
            size = cc.size(1120,592),
            listener = function ( event, editbox )
                if event == "return" then
                    SendCMD:feed(string.trim(editbox:getText()))
                end
            end
        }):addTo(bg)
    self.parts["feed-input"]:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND)
    self.parts["feed-input"]:setFont("Helvetica",40)

    self.parts["feed-input"]:setPlaceholderFont("Helvetica",40)
    self.parts["feed-input"]:setMaxLength(200)
    -- self.parts["feed-input"]:setVisible(false)
    self.parts["feed-input"]:setPlaceholderFontColor(cc.c3b(200,200,200))
    
   
end

function Seting:initChangeAcc()
    local bg = display.newNode()
        :addTo(self.bg)
    bg:setVisible(false)
    local size = self.bg:getContentSize()
    self.parts["account"] = bg
    
   
    self.parts["input"] = {}
    local err = cc.ui.UILabel.new({
            UILabelType = 2,
            text = "",
            size = 30,
            color = cc.c3b(255,0,0),
            })
            :align(display.CENTER,size.width/2,size.height-130)
            :addTo(bg)
    local acc = cc.ui.UIInput.new({
            image = "#login/reg-input.png",
            x = size.width / 2,
            y = size.height * 0.77,
            size = cc.size(701,74),
            listener = function ( event, editbox )
                -- body
            end
        }):addTo(bg)
    acc:setVisible(false)
    acc:setMaxLength(11)
    acc:setPlaceholderFontColor(cc.c3b(200,200,200))
    self.parts["acc"] = acc
    local pwd = cc.ui.UIInput.new({
            image = "#login/reg-input.png",
            x = size.width / 2,
            y = size.height * 0.6,
            size = cc.size(701,74),
            listener = function ( event, editbox )
                -- body
            end
        }):addTo(bg)
    pwd:setVisible(false)
    pwd:setInputFlag(0)
    pwd:setMaxLength(20)
    pwd:setPlaceholderFontColor(cc.c3b(200,200,200))
    self.parts["pwd"] = pwd
    cc.ui.UIPushButton.new("#login/login-btn.png",{scale9 = true})
                :align(display.CENTER,size.width/2,size.height * 0.4)
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
                    device.showActivityIndicator("登陆中…")
                    CONFIG.last_login = {pwd = pwd,acc = acc,_type=2}
                    SendCMD:changeToLoginServer()

                    
                    --连接登陆服务器成功
                    SocketEvent:addEventListener(CMD.RSP_LOGIN .. "back", function(event)
                        _.Loading = Loading:new()
                        display.replaceScene(_.Loading)
                        SocketEvent:removeEventListenersByEvent(CMD.RSP_LOGIN .. "back")
                        --连接游戏服务器成功后
                        SocketEvent:addEventListener(CMD.RSP_GAME_SERVER .. "back", function(event)
                            SocketEvent:removeEventListenersByEvent(CMD.RSP_GAME_SERVER .. "back")
                                if _.Loading then
                                    _.Loading:hide()
                                    _.Loading = nil
                                end
                                if checkint(USER.tid) > 0 then
                                    SendCMD.toGame(USER.tid)
                                else
                                    _.Hall = Hall.new()
                                display.replaceScene(_.Hall)
                                end
                            end)
                        end)
                    end)       
                :addTo(bg)
    cc.ui.UIPushButton.new("#common/1px.png")
            :setButtonLabel(cc.ui.UILabel.new({
                            text = "忘记密码", 
                            size = 45, 
                            -- font = "ArialMT",
                            align = cc.ui.TEXT_ALIGN_RIGHT,
                            color =  cc.c3b(221,194,148),
                            dimensions = cc.size(355, 60)
                            })
                            )
            :align(display.CENTER,size.width * 0.65,size.height * 0.2)
            :onButtonPressed(function(event,sprite)
                event.target:runAction(cc.TintTo:create(0,128,128,128))
            end)
            :onButtonRelease(function(event)
                event.target:runAction(cc.TintTo:create(0,255,255,255))
            end)
            :onButtonClicked(function (event)
                self:hide(0)
                self.parts["acc"]:setVisible(false)
                self.parts["pwd"]:setVisible(false)
                self.parts["acc"]:setPlaceHolder("")
                self.parts["pwd"]:setPlaceHolder("")
                display.getRunningScene():addChild(require("app.scenes.index.ForgetPwd").new(function(  )
                    -- self.parts["acc"]:setVisible(true)
                    -- self.parts["pwd"]:setVisible(true)
                    -- self.parts["acc"]:setPlaceHolder("请输入手机号")
                    -- self.parts["pwd"]:setPlaceHolder("请输入密码")
                end))
            end)
            :addTo(bg) 

    cc.ui.UIPushButton.new("#common/1px.png")
            :setButtonLabel(cc.ui.UILabel.new({
                            text = "新用户注册", 
                            size = 45, 
                            -- font = "Arial-ItalicMT",
                            align = cc.ui.TEXT_ALIGN_RIGHT,
                            color =  cc.c3b(221,194,148),
                            dimensions = cc.size(355, 60)
                            })
                            )
            :align(display.CENTER,size.width * 0.25,size.height * 0.2)
            :onButtonPressed(function(event,sprite)
                event.target:runAction(cc.TintTo:create(0,128,128,128))
            end)
            :onButtonRelease(function(event)
                event.target:runAction(cc.TintTo:create(0,255,255,255))
            end)
            :onButtonClicked(function (event)
                self:hide(0)
                self.parts["acc"]:setVisible(false)
                self.parts["pwd"]:setVisible(false)
                self.parts["acc"]:setPlaceHolder("")
                self.parts["pwd"]:setPlaceHolder("")

                display.getRunningScene():addChild(require("app.scenes.index.Register").new(function(  )
                    -- self.parts["acc"]:setVisible(true)
                    -- self.parts["pwd"]:setVisible(true)
                    -- self.parts["acc"]:setPlaceHolder("请输入手机号")
                    -- self.parts["pwd"]:setPlaceHolder("请输入密码")
                end))
            end)
            :addTo(bg) 
    SocketEvent:addEventListener(CMD.RSP_GAME_SERVER .. "back", function(event)
        device.hideActivityIndicator()
        SocketEvent:removeEventListenersByEvent(CMD.RSP_GAME_SERVER .. "back")
        if checkint(USER.tid) > 0 then
            SendCMD.toGame(USER.tid)
        end
    end)
end

return Seting


