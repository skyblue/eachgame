ParseSocket = class("SocketTCP")

SocketEvent = require("app.net.SocketEvent").new()     
SendCMD = require("app.net.SendCMD").new(SocketEvent)     

function ParseSocket:ctor()
	self.contentType = 1
	SocketEvent:init(CONFIG.server ,CONFIG.port ,false) 
	SocketEvent:addEventListener("contented", function(event)

		if self.contentType == 1 then 
			--弹登陆框  ..math.random()
			-- SendCMD:test()
			local siginId = utils.setUserSetting("last_login_siginId",nil)
			if siginId == nil then --没有就游客登陆 1
				SendCMD:login("","",1,device.deviceID,device.platform == "ios" and 1 or 2,"1.0.0",100,1)
			else  -- 0 自己的帐号登陆
            	display.replaceScene(Login.new())
			end
			-- SendCMD:register("test","123456",0,"name","devid_test",device.platform == "ios" and 1 or 2,"1.0.0",100,1)
		else
			--连游戏服务器
			if CONFIG.gameServer and CONFIG.gamePort then
				SendCMD:loginToGameServer()
			else
				--弹登陆框
				-- SendCMD:login()
			end
		end
	end)

	-- SocketEvent:addEventListener("closed", function(event)
	-- 	self.contentType == 1
	-- end)
	SocketEvent:addEventListener("onServerData", function(event)
			local packet = event.data
			packet:setPos(1)
			local cmd = packet:getBeginCmd()
			dump("cmd -----》》》  "..cmd)
			--如果房间还没初始化完成，把房间命令的数据丢掉
			if table.indexof(ROOM_CMD,cmd) and not _.Room.load then
				return
			end
			if self.fun["fun"..cmd] then
				self.fun["fun"..cmd](self,packet)
			else 
				print("no this cmd")
			end
		end)  
	self.fun = {}
	self.fun["fun"..CMD.RSP_LOGIN] = self.loginSuccess
	self.fun["fun"..CMD.RSP_USER_INFO] = self.userInfo
	self.fun["fun"..CMD.RSP_GAME_SERVER] = self.loginToGameSuccess
	self.fun["fun"..CMD.RSP_IN_TABLE] = self.inTable
	self.fun["fun"..CMD.RSP_SCENES_LIST] = self.scenesList
	self.fun["fun"..CMD.RSP_CHANGE_PIC] = self.changePic
	self.fun["fun"..CMD.RSP_CHANGE_UNAME] = self.changeUname
	self.fun["fun"..CMD.RSP_CHANGE_SEX] = self.changeSex
	----------
	self.fun["fun"..ROOM_CMD.NTF_USER_SIT] = self.userSit
	self.fun["fun"..ROOM_CMD.RSP_USER_SIT] = self.userSitFailure
	self.fun["fun"..ROOM_CMD.NTF_BUYING] = self.buying
	self.fun["fun"..ROOM_CMD.RSP_USER_STAND] = self.userStandFailure
	self.fun["fun"..ROOM_CMD.NTF_USER_STAND] = self.userStandNtf
	self.fun["fun"..ROOM_CMD.NTF_GAME_START] = self.gameStart
	self.fun["fun"..ROOM_CMD.NTF_START_ACTION] = self.startChipinAction
	self.fun["fun"..ROOM_CMD.RSP_CHIP_ACTION] = self.chipinActionFailure
	self.fun["fun"..ROOM_CMD.NTF_CHIP_ACTION] = self.chipinAction
	self.fun["fun"..ROOM_CMD.RSP_HAND_CARDS] = self.handCard
	-- self.fun["fun"..ROOM_CMD.RSP_FLOP] = self.    flop
	-- self.fun["fun"..ROOM_CMD.RSP_TURN] = self.turn
	self.fun["fun"..ROOM_CMD.RSP_FLOP] = self.river
	self.fun["fun"..ROOM_CMD.RSP_TURN] = self.river
	self.fun["fun"..ROOM_CMD.RSP_RIVER] = self.river
	self.fun["fun"..ROOM_CMD.RSP_FINAL_ROUND] = self.finalRound
	self.fun["fun"..ROOM_CMD.RSP_FINAL_GAME] = self.finalGame
	self.fun["fun"..ROOM_CMD.RSP_OUT_TABLE] = self.outTable
	self.fun["fun"..ROOM_CMD.NTF_OUT_TABLE] = self.outTableNtf
	self.fun["fun"..ROOM_CMD.NTF_USER_ENTER] = self.userEnter

end

function ParseSocket:userEnter(packet)
	local data = self:readUserBaseInfo(packet)
	data.uchips = packet:readInt()
	data.level = packet:readShort()
	_.Room.model.lookUser[#_.Room.model.lookUser] = data
	-- dump(data)
end

function ParseSocket:changeSex(packet)

end

function ParseSocket:changePic(packet)

end

function ParseSocket:changeUname(packet)

end

function ParseSocket:scenesList(packet) 
	local num = packet:readChar()
	local list,item = {}
	for i=1,num do
		item = {}
		item.id = packet:readInt()
		item.min_b = packet:readInt()
		item.max_b = packet:readInt()
		item.min_buying = packet:readInt()
		item.max_buying = packet:readInt()
		item.name = packet:readString()
		list[i] = item
	end
	CONFIG.selectRoom = list
	SocketEvent:dispatchEvent({name = CMD.RSP_SCENES_LIST .. "back"})
end

function ParseSocket:outTableNtf(packet) 
	local uid = packet:readInt()
	-- if uid == USER.uid then
 --        _.Hall = Hall.new()
	-- 	display.replaceScene(_.Hall)
	-- else
		for i,v in ipairs(_.Room.model.lookUser) do
			if v.uid == uid then
				table.remove(_.Room.model.lookUser, i)
				break;
			end
		end
	-- end
	SocketEvent:dispatchEvent({name = CMD.NTF_OUT_TABLE .. "back",data = uid})
end

function ParseSocket:outTable(packet) 
	local flag = packet:readChar()
	if flag == 0 then
		_.Event:exit()
		_.Hall = Hall.new()
		display.replaceScene(_.Hall)
		for i,v in ipairs(_.Room.model.lookUser) do
			if v.uid == USER.uid then
				table.remove(_.Room.model.lookUser, i)
				break;
			end
		end
		_.Room.exit()
	else
		utils.dialog("", LANG["RSP_OUT_TABLE_"..flag],{"确定"})
	end
end

function ParseSocket:finalGame(packet) 
	local _type = packet:readChar()
	local playerNum = packet:readChar()
	local player
	local players = {}
	for i=1,playerNum do
		player = {}
		player.seatid = packet:readChar()
		player.uid = packet:readInt()

		player.win = packet:readInt()
		player.buying = packet:readInt()
		player.profit = packet:readInt()
		player._type = packet:readChar()
		if player._type > 0 then
			player.hand_cards = {packet:readChar(),packet:readChar()}

			player.hight_cards = {packet:readChar(),packet:readChar(),packet:readChar(),packet:readChar(),packet:readChar()}
		end
		players[i] = player
	end
	SocketEvent:dispatchEvent(ROOM_CMD.RSP_FINAL_GAME .. "back",{data ={users =players,_type = _type}})
end

function ParseSocket:finalRound(packet) 
	local round = packet:readChar()
	local round_pot = packet:readInt()
	local bottom_pots = packet:readInt()
	local pots = self:readCharArrayData(packet) 
		pot = pots or {}
	pots[#pots] = bottom_pots

	SocketEvent:dispatchEvent(ROOM_CMD.RSP_FINAL_ROUND .. "back",{data ={round = round,round_pot =round_pot,bottom_pots=bottom_pots,pots=pots}})
end

function ParseSocket:river(packet) --最后一轮，河牌
	local card = self:readCharArrayData()
	SocketEvent:dispatchEvent(ROOM_CMD.RSP_RIVER .. "back",{data = card})
end

-- function ParseSocket:turn(packet) --第二轮，转牌
-- 	local card = self:readCharArrayData()
-- 	SocketEvent:dispatchEvent(ROOM_CMD.RSP_TURN .. "back",{data = card})
-- end

-- function ParseSocket:flop(packet) --第一轮，翻牌
-- 	local card = self:readCharArrayData()
-- 	SocketEvent:dispatchEvent(ROOM_CMD.RSP_FLOP .. "back",{data = card})
-- end


function ParseSocket:handCard(packet)
	local card = {packet:readChar(),packet:readChar()}
	SocketEvent:dispatchEvent(ROOM_CMD.RSP_HAND_CARDS .. "back",{data = card})
end

function ParseSocket:readChipAction(packet)
	local data = {}
	data.uid = packet:readInt()
	data.seatid = packet:readChar()
	data._type = packet:readChar()
	data.buying = packet:readInt()
	data.chipin = packet:readInt()
	return data
end

function ParseSocket:chipinAction(packet)
	local data = self:readChipAction(packet)
	SocketEvent:dispatchEvent(ROOM_CMD.NTF_CHIP_ACTION .. "back",{data = data})
end

function ParseSocket:chipinActionFailure(packet)
	local flag = packet:readChar()
	if flag == 0 then

	else
		--
	end
end

function ParseSocket:readChipinGameBaseInfo(packet)
	local data = {}
	data.tid = packet:readInt()
	data.seatid = packet:readChar()
	data.chipin = packet:readInt()
	data.buying = packet:readInt()
	return data
end

function ParseSocket:readRoomBaseInfo(packet)
	local tableInfo = {}
	tableInfo.tid = packet:readInt()
	tableInfo.status = packet:readChar()
	tableInfo.dealer = packet:readChar()
	tableInfo.gap_sec = packet:readShort()
	tableInfo.max_player = packet:readShort()
	tableInfo.s_blind = packet:readInt()
	tableInfo.b_blind = packet:readInt()
	tableInfo.min_buying = packet:readInt()
	tableInfo.max_buying = packet:readInt()
	return tableInfo
end


function ParseSocket:gameStart(packet)
	local tableInfo = self:readRoomBaseInfo(packet)

	tableInfo.sSeat = packet:readChar()
	tableInfo.bSeat = packet:readChar()

	local playerNum = packet:readChar()
	local userSeatInfo = {}
	for i=1,playerNum do
		userSeatInfo[i].uid = packet:readInt()
		userSeatInfo[i].seatid = packet:readChar()
		userSeatInfo[i].buying = packet:readInt()
	end
	tableInfo.user = userSeatInfo
	SocketEvent:dispatchEvent(ROOM_CMD.NTF_GAME_START .. "back",{data = tableInfo})
end

function ParseSocket:userStandNtf(packet)
	local uid = packet:readInt()
	local seatid = packet:readChar()
	local tid = packet:readInt()
	local _type = packet:readChar()
	SocketEvent:dispatchEvent({name = ROOM_CMD.NTF_USER_STAND .. "back",data = {uid =uid,seatid =seatid,tid =tid,type=_type}})
end

function ParseSocket:userStandFailure(packet)
	local flag = packet:readChar()
	if flag <=2 then return end
	utils.dialog("", LANG["RSP_USER_STAND_"..flag],{"确定"})
end

function ParseSocket:buying(packet)
		local data = {}
		data.uid = packet:readInt()
		-- USER.gameinfo.uid = packet:readInt()

		data.seatid = packet:readChar()
		data.buying = packet:readInt()
		data.uchips = packet:readInt()
		if uid == USER.uid then
			USER.seatid = data.seatid
			USER.buying = data.buying
			USER.uchips = data.uchips
		else
			
		end
		SocketEvent:dispatchEvent(ROOM_CMD.NTF_BUYING .. "back",{data = data})
end

function ParseSocket:userSitFailure(packet)
	local flag = packet:readChar()
	if flag == 0 then
		
	else
		utils.dialog("", LANG["RSP_USER_SIT_"..flag],{"确定"})
	end
end

function ParseSocket:userSit(packet)
	local data = self:readUserBaseInfo(packet)

	data.uchips = packet:readInt()
	data.seatid = packet:readChar()
	data.buying = packet:readInt()
	if data.uid  == USER.uid  then
		USER.sex = data.sex
		USER.uname = data.uname
		USER.upic = data.upic
		USER.uchips = data.uchips
		USER.seatid = data.seatid
		USER.buying = data.buying
	else
		
	end
	SocketEvent:dispatchEvent({name = ROOM_CMD.NTF_USER_SIT .. "back",data = data})
	
end

function ParseSocket:readCharArrayData(packet)
	local arr = {}
	local arrLen = packet:readChar()
	for i=1,arrLen do
		table.insert(arr, packet:readChar())
	end
	return arr
end

function ParseSocket:inTable(packet)
	local flag = packet:readChar()
	if flag == 0 then
		local tableInfo = self:readRoomBaseInfo(packet)
		tableInfo.pots = packet:readInt()
		tableInfo.edge_pots = self:readCharArrayData(packet)
		tableInfo.public_cards = self:readCharArrayData(packet)

		local playerNum = packet:readChar()
		local has_focus = packet:readChar()
		tableInfo.user={}
		for i=1,playerNum do
			tableInfo.user[i] = self:readUserBaseInfo(packet)
			------
			tableInfo.user[i].uchips = packet:readInt()
			-------
			tableInfo.user[i].seatid = packet:readChar()
			tableInfo.user[i].chipin = packet:readInt()
			tableInfo.user[i].buying = packet:readInt()
			tableInfo.user[i].status = packet:readChar()
		end
		if has_focus == 1 then
			tableInfo.currPlayer = self:readChipInfo(packet)
		end

		SocketEvent:dispatchEvent({name = CMD.RSP_IN_TABLE .. "back",data =tableInfo})
	else
		utils.dialog("", LANG["RSP_IN_TABLE_"..flag],{"确定"})
	end
end

function ParseSocket:readChipInfo(packet)
	local data = {}
	data.uid = packet:readInt()
	data.seatid = packet:readChar()
	data.need_call = packet:readInt()
	data.min_raise = packet:readInt()
	data.max_raise = packet:readInt()
	data.chipin = packet:readInt()
	data.gap_sec = packet:readInt() - CONFIG.clinet_diftime - os.time()
	return data
end

function ParseSocket:startChipinAction(packet)
	local data = self:readChipInfo(packet)
	SocketEvent:dispatchEvent({name = CMD.NTF_START_ACTION .. "back",data =data})
end

function ParseSocket:loginSuccess(packet)
	local flag = packet:readChar()
	if flag == 0 or flag == 1 then
		CONFIG.siginId = packet:readChar()
		utils.setUserSetting("last_login_siginId",CONFIG.siginId)
		CONFIG.blockedSecs = packet:readInt()
		USER.sessionkey = packet:readInt()

		CONFIG.gameSever = packet:readString()
		CONFIG.gamePort = packet:readShort()
		CONFIG.httpServer = packet:readString()
		self.contentType = 2
		SendCMD:changeToGameServer()
	else
		--错误提示
		utils.dialog("", LANG["RSP_LOGIN_"..flag],{"确定"})
	end
end


function ParseSocket:userInfo(packet)
	local flag = packet:readChar()
	if flag == 0 then
		local data = self:readUserInfo(packet)
		data.tid = packet:readInt()
		data.online = packet:readChar() -- 1 online -- 0 offline
		if not _.UserInfo then
			_.UserInfo = UserInfo.new()
		end
		_.UserInfo:show(data)
	else

	end
end

function ParseSocket:readUserBaseInfo(packet)
	local data = {}
	data.uid = packet:readInt()
	data.sex = packet:readChar()
	data.uname = packet:readString()
	data.upic = packet:readString()
	return data
end

function ParseSocket:readUserInfo(packet)
	-------用户基础信息
	local data = self:readUserBaseInfo(packet)
	data.reg_time = packet:readInt()
	data.login_time = packet:readInt()
	data.offline_time = packet:readInt()
	data.city = packet:readString()
	--游戏信息
	data.uchips = packet:readInt()
	data.level = packet:readShort()
	data.score = packet:readInt()
	data.exp = packet:readInt()
	data.vip_level = packet:readShort()
	data.vip_time = packet:readInt()
	--
	data.play_count = packet:readInt()
	data.win_count = packet:readInt()
	data.win_max = packet:readInt() --最大赢注
	data.win_total = packet:readInt() -- 累积赢得的总筹码数
	-- data.allin_count = packet:readInt()
	-- data.allin_win_count = packet:readInt() 
	-- data.arena_count = packet:readInt() --竞技场的参加次数
	-- data.arena_win_count = packet:readInt() -- 竞技场的夺冠次数

	data.best_cards = {packet:readChar(),packet:readChar(),packet:readChar(),packet:readChar(),packet:readChar()}
	-------
	return data
end

function ParseSocket:loginToGameSuccess(packet)
	local flag = packet:readChar()
	if flag == 0 then
		local data = self:readUserInfo(packet)
		utils.__merge(USER,data)
		CONFIG.serverTime = packet:readInt()
		CONFIG.clinet_diftime = CONFIG.serverTime  - os.time()
		-------当前游戏局会话信息 
		flag = packet:readChar()  --是否读取本字段
		if flag == 1 then 
			USER.tid = packet:readInt()
			USER.seatid = packet:readChar()
			USER.chipin = packet:readInt()
			USER.buying = packet:readInt()
		end
	else
		-- LANG["RSP_LOGIN_"..flag] --错误提示
	end

	SocketEvent:dispatchEvent({name = CMD.RSP_GAME_SERVER.."back",data=falg})
end

return ParseSocket