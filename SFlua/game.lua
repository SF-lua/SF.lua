--[[
    Project: SF.lua <https://github.com/imring/SF.lua>
    License: MIT License
    Author: imring
]]

local sampapi = require 'sampapi'
local shared = require 'sampapi.shared'
local ffi = shared.ffi

local game = sampapi.require('CGame', true)

function sampGetMiscInfoPtr()
    return shared.get_pointer(game.RefGame())
end

function sampToggleCursor(show)
    game.RefGame():SetCursorMode(show and ffi.C.CURSOR_LOCKCAM or ffi.C.CURSOR_NONE, show)
    if not show then
        game.RefGame():ProcessInputEnabling()
    end
end

function sampIsCursorActive()
    return game.RefGame().m_nCursorMode ~= ffi.C.CURSOR_NONE
end

function sampGetCursorMode()
    return game.RefGame().m_nCursorMode
end

function sampSetCursorMode(mode)
    game.RefGame().m_nCursorMode = mode
end