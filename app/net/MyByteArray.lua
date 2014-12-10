ByteArray = require("framework.cc.utils.ByteArray")


function ByteArray:Begin(cmd)
	self:writeInt(0) --站个写包长度的位置
	self:writeShort(cmd)
	dump("send ---- >>>>>    "..cmd)
end

function ByteArray:End()
	self:writeInInt(1,self:getPos()-5)
end

function ByteArray:getBeginCmd()
	self._pos = 5
	local cmd = self:readShort()
	return cmd
end

function ByteArray:readInShort(__offset)
	local __, __v = string.unpack(self:readInBuf(__offset,2), self:_getLC("h"))
	return __v
end

function ByteArray:writeInShort(__offset,__short)
	local __s = string.pack( self:_getLC("h"),  __short)
	self:writeInBuf(__offset,__s)
	return self
end

function ByteArray:writeInInt(__offset,__int)
	local __s = string.pack( self:_getLC("i"),  __int)
	self:writeInBuf(__offset,__s)
	return self
end

function ByteArray:writeInBuf(__offset,__s)
	for i=1,#__s do
		self:writeInRawByte(__offset+i-1,__s:sub(i))
	end
	return self
end

function ByteArray:writeInRawByte(__offset,__rawByte)
	if __offset > #self._buf then
		for i=#self._buf+1,__offset do
			self._buf[i] = string.char(0)
		end
		self._pos = __offset+1;
	end
	self._buf[__offset] = __rawByte
	return self
end

function ByteArray:readInBuf(__offset,__len)
	--printf("readBuf,len:%u, pos:%u", __len, self._pos)
	local __ba = self:getBytes(__offset, __offset + __len - 1)
	self._pos = __offset + __len
	return __ba
end

function ByteArray:readString()
	self:_checkAvailable()
	local __len = self:readShort()
	local str = self:readStringBytes(__len) 
	return string.format("%s", str)
end


function ByteArray:writeString(__string)
	self:writeShort(#__string)
	self:writeBuf(__string)
	return self
end

return ByteArray