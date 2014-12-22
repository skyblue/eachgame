
-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
-- DEBUG = 0
DEBUG = 1

-- display FPS stats on screen
-- DEBUG_FPS = true
DEBUG_FPS = false

-- dump memory info every 10 seconds
DEBUG_MEM = false

-- load deprecated API
LOAD_DEPRECATED_API = false

-- load shortcodes API
LOAD_SHORTCODES_API = true

-- screen orientation
CONFIG_SCREEN_ORIENTATION = "landscape"

-- design resolution
CONFIG_SCREEN_WIDTH  = 1704
CONFIG_SCREEN_HEIGHT = 960

-- auto scale mode
-- CONFIG_SCREEN_AUTOSCALE = "FIXED_HEIGHT"
CONFIG_SCREEN_AUTOSCALE = "FIXED_WIDTH"

--一些全局实例数据
_ = {}


CONFIG={
	sid = 2,---0、自身的几点号，1、游客，2、泡泡吃
	appName = "一起德州",
	gameId = 10002,
	itunesId = 949785491,
	EachGame_URL = "http://api.17yx.tk/" ,
	-- EachGame_URL = "http://api.17test.tk/",
	-- EachGame_URL = "http://api.eachgame.com/",
	API_URL = "texas.eachgame.com",
	ORIGIN_API_URL = "http://192.168.1.109/pokerp/api/flashapi.php",
	BACKUP_API_URL = "http://192.168.1.109/pokerp/api/flashapi.php",
	useBackupApi = "false",
	server = "192.168.1.11",
	-- server = "texas.eachgame.com",
	port = "3050",
	-- server = "192.168.1.34",
	-- port = "9501",
	gameServer = "192.168.1.11",
	-- gameServer = "texas.eachgame.com",
	gamePort = "3050",

	appversion = "1.0.0",
	versioncode = 1,
	uploadPic = true,
	umengid="",
	channel = "",
	lang ="cn",
	appid = 1001,
	coinList = "",
	levelExps="",
	clinet_diftime = 0 ,

	cardtypes    = {'高牌', '一对', '两对', '三条', '顺子', '同花', '葫芦', '四条', '同花顺', '皇家同花顺'},
	coinList     = {1,5,25,100,500,1000,5000,10000,25000,50000,100000,500000,1000000},
	status= {"弃牌","看牌","跟注","加注","全下","小盲注","大盲注","下注"},
	cards ={102,103,104,105,106,107,108,109,110,111,112,113,114,
			202,203,204,205,206,207,208,209,210,211,212,213,214,
			302,303,304,305,306,307,308,309,310,311,312,313,314,
			402,403,404,405,406,407,408,409,410,411,412,413,414
			},
	-- selectRoom={
	-- 			{name="一级荷官",min_b = 10,max_b = 500,min_buying = "1万",max_buying ="10万"},
	-- 			{name="二级荷官",min_b = 1000,max_b = 10000,min_buying = "20万",max_buying ="200万"},
	-- 			{name="三级荷官",min_b = 20000,max_b = 100000,min_buying = "400万",max_buying ="1亿"},
	-- 		},
}

USER ={
	sessionkey = "",
	testKey = "E84B2EF4602533858G49FB57F7ID222B",
}

CMD = {
	HEART			= 0,
	REQ_REG 		= 1,
	REQ_LOGIN 		= 2,
	RSP_LOGIN 		= 3,
	REQ_GAME_SERVER = 2000,
	RSP_GAME_SERVER = 2001,
	REQ_USER_INFO 	= 2002,
	RSP_USER_INFO 	= 2003,

	REQ_SCENES_LIST	= 2006,
	RSP_SCENES_LIST	= 2007,

	REQ_CHANGE_SEX 	= 2010,
	RSP_CHANGE_SEX	= 2011,
	REQ_CHANGE_UNAME 	= 2012,
	RSP_CHANGE_UNAME	= 2013,
	REQ_CHANGE_PIC 	= 2014,
	RSP_CHANGE_PIC	= 2015,

	REQ_IN_TABLE 	= 2101,
	RSP_IN_TABLE 	= 2102,

	REQ_SHOPLIST	= 12,
	RSP_SHOPLIST	= 13,
	REQ_BUY			= 14,
	RSP_BUY			= 15,

	REQ_MISSIONLIST	= 20,
	RSP_MISSIONLIST	= 21,
	REQ_MISSION_COM	= 22,
	RSP_MISSION_COM	= 23,

	CHAT 			= 3001,
	CHAT_NTF 		= 3002,
}

ROOM_CMD = {
	NTF_GAME_START	= 2550,
	NTF_START_ACTION= 2551,

	REQ_CHIP_ACTION	= 2560,
	RSP_CHIP_ACTION	= 2561,
	NTF_CHIP_ACTION	= 2562,

	RSP_HAND_CARDS	= 2571,
	RSP_FLOP		= 2572,
	RSP_TURN		= 2573,
	RSP_RIVER		= 2574,
	RSP_FINAL_ROUND	= 2575,
	RSP_FINAL_GAME	= 2576,

	NTF_USER_ENTER	= 2103,

	REQ_USER_SIT	= 2105,
	RSP_USER_SIT	= 2106,
	NTF_USER_SIT	= 2107,
	NTF_BUYING		= 2108,
	
	REQ_USER_STAND	= 2109,
	RSP_USER_STAND	= 2110,
	NTF_USER_STAND	= 2111,

	REQ_OUT_TABLE = 2201,
	RSP_OUT_TABLE =2202,
	NTF_OUT_TABLE =2104,
}

CON__USER_NONE 	= 0;--无动作
CON__USER_FOLD 	= 1;--弃牌
CON__USER_CHECK = 2;--看牌
CON__USER_CALL  = 3;--跟注
CON__USER_RAISE = 4;--加注
CON__USER_ALLIN = 5;--全下
CON__USER_BET   = 6;--下注
CHIPIN_SMALL 	= 7;--小盲注
CHIPIN_BIG 		= 8;--大盲注
CHIPIN_NONE 	= 9;--未说话
CHIPIN_WAIT 	= 10;--等待下一轮


