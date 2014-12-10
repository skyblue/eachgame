local SocketEvent = class("SocketEvent")

local REQ_REQUEST = 0    -- 读包头
local REQ_BODY = 2       -- 读包数据
local REQ_DONE = 3       -- 完成 
local PACKET_HEADER_SIZE = 6 -- 头部6字节
local PACKET_BUFFER_SIZE = 1024*16 -- 最大接收buf

local SocketTCP = require("framework.cc.net.SocketTCP")
local ByteArray = require("app.net.MyByteArray")


local function getcmd(self)
    self.readPacket:setPos(5)
    return self.readPacket:readShort()
end

-- local function getbodylen(self)
--     self.readPacket:setPos(5)
--     return self.readPacket:readShort();
-- end

local function reset(self)
    self.nStatus = REQ_REQUEST
    self.nBodyLen = 0
    self.readPacket = ByteArray.new(ByteArray.ENDIAN_LITTLE)
end

local function parse_body(self)
    if self.buf:getAvailable() < self.nBodyLen then
        return false
    end
    if self.nBodyLen ~= 0 then
        self.buf:readBytes(self.readPacket, 5, self.nBodyLen-1)
    end
    -- dump("parse_body --  " .. self.readPacket:getLen())
    return true
end

local function read_header(self)
    if self.buf:getAvailable() < PACKET_HEADER_SIZE then
        return false
    end
    self.buf:readBytes(self.readPacket, 1, 3)
    self.readPacket:setPos(1)
    local len = self.readPacket:readInt()
    self.nBodyLen = len 
    -- print(string.format("SERVERDebug  recv cmd=%d,len=%d", cmd, self.nBodyLen))
    if self.nBodyLen >= 0 and self.nBodyLen < (PACKET_BUFFER_SIZE - PACKET_HEADER_SIZE) then
        return true
    else
        --长度操出buf的长度了，把包丢掉
        reset(self)
    end
    return false
end

local loopParse 
    loopParse= function(self)
    if not self.socket.isConnected then
        return
    end
    -- 读头
    if (self.nStatus == REQ_REQUEST) then
        if not read_header(self) then
            -- dump("头部非正常重置")
            -- reset(self)
            if self.buf:getAvailable() >= PACKET_HEADER_SIZE then
                loopParse(self)
            end
            return
        end
        self.nStatus = REQ_BODY
    end

    -- 包体
    if self.nStatus == REQ_BODY then
        if not parse_body(self) then
            return
        end
        self.nStatus = REQ_DONE
    end

    -- 完成向外派发事件并继续读取
    if self.nStatus == REQ_DONE then
        self:processServerMsg()
        -- dump("读完包体正常重置")
        reset(self)
        loopParse(self)
    end
end


function SocketEvent:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    -- 当前读取的状态
    self.nStatus = REQ_REQUEST
    -- 包体的长度
    self.nBodyLen = 0
    -- 接收缓冲区
    self.buf = ByteArray.new(ByteArray.ENDIAN_LITTLE)
    -- 读取包
    self.readPacket = ByteArray.new(ByteArray.ENDIAN_LITTLE)
    self.socket = nil
    -- dump("reset self.readPacket ctor")
end

function SocketEvent:init( host,pot,__retryConnectWhenFailure)
    if self.socket then
        self.socket:removeEventListenersByEvent(SocketTCP.EVENT_CONNECTED)
        self.socket:removeEventListenersByEvent(SocketTCP.EVENT_CLOSE)
        self.socket:removeEventListenersByEvent(SocketTCP.EVENT_CLOSED)
        self.socket:removeEventListenersByEvent(SocketTCP.EVENT_CONNECT_FAILURE)
        self.socket:removeEventListenersByEvent(SocketTCP.EVENT_DATA)
        self.socket = nil
    end
	local socket = SocketTCP.new(host, pot, __retryConnectWhenFailure)
    self.socket = socket
    socket:addEventListener(SocketTCP.EVENT_CONNECTED, handler(self, self.onConnect))
    socket:addEventListener(SocketTCP.EVENT_CLOSE, handler(self, self.onClose))
    socket:addEventListener(SocketTCP.EVENT_CLOSED, handler(self, self.onClosed))
    socket:addEventListener(SocketTCP.EVENT_CONNECT_FAILURE, handler(self, self.onConnectFailure))
    socket:addEventListener(SocketTCP.EVENT_DATA, handler(self, self.onData))
    socket:connect()
end

function SocketEvent:connect(host,pot,__retryConnectWhenFailure)
    self.socket.__host = host
    self.socket.__port = pot
    self.socket.__retryConnectWhenFailure = __retryConnectWhenFailure
    self.socket:connect()
end

function SocketEvent:close()
    self.socket:close()
end

function SocketEvent:send(packet)
	-- if DEBUG>0 then
 --        console.log("send >>> ",json.encode(data))
 --    end
    if not self.socket or not self.socket.tcp then
        print("connection not exist")
        return
    end
    if self.socket.isConnected then

        self.socket:send(packet:getPack())
    end
end

function SocketEvent:onClose(__event)
    print("socket status: ".. __event.name)
    self:dispatchEvent({name = " closed"})
end

function SocketEvent:onClosed(__event)
    print("socket status: ".. __event.name)
    self:dispatchEvent({name = " closed"})
end

function SocketEvent:onConnectFailure(__event)
    print("socket status: ".. __event.name)
end

function SocketEvent:onConnect(__event)
    print("socket status: ".. __event.name)

    self:dispatchEvent({name = "contented"})
end

function SocketEvent:onData(__event)
    -- dump("pos      "..self.buf:getPos())
    -- dump("__event.data     " ..  #__event.data)
    -- dump(self.buf:getAvailable())
    if self.buf:getAvailable() == 0 then
        self.buf = ByteArray.new(ByteArray.ENDIAN_LITTLE)
        self.buf:setPos(1)
    else
        -- dump(#self.buf._buf)
        self.buf:setPos(#self.buf._buf + 1)
    end
    self.buf:writeBuf(__event.data)
    self.buf:setPos(1)

    -- dump(string.format("pos %d size %d", self.buf:getPos(), self.buf:getAvailable()))
    -- dump(#self.buf._buf)
    loopParse(self)
end

--解析接收报文
function SocketEvent:processServerMsg()
    self.readPacket:setPos(1)
    local packet = self.readPacket
    -- dump("dispatch packet len  --  " .. packet:getLen())
    local cmd = packet:getBeginCmd()
    -- dump("process cmd=" .. cmd)
    self:dispatchEvent({name = "onServerData", data= packet})
end

return SocketEvent
