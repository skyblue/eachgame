ParseSocket = class("SocketTCP")

SocketEvent = require("app.net.SocketEvent").new()     
SendCMD = require("app.net.SendCMD").new(SocketEvent)     

function ParseSocket:ctor()
	self.contentType = 1
	self.neddHeart = true
	SocketEvent:init(CONFIG.server ,CONFIG.port ,false) 

	local timeout_num,tid = 0
	local function reCon ( msg )
		timeout_num = 0
    	if tid then
        	scheduler.unscheduleGlobal(tid)
        end
        utils.dialog("", msg,{"重试"},function(event)
        	SendCMD:changeToGameServer()
        	self.neddHeart = true
        	heart()
        end)
	end
    local function heart(  )
    	return scheduler.scheduleGlobal(function()
    		if not self.neddHeart then return end
	        if timeout_num >= 5 then
	        	reCon("连接超时，请重新连接")
	        else
	        	SendCMD:heart()
	        	timeout_num = timeout_num + 1
	        end
	    end, 4)
    end
    -- tid = heart()

	SocketEvent:addEventListener("closed", function(event)
		reCon("网络连接被断开，请重新连接")
	end)
	SocketEvent:addEventListener("failure", function(event)
		reCon("连接失败，请检查您的网络！")
	end)


	SocketEvent:addEventListener("contented", function(event)
		if self.contentType == 1 then 
			if CONFIG.last_login then
				self.neddHeart = false
				CONFIG.last_login._type = CONFIG.last_login._type or 2
				SendCMD:login(CONFIG.last_login.acc,CONFIG.last_login.pwd,CONFIG.last_login._type)
			else
				self.neddHeart = true
				local siginId = utils.getUserSetting("last_login_siginId",nil)
				if siginId == nil or siginId == 1 then --没有就游客登陆 1
					SendCMD:login("","",1)
				else  -- 0 自己的帐号登陆
					local data = utils.getUserSetting("last_login")
					if data and data.acc and data.pwd then
						data._type = data._type or 2
						SendCMD:login(data.acc,data.pwd,data._type)
					else
						SendCMD:login("","",1)
					end
				end
			end
		else
			--连游戏服务器
			if CONFIG.gameServer and CONFIG.gamePort then
				SendCMD:loginToGameServer()
			else
				-- --弹登陆框
				-- display.replaceScene(Login.new())
			end
		end
	end)
			

	SocketEvent:addEventListener("onServerData", function(event)
			local packet = event.data
			packet:setPos(1)
			local cmd = packet:getBeginCmd()
			if DEBUG > 0 and cmd > 0 then
				dump("cmd -----》》》  "..cmd)
		        -- printInfo(os.date("%Y-%M-%d-%X"))
       			-- dump(os.time() + CONFIG.clinet_diftime)
			end
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
	self.fun["fun"..CMD.HEART] = function()
		timeout_num = 0
	end
	self.fun["fun"..CMD.RSP_LOGIN] = self.loginSuccess
	self.fun["fun"..CMD.RSP_USER_INFO] = self.userInfo
	self.fun["fun"..CMD.RSP_GAME_SERVER] = self.loginToGameSuccess
	self.fun["fun"..CMD.RSP_IN_TABLE] = self.inTable
	self.fun["fun"..CMD.RSP_SCENES_LIST] = self.scenesList
	self.fun["fun"..CMD.RSP_CHANGE_PIC] = self.changePic
	self.fun["fun"..CMD.RSP_CHANGE_UNAME] = self.changeUname
	self.fun["fun"..CMD.RSP_CHANGE_SEX] = self.changeSex
	self.fun["fun"..CMD.RSP_SHOPLIST] = self.shoplist  
	self.fun["fun"..CMD.RSP_BUY] = self.buy
	self.fun["fun"..CMD.RSP_MISSION_COM] = self.completeMission

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
	self.fun["fun"..ROOM_CMD.NTF_ANIMATION] = self.animation
	self.fun["fun"..ROOM_CMD.RSP_ANIMATION] = self.animationFailure

end

function ParseSocket:animationFailure(packet)
	local flag = packet:readChar()
	if flag ~= 0 then
		utils.dialog("", LANG["RSP_ANIMATION_"..flag],{"确定"})
	end
end

function ParseSocket:animation(packet)
	local uid = packet:readInt()
	local pid = packet:readShort()
	local seatid = packet:readChar()
	SocketEvent:dispatchEvent({name = ROOM_CMD.NTF_ANIMATION .. "back",data = {uid =uid,pid = pid,seatid =  seatid}})
end

function ParseSocket:completeMission(packet)
	local flag = packet:readChar()
	if flag ~= 0 then
		utils.dialog("", LANG["RSP_MISSION_COM_"..flag],{"确定"})
	else
		USER.uchips = packet:readInt()
		USER.exp = packet:readInt()
		USER.score = packet:readInt()
		SocketEvent:dispatchEvent({name = CMD.RSP_BUY .. "back"})
	end
end

function ParseSocket:buy(packet)
	local flag = packet:readChar()
	USER.uchips = packet:readInt()
	if flag ~= 0 then
		utils.dialog("", LANG["RSP_BUY_"..flag],{"确定"})
	else
		SocketEvent:dispatchEvent({name = CMD.RSP_BUY .. "back"})
	end
end

function ParseSocket:shoplist(packet)
	local list = {}
	local num = packet:readShort()
	local item = {}
	for i=1,num do
		item = {}
		item.proid = packet:readString()
		item.type  = packet:readInt()
		item.chips = packet:readInt()
		item.addChips = packet:readInt()
		item.money = packet:readInt()
		item.dec   = packet:readString()
		item.unit = "￥"
		list[i] = item
	end
	SocketEvent:dispatchEvent({name = CMD.RSP_SHOPLIST .. "back",data = list})
end

function ParseSocket:userEnter(packet)
	local data = self:readUserBaseInfo(packet)
	data.uchips = packet:readInt()
	data.level = packet:readShort()
	if _.Room and _.Room.model and _.Room.model.lookUser then
		_.Room.model.lookUser[#_.Room.model.lookUser] = data
	end
end

function ParseSocket:changeSex(packet)
	local flag = packet:readChar()
	if flag == 0 then
		-- USER.sex = packet:readChar()
	else
		utils.dialog("", LANG["RSP_CHANGE_SEX_"..flag],{"确定"})
	end
	SocketEvent:dispatchEvent({name = CMD.RSP_CHANGE_SEX .. "back"})
end

function ParseSocket:changePic(packet)
	local flag = packet:readChar()
	if flag == 0 then
		-- USER.upic = packet:readString()
		SocketEvent:dispatchEvent({name = CMD.RSP_CHANGE_PIC .. "back"})
	else
		utils.dialog("", LANG["RSP_CHANGE_PIC_"..flag],{"确定"})
	end
end

function ParseSocket:changeUname(packet)
	local flag = packet:readChar() dump(flag)
	if flag == 0 then
		-- USER.uname = packet:readString()
		SocketEvent:dispatchEvent({name = CMD.RSP_CHANGE_UNAME .. "back"})
		SocketEvent:dispatchEvent({name = CMD.RSP_CHANGE_UNAME .. "back1"})
	else
		utils.dialog("", LANG["RSP_CHANGE_UNAME_"..flag],{"确定"})
	end
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
	if _.Room and _.Room.model and _.Room.model.lookUser then
		for i,v in ipairs(_.Room.model.lookUser) do
			if v.uid == uid then
				table.remove(_.Room.model.lookUser, i)
				break;
			end
		end
	end
	SocketEvent:dispatchEvent({name = ROOM_CMD.NTF_OUT_TABLE .. "back",data = uid})
end

function ParseSocket:outTable(packet) 
	local flag = packet:readChar()
	if flag == 0 then
		_.Room:exit(true)
		_.Hall = Hall.new()
		display.replaceScene(_.Hall)
		if _.Room and _.Room.model and _.Room.model.lookUser then
			for i,v in ipairs(_.Room.model.lookUser) do
				if v.uid == USER.uid then
					table.remove(_.Room.model.lookUser, i)
					break;
				end
			end
		end
		
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
		player.uid = packet:readInt()
		player.seatid = packet:readChar()

		player.win = packet:readInt()
		player.buying = packet:readInt()
		player.profit = packet:readInt()
		player.type = packet:readChar()
		if player.type > 0 then
			player.hand_cards ={}
			player.hand_cards[1] = packet:readChar()
			player.hand_cards[2] = packet:readChar()
			player.hight_cards ={}
			player.hight_cards[1] = packet:readChar()
			player.hight_cards[2] = packet:readChar()
			player.hight_cards[3] = packet:readChar()
			player.hight_cards[4] = packet:readChar()
			player.hight_cards[5] = packet:readChar()
		end
		players[i] = player
	end
	SocketEvent:dispatchEvent({name = ROOM_CMD.RSP_FINAL_GAME .. "back",data ={users =players,_type = _type}})
end

function ParseSocket:finalRound(packet) 
	local round = packet:readChar()
	local round_pot = packet:readInt()
	local bottom_pots = packet:readInt()
	local pots = self:readCharArrayData(packet) 
		pot = pots or {}
	pots[#pots] = bottom_pots

	SocketEvent:dispatchEvent({name = ROOM_CMD.RSP_FINAL_ROUND .. "back",data ={round = round,round_pot =round_pot,bottom_pots=bottom_pots,pots=pots}})
end

function ParseSocket:river(packet) --最后一轮，河牌
	local card = self:readCharArrayData(packet)
	SocketEvent:dispatchEvent({name = ROOM_CMD.RSP_RIVER .. "back",data = card})
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
	SocketEvent:dispatchEvent({name =ROOM_CMD.RSP_HAND_CARDS .. "back",data = card})
end

function ParseSocket:readChipAction(packet)
	local data = {}
	data.uid = packet:readInt()
	data.seatid = packet:readChar()
	data.type = packet:readChar()
	data.buying = packet:readInt()
	data.chipin = packet:readInt()
	return data
end

function ParseSocket:chipinAction(packet)
	local data = self:readChipAction(packet)
	SocketEvent:dispatchEvent({name = ROOM_CMD.NTF_CHIP_ACTION .. "back",data = data})
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
		userSeatInfo[i] = {}
		userSeatInfo[i].uid = packet:readInt()
		userSeatInfo[i].seatid = packet:readChar()
		userSeatInfo[i].buying = packet:readInt()
	end
	tableInfo.users = userSeatInfo
	SocketEvent:dispatchEvent({name = ROOM_CMD.NTF_GAME_START .. "back",data = tableInfo})
end

function ParseSocket:userStandNtf(packet)
	local uid = packet:readInt()
	local seatid = packet:readChar()
	local tid = packet:readInt()
	local _type = packet:readChar()
	if uid == USER.uid then
		USER.uchips = packet:readInt()
	end
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
		SocketEvent:dispatchEvent({name = ROOM_CMD.NTF_BUYING .. "back",data = data})
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
		tableInfo.public_cards = {packet:readChar(),packet:readChar(),packet:readChar(),packet:readChar(),packet:readChar()}
		local playerNum = packet:readChar()
		local edgeNum = packet:readChar()
		local has_focus = packet:readChar()
		for i=1,edgeNum do
			tableInfo.edge_pots[i] = packet:readChar()
		end
		tableInfo.users={}
		
		if has_focus == 1 then
			tableInfo.currPlayer = {}
			tableInfo.currPlayer.uid = packet:readInt()
			tableInfo.currPlayer.seatid = packet:readChar()
			tableInfo.currPlayer.need_call = packet:readInt()
			tableInfo.currPlayer.min_raise = packet:readInt()
			tableInfo.currPlayer.max_raise = packet:readInt()
			tableInfo.currPlayer.gap_sec = packet:readInt() - CONFIG.clinet_diftime - os.time()
		end
		for i=1,playerNum do
			tableInfo.users[i] = self:readUserBaseInfo(packet)
			------
			tableInfo.users[i].uchips = packet:readInt()
			-------
			tableInfo.users[i].seatid = packet:readChar()
			tableInfo.users[i].chipin = packet:readInt()
			tableInfo.users[i].buying = packet:readInt()
			tableInfo.users[i].status = packet:readChar()
			if tableInfo.currPlayer and tableInfo.currPlayer.uid == tableInfo.users[i].uid then
				tableInfo.currPlayer.chipin = tableInfo.users[i].chipin
			end
		end
		SocketEvent:dispatchEvent({name = CMD.RSP_IN_TABLE .. "back",data =tableInfo})
	else
		utils.dialog("", LANG["RSP_IN_TABLE_"..flag],{"确定"})
	end
end

function ParseSocket:startChipinAction(packet)
	local data = {}
	data.seatid = packet:readChar()
	data.uid = packet:readInt()
	data.need_call = packet:readInt()
	data.min_raise = packet:readInt()
	data.max_raise = packet:readInt()
	data.chipin = packet:readInt()
		-- int 服务器发包的时候操作结束的时间
		-- CONFIG.clinet_diftime 服务器和客户端的时间差
		-- os.time() + CONFIG.clinet_diftime 同步的服务器时间
		-- data.time - os.time() + CONFIG.clinet_diftime 数据在传输过程中的延时
		-- room.model.gap_seci 当前房间的操作时间
		-- data.gap_sec 还剩下的操作时间
		-- data.gap_sec = data.time - os.time() + CONFIG.clinet_diftime + room.model.gap_sec
	data.gap_sec = packet:readInt()
	data.gap_sec = data.gap_sec - CONFIG.clinet_diftime - os.time()
	SocketEvent:dispatchEvent({name = ROOM_CMD.NTF_START_ACTION .. "back",data =data})
end

function ParseSocket:loginSuccess(packet)
	local flag = packet:readChar()
	if flag == 0 or flag == 1 then
		CONFIG.siginId = packet:readChar()
		utils.setUserSetting("last_login_siginId",CONFIG.siginId)
		CONFIG.blockedSecs = packet:readInt()
		USER.sessionkey = packet:readInt()

		CONFIG.gameServer = packet:readString()
		CONFIG.gamePort = packet:readShort()
		CONFIG.httpServer = packet:readString()
		self.contentType = 2
		SendCMD:changeToGameServer()
		if CONFIG.last_login then
			utils.setUserSetting("last_login",CONFIG.last_login)
		end
		SocketEvent:dispatchEvent({name = CMD.RSP_LOGIN .. "back"})
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
		if data.uid == USER.uid then
			utils.__merge(USER,data)
		 	if USER.needShow then
				display.getRunningScene():addChild(UserInfo.new(data),30)
			else
				USER.needShow = true
			end
		else
			display.getRunningScene():addChild(UserInfo.new(data),30)
		end
	else
		utils.dialog("", LANG["RSP_USER_INFO"],{"确定"})
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
	
	-- data.arena_count = packet:readInt() --竞技场的参加次数
	-- data.arena_win_count = packet:readInt() -- 竞技场的夺冠次数

	data.best_cards = {packet:readChar(),packet:readChar(),packet:readChar(),packet:readChar(),packet:readChar()}
	-------
	data.pay_count = packet:readInt()
	data.top_chips = packet:readInt() 
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
		dump(flag)
		if flag == 1 then
			USER.tid = packet:readInt()
			USER.seatid = packet:readChar()
			USER.chipin = packet:readInt()
			USER.buying = packet:readInt()
			dump(USER)
		end
	else
		-- LANG["RSP_LOGIN_"..flag] --错误提示
	end

	SocketEvent:dispatchEvent({name = CMD.RSP_GAME_SERVER.."back",data=falg})
end

return ParseSocket