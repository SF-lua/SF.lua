--[[
    Project: SF.lua <https://github.com/imring/SF.lua>
    License: MIT License
    Authors: look in file <AUTHORS>.
]]

local ffi = require("ffi")
local memory = require("memory")

require("SFlua.cdef")

local versions = {
    [0x31DF13] = { '0.3.7-R1', 'SFlua.037-r1' }
}

local currentVersion, sampModule = nil, getModuleHandle("samp.dll")

function isSampLoaded()
    if not currentVersion then
        -- Getting version taken from SAMP-API (thx fyp)
        local ntheader = sampModule + memory.getint32(sampModule + 0x3C)
        local ep = memory.getuint32(ntheader + 0x28)
        currentVersion = versions[ep]
        if not currentVersion then
            error(string.format("Unknown version of SA-MP (Entry point: 0x%08x)", ep))
        end
        require(currentVersion[2])
    end
    return sampModule > 0
end

function isSampfuncsLoaded()
    return true
end

function sampGetBase()
    return sampModule
end

function sampGetVersion()
    assert(isSampLoaded(), 'SA-MP is not loaded.')
    return currentVersion[1]
end

isSampLoaded()