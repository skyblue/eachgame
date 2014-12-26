MyStore = class("MyStore",display.newNode)

local UIScrollView = require("framework.cc.ui.UIScrollView")

function MyStore:ctor()
    
    self.title = {"商城","兑换"}
    SocketEvent:addEventListener(CMD.RSP_SHOPLIST .. "back", function(event)
        SocketEvent:removeEventListenersByEvent(CMD.RSP_SHOPLIST .. "back")
        self:init()
    end)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT,self:onTouch())
    self:setContentSize(display.width,display.height)
end

function MyStore:onTouch()
    local layer = self
    return function(event)
            self:hide()
        return true
    end
end

function MyStore:show()
    if not self.load then
        self:init()
    end
    self.mask:setVisible(true)
    self:setVisible(true)
    self.bg:setScale(0.4)
    transition.scaleTo(self.bg,{
        time   = 0.25,
        scale  = 1,
        easing = "BACKOUT"
    })
    self:setTouchEnabled(true)
end

function MyStore:hide()
    self:setTouchEnabled(false)
    transition.scaleTo(self.bg,{
        time = 0.2,
        scale = 0,
        easing = "BACKIN",
        onComplete = function(  )
            self.mask:setVisible(false)
            self:setVisible(false)
        end
    })
end

function MyStore:init()
    if MyStore.data then
    -- MyStore.data = {{chips = 100000,addChips = 10000,unit = "￥",money = 20,proid ="com.eg.texas.c6"},
    --     {chips = 100000,addChips = 10000,unit = "￥",money = 20,proid ="com.eg.texas.c6"},
    --     {chips = 100000,addChips = 10000,unit = "￥",money = 20,proid ="com.eg.texas.c6"},
    --     {chips = 100000,addChips = 10000,unit = "￥",money = 20,proid ="com.eg.texas.c6"},
    --     {chips = 100000,addChips = 10000,unit = "￥",money = 20,proid ="com.eg.texas.c6"},
    --     {chips = 100000,addChips = 10000,unit = "￥",money = 20,proid ="com.eg.texas.c6"},
    --     {chips = 100000,addChips = 10000,unit = "￥",money = 20,proid ="com.eg.texas.c6"},
    --     {chips = 100000,addChips = 10000,unit = "￥",money = 20,proid ="com.eg.texas.c6"},
    --     {chips = 100000,addChips = 10000,unit = "￥",money = 20,proid ="com.eg.texas.c6"},
    --     {chips = 100000,addChips = 10000,unit = "￥",money = 20,proid ="com.eg.texas.c6"},
    --     {chips = 100000,addChips = 10000,unit = "￥",money = 20,proid ="com.eg.texas.c6"},
    --     {chips = 100000,addChips = 10000,unit = "￥",money = 20,proid ="com.eg.texas.c6"},
    --     {chips = 100000,addChips = 10000,unit = "￥",money = 20,proid ="com.eg.texas.c6"}}   


        local mask = display.newColorLayer(cc.c4b(0,0,0,0))
            :addTo(self)
        mask:setContentSize(display.width,display.height)
        mask:setOpacity(190)
        mask:setTouchEnabled(false)
        self.mask =  mask
        local bg = display.newSprite("img/myinfo-bg.png",display.cx,display.cy)
            :addTo(self)
        self.bg = bg

        cc.ui.UIPushButton.new("#common/close_icon.png")
            :align(display.CENTER,bg:getContentSize().width,bg:getContentSize().height)
            :onButtonPressed(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,-128,-128,-128))
            end)
            :onButtonRelease(function(event)
                    -- sprite:runAction(cc.TintBy:create(0,255,255,255))
            end)
            :onButtonClicked(function (event)
                    self:hide()
                    utils.playSound("click")
            end)
            :addTo(bg)
        self.list = cc.ui.UIListView.new {
            viewRect = cc.rect(0,0, bg:getContentSize().width, bg:getContentSize().height-120),
            direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
            }
        :addTo(bg)
        local xx,yy = bg:getContentSize().width/2,bg:getContentSize().height/2
        cc.ui.UILabel.new({text = self.title[1] , size = 60})
                :align(display.CENTER,xx,bg:getContentSize().height-40)
                :addTo(bg)
        local height,item,line,content = 100
        for k,v in pairs(MyStore.data) do
            item = self.list:newItem()
            content = display.newNode()
                -- :pos(bg:getContentSize().width/2,yy)
            line = display.newSprite("#common/line.png",0,height/2)
                :addTo(content)
            line:setScaleX(1.2)
            display.newSprite("#chip-blue.png",-xx + 60,0)
                :addTo(content)
            cc.ui.UILabel.new({text = utils.numAbbr(v.chips).."筹码(赠".. utils.numAbbr(v.addChips) .. ")" , size = 40})
                :align(display.CENTER,-300,0)
                :addTo(content)
            cc.ui.UILabel.new({text = "实得：".. utils.numAbbr(v.addChips+v.chips) , size = 40})
                :align(display.CENTER,100,0)
                :addTo(content)
            cc.ui.UIPushButton.new("#common/green-btn.png",{scale9 = true})
                :setButtonSize(226, 82)
                :setButtonLabel(cc.ui.UILabel.new({text = v.unit..v.money.." 购买", size = 40, font = "Helvetica-Bold"}))
                :align(display.CENTER,460,0)
                :onButtonPressed(function(event)
                        -- sprite:runAction(cc.TintBy:create(0,-128,-128,-128))
                end)
                :onButtonRelease(function(event)
                        -- sprite:runAction(cc.TintBy:create(0,255,255,255))
                end)
                :onButtonClicked(function (event)
                       self:buyItem(v)
                end)
                :addTo(content)

            item:addContent(content)
            item:setItemSize(bg:getContentSize().width,height)
            self.list:addItem(item)
        end
        self.load = true
        self.list:reload()
    else 
        SendCMD:getShoplist()
    end
    self:setVisible(false)
end



function MyStore.loadProducts(data)
    local productIds = {}
    for i,r in ipairs(data) do
        table.insert(productIds, r.proid)
    end
    Store.loadProducts(productIds, function ( products )
        for k,v in pairs(products["products"]) do
            MyStore.products[v.productIdentifier] = v.productIdentifier
        end
    end)
end

function MyStore.initStore(productIds)

   function transactionCallback(event)
        local transaction = event.transaction
        device.hideActivityIndicator()
        if transaction.state == "purchased" then
            local receipt = transaction.receipt
            local params = {
                productId = transaction.productIdentifier,
                transactionIdentifier = transaction.transactionIdentifier,
                sandbox = DEBUG > 1 and 1 or 0
            }

            params["receipt_data"] = crypto.encodeBase64(transaction.receipt)  --出来的结果带有换行符
            params["receipt_data"] = string.gsub(params["receipt_data"], "\n", "")
            params["pf"] = "appstore"
            -- for i,v in ipairs(USER.sendChips) do
                -- if v[2] == transaction.productIdentifier then
                    params["to_uid"] = USER.uid--v[1]
                    -- table.remove(USER.sendChips,i)
                    -- break
                -- end
            -- end
            SendCMD:buy(params)
        elseif  transaction.state == "restored" then
        elseif transaction.state == "failed" then
            utils.dialog("","支付失败，请重试",{"关闭"})
            -- dump("errorCode", transaction.errorCode)
            -- dump("errorString", transaction.errorString)
        else
            --取消支付会触发
            -- dump("取消支付会触发 unknown event")
        end
        Store.finishTransaction(transaction)
    end
    Store.init(transactionCallback)
end

function MyStore:buyItem(data)
    local proid = data.proid
    if not Store.canMakePurchases() then
        utils.dialog("","您当前不能支付",{"确认"})
        return
    end
    device.showActivityIndicator("连接App Store中…")

    local tid = self:performWithDelay(function( ... )
        device.showActivityIndicator("连接App Store超时…")
        self:performWithDelay(function( ... )
            device.hideActivityIndicator()
        end, 1)
    end, 30)
    if MyStore.products[proid] then
        Store.purchase(proid)
        transition.removeAction(tid)
        -- Analytics.event("购买开始")
    else
        Store.loadProducts({proid}, function ( data )
            if data['invalidProductsId'] then
                device.hideActivityIndicator()
                transition.removeAction(tid)
                utils.dialog("","该商品当前无法购买",{"确认"})
                return
            end
            transition.removeAction(tid)
            MyStore.products[proid] = data["products"][1].productIdentifier
            Store.purchase(proid)
            -- Analytics.event("购买开始")
        end)
    end
end


return MyStore
