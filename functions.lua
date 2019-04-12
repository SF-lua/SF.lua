--[[
	Authors: FYP, imring, DonHomka.
	Thanks BH Team for development.
	Structuers/addresses/other were taken in s0beit 0.3.7: https://github.com/BlastHackNet/mod_s0beit_sa
	http://blast.hk/ (c) 2018-2019.
]]
local ffi = require 'ffi'
local bit = require 'bit'
local memory = require 'memory'
local kernel = require 'SAMPFUNCSLUA.kernel'
require 'SAMPFUNCSLUA.structures'
local bs = require 'SAMPFUNCSLUA.bitstream'

local cast, new, str, typeof, sizeof, offsetof = ffi.cast, ffi.new, ffi.string, ffi.typeof, ffi.sizeof, ffi.offsetof
local nchar, ncmd, tdt, i16, i32, float = typeof('char[?]'), typeof('CMDPROC'), typeof('stTextDrawTransmit[1]'), 
	typeof('int16_t[1]'), typeof('int32_t[1]'), typeof('float[1]')
local onfoot_size = sizeof('struct onFootData')
local incar_size = sizeof('struct stInCarData')
local pass_size = sizeof('struct stPassengerData')
local trailer_size = sizeof('struct stTrailerData')
local aim_size = sizeof('struct stAimData')

local st_dialog, st_input, st_chat, st_samp, st_scoreboard, st_pools, st_player, st_textdraw, st_object, st_gangzone, st_text3d, st_car, st_pickup

local SAMP_INFO								= 0x21A0F8
local SAMP_DIALOG_INFO						= 0x21A0B8
local SAMP_MISC_INFO						= 0x21A10C
local SAMP_INPUIT_INFO						= 0x21A0E8
local SAMP_CHAT_INFO						= 0x21A0E4
local SAMP_COLOR							= 0x216378
local SAMP_KILL_INFO						= 0x21A0EC
local SAMP_SCOREBOARD_INFO					= 0x21A0B4

local sf = {
	-- Limits
	SAMP_MAX_ACTORS = 1000,
	SAMP_MAX_PLAYERS = 1004,
	SAMP_MAX_VEHICLES = 2000,
	SAMP_MAX_PICKUPS = 4096,
	SAMP_MAX_OBJECTS = 1000,
	SAMP_MAX_GANGZONES = 1024,
	SAMP_MAX_3DTEXTS = 2048,
	SAMP_MAX_TEXTDRAWS = 2048,
	SAMP_MAX_PLAYERTEXTDRAWS = 256,
	SAMP_MAX_CLIENTCMDS = 144,
	SAMP_MAX_MENUS = 128,
	SAMP_MAX_PLAYER_NAME = 24,
	SAMP_ALLOWED_PLAYER_NAME_LENGTH = 20,

	-- Chat types
	CHAT_TYPE_NONE = 0,
	CHAT_TYPE_CHAT = 2,
	CHAT_TYPE_INFO = 4,
	CHAT_TYPE_DEBUG = 8,

	-- Dialog types
	DIALOG_STYLE_MSGBOX = 0,
	DIALOG_STYLE_INPUT = 1,
	DIALOG_STYLE_LIST = 2,
	DIALOG_STYLE_PASSWORD = 3,
	DIALOG_STYLE_TABLIST = 4,
	DIALOG_STYLE_TABLIST_HEADERS = 5
}

local samp_dll = getModuleHandle('samp.dll')
local color_table = cast('DWORD*', samp_dll + SAMP_COLOR)

local sampFunctions = {
	-- stSAMP
	sendSCM = cast('void(__cdecl *)(void *this, int type, WORD id, int param1, int param2)', samp_dll + 0x1A50),
	sendGiveDmg = cast('void(__stdcall *)(WORD id, float damage, DWORD weapon, DWORD bodypart)', samp_dll + 0x6770),
	sendTakeDmg = cast('void(__stdcall *)(WORD id, float damage, DWORD weapon, DWORD bodypart)', samp_dll + 0x6660),
	sendReqSpwn = cast('void(__cdecl *)()', samp_dll + 0x3A20),

	-- stDialogInfo
	showDialog = cast('void(__thiscall *)(void* this, WORD wID, BYTE iStyle, PCHAR szCaption, PCHAR szText, PCHAR szButton1, PCHAR szButton2, bool bSend)', samp_dll + 0x6B9C0),
	closeDialog = cast('void(__thiscall *)(void* this, int button)', samp_dll + 0x6C040),
	getElementSturct = cast('char*(__thiscall *)(void* this, int a, int b)', samp_dll + 0x82C50),
	getEditboxStruct = cast('char*(__thiscall *)(void* this)', samp_dll + 0x81030),

	-- stGameInfo
	showCursor = cast('void (__thiscall*)(void* this, int type, bool show)', samp_dll + 0x9BD30),
	cursorUnlockActorCam = cast('void (__thiscall*)(void* this)', samp_dll + 0x9BC10),

	-- stPlayerPool
	reqSpawn = cast('void(__thiscall*)(void* this)', samp_dll + 0x3EC0),
	spawn = cast('void(__thiscall*)(void* this)', samp_dll + 0x3AD0),
	say = cast('void(__thiscall *)(void* this, PCHAR message)', samp_dll + 0x57F0),
	reqClass = cast('void(__thiscall *)(void* this, int classId)', samp_dll + 0x56A0),
	sendInt = cast('void (__thiscall *)(void* this, BYTE interiorID)', samp_dll + 0x5740),
	forceUnocSync = cast('void (__thiscall *)(void* this, WORD id, BYTE seat)', samp_dll + 0x4B30),
	setAction = cast('void( __thiscall*)(void* this, BYTE specialActionId)', samp_dll + 0x30C0),
	setName = cast('void(__thiscall *)(int this, const char *name, int len)', samp_dll + 0xB290),

	-- stInputInfo
	sendCMD = cast('void(__thiscall *)(void* this, PCHAR message)', samp_dll + 0x65C60),
	regCMD = cast('void(__thiscall *)(void* this, PCHAR command, CMDPROC function)', samp_dll + 0x65AD0),
	enableInput = cast('void(__thiscall *)(void* this)', samp_dll + 0x6AD30),
	disableInput = cast('void(__thiscall *)(void* this)', samp_dll + 0x658E0),

	-- stTextdrawPool
	createTextDraw = cast('void(__thiscall *)(void* this, WORD id, struct stTextDrawTransmit* transmit, PCHAR text)', samp_dll + 0x1AE20),
	deleteTextDraw = cast('void(__thiscall *)(void* this, WORD id)', samp_dll + 0x1AD00),

	-- stScoreboardInfo
	enableScoreboard = cast('void (__thiscall *)(void *this)', samp_dll + 0x6AD30),
	disableScoreboard = cast('void (__thiscall *)(void* this, bool disableCursor)', samp_dll + 0x658E0),

	-- stTextLabelPool
	createTextLabel = cast('int (__thiscall *)(void* this, WORD id, PCHAR text, DWORD color, float x, float y, float z, float dist, bool ignoreWalls, WORD attachPlayerId, WORD attachCarId)', samp_dll + 0x11C0),
	deleteTextLabel = cast('void(__thiscall *)(void* this, WORD id)', samp_dll + 0x12D0),

	-- stChatInfo
	addMessage = cast('void(__thiscall *)(void* this, int Type, PCSTR szString, PCSTR szPrefix, DWORD TextColor, DWORD PrefixColor)', samp_dll + 0x64010),

	-- stKillInfo
	sendDeathMessage = cast('void(__thiscall*)(void *this, PCHAR killer, PCHAR killed, DWORD clKiller, DWORD clKilled, BYTE reason)', samp_dll + 0x66930),

	-- BitStream
	readDecodeString = cast('void (__thiscall*)(void* this, char* buf, size_t size_buf, BitStream* bs, int unk)', samp_dll + 0x507E0),
	writeEncodeString = cast('void (__thiscall*)(void* this, const char* str, size_t size_str, BitStream* bs, int unk)', samp_dll + 0x506B0)
}

local originals = {}

local hooks = {
	onSendRpc = {
		function(id, bitstream, priority, reliability, orderingChannel, shiftTs)
			local oid, obitstream, opriority, oreliability, oorderingChannel, oshiftTs = id, bitstream, priority, reliability, orderingChannel, shiftTs
			local process
			if type(onSendRpc) == 'function' then
				process, id, bitstream, priority, reliability, orderingChannel, shiftTs = onSendRpc(id[0], kernel.getAddressByCData(bitstream), priority, reliability, orderingChannel, shiftTs)
			end
			if process ~= false then
				if id then oid[0] = cast('BYTE*', id) end
				if bitstream then obitstream[0] = cast('char*', bitstream) end
				opriority = priority or opriority
				oreliability = reliability or oreliability
				oorderingChannel = orderingChannel or oorderingChannel
				if shiftTs ~= nil then oshiftTs = shiftTs end
				originals.onSendRpc(oid, obitstream, opriority, oreliability, oorderingChannel, oshiftTs)
			end
		end
	}
}

--- Standart functions

function sf.isSampfuncsLoaded()
	return true
end

function sf.sampGetBase()
	return samp_dll
end

function sf.isSampLoaded()
	return sf.sampGetBase() > 0x0
end

-- Pointers to structures

function sf.sampGetSampInfoPtr()
	return memory.getint32( sf.sampGetBase() + SAMP_INFO)
end

function sf.sampGetDialogInfoPtr()
	return memory.getint32( sf.sampGetBase() + SAMP_DIALOG_INFO )
end

function sf.sampGetMiscInfoPtr()
	return memory.getint32( sf.sampGetBase() + SAMP_MISC_INFO )
end

function sf.sampGetInputInfoPtr()
	return memory.getint32( sf.sampGetBase() + SAMP_INPUIT_INFO )
end

function sf.sampGetChatInfoPtr()
	return memory.getint32( sf.sampGetBase() + SAMP_CHAT_INFO )
end

function sf.sampGetKillInfoPtr()
	return memory.getint32( sf.sampGetBase() + SAMP_KILL_INFO )
end

function sf.sampGetSampPoolsPtr()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return kernel.getAddressByCData(st_pools)
end

function sf.sampGetServerSettingsPtr()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return kernel.getAddressByCData(st_samp.pSettings)
end

function sf.sampGetTextdrawPoolPtr()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return kernel.getAddressByCData(st_textdraw)
end

function sf.sampGetObjectPoolPtr()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return kernel.getAddressByCData(st_object)
end

function sf.sampGetGangzonePoolPtr()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return kernel.getAddressByCData(st_gangzone)
end

function sf.sampGetTextlabelPoolPtr()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return kernel.getAddressByCData(st_text3d)
end

function sf.sampGetTextlabelPoolPtr()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return kernel.getAddressByCData(st_text3d)
end

function sf.sampGetPlayerPoolPtr()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return kernel.getAddressByCData(st_player)
end

function sf.sampGetVehiclePoolPtr()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return kernel.getAddressByCData(st_car)
end

function sf.sampGetPickupPoolPtr()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return kernel.getAddressByCData(st_pickup)
end

function sf.sampGetRakclientInterface()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return kernel.getAddressByCData(st_samp.pRakClientInterface)
end

function sf.isSampAvailable()
	if sf.isSampLoaded() and sf.sampGetSampInfoPtr() > 0x0 then
		if not st_dialog then
			st_dialog = kernel.getStruct('stDialogInfo', sf.sampGetDialogInfoPtr())
			st_input = kernel.getStruct('stInputInfo', sf.sampGetInputInfoPtr())
			st_chat = kernel.getStruct('stChatInfo', sf.sampGetChatInfoPtr())
			st_samp = kernel.getStruct('stSAMP', sf.sampGetSampInfoPtr())
			st_scoreboard = kernel.getStruct('stScoreboardInfo', sf.sampGetScoreboardInfoPtr())
			st_killinfo = kernel.getStruct('stKillInfo', sf.sampGetKillInfoPtr())
			st_misc = kernel.getStruct('stGameInfo', sf.sampGetMiscInfoPtr())
			st_pools = st_samp.pPools
			st_player = st_pools.pPlayer
			st_textdraw = st_pools.pTextdraw
			st_object = st_pools.pObject
			st_gangzone = st_pools.pGangzone
			st_text3d = st_pools.pText3D
			st_car = st_pools.pVehicle
			st_pickup = st_pools.pPickup
		end
		return true
	end
	return false
end

-- stSAMP

function sf.sampGetCurrentServerName()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return str(st_samp.szHostname)
end

function sf.sampGetCurrentServerAddress()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return str(st_samp.szIP), st_samp.ulPort
end

function sf.sampGetGamestate()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return st_samp.iGameState
end

function sf.sampSetGamestate(gamestate)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	gamestate = tonumber(gamestate) or 0
	st_samp.iGameState = gamestate
end

function sf.sampSendScmEvent(event, id, param1, param2)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	sampFunctions.sendSCM(id, event, param1, param1)
end

function sf.sampSendGiveDamage(id, damage, weapon, bodypart)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	sampFunctions.sendGiveDmg(id, damage, weapon, bodypart)
end

function sf.sampSendTakeDamage(id, damage, weapon, bodypart)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	sampFunctions.sendTakeDmg(id, damage, weapon, bodypart)
end

function sf.sampSendRequestSpawn()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	sampFunctions.sendReqSpwn()
end

-- stDialogInfo

function sf.sampIsDialogActive()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return st_dialog.iIsActive == 1
end

function sf.sampGetDialogCaption()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return str(st_dialog.szCaption)
end

function sf.sampGetCurrentDialogId()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return st_dialog.DialogID
end

function sf.sampGetDialogText()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return str(st_dialog.pText)
end

function sf.sampGetCurrentDialogType()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return st_dialog.iType
end

function sf.sampShowDialog(id, caption, text, button1, button2, style)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	local caption = cast('PCHAR', tostring(caption))
	local text = cast('PCHAR', tostring(text))
	local button1 = cast('PCHAR', tostring(button1))
	local button2 = cast('PCHAR', tostring(button2))
	sampFunctions.showDialog(st_dialog, id, style, caption, text, button1, button2, false)
end

function sf.sampGetCurrentDialogListItem()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	local list = getStructElement(sf.sampGetDialogInfoPtr(), 0x20, 4)
	return getStructElement(list, 0x143 --[[m_nSelected]], 4)
end

function sf.sampSetCurrentDialogListItem(number)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	local list = getStructElement(sf.sampGetDialogInfoPtr(), 0x20, 4)
	return setStructElement(list, 0x143 --[[m_nSelected]], 4, tonumber(number) or 0)
end

function sf.sampCloseCurrentDialogWithButton(button)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	sampFunctions.closeDialog(st_dialog, button)
end

function sf.sampGetCurrentDialogEditboxText()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	local dialog = st_dialog.pEditBox
	local char = sampFunctions.getEditboxStruct(dialog)
	return str(char)
end

-- stGameInfo

function sf.sampToggleCursor(showed)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	sampFunctions.showCursor(st_misc, showed == true and 3 or 0, showed)
	if showed ~= true then sampFunctions.cursorUnlockActorCam(st_misc) end
end

function sf.sampIsCursorActive()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return st_misc.iCursorMode > 0
end

function sf.sampGetCursorMode()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return st_misc.iCursorMode
end

function sf.sampSetCursorMode(mode)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	st_misc.iCursorMode = tonumber(mode) or 0
end

-- stPlayerPool

function sf.sampIsPlayerConnected(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	assert(id >= 0 and id < sf.SAMP_MAX_PLAYERS, 'Max IDs 1004. Current ID: '..id)
	return st_player.iIsListed[id] == 1 or sf.sampGetLocalPlayerId() == id
end

function sf.sampGetPlayerNickname(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	local char
	if sf.sampGetLocalPlayerId() == id then char = cast('PCSTR', st_player.strLocalPlayerName)
	elseif sf.sampIsPlayerConnected(id) then char = cast('PCSTR', st_player.pRemotePlayer[id].strPlayerName) end
	return char and str(char) or ''
end

function sf.sampSpawnPlayer()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	sampFunctions.reqSpawn(st_player.pLocalPlayer)
	sampFunctions.spawn(st_player.pLocalPlayer)
end

function sf.sampSendChat(msg)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	local char = cast('PCHAR', tostring(msg))
	if char[0] == 47 then 
		sampFunctions.sendCMD(st_input, char)
	else 
		sampFunctions.say(st_player.pLocalPlayer, char) 
	end
end

function sf.sampIsPlayerNpc(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	return sf.sampIsPlayerConnected(id) and st_player.pRemotePlayer[id].iIsNPC == 1
end

function sf.sampGetPlayerScore(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	local score = 0
	if sf.sampGetLocalPlayerId() == id then score = st_player.iLocalPlayerScore
	elseif sf.sampIsPlayerConnected(id) then score = st_player.pRemotePlayer[id].iScore end
	return score
end

function sf.sampGetPlayerPing(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	local ping = 0
	if sf.sampGetLocalPlayerId() == id then ping = st_player.iLocalPlayerPing
	elseif sf.sampIsPlayerConnected(id) then ping = st_player.pRemotePlayer[id].iPing end
	return ping
end

function sf.sampRequestClass(class)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	class = tonumber(class) or 0
	sampFunctions.reqClass(st_player.pLocalPlayer, class)
end

function sf.sampGetPlayerColor(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	if sf.sampIsPlayerConnected(id) or sf.sampGetLocalPlayerId() == id then
		return kernel.convertRGBAToARGB(color_table[id])
	end
end

function sf.sampSendInteriorChange(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	sampFunctions.sendInt(st_player.pLocalPlayer, id)
end

function sf.sampForceUnoccupiedSyncSeatId(id, seat)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	seat = tonumber(seat) or 0
	sampFunctions.forceUnocSync(st_player.pLocalPlayer, id, seat)
end

function sf.sampGetCharHandleBySampPlayerId(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	if id == sf.sampGetLocalPlayerId() then return true, playerPed
	elseif sf.sampIsPlayerDefined(id) then
		return true, getCharPointerHandle(kernel.getAddressByCData(st_player.pRemotePlayer[id].pPlayerData.pSAMP_Actor.pGTA_Ped))
	end
	return false, -1
end

function sf.sampGetPlayerIdByCharHandle(ped)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	ped = tonumber(ped) or 0
	if ped == playerPed then return true, sf.sampGetLocalPlayerId() end
	for i = 0, sf.SAMP_MAX_PLAYERS - 1 do
		local res, pped = sampGetCharHandleBySampPlayerId(i)
		if res and pped == ped then return true, i end
	end
	return false, -1
end

function sf.sampGetPlayerArmor(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	if sf.sampIsPlayerDefined(id) then 
		if id == sf.sampGetLocalPlayerId() then return getCharArmour(playerPed) end
		return st_player.pRemotePlayer[id].pPlayerData.fActorArmor 
	end
	return 0
end

function sf.sampGetPlayerHealth(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	if sf.sampIsPlayerDefined(id) then 
		if id == sf.sampGetLocalPlayerId() then return getCharHealth(playerPed) end
		return st_player.pRemotePlayer[id].pPlayerData.fActorHealth 
	end
	return 0
end

function sf.sampSetSpecialAction(action)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	action = tonumber(action) or 0
	if sf.sampIsPlayerDefined(sf.sampGetLocalPlayerId()) then
		sampFunctions.setAction(st_player.pLocalPlayer, action)
	end
end

function sf.sampGetPlayerCount(streamed)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	if not streamed then return st_scoreboard.iPlayersCount - 1 end
	local players = 0
	for i = 0, sf.SAMP_MAX_PLAYERS - 1 do
		if i ~= sf.sampGetLocalPlayerId() then
			local bool = false
			local res, ped = sf.sampGetCharHandleBySampPlayerId(i)
			bool = res and doesCharExist(ped)
			if bool then players = players + 1 end
		end
	end
	return players
end

function sf.sampGetMaxPlayerId(streamed)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	local mid = sf.sampGetLocalPlayerId()
	for i = 0, sf.SAMP_MAX_PLAYERS - 1 do
		if i ~= sf.sampGetLocalPlayerId() then
			local bool = false
			if streamed then
				local res, ped = sf.sampGetCharHandleBySampPlayerId(i)
				bool = res and doesCharExist(ped)
			else bool = sf.sampIsPlayerConnected(i) end
			if bool and i > mid then mid = i end
		end
	end
	return mid
end

function sf.sampGetPlayerSpecialAction(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	if sf.sampIsPlayerConnected(id) then return st_player.pRemotePlayer[i].pPlayerData.byteSpecialAction end
	return -1
end

function sf.sampStorePlayerOnfootData(id, data)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	data = tonumber(data) or 0
	local struct
	if id == sf.sampGetLocalPlayerId() then struct = st_player.pLocalPlayer.onFootData
	elseif sf.sampIsPlayerDefined(id) then struct = st_player.pRemotePlayer[id].pPlayerData.onFootData end
	if struct then memory.copy(data, kernel.getAddressByCData(struct), onfoot_size) end
end

function sf.sampIsPlayerPaused(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	if id == sf.sampGetLocalPlayerId() then return false end
	if sf.sampIsPlayerConnected(id) then return st_player.pRemotePlayer[id].pPlayerData.iAFKState == 0 end
end

function sf.sampStorePlayerIncarData(id, data)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	data = tonumber(data) or 0
	local struct
	if id == sf.sampGetLocalPlayerId() then struct = st_player.pLocalPlayer.inCarData
	elseif sf.sampIsPlayerDefined(id) then struct = st_player.pRemotePlayer[id].pPlayerData.inCarData end
	if struct then memory.copy(data, kernel.getAddressByCData(struct), incar_size) end
end

function sf.sampStorePlayerPassengerData(id, data)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	data = tonumber(data) or 0
	local struct
	if id == sf.sampGetLocalPlayerId() then struct = st_player.pLocalPlayer.passengerData
	elseif sf.sampIsPlayerDefined(id) then struct = st_player.pRemotePlayer[id].pPlayerData.passengerData end
	if struct then memory.copy(data, kernel.getAddressByCData(struct), pass_size) end
end

function sf.sampStorePlayerTrailerData(id, data)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	data = tonumber(data) or 0
	local struct
	if id == sf.sampGetLocalPlayerId() then struct = st_player.pLocalPlayer.trailerData
	elseif sf.sampIsPlayerDefined(id) then struct = st_player.pRemotePlayer[id].pPlayerData.trailerData end
	if struct then memory.copy(data, kernel.getAddressByCData(struct), trailer_size) end
end

function sf.sampStorePlayerAimData(id, data)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	data = tonumber(data) or 0
	local struct
	if id == sf.sampGetLocalPlayerId() then struct = st_player.pLocalPlayer.aimData
	elseif sf.sampIsPlayerDefined(id) then struct = st_player.pRemotePlayer[id].pPlayerData.aimData end
	if struct then memory.copy(data, kernel.getAddressByCData(struct), aim_size) end
end

function sf.sampSendSpawn()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	sampFunctions.spawn(st_player.pLocalPlayer)
end

function sf.sampGetPlayerAnimationId(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	if id == sf.sampGetLocalPlayerId() then return st_player.pLocalPlayer.sCurrentAnimID end
	if sf.sampIsPlayerConnected(id) then return st_player.pRemotePlayer[id].pPlayerData.onFootData.sCurrentAnimationID end
end

function sf.sampSetLocalPlayerName(name)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	local name = tostring(name)
	assert(#name <= sf.SAMP_MAX_PLAYER_NAME, 'Limit name - '..sf.SAMP_MAX_PLAYER_NAME..'.')
	sampFunctions.setName(kernel.getAddressByCData(st_player) + offsetof('struct stPlayerPool', 'pVTBL_txtHandler'), name, #name)
end

-- stInputInfo

function sf.sampUnregisterChatCommand(name)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	for i = 0, sf.SAMP_MAX_CLIENTCMDS - 1 do
		if str(st_input.szCMDNames[i]) == tostring(name) then
			st_input.szCMDNames[i] = nchar(33)
			st_input.pCMDs[i] = ncmd()
			st_input.iCMDCount = st_input.iCMDCount - 1
			return true
		end
	end
	return false
end

function sf.sampRegisterChatCommand(name, function_)
	local name = tostring(name)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	assert(type(function_) == 'function', '"'..tostring(function_)..'" is not function.')
	assert(st_input.iCMDCount < sf.SAMP_MAX_CLIENTCMDS, 'Couldn\'t initialize "'..name..'". Maximum command amount reached.')
	assert(#name < 30, 'Command name "'..tostring(name)..'" was too long.')
	sf.sampUnregisterChatCommand(name)
	local char = cast('PCHAR', name)
	local func = ncmd(function(args)
		function_(str(args))
	end)
	sampFunctions.regCMD(st_input, char, func)
	return true
end

function sf.sampSetChatInputText(text)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	st_input.szInputBuffer = nchar(129, tostring(text))
end

function sf.sampGetChatInputText()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return str(st_input.szInputBuffer)
end

function sf.sampSetChatInputEnabled(enabled)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	sampFunctions[enabled and 'enableInput' or 'disableInput'](st_input)
end

function sf.sampIsChatInputActive()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return st_input.pDXUTEditBox.bIsChatboxOpen == 1
end

function sf.sampIsChatCommandDefined(name)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	name = tostring(name)
	for i = 0, sf.SAMP_MAX_CLIENTCMDS - 1 do
		if str(st_input.szCMDNames[i]) == name then return true end
	end
	return false
end

function sf.sampProcessChatInput(text)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	local char = cast('PCHAR', tostring(text))
	sampFunctions.say(st_player.pLocalPlayer, char)
end

-- stChatInfo

function sf.sampAddChatMessage(text, color)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	sf.sampAddChatMessageEx(sf.CHAT_TYPE_DEBUG, text, '', color, -1)
end

function sf.sampGetChatDisplayMode()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return st_chat.iChatWindowMode
end

function sf.sampSetChatDisplayMode(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	st_chat.iChatWindowMode = id
end

function sf.sampGetChatString(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	return str(st_chat.chatEntry[id].szText), str(st_chat.chatEntry[id].szPrefix), st_chat.chatEntry[id].clTextColor, st_chat.chatEntry[id].clPrefixColor
end

function sf.sampSetChatString(id, text, prefix, color_t, color_p)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	st_chat.chatEntry[id].szText = nchar(144, tostring(text))
	st_chat.chatEntry[id].szPrefix = nchar(28, tostring(prefix))
	st_chat.chatEntry[id].clTextColor = color_t
	st_chat.chatEntry[id].clPrefixColor = color_p
end

function sf.sampIsChatVisible()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return sf.sampGetChatDisplayMode() > 0
end

-- stTextdrawPool

function sf.sampTextdrawIsExists(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	return id < sf.SAMP_MAX_TEXTDRAWS and st_textdraw.iIsListed[id] == 1 or st_textdraw.iPlayerTextDraw[id - sf.SAMP_MAX_TEXTDRAWS] == 1
end

function sf.sampTextdrawCreate(id, text, x, y)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	local transmit = tdt{ { fX = x, fY = y } }
	sampFunctions.createTextDraw(st_textdraw, transmit, cast('PCHAR', tostring(text)))
end

function sf.sampTextdrawSetBoxColorAndSize(id, box, color, sizeX, sizeY)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	if sf.sampTextdrawIsExists(id) then
		local struct = id >= sf.SAMP_MAX_TEXTDRAWS and st_textdraw.playerTextdraw[id - sf.SAMP_MAX_TEXTDRAWS] or st_textdraw.textdraw[id]
		struct.byteBox = box
		struct.dwBoxColor = color
		struct.fBoxSizeX = sizeX
		struct.fBoxSizeY = sizeY
	end
end

function sf.sampTextdrawGetString(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	if sf.sampTextdrawIsExists(id) then
		local str
		if id >= sf.SAMP_MAX_TEXTDRAWS then str = st_textdraw.playerTextdraw[id - sf.SAMP_MAX_TEXTDRAWS].szText
		else str = st_textdraw.textdraw[id - sf.SAMP_MAX_TEXTDRAWS].szText end
		return str(str)
	end
	return ''
end

function sf.sampTextdrawDelete(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	sampFunctions.deleteTextDraw(st_textdraw, id)
end

-- stScoreboardInfo

function sf.sampToggleScoreboard(showed)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	if showed then 
		sampFunctions.enableScoreboard(st_scoreboard)
	else 
		sampFunctions.disableScoreboard(st_scoreboard, true)
	end
end

function sf.sampIsScoreboardOpen()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return st_scoreboard.iIsEnabled == 1
end

-- stTextLabelPool

function sf.sampCreate3dText(text, color, x, y, z, dist, i_walls, id, vid)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	local text = cast('PCHAR', tostring(text))
	for i = 0, #sf.SAMP_MAX_3DTEXTS - 1 do
		if not sf.sampIs3dTextDefined(i) then
			sampFunctions.createTextLabel(st_text3d, i, text, color, x, y, z, dist, i_walls, id, vid)
			return i
		end
	end
	return -1
end

function sf.sampIs3dTextDefined(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	return st_text3d.iIsListed[id] == 1
end

function sf.sampGet3dTextInfoById(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	if sf.sampIs3dTextDefined(id) then
		local t = st_text3d.textLabel[id]
		return str(t.pText), t.color, t.fPosition[0], t.fPosition[1], t.fPosition[2], t.fMaxViewDistance, t.byteShowBehindWalls == 1, t.sAttachedToPlayerID, t.sAttachedToVehicleID
	end
end

function sf.sampSet3dTextString(id, text)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	if sf.sampIs3dTextDefined(id) then
		st_text3d.textLabel[id].pText = cast('PCHAR', tostring(text))
	end
end

function sf.sampDestroy3dText(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	if sf.sampIs3dTextDefined(id) then
		sampFunctions.deleteTextLabel(st_text3d, id)
	end
end

function sf.sampCreate3dTextEx(i, text, color, x, y, z, dist, i_walls, id, vid)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	if sf.sampIs3dTextDefined(i) then sf.sampDestroy3dText(i) end
	local text = cast('PCHAR', tostring(text))
	sampFunctions.createTextLabel(st_text3d, id, text, color, x, y, z, dist, i_walls, id, vid)
end

-- stVehiclePool

function sf.sampGetCarHandleBySampVehicleId(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	if sf.sampIsVehicleDefined(id) then return true, getVehiclePointerHandle(kernel.getAddressByCData(st_car.pSAMP_Vehicle[id].pGTA_Vehicle)) end
	return false, -1
end

function sf.sampGetVehicleIdByCarHandle(car)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	car = tonumber(car) or 0
	for i = 0, sf.SAMP_MAX_VEHICLES - 1 do
		local res, ccar = sf.sampGetCarHandleBySampVehicleId(i)
		if res and ccar == car then return true, i end
	end
end

-- BitStream

function sf.sampSendDeathByPlayer(id, reason)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	local bitstream = bs.new()
	bitstream:BitStream()
	bitstream:WriteBits(nchar(1, reason), 8, true)
	bitstream:WriteBits(i16(id), 16, true)
	raknetSendRpc(53, kernel.getAddressByCData(bitstream[1]))
	bitstream:FBitStream()
end

function sf.raknetBitStreamReadBool(bitstream)
	bitstream = bs.new(bitstream)
	return bs:ReadBit()
end

function sf.raknetBitStreamReadInt8(bitstream)
	bitstream = bs.new(bitstream)
	local buf = nchar(1)
	bitstream:ReadBits(buf, 8, true)
	return buf[0]
end

function sf.raknetBitStreamReadInt16(bitstream)
	bitstream = bs.new(bitstream)
	local buf = i16()
	bitstream:ReadBits(buf, 16, true)
	return buf[0]
end

function sf.raknetBitStreamReadInt32(bitstream)
	bitstream = bs.new(bitstream)
	local buf = i32()
	bitstream:ReadBits(buf, 32, true)
	return buf[0]
end

function sf.raknetBitStreamReadFloat(bitstream)
	bitstream = bs.new(bitstream)
	local buf = float()
	bitstream:ReadBits(buf, 32, true)
	return buf[0]
end

function sf.raknetBitStreamReadBuffer(bitstream, dest, size)
	bitstream = bs.new(bitstream)
	bitstream:ReadBits(dest, size * 8, true)
end

function sf.raknetBitStreamReadString(bitstream, size)
	bitstream = bs.new(bitstream)
	local buf = nchar(size + 1)
	bitstream:ReadBits(buf, size * 8, true)
	return str(buf)
end

function sf.raknetBitStreamResetReadPointer(bitstream)
	bitstream = bs.new(bitstream)
	bitstream:ResetReadPointer()
end

function sf.raknetBitStreamResetWritePointer(bitstream)
	bitstream = bs.new(bitstream)
	bitstream:ResetWritePointer()
end

function sf.raknetBitStreamIgnoreBits(bitstream, amount)
	bitstream = bs.new(bitstream)
	bitstream:IgnoreBits(amount)
end

function sf.raknetBitStreamSetWriteOffset(bitstream, offset)
	bitstream = bs.new(bitstream)
	bitstream:SetWriteOffset(offset)
end

function sf.raknetBitStreamSetReadOffset(bitstream, offset)
	bitstream = bs.new(bitstream)
	bitstream[1].readOffset = offset
end

function sf.raknetBitStreamGetNumberOfBitsUsed(bitstream)
	bitstream = bs.new(bitstream)
	return bitstream[1].numberOfBitsUsed
end

function sf.raknetBitStreamGetNumberOfBytesUsed(bitstream)
	bitstream = bs.new(bitstream)
	return bit.rshift(bitstream[1].numberOfBitsUsed + 7, 3)
end

function sf.raknetBitStreamGetNumberOfUnreadBits(bitstream)
	bitstream = bs.new(bitstream)
	return bitstream[1].numberOfBitsAllocated - bitstream[1].numberOfBitsUsed
end

function sf.raknetBitStreamGetWriteOffset(bitstream)
	bitstream = bs.new(bitstream)
	return bitstream[1].numberOfBitsUsed
end

function sf.raknetBitStreamGetReadOffset(bitstream)
	bitstream = bs.new(bitstream)
	return bitstream[1].readOffset
end

function sf.raknetBitStreamGetDataPtr(bitstream)
	bitstream = bs.new(bitstream)
	return kernel.getAddressByCData(bitstream[1].data)
end

function sf.raknetNewBitStream()
	local bitstream = bs.new()
	bitstream:BitStream()
	return kernel.getAddressByCData(bitstream[1])
end

function sf.raknetDeleteBitStream(bitstream)
	bitstream = bs.new(bitstream)
	bitstream:FBitStream()
end

function sf.raknetResetBitStream(bitstream)
	bitstream = bs.new(bitstream)
	bitstream:Reset()
end

function sf.raknetBitStreamWriteBool(bitstream, value)
	bitstream = bs.new(bitstream)
	if value then bitstream:Write1()
	else bitstream:Write0() end
end

function sf.raknetBitStreamWriteInt8(bitstream, value)
	bitstream = bs.new(bitstream)
	local buf = nchar(1, value)
	bitstream:WriteBits(buf, 8, true)
end

function sf.raknetBitStreamWriteInt16(bitstream, value)
	bitstream = bs.new(bitstream)
	local buf = i16(value)
	bitstream:WriteBits(buf, 16, true)
end

function sf.raknetBitStreamWriteInt32(bitstream, value)
	bitstream = bs.new(bitstream)
	local buf = i32(value)
	bitstream:WriteBits(buf, 32, true)
end

function sf.raknetBitStreamWriteFloat(bitstream, value)
	bitstream = bs.new(bitstream)
	local buf = float(value)
	bitstream:WriteBits(buf, 32, true)
end

function sf.raknetBitStreamWriteBuffer(bitstream, dest, size)
	bitstream = bs.new(bitstream)
	bitstream:WriteBits(dest, size * 8, true)
end

function sf.raknetBitStreamWriteString(bitstream, str)
	bitstream = bs.new(bitstream)
	local buf = nchar(#str + 1, str)
	bitstream:WriteBits(buf, #str * 8, true)
end

function sf.raknetBitStreamDecodeString(bitstream, size)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	bitstream = bs.new(bitstream)
	local buf = nchar(size + 1)
	local this = cast('void**', samp_dll + 0x10D894)
	sampFunctions.readDecodeString(this[0], buf, size, bitstream[1], 0)
	return str(buf)
end

function sf.raknetBitStreamEncodeString(bitstream, str)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	bitstream = bs.new(bitstream)
	local buf = nchar(#str + 1, str)
	local this = cast('void**', samp_dll + 0x10D894)
	sampFunctions.writeEncodeString(this[0], buf, #str, bitstream[1], 0)
end

--- New functions

-- stVehiclePool

function sf.sampIsVehicleDefined(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	return st_car.iIsListed[id] == 1 and kernel.getAddressByCData(st_car.pSAMP_Vehicle[id]) > 0 and kernel.getAddressByCData(st_car.pSAMP_Vehicle[id].pGTA_Vehicle) > 0
end

-- stPlayerPool

function sf.sampIsPlayerDefined(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	if id == sf.sampGetLocalPlayerId() then return kernel.getAddressByCData(st_player.pLocalPlayer) > 0 end
	return sf.sampIsPlayerConnected(id) and kernel.getAddressByCData(st_player.pRemotePlayer[id]) > 0 and kernel.getAddressByCData(st_player.pRemotePlayer[id].pPlayerData) > 0 and
	kernel.getAddressByCData(st_player.pRemotePlayer[id].pPlayerData.pSAMP_Actor) > 0 and kernel.getAddressByCData(st_player.pRemotePlayer[id].pPlayerData.pSAMP_Actor.actor_info) > 0
end

function sf.sampGetLocalPlayerNickname()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return sf.sampGetPlayerNickname(sf.sampGetLocalPlayerId())
end

function sf.sampGetLocalPlayerColor()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return sf.sampGetPlayerColor(sf.sampGetLocalPlayerId())
end

function sf.sampGetLocalPlayerId()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return st_player.sLocalPlayerID
end

function sf.sampSetPlayerColor(id, color)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id)
	if sf.sampIsPlayerConnected(id) or sf.sampGetLocalPlayerId() == id then
		color_table[id] = kernel.convertARGBToRGBA(color)
	end
end

-- Pointers to structures

function sf.sampGetScoreboardInfoPtr()
	return memory.getint32( sf.sampGetBase() + SAMP_SCOREBOARD_INFO )
end

-- stChatInfo

function sf.sampAddChatMessageEx(_type, text, prefix, textColor, prefixColor)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	local char = cast('PCSTR', tostring(text))
	local charPrefix = prefix and cast('PCSTR', tostring(prefix))
	sampFunctions.addMessage(st_chat, type, char, charPrefix, textColor, prefixColor)
end

-- stPickupPool

function sf.sampGetPickupModelTypeBySampId(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	if st_pickup.pickup[id] then return st_pickup.pickup[id].iModelID, st_pickup.pickup[id].iType end
	return -1, -1
end

-- stKillInfo

function sf.sampAddDeathMessage(killer, killed, clkiller, clkilled, reason)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	local killer = cast('PCHAR', killer)
	local killed = cast('PCHAR', killed)
	sampFunctions.sendDeathMessage(st_killinfo, killer, killed, 0xFFFFFF000000 + clkiller, 0xFFFFFF000000 + clkilled, reason)
end

-- stDialogInfo

function sf.sampGetDialogButtons()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
    local dialog = st_dialog.pDialog
    local b1p = sampFunctions.getElementSturct(dialog, 20, 0) + 0x4D
    local b2p = sampFunctions.getElementSturct(dialog, 21, 0) + 0x4D
    return str(b1p), str(b2p)
end

-- Hooks
lua_thread.create(function()
	while not sf.isSampAvailable() do wait(0) end
	if #hooks.onSendRpc == 1 then
		local callback = cast('RPC_CALL', hooks.onSendRpc[1])
		local detour_addr = kernel.getAddressByCData(callback)
		local raknet = kernel.getAddressByCData(st_samp.pRakClientInterface)
		local hook_addr = memory.getuint32(raknet) + 0x64
		local inf_addr = memory.getuint32(hook_addr, true)
		originals.onSendRpc = cast('RPC_CALL', inf_addr)
		hooks.onSendRpc[2] = inf_addr
		hooks.onSendRpc[3] = hook_addr
		memory.setuint32(hook_addr, detour_addr, true)
	end
end)

function onScriptTerminate(scr)
	if scr == script.this then
		memory.setuint32(hooks.onSendRpc[3], hooks.onSendRpc[2], true)
	end
end

return sf

--[[
Unfinished functions

function sf.raknetSendRpc(rpc, bs)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	local rpc = ffi.new('DWORD[1]', rpc)
	local bs = ffi.new('DWORD[1]', bs)
	ffi.cast('void (__stdcall*)(void*, void*, signed int, signed int, DWORD, DWORD)', memory.getuint32(kernel.getAddressByCData(st_samp.pRakClientInterface)) + 0x64)
		(rpc, bs, 1, 9, 0, 0)
end
]]