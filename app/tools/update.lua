------------------------------------------------------------------------------
--Load origin framework
------------------------------------------------------------------------------
-- CCLuaLoadChunksFromZip("res/framework.zip")
------------------------------------------------------------------------------
--If you would update the modoules which have been require here,
--you can reset them, and require them again in modoule "appentry"
------------------------------------------------------------------------------
-- require("app.config")
-- require("framework.init")
-- require("framework.functions")
------------------------------------------------------------------------------
--define UpdateScene
------------------------------------------------------------------------------
local UpdateScene = class("UpdateScene", function()
    return display.newScene("UpdateScene")
end)
local server 
local param = "?dev="..device.platform
local list_filename = "versions"
local downList = {}
-- local configLang = {}
local ok
local code
if device.platform == "ios" then 
    if luaoc then
        ok,code= luaoc.callStaticMethod("Helper","getAppVersionCode")
    end
else
    if luaj then
        ok,code= luaj.callStaticMethod("Helper","getAppVersionCode")
    end
end

-- function string.lastIndexOf(haystack, needle)
--     local i, j
--     local k = 0
--     repeat
--         i = j
--         j, k = string.find(haystack, needle, k + 1, true)
--     until j == nil

--     return i
-- end

local function hex(s)
 s=string.gsub(s,"(.)",function (x) return string.format("%02X",string.byte(x)) end)
 return s
end

local function readFile(path)
    local file = io.open(path, "rb")
    if file then
        local content = file:read("*all")
        io.close(file)
        return content
    end
    return nil
end

local function removeFile(path)
    -- CCLuaLog("removeFile: "..path)
    io.writefile(path, "")
    if device.platform == "windows" then
        --os.execute("del " .. string.gsub(path, '/', '\\'))
    else
        os.execute("rm " .. path)
    end
end

local function checkFile(fileName, cryptoCode)
    -- print("checkFile:", fileName)
    -- print("cryptoCode:", cryptoCode)
    if not io.exists(fileName) then
        return false
    end

    local data=readFile(fileName)
    if data==nil then
        return false
    end

    if cryptoCode==nil then
        return true
    end

    local ms = crypto.md5(hex(data))
    -- print("file cryptoCode:", ms)
    if ms==cryptoCode then
        return true
    end

    return false
end

local function checkDirOK( path )
        require "lfs"
        local oldpath = lfs.currentdir()
         if lfs.chdir(path) then
            lfs.chdir(oldpath)
            return true
         end
         if lfs.mkdir(path) then
            return true
         end
end

function UpdateScene:ctor()
    local bg = display.newSprite("res/img/loading-bg.png",display.cx,display.cy)
        :addTo(self)
    self.path = device.writablePath.."upd/"
    local yy = display.cy * 0.15
    cc.ui.UILabel.new({text = "跳过", size = 20})
        :align(display.CENTER, display.width * 0.9, yy)
        :addTo(self)
    local loadingText = "loading..."
    if CONFIG.lang == "cn" then
        loadingText = "加载中..."
    end
    cc.ui.UILabel.new({text = loadingText, size = 22, })
        :align(display.CENTER, display.cx, yy -30)
        :addTo(self)
end

function UpdateScene:updateFiles()
    local data = readFile(self.newListFile)
    io.writefile(self.curListFile, data)
    self.fileList = self:dofile(self.curListFile)
    if self.fileList==nil then
        self:endProcess()
        return
    end
    removeFile(self.newListFile)

    for i,v in ipairs(downList) do
        -- print(i,v)
        local data=readFile(v)
        local fn = string.sub(v, 1, -5)
        -- print("fn: ", fn)
        io.writefile(fn, data)
        removeFile(v)
    end
    self:endProcess()
end

function UpdateScene:reqNextFile()
    self.numFileCheck = self.numFileCheck+1
    self.curStageFile = self.fileListNew.stage[self.numFileCheck]
    if self.curStageFile and self.curStageFile.name then
        local fn = self.path..self.curStageFile.name
        if checkFile(fn, self.curStageFile.code) then
            self:reqNextFile()
            return
        end
        fn = fn..".upd"
        if checkFile(fn, self.curStageFile.code) then
            table.insert(downList, fn)
            self:reqNextFile()
            return
        end
        server = self.fileListNew.url
        self:requestFromServer(self.curStageFile.name)
        return
    end

    self:updateFiles()
end

function UpdateScene:onEnterFrame(dt)
    if self.dataRecv then
            local down_num = 1
            if #downList > 1 then
                down_num = #downList
            end
            local fn = self.path..self.curStageFile.name..".upd"
            local dir = string.lastIndexOf(fn, "/")
            dir = string.sub(fn,1,dir)
            if #dir > 1 and not lfs.chdir(dir) then
                lfs.mkdir(dir)
            end
            io.writefile(fn, self.dataRecv)
            self.dataRecv = nil
            if checkFile(fn, self.curStageFile.code) then
                table.insert(downList, fn)
                self:reqNextFile()
            else
                self:endProcess()
            end
        return
    end

end

function UpdateScene:dofile(file )
    local val = readFile(file)
    return checktable(json.decode(val))
end

function UpdateScene:start()
    -- do return end
    -- require("app.app")
    -- display.replaceScene(MainScene.new())
    -- self:removeSelf()
    function __G__TRACKBACK__(errorMessage)
        print("----------------------------------------")
        print("LUA ERROR: "..tostring(errorMessage).."\n")
        print(debug.traceback("", 2))
        print("----------------------------------------")
    end
    -- xpcall(App.startup,__G__TRACKBACK__)
    require("app.MyApp").new():run()
end

function UpdateScene:onExit()
    cc.Director:getInstance():getActionManager():removeAllActionsFromTarget(self.bg)
end

function UpdateScene:endProcess()
    -- CCLuaLog("----------------------------------------UpdateScene:endProcess")
    if self.fileList and self.fileList.stage then
        local checkOK = true
        for i,v in ipairs(self.fileList) do
            if not checkFile(self.path..v.name, v.code) then
                -- CCLuaLog("----------------------------------------Check Files Error")
                checkOK = false
                break
            end
        end
        if checkOK then
            for i,v in ipairs(self.fileList.stage) do
                if v.act=="load" then
                    CCLuaLoadChunksFromZIP(self.path..v.name)
                    require("app.config")
                end
                -- configLang[v.name] = self.path..v.name
            end
            if self.fileList.remove then
                for i,v in ipairs(self.fileList.remove) do
                    if v.ver == self.ver then
                        removeFile(self.path..v.name)
                    end
                end
            end
        else
            removeFile(self.curListFile)
        end
      end
    self:start()
end

function UpdateScene:requestFromServer(filename, waittime)
    local url = server..filename..param
    self.requestCount = self.requestCount + 1
    local index = self.requestCount
    local request = network.createHTTPRequest(function(event)
        self:onResponse(event)
    end, url, "GET")
    if request then
        request:setTimeout(waittime or 30)
        request:start()
    else
        self:endProcess()
    end
end

function UpdateScene:onResponse(event)
    local request = event.request
    printf("REQUEST %d - event.name = %s", index, event.name)
    if event.name == "completed" then
        -- printf("REQUEST %d - getResponseStatusCode() = %d", index, request:getResponseStatusCode())
        --printf("REQUEST %d - getResponseHeadersString() =\n%s", index, request:getResponseHeadersString())

        if request:getResponseStatusCode() ~= 200 then
            self:endProcess()
        else
            -- printf("REQUEST %d - getResponseDataLength() = %d", index, request:getResponseDataLength())
            -- if dumpResponse then
            --     printf("REQUEST %d - getResponseString() =\n%s", index, request:getResponseString())
            -- end
            self.dataRecv = request:getResponseDataLua()
        end
     elseif event.name == "progress" then
        printf("REQUEST %d - total:%d, have download:%d", index, event.total, event.dltotal)
        -- local percent = 0
        -- if event.total and 0 ~= event.total then
        --     percent = event.dltotal*100/event.total
        -- end
        -- self.progressLabel:setString(string.format("total:%d,download:%d,percent:%d%%", event.total, event.dltotal, percent))
    else
        -- printf("REQUEST %d - getErrorCode() = %d, getErrorMessage() = %s", index, request:getErrorCode(), request:getErrorMessage())
        self:endProcess()
    end

    -- print("----------------------------------------")
end
function UpdateScene:request(url,callback,params,method,cacheable)
        local function listener( event )
            local ok = (event.name == "completed")
            local request = event.request
            local result = {}
            if ok then
                result.http_code = request:getResponseStatusCode()
                result.error_code = 0
                result.responseString = request:getResponseString()
                callback(result)
            elseif event.name == "progress" then
            else
                result.http_code = 0
                result.error_code = tonumber(request:getErrorCode())
                result.error_message = request:getErrorMessage()
                callback(result)
            end
            
        end
        req = network.createHTTPRequest(listener,url,"GET");
        req:setTimeout(1)
        req:setAcceptEncoding(2)
        req:start()
end
function UpdateScene:onEnter()
    self:start()
    do return end
     -- if 1 then
    if not checkDirOK(self.path) then
        if io.exists(self.path.."game.zip") then
            CCLuaLoadChunksFromZip(self.path.."game.zip")
        end
        self:start()
        return
    end
    --当发新版本的时候要把老的下载的东西给删除的时候打开
    -- if io.exists(self.path.."game.zip") then
    --     removeFile(self.path.."game.zip")
    -- end

    -- display.addSpriteFrames("img/hall.plist","img/hall.png")
    -- local bg = display.newSprite("img/hall-bg.png",display.cx,display.cy)
    --     :addTo(self)

    cc.FileUtils:getInstance():addSearchPath(self.path)
    self.curListFile =  self.path..list_filename
    self.fileList = nil
    if io.exists(self.curListFile) then
        self.fileList = self:dofile(self.curListFile)
    end
    if self.fileList==nil then
        self.fileList = {
            ver = 1,
            stage = {},
            remove = {},
        }
    end
    self.ver = self.fileList.ver
    self.requestCount = 0
    self.newListFile = self.curListFile..".upd"
    self.dataRecv = nil
    self:endProcess()
    do return end
    local this = self
    --去访问自动更新的接口
    local url = CONFIG.API_URL.."/checkUpdate?versioncode=".. code .. "&appid="..CONFIG.appid
    self:request(url,function ( data )
        dump(data)
         if(data.http_code == 200) then
            if data.responseString=="{}" then
                self:endProcess()
                return
            end
            io.writefile(self.newListFile, data.responseString)
            self.fileListNew =  self:dofile(self.newListFile)
            if self.fileListNew == nil then
                self:endProcess()
                return
            end
            if tonumber(self.fileListNew.ver) <= tonumber(self.fileList.ver) then
                self:endProcess()
                return
            end
            io.writefile(self.newListFile, data.responseString)
            if self.fileListNew.cancel then
                self.menu:setVisible(true)
            end
            self:scheduleUpdate(function(dt) self:onEnterFrame(dt) end)
            self.numFileCheck = 0
            self:reqNextFile()
        else
            this:endProcess()
        end
    end)
    -- print("device.platform", device.platform)
    if device.platform ~= "android" then return end
    self:performWithDelay(function()
        -- keypad layer, for android
        self:addNodeEventListener(cc.KEYPAD_EVENT,function(event)
            if event == "back" then exitApp() end
        end)
    end, 0.5)
end

local upd = UpdateScene.new()
display.replaceScene(upd)