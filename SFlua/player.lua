--[[
    Project: SF.lua <https://github.com/imring/SF.lua>
    License: MIT License
    Author: imring
]]

local sampapi = require 'sampapi'
local shared = require 'sampapi.shared'
local ffi = shared.ffi

local netgame = sampapi.require('CNetGame', true)
local input = sampapi.require('CInput', true)
sampapi.require('CPlayerPool', true)

local function playerpool()
    return netgame.RefNetGame():GetPlayerPool()
end

function sampGetPlayerPoolPtr()
    return shared.get_pointer(playerpool())
end
jit.off(sampGetPlayerPoolPtr, true)

function sampIsPlayerConnected(id)
    return playerpool():IsConnected(id)
end
jit.off(sampIsPlayerConnected, true)

function sampGetPlayerNickname(id)
    if not sampIsPlayerConnected(id) then
        return ''
    end
    netgame.RefNetGame():UpdatePlayers()
    return ffi.string(playerpool():GetName(id))
end
jit.off(sampGetPlayerNickname, true)

function sampSpawnPlayer()
    local localplayer = playerpool():GetLocalPlayer()
    localplayer:RequestSpawn()
    localplayer:Spawn()
end
jit.off(sampSpawnPlayer, true)

function sampSendChat(text)
    if text:byte(1) == 47 then -- character "/"
        input.RefInput():Send(text)
    else
        local localplayer = playerpool():GetLocalPlayer()
        playerpool():GetLocalPlayer():Chat(text)
    end
end
jit.off(sampSendChat, true)

function sampIsPlayerNpc(id)
    return sampIsPlayerConnected(id) and playerpool().m_pObject[id].m_bIsNPC == 1
end
jit.off(sampIsPlayerNpc, true)

function sampGetPlayerScore(id)
    if not sampIsPlayerConnected(id) then
        return 0
    end
    netgame.RefNetGame():UpdatePlayers()
    if id == sampGetLocalPlayerId() then
        return playerpool():GetLocalPlayerScore()
    end
    return playerpool():GetScore(id)
end
jit.off(sampGetPlayerScore, true)

function sampGetPlayerPing(id)
    if not sampIsPlayerConnected(id) then
        return 0
    end
    netgame.RefNetGame():UpdatePlayers()
    if id == sampGetLocalPlayerId() then
        return playerpool():GetLocalPlayerPing()
    end
    return playerpool():GetPing(id)
end
jit.off(sampGetPlayerPing, true)

function sampRequestClass(class)
    local localplayer = playerpool():GetLocalPlayer()
    localplayer:RequestClass(class)
end
jit.off(sampRequestClass, true)

function sampSendInteriorChange(id)
    local localplayer = playerpool():GetLocalPlayer()
    localplayer:ChangeInterior(id)
end
jit.off(sampSendInteriorChange, true)

function sampForceUnoccupiedSyncSeatId(id, seat)
    local localplayer = playerpool():GetLocalPlayer()
    localplayer:SendUnoccupiedData(id, seat)
end
jit.off(sampForceUnoccupiedSyncSeatId, true)

function sampGetCharHandleBySampPlayerId(id)
    if id == sampGetLocalPlayerId() then
        return true, PLAYER_PED
    elseif sampIsPlayerDefined(id) then
        local remoteplayer = playerpool():GetPlayer(id)
        if remoteplayer ~= nil then
            local ped = remoteplayer.m_pPed.m_pGamePed
            return true, getCharPointerHandle(shared.get_pointer(ped))
        end
    end
    return false, -1
end
jit.off(sampGetCharHandleBySampPlayerId, true)

function sampGetPlayerIdByCharHandle(handle)
    if handle == PLAYER_PED then
        return true, sampGetLocalPlayerId()
    end
    for i = 0, ffi.C.MAX_PLAYERS - 1 do
        local res, pped = sampGetCharHandleBySampPlayerId(i)
        if res and pped == handle then return true, i end
    end
    return false, -1
end
jit.off(sampGetPlayerIdByCharHandle, true)

function sampGetPlayerArmor(id)
    if id == sampGetLocalPlayerId() then
        return getCharArmour(PLAYER_PED)
    elseif sampIsPlayerDefined(id) then
        local remoteplayer = playerpool():GetPlayer(id)
        if remoteplayer ~= nil then
            return remoteplayer.m_fReportedArmour
        end
    end
    return 0
end
jit.off(sampGetPlayerArmor, true)

function sampGetPlayerHealth(id)
    if id == sampGetLocalPlayerId() then
        return getCharHealth(PLAYER_PED)
    elseif sampIsPlayerDefined(id) then
        local remoteplayer = playerpool():GetPlayer(id)
        if remoteplayer ~= nil then
            return remoteplayer.m_fReportedHealth
        end
    end
    return 0
end
jit.off(sampGetPlayerHealth, true)

function sampIsPlayerPaused(id)
    if id == sampGetLocalPlayerId() then
        -- TODO: CMenuManager?
        return false
    elseif sampIsPlayerConnected(id) then
        local remoteplayer = playerpool():GetPlayer(id)
        if remoteplayer ~= nil then
            return remoteplayer.m_nStatus == ffi.C.PLAYER_STATE_NONE
        end
    end
end
jit.off(sampIsPlayerPaused, true)

function sampSetSpecialAction(action)
    local localplayer = playerpool():GetLocalPlayer()
    localplayer:SetSpecialAction(action)
end
jit.off(sampSetSpecialAction, true)

function sampGetPlayerCount(streamed)
    if not streamed then
        return playerpool():GetCount(true)
    end

    local players = 0
    for i = 0, ffi.C.MAX_PLAYERS - 1 do
        if i ~= sampGetLocalPlayerId() then
            local res, ped = sampGetCharHandleBySampPlayerId(i)
            local bool = res and doesCharExist(ped)
            if bool then players = players + 1 end
        end
    end
    return players
end
jit.off(sampGetPlayerCount, true)

function sampGetMaxPlayerId(streamed)
    if not streamed then
        return playerpool().m_nLargestId
    end

    local mid = sampGetLocalPlayerId()
    for i = 0, ffi.C.MAX_PLAYERS - 1 do
        if i ~= sampGetLocalPlayerId() then
            local res, ped = sampGetCharHandleBySampPlayerId(i)
            local bool = res and doesCharExist(ped)
            if bool and i > mid then mid = i end
        end
    end
    return mid
end
jit.off(sampGetMaxPlayerId, true)

function sampGetPlayerSpecialAction(id)
    if id == sampGetLocalPlayerId() then
        local localplayer = playerpool():GetLocalPlayer()
        return localplayer:GetSpecialAction()
    elseif sampIsPlayerDefined(id) then
        local remoteplayer = playerpool():GetPlayer(id)
        if remoteplayer ~= nil then
            return remoteplayer.m_nSpecialAction
        end
    end
    return -1
end
jit.off(sampGetPlayerSpecialAction, true)

function sampStorePlayerOnfootData(id, data)
    local player
    if id == sampGetLocalPlayerId() then
        player = playerpool():GetLocalPlayer()
    elseif sampIsPlayerDefined(id) then
        player = playerpool():GetPlayer(id)
    end
    
    if player then
        ffi.copy(ffi.cast('void*', data), player.m_onfootData, ffi.sizeof(player.m_onfootData))
    end
end
jit.off(sampStorePlayerOnfootData, true)

function sampStorePlayerIncarData(id, data)
    local player
    if id == sampGetLocalPlayerId() then
        player = playerpool():GetLocalPlayer()
    elseif sampIsPlayerDefined(id) then
        player = playerpool():GetPlayer(id)
    end
    
    if player then
        ffi.copy(ffi.cast('void*', data), player.m_incarData, ffi.sizeof(player.m_incarData))
    end
end
jit.off(sampStorePlayerIncarData, true)

function sampStorePlayerPassengerData(id, data)
    local player
    if id == sampGetLocalPlayerId() then
        player = playerpool():GetLocalPlayer()
    elseif sampIsPlayerDefined(id) then
        player = playerpool():GetPlayer(id)
    end
    
    if player then
        ffi.copy(ffi.cast('void*', data), player.m_passengerData, ffi.sizeof(player.m_passengerData))
    end
end
jit.off(sampStorePlayerPassengerData, true)

function sampStorePlayerTrailerData(id, data)
    local player
    if id == sampGetLocalPlayerId() then
        player = playerpool():GetLocalPlayer()
    elseif sampIsPlayerDefined(id) then
        player = playerpool():GetPlayer(id)
    end
    
    if player then
        ffi.copy(ffi.cast('void*', data), player.m_trailerData, ffi.sizeof(player.m_trailerData))
    end
end
jit.off(sampStorePlayerTrailerData, true)

function sampStorePlayerAimData(id, data)
    local player
    if id == sampGetLocalPlayerId() then
        player = playerpool():GetLocalPlayer()
    elseif sampIsPlayerDefined(id) then
        player = playerpool():GetPlayer(id)
    end
    
    if player then
        ffi.copy(ffi.cast('void*', data), player.m_aimData, ffi.sizeof(player.m_aimData))
    end
end
jit.off(sampStorePlayerAimData, true)

function sampSendSpawn()
    local localplayer = playerpool():GetLocalPlayer()
    localplayer:Spawn()
end
jit.off(sampSendSpawn, true)

function sampGetPlayerAnimationId(id)
    if id == sampGetLocalPlayerId() then
        local localplayer = playerpool():GetLocalPlayer()
        return localplayer.m_animation.m_value
    elseif sampIsPlayerDefined(id) then
        local remoteplayer = playerpool():GetPlayer(id)
        if remoteplayer ~= nil then
            return remoteplayer.m_animation.m_value
        end
    end
    return -1
end
jit.off(sampGetPlayerAnimationId, true)

function sampSetLocalPlayerName(name)
    playerpool():SetLocalPlayerName(name)
end
jit.off(sampSetLocalPlayerName, true)

function sampGetPlayerStructPtr(id)
    if id == sampGetLocalPlayerId() then
        local localplayer = playerpool():GetLocalPlayer()
        return shared.get_pointer(localplayer)
    elseif sampIsPlayerConnected(id) then
        local remoteplayer = playerpool():GetPlayer(id)
        return shared.get_pointer(remoteplayer)
    end
    return 0
end
jit.off(sampGetPlayerStructPtr, true)

function sampSendEnterVehicle(id, passenger)
    local localplayer = playerpool():GetLocalPlayer()
    localplayer:EnterVehicle(id, passenger)
end
jit.off(sampSendEnterVehicle, true)

function sampSendExitVehicle(id)
    local localplayer = playerpool():GetLocalPlayer()
    localplayer:ExitVehicle(id)
end
jit.off(sampSendExitVehicle, true)

function sampIsLocalPlayerSpawned()
    -- TODO: works fine?
    local localplayer = playerpool():GetLocalPlayer()
    return localplayer.m_bClearedToSpawn == 1 and localplayer.m_bHasSpawnInfo == 1 and ( localplayer.m_bIsActive == 1 or isCharDead(PLAYER_PED) )
end
jit.off(sampIsLocalPlayerSpawned, true)

function sampGetPlayerColor(id)
    if id == sampGetLocalPlayerId() then
        local localplayer = playerpool():GetLocalPlayer()
        return localplayer:GetColorAsARGB()
    elseif sampIsPlayerConnected(id) then
        local remoteplayer = playerpool():GetPlayer(id)
        if remoteplayer ~= nil then
            return remoteplayer:GetColorAsARGB()
        end
    end
    return 0
end
jit.off(sampGetPlayerColor, true)

function sampForceAimSync()
    local localplayer = playerpool():GetLocalPlayer()
    localplayer.m_lastAnyUpdate = 0 -- lol
    localplayer:SendAimData()
end
jit.off(sampForceAimSync, true)

function sampForceOnfootSync()
    local localplayer = playerpool():GetLocalPlayer()
    localplayer.m_lastAnyUpdate = 0
    localplayer:SendOnfootData()
end
jit.off(sampForceOnfootSync, true)

function sampForceStatsSync()
    local localplayer = playerpool():GetLocalPlayer()
    localplayer.m_lastAnyUpdate = 0
    localplayer:SendStats()
end
jit.off(sampForceStatsSync, true)

function sampForceTrailerSync(id)
    local localplayer = playerpool():GetLocalPlayer()
    localplayer.m_lastAnyUpdate = 0
    localplayer:SendTrailerData(id)
end
jit.off(sampForceTrailerSync, true)

function sampForceVehicleSync(id)
    local localplayer = playerpool():GetLocalPlayer()
    localplayer.m_lastAnyUpdate = 0
    localplayer:SendIncarData(id)
end
jit.off(sampForceVehicleSync, true)

-- New functions

function sampGetLocalPlayerId()
    return playerpool().m_localInfo.m_nId
end
jit.off(sampGetLocalPlayerId, true)

function sampIsPlayerDefined(id)
    if id == sampGetLocalPlayerId() then
        local localplayer = playerpool():GetLocalPlayer()
        return localplayer ~= nil
    end

    if not sampIsPlayerConnected(id) then
        return false
    end
    local remoteplayer = playerpool():GetPlayer(id)
    if remoteplayer == nil then
        return false
    end
    return remoteplayer:DoesExist() ~= 0
end
jit.off(sampIsPlayerDefined, true)

function sampGetLocalPlayerNickname()
    return sampGetPlayerNickname(sampGetLocalPlayerId())
end

function sampGetLocalPlayerColor()
    return sampGetPlayerColor(sampGetLocalPlayerId())
end

function sampSetPlayerColor(id, color)
    if id == sampGetLocalPlayerId() then
        local localplayer = playerpool():GetLocalPlayer()
        return localplayer:SetColor(color)
    elseif sampIsPlayerConnected(id) then
        local remoteplayer = playerpool():GetPlayer(id)
        if remoteplayer ~= nil then
            return remoteplayer:SetColor(color)
        end
    end
end
jit.off(sampSetPlayerColor, true)