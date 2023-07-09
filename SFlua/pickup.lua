--[[
    Project: SF.lua <https://github.com/imring/SF.lua>
    License: MIT License
    Author: imring
]]

local sampapi = require 'sampapi'
local shared = require 'sampapi.shared'
local ffi = shared.ffi

local netgame = sampapi.require('CNetGame', true)
sampapi.require('CPickupPool', true)

local function pickuppool()
    return netgame.RefNetGame().m_pPools.m_pPickup
end

function sampGetPickupPoolPtr()
    return shared.get_pointer(pickuppool())
end
jit.off(sampGetPickupPoolPtr, true)

function sampGetPickupHandleBySampId(id)
    return pickuppool().m_handle[id]
end
jit.off(sampGetPickupHandleBySampId, true)

function sampGetPickupSampIdByHandle(handle)
    for i = 0, ffi.C.MAX_PICKUPS - 1 do
        if sampGetPickupHandleBySampId(i) == handle then
            return i
        end
    end
    return -1
end