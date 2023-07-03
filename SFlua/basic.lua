--[[
    Project: SF.lua <https://github.com/imring/SF.lua>
    License: MIT License
    Author: imring
]]

local ffi = require 'ffi'
local sampapi = require 'sampapi'
local netgame = sampapi.require('CNetGame', true)

require 'sampfuncs'

function sampGetBase()
    return sampapi.GetBase()
end

function sampGetVersion()
    return sampapi.GetSAMPVersion()
end

function isSampLoaded()
    return sampapi.GetBase() ~= 0
end

function isSampfuncsLuaLoaded()
    return sampapi.GetSAMPVersion() ~= ffi.C.SAMP_VERSION_UNKNOWN
end

function isSampAvailable()
    return isSampLoaded() and netgame.RefNetGame() ~= nil
end

isSampfuncsLoaded = isSampfuncsLuaLoaded

if not isSampfuncsConsoleActive then
    function isSampfuncsConsoleActive() return false end
end