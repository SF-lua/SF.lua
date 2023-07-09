--[[
    Project: SF.lua <https://github.com/imring/SF.lua>
    License: MIT License
    Author: imring
]]

local sampapi = require 'sampapi'
local shared = require 'sampapi.shared'
local ffi = shared.ffi

local color = require 'sflua.color'
local netgame = sampapi.require('CNetGame', true)
sampapi.require('CTextDrawPool', true)

local function textdrawpool()
    return netgame.RefNetGame().m_pPools.m_pTextDraw
end

function sampGetTextdrawPoolPtr()
    return shared.get_pointer(textdrawpool())
end
jit.off(sampGetTextdrawPoolPtr, true)

function sampTextdrawIsExists(id)
    return textdrawpool().m_bNotEmpty[id] == 1
end
jit.off(sampTextdrawIsExists, true)

function sampTextdrawCreate(id, text, posX, posY)
    local transmit = ffi.new('STransmit[1]', { { m_fX = posX, m_fY = posY } })
    textdrawpool():Create(id, transmit, text)
end
jit.off(sampTextdrawCreate, true)

function sampTextdrawSetBoxColorAndSize(id, box, color, sizeX, sizeY)
    if sampTextdrawIsExists(id) then
        local obj = textdrawpool().m_pObject[id]
        obj.m_data.m_bBox = box
        obj.m_data.m_boxColor = color
        obj.m_data.m_fBoxSizeX = sizeX
        obj.m_data.m_fBoxSizeY = sizeY
    end
end
jit.off(sampTextdrawSetBoxColorAndSize, true)

function sampTextdrawGetString(id)
    if sampTextdrawIsExists(id) then
        local obj = textdrawpool().m_pObject[id]
        return ffi.string(obj.m_szString)
    end
end
jit.off(sampTextdrawGetString, true)

function sampTextdrawDelete(id)
    textdrawpool():Delete(id)
end
jit.off(sampTextdrawDelete, true)

function sampTextdrawGetLetterSizeAndColor(id)
    if sampTextdrawIsExists(id) then
        local obj = textdrawpool().m_pObject[id]
        return obj.m_data.m_fLetterWidth, obj.m_data.m_fLetterHeight, color.abgr_to_argb(obj.m_data.m_letterColor)
    end
end
jit.off(sampTextdrawGetLetterSizeAndColor, true)

function sampTextdrawGetPos(id)
    if sampTextdrawIsExists(id) then
        local obj = textdrawpool().m_pObject[id]
        return obj.m_data.m_fX, obj.m_data.m_fY
    end
end
jit.off(sampTextdrawGetPos, true)

function sampTextdrawGetShadowColor(id)
    if sampTextdrawIsExists(id) then
        local obj = textdrawpool().m_pObject[id]
        return obj.m_data.m_nShadow, obj.m_data.m_backgroundColor
    end
end
jit.off(sampTextdrawGetShadowColor, true)

function sampTextdrawGetOutlineColor(id)
    if sampTextdrawIsExists(id) then
        local obj = textdrawpool().m_pObject[id]
        return obj.m_data.m_nOutline, obj.m_data.m_backgroundColor
    end
end
jit.off(sampTextdrawGetOutlineColor, true)

function sampTextdrawGetStyle(id)
    if sampTextdrawIsExists(id) then
        local obj = textdrawpool().m_pObject[id]
        return obj.m_data.m_nStyle
    end
end
jit.off(sampTextdrawGetStyle, true)

function sampTextdrawGetProportional(id)
    if sampTextdrawIsExists(id) then
        local obj = textdrawpool().m_pObject[id]
        return obj.m_data.m_nProportional
    end
end
jit.off(sampTextdrawGetProportional, true)

function sampTextdrawGetAlign(id)
    if sampTextdrawIsExists(id) then
        local obj = textdrawpool().m_pObject[id]
        if obj.m_data.m_bLeft == 1 then
            return 1
        elseif obj.m_data.m_bCenter == 1 then
            return 2
        elseif obj.m_data.m_bRight == 1 then
            return 3
        else
            return 0
        end
    end
end
jit.off(sampTextdrawGetAlign, true)

function sampTextdrawGetBoxEnabledColorAndSize(id)
    if sampTextdrawIsExists(id) then
        local obj = textdrawpool().m_pObject[id]
        return obj.m_data.m_bBox, color.abgr_to_argb(obj.m_data.m_boxColor),
            obj.m_data.m_fBoxSizeX, obj.m_data.m_fBoxSizeY
    end
end
jit.off(sampTextdrawGetBoxEnabledColorAndSize, true)

function sampTextdrawGetModelRotationZoomVehColor(id)
    if sampTextdrawIsExists(id) then
        local obj = textdrawpool().m_pObject[id]
        return obj.m_data.m_nModel,
            obj.m_data.m_rotation.x, obj.m_data.m_rotation.y, obj.m_data.m_rotation.z,
            obj.m_data.m_fZoom, obj.m_data.m_aColor[1], obj.m_data.m_aColor[2]
    end
end
jit.off(sampTextdrawGetModelRotationZoomVehColor, true)

function sampTextdrawSetLetterSizeAndColor(id, letSizeX, letSizeY, color)
    if sampTextdrawIsExists(id) then
        local obj = textdrawpool().m_pObject[id]
        obj.m_data.m_fLetterWidth = letSizeX
        obj.m_data.m_fLetterHeight = letSizeY
        obj.m_data.m_letterColor = color
    end
end
jit.off(sampTextdrawSetLetterSizeAndColor, true)

function sampTextdrawSetPos(id, posX, posY)
    if sampTextdrawIsExists(id) then
        local obj = textdrawpool().m_pObject[id]
        obj.m_data.m_fX = posX
        obj.m_data.m_fY = posY
    end
end
jit.off(sampTextdrawSetPos, true)

function sampTextdrawSetString(id, str)
    if sampTextdrawIsExists(id) then
        local obj = textdrawpool().m_pObject[id]
        obj.m_szString = str
    end
end
jit.off(sampTextdrawSetString, true)

function sampTextdrawSetModelRotationZoomVehColor(id, model, rotX, rotY, rotZ, zoom, clr1, clr2)
    if sampTextdrawIsExists(id) then
        local obj = textdrawpool().m_pObject[id]
        obj.m_data.m_nModel = model
        obj.m_data.m_rotation = { x = rotX, y = rotY, z = rotZ }
        obj.m_data.m_fZoom = zoom
        obj.m_data.sColor = { clr1, clr2 }
    end
end
jit.off(sampTextdrawSetModelRotationZoomVehColor, true)

function sampTextdrawSetOutlineColor(id, outline, color)
    if sampTextdrawIsExists(id) then
        local obj = textdrawpool().m_pObject[id]
        obj.m_data.m_nOutline = outline
        obj.m_data.m_backgroundColor = color
    end
end
jit.off(sampTextdrawSetOutlineColor, true)

function sampTextdrawSetShadow(id, shadow, color)
    if sampTextdrawIsExists(id) then
        local obj = textdrawpool().m_pObject[id]
        obj.m_data.m_nShadow = shadow
        obj.m_data.m_backgroundColor = color
    end
end
jit.off(sampTextdrawSetShadow, true)

function sampTextdrawSetStyle(id, style)
    if sampTextdrawIsExists(id) then
        local obj = textdrawpool().m_pObject[id]
        obj.m_data.m_nStyle = style
    end
end
jit.off(sampTextdrawSetStyle, true)

function sampTextdrawSetProportional(id, proportional)
    if sampTextdrawIsExists(id) then
        local obj = textdrawpool().m_pObject[id]
        obj.m_data.m_nProportional = proportional
    end
end
jit.off(sampTextdrawSetProportional, true)

function sampTextdrawSetAlign(id, align)
    if sampTextdrawIsExists(id) then
        local obj = textdrawpool().m_pObject[id]
        obj.m_data.m_bLeft = 0
        obj.m_data.m_bCenter = 0
        obj.m_data.m_bRight = 0
        if align == 1 then
            obj.m_data.m_bLeft = 1
        elseif align == 2 then
            obj.m_data.m_bCenter = 1
        elseif align == 3 then
            obj.m_data.m_bRight = 1
        end
    end
end
jit.off(sampTextdrawSetAlign, true)