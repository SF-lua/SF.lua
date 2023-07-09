--[[
    Project: SF.lua <https://github.com/imring/SF.lua>
    License: MIT License
    Author: imring
]]

local sampapi = require 'sampapi'
local shared = require 'sampapi.shared'
local ffi = shared.ffi

local netgame = sampapi.require('CNetGame', true)
sampapi.require('CObjectPool', true)

local function objectpool()
    return netgame.RefNetGame():GetObjectPool()
end

function sampGetObjectPoolPtr()
    return shared.get_pointer(objectpool())
end
jit.off(sampGetObjectPoolPtr, true)

function sampGetObjectHandleBySampId(id)
    if objectpool().m_bNotEmpty[id] == 1 then
        local obj = objectpool():Get(id)
        return obj.__parent.m_handle
    end
    return -1
end
jit.off(sampGetObjectHandleBySampId, true)

function sampGetObjectSampIdByHandle(object)
    for i = 0, ffi.C.MAX_OBJECTS - 1 do
        local res, handle = sampGetObjectHandleBySampId(i)
        if res and handle == object then return true, i end
    end
    return false, -1
end