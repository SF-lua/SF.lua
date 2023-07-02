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

function sampIsPlayerConnected(id)
    return playerpool():IsConnected(id)
end

function sampGetPlayerNickname(id)
    return ffi.string(playerpool():GetName(id))
end

function sampSpawnPlayer()
    local localplayer = playerpool():GetLocalPlayer()
    localplayer:RequestSpawn()
    localplayer:Spawn()
end

function sampSendChat(text)
    if text:byte(1) == 47 then -- character "/"
        input.RefInput():Send(text)
    else
        local localplayer = playerpool():GetLocalPlayer()
        playerpool():GetLocalPlayer():Chat(text)
    end
end

function sampIsPlayerNpc(id)
    return sampIsPlayerConnected(id) and playerpool().m_pObject[id].m_bIsNPC == 1
end

function sampGetPlayerScore(id)
    if id == sampGetLocalPlayerId() then
        return playerpool():GetLocalPlayerScore()
    end
    return playerpool():GetScore(id)
end

function sampGetPlayerPing(id)
    if id == sampGetLocalPlayerId() then
        return playerpool():GetLocalPlayerPing()
    end
    return playerpool():GetPing(id)
end

function sampRequestClass(class)
    local localplayer = playerpool():GetLocalPlayer()
    localplayer:RequestClass(class)
end

function sampSendInteriorChange(id)
    local localplayer = playerpool():GetLocalPlayer()
    localplayer:ChangeInterior(id)
end

function sampForceUnoccupiedSyncSeatId(id, seat)
    local localplayer = playerpool():GetLocalPlayer()
    localplayer:SendUnoccupiedData(id, seat)
end

function sampGetCharHandleBySampPlayerId(id)
    if id == sampGetLocalPlayerId() then
        return true, PLAYER_PED
    elseif sampIsPlayerDefined(id) then
        local remoteplayer = playerpool():GetPlayer(id)
        local ped = remoteplayer.m_pPed.m_pGamePed
        return true, getCharPointerHandle(shared.get_pointer(ped))
    end
    return false, -1
end

function sampGetPlayerIdByCharHandle(handle)
    if handle == PLAYER_PED then
        return true, sampGetLocalPlayerId()
    end
    for i = 0, ffi.C.MAX_PLAYERS - 1 do
        local res, pped = sampGetCharHandleBySampPlayerId(i)
        if res and pped == ped then return true, i end
    end
    return false, -1
end

function sampGetPlayerArmor(id)
    if id == sampGetLocalPlayerId() then
        return getCharArmour(PLAYER_PED)
    elseif sampIsPlayerDefined(id) then
        local remoteplayer = playerpool():GetPlayer(id)
        return remoteplayer.m_fReportedArmour
    end
    return 0
end

function sampGetPlayerHealth(id)
    if id == sampGetLocalPlayerId() then
        return getCharHealth(PLAYER_PED)
    elseif sampIsPlayerDefined(id) then
        local remoteplayer = playerpool():GetPlayer(id)
        return remoteplayer.m_fReportedHealth
    end
    return 0
end

function sampIsPlayerPaused(id)
    if id == sampGetLocalPlayerId() then
        -- TODO: CMenuManager?
        return false
    elseif sampIsPlayerConnected(id) then
        local remoteplayer = playerpool():GetPlayer(id)
        return remoteplayer.m_nStatus == ffi.C.PLAYER_STATE_NONE
    end
end

function sampSetSpecialAction(action)
    local localplayer = playerpool():GetLocalPlayer()
    localplayer:SetSpecialAction(action)
end

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

function sampGetPlayerSpecialAction(id)
    if id == sampGetLocalPlayerId() then
        local localplayer = playerpool():GetLocalPlayer()
        return localplayer:GetSpecialAction()
    elseif sampIsPlayerDefined(id) then
        local remoteplayer = playerpool():GetPlayer(id)
        return remoteplayer.m_nSpecialAction
    end
    return -1
end

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

function sampSendSpawn()
    local localplayer = playerpool():GetLocalPlayer()
    localplayer:Spawn()
end

function sampGetPlayerAnimationId(id)
    if id == sampGetLocalPlayerId() then
        local localplayer = playerpool():GetLocalPlayer()
        return localplayer.m_animation.m_value
    elseif sampIsPlayerDefined(id) then
        local remoteplayer = playerpool():GetPlayer(id)
        return remoteplayer.m_animation.m_value
    end
    return -1
end

function sampSetLocalPlayerName(name)
    playerpool():SetLocalPlayerName(name)
end

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

function sampSendEnterVehicle(id, passenger)
    local localplayer = playerpool():GetLocalPlayer()
    localplayer:EnterVehicle(id, passenger)
end

function sampSendExitVehicle(id)
    local localplayer = playerpool():GetLocalPlayer()
    localplayer:ExitVehicle(id)
end

function sampIsLocalPlayerSpawned()
    -- TODO: works fine?
    local localplayer = playerpool():GetLocalPlayer()
    return localplayer.m_bClearedToSpawn == 1 and localplayer.m_bHasSpawnInfo == 1 and ( localplayer.m_bIsActive == 1 or isCharDead(PLAYER_PED) )
end

function sampGetPlayerColor(id)
    if id == sampGetLocalPlayerId() then
        local localplayer = playerpool():GetLocalPlayer()
        return localplayer:GetColorAsRGBA()
    elseif sampIsPlayerConnected(id) then
        local remoteplayer = playerpool():GetPlayer(id)
        return remoteplayer:GetColorAsRGBA()
    end
    return 0
end

function sampForceAimSync()
    local localplayer = playerpool():GetLocalPlayer()
    localplayer.m_lastAnyUpdate = 0 -- lol
    localplayer:SendAimData()
end

function sampForceOnfootSync()
    local localplayer = playerpool():GetLocalPlayer()
    localplayer.m_lastAnyUpdate = 0
    localplayer:SendOnfootData()
end

function sampForceStatsSync()
    local localplayer = playerpool():GetLocalPlayer()
    localplayer.m_lastAnyUpdate = 0
    localplayer:SendStats()
end

function sampForceTrailerSync(id)
    local localplayer = playerpool():GetLocalPlayer()
    localplayer.m_lastAnyUpdate = 0
    localplayer:SendTrailerData(id)
end

function sampForceVehicleSync(id)
    local localplayer = playerpool():GetLocalPlayer()
    localplayer.m_lastAnyUpdate = 0
    localplayer:SendIncarData(id)
end

-- New functions

function sampGetLocalPlayerId()
    return playerpool().m_localInfo.m_nId
end

function sampIsPlayerDefined(id)
    if id == sampGetLocalPlayerId() then
        local localplayer = playerpool():GetLocalPlayer()
        return localplayer ~= nil
    end

    local remoteplayer = playerpool():GetPlayer(id)
    if remoteplayer == nil then
        return false
    end
    return remoteplayer:DoesExist()
end

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
        return remoteplayer:SetColor(color)
    end
end