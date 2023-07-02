--[[
    Project: SF.lua <https://github.com/imring/SF.lua>
    License: MIT License
    Author: imring
]]

local sampapi = require 'sampapi'
local shared = require 'sampapi.shared'
local ffi = shared.ffi

local netgame = sampapi.require('CNetGame', true)
local localplayer = sampapi.require('CLocalPlayer', true)

local AnimList_addr = {
    [ffi.C.SAMP_VERSION_037R1] = 0xF15B0,
    [ffi.C.SAMP_VERSION_037R3_1] = 0x1039D0,
    [ffi.C.SAMP_VERSION_037R5_1] = 0x1039E8,
}
local AnimList = ffi.cast('char*', sampapi.GetAddress(AnimList_addr[sampapi.GetSAMPVersion()])) -- char[1812][36]

function sampGetSampInfoPtr()
    return shared.get_pointer(netgame.RefNetGame())
end

function sampGetSampPoolsPtr()
    return shared.get_pointer(netgame.RefNetGame().m_pPools)
end

function sampGetServerSettingsPtr()
    return shared.get_pointer(netgame.RefNetGame().m_pSettings)
end

function sampGetCurrentServerName()
    return ffi.string(netgame.RefNetGame().m_szHostname)
end

function sampGetCurrentServerAddress()
    return ffi.string(netgame.RefNetGame().m_szHostAddress), netgame.RefNetGame().m_nPort
end

function sampGetGamestate()
    local convert = {
        [ffi.C.GAME_MODE_WAITCONNECT] = GAMESTATE_WAIT_CONNECT,
        [ffi.C.GAME_MODE_CONNECTING] = GAMESTATE_DISCONNECTED, -- TODO: correct?
        [ffi.C.GAME_MODE_CONNECTED] = GAMESTATE_CONNECTED,
        [ffi.C.GAME_MODE_WAITJOIN] = GAMESTATE_AWAIT_JOIN,
        [ffi.C.GAME_MODE_RESTARTING] = GAMESTATE_RESTARTING
    }
    return convert[netgame.RefNetGame().m_nGameState] or GAMESTATE_NONE
end

function sampSetGamestate(gamestate)
    local convert = {
        [GAMESTATE_WAIT_CONNECT] = ffi.C.GAME_MODE_WAITCONNECT,
        [GAMESTATE_DISCONNECTED] = ffi.C.GAME_MODE_CONNECTING, -- TODO: correct?
        [GAMESTATE_CONNECTED] = ffi.C.GAME_MODE_CONNECTED,
        [GAMESTATE_AWAIT_JOIN] = ffi.C.GAME_MODE_WAITJOIN,
        [GAMESTATE_RESTARTING] = ffi.C.GAME_MODE_RESTARTING
    }
    if convert[gamestate] then
        netgame.RefNetGame().m_nGameState = convert[gamestate]
    end
end

function sampGetAnimationNameAndFile(id)
    id = tonumber(id) or 0
    local name, file = ffi.string(AnimList + 36 * id):match('(.*):(.*)')
    return name or '', file or ''
end

function sampFindAnimationIdByNameAndFile(name, file)
    local filename = ('%s:%s'):format(name, file)
    for i = 0, 1812 - 1 do
        if ffi.string(AnimList + 36 * i) == filename then
            return i
        end
    end
    return -1
end

-- TODO: add for r3-1/r5
function sampSetSendrate(type, rate)
    local ref
    if type == ONFOOTSENDRATE then
        ref = localplayer.RefOnfootSendrate()
    elseif type == INCARSENDRATE then
        ref = localplayer.RefIncarSendrate()
    elseif type == AIMSENDRATE then
        ref = localplayer.RefFiringSendrate()
    end

    if ref then
        ref[0] = rate
    end
end