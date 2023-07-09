--[[
    Project: SF.lua <https://github.com/imring/SF.lua>
    License: MIT License
    Author: imring
]]

local sampapi = require 'sampapi'
local shared = require 'sampapi.shared'
local ffi = shared.ffi

local deathwindow = sampapi.require('CDeathWindow', true)

function sampGetKillInfoPtr()
    return shared.get_pointer(deathwindow.RefDeathWindow())
end
jit.off(sampGetKillInfoPtr, true)

-- New functions

function sampAddDeathMessage(killer, killed, clkiller, clkilled, reason)
    deathwindow.RefDeathWindow():AddMessage(killer, killed, clkiller, clkilled, reason)
end
jit.off(sampAddDeathMessage, true)