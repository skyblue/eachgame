local utils = {}

 function utils.__merge(parant,val)
        for k,v in pairs(val) do 
           if type(v) == "table" then
                if not parant[k] then
                    parant[k] = {}
                end
                utils.__merge(parant[k],v)
            else
                parant[k] = v
            end
        end
    end
--[[--test empty value
### Example:
### Parameters:
-   anything
### Returns:
-   bool
]]
function utils.empty(v)
    return  v == nil or v == false or v == "" or v == 0
end
--[[--
convert Lua table to CCArray
### Example:
    utils.table2array({1,2,3})
### Parameters:
-   lua table
### Returns:
-   CCArray]]
function utils.table2array(t)
    local arr = CCArray:create()
    local count = #t
    for i = 1, count do
        arr:addObject(t[i])
    end
    return arr
end

--[[--convert  CCArray to Lua table
### Example:
    utils.array2table((CCArray) arr)
### Parameters:
-   CCArray
### Returns:
-   Lua table ]]
function utils.array2table(arr)
    if tolua.type(arr) ~= "CCArray" then return end
    local t = {}
    for i = 1,  arr:count() do
        table.insert(t, arr:objectAtIndex(i-1))
    end
    return t
end

--[[--convert hex to ccc3
### Example:
    utils.hex2ccc3("#FFFFFF") -- return ccc3(255, 255, 255)
### Parameters:
-   string
### Returns:
-   c3b]]
function utils.hex2ccc3(hex)
    if string.sub(hex,1,1) ~= "#" then return nil end
    hex = string.sub(hex,2)
    local r,g,b = string.sub(hex,1,2),string.sub(hex,3,4),string.sub(hex,5,6)
    r = tonumber("0x"..r)
    g = tonumber("0x"..g)
    b = tonumber("0x"..b)
    return cc.c3b(r,g,b)
end

function utils.distance(x1,y1,x2,y2)
  local a = x1 - x2
  local b = y1 - y2
  return math.sqrt(math.pow(a, 2) + math.pow(b, 2))
end

function utils.distancePoints(p1,p2)
  return utils.distance(p1.x,p1.y,p2.x,p2.y)
end

function utils.parse_query(query)
    local parsed = {}
    local pos = 0

    query = string.gsub(query, "&amp;", "&")
    query = string.gsub(query, "&lt;", "<")
    query = string.gsub(query, "&gt;", ">")

    local function ginsert(qstr)
        local first, last = string.find(qstr, "=")
        if first then
            parsed[string.sub(qstr, 0, first-1)] = string.sub(qstr, first+1)
        end
    end

    while true do
        local first, last = string.find(query, "&", pos)
        if first then
            ginsert(string.sub(query, pos, first-1));
            pos = last+1
        else
            ginsert(string.sub(query, pos));
            break;
        end
    end
    return parsed
end

--[[--

数字格式化为亿/万单位,(英文环境下为 M/K单位)

### Example:

    utils.numAbbr("123456789") -- return "1.2亿"
    utils.numAbbr("123456") -- return "12.3万"

### Parameters:

-   number int/string  待格式的数值
-   digit int 小数点后位数

### Returns:

-   string

]]
function utils.numAbbr(num, digit)
    digit = digit or 1
    num = checkint(num) 
    local s
    if table.indexof({"en","tw","de","th","ida"}, CONFIG.lang) then
        if(num >= 1e6 ) then
            s = string.format("%gM", string.format("%."..digit.."f",num / 1e6));
        elseif(num >= 1e3 ) then
            s = string.format("%gK", string.format("%."..digit.."f",num / 1e3));
        else
            s = tostring(num)
        end
    else
        if(num >= 1e8 ) then
            s = string.format("%g".."亿",string.format("%."..digit.."f",num / 1e8));
        elseif(num >= 1e4 ) then
            s = string.format("%g".."万",string.format("%."..digit.."f",num / 1e4));
        else
            s = tostring(num)
        end
    end
    return s
end

function utils.formatNumber(num)
    return string.formatNumberThousands(num)
end

local checktableid_gap
function utils.playSound(title,isloop,suffix)
    if not utils.getUserSetting("sound_enabled",true) then return end
    local filename = CONFIG.soundList[title]
    if filename == nil then return end
    if device.platform ~= "android" then
        if not suffix then
            filename = filename..".mp3"
        else
            filename = filename .. suffix
        end
        return audio.playSound("res/mp3/"..filename,isloop)
    else
        filename = filename..".ogg"
        return audio.playSound("res/ogg/"..filename,isloop)
    end
end

function utils.stopSound(playSoundBack)
    if playSoundBack then
        audio.stopSound(playSoundBack)
    end
end


local _curr_music = nil
function utils.playMusic(title,isloop,time)
    if CONFIG.palyMusic == true then  return end
    if _curr_music then
        audio.resumeMusic()
        return
    end
    local filename = CONFIG.soundList[title]
    if filename == nil then return end
    if device.platform ~= "android" then
        filename = "res/mp3/"..filename..".mp3";
    else
        filename = "res/ogg/"..filename..".ogg";
    end
    audio.setMusicVolume(1);
    audio.playMusic(filename,isloop)
    _curr_music = title
end

function utils.stopMusic()
    audio.pauseMusic()
end

function utils.shuffle(t)
  local n = #t
  while n >= 2 do
    -- n is now the last pertinent index
    local k = math.random(n) -- 1 <= k <= n
    -- Quick swap
    t[n], t[k] = t[k], t[n]
    n = n - 1
  end
  return t
end

-- {
-- "action"      = "clicked"
-- "buttonIndex" = 2
-- }
function utils.dialog(title, message, buttonLabels, listener, params)
    local dialog = require("app.common.dialog").new(title, message, buttonLabels, listener, params)
    return dialog
end

-- cb里返回的为正常业务数据,如cb的code > 0 则表示业务错误, 网络错误内部消化
-- silent 控制是否接管处理网络错误true则抛到业务层处理
-- retryTimes 控制网络错误后的重试次数
local MaxRetryTimes,RetryTimes = 3, 3
function utils.http(url,params,cb,method,silent,retryTimes)
    url = url or CONFIG.API_URL
    method = method or "GET"
    if type(params) == "function" then -- 无参数情况下
        params,cb = cb,params
    end
    if type(cb) ~= "function" then
        cb = function()end;
    end
    params = checktable(params)
    if retryTimes then
        RetryTimes = retryTimes
    end
    local function listener(event)
        local request = event.request
        if event.name == "completed" then
            -- CONFIG.API_URL =  CONFIG.ORIGIN_API_URL
             --网络相关错误
            if (request:getResponseStatusCode() ~= 200 and request:getResponseStatusCode() ~= 304)  
                or checknumber(request:getErrorCode()) ~= 0 then 
                Analytics.event("HTTP错误", "错误码"..request:getErrorCode())
                print(string.format("网络错误:api:%s,http_code:%d,error_code:%d,msg:%s",
                params.method, request:getResponseStatusCode(),request:getErrorCode(),request:getErrorMessage()))
                RetryTimes = RetryTimes - 1
                -- if RetryTimes > 0 then
                --     -- 启用备用地址直接IP访问
                --     if RetryTimes == 1 and CONFIG.useBackupApi and table.indexof(checktable(CONFIG.codeUseBackupApi), request:getErrorCode()) then
                --         local backup_ = utils.getUserSetting("BACKUP_API_URL", CONFIG.BACKUP_API_URL)
                --         if backup_ then
                --             CONFIG.API_URL = backup_
                --         end
                --     end
                --     -- socket.sleep(0.1)
                --     utils.http(params,cb,method,silent)
                -- else
                    Analytics.event("HTTP错误", "重试失败".. request:getErrorCode())
                    if silent then 
                        RetryTimes = MaxRetryTimes; 
                        cb({code= checknumber(request:getErrorCode()), msg=request:getErrorMessage()})
                    else
                        utils.dialog("网络错误","请您检查网络或稍后重试",{"取消","重试"},function(e)
                            RetryTimes = MaxRetryTimes
                            if e.buttonIndex == 2 then
                                utils.http(params,cb,method, silent)
                            else
                                cb({code= checknumber(request:getErrorCode()), msg=request:getErrorMessage()})
                            end
                        end,{"white","green"}, {block = true})
                    end
                -- end
                return
            end
            RetryTimes = MaxRetryTimes
            -- Analytics.endEvent("API调用结束", params.method)

            local data = checktable(json.decode(request:getResponseString()))
            -- 业务逻辑相关错误
            if DEBUG > 0 then
                dump("method ===========" .. method)
                dump(request:getResponseString())
                dump("code ===========" .. request:getResponseStatusCode())
            end
            if data.error then
                if (data.error == "SESSION_ERROR"  or data.error == "SESSION_ERROR!") then
                    --TODO session过期

                    return
                end
            end
            cb(data,request:getResponseStatusCode())
        elseif event.name == "progress"  then
            if params.progress then
                dump(params.progress)
                cb(event)
            end
        else 
            cb({code= checknumber(request:getErrorCode()), msg=request:getErrorMessage()})
        end
    end
    
    if DEBUG > 0 then
        local json_params = utils.http_build_query(params)
        print("api调用 --- > " ..url.. "?"..json_params)
    end
    local req
    if method and string.upper(method) == "POST" then
        req = network.createHTTPRequest(listener,url,"POST");
        for k,v in pairs(params) do
                req:addPOSTValue(k, v)
            end
    else
        local json_params = utils.http_build_query(params)
        url = url .. "?"..json_params
        req = network.createHTTPRequest(listener,url,"GET");
    end
    req:setAcceptEncoding(2)
    req:start()
    -- Analytics.beginEvent("API调用", api)
end

function utils.http_build_query(params)
    local query = ""
    for k, v in pairs(params) do
        query = query..string.format("%s=%s&", k, string.urlencode(v))
    end
    return string.sub(query, 1, string.len(query) - 1)
end

local coin_list = CONFIG.coinList
function utils.genChipGroup(chip_val,max,maxgroup)
    max = max or 120
    maxgroup = maxgroup or 5
    local _maxgroup = maxgroup
    local group_max = 20
    local result = {};
    local i = #coin_list
    repeat
        local v = coin_list[i]
        if chip_val>=v then
            local n = math.floor(chip_val/v)
            chip_val = chip_val - v * n
            -- n = n>group_max and group_max or n
            table.insert(result,{val=v,num=n})
            max = max - n
            _maxgroup = _maxgroup - 1
        end
        i = i-1
    until ( i <= 0 or chip_val <= 0 or max == 0 or _maxgroup == 0 );

    local new_result = {}
    for k,v in ipairs(result) do
        if #new_result == maxgroup then break end
        local i_ = 1
        repeat
            i_ = i_ + 1
            if i_ > 1000 then
                break
            end
            if v.num > group_max then
                table.insert(new_result,{val=v.val,num = group_max})
                v.num = v.num - group_max
            else
                table.insert(new_result,{val=v.val,num = v.num})
                v.num = 0
            end
        until ( v.num <= 0 or #new_result == maxgroup )
    end
    return new_result
end

function utils.getChildUnderPoint(layer,pos,children)
    local children = children or layer:getChildren()
    for i,obj in pairs(children) do
        local touched = obj:getEventRect():containsPoint(pos)
        if touched then
            return obj
        end
    end
end


function utils.expTolevel(exp)
    local level_exps = CONFIG.levelExps
    for i,v in ipairs(level_exps) do
        if exp == 0 then return 1 end
        if (exp < v) then
            return i - 1
        end
    end
end

-- function utils.round(val, decimal)
--   if (decimal) then
--     return math.floor( (val * 10^decimal) + 0.5) / (10^decimal)
--   else
--     return math.floor(val+0.5)
--   end
-- end

function utils.isnan(x)
    return x ~= x
end

--中文按一个字算
function utils.substr(s,len)
    local str_len = string.len(s)
    if len > str_len then len = str_len end
    local cut_s,i = "",1
    local cut_len = 0
    while len>0  do
        local byte = string.byte(s,i)
        if not byte then break end
        if byte >= 240 then --这是苹果的表情
            cut_s = cut_s .. string.sub(s,i,i+3)
            i=i+4
        elseif byte > 127 then
            cut_s = cut_s .. string.sub(s,i,i+2)
            i=i+3
        else
            cut_s = cut_s .. string.char(byte)
            i = i+1
        end
        len = len -1
        cut_len = cut_len + 1
    end
    return cut_s,cut_len
end

function utils.stringlen(str)
    string.gsub(str,"([%w_]+",function(s)

    end)
end


function utils.suffixStr(s,len,suff)
    local s,s_len = utils.substr(s, string.len(s))
    if s_len > len then
        s = utils.substr(s,len-1) .. "…"
    end
    return s
end

function utils.lenMaxToSuffixStr(txt,max)
    local s_len = string.lenbyte(txt)
    if s_len>=2*max-3 and #txt>s_len then
        txt = utils.suffixStr(txt,max)
    elseif s_len>=2*max-2 then
        txt = utils.suffixStr(txt,2*max-3)
    end
    return txt
end


function utils.isURL(url)
    url = _s(url)
    return (string.find(url, "http://") or string.find(url, "http://"))
end

--添加全局遮罩层
function utils.mask(opacity, duration, spinner,text)
    local masklayer = CCLayerColor:create(ccc4(0,0,0,0))
    -- masklayer:setPosition(display.cx*-1,display.cy * -1)

    function masklayer:show()
        local parent = self:getParent()
        if not parent then return end
        local pos = parent:convertToWorldSpace(ccp(0, 0))
        if pos.x ~= 0 or pos.y ~= 0 then
            self:setPosition(-pos.x,-pos.y)
        end
        self:setOpacity(0)
        transition.fadeTo(self,{
            time = duration or 0.2,
            opacity = opacity or 120
        })
    end
    function masklayer:hide()
        transition.stopTarget(self)
        transition.fadeTo(self,{
            time = duration or 0.2,
            opacity = 0
        })
    end

    return masklayer
end

local sig_key = '{}d(]Z6+fjfj7MgJ11pk{V;:jfps&"R#'

function utils.genSig(params)
    params._sig = nil
    local tmp = {}
    for k,v in pairs(params) do
        table.insert(tmp, k.."="..v)
    end
    table.sort(tmp)
    local s = table.concat(tmp,"&") .. sig_key;
    local sig = crypto.md5(s)
    -- local sig = crypto.md5(table.concat(tmp,"&") .. sig_key)
    -- sig = string.sub(sig,1,7)
    return sig
end

local _setting_file , _setting_cache = device.writablePath .. "user_setting",nil
local _sign_key = "zengcheng"

local function _getAllSetting(  )
    -- _setting_cache = _setting_cache or totable(json.decode(io.readfile(_setting_file)))
    if not _setting_cache  then
        local str = io.readfile(_setting_file) or ""
        if string.byte(str) ~= 123 then
            str = crypto.decryptAES256(str,_sign_key)
        end
       _setting_cache =  checktable(json.decode(str))
    end
    return _setting_cache
end

function utils.getUserSetting( key,default_val )
    local setting = _getAllSetting()
    if setting[key] ~= nil then
        return setting[key]
    elseif default_val then
        return default_val
    end
    return nil
end

function utils.setUserSetting( key,val )
    local setting = _getAllSetting()
    setting[key] = val
    local str = json.encode(setting)
    -- if DEBUG == 1 then
       str = crypto.encryptAES256(str,_sign_key)
    -- end
    return io.writefile(_setting_file,str)
end


function utils.debugNode( node )
    local bound = node:getBoundingBox()
    local ap = node:getAnchorPoint()
    print(bound.origin.x,bound.origin.y,bound._size.width,bound._size.height,"AnchorPoint:",ap.x,ap.y);
end

-- 暂时不知道要放哪里的方法....
-- 生成圆形头像的方法
function utils.makeAvatar(udata, size, dia, callback, mask1)
    udata           = checktable(udata)
    udata.upic      = udata.upic or ""
    size            = size or cc.size(156, 132)
    dia             = dia or size.width

    local head  = display.newNode()
    head._size  = size
    head:setContentSize(size)
    head:align(display.CENTER)

    -- local border = display.newSprite("#common/head-border.png", size.width/2, size.height/2)
    -- head:addChild(border,10);
    local pic
    if udata.upic == "img/1px.png" then
        pic = display.newSprite(udata.upic)
    else
        local def_pic = udata.usex == 0 and "img/f.png" or "img/m.png"
        pic = display.newSprite(def_pic)
    end
    local maskPic = "img/head-mask.png"
    if mask1 == 1 then
        maskPic = "img/head-mask1.png"
    elseif mask1 == 2 then
        maskPic = "img/head-mask-circle.png"
    end
    local mask    = display.newSprite(maskPic);
    local avatar  = cc.ClippingNode:create(mask)
    avatar:setAlphaThreshold(0.01)
    avatar:setPosition(size.width/2, size.height/2)
    avatar:addChild(pic)
    head:addChild(avatar)
    head.pic = pic
    avatar.pic = pic
    head.avatar = avatar
    head.border = border
    -- pic:setScale(dia/size.width)
    mask:setScale(dia/mask:getContentSize().width)
    if def_pic ~= udata.upic then
        utils:loadRemote(pic,udata.upic, callback)
    end
    return  head, pic
end

function utils:loadRemote(sprite,url, callback)
    if not CONFIG.uploadPic then
        return
    end
    if tolua.isnull(sprite) or tolua.type(sprite) ~= "cc.Sprite" then
        print("error params@CCSprite.loadRemote")
        return
    end
    local shareCache = cc.Director:getInstance():getTextureCache()
    if not string.find(url,"http://") and not string.find(url,"https://") then
        if io.exists(url) then
            local texture = shareCache:addImage(url)
            sprite:setTexture(texture)
        end
        if type(callback) == "function" then
            callback(false,nil,sprite,false)
        end
        return sprite
    end
    local _key = crypto.md5(url)
    if _key == sprite.__key then return end
    sprite.__key = _key
    local texture = shareCache:getTextureForKey(_key)

    if texture  and not tolua.isnull(texture)  and tolua.type(texture) == "CCTexture2D" then
        if type(callback) == "function" then
            callback(true, texture, sprite, true)
        else
            sprite:setTexture(texture)
            transition.fadeIn(sprite,{time = .1})
        end
        return sprite
    end

    callback = callback or function(succ,texture,sprite,isCache)
        if not succ then return end
        -- 这两句判断可以去掉,暂时保留
        if tolua.type(texture) ~= "CCTexture2D" then return end
        if not sprite or tolua.isnull(sprite)  or tolua.type(sprite) ~= "CCSprite"  then return end
        sprite:setTexture(texture)
        transition.fadeIn(sprite,{time = .2})
    end
    utils.loadImage(url,function(succ, ccimage, isCache)
        if succ then
            local texture
            if tolua.type(ccimage) == "CCImage" then
                texture = shareCache:addUIImage(ccimage,_key)
                ccimage = nil
            elseif type(ccimage) == "string"  and ccimage ~= "" then
                texture = shareCache:addImage(ccimage)
            end
            if tolua.type(texture) == "CCTexture2D" and tolua.type(sprite) == "CCSprite"  then
                return callback(true, texture, sprite, false)
            end
        end
        callback(false,nil,sprite,false)
    end)
    return sprite
end

function utils.loadImage(url,cb)
        -- 强制刷新
        -- local flush = false
        -- if string.find(url,"#flush") then
        --     flush = true
        --     url = string.gsub(url,"#flush")
        -- end
        -- if math.round(1,100) > 95 then
        --     flush = true
        -- end
        local key = crypto.md5(url)
        local save_path = device.writablePath.."/networkcache/" .. key
        -- if not flush and io.exists(save_path) and io.filesize(save_path) > 100 then
        if io.exists(save_path) and io.filesize(save_path) > 100 then
            return cb(true, save_path, true)
        end
        local req = network.createHTTPRequest(function(event)
            local ok = (event.name == "completed")
            local request = event.request
            local errCode = request:getErrorCode()
            local statusCode = 0
            if ok then
                statusCode = request:getResponseStatusCode()
            end
            if ok and errCode == 0 and statusCode == 200 then
                -- request:saveResponseData(save_path)
                print(string.format("load %s success! >>> statusCode:%d,errorCode:%d",url,statusCode,errCode))
                return cb(true, save_path, false)
            elseif event.name == "progress" then
                
            else
                print(string.format("load %s fail! >>> statusCode:%d,errorCode:%d",url,statusCode,errCode))
                return cb(false, save_path, false) 
            end
        end,url,"GET")
        req:start()
    end

function utils.toAppstore( ... )
    local url = "itms-apps://itunes.apple.com/app/id%d"
    url = string.format(url, CONFIG.itunesId)
    device.openURL(url)
end

function utils.toAppstoreAndItunes( itunesId )
    local url = "itms-apps://itunes.apple.com/app/id%d"
    url = string.format(url, itunesId)
    device.openURL(url)
end

function utils.toAppstoreGrade( ... )
    local sysVer = device.getSystemVersion()
    local url
    if sysVer < 7 then
        url = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%d"
    else
        url = "itms-apps://itunes.apple.com/app/id%d"
    end
    url = string.format(url, CONFIG.itunesId)
    device.openURL(url)
end

function string.lenbyte(str)
    return #(string.gsub(str,'[\128-\255][\128-\255]',' '))
end

function string.lastindexof(haystack, needle)
    local i, j
    local k = 0
    repeat
        i = j
        j, k = string.find(haystack, needle, k + 1, true)
    until j == nil

    return i
end

function utils.callStaticMethod( cls, method, args, args_order, sig)
    if device.platform == "ios"  then
        return luaoc.callStaticMethod(cls, method, args)
    elseif device.platform == "android" then
        luaj = require("framework.luaj")
        local base_package = "com/zzz/zzztexas/"
        cls = base_package..cls
        if sig then
            if not string.find(sig,"Ljava") then
                sig = string.gsub(sig,"S","Ljava/lang/String;")
            end
        end
        if args_order then
            new_args = {}
            for _ ,k in ipairs(args_order) do
                table.insert(new_args,args[k])
            end
            args = new_args
        elseif args then
            args = table.values(args)
        end
        return luaj.callStaticMethod(cls, method, args, sig)
    else
        print("%s:%s not support this platform: %s",cls, method, device.platform)
    end
end

-- 获取app的版本
function device.getAppVersion()
    local ok, r = luaoc.callStaticMethod("Helper","getAppVersion")
    return r
end

-- CONFIG.appversion = device.getAppVersion()

function device.getSystemVersion()
    local ok, r = luaoc.callStaticMethod("Helper","getSystemVersion")
    return tonumber(r)
end

function device.getVersionCode()
    local ok, r = luaoc.callStaticMethod("Helper","getVersionCode")
    return tonumber(r)
end

-- CONFIG.versioncode = device.getVersionCode()

function device.getDeviceID()
    local ok, r 
    if device.platform == "ios" then
        ok, r = luaoc.callStaticMethod("Helper","getIDFA")
    else
        ok, r = luaj.callStaticMethod("Helper","getDeviceID")
    end
    return r
end
device.deviceID = "test_deviceid_".. math.random(2,13)
-- device.deviceId = device.getDeviceID()

function device.vibrate(t)
    if device.platform == "ios" then
        cc.Native:vibrate()
    else
        t = t or 200
        utils.callStaticMethod("Helper","vibrate",{t =t})
    end
end

function exitApp()
    if device.platform == "ios" then
        os.exit()
    else
        utils.callStaticMethod("Helper","exitApp",{_b(isDirectly)},nil,"(Z)V")
    end
end

return utils