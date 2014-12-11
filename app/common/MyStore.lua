MyStore = class("MyStore",display.newNode)

local Store = require("framework.cc.sdk.Store")
local UIScrollView = require("framework.cc.ui.UIScrollView")

function MyStore:ctor()
	-- SendCMD:getShoplist({appid =  CONFIG.appid,versioncode = CONFIG.versioncode})
	SocketEvent:addEventListener(CMD.RSP_SHOPLIST .. "back", function(event)
		self.data = event.data
		self:loadProducts(self.data)
        -- if display.getRunningScene().name == "MyStore" then
        --     self:init()
        -- end
    end)

    SocketEvent:addEventListener(CMD.RSP_BUY .. "back", function(event)
    	local data = event.data
    	device.hideActivityIndicator()
        device.cancelAlert()
        if not data.uid or (data.code and data.code > 10) then --数据验证错误 IAP破解插件
            utils.notice("购买失败","您的订单信息有误，请确认后重试。",{"关闭"})
            return
        end

        if data.status == 6 then --延时发货
            utils.notice("购买成功","我们正在处理您的订单，筹码将会延时到帐（24 小时内）。",{"确认"})
        else
            utils.notice("购买成功","您的订单已成功。",{"确认"})
        end
        self:updatePayCount()
        -- Analytics.event("购买成功")
    end)
	
    self:initStore()
end

function MyStore:show()
    -- if self.data then

        local bg = display.newSprite("img/myinfo-bg.png",display.cx,display.cy)
        :addTo(self)
        cc.ui.UIPushButton.new("#common/close_icon.png")
            :align(display.CENTER,bg:getContentSize().width-150,bg:getContentSize().height-92)
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
        self.list = cc.ui.UIListView.new {
            viewRect = cc.rect(30,60, 1600, 680),
            direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
            }
        :addTo(bg)
        cc.ui.UILabel.new({text = "商城" , size = 60})
                :align(display.CENTER,display.cx,display.top - 150)
                :addTo(self)
        local height,item,line,content = 100
        self.data = {{chips = 100000,addChips = 10000,unit = "￥",money = 20,proid ="com.eg.texas.c6"},
        {chips = 100000,addChips = 10000,unit = "￥",money = 20,proid ="com.eg.texas.c6"},
        {chips = 100000,addChips = 10000,unit = "￥",money = 20,proid ="com.eg.texas.c6"},
        {chips = 100000,addChips = 10000,unit = "￥",money = 20,proid ="com.eg.texas.c6"},
        {chips = 100000,addChips = 10000,unit = "￥",money = 20,proid ="com.eg.texas.c6"},
        {chips = 100000,addChips = 10000,unit = "￥",money = 20,proid ="com.eg.texas.c6"},
        {chips = 100000,addChips = 10000,unit = "￥",money = 20,proid ="com.eg.texas.c6"},
        {chips = 100000,addChips = 10000,unit = "￥",money = 20,proid ="com.eg.texas.c6"},
        {chips = 100000,addChips = 10000,unit = "￥",money = 20,proid ="com.eg.texas.c6"},
        {chips = 100000,addChips = 10000,unit = "￥",money = 20,proid ="com.eg.texas.c6"},
        {chips = 100000,addChips = 10000,unit = "￥",money = 20,proid ="com.eg.texas.c6"},
        {chips = 100000,addChips = 10000,unit = "￥",money = 20,proid ="com.eg.texas.c6"},
        {chips = 100000,addChips = 10000,unit = "￥",money = 20,proid ="com.eg.texas.c6"}}   

        for k,v in pairs(self.data) do
            -- dump(v)
            item = self.list:newItem()
            content = display.newNode()
                -- :pos(bg:getContentSize().width/2,yy)
            line = display.newSprite("#common/line.png",0,height/2)
                :addTo(content)
            line:setScaleX(1.5)
            display.newSprite("#chip-blue.png",-bg:getContentSize().width/2 +200,0)
                :addTo(content)
            cc.ui.UILabel.new({text = utils.numAbbr(v.chips).."筹码(赠".. utils.numAbbr(v.addChips) .. ")" , size = 40})
                :align(display.CENTER,-200,0)
                :addTo(content)
            cc.ui.UILabel.new({text = "实得：".. utils.numAbbr(v.addChips+v.chips) , size = 40})
                :align(display.CENTER,200,0)
                :addTo(content)
            cc.ui.UIPushButton.new("#common/green-btn.png",{scale9 = true})
                :setButtonSize(226, 82)
                :setButtonLabel(cc.ui.UILabel.new({text = v.unit..v.money.." 购买", size = 40, font = "Helvetica-Bold"}))
                :align(display.CENTER,560,0)
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
        self.list:reload()
    -- else 
    --     SendCMD:getShoplist({appid =  CONFIG.appid,versioncode = CONFIG.versioncode})
    -- end 
end

function MyStore:loadProducts(data)
    local productIds = {}
    for i,r in ipairs(data) do
        table.insert(productIds, r.proid)
    end
    -- local t1 = os.clock()
    Store.loadProducts(productIds, function ( products )
        self.products = products
        -- console.log("请求products耗时:",(os.clock() - t1)/1000 )
    end)
end

function MyStore:initStore(productIds)

   function transactionCallback(event)
        local transaction = event.transaction
        if transaction.state ~="purchased" then
            device.hideActivityIndicator()
            device.cancelAlert()
        end
        if transaction.state == "purchased" then
            -- print("Transaction succuessful!")
            -- print("productId", transaction.productIdentifier)
            -- print("quantity", transaction.quantity)
            -- print("transactionIdentifier", transaction.transactionIdentifier)
            -- print("date", os.date("%Y-%m-%d %H:%M:%S", transaction.date))
            -- print("receipt", transaction.receipt)
            -- print("originalDate", transaction.originalDate)

            -- 整理数据发回服务器
            local receipt = transaction.receipt
            local params = {
                productId = transaction.productIdentifier,
                transactionIdentifier = transaction.transactionIdentifier,
                -- sandbox = DEBUG > 1 and 1 or 0
            }

            params["receipt-data"] = crypto.encodeBase64(transaction.receipt)  --出来的结果带有换行符
            params["receipt-data"] = string.gsub(params["receipt-data"], "\n", "")
            -- params["receipt-data"] = string.urlencode(params["receipt-data"])
            if DEBUG > 0 then
                params.sandbox = 1
            end

            params["pf"] = "appstore"
            for i,v in ipairs(USER.sendChips) do
                if v[2] == transaction.productIdentifier then
                    params["to_uid"] = v[1]
                    table.remove(USER.sendChips,i)
                    break
                end
            end
            SendCMD:buy(params)

        elseif  transaction.state == "restored" then
            -- print("Transaction restored (from previous session)")
            -- print("productId", transaction.productIdentifier)
            -- print("receip:t", transaction.receipt)
            -- print("transactionIdentifier", transaction.identifier)
            -- print("date", transaction.date)
            -- print("originalReceipt", transaction.originalReceipt)
            -- print("originalTransactionIdentifier", transaction.originalIdentifier)
            -- print("originalDate", transaction.originalDate)
        elseif transaction.state == "failed" then
            utils.notice("","支付失败，请重试",{"关闭"})
            console.error("errorCode", transaction.errorCode)
            console.error("errorString", transaction.errorString)
        else
            --取消支付会触发
            console.warn("unknown event")
        end
        Store.finishTransaction(transaction)
    end
    -- Store.init(transactionCallback)
end

function MyStore:buyItem(data)
    dump(data)
    local proid = data.proid
    if not Store.canMakePurchases() then
        utils.notice("","您当前不能支付",{"确认"})
        return
    end
    device.showActivityIndicator("连接App Store中…")

    local tid = scheduler.performWithDelayGlobal(function( ... )
        device.showActivityIndicator("连接App Store超时…")
        scheduler.performWithDelayGlobal(function( ... )
            device.hideActivityIndicator()
        end, 1)
    end, 30)

    if self.products[proid] then
        Store.purchase(proid)
        scheduler.clearTimeout(tid)
        -- Analytics.event("购买开始")
    else
        Store.loadProducts({proid}, function ( data )
            if data['invalidProductsId'] then
                device.hideActivityIndicator()
                scheduler.clearTimeout(tid)
                utils.notice("","该商品当前无法购买",{"确认"})
                return
            end
            self.products[proid] = data["products"][1]
            self.purchase(proid)
            scheduler.clearTimeout(tid)
            -- Analytics.event("购买开始")
        end)
    end
end


return MyStore
