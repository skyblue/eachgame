local UserInfo = class("UserInfo",display.newNode)

function UserInfo:initMyInfo()
	local bg = display.newSprite("img/myinfo-bg.png",display.cx,display.cy)
    :addTo(self)
    bg:setVisible(false)
    local head = utils.makeAvatar({size = cc.size(216, 216),mask_choose =2})
    -- border = "#hall/head-bg.png"
	head:setPosition(400,bg:getContentSize().height -380)
	bg:addChild(head)	
	head:setScale(1.2)
    cc.ui.UIPushButton.new("#common/close_icon.png")
            :align(display.CENTER,bg:getContentSize().width-150,bg:getContentSize().height-94)
            :onButtonPressed(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,-128,-128,-128))
            end)
            :onButtonRelease(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,255,255,255))
            end)
            :onButtonClicked(function (event)
            	utils.playSound("click")
                self:hide()
            end)
            :addTo(bg)
	local menu = {"meun_1","meun_2","meun_2","meun_3"}
	local menuText = {"基本资料","详细记录","物品","成就"}
	self.parts["menu"] ={}
	for i=1,4 do
		self.parts["menu"][i] = cc.ui.UIPushButton.new("#common/"..menu[i]..".png")
            :setButtonLabel(cc.ui.UILabel.new({
                    text = menuText[i], 
                    size = 36, 
                    font = "Helvetica-Bold",
                    align = cc.ui.TEXT_ALIGN_RIGHT,
                    })
                    )
            -- :setButtonLabelOffset(24,0)
            :align(display.CENTER,480 + (i-1)*246,800)
            :onButtonPressed(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,-128,-128,-128))
            end)
            :onButtonRelease(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,255,255,255))
            end)
            :onButtonClicked(function (event)
                    local menuFrames
                    for j,v in ipairs(self.parts["menu"]) do
                    	menuFrames = "common/"..menu[j]..".png"
                    	v.sprite_[1]:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(menuFrames))
                    end
                    if i == 3 then
                    	menuFrames = "common/"..menu[i].."2.png"
                    elseif i == 4 then
                    	menuFrames = "common/"..menu[i].."3.png"
                    else
                    	menuFrames = "common/"..menu[i]..i..".png"
                    end
            		self.parts["menu"][i].sprite_[1]:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(menuFrames))
            		--切换下资料
            		self:changeMyinfo()
            end)
            :addTo(bg)
            :setVisible(false) 
	end
	self.myinfo = bg
	self:initPublicInfo(bg)
end

function UserInfo:initOtherInfo()
	local bg = display.newSprite("#common/userinfo-bg.png",display.cx,display.cy)
    :addTo(self)
    bg:setVisible(false)
    local head = utils.makeAvatar({size = cc.size(216, 216),mask_choose =2})
	head:setPosition(200,bg:getContentSize().height - 200)
	bg:addChild(head)
	cc.ui.UIPushButton.new("#common/close_icon.png")
            :align(display.CENTER,bg:getContentSize().width-150,bg:getContentSize().height-94)
            :onButtonPressed(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,-128,-128,-128))
            end)
            :onButtonRelease(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,255,255,255))
            end)
            :onButtonClicked(function (event)
                    self:hide()
            end)
            :addTo(bg)
 --    local addFriend = cc.ui.UIPushButton.new("#common/green-btn.png", {scale9 = true})
	-- 		:setButtonSize(160, 90)
 --            :setButtonLabel(cc.ui.UILabel.new({
 --                    text = "关注", 
 --                    size = 34, 
 --                    font = "Helvetica",
 --                    align = cc.ui.TEXT_ALIGN_RIGHT,
 --                    })
 --                    )
 --            :setButtonLabelOffset(24,0)
 --            :align(display.LEFT_CENTER,100,340)
 --            :onButtonPressed(function(event)
 --                    -- sprite:runAction(cc.TintBy:create(0,-128,-128,-128))
 --            end)
 --            :onButtonRelease(function(event)
 --                    -- sprite:runAction(cc.TintBy:create(0,255,255,255))
 --            end)
 --            :onButtonClicked(function (event)
 --                    dump("add friend")
 --            end)
 --            :addTo(bg)
	-- display.newSprite("#common/add-friend.png",36,6):addTo(addFriend)
	-- self.parts["addFriend"] = addFriend

	display.newSprite("#common/line.png",bg:getContentSize().width/2,200):addTo(bg)

	self.parts["props"] ={}
	local propsImg,propsBg = {"flower","bomb","beer","egg"}
	for i=1,7 do
        -------------------------互动道具--------------------------
	    propsBg = display.newSprite("#common/goods_background.png",128+(i-1)*140,120)
	        	:addTo(bg)
		self.parts["props"][i] = propsBg
	    if propsImg[i] then
	        cc.ui.UIPushButton.new("#common/"..propsImg[i]..".png")
	            :align(display.LEFT_CENTER,0,62)
	            :onButtonPressed(function(event)
	                    -- sprite:runAction(cc.TintBy:create(0,-128,-128,-128))
	            end)
	            :onButtonRelease(function(event)
	                    -- sprite:runAction(cc.TintBy:create(0,255,255,255))
	            end)
	            :onButtonClicked(function (event)
	                     dump(i)
	            end)
	            :addTo(propsBg)

	    end
	end
	self.otherinfo = bg
	self:initPublicInfo(bg)
end

function UserInfo:initPublicInfo(bg)
	bg.cards ={}
	bg.text = {}
	bg.textIcon = {}
	for i=1,7 do
		bg.text[i] = cc.ui.UILabel.new({
            UILabelType = 2,
            text = "",
            size = 34,
            color = table.indexof({2,3},i) and cc.c3b(254,221,70) or cc.c3b(255,0,0),
            })
            :align(display.LEFT_CENTER)
            :addTo(bg)
        if i > 1 then    
	        bg.textIcon[i-1] = display.newSprite("#common/icon_"..(i-1)..".png")
	        	:addTo(bg)
	    else
	    	bg.sexIcon = display.newSprite("#common/female.png")
	        	:addTo(bg)
	    end
	end
	bg.pokerIcon = display.newSprite("#common/icon_8.png")
	        	:addTo(bg)
	for i=1,5 do
		bg.cards[i] = Card.new()
		bg.cards[i]:setScale(0.8)
		bg:addChild(bg.cards[i])
	end
end

function UserInfo:ctor()
	self.parts={}
	self:initOtherInfo()
	self:initMyInfo()
end

function UserInfo:show(user)
	local xx,yy,height,textIcon,text,pokerIcon,sexIcon,bg = 440,600,60
	local cardy = 310
	if user.uid ==  USER.uid then
		xx,yy,height = 700,700,80
		self.myinfo:setVisible(true)
		self.otherinfo:setVisible(false)
		text = self.myinfo.text
		textIcon = self.myinfo.textIcon
		bg = self.myinfo
		bg.pokerIcon:pos(xx-64,354)
		cardy = 410
	else
		bg = self.otherinfo
		self.myinfo:setVisible(false)
		bg:setVisible(true)
		text = bg.text
		textIcon = bg.textIcon
		bg.pokerIcon:pos(xx-64,350)
	end
	if user.best_cards then
		for i,v in ipairs(user.best_cards) do
			bg.cards[i]:changeVal(v)
			bg.cards[i]:setPosition(xx +40 + (i-1)*104, yy - cardy)
		end
	end
	user.city = user.city or "神秘"
	if user.city ==  "" then
		user.city = "神秘"
	end
	local win = user.win_count / user.play_count
	if user.play_count == 0 then 
		win = 0
	end
	local textInfo = {user.uname , utils.numAbbr(user.uchips) , user.level,user.city,
		utils.numAbbr(user.win_max) ,  utils.numAbbr(user.win_total) , 
		user.win_count.."胜"..user.play_count.."局 - %" .. win .."胜率"}
	for i,v in pairs(textInfo) do
		if i == 5 then
        	yy = 530
        	if user.uid ==  USER.uid then
        		yy = 630
        	end
        	xx = xx + 320
        end
		text[i]:setString(v)
		text[i]:pos(xx,yy)
		if i > 1 then    
			textIcon[i-1]:pos(xx-64,yy)
		else
			bg.sexIcon:pos(xx-64,yy)
		end
		yy = yy - height
	end
	if user.sex ==1 then
		bg.sexIcon:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("common/female.png"))
	else
		bg.sexIcon:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("common/male.png"))
	end
	self:setVisible(true)
end

function UserInfo:hide()
	self:setVisible(false)
end

return UserInfo