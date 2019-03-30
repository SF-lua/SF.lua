--[[
	Authors: FYP, imring, DonHomka.
	Thanks BH Team for development.
	Structuers/addresses/other were taken in s0beit 0.3.7: https://github.com/BlastHackNet/mod_s0beit_sa
	http://blast.hk/ (ñ) 2018.

	lite version of RakNet BitStream Copyright 2003 Kevin Jenkins.
]]
local BitStream = {}

local ffi = require 'ffi'
local bit = require 'bit'

local BITSTREAM_STACK_ALLOCATION_SIZE = 256

local function BYTES_TO_BITS(x) return bit.lshift(x, 3) end
local function BITS_TO_BYTES(x) return bit.rshift(byte + 7, 3) end
local function GET_POINTER(cdata) return tonumber(ffi.cast('intptr_t', ffi.cast('void*', struct))) end

ffi.cdef[[
struct BitStream
{
	int						numberOfBitsUsed;
	int						numberOfBitsAllocated;
	int						readOffset;
	uint8_t*				data;
	bool					copyData;
	uint8_t					stackData[256];
} __attribute__ ((packed));
]]

function BitStream.new(pointer)
	local bs_data = tonumber(pointer) and ffi.cast('BitStream *', tonumber(pointer)) or ffi.new('BitStream')
	local bitstream = { bs_data }
	function bitstream:BitStream(...)
		local functions = {
			[0] = function()
				bs_data.numberOfBitsUsed = 0,
				-- bs_data.numberOfBitsAllocated = 32 * 8,
				bs_data.numberOfBitsAllocated = BITSTREAM_STACK_ALLOCATION_SIZE * 8,
				bs_data.readOffset = 0,
				-- bs_data.data = ffi.cast('uint8_t*', ffi.C.malloc(32)),
				bs_data.copyData = true
				bs_data.data = ffi.cast('uint8_t*', bs_data.stackData)
			end,
			function(initialBytesToAllocate)
				bs_data.numberOfBitsUsed = 0,
				bs_data.readOffset = 0,
				bs_data.copyData = true
				if initialBytesToAllocate <= BITSTREAM_STACK_ALLOCATION_SIZE then
					bs_data.data = ffi.cast('uint8_t*', bs_data.stackData)
					bs_data.numberOfBitsAllocated = BITSTREAM_STACK_ALLOCATION_SIZE * 8
				else
					bs_data..data = ffi.cast('uint8_t*', ffi.C.malloc(initialBytesToAllocate))
					bs_data.numberOfBitsAllocated = BYTES_TO_BITS(initialBytesToAllocate)
				end
			end,
			[3] = function(_data, lengthInBytes, _copyData)
				bs_data.numberOfBitsUsed = BYTES_TO_BITS(lengthInBytes),
				bs_data.readOffset = 0,
				bs_data.copyData = _copyData,
				bs_data.numberOfBitsAllocated = BYTES_TO_BITS(lengthInBytes)
				if bs_data.copyData then
					if lengthInBytes > 0 then
						if lengthInBytes < BITSTREAM_STACK_ALLOCATION_SIZE then
							bs_data.data = ffi.cast('uint8_t*', bs_data.stackData)
							bs_data.numberOfBitsAllocated = BYTES_TO_BITS(BITSTREAM_STACK_ALLOCATION_SIZE)
						else bs_data.data = ffi.cast('uint8_t*', ffi.C.malloc(lengthInBytes)) end
					end
					ffi.C.memcpy(data, _data, lengthInBytes)
				end
			end
		}
		local v = { ... }
		functions[#v](...)
	end

	function bitstream:SetNumberOfBitsAllocated(lengthInBits)
		bs_data.numberOfBitsAllocated = lengthInBits
	end

	function bitstream:FBitStream()
		if bs_data.copyData and bs_data.numberOfBitsAllocated > BYTES_TO_BITS(BITSTREAM_STACK_ALLOCATION_SIZE) then ffi.C.free(bs_data) end
	end

	function bitstream:Reset()
		if bs_data.numberOfBitsUsed > 0 then
			-- memset(data, 0, BITS_TO_BYTES(numberOfBitsUsed));
		end
		bs_data.numberOfBitsUsed = 0
		bs_data.readOffset = 0
	end

	function bitstream:Write(...)
		local functions = {
			function(...)
				local funcs = {
					function(bs)
						if type(bs) == 'userdata' and type(bs[1]) == 'cdata' then self:Write(bs, bs:GetNumberOfBitsUsed()) end
					end,
					function(input, numberOfBytes)
						if not numberOfBytes or numberOfBytes == 0 then return end
						if bit.band(bs_data.numberOfBitsUsed, 7) == 0 then
							self:AddBitsAndReallocate(BYTES_TO_BITS(numberOfBytes))
							ffi.C.memcpy(GET_POINTER(bs_data.data) + BITS_TO_BYTES(numberOfBitsUsed), input, numberOfBytes)
						else self:WriteBits(input, numberOfBytes * 8, true) end
					end,
					function(bitStream, numberOfBits)
						self:AddBitsAndReallocate(numberOfBits)
						local numberOfBitsMod8 = 0
						while bs_data.numberOfBits - 1 > 0 and bitStream.readOffset + 1 <= bitStream.numberOfBitsUsed do
							numberOfBitsMod8 = bit.band(numberOfBitsUsed, 7)
							if numberOfBitsMod8 == 0 then
								if bitStream.data[bit.band(bit.rshift(bitStream.readOffset, 3), bit.rshift(0x80, bitStream.readOffset + 1 % 8))] then
									bs_data.data[bit.rshift(bitStream.readOffset, 3)] = 0x80
								else
									bs_data.data[bit.rshift(bitStream.readOffset, 3)] = 0
								end
							else
								if bitStream.data[bit.band(bit.rshift(bitStream.readOffset, 3), bit.rshift(0x80, bitStream.readOffset + 1 % 8))] then
									bs_data.data[bit.rshift(bs_data.readOffset, 3)] = bit.bor(bs_data.data[bit.rshift(bs_data.readOffset, 3)], bit.rshift(0x80, numberOfBitsMod8))
								end
							end
							bs_data.numberOfBitsUsed = bs_data.numberOfBitsUsed + 1
						end
					end
				}
				if #({...}) > 1 then if type(({...})[1]) == 'cdata' then funcs[3](...) else funcs[2](...) end 
				else funcs[1](...) end
			end
		}
	end

	function bitstream:Read(output, numberOfBytes)
		if bit.band(bs_data.readOffset, 7) == 0 then
			if bs_data.readOffset + BYTES_TO_BITS(numberOfBytes) > bs_data.numberOfBitsUsed then return false end
			ffi.C.memcpy(output, GET_POINTER(bs_data.data) + bit.rshift(bs_data.readOffset, 3), numberOfBytes)
			bs_data.readOffset = bs_data.readOffset + BYTES_TO_BITS(numberOfBytes)
		else
			return self:ReadBits(output, numberOfBytes * 8)
		end
	end

	function bitstream:ResetReadPointer()
		bs_data.readOffset = 0
	end

	function bitstream:ResetWritePointer()
		bs_data.numberOfBitsUsed = 0
	end

	function bitstream:Write0()
		self:AddBitsAndReallocate(1)
		if bit.band(bs_data.numberOfBitsUsed, 7) == 0 then
			bs_data.data[bit.rshift(numberOfBitsUsed, 3)] = 0
		end
		bs_data.numberOfBitsUsed = bs_data.numberOfBitsUsed + 1
	end

	function bitstream:Write1()
		self:AddBitsAndReallocate(1)
		local numberOfBitsMod8 = bit.band(bs_data.numberOfBitsUsed, 7)
		if numberOfBitsMod8 == 0 then
			bs_data.data[bit.rshift(bs_data.numberOfBitsUsed, 3)] = 0x80
		else
			bs_data.data[bit.rshift(bs_data.numberOfBitsUsed, 3)] = bit.bor(bs_data.data[bit.rshift(numberOfBitsUsed, 3)], bit.rshift(0x80, numberOfBitsMod8))
		end
	end

	function bitstream:ReadBit()
		return bit.band(bs_data.data[bit.rshift(bs_data.numberOfBitsUsed, 3)], bit.rshift(0x80, bit.band(bs_data.readOffset + 1, 7))) ~= 0
	end

	function bitstream:WriteAlignedBytes(input, numberOfBytesToWrite)
		self:AlignWriteToByteBoundary()
		self:Write(input, numberOfBytesToWrite)
	end

	function bitstream:ReadAlignedBytes(output, numberOfBytesToRead)
		if numberOfBytesToRead <= 0 then return false end
		self:AlignReadToByteBoundary()
		if readOffset + BYTES_TO_BITS(numberOfBytesToRead) > bs_data.numberOfBitsUsed then return false end
		ffi.C.memcpy(output, GET_POINTER(bs_data.data) + bit.rshift(bs_data.readOffset, 3), numberOfBytesToRead)
		bs_data.readOffset = bs_data.readOffset + BYTES_TO_BITS(numberOfBytesToRead)
	end

	function bitstream:AlignWriteToByteBoundary()
		if bs_data.numberOfBitsUsed > 0 then bs_data.numberOfBitsUsed = bs_data.numberOfBitsUsed + ( 8 - bit.band(numberOfBitsUsed - 1, 7) + 1 ) end
	end

	function bitstream:AlignReadToByteBoundary()
		if bs_data.readOffset > 0 then bs_data.readOffset = bs_data.readOffset + ( 8 - bit.band(numberOfBitsUsed - 1, 7) + 1 ) end
	end

	function bitstream:WriteBits(input, numberOfBitsToWrite, rightAlignedBits)
		if bs_data.numberOfBitsToWrite <= 0 then return end
		self:AddBitsAndReallocate(numberOfBitsToWrite)
		local offset = 0
		local dataByte = 0
		local numberOfBitsUsedMod8 = bit.band(bs_data.numberOfBitsUsed, 7)
		while numberOfBitsToWrite > 0 do
			dataByte = GET_POINTER(input) + offset
			if numberOfBitsToWrite < 8 and rightAlignedBits then dataByte = bit.lshift(dataByte, 8 - numberOfBitsToWrite) end
			if numberOfBitsUsedMod8 == 0 then bs_data.data[bit.rshift(bs_data.numberOfBitsUsed, 3)] = dataByte
			else
				bs_data.data[bit.rshift(bs_data.numberOfBitsUsed, 3)] = bit.bor(bs_data.data[bit.rshift(bs_data.numberOfBitsUsed, 3)], bit.lshift(dataByte, numberOfBitsUsedMod8))
				if 8 - numberOfBitsUsedMod8 < 8 and 8 - numberOfBitsUsedMod8 < numberOfBitsToWrite then
					bs_data.data[bit.rshift(bs_data.numberOfBitsUsed, 3) + 1] = bit.rshift(dataByte, 8 - numberOfBitsUsedMod8)
				end
			end
			bs_data.numberOfBitsUsed = bs_data.numberOfBitsUsed + ( numberOfBitsToWrite >= 8 and 8 or numberOfBitsToWrite )
			numberOfBitsToWrite = numberOfBitsToWrite - 8
			offset = offset + 1
		end
	end

	function bitstream:SetData(input)
		bs_data.data = ffi.cast('uint8_t*', input)
		bs_data.copyData = false
	end

	function bitstream:WriteCompressed(input, size, unsignedData)
		input = ffi.cast('uint8_t*', input)
		local currentByte = bit.rshift(size, 3) - 1
		local byteMatch = 0
		if not unsignedData then byteMatch = 0xFF end
		while currentByte > 0 do
			if input[currentByte] == byteMatch then self:Write(true)
			else
				self:Write(false)
				self:WriteBits(input, BYTES_TO_BITS(currentByte + 1))
				return
			end
			currentByte = currentByte - 1
		end
		if ( unsignedData and bit.band(GET_POINTER(input) + currentByte, 0xF0) == 0x0 ) or 
			( unsignedData == false and bit.band(GET_POINTER(input) + currentByte, 0xF0) == 0xF0 ) then
			self:Write(true)

		end
	end

	return setmetatable(bitstream, {})
end

return BitStream