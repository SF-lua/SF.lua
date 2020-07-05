--[[
    Project: SF.lua <https://github.com/imring/SF.lua>
    License: GNU General Public License v3.0
    Authors: look in file <AUTHORS>.
]]

local memory = require 'memory'
local ffi = require 'ffi'
local bit = require 'bit'

require 'SFlua.037-r1.cdef'
local add = require 'SFlua.addition'
local bs = require 'SFlua.bitstream'

local samp_C = {
    -- CNetGame
    sendGiveDmg = ffi.cast('void(__stdcall *)(int nId, float fDamage, int nWeapon, int nBodyPart)', sampGetBase() + 0x6770),
    sendTakeDmg = ffi.cast('void(__stdcall *)(int nId, float fDamage, int nWeapon, int nBodyPart)', sampGetBase() + 0x6660),
    sendReqSpwn = ffi.cast('void(__cdecl *)()', sampGetBase() + 0x3A20),

    -- CDialog
    showDialog = ffi.cast('void(__thiscall*)(SFL_Dialog *this, int nId, int nType, const char *szCaption, const char *szText, const char *szLeftButton, const char *szRightButton, BOOL bServerside)', sampGetBase() + 0x6B9C0),
    closeDialog = ffi.cast('void(__thiscall *)(SFL_Dialog *this, char nProcessButton)', sampGetBase() + 0x6C040),

    -- DXUT
    getControl = ffi.cast('void*(__thiscall *)(struct CDXUTDialog *this, int ID, unsigned int nControlType)', sampGetBase() + 0x82C50), -- CDXUTControl* GetControl( int ID, UINT nControlType );
    getEditboxText = ffi.cast('const char*(__thiscall *)(struct CDXUTIMEEditBox *this)', sampGetBase() + 0x81030),
    setEditboxText = ffi.cast('void(__thiscall *)(struct CDXUTIMEEditBox *this, const char* szText, bool bSelected)', sampGetBase() + 0x80F60),

    -- CGame
    setCursorMode = ffi.cast('void (__thiscall*)(SFL_Game *this, int nMode, BOOL bImmediatelyHideCursor)', sampGetBase() + 0x9BD30),
    cursorUnlockActorCam = ffi.cast('void (__thiscall*)(void* this)', sampGetBase() + 0x9BC10),

    -- stPlayerPool
    reqSpawn = ffi.cast('void(__thiscall*)(void* this)', sampGetBase() + 0x3EC0),
    spawn = ffi.cast('void(__thiscall*)(void* this)', sampGetBase() + 0x3AD0),
    say = ffi.cast('void(__thiscall *)(void* this, PCHAR message)', sampGetBase() + 0x57F0),
    reqClass = ffi.cast('void(__thiscall *)(void* this, int classId)', sampGetBase() + 0x56A0),
    sendInt = ffi.cast('void (__thiscall *)(void* this, BYTE interiorID)', sampGetBase() + 0x5740),
    forceUnocSync = ffi.cast('void (__thiscall *)(void* this, WORD id, BYTE seat)', sampGetBase() + 0x4B30),
    setAction = ffi.cast('void( __thiscall*)(void* this, BYTE specialActionId)', sampGetBase() + 0x30C0),
    setName = ffi.cast('void(__thiscall *)(int this, const char *name, int len)', sampGetBase() + 0xB290),
    sendEnterVehicle = ffi.cast('void (__thiscall*)(void* this, int id, bool passenger)', sampGetBase() + 0x58C0),
    sendExitVehicle = ffi.cast('void (__thiscall*)(void* this, int id)', sampGetBase() + 0x59E0),

    -- stInputInfo
    sendCMD = ffi.cast('void(__thiscall *)(void* this, PCHAR message)', sampGetBase() + 0x65C60),
    regCMD = ffi.cast('void(__thiscall *)(void* this, PCHAR command, CMDPROC function)', sampGetBase() + 0x65AD0),
    enableInput = ffi.cast('void(__thiscall *)(void* this)', sampGetBase() + 0x6AD30),
    disableInput = ffi.cast('void(__thiscall *)(void* this)', sampGetBase() + 0x658E0),

    -- stTextdrawPool
    createTextDraw = ffi.cast('SFL_TextDraw*(__thiscall *)(SFL_TextDrawPool *this, ID nId, SFL_TextDrawTransmit *pTransmit, const char* szText)', sampGetBase() + 0x1AE20),
    deleteTextDraw = ffi.cast('void(__thiscall *)(void* this, WORD id)', sampGetBase() + 0x1AD00),

    -- stScoreboardInfo
    enableScoreboard = ffi.cast('void (__thiscall *)(void *this)', sampGetBase() + 0x6AD30),
    disableScoreboard = ffi.cast('void (__thiscall *)(void* this, bool disableCursor)', sampGetBase() + 0x658E0),

    -- stTextLabelPool
    createTextLabel = ffi.cast('int (__thiscall *)(void* this, WORD id, PCHAR text, DWORD color, float x, float y, float z, float dist, bool ignoreWalls, WORD attachPlayerId, WORD attachCarId)', sampGetBase() + 0x11C0),
    deleteTextLabel = ffi.cast('void(__thiscall *)(void* this, WORD id)', sampGetBase() + 0x12D0),

    -- stChatInfo
    addMessage = ffi.cast('void(__thiscall *)(void* this, int Type, PCSTR szString, PCSTR szPrefix, DWORD TextColor, DWORD PrefixColor)', sampGetBase() + 0x64010),

    -- stKillInfo
    sendDeathMessage = ffi.cast('void(__thiscall*)(void *this, PCHAR killer, PCHAR killed, DWORD clKiller, DWORD clKilled, BYTE reason)', sampGetBase() + 0x66930),

    -- BitStream
    readDecodeString = ffi.cast('void (__thiscall*)(void* this, char* buf, size_t size_buf, SFL_BitStream* bs, int unk)', sampGetBase() + 0x507E0),
    writeEncodeString = ffi.cast('void (__thiscall*)(void* this, const char* str, size_t size_str, SFL_BitStream* bs, int unk)', sampGetBase() + 0x506B0)
}

local function check_samp_loaded()
    assert(isSampLoaded(), 'SA-MP is not loaded.')
end

local function check_samp_available()
    assert(isSampAvailable(), 'SA-MP is not available.')
end

--- Standart functions

-- Pointers to structures

function sampGetSampInfoPtr() check_samp_loaded()
    return memory.getuint32(sampGetBase() + 0x21A0F8)
end

function sampGetDialogInfoPtr() check_samp_loaded()
    return memory.getuint32(sampGetBase() + 0x21A0B8)
end

function sampGetMiscInfoPtr() check_samp_loaded()
    return memory.getuint32(sampGetBase() + 0x21A10C)
end

function sampGetInputInfoPtr() check_samp_loaded()
    return memory.getuint32(sampGetBase() + 0x21A0E8)
end

function sampGetChatInfoPtr() check_samp_loaded()
    return memory.getuint32(sampGetBase() + 0x21A0E4)
end

function sampGetKillInfoPtr() check_samp_loaded()
    return memory.getuint32(sampGetBase() + 0x21A0EC)
end

function sampGetSampPoolsPtr() check_samp_available()
    return add.GET_POINTER(samp_C.pools)
end

function sampGetServerSettingsPtr() check_samp_available()
    return add.GET_POINTER(samp_C.samp.m_pSettings)
end

function sampGetTextdrawPoolPtr() check_samp_available()
    return add.GET_POINTER(samp_C.textdraw)
end

function sampGetObjectPoolPtr() check_samp_available()
    return add.GET_POINTER(samp_C.object)
end

function sampGetGangzonePoolPtr() check_samp_available()
    return add.GET_POINTER(samp_C.gangzone)
end

function sampGetTextlabelPoolPtr() check_samp_available()
    return add.GET_POINTER(samp_C.text3d)
end

function sampGetPlayerPoolPtr() check_samp_available()
    return add.GET_POINTER(samp_C.player)
end

function sampGetVehiclePoolPtr() check_samp_available()
    return add.GET_POINTER(samp_C.car)
end

function sampGetPickupPoolPtr() check_samp_available()
    return add.GET_POINTER(samp_C.pickup)
end

function sampGetRakclientInterface() check_samp_available()
    return add.GET_POINTER(samp_C.samp.pRakClientInterface)
end

local availables = {
    { 'sampGetSampInfoPtr', 'samp', 'NetGame' },
    { 'sampGetDialogInfoPtr', 'dialog', 'Dialog' },
    { 'sampGetMiscInfoPtr', 'misc', 'Game' },
    { 'sampGetInputInfoPtr', 'input', 'Input' },
    { 'sampGetChatInfoPtr', 'chat', 'Chat' },
    { 'sampGetKillInfoPtr', 'killinfo', 'DeathWindow' },
    { 'sampGetScoreboardInfoPtr', 'scoreboard', 'Scoreboard' }
}

function isSampAvailable() check_samp_loaded()
    local addr, result = 0, true
    for i = 1, #availables do
        local ptr = availables[i]
        addr = _G[ ptr[1] ]()
        result = result and addr > 0
        if result then
            samp_C[ ptr[2] ] = ffi.cast('struct SFL_' .. ptr[3] .. '*', addr)
        else
            return result
        end
    end
    
    local anim_list = ffi.new('char[1811][36]')
    ffi.copy(anim_list, ffi.cast('void*', sampGetBase() + 0xF15B0), ffi.sizeof(anim_list))
    samp_C.color_table = ffi.cast('DWORD*', sampGetBase() + 0x216378)
    samp_C.anim_list = anim_list

    samp_C.pools = samp_C.samp.m_pPools
    samp_C.player = samp_C.pools.m_pPlayer
    samp_C.textdraw = samp_C.pools.m_pTextdraw
    samp_C.object = samp_C.pools.m_pObject
    samp_C.gangzone = samp_C.pools.m_pGangzone
    samp_C.text3d = samp_C.pools.m_pLabel
    samp_C.car = samp_C.pools.m_pVehicle
    samp_C.pickup = samp_C.pools.m_pPickup

    samp_C.orig_rakclient = samp_C.samp.m_pRakClient

    return result
end

-- CNetGame

function sampGetCurrentServerName() check_samp_available()
    return ffi.string(samp_C.samp.m_szHostname)
end

function sampGetCurrentServerAddress() check_samp_available()
    return ffi.string(samp_C.samp.m_szHostAddress), samp_C.samp.m_nPort
end

local game_states = {
    [0] = GAMESTATE_NONE,
    [9] = GAMESTATE_WAIT_CONNECT,
    [15] = GAMESTATE_AWAIT_JOIN,
    [14] = GAMESTATE_CONNECTED,
    [18] = GAMESTATE_RESTARTING,
    [13] = GAMESTATE_DISCONNECTED
}

function sampGetGamestate() check_samp_available()
    return game_states[samp_C.samp.m_nGameState]
end

function sampSetGamestate(gamestate) check_samp_available()
    gamestate = tonumber(gamestate) or 0
    for i = 0, 13 do -- pairs bad
        if game_states[i] == gamestate then
            samp_C.samp.m_nGameState = i
            break
        end
    end
end

function sampSendGiveDamage(id, damage, weapon, bodypart) check_samp_available()
    samp_C.sendGiveDmg(id, damage, weapon, bodypart)
end

function sampSendTakeDamage(id, damage, weapon, bodypart) check_samp_available()
    samp_C.sendTakeDmg(id, damage, weapon, bodypart)
end

function sampSendRequestSpawn() check_samp_available()
    samp_C.sendReqSpwn()
end

function sampSetSendrate(type, rate) check_samp_available()
    type = tonumber(type) or 0
    rate = tonumber(rate) or 0
    local addrs = { 0xEC0A8, 0xEC0AC, 0xEC0B0 }
    if addrs[type] then
        memory.setuint32(sampGetBase() + addrs[type], rate, true)
    end
end

function sampGetAnimationNameAndFile(id) check_samp_available()
    id = tonumber(id) or 0
    local name, file = ffi.string(samp_C.anim_list[id]):match('(.*):(.*)')
    return name or '', file or ''
end

function sampFindAnimationIdByNameAndFile(file, name) check_samp_available()
    for i = 0, ffi.sizeof(samp_C.anim_list) / 36 - 1 do
        local n, f = sampGetAnimationNameAndFile(i)
        if n == name and f == file then return i end
    end
    return -1
end

-- CDialog

function sampIsDialogActive() check_samp_available()
    return samp_C.dialog.m_bIsActive == 1
end

function sampGetDialogCaption() check_samp_available()
    return ffi.string(samp_C.dialog.m_szCaption)
end

function sampGetCurrentDialogId() check_samp_available()
    return samp_C.dialog.m_nId
end

function sampGetDialogText() check_samp_available()
    return ffi.string(samp_C.dialog.m_szText)
end

function sampGetCurrentDialogType() check_samp_available()
    return samp_C.dialog.m_nType
end

function sampShowDialog(id, caption, text, button1, button2, style) check_samp_available()
    samp_C.showDialog(samp_C.dialog, id, style, tostring(caption), tostring(text), tostring(button1), tostring(button2), false)
end

function sampGetCurrentDialogListItem() check_samp_available()
    local list = add.GET_POINTER(samp_C.dialog.m_pListbox)
    return memory.getint32(list + 0x143 --[[m_nSelected]])
end

function sampSetCurrentDialogListItem(number) check_samp_available()
    local list = add.GET_POINTER(samp_C.dialog.m_pListbox)
    return memory.setint32(list + 0x143 --[[m_nSelected]], tonumber(number) or 0)
end

function sampCloseCurrentDialogWithButton(button) check_samp_available()
    samp_C.closeDialog(samp_C.dialog, button)
end

function sampGetCurrentDialogEditboxText() check_samp_available()
    local char = samp_C.getEditboxText(samp_C.dialog.m_pEditbox)
    return ffi.string(char)
end

function sampSetCurrentDialogEditboxText(text) check_samp_available()
    samp_C.setEditboxText(samp_C.dialog.m_pEditbox, tostring(text), false)
end

function sampIsDialogClientside() check_samp_available()
    return samp_C.dialog.m_bServerside ~= 0
end

function sampSetDialogClientside(client) check_samp_available()
    samp_C.dialog.m_bServerside = client and 0 or 1
end

function sampGetListboxItemsCount() check_samp_available()
    local list = add.GET_POINTER(samp_C.dialog.m_pListbox)
    return memory.getint32(list + 0x150)
end

function sampGetListboxItemText(list) check_samp_available()
    list = tonumber(list) or 0
    if list >= 0 and sampGetListboxItemsCount() - 1 >= list then
        local data = ffi.cast('struct DXUTComboBoxItem**', memory.getuint32(add.GET_POINTER(samp_C.dialog.m_pListbox) + 0x14C))
        return ffi.string(data[list].strText)
    end
    return ''
end


-- CGame

function sampToggleCursor(show) check_samp_available()
    samp_C.setCursorMode(samp_C.misc, show and CMODE_LOCKCAM or CMODE_DISABLED, show)
    if not show then samp_C.cursorUnlockActorCam(samp_C.misc) end
end

function sampIsCursorActive() check_samp_available()
    return samp_C.misc.m_nCursorMode ~= CMODE_DISABLED
end

function sampGetCursorMode() check_samp_available()
    return samp_C.misc.m_nCursorMode
end

function sampSetCursorMode(mode) check_samp_available()
    samp_C.misc.m_nCursorMode = tonumber(mode) or 0
end

-- stPlayerPool

function sampIsPlayerConnected(id) check_samp_available()
    id = tonumber(id) or 0
    if id >= 0 and id < MAX_PLAYERS then
        return samp_C.player.m_bNotEmpty[id] == 1 or sampGetLocalPlayerId() == id
    end
    return false
end

function sampGetPlayerNickname(id) check_samp_available()
    local point
    if sampGetLocalPlayerId() == id then point = samp_C.player.m_localInfo.m_szName
    elseif sampIsPlayerConnected(id) then point = samp_C.player.m_pObject[id].m_szNick end
    return point and ffi.string(point.str) or ''
end

function sampSpawnPlayer() check_samp_available()
    samp_C.reqSpawn(samp_C.player.pLocalPlayer)
    samp_C.spawn(samp_C.player.pLocalPlayer)
end

function sampSendChat(msg) check_samp_available()
    local char = ffi.cast('PCHAR', tostring(msg))
    if char[0] == 47 then -- character "/"
        samp_C.sendCMD(samp_C.input, char)
    else
        samp_C.say(samp_C.player.pLocalPlayer, char)
    end
end

function sampIsPlayerNpc(id) check_samp_available()
    id = tonumber(id) or 0
    return sampIsPlayerConnected(id) and samp_C.player.m_pObject[id].m_bIsNPC == 1
end

function sampGetPlayerScore(id) check_samp_available()
    id = tonumber(id) or 0
    local score = 0
    if sampGetLocalPlayerId() == id then score = samp_C.player.m_localInfo.m_nScore
    elseif sampIsPlayerConnected(id) then score = samp_C.player.m_pObject[id].m_nScore end
    return score
end

function sampGetPlayerPing(id) check_samp_available()
    id = tonumber(id) or 0
    local ping = 0
    if sampGetLocalPlayerId() == id then ping = samp_C.player.m_localInfo.m_nPing
    elseif sampIsPlayerConnected(id) then ping = samp_C.player.m_pObject[id].m_nPing end
    return ping
end

function sampRequestClass(class) check_samp_available()
    class = tonumber(class) or 0
    samp_C.reqClass(samp_C.player.pLocalPlayer, class)
end

function sampGetPlayerColor(id) check_samp_available()
    id = tonumber(id) or 0
    if sampIsPlayerConnected(id) or sampGetLocalPlayerId() == id then
        return add.convertRGBAToARGB(samp_C.color_table[id])
    end
end

function sampSendInteriorChange(id) check_samp_available()
    id = tonumber(id) or 0
    samp_C.sendInt(samp_C.player.pLocalPlayer, id)
end

function sampForceUnoccupiedSyncSeatId(id, seat) check_samp_available()
    id = tonumber(id) or 0
    seat = tonumber(seat) or 0
    samp_C.forceUnocSync(samp_C.player.pLocalPlayer, id, seat)
end

function sampGetCharHandleBySampPlayerId(id) check_samp_available()
    id = tonumber(id) or 0
    if id == sampGetLocalPlayerId() then return true, PLAYER_PED
    elseif sampIsPlayerDefined(id) then
        return true, getCharPointerHandle(add.GET_POINTER(samp_C.player.m_pObject[id].m_pPlayer.m_pPed.m_pGamePed))
    end
    return false, -1
end

function sampGetPlayerIdByCharHandle(ped) check_samp_available()
    ped = tonumber(ped) or 0
    if ped == PLAYER_PED then return true, sampGetLocalPlayerId() end
    for i = 0, MAX_PLAYERS - 1 do
        local res, pped = sampGetCharHandleBySampPlayerId(i)
        if res and pped == ped then return true, i end
    end
    return false, -1
end

function sampGetPlayerArmor(id) check_samp_available()
    id = tonumber(id) or 0
    if sampIsPlayerDefined(id) then
        if id == sampGetLocalPlayerId() then return getCharArmour(PLAYER_PED) end
        return samp_C.player.m_pObject[id].m_pPlayer.m_fReportedArmour
    end
    return 0
end

function sampGetPlayerHealth(id) check_samp_available()
    id = tonumber(id) or 0
    if sampIsPlayerDefined(id) then
        if id == sampGetLocalPlayerId() then return getCharHealth(PLAYER_PED) end
        return samp_C.player.m_pObject[id].m_pPlayer.m_fReportedHealth
    end
    return 0
end

function sampSetSpecialAction(action) check_samp_available()
    action = tonumber(action) or 0
    if sampIsPlayerDefined(sampGetLocalPlayerId()) then
        samp_C.setAction(samp_C.player.pLocalPlayer, action)
    end
end

function sampGetPlayerCount(streamed) check_samp_available()
    if not streamed then return samp_C.scoreboard.m_nPlayerCount - 1 end
    local players = 0
    for i = 0, MAX_PLAYERS - 1 do
        if i ~= sampGetLocalPlayerId() then
            local bool = false
            local res, ped = sampGetCharHandleBySampPlayerId(i)
            bool = res and doesCharExist(ped)
            if bool then players = players + 1 end
        end
    end
    return players
end

function sampGetMaxPlayerId(streamed) check_samp_available()
    local mid = sampGetLocalPlayerId()
    for i = 0, MAX_PLAYERS - 1 do
        if i ~= sampGetLocalPlayerId() then
            local bool = false
            if streamed then
                local res, ped = sampGetCharHandleBySampPlayerId(i)
                bool = res and doesCharExist(ped)
            else bool = sampIsPlayerConnected(i) end
            if bool and i > mid then mid = i end
        end
    end
    return mid
end

function sampGetPlayerSpecialAction(id) check_samp_available()
    id = tonumber(id) or 0
    if sampIsPlayerConnected(id) then return samp_C.player.m_pObject[id].m_pPlayer.m_nSpecialAction end
    return -1
end

function sampStorePlayerOnfootData(id, data) check_samp_available()
    id = tonumber(id) or 0
    data = tonumber(data) or 0
    local struct
    if id == sampGetLocalPlayerId() then struct = samp_C.player.pLocalPlayer.m_onfootData
    elseif sampIsPlayerDefined(id) then struct = samp_C.player.m_pObject[id].m_pPlayer.m_onfootData end
    if struct then memory.copy(data, add.GET_POINTER(struct), ffi.sizeof('SFL_OnfootData')) end
end

function sampIsPlayerPaused(id) check_samp_available()
    id = tonumber(id) or 0
    if id == sampGetLocalPlayerId() then return false end
    if sampIsPlayerConnected(id) then return samp_C.player.m_pObject[id].m_pPlayer.m_nStatus == 0 end
end

function sampStorePlayerIncarData(id, data) check_samp_available()
    id = tonumber(id) or 0
    data = tonumber(data) or 0
    local struct
    if id == sampGetLocalPlayerId() then struct = samp_C.player.pLocalPlayer.m_incarData
    elseif sampIsPlayerDefined(id) then struct = samp_C.player.m_pObject[id].m_pPlayer.m_incarData end
    if struct then memory.copy(data, add.GET_POINTER(struct), ffi.sizeof('SFL_IncarData')) end
end

function sampStorePlayerPassengerData(id, data) check_samp_available()
    id = tonumber(id) or 0
    data = tonumber(data) or 0
    local struct
    if id == sampGetLocalPlayerId() then struct = samp_C.player.pLocalPlayer.m_passengerData
    elseif sampIsPlayerDefined(id) then struct = samp_C.player.m_pObject[id].m_pPlayer.m_passengerData end
    if struct then memory.copy(data, add.GET_POINTER(struct), ffi.sizeof('SFL_PassengerData')) end
end

function sampStorePlayerTrailerData(id, data) check_samp_available()
    id = tonumber(id) or 0
    data = tonumber(data) or 0
    local struct
    if id == sampGetLocalPlayerId() then struct = samp_C.player.pLocalPlayer.m_trailerData
    elseif sampIsPlayerDefined(id) then struct = samp_C.player.m_pObject[id].m_pPlayer.m_trailerData end
    if struct then memory.copy(data, add.GET_POINTER(struct), ffi.sizeof('SFL_TrailerData')) end
end

function sampStorePlayerAimData(id, data) check_samp_available()
    id = tonumber(id) or 0
    data = tonumber(data) or 0
    local struct
    if id == sampGetLocalPlayerId() then struct = samp_C.player.pLocalPlayer.m_aimData
    elseif sampIsPlayerDefined(id) then struct = samp_C.player.m_pObject[id].m_pPlayer.m_aimData end
    if struct then memory.copy(data, add.GET_POINTER(struct), ffi.sizeof('SFL_AimData')) end
end

function sampSendSpawn() check_samp_available()
    samp_C.spawn(samp_C.player.pLocalPlayer)
end

function sampGetPlayerAnimationId(id) check_samp_available()
    id = tonumber(id) or 0
    if id == sampGetLocalPlayerId() then return samp_C.player.pLocalPlayer.m_animation.m_nId end
    if sampIsPlayerConnected(id) then return samp_C.player.m_pObject[id].m_pPlayer.m_onfootData.m_animation.m_nId end
end

function sampSetLocalPlayerName(name) check_samp_available()
    local name = tostring(name)
    assert(#name <= MAX_PLAYER_NAME, 'Limit name - '..MAX_PLAYER_NAME..'.')
    samp_C.setName(add.GET_POINTER(samp_C.player) + ffi.offsetof('struct stPlayerPool', '__align'), name, #name)
end

function sampGetPlayerStructPtr(id) check_samp_available()
    id = tonumber(id) or 0
    if id == sampGetLocalPlayerId() then return add.GET_POINTER(samp_C.player.pLocalPlayer) end
    if sampIsPlayerConnected(id) then
        return add.GET_POINTER(samp_C.player.m_pObject[id])
    end
end

function sampSendEnterVehicle(id, passenger) check_samp_available()
    samp_C.sendEnterVehicle(samp_C.player.pLocalPlayer, id, passenger)
end

function sampSendExitVehicle(id) check_samp_available()
    samp_C.sendExitVehicle(samp_C.player.pLocalPlayer, id)
end

function sampIsLocalPlayerSpawned() check_samp_available()
    local local_player = samp_C.player.pLocalPlayer
    return local_player.m_bClearedToSpawn == 1 and local_player.m_bHasSpawnInfo == 1 and ( local_player.m_bIsActive == 1 or isCharDead(PLAYER_PED) )
end

-- stInputInfo

function sampUnregisterChatCommand(name) check_samp_available()
    for i = 0, MAX_CLIENTCMDS - 1 do
        if ffi.string(samp_C.input.m_szCommandName[i]) == tostring(name) then
            samp_C.input.m_szCommandName[i] = '\0'
            samp_C.input.m_pCommandProc[i] = nil
            samp_C.input.m_nCommandCount = samp_C.input.m_nCommandCount - 1
            return true
        end
    end
    return false
end

function sampRegisterChatCommand(name, function_)
    name = tostring(name) check_samp_available()
    assert(type(function_) == 'function', '"'..tostring(function_)..'" is not function.')
    assert(samp_C.input.m_nCommandCount < MAX_CLIENTCMDS, 'Couldn\'t initialize "'..name..'". Maximum command amount reached.')
    assert(#name < 30, 'Command name "'..tostring(name)..'" was too long.')
    sampUnregisterChatCommand(name)
    local char = ffi.cast('PCHAR', name)
    local func = ffi.new('CMDPROC', function(args)
        function_(ffi.string(args))
    end)
    samp_C.regCMD(samp_C.input, char, func)
    return true
end

function sampSetChatInputText(text) check_samp_available()
    samp_C.setEditboxText(samp_C.input.m_pEditbox, ffi.cast('PCHAR', text), 0)
end

function sampGetChatInputText() check_samp_available()
    return ffi.string(samp_C.getEditboxText(samp_C.input.m_pEditbox))
end

function sampSetChatInputEnabled(enabled) check_samp_available()
    samp_C[enabled and 'enableInput' or 'disableInput'](samp_C.input)
end

function sampIsChatInputActive() check_samp_available()
    return samp_C.input.m_bEnabled == 1
end

function sampIsChatCommandDefined(name) check_samp_available()
    name = tostring(name)
    for i = 0, MAX_CLIENTCMDS - 1 do
        if ffi.string(samp_C.input.m_szCommandName[i]) == name then return true end
    end
    return false
end

-- stChatInfo

function sampAddChatMessage(text, color) check_samp_available()
    sampAddChatMessageEx(CHAT_TYPE_DEBUG, text, '', color, -1)
end

function sampGetChatDisplayMode() check_samp_available()
    return samp_C.chat.m_nMode
end

function sampSetChatDisplayMode(id) check_samp_available()
    id = tonumber(id) or 0
    samp_C.chat.m_nMode = id
end

function sampGetChatString(id) check_samp_available()
    id = tonumber(id) or 0
    if id < 0 or id > 100 then return end
    local current = samp_C.chat.m_entry[id]
    return ffi.string(current.m_szText), ffi.string(current.m_szPrefix), current.m_textColor, current.m_prefixColor
end

function sampSetChatString(id, text, prefix, color_t, color_p) check_samp_available()
    id = tonumber(id) or 0
    if id < 0 or id > 100 then return end
    local current = samp_C.chat.m_entry[id]
    current.m_szText = tostring(text)
    current.m_szPrefix = tostring(prefix)
    current.m_textColor = color_t
    current.m_prefixColor = color_p
end

function sampIsChatVisible() check_samp_available()
    return sampGetChatDisplayMode() ~= 0
end

-- CTextDrawPool

function sampTextdrawIsExists(id) check_samp_available()
    id = tonumber(id) or 0
    return samp_C.textdraw.m_bNotEmpty[id] == 1
end

function sampTextdrawCreate(id, text, x, y) check_samp_available()
    id = tonumber(id) or 0
    local transmit = ffi.new('SFL_TextDrawTransmit[1]', { { m_fX = x, m_fY = y } })
    samp_C.createTextDraw(samp_C.textdraw, id, transmit, tostring(text))
end

function sampTextdrawSetBoxColorAndSize(id, box, color, sizeX, sizeY) check_samp_available()
    id = tonumber(id) or 0
    if not sampTextdrawIsExists(id) then return end

    local current = samp_C.textdraw.m_pObject[id]
    current.m_bBox = box
    current.m_boxColor = color
    current.m_fBoxSizeX = sizeX
    current.m_fBoxSizeY = sizeY
end

function sampTextdrawGetString(id) check_samp_available()
    id = tonumber(id) or 0
    return sampTextdrawIsExists(id) and samp_C.textdraw.m_pObject[id].m_szText or ''
end

function sampTextdrawDelete(id) check_samp_available()
    id = tonumber(id) or 0
    if sampTextdrawIsExists(id) then samp_C.deleteTextDraw(samp_C.textdraw, id) end
end

function sampTextdrawGetLetterSizeAndColor(id) check_samp_available()
    id = tonumber(id) or 0
    if not sampTextdrawIsExists(id) then return end

    local current = samp_C.textdraw.m_pObject[id]
    return current.m_fLetterWidth, current.m_fLetterHeight, add.convertABGRtoARGB(current.m_letterColor)
end

function sampTextdrawGetPos(id) check_samp_available()
    id = tonumber(id) or 0
    if not sampTextdrawIsExists(id) then return end

    local current = samp_C.textdraw.m_pObject[id]
    return current.m_fX, current.m_fY
end

function sampTextdrawGetShadowColor(id) check_samp_available()
    id = tonumber(id) or 0
    if not sampTextdrawIsExists(id) then return end

    local current = samp_C.textdraw.m_pObject[id]
    return current.m_nShadow, current.m_backgroundColor
end

function sampTextdrawGetOutlineColor(id) check_samp_available()
    id = tonumber(id) or 0
    if not sampTextdrawIsExists(id) then return end

    local current = samp_C.textdraw.m_pObject[id]
    return current.m_nOutline, current.m_backgroundColor
end

function sampTextdrawGetStyle(id) check_samp_available()
    id = tonumber(id) or 0
    if sampTextdrawIsExists(id) then return samp_C.textdraw.m_pObject[id].iStyle end
end

function sampTextdrawGetProportional(id) check_samp_available()
    id = tonumber(id) or 0
    if sampTextdrawIsExists(id) then return samp_C.textdraw.m_pObject[id].m_nProportional end
end

function sampTextdrawGetAlign(id) check_samp_available()
    id = tonumber(id) or 0
    if not sampTextdrawIsExists(id) then return end

    local current = samp_C.textdraw.m_pObject[id]
    return current.m_bLeft == 1 and 1 or
           current.m_bCenter == 1 and 2 or
           current.m_bRight == 1 and 3 or 0
end

function sampTextdrawGetBoxEnabledColorAndSize(id) check_samp_available()
    id = tonumber(id) or 0
    if not sampTextdrawIsExists(id) then return end

    local current = samp_C.textdraw.m_pObject[id]
    return current.m_bBox, current.m_boxColor, current.m_fBoxSizeX, current.m_fBoxSizeY
end

function sampTextdrawGetModelRotationZoomVehColor(id) check_samp_available()
    id = tonumber(id) or 0
    if not sampTextdrawIsExists(id) then return end

    local current = samp_C.textdraw.m_pObject[id]
    return current.m_nModel, current.m_rotation.x, current.m_rotation.y, current.m_rotation.z,
           current.m_fZoom, current.m_aColor[1], current.m_aColor[2]
end

function sampTextdrawSetLetterSizeAndColor(id, letSizeX, letSizeY, color) check_samp_available()
    id = tonumber(id) or 0
    if not sampTextdrawIsExists(id) then return end

    local current = samp_C.textdraw.m_pObject[id]
    current.m_fLetterWidth = letSizeX
    current.m_fLetterHeight = letSizeY
    current.m_letterColor = color
end

function sampTextdrawSetPos(id, posX, posY) check_samp_available()
    id = tonumber(id) or 0
    if not sampTextdrawIsExists(id) then return end

    local current = samp_C.textdraw.m_pObject[id]
    current.m_fX = posX
    current.m_fY = posY
end

function sampTextdrawSetString(id, str) check_samp_available()
    id = tonumber(id) or 0
    if not sampTextdrawIsExists(id) then return end
    samp_C.textdraw.m_pObject[id].m_szText = str
end

function sampTextdrawSetModelRotationZoomVehColor(id, model, rotX, rotY, rotZ, zoom, clr1, clr2) check_samp_available()
    id = tonumber(id) or 0
    if not sampTextdrawIsExists(id) then return end

    local current = samp_C.textdraw.m_pObject[id]
    current.m_nModel = model
    current.m_rotation.x = rotX
    current.m_rotation.y = rotY
    current.m_rotation.z = rotZ
    current.m_fZoom = zoom
    current.m_aColor[1] = clr1
    current.m_aColor[2] = clr2
end

function sampTextdrawSetOutlineColor(id, outline, color) check_samp_available()
    id = tonumber(id) or 0
    if not sampTextdrawIsExists(id) then return end

    local current = samp_C.textdraw.m_pObject[id]
    current.m_nOutline = outline
    current.m_backgroundColor = color
end

function sampTextdrawSetShadow(id, shadow, color) check_samp_available()
    id = tonumber(id) or 0
    if not sampTextdrawIsExists(id) then return end

    local current = samp_C.textdraw.m_pObject[id]
    current.m_nShadow = shadow
    current.m_backgroundColor = color
end

function sampTextdrawSetStyle(id, style) check_samp_available()
    id = tonumber(id) or 0
    if sampTextdrawIsExists(id) then samp_C.textdraw.m_pObject[id].m_nStyle = style end
end

function sampTextdrawSetProportional(id, proportional) check_samp_available()
    id = tonumber(id) or 0
    if sampTextdrawIsExists(id) then samp_C.textdraw.m_pObject[id].m_nProportional = proportional end
end

local alignes = { 'm_bLeft', 'm_bCenter', 'm_bRight' }
function sampTextdrawSetAlign(id, align) check_samp_available()
    id = tonumber(id) or 0
    if not sampTextdrawIsExists(id) then return end

    local current = samp_C.textdraw.m_pObject[id]
    current.m_bLeft = 0; current.m_bCenter = 0; current.m_bRight = 0
    current[ alignes[align] ] = 1
end

-- stScoreboardInfo

function sampToggleScoreboard(showed) check_samp_available()
    if showed then samp_C.enableScoreboard(samp_C.scoreboard)
    else samp_C.disableScoreboard(samp_C.scoreboard, true) end
end

function sampIsScoreboardOpen() check_samp_available()
    return samp_C.scoreboard.m_bIsEnabled == 1
end

-- stTextLabelPool

function sampCreate3dText(text, color, x, y, z, dist, i_walls, id, vid) check_samp_available()
    local text = ffi.cast('PCHAR', tostring(text))
    for i = 0, #MAX_3DTEXTS - 1 do
        if not sampIs3dTextDefined(i) then
            samp_C.createTextLabel(samp_C.text3d, i, text, color, x, y, z, dist, i_walls, id, vid)
            return i
        end
    end
    return -1
end

function sampIs3dTextDefined(id) check_samp_available()
    id = tonumber(id) or 0
    return samp_C.text3d.m_bNotEmpty[id] == 1
end

function sampGet3dTextInfoById(id) check_samp_available()
    id = tonumber(id) or 0
    if sampIs3dTextDefined(id) then
        local t = samp_C.text3d.m_object[id]
        return ffi.string(t.m_pText), t.m_color, t.m_position.x, t.m_position.y, t.m_position.z,
            t.m_fDrawDistance, t.m_bBehindWalls, t.m_nAttachedToPlayer, t.m_nAttachedToVehicle
    end
end

function sampSet3dTextString(id, text) check_samp_available()
    id = tonumber(id) or 0
    if sampIs3dTextDefined(id) then
        samp_C.text3d.m_object[id].m_pText = ffi.cast('char*', tostring(text))
    end
end

function sampDestroy3dText(id) check_samp_available()
    id = tonumber(id) or 0
    if sampIs3dTextDefined(id) then
        samp_C.deleteTextLabel(samp_C.text3d, id)
    end
end

function sampCreate3dTextEx(i, text, color, x, y, z, dist, i_walls, id, vid) check_samp_available()
    if sampIs3dTextDefined(i) then sampDestroy3dText(i) end
    local text = ffi.cast('PCHAR', tostring(text))
    samp_C.createTextLabel(samp_C.text3d, id, text, color, x, y, z, dist, i_walls, id, vid)
end

-- stVehiclePool

function sampGetCarHandleBySampVehicleId(id) check_samp_available()
    id = tonumber(id) or 0
    if sampIsVehicleDefined(id) then return true, getVehiclePointerHandle(add.GET_POINTER(samp_C.car.m_pGameObject[id])) end
    return false, -1
end

function sampGetVehicleIdByCarHandle(car) check_samp_available()
    car = tonumber(car) or 0
    for i = 0, MAX_VEHICLES - 1 do
        local res, ccar = sampGetCarHandleBySampVehicleId(i)
        if res and ccar == car then return true, i end
    end
end

-- stObjectPool

function sampGetObjectHandleBySampId(id) check_samp_available()
    id = tonumber(id) or 0
    if samp_C.object.m_bNotEmpty[id] == 1 then
        return samp_C.object.m_pObject[id].entity.m_handle
    end
    return -1
end

-- stPickupPool

function sampGetPickupHandleBySampId(id) check_samp_available()
    id = tonumber(id) or 0
    return samp_C.pickup.ul_GTA_PickupID[id]
end

function sampGetPickupSampIdByHandle(handle) check_samp_available()
    handle = tonumber(handle) or 0
    for i = 0, MAX_PICKUPS - 1 do
        if sampGetPickupHandleBySampId(i) == handle then return i end
    end
    return -1
end

-- BitStream

function raknetBitStreamReadBool(bitstream)
    bitstream = ffi.cast('struct SFL_BitStream*', bitstream)
    return bitstream:ReadBit()
end

function raknetBitStreamReadInt8(bitstream)
    bitstream = ffi.cast('struct SFL_BitStream*', bitstream)
    local buf = ffi.new('char[?]', 1)
    bitstream:ReadBits(buf, 8, true)
    return buf[0]
end

function raknetBitStreamReadInt16(bitstream)
    bitstream = ffi.cast('struct SFL_BitStream*', bitstream)
    local buf = ffi.new('WORD[1]')
    bitstream:ReadBits(buf, 16, true)
    return buf[0]
end

function raknetBitStreamReadInt32(bitstream)
    bitstream = ffi.cast('struct SFL_BitStream*', bitstream)
    local buf = ffi.new('DWORD[1]')
    bitstream:ReadBits(buf, 32, true)
    return buf[0]
end

function raknetBitStreamReadFloat(bitstream)
    bitstream = ffi.cast('struct SFL_BitStream*', bitstream)
    local buf = ffi.new('float[1]')
    bitstream:ReadBits(buf, 32, true)
    return buf[0]
end

function raknetBitStreamReadBuffer(bitstream, dest, size)
    bitstream = ffi.cast('struct SFL_BitStream*', bitstream)
    bitstream:ReadBits(dest, size * 8, true)
end

function raknetBitStreamReadString(bitstream, size)
    bitstream = ffi.cast('struct SFL_BitStream*', bitstream)
    local buf = ffi.new('char[?]', size + 1)
    bitstream:ReadBits(buf, size * 8, true)
    return ffi.string(buf)
end

function raknetBitStreamResetReadPointer(bitstream)
    bitstream = ffi.cast('struct SFL_BitStream*', bitstream)
    bitstream:ResetReadPointer()
end

function raknetBitStreamResetWritePointer(bitstream)
    bitstream = ffi.cast('struct SFL_BitStream*', bitstream)
    bitstream:ResetWritePointer()
end

function raknetBitStreamIgnoreBits(bitstream, amount)
    bitstream = ffi.cast('struct SFL_BitStream*', bitstream)
    bitstream:IgnoreBits(amount)
end

function raknetBitStreamSetWriteOffset(bitstream, offset)
    bitstream = ffi.cast('struct SFL_BitStream*', bitstream)
    bitstream:SetWriteOffset(offset)
end

function raknetBitStreamSetReadOffset(bitstream, offset)
    bitstream = ffi.cast('struct SFL_BitStream*', bitstream)
    bitstream.readOffset = offset
end

function raknetBitStreamGetNumberOfBitsUsed(bitstream)
    bitstream = ffi.cast('struct SFL_BitStream*', bitstream)
    return bitstream.numberOfBitsUsed
end

function raknetBitStreamGetNumberOfBytesUsed(bitstream)
    local bits = raknetBitStreamGetNumberOfBitsUsed(bitstream)
    return bit.rshift(bits + 7, 3)
end

function raknetBitStreamGetNumberOfUnreadBits(bitstream)
    bitstream = ffi.cast('struct SFL_BitStream*', bitstream)
    return bitstream.numberOfBitsAllocated - bitstream.numberOfBitsUsed
end

function raknetBitStreamGetWriteOffset(bitstream)
    bitstream = ffi.cast('struct SFL_BitStream*', bitstream)
    return bitstream.numberOfBitsUsed
end

function raknetBitStreamGetReadOffset(bitstream)
    bitstream = ffi.cast('struct SFL_BitStream*', bitstream)
    return bitstream.readOffset
end

function raknetBitStreamGetDataPtr(bitstream)
    bitstream = ffi.cast('struct SFL_BitStream*', bitstream)
    return add.GET_POINTER(bitstream.data)
end

function raknetNewBitStream()
    local bitstream = bs()
    return add.GET_POINTER(bitstream)
end

function raknetDeleteBitStream(bitstream)
    bitstream = ffi.cast('struct SFL_BitStream*', bitstream)
    bitstream:__gc()
end

function raknetResetBitStream(bitstream)
    bitstream = ffi.cast('struct SFL_BitStream*', bitstream)
    bitstream:Reset()
end

function raknetBitStreamWriteBool(bitstream, value)
    bitstream = ffi.cast('struct SFL_BitStream*', bitstream)
    if value then bitstream:Write1()
    else bitstream:Write0() end
end

function raknetBitStreamWriteInt8(bitstream, value)
    bitstream = ffi.cast('struct SFL_BitStream*', bitstream)
    local buf = ffi.new('char[?]', 1, value)
    bitstream:WriteBits(buf, 8, true)
end

function raknetBitStreamWriteInt16(bitstream, value)
    bitstream = ffi.cast('struct SFL_BitStream*', bitstream)
    local buf = ffi.new('WORD[1]', value)
    bitstream:WriteBits(buf, 16, true)
end

function raknetBitStreamWriteInt32(bitstream, value)
    bitstream = ffi.cast('struct SFL_BitStream*', bitstream)
    local buf = ffi.new('DWORD[1]', value)
    bitstream:WriteBits(buf, 32, true)
end

function raknetBitStreamWriteFloat(bitstream, value)
    bitstream = ffi.cast('struct SFL_BitStream*', bitstream)
    local buf = ffi.new('float[1]', value)
    bitstream:WriteBits(buf, 32, true)
end

function raknetBitStreamWriteBuffer(bitstream, dest, size)
    bitstream = ffi.cast('struct SFL_BitStream*', bitstream)
    bitstream:WriteBits(dest, size * 8, true)
end

function raknetBitStreamWriteString(bitstream, str)
    bitstream = ffi.cast('struct SFL_BitStream*', bitstream)
    local buf = ffi.new('char[?]', #str + 1, str)
    bitstream:WriteBits(buf, #str * 8, true)
end

function raknetBitStreamDecodeString(bitstream, size) check_samp_available()
    bitstream = ffi.cast('struct SFL_BitStream*', bitstream)
    local buf = ffi.new('char[?]', size + 1)
    local this = ffi.cast('void**', sampGetBase() + 0x10D894)
    samp_C.readDecodeString(this[0], buf, size, bitstream, 0)
    return ffi.string(buf)
end

function raknetBitStreamEncodeString(bitstream, str) check_samp_available()
    bitstream = ffi.cast('struct SFL_BitStream*', bitstream)
    local buf = ffi.new('char[?]', #str + 1, str)
    local this = ffi.cast('void**', sampGetBase() + 0x10D894)
    samp_C.writeEncodeString(this[0], buf, #str, bitstream, 0)
end

function raknetBitStreamWriteBitStream(bitstream, bitStream)
    bitstream = ffi.cast('struct SFL_BitStream*', bitstream)
    bitstream:Write(bitStream)
end

-- RakClient

function raknetGetRpcName(id)
    local tab = {
        [23] = 'ClickPlayer',
        [25] = 'ClientJoin',
        [26] = 'EnterVehicle',
        [27] = 'EnterEditObject',
        [31] = 'ScriptCash',
        [50] = 'ServerCommand',
        [52] = 'Spawn',
        [53] = 'Death',
        [54] = 'NPCJoin',
        [62] = 'DialogResponse',
        [83] = 'ClickTextDraw',
        [96] = 'SCMEvent',
        [101] = 'Chat',
        [102] = 'SrvNetStats',
        [103] = 'ClientCheck',
        [106] = 'DamageVehicle',
        [115] = 'GiveTakeDamage',
        [116] = 'EditAttachedObject',
        [117] = 'EditObject',
        [118] = 'SetInteriorId',
        [119] = 'MapMarker',
        [128] = 'RequestClass',
        [129] = 'RequestSpawn',
        [131] = 'PickedUpPickup',
        [132] = 'MenuSelect',
        [136] = 'VehicleDestroyed',
        [140] = 'MenuQuit',
        [154] = 'ExitVehicle',
        [155] = 'UpdateScoresPingsIPs',
        [11] = 'SetPlayerName',
        [12] = 'SetPlayerPos',
        [13] = 'SetPlayerPosFindZ',
        [14] = 'SetPlayerHealth',
        [15] = 'TogglePlayerControllable',
        [16] = 'PlaySound',
        [17] = 'SetPlayerWorldBounds',
        [18] = 'GivePlayerMoney',
        [19] = 'SetPlayerFacingAngle',
        [20] = 'ResetPlayerMoney',
        [21] = 'ResetPlayerWeapons',
        [22] = 'GivePlayerWeapon',
        [24] = 'SetVehicleParamsEx',
        [28] = 'CancelEdit',
        [29] = 'SetPlayerTime',
        [30] = 'ToggleClock',
        [32] = 'WorldPlayerAdd',
        [33] = 'SetPlayerShopName',
        [34] = 'SetPlayerSkillLevel',
        [35] = 'SetPlayerDrunkLevel',
        [36] = 'Create3DTextLabel',
        [37] = 'DisableCheckpoint',
        [38] = 'SetRaceCheckpoint',
        [39] = 'DisableRaceCheckpoint',
        [40] = 'GameModeRestart',
        [41] = 'PlayAudioStream',
        [42] = 'StopAudioStream',
        [43] = 'RemoveBuildingForPlayer',
        [44] = 'CreateObject',
        [45] = 'SetObjectPos',
        [46] = 'SetObjectRot',
        [47] = 'DestroyObject',
        [55] = 'DeathMessage',
        [56] = 'SetPlayerMapIcon',
        [57] = 'RemoveVehicleComponent',
        [58] = 'Update3DTextLabel',
        [59] = 'ChatBubble',
        [60] = 'UpdateSystemTime',
        [61] = 'ShowDialog',
        [63] = 'DestroyPickup',
        [64] = 'WeaponPickupDestroy',
        [65] = 'LinkVehicleToInterior',
        [66] = 'SetPlayerArmour',
        [67] = 'SetPlayerArmedWeapon',
        [68] = 'SetSpawnInfo',
        [69] = 'SetPlayerTeam',
        [70] = 'PutPlayerInVehicle',
        [71] = 'RemovePlayerFromVehicle',
        [72] = 'SetPlayerColor',
        [73] = 'DisplayGameText',
        [74] = 'ForceClassSelection',
        [75] = 'AttachObjectToPlayer',
        [76] = 'InitMenu',
        [77] = 'ShowMenu',
        [78] = 'HideMenu',
        [79] = 'CreateExplosion',
        [80] = 'ShowPlayerNameTagForPlayer',
        [81] = 'AttachCameraToObject',
        [82] = 'InterpolateCamera',
        [84] = 'SetObjectMaterial',
        [85] = 'GangZoneStopFlash',
        [86] = 'ApplyAnimation',
        [87] = 'ClearAnimations',
        [88] = 'SetPlayerSpecialAction',
        [89] = 'SetPlayerFightingStyle',
        [90] = 'SetPlayerVelocity',
        [91] = 'SetVehicleVelocity',
        [92] = 'SetPlayerDrunkVisuals',
        [93] = 'ClientMessage',
        [94] = 'SetWorldTime',
        [95] = 'CreatePickup',
        [98] = 'SetVehicleTireStatus',
        [99] = 'MoveObject',
        [104] = 'EnableStuntBonusForPlayer',
        [105] = 'TextDrawSetString',
        [107] = 'SetCheckpoint',
        [108] = 'GangZoneCreate',
        [112] = 'PlayCrimeReport',
        [113] = 'SetPlayerAttachedObject',
        [120] = 'GangZoneDestroy',
        [121] = 'GangZoneFlash',
        [122] = 'StopObject',
        [123] = 'SetNumberPlate',
        [124] = 'TogglePlayerSpectating',
        [126] = 'PlayerSpectatePlayer',
        [127] = 'PlayerSpectateVehicle',
        [133] = 'SetPlayerWantedLevel',
        [134] = 'ShowTextDraw',
        [135] = 'TextDrawHideForPlayer',
        [137] = 'ServerJoin',
        [138] = 'ServerQuit',
        [139] = 'InitGame',
        [144] = 'RemovePlayerMapIcon',
        [145] = 'SetPlayerAmmo',
        [146] = 'SetPlayerGravity',
        [147] = 'SetVehicleHealth',
        [148] = 'AttachTrailerToVehicle',
        [149] = 'DetachTrailerFromVehicle',
        [150] = 'SetPlayerDrunkHandling',
        [151] = 'DestroyPickups',
        [152] = 'SetWeather',
        [153] = 'SetPlayerSkin',
        [156] = 'SetPlayerInterior',
        [157] = 'SetPlayerCameraPos',
        [158] = 'SetPlayerCameraLookAt',
        [159] = 'SetVehiclePos',
        [160] = 'SetVehicleZAngle',
        [161] = 'SetVehicleParamsForPlayer',
        [162] = 'SetCameraBehindPlayer',
        [163] = 'WorldPlayerRemove',
        [164] = 'WorldVehicleAdd',
        [165] = 'WorldVehicleRemove',
        [166] = 'WorldPlayerDeath'
    }
    return tab[id]
end

function raknetGetPacketName(id)
    local tab = {
        [6] = 'INTERNAL_PING',
        [7] = 'PING',
        [8] = 'PING_OPEN_CONNECTIONS',
        [9] = 'CONNECTED_PONG',
        [10] = 'REQUEST_STATIC_DATA',
        [11] = 'CONNECTION_REQUEST',
        [12] = 'AUTH_KEY',
        [14] = 'BROADCAST_PINGS',
        [15] = 'SECURED_CONNECTION_RESPONSE',
        [16] = 'SECURED_CONNECTION_CONFIRMATION',
        [17] = 'RPC_MAPPING',
        [19] = 'SET_RANDOM_NUMBER_SEED',
        [20] = 'RPC',
        [21] = 'RPC_REPLY',
        [23] = 'DETECT_LOST_CONNECTIONS',
        [24] = 'OPEN_CONNECTION_REQUEST',
        [25] = 'OPEN_CONNECTION_REPLY',
        [26] = 'CONNECTION_COOKIE',
        [28] = 'RSA_PUBLIC_KEY_MISMATCH',
        [29] = 'CONNECTION_ATTEMPT_FAILED',
        [30] = 'NEW_INCOMING_CONNECTION',
        [31] = 'NO_FREE_INCOMING_CONNECTIONS',
        [32] = 'DISCONNECTION_NOTIFICATION',
        [33] = 'CONNECTION_LOST',
        [34] = 'CONNECTION_REQUEST_ACCEPTED',
        [35] = 'INITIALIZE_ENCRYPTION',
        [36] = 'CONNECTION_BANNED',
        [37] = 'INVALID_PASSWORD',
        [38] = 'MODIFIED_PACKET',
        [39] = 'PONG',
        [40] = 'TIMESTAMP',
        [41] = 'RECEIVED_STATIC_DATA',
        [42] = 'REMOTE_DISCONNECTION_NOTIFICATION',
        [43] = 'REMOTE_CONNECTION_LOST',
        [44] = 'REMOTE_NEW_INCOMING_CONNECTION',
        [45] = 'REMOTE_EXISTING_CONNECTION',
        [46] = 'REMOTE_STATIC_DATA',
        [56] = 'ADVERTISE_SYSTEM',
        [200] = 'VEHICLE_SYNC',
        [201] = 'RCON_COMMAND',
        [202] = 'RCON_RESPONCE',
        [203] = 'AIM_SYNC',
        [204] = 'WEAPONS_UPDATE',
        [205] = 'STATS_UPDATE',
        [206] = 'BULLET_SYNC',
        [207] = 'PLAYER_SYNC',
        [208] = 'MARKERS_SYNC',
        [209] = 'UNOCCUPIED_SYNC',
        [210] = 'TRAILER_SYNC',
        [211] = 'PASSENGER_SYNC',
        [212] = 'SPECTATOR_SYNC'
    }
    return tab[id]
end

--- New functions

-- stVehiclePool

function sampIsVehicleDefined(id) check_samp_available()
    id = tonumber(id) or 0
    return samp_C.car.m_bNotEmpty[id] == 1 and samp_C.car.m_pObject[id] ~= nil and samp_C.car.m_pGameObject[id] ~= nil
end

-- stPlayerPool

function sampIsPlayerDefined(id) check_samp_available()
    id = tonumber(id) or 0
    if id == sampGetLocalPlayerId() then return samp_C.player.pLocalPlayer ~= nil end
    return sampIsPlayerConnected(id) and samp_C.player.m_pObject[id] ~= nil and samp_C.player.m_pObject[id].m_pPlayer ~= nil and
        samp_C.player.m_pObject[id].m_pPlayer.m_pPed ~= nil and samp_C.player.m_pObject[id].m_pPlayer.m_pPed.m_pGamePed ~= nil
end

function sampGetLocalPlayerNickname() check_samp_available()
    return sampGetPlayerNickname(sampGetLocalPlayerId())
end

function sampGetLocalPlayerColor() check_samp_available()
    return sampGetPlayerColor(sampGetLocalPlayerId())
end

function sampGetLocalPlayerId() check_samp_available()
    return samp_C.player.m_localInfo.m_nId
end

function sampSetPlayerColor(id, color) check_samp_available()
    id = tonumber(id)
    if sampIsPlayerConnected(id) or sampGetLocalPlayerId() == id then
        samp_C.color_table[id] = add.convertARGBToRGBA(color)
    end
end

-- Pointers to structures

function sampGetScoreboardInfoPtr() check_samp_loaded()
    return memory.getint32( sampGetBase() + 0x21A0B4 )
end

-- stChatInfo

function sampAddChatMessageEx(_type, text, prefix, textColor, prefixColor) check_samp_available()
    local char = ffi.cast('PCSTR', tostring(text))
    local charPrefix = prefix and ffi.cast('PCSTR', tostring(prefix))
    samp_C.addMessage(samp_C.chat, _type, char, charPrefix, tonumber(textColor) or -1, tonumber(prefixColor) or -1)
end

-- stPickupPool

function sampGetPickupModelTypeBySampId(id) check_samp_available()
    id = tonumber(id) or 0
    if samp_C.pickup.pickup[id] then return samp_C.pickup.pickup[id].m_nModel, samp_C.pickup.pickup[id].m_nType end
    return -1, -1
end

-- stKillInfo

function sampAddDeathMessage(killer, killed, clkiller, clkilled, reason) check_samp_available()
    local killer = ffi.cast('PCHAR', killer)
    local killed = ffi.cast('PCHAR', killed)
    samp_C.sendDeathMessage(samp_C.killinfo, killer, killed, clkiller, clkilled, reason)
end

-- stDialogInfo

function sampGetDialogButtons() check_samp_available()
    local dialog = samp_C.dialog.m_pDialog
    local b1p = ffi.cast('char*', samp_C.getControl(dialog, 20, 0)) + 0x4D
    local b2p = ffi.cast('char*', samp_C.getControl(dialog, 21, 0)) + 0x4D
    return ffi.string(b1p), ffi.string(b2p)
end
