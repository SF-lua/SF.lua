--[[
	Authors: FYP, imring, DonHomka.
	Thanks BH Team for development.
	Structuers/addresses/other were taken in s0beit 0.3.7: https://github.com/BlastHackNet/mod_s0beit_sa
	http://blast.hk/ (c) 2018-2019.

	lite version of RakNet BitStream Copyright 2003 Kevin Jenkins.
]]
local BitStream = {}

local ffi = require 'ffi'
local bit = require 'bit'

local BITSTREAM_STACK_ALLOCATION_SIZE = 256

local function BYTES_TO_BITS(x) return bit.lshift(x, 3) end
local function BITS_TO_BYTES(x) return bit.rshift(x + 7, 3) end
local function GET_POINTER(cdata) return tonumber(ffi.cast('intptr_t', ffi.cast('void*', cdata))) end

ffi.cdef[[
struct BitStream
{
	int						numberOfBitsUsed;
	int						numberOfBitsAllocated;
	int						readOffset;
	BYTE*					data;
	bool					copyData;
	BYTE					stackData[256];
} __attribute__ ((packed));
]]

function BitStream.new(pointer)
	local bs_data = tonumber(pointer) and ffi.cast('BitStream *', tonumber(pointer))[0] or ffi.new('BitStream')
	local bitstream = { bs_data }
	function bitstream:BitStream(...)
		local functions = {
			[0] = function()
				bs_data.numberOfBitsUsed = 0
				-- bs_data.numberOfBitsAllocated = 32 * 8,
				bs_data.numberOfBitsAllocated = BITSTREAM_STACK_ALLOCATION_SIZE * 8
				bs_data.readOffset = 0
				-- bs_data.data = ffi.cast('BYTE*', ffi.C.malloc(32)),
				bs_data.copyData = true
				bs_data.data = ffi.cast('BYTE*', bs_data.stackData)
			end,
			function(initialBytesToAllocate)
				bs_data.numberOfBitsUsed = 0
				bs_data.readOffset = 0
				bs_data.copyData = true
				if initialBytesToAllocate <= BITSTREAM_STACK_ALLOCATION_SIZE then
					bs_data.data = ffi.cast('BYTE*', bs_data.stackData)
					bs_data.numberOfBitsAllocated = BITSTREAM_STACK_ALLOCATION_SIZE * 8
				else
					bs_data.data = ffi.cast('BYTE*', ffi.C.malloc(initialBytesToAllocate))
					bs_data.numberOfBitsAllocated = BYTES_TO_BITS(initialBytesToAllocate)
				end
			end,
			[3] = function(_data, lengthInBytes, _copyData)
				_data = ffi.cast('BYTE*', _data)
				bs_data.numberOfBitsUsed = BYTES_TO_BITS(lengthInBytes)
				bs_data.readOffset = 0
				bs_data.copyData = _copyData
				bs_data.numberOfBitsAllocated = BYTES_TO_BITS(lengthInBytes)
				if bs_data.copyData then
					if lengthInBytes > 0 then
						if lengthInBytes < BITSTREAM_STACK_ALLOCATION_SIZE then
							bs_data.data = ffi.cast('BYTE*', bs_data.stackData)
							bs_data.numberOfBitsAllocated = BYTES_TO_BITS(BITSTREAM_STACK_ALLOCATION_SIZE)
						else bs_data.data = ffi.cast('BYTE*', ffi.C.malloc(lengthInBytes)) end
					end
					ffi.C.memcpy(data, _data, lengthInBytes)
				end
			end
		}
		local v = { ... }
		local func = functions[#v]
		if #v == 2 then func = functions[1]
		elseif #v > 3 then func = functions[3] end
		func(...)
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
						bs = BitStream.new(GET_POINTER(bs))
						self:Write(bs, bs:GetNumberOfBitsUsed())
					end,
					function(input, numberOfBytes)
						input = ffi.cast('const char*', input)
						if not numberOfBytes or numberOfBytes == 0 then return end
						if bit.band(bs_data.numberOfBitsUsed, 7) == 0 then
							self:AddBitsAndReallocate(BYTES_TO_BITS(numberOfBytes))
							ffi.C.memcpy(bs_data.data + BITS_TO_BYTES(numberOfBitsUsed), input, numberOfBytes)
							bs_data.numberOfBitsUsed = bs_data.numberOfBitsUsed + BYTES_TO_BITS(numberOfBytes)
						else self:WriteBits(input, numberOfBytes * 8, true) end
					end,
					function(bitStream, numberOfBits)
						local bsdata = bitStream[1]
						self:AddBitsAndReallocate(numberOfBits)
						local numberOfBitsMod8 = 0
						while bs_data.numberOfBits - 1 > 0 and bsdata.readOffset + 1 <= bsdata.numberOfBitsUsed do
							numberOfBitsMod8 = bit.band(numberOfBitsUsed, 7)
							if numberOfBitsMod8 == 0 then
								if bsdata.data[bit.band(bit.rshift(bsdata.readOffset, 3), bit.rshift(0x80, bsdata.readOffset + 1 % 8))] then
									bs_data.data[bit.rshift(bsdata.readOffset, 3)] = 0x80
								else
									bs_data.data[bit.rshift(bsdata.readOffset, 3)] = 0
								end
							else
								if bsdata.data[bit.band(bit.rshift(bsdata.readOffset, 3), bit.rshift(0x80, bsdata.readOffset + 1 % 8))] then
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
		output = ffi.cast('char*', output)
		if bit.band(bs_data.readOffset, 7) == 0 then
			if bs_data.readOffset + BYTES_TO_BITS(numberOfBytes) > bs_data.numberOfBitsUsed then return false end
			ffi.C.memcpy(output, bs_data.data + bit.rshift(bs_data.readOffset, 3), numberOfBytes)
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
		bs_data.readOffset = bs_data.readOffset + 1
		return bit.band(bs_data.data[bit.rshift(bs_data.readOffset - 1, 3)], bit.rshift(0x80, bit.band(bs_data.readOffset + 1, 7))) ~= 0
	end

	function bitstream:WriteAlignedBytes(input, numberOfBytesToWrite)
		self:AlignWriteToByteBoundary()
		self:Write(input, numberOfBytesToWrite)
	end

	function bitstream:ReadAlignedBytes(output, numberOfBytesToRead)
		output = ffi.cast('BYTE*', output)
		if numberOfBytesToRead <= 0 then return false end
		self:AlignReadToByteBoundary()
		if readOffset + BYTES_TO_BITS(numberOfBytesToRead) > bs_data.numberOfBitsUsed then return false end
		ffi.C.memcpy(output, bs_data.data + bit.rshift(bs_data.readOffset, 3), numberOfBytesToRead)
		bs_data.readOffset = bs_data.readOffset + BYTES_TO_BITS(numberOfBytesToRead)
	end

	function bitstream:AlignWriteToByteBoundary()
		if bs_data.numberOfBitsUsed ~= 0 then bs_data.numberOfBitsUsed = bs_data.numberOfBitsUsed + ( 8 - bit.band(numberOfBitsUsed - 1, 7) + 1 ) end
	end

	function bitstream:AlignReadToByteBoundary()
		if bs_data.readOffset ~= 0 then bs_data.readOffset = bs_data.readOffset + ( 8 - bit.band(numberOfBitsUsed - 1, 7) + 1 ) end
	end

	function bitstream:WriteBits(input, numberOfBitsToWrite, rightAlignedBits)
		input = ffi.cast('BYTE*', input)
		if numberOfBitsToWrite <= 0 then return end

		self:AddBitsAndReallocate(numberOfBitsToWrite)
		local offset = 0
		local dataByte = 0
		local numberOfBitsUsedMod8 = 0

		numberOfBitsUsedMod8 = bit.band(bs_data.numberOfBitsUsed, 7)

		while numberOfBitsToWrite > 0 do
			dataByte = (input + offset)[0]

			if numberOfBitsToWrite < 8 and rightAlignedBits then
				dataByte = bit.lshift(dataByte, 8 - numberOfBitsToWrite)
			end

			if numberOfBitsUsedMod8 == 0 then
				(bs_data.data + bit.rshift(bs_data.numberOfBitsUsed, 3))[0] = dataByte
			else
				(bs_data.data + bit.rshift(bs_data.numberOfBitsUsed, 3))[0] = bit.bor((data + bit.rshift(bs_data.numberOfBitsUsed, 3))[0], bit.rshift(dataByte, numberOfBitsUsedMod8))

				if 8 - numberOfBitsUsedMod8 < 8 and 8 - numberOfBitsUsedMod8 < numberOfBitsToWrite then
					(bs_data.data + bit.rshift(bs_data.numberOfBitsUsed, 3) + 1)[0] = bit.lshift(dataByte, 8 - numberOfBitsUsedMod8)
				end
			end

			if numberOfBitsToWrite >= 8 then bs_data.numberOfBitsUsed = bs_data.numberOfBitsUsed + 8
			else bs_data.numberOfBitsUsed = bs_data.numberOfBitsUsed + numberOfBitsToWrite end

			numberOfBitsToWrite = numberOfBitsToWrite - 8

			offset = offset + 1
		end
	end

	function bitstream:SetData(input)
		bs_data.data = ffi.cast('BYTE*', input)
		bs_data.copyData = false
	end

	function bitstream:WriteCompressed(input, size, unsignedData)
		input = ffi.cast('BYTE*', input)
		local currentByte = bit.rshift(size, 3) - 1
		local byteMatch = 0
		if not unsignedData then byteMatch = 0xFF end
		while currentByte > 0 do
			if input[currentByte] == byteMatch then self:Write(true)
			else
				self:Write(false)
				self:WriteBits(input, BYTES_TO_BITS(currentByte + 1), true)
				return
			end
			currentByte = currentByte - 1
		end
		if ( unsignedData and bit.band(input + currentByte, 0xF0) == 0x0 ) or 
			( unsignedData == false and bit.band(input + currentByte, 0xF0) == 0xF0 ) then
			self:Write(true)
			self:WriteBits(input + currentByte, 4, true)
		else
			self:Write(false)
			self:WriteBits(input + currentByte, 8, true)
		end
	end

	function bitstream:ReadBits(output, numberOfBitsToRead, alignBitsToRight)
		output = ffi.cast('BYTE*', output)
		if numberOfBitsToRead <= 0 then return false end

		if bs_data.readOffset + numberOfBitsToRead > numberOfBitsUsed then return false end

		local readOffsetMod8, offset = 0, 0
		ffi.C.memset(output, 0, BITS_TO_BYTES(numberOfBitsToRead))

		readOffsetMod8 = bit.band(bs_data.readOffset, 7)
		while numberOfBitsToRead > 0 do
			(output + offset)[0] = bit.bor((output + offset)[0], bit.lshift((bs_data.data + bit.rshift(bs_data.readOffset, 3))[0], readOffsetMod8))
			if readOffsetMod8 > 0 and numberOfBitsToRead > 8 - readOffsetMod8 then
				(output + offset)[0] = bit.bor((output + offset)[0], bit.lshift((bs_data.data + bit.rshift(bs_data.readOffset, 3) + 1)[0], 8 - readOffsetMod8))
			end
			numberOfBitsToRead = numberOfBitsToRead - 8
			if numberOfBitsToRead < 0 then
				if alignBitsToRight then (output + offset)[0] = -numberOfBitsToRead end
				readOffset = readOffset + 8 + numberOfBitsToRead
			else readOffset = readOffset + 8 end
			offset = offset + 1
		end
		return true
	end

	function bitstream:ReadCompressed(output, size, unsignedData)
		output = ffi.cast('BYTE*', output)
		local currentByte = BYTES_TO_BITS(size) - 1

		local byteMatch, halfByteMatch = 0, 0

		if not unsignedData then byteMatch, halfByteMatch = 0xFF, 0xF0 end

		while currentByte > 0 do
			local b = ffi.new('bool[1]')

			if self:Read(b) == false then return false end

			if b[0] then
				output[currentByte] = byteMatch
				currentByte = currentByte - 1
			else
				if self:ReadBits(output, BYTES_TO_BITS(currentByte + 1)) == false then return false end

				return true
			end
		end

		if readOffset + 1 > bs_data.numberOfBitsUsed then
			return false
		end

		local b = ffi.new('bool[1]')
		if self:Read(b) == false then return false end
		if b[0] then
			if self:ReadBits(output + currentByte, 4) == false then
				return false
			end
			output[currentByte] = bit.bor(output[currentByte], halfByteMatch)
		else
			if self:ReadBits(output + currentByte, 8) == false then return false end
		end

		return true
	end

	function bitstream:AddBitsAndReallocate(numberOfBitsToWrite)
		if numberOfBitsToWrite <= 0 then return end

		local newNumberOfBitsAllocated = numberOfBitsToWrite + bs_data.numberOfBitsUsed

		if numberOfBitsToWrite + bs_data.numberOfBitsUsed > 0 and bit.rshift(bs_data.numberOfBitsAllocated - 1, 3) < bit.rshift(newNumberOfBitsAllocated - 1, 3) then
			newNumberOfBitsAllocated = ( numberOfBitsToWrite + numberOfBitsUsed ) * 2
			local amountToAllocate = BITS_TO_BYTES(newNumberOfBitsAllocated)
			if bs_data.data == ffi.cast('uint8_t*', bs_data.stackData) then
				if amountToAllocate > BITSTREAM_STACK_ALLOCATION_SIZE then
					data = ffi.cast('uint8_t*', ffi.C.malloc(amountToAllocate))

					ffi.C.memcpy(ffi.cast('void*', data), ffi.cast('void*', stackData), BITS_TO_BYTES(bs_data.numberOfBitsAllocated))
				end
			else
				data = ffi.cast('uint8_t*', ffi.C.realloc(bs_data.data, amountToAllocate))
			end
		end

		if newNumberOfBitsAllocated > bs_data.numberOfBitsAllocated then
			bs_data.numberOfBitsAllocated = newNumberOfBitsAllocated
		end
	end

	function bitstream:AssertStreamEmpty()
		assert(bs_data.readOffset == bs_data.numberOfBitsUsed)
	end

	function bitstream:CopyData(_data)
		_data = ffi.cast('BYTE**', _data)
		_data[0] = ffi.new('uint8_t[?]', BITS_TO_BYTES( bs_data.numberOfBitsUsed ))
		ffi.C.memcpy(_data[0], bs_data.data, ffi.sizeof('uint8_t') * BITS_TO_BYTES( numberOfBitsUsed ))
		return numberOfBitsUsed
	end

	function bitstream:IgnoreBits(numberOfBits)
		bs_data.IgnoreBits = bs_data.IgnoreBits + numberOfBits
	end

	function bitstream:SetWriteOffset(offset)
		bs_data.numberOfBitsUsed = offset
	end

	function bitstream:AssertCopyData()
		if bs_data.copyData == false then
			bs_data.copyData = true

			if bs_data.numberOfBitsAllocated > 0 then
				local newdata = ffi.C.malloc(BITS_TO_BYTES( bs_data.numberOfBitsAllocated ) )

				ffi.C.memcpy(newdata, data, BITS_TO_BYTES( bs_data.numberOfBitsAllocated ))
				bs_data.data = newdata
			else bs_data = 0 end
		end
	end

	function bitstream:ReverseBytes(input, output, length)
		input = ffi.cast('BYTE*', input)
		output = ffi.cast('BYTE*', output)
		for i = 0, length do
			output[i] = input[length-i-1]
		end
	end

	return setmetatable(bitstream, {})
end

return BitStream