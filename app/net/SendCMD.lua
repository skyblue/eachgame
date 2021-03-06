SendCMD = class("SendCMD")


function SendCMD:ctor(socket)
	self.socket = socket
end 

function SendCMD:getUserInfo(uid)
    local packet = ByteArray.new()
    packet:Begin(CMD.REQ_USER_INFO)
    packet:writeInt(uid)
    packet:End()
    self.socket:send(packet)
end

function SendCMD:changePic(pic)
    local packet = ByteArray.new()
    packet:Begin(CMD.REQ_CHANGE_PIC)
    packet:writeString(pic)
    packet:End()
    self.socket:send(packet)
end

function SendCMD:changeSex(sex)
    local packet = ByteArray.new()
    packet:Begin(CMD.REQ_CHANGE_SEX)
    packet:writeChar(sex)
    packet:End()
    self.socket:send(packet)
end

function SendCMD:changeUname(uname)
    local packet = ByteArray.new()
    packet:Begin(CMD.REQ_CHANGE_UNAME)
    packet:writeString(uname)
    packet:End()
    self.socket:send(packet)
end

function SendCMD:getSceneList(uid)
    local packet = ByteArray.new()
    packet:Begin(CMD.REQ_SCENES_LIST)
    packet:End()
    self.socket:send(packet)
end

function SendCMD:chipinAction(chipin,_type)
    local packet = ByteArray.new()
    packet:Begin(ROOM_CMD.REQ_CHIP_ACTION)
    packet:writeInt(chipin)
    packet:writeChar(_type)
    packet:End()
    self.socket:send(packet)
end


function SendCMD:test()
    local packet = ByteArray.new()
    packet:Begin(CMD.REQ_LOGIN)
    packet:End()
    self.socket:send(packet)
end

function SendCMD:login(account,pwd,_type)
    pwd = pwd or ""
	local packet = ByteArray.new()
    packet:Begin(CMD.REQ_LOGIN)
    packet:writeString(account)
    packet:writeString(pwd)
    packet:writeChar(_type)
    packet:writeString(device.deviceID)
    packet:writeChar(device.platform == "ios" and 1 or 2)
    packet:writeString(CONFIG.appversion)
    packet:writeInt(CONFIG.versioncode)
    packet:writeInt(CONFIG.appid)
    packet:End()
    self.socket:send(packet)
end

function SendCMD:register(account,pwd,sex,uname,sign)
    pwd = pwd or ""
    local packet = ByteArray.new()
    packet:Begin(CMD.REQ_REG)
    packet:writeString(account)
    packet:writeString(pwd)
    packet:writeChar(sex)
    packet:writeString(uname)
    packet:writeString(device.deviceID)
    packet:writeChar(device.platform == "ios" and 1 or 2)
    packet:writeString(CONFIG.appversion)
    packet:writeInt(CONFIG.versioncode)
    packet:writeInt(CONFIG.appid)
    packet:writeInt(sign)
    packet:End()
    self.socket:send(packet)
end

function SendCMD:changePwd(oldpwd,pwd,sign)
    local packet = ByteArray.new()
    packet:Begin(CMD.REQ_REG)
    packet:writeString(oldpwd)
    packet:writeString(pwd)
    packet:writeInt(sign)
    packet:End()
    self.socket:send(packet)
end

function SendCMD:changeToLoginServer()
	self.socket:close()
	--连上登陆服务器
    _.ParseSocket.contentType = 1
    SocketEvent:init(CONFIG.server ,CONFIG.port ,false) 
end

function SendCMD:changeToGameServer()
    self.socket:close()
   -- SocketEvent:init(CONFIG.gameServer ,CONFIG.gamePort ,true) 
    --连上游戏服务器
   SocketEvent:init(CONFIG.gameServer ,CONFIG.gamePort ,false) 
end

function SendCMD:loginToGameServer()
	local packet = ByteArray.new()
    packet:Begin(CMD.REQ_GAME_SERVER)
    packet:writeInt(USER.sessionkey)
    packet:End()
    self.socket:send(packet)
end

function SendCMD:userStand(_type)
	local packet = ByteArray.new()
    packet:Begin(ROOM_CMD.REQ_USER_STAND)
    packet:writeInt(USER.uid)
    packet:writeChar(_type)
    packet:End()
    self.socket:send(packet)
end

function SendCMD:outTable(_type)
    local packet = ByteArray.new()
    packet:Begin(ROOM_CMD.REQ_OUT_TABLE)
    packet:writeInt(USER.uid)
    packet:writeChar(_type)
    packet:End()
    self.socket:send(packet)
end

function SendCMD:userSit(seatid,buying,autobuying)
    local packet = ByteArray.new()
    packet:Begin(ROOM_CMD.REQ_USER_SIT)
    packet:writeInt(USER.uid)
    packet:writeChar(seatid)
    packet:writeInt(buying)
    packet:writeChar(autobuying)
    packet:End()
    self.socket:send(packet)
end

function SendCMD:toGame(tid,_type)
    tid =  tid or 0
    _type = _type or 0
	local packet = ByteArray.new()
    packet:Begin(CMD.REQ_IN_TABLE)
    packet:writeInt(tid)
    packet:writeInt(_type)
    packet:End()
    self.socket:send(packet)
end

function SendCMD:getShoplist()
    local packet = ByteArray.new()
    packet:Begin(CMD.REQ_SHOPLIST)
    packet:End()
    self.socket:send(packet)
end 

function SendCMD:buy(data)
    local packet = ByteArray.new()
    packet:Begin(CMD.REQ_BUY)
    packet:writeString(data.productId)
    packet:writeString(data.transactionIdentifier)
    packet:writeChar(data.sandbox)
    packet:writeInt(data.to_uid)
    packet:writeString(data.receipt_data)
    packet:End()
    self.socket:send(packet)
end

function SendCMD:chat(msg,_type)
    local packet = ByteArray.new()
    packet:Begin(CMD.CHAT)
    packet:writeString(msg)
    packet:writeChar(_type)
    packet:End()
    self.socket:send(packet)
end

function SendCMD:heart()
    local packet = ByteArray.new()
    packet:Begin(CMD.HEART)
    packet:End()
    self.socket:send(packet)
end

function SendCMD:getMissionlist()
    local packet = ByteArray.new()
    packet:Begin(CMD.REQ_MISSIONLIST)
    packet:End()
    self.socket:send(packet)
end 

function SendCMD:completeMission(id)
    local packet = ByteArray.new()
    packet:Begin(CMD.REQ_MISSION_COM)
    packet:writeInt(id)
    packet:End()
    self.socket:send(packet)
end 

function SendCMD:animation(seatid,pid)
    local packet = ByteArray.new()
    packet:Begin(ROOM_CMD.REQ_ANIMATION)
    packet:writeInt(seatid)
    packet:writeInt(pid)
    packet:End()
    self.socket:send(packet)
end 

function SendCMD:feed(msg)
    local packet = ByteArray.new()
    packet:Begin(CMD.FEED)
    packet:writeString(msg)
    packet:End()
    self.socket:send(packet)
end 

return SendCMD