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

local registered_cmds = {}

function sampGetInputInfoPtr()
    return shared.get_pointer(dialog.RefInputBox())
end
jit.off(sampGetInputInfoPtr, true)

function sampRegisterChatCommand(cmd, func)
    if input.RefInputBox():GetCommandHandler(cmd) ~= nil then
        print(('WARNING: The "%s" command is already registered.'):format(cmd))
        return
    end

    jit.off(func, true)
    local cb = ffi.cast('CMDPROC', function(args) func(ffi.string(args)) end)
    input.RefInputBox():AddCommand(cmd, cb)
    registered_cmds[cmd] = true
    return true
end
jit.off(sampRegisterChatCommand, true)

function sampUnregisterChatCommand(cmd)
    local ref = input.RefInputBox()
    for i = 0, ref.m_nCommandCount - 1 do
        if ffi.string(ref.m_szCommandName[i]) == cmd then
            local needs = ref.m_nCommandCount - i - 1
            local clear = i
            if needs > 0 then
                ffi.copy(ref.m_szCommandName[i], ref.m_szCommandName[i + 1], ffi.sizeof(ref.m_szCommandName[i]) * needs)
                ffi.copy(ref.m_commandProc + i, ref.m_commandProc + i + 1, ffi.sizeof(ref.m_commandProc[i]) * needs)
                clear = i + needs
            end
            ffi.fill(ref.m_szCommandName[clear], ffi.sizeof(ref.m_szCommandName[clear]), 0)
            ref.m_commandProc[clear] = nil
            ref.m_nCommandCount = ref.m_nCommandCount - 1
            registered_cmds[cmd] = nil
            return true
        end
    end
    return false
end
jit.off(sampUnregisterChatCommand, true)

function sampSetChatInputText(text)
    input.RefInputBox().m_pEditbox:SetText(text, false)
end
jit.off(sampSetChatInputText, true)

function sampGetChatInputText()
    return input.RefInputBox().m_pEditbox:GetText()
end
jit.off(sampGetChatInputText, true)

function sampSetChatInputEnabled(enabled)
    if enabled then
        input.RefInputBox():Open()
    else
        input.RefInputBox():Close()
    end
end
jit.off(sampSetChatInputEnabled, true)

function sampIsChatInputActive()
    return input.RefInputBox().m_bEnabled == 1
end
jit.off(sampIsChatInputActive, true)

function sampIsChatCommandDefined(cmd)
    local ref = input.RefInputBox()
    for i = 0, ffi.C.MAX_CLIENT_CMDS - 1 do
        if ffi.string(ref.m_szCommandName[i]) == cmd then
            return true
        end
    end
    return false
end
jit.off(sampIsChatCommandDefined, true)

function sampProcessChatInput(text)
    sampSetChatInputText(text)
    input.RefInputBox():ProcessInput()
end
jit.off(sampProcessChatInput, true)

-- unregister commands when unloading the script
addEventHandler('onScriptTerminate', function (s, quitGame)
    if s == script.this then
        for i in pairs(registered_cmds) do
            sampUnregisterChatCommand(i)
        end
    end
end)