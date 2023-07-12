--[[
    Project: SF.lua <https://github.com/imring/SF.lua>
    License: MIT License
    Author: imring
]]

local ok, raklua = pcall(require, 'RakLua')
if ok then
    raklua.defineSampLuaCompatibility()
end

require 'sflua.basic'
require 'sflua.chat'
require 'sflua.deathwindow'
require 'sflua.dialog'
require 'sflua.game'
require 'sflua.gangzone'
require 'sflua.input'
require 'sflua.label'
require 'sflua.netgame'
require 'sflua.object'
require 'sflua.pickup'
require 'sflua.player'
require 'sflua.scoreboard'
require 'sflua.textdraw'
require 'sflua.vehicle'
require 'sflua.raknet'

-- TODO:
-- sampHasDialogRespond
-- sampForcePassengerSyncSeatId
-- sampForceWeaponsSync
-- sampGetRakclientFuncAddressByIndex
-- sampGetRpcCallbackByRpcId
-- sampGetRpcNodeByRpcId
-- raknetEmulRpcReceiveBitStream
-- raknetEmulPacketReceiveBitStream
-- sampSetClientCommandDescription: needed?
-- sampGetStreamedOutPlayerPos: RakLua?
-- onSendRpc
-- onSendPacket
-- onReceiveRpc
-- onReceivePacket