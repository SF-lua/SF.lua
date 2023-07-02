--[[
    Project: SF.lua <https://github.com/imring/SF.lua>
    License: MIT License
    Author: imring
]]

local sampapi = require 'sampapi'
local shared = require 'sampapi.shared'
local ffi = shared.ffi

local scoreboard = sampapi.require('CScoreboard', true)

function sampToggleScoreboard(show)
    if show then
        scoreboard.RefScoreboard():Enable()
    else
        scoreboard.RefScoreboard():Close(true)
    end
end

function sampIsScoreboardOpen()
    return scoreboard.RefScoreboard().m_bIsEnabled == 1
end