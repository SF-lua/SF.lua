--[[
	Project: SAMPFUNCSLUA
	URL: https://github.com/imring/SAMPFUNCSLUA

	File: hook.lua
	License: MIT License

	Authors: FishLake Scripts <fishlake-scripts.ru> and BH Team <blast.hk>.
]]
script_name('SFL_Hook')

local ffi = require 'ffi'
local memory = require 'memory'

require 'SAMPFUNCSLUA.init'
local raknet = require 'raknet_sflua'
local BitStream = require 'SAMPFUNCSLUA.bitstream'
local kernel = require 'SAMPFUNCSLUA.kernel'

local StreamedOutInfo = ffi.new('struct SFL_StreamedOutPlayerInfo')
ffi.fill(StreamedOutInfo, ffi.sizeof(StreamedOutInfo), 0)

function EXPORTS.StreamedOutInfo(id)
	local pos = StreamedOutInfo.fPlayerPos[id]
	return StreamedOutInfo.iIsListed[id], pos[0], pos[1], pos[2]
end

local function hook_onReceivePacket(playerIndex, binaryAddress, port, length, bitSize, data, deleteData)
	if data == 0 or length == 0 then return true end
	data = ffi.cast('unsigned char*', data)

	if data[0] == 208 then -- ID_MARKERS_SYNC
		local bs = BitStream(data, length, false)
		local count = ffi.new('int[1]')
		local id = ffi.new('uint16_t[1]')
		local pos = ffi.new('short[3]')
		bs:IgnoreBits(8)
		bs:Read(count)
		for i = 1, count[0] do
			bs:Read(id)
			local active = bs:ReadBit()
			if active then
				bs:Read(pos)
				StreamedOutInfo.iIsListed[ id[0] ] = true
				StreamedOutInfo.fPlayerPos[ id[0] ][0] = pos[0]
				StreamedOutInfo.fPlayerPos[ id[0] ][1] = pos[1]
				StreamedOutInfo.fPlayerPos[ id[0] ][2] = pos[2]
			end
		end
		bs:__gc()
	end
	return true
end

function main()
	while not isSampAvailable() do wait(0) end

	raknet.initialize(sampGetSampInfoPtr() + ffi.offsetof('struct SFL_SAMP', 'pRakClientInterface'))
	raknet.setSendRPC(function(id, bitStream, priority, reliability, orderingChannel, shiftTimestamp)
		-- print('sendrpc', id, bitStream, priority, reliability, orderingChannel, shiftTimestamp)
		return true
	end)
	raknet.setSendPacket(function(bitStream, priority, reliability, orderingChannel)
		-- print('sendpacket', bitStream, priority, reliability, orderingChannel)
		return true
	end)
	raknet.setReceivePacket(function(playerIndex, binaryAddress, port, length, bitSize, data, deleteData)
		local res, err = pcall(hook_onReceivePacket, playerIndex, binaryAddress, port, length, bitSize, data, deleteData)
		if res == false then
			print('[warning] ' .. err)
			return true
		end
		return err ~= false
	end)

	wait(-1)
end

function onScriptTerminate(scr)
	if script.this == scr then
		raknet.destructor()
	end
end