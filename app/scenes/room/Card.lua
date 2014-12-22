local Card = class("Card",display.newNode)

function Card:ctor(val, x, y, batchnode)
	val = val or 0
    self._value = val
    x,y = x or 0, y or 0
    self:setPosition(x,y)
    if val == 0 then
        self.value = 0
    else
        self.value = CONFIG.cards[val]
    end
    self.line = display.newSprite("#card-hightline.png",0,1):addTo(self)
    if val > 0 then
        self.face = display.newSprite("#card-".. self.value..".png"):addTo(self)
    else
        self.face = display.newSprite("#cover.png"):addTo(self)
    end
    self.line:setVisible(false)
    self._size = self:getContentSize();
end

function Card:changeVal(val,quick)
    val = tonumber(val) or 0
    self._value = val
    self:normal()
    if val == 0 or self._fliped then
        self.value = 0
        self.face:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("cover.png"))
        self._fliped = false
        if val == 0 then
            return
        end
    end
    self.value = CONFIG.cards[val]
    if quick then
    	self.face:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("card-"..self.value..".png"))
    else
        self:flip()
    end

end

function Card:flip()
    if (not checkint(self.value))  or self._fliped then return end
    local time = 0.2
    local a1 = cc.ScaleBy:create(time,-0.01,1.2)
    local a2 = cc.ScaleTo:create(time,1,1)
    local action = transition.sequence({a1,a2})
    self:runAction(action)
    transition.moveTo(self.face,{time = 0.15,y = 18})
    self._frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("card-".. self.value..".png")
    self:performWithDelay(function()
        self.face:setSpriteFrame(self._frame)
    end,time)
    transition.moveTo(self.face,{time = 0.15,y = 0, delay = time*1.4})

    if self._showline then
        self.line:setVisible(false)
        self:performWithDelay(function()
             self:showline()
        end,0.5)
    end
    self._fliped = true
end

function Card:gray()
    local action  = cc.TintTo:create(0, 160, 160, 160);
    self.face:runAction(action)
    self._gray = true
end

function Card:normal()
    local action  = cc.TintTo:create(0, 255, 255, 255);
    self.face:runAction(action)
    self._highlight = false
    self._gray = false
end

function Card:showline()
    self._showline = true
    self.line:setVisible(true)
end

function Card:hideline()
    self._showline = false
    self.line:setVisible(false)
end

local function getCardVal( card )
    return card % 100
end

local function getCardColor( card )
    return math.floor(card/100)
end

-- 从小到大
function getCardSortByVal( cards )
    table.sort(cards,function(a,b)
        return getCardVal(a) > getCardVal(b)
    end)
    return cards
end

function getCardUniqueByVal( cards )
    local tmp = {}
    for  i,card in ipairs(cards) do
        local val = getCardVal(card)
        tmp[val] = card
    end
    cards = table.values(tmp)

    table.sort(cards,function(a,b)
        return b>a
    end)
    return cards
end

-- 判断皇家同花顺
local function isRoyalFlush(cards)
    if #cards < 5 then  return  false end
    local tmp = table.concat(cards,",")
    local royalflush = {
        {110,111,112,113,114},
        {210,211,212,213,214},
        {310,311,312,313,314},
        {410,411,412,413,414}
    }
    for i, r in ipairs(royalflush) do
        local str = table.concat(r,",")
        if string.match(tmp, str) then
            return r
        end
    end
    return false
end

-- 是否同花
local function isFlush( cards )
    if #cards < 5 then  return  false end
    local colorCard = {{},{},{},{}};
    for i,card in ipairs(cards) do
        local color = getCardColor(card);
        table.insert(colorCard[color],card)
    end

    for i,v in ipairs(colorCard) do
        if #v >= 5 then
            return v
        end
    end
    return false
end


-- 是否顺子
local function isStraight( cards )
    if #cards < 5 then  return false end
    cards = clone(cards)
    for i,card in ipairs(cards) do
        local val = getCardVal(card)
        if val == 14 then
            table.insert(cards,card - 13) -- A 当 1 用
        end
    end

    cards = getCardUniqueByVal(cards)
    cards = getCardSortByVal(cards)
    local _from,_to = 0,0
    for i=1,#cards-1 do
        if getCardVal(cards[i]) == getCardVal(cards[i+1]) + 1 then
            _from = _from > 0 and _from or i
            _to = i + 1
            if (_to - _from == 4) then
                break
            end
        else
            _from,_to = 0,0
        end
    end

    if (_to - _from >= 4) then
        local hCard = table.slice(cards,_from,_to)
        for i,card in ipairs(hCard) do
            if getCardVal(card) == 1 then
                table.remove(hCard,i)
                table.insert(hCard,card+13) -- 1转A
            end
        end
        return hCard
    end
    return false
end

local function isFourKind(cards)
    if #cards < 4 then  return false end
    local cardVal = {}
    for i,card in ipairs(cards) do
        local val = getCardVal(card)
        cardVal[val] = cardVal[val] or {}
        table.insert(cardVal[val],card)
        if #(cardVal[val]) == 4 then
            return cardVal[val]
        end
    end
    return false
end

local function isFullHouse(cards)
    if #cards < 5 then  return false end
    cards = clone(cards)
    cards = getCardSortByVal(cards)
    local cardVal = {}
    local card3arr,card2arr
    local card2,card3 = 0,0
    for i,card in ipairs(cards) do
        local val = getCardVal(card)
        cardVal[val] = cardVal[val]  or {}
        table.insert(cardVal[val] , card)
    end
    -- 可以合并上去
    for val,card in pairs(cardVal) do
        if #card == 3 then
            if card3 < val then
                card3arr = card
                card3 = val
            end
        end
    end

    if card3 == 0 then  return false end

    for val,card in pairs(cardVal) do
        if #card >= 2 and val ~= card3 then
            if card2 < val then
                card2arr = card
                card2 = val
            end
        end
    end
    if (card3arr and card2arr) then
        card2arr = table.slice(card2arr,1,2)
        table.append(card3arr,card2arr)
        return card3arr
    end
    return false
end

local function isThreeKind( cards )
    if (#cards < 3)  then return false end
    local cardVal = {}
    for i,card in ipairs(cards) do
        local val = getCardVal(card)
        cardVal[val] = cardVal[val] or {}
        table.insert(cardVal[val],card)
        if #(cardVal[val]) == 3 then
            return cardVal[val]
        end
    end
    return false
end

local function isTwoPairs( cards )
    if (#cards < 4)  then return false end
    -- 有3对的可能,需排序
    cards  = getCardSortByVal(cards)
    local cardVal = {}
    local pairCard = {}
    for i,card in ipairs(cards) do
        local val = getCardVal(card)
        cardVal[val] = cardVal[val] or {}
        table.insert(cardVal[val],card)
        if #(cardVal[val]) ==2 then
            table.insert(pairCard,cardVal[val])
        end
    end

    if #pairCard >=2 then return table.append(pairCard[1],pairCard[2]) end
    return false
end


local function isPair(cards)
    local cardVal = {}
    local pairCard = {}
    for i,card in ipairs(cards) do
        local val = getCardVal(card)
        cardVal[val] = cardVal[val] or {}
        table.insert(cardVal[val],card)
        if #(cardVal[val]) == 2 then
            return cardVal[val]
        end
    end
    return false
end


-- TODO 为更精确计算牌型,应将公共牌和手牌单独传入计算
function Card.calCard(cards,handcards)
    cards = checktable(cards)
    handcards = checktable(handcards)
    --从大到小排
    table.sort(cards,function(a,b)
        return a>b
    end)

    local retVal = {};
    retVal.cards = cards

    local hCard
    if #cards >= 4  then

        -- 判断皇家同花顺
        hCard = isRoyalFlush(cards)
        if hCard then
            retVal.type = Card.ROYAL_FLUSH
            retVal.hCard = hCard
            return retVal
        end

        --是否同花顺
        --先判断是否有同花
        local _isFlush = false
        local _flushCard = false
        hCard = isFlush(cards)
        if hCard then
            _flushCard = hCard
            _isFlush = true
            --再判断是否是顺子
            local _hCard =  isStraight(hCard)
            if _hCard then
                retVal.type = Card.STRAIGHT_FLUSH
                retVal.hCard = table.slice(_hCard, 1, 5)
                return retVal
            end
        end

        --是否四条
        hCard = isFourKind(cards)
        if hCard then
            retVal.type = Card.FOUR_KIND
            retVal.hCard = hCard
            return retVal
        end

        --是否葫芦
        hCard = isFullHouse(cards)
        if hCard then
            retVal.type = Card.FULL_HOUSE
            retVal.hCard = hCard
            return retVal
        end


        --是否同花
        if _isFlush then
            retVal.type  = Card.FLUSH
            retVal.hCard = table.slice(_flushCard, 1, 5)
            return retVal
        end

        --是否顺子
        hCard = isStraight(cards)
        if hCard then
            retVal.type  = Card.STRAIGHT
            retVal.hCard = table.slice(hCard, 1, 5)
            return retVal
        end
    end

    --是否三条
    hCard = isThreeKind(cards);
    if hCard then
        retVal.type  = Card.THREE_KIND
        retVal.hCard = hCard
        return retVal
    end


    --是否两对
    hCard = isTwoPairs(cards)
    if hCard then
        retVal.type = Card.TOW_PAIRS
        retVal.hCard = hCard
        return retVal
    end

    --是否一对
    hCard = isPair(cards)
    if hCard then
        retVal.type = Card.PAIR
        retVal.hCard = hCard
        return retVal
    end


    cards  = getCardSortByVal(cards)
    retVal.type = Card.HIGH_CARD
    retVal.hCard = {cards[1]}
    return retVal

end


function Card.getCardType(cards)
    local r = Card.calCard(cards)
    return r.type,r.hCard
end

-- --牌型
Card.HIGH_CARD = 1          -- 高牌
Card.PAIR = 2               -- 一对
Card.TOW_PAIRS = 3          -- 两对
Card.THREE_KIND = 4         -- 三条
Card.STRAIGHT = 5           -- 顺子
Card.FLUSH = 6              -- 同花
Card.FULL_HOUSE = 7         -- 葫芦
Card.FOUR_KIND = 8          -- 四条
Card.STRAIGHT_FLUSH = 9    -- 同花顺
Card.ROYAL_FLUSH = 10       -- 皇家同花顺

return Card
