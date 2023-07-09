--[[
    Project: SF.lua <https://github.com/imring/SF.lua>
    License: MIT License
    Author: imring
]]

local sampapi = require 'sampapi'
local shared = require 'sampapi.shared'
local ffi = shared.ffi

local netgame = sampapi.require('CNetGame', true)
sampapi.require('CLabelPool', true)

ffi.cdef[[
void *calloc(size_t nmemb, size_t size);
void *realloc(void *ptr, size_t size);
]]

local function labelpool()
    return netgame.RefNetGame().m_pPools.m_pLabel
end

function sampGetTextlabelPoolPtr()
    return shared.get_pointer(labelpool())
end
jit.off(sampGetTextlabelPoolPtr, true)

function sampCreate3dText(text, color, posX, posY, posZ, distance, ignoreWalls, playerId, vehicleId)
    for i = 0, ffi.C.MAX_TEXT_LABELS - 1 do
        if not sampIs3dTextDefined(i) then
            sampCreate3dTextEx(i, text, color, posX, posY, posZ, distance, ignoreWalls, playerId, vehicleId)
            return i
        end
    end
    return -1
end

function sampIs3dTextDefined(id)
    return labelpool().m_bNotEmpty[id] == 1
end
jit.off(sampIs3dTextDefined, true)

function sampGet3dTextInfoById(id)
    if sampIs3dTextDefined(id) then
        local obj = labelpool().m_object[id]
        return ffi.string(obj.m_pText), obj.m_color,
            obj.m_position.x, obj.m_position.y, obj.m_position.z,
            obj.m_fDrawDistance, obj.m_bBehindWalls, obj.m_nAttachedToPlayer, obj.m_nAttachedToVehicle
    end
end
jit.off(sampGet3dTextInfoById, true)

function sampSet3dTextString(id, text)
    if sampIs3dTextDefined(id) then
        local obj = labelpool().m_object[id]
        if obj.m_pText == nil then
            obj.m_pText = ffi.cast('char*', ffi.C.calloc(ffi.sizeof('char'), #text + 1))
        else
            obj.m_pText = ffi.cast('char*', ffi.C.realloc(obj.m_pText, #text + 1))
        end
        ffi.copy(obj.m_pText, text)
    end
end
jit.off(sampSet3dTextString, true)

function sampDestroy3dText(id)
    if sampIs3dTextDefined(id) then
        labelpool():Delete(id)
    end
end
jit.off(sampDestroy3dText, true)

function sampCreate3dTextEx(id, text, color, posX, posY, posZ, distance, ignoreWalls, playerId, vehicleId)
    sampDestroy3dText(id) -- if the label exists
    labelpool():Create(id, text, color, { x = posX, y = posY, z = posZ }, distance, ignoreWalls, playerId, vehicleId)
end
jit.off(sampCreate3dTextEx, true)