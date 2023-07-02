--[[
    Project: SF.lua <https://github.com/imring/SF.lua>
    License: MIT License
    Author: imring
]]

local sampapi = require 'sampapi'
local shared = require 'sampapi.shared'
local ffi = shared.ffi

require 'sflua.cdef.dxut'
local input = sampapi.require('CInput', true)

function sampGetInputInfoPtr()
    return shared.get_pointer(dialog.RefInput())
end

function sampRegisterChatCommand(cmd, func)
    sampUnregisterChatCommand(cmd)
    local cb = ffi.cast('CMDPROC', function(args) func(ffi.string(args)) end)
    jit.off(cb, true)
    input.RefInput():AddCommand(cmd, cb)
    return true
end

function sampUnregisterChatCommand(cmd)
    local ref = input.RefInput()
    for i = 0, ffi.C.MAX_CLIENT_CMDS - 1 do
        if ffi.string(ref.m_szCommandName[i]) == cmd then
            ffi.fill(ref.m_szCommandName[i], ffi.sizeof(ref.m_szCommandName[i]), 0)
            ref.m_commandProc[i] = nil
            ref.m_nCommandCount = ref.m_nCommandCount - 1
            return true
        end
    end
    return false
end

function sampSetChatInputText(text)
    input.RefInput().m_pEditbox:SetText(text)
end

function sampGetChatInputText()
    return input.RefInput().m_pEditbox:GetText()
end

function sampSetChatInputEnabled(enabled)
    if enabled then
        input.RefInput():Open()
    else
        input.RefInput():Close()
    end
end

function sampIsChatInputActive()
    return input.RefInput().m_bEnabled == 1
end

function sampIsChatCommandDefined(cmd)
    local ref = input.RefInput()
    for i = 0, ffi.C.MAX_CLIENT_CMDS - 1 do
        if ffi.string(ref.m_szCommandName[i]) == cmd then
            return true
        end
    end
    return false
end

function sampProcessChatInput(text)
    sampSetChatInputText(text)
    input.RefInput():ProcessInput()
end