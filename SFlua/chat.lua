--[[
    Project: SF.lua <https://github.com/imring/SF.lua>
    License: MIT License
    Author: imring
]]

local sampapi = require 'sampapi'
local shared = require 'sampapi.shared'
local ffi = shared.ffi

local chat = sampapi.require('CChat', true)

function sampGetChatInfoPtr()
    return shared.get_pointer(dialog.RefChat())
end
jit.off(sampGetChatInfoPtr, true)

function sampAddChatMessage(text, color)
    sampAddChatMessageEx(ffi.C.ENTRY_TYPE_DEBUG, text, '', color, -1)
end

function sampGetChatDisplayMode()
    return chat.RefChat():GetMode()
end
jit.off(sampGetChatDisplayMode, true)

function sampSetChatDisplayMode(mode)
    chat.RefChat().m_nMode = id
end
jit.off(sampSetChatDisplayMode, true)

function sampGetChatString(id)
    local entry = chat.RefChat().m_entry[id]
    return ffi.string(entry.m_szText), ffi.string(entry.m_szPrefix), entry.m_textColor, entry.m_prefixColor
end
jit.off(sampGetChatString, true)

function sampSetChatString(id, text, prefix, color, pcolor)
    chat.RefChat().m_entry[id] = {
        m_szText = text,
        m_szPrefix = prefix,
        m_textColor = color,
        m_prefixColor = pcolor
    }
end
jit.off(sampSetChatString, true)

function sampIsChatVisible()
    return sampGetChatDisplayMode() ~= ffi.C.DISPLAY_MODE_OFF
end

-- New functions

function sampAddChatMessageEx(type_msg, text, prefix, color, pcolor)
    chat.RefChat():AddEntry(type_msg, text, prefix, color, pcolor)
end
jit.off(sampAddChatMessageEx, true)