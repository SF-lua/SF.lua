--[[
    Project: SF.lua <https://github.com/imring/SF.lua>
    License: MIT License
    Author: imring
]]

local sampapi = require 'sampapi'
local shared = require 'sampapi.shared'
local ffi = shared.ffi

local netgame = sampapi.require('CNetGame', true)
sampapi.require('CGangZonePool', true)

local function gangzonepool()
    return netgame.RefNetGame().m_pPools.m_pGangZone
end

function sampGetGangzonePoolPtr()
    return shared.get_pointer(gangzonepool())
end
jit.off(sampGetGangzonePoolPtr, true)