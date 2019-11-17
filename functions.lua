--[[
    Project: SAMPFUNCSLUA
    URL: https://github.com/imring/SAMPFUNCSLUA

    File: functions.lua
    License: MIT License

	Authors: FishLake Scripts <fishlake-scripts.ru> and BH Team <blast.hk>.
]]
local ffi = require 'ffi'
local bit = require 'bit'
local memory = require 'memory'
local kernel = require 'SAMPFUNCSLUA.kernel'
require 'SAMPFUNCSLUA.structures'
local bs = require 'SAMPFUNCSLUA.bitstream'
local hook = {}

local cast, new, str, typeof, sizeof, offsetof = ffi.cast, ffi.new, ffi.string, ffi.typeof, ffi.sizeof, ffi.offsetof
local nchar, ncmd, i16, i32, float = typeof('char[?]'), typeof('CMDPROC'), typeof('int16_t[1]'), typeof('int32_t[1]'), typeof('float[1]')

local SAMP_INFO								= 0x21A0F8
local SAMP_DIALOG_INFO						= 0x21A0B8
local SAMP_MISC_INFO						= 0x21A10C
local SAMP_INPUIT_INFO						= 0x21A0E8
local SAMP_CHAT_INFO						= 0x21A0E4
local SAMP_COLOR							= 0x216378
local SAMP_KILL_INFO						= 0x21A0EC
local SAMP_SCOREBOARD_INFO					= 0x21A0B4
local SAMP_ANIM								= 0xF15B0

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
	DIALOG_STYLE_TABLIST_HEADERS = 5,

	-- RPCs
	RPC_CLICKPLAYER = 23,
	RPC_CLIENTJOIN = 25,
	RPC_ENTERVEHICLE = 26,
	RPC_ENTEREDITOBJECT = 27,
	RPC_SCRIPTCASH = 31,
	RPC_SERVERCOMMAND = 50,
	RPC_SPAWN = 52,
	RPC_DEATH = 53,
	RPC_NPCJOIN = 54,
	RPC_DIALOGRESPONSE = 62,
	RPC_CLICKTEXTDRAW = 83,
	RPC_SCMEVENT = 96,
	RPC_WEAPONPICKUPDESTROY = 97,
	RPC_CHAT = 101,
	RPC_SRVNETSTATS = 102,
	RPC_CLIENTCHECK = 103,
	RPC_DAMAGEVEHICLE = 106,
	RPC_GIVETAKEDAMAGE = 115,
	RPC_EDITATTACHEDOBJECT = 116,
	RPC_EDITOBJECT = 117,
	RPC_SETINTERIORID = 118,
	RPC_MAPMARKER = 119,
	RPC_REQUESTCLASS = 128,
	RPC_REQUESTSPAWN = 129,
	RPC_PICKEDUPPICKUP = 131,
	RPC_MENUSELECT = 132,
	RPC_VEHICLEDESTROYED = 136,
	RPC_MENUQUIT = 140,
	RPC_EXITVEHICLE = 154,
	RPC_UPDATESCORESPINGSIPS = 155,

	RPC_SCRSETPLAYERNAME = 11,
	RPC_SCRSETPLAYERPOS = 12,
	RPC_SCRSETPLAYERPOSFINDZ = 13,
	RPC_SCRSETPLAYERHEALTH = 14,
	RPC_SCRTOGGLEPLAYERCONTROLLABLE = 15,
	RPC_SCRPLAYSOUND = 16,
	RPC_SCRSETPLAYERWORLDBOUNDS = 17,
	RPC_SCRGIVEPLAYERMONEY = 18,
	RPC_SCRSETPLAYERFACINGANGLE = 19,
	RPC_SCRRESETPLAYERMONEY = 20,
	RPC_SCRRESETPLAYERWEAPONS = 21,
	RPC_SCRGIVEPLAYERWEAPON = 22,
	RPC_SCRSETVEHICLEPARAMSEX = 24,
	RPC_SCRCANCELEDIT = 28,
	RPC_SCRSETPLAYERTIME = 29,
	RPC_SCRTOGGLECLOCK = 30,
	RPC_SCRWORLDPLAYERADD = 32,
	RPC_SCRSETPLAYERSHOPNAME = 33,
	RPC_SCRSETPLAYERSKILLLEVEL = 34,
	RPC_SCRSETPLAYERDRUNKLEVEL = 35,
	RPC_SCRCREATE3DTEXTLABEL = 36,
	RPC_SCRDISABLECHECKPOINT = 37,
	RPC_SCRSETRACECHECKPOINT = 38,
	RPC_SCRDISABLERACECHECKPOINT = 39,
	RPC_SCRGAMEMODERESTART = 40,
	RPC_SCRPLAYAUDIOSTREAM = 41,
	RPC_SCRSTOPAUDIOSTREAM = 42,
	RPC_SCRREMOVEBUILDINGFORPLAYER = 43,
	RPC_SCRCREATEOBJECT = 44,
	RPC_SCRSETOBJECTPOS = 45,
	RPC_SCRSETOBJECTROT = 46,
	RPC_SCRDESTROYOBJECT = 47,
	RPC_SCRDEATHMESSAGE = 55,
	RPC_SCRSETPLAYERMAPICON = 56,
	RPC_SCRREMOVEVEHICLECOMPONENT = 57,
	RPC_SCRUPDATE3DTEXTLABEL = 58,
	RPC_SCRCHATBUBBLE = 59,
	RPC_SCRSOMEUPDATE = 60,
	RPC_SCRSHOWDIALOG = 61,
	RPC_SCRDESTROYPICKUP = 63,
	RPC_SCRLINKVEHICLETOINTERIOR = 65,
	RPC_SCRSETPLAYERARMOUR = 66,
	RPC_SCRSETPLAYERARMEDWEAPON = 67,
	RPC_SCRSETSPAWNINFO = 68,
	RPC_SCRSETPLAYERTEAM = 69,
	RPC_SCRPUTPLAYERINVEHICLE = 70,
	RPC_SCRREMOVEPLAYERFROMVEHICLE = 71,
	RPC_SCRSETPLAYERCOLOR = 72,
	RPC_SCRDISPLAYGAMETEXT = 73,
	RPC_SCRFORCECLASSSELECTION = 74,
	RPC_SCRATTACHOBJECTTOPLAYER = 75,
	RPC_SCRINITMENU = 76,
	RPC_SCRSHOWMENU = 77,
	RPC_SCRHIDEMENU = 78,
	RPC_SCRCREATEEXPLOSION = 79,
	RPC_SCRSHOWPLAYERNAMETAGFORPLAYER = 80,
	RPC_SCRATTACHCAMERATOOBJECT = 81,
	RPC_SCRINTERPOLATECAMERA = 82,
	RPC_SCRSETOBJECTMATERIAL = 84,
	RPC_SCRGANGZONESTOPFLASH = 85,
	RPC_SCRAPPLYANIMATION = 86,
	RPC_SCRCLEARANIMATIONS = 87,
	RPC_SCRSETPLAYERSPECIALACTION = 88,
	RPC_SCRSETPLAYERFIGHTINGSTYLE = 89,
	RPC_SCRSETPLAYERVELOCITY = 90,
	RPC_SCRSETVEHICLEVELOCITY = 91,
	RPC_SCRCLIENTMESSAGE = 93,
	RPC_SCRSETWORLDTIME = 94,
	RPC_SCRCREATEPICKUP = 95,
	RPC_SCRMOVEOBJECT = 99,
	RPC_SCRENABLESTUNTBONUSFORPLAYER = 104,
	RPC_SCRTEXTDRAWSETSTRING = 105,
	RPC_SCRSETCHECKPOINT = 107,
	RPC_SCRGANGZONECREATE = 108,
	RPC_SCRPLAYCRIMEREPORT = 112,
	RPC_SCRSETPLAYERATTACHEDOBJECT = 113,
	RPC_SCRGANGZONEDESTROY = 120,
	RPC_SCRGANGZONEFLASH = 121,
	RPC_SCRSTOPOBJECT = 122,
	RPC_SCRSETNUMBERPLATE = 123,
	RPC_SCRTOGGLEPLAYERSPECTATING = 124,
	RPC_SCRPLAYERSPECTATEPLAYER = 126,
	RPC_SCRPLAYERSPECTATEVEHICLE = 127,
	RPC_SCRSETPLAYERWANTEDLEVEL = 133,
	RPC_SCRSHOWTEXTDRAW = 134,
	RPC_SCRTEXTDRAWHIDEFORPLAYER = 135,
	RPC_SCRSERVERJOIN = 137,
	RPC_SCRSERVERQUIT = 138,
	RPC_SCRINITGAME = 139,
	RPC_SCRREMOVEPLAYERMAPICON = 144,
	RPC_SCRSETPLAYERAMMO = 145,
	RPC_SCRSETGRAVITY = 146,
	RPC_SCRSETVEHICLEHEALTH = 147,
	RPC_SCRATTACHTRAILERTOVEHICLE = 148,
	RPC_SCRDETACHTRAILERFROMVEHICLE = 149,
	RPC_SCRSETWEATHER = 152,
	RPC_SCRSETPLAYERSKIN = 153,
	RPC_SCRSETPLAYERINTERIOR = 156,
	RPC_SCRSETPLAYERCAMERAPOS = 157,
	RPC_SCRSETPLAYERCAMERALOOKAT = 158,
	RPC_SCRSETVEHICLEPOS = 159,
	RPC_SCRSETVEHICLEZANGLE = 160,
	RPC_SCRSETVEHICLEPARAMSFORPLAYER = 161,
	RPC_SCRSETCAMERABEHINDPLAYER = 162,
	RPC_SCRWORLDPLAYERREMOVE = 163,
	RPC_SCRWORLDVEHICLEADD = 164,
	RPC_SCRWORLDVEHICLEREMOVE = 165,
	RPC_SCRWORLDPLAYERDEATH = 166,

	-- Packets
	PACKET_INTERNAL_PING = 6,
	PACKET_PING = 7,
	PACKET_PING_OPEN_CONNECTIONS = 8,
	PACKET_CONNECTED_PONG = 9,
	PACKET_REQUEST_STATIC_DATA = 10,
	PACKET_CONNECTION_REQUEST = 11,
	PACKET_AUTH_KEY = 12,
	PACKET_BROADCAST_PINGS = 14,
	PACKET_SECURED_CONNECTION_RESPONSE = 15,
	PACKET_SECURED_CONNECTION_CONFIRMATION = 16,
	PACKET_RPC_MAPPING = 17,
	PACKET_SET_RANDOM_NUMBER_SEED = 19,
	PACKET_RPC = 20,
	PACKET_RPC_REPLY = 21,
	PACKET_DETECT_LOST_CONNECTIONS = 23,
	PACKET_OPEN_CONNECTION_REQUEST = 24,
	PACKET_OPEN_CONNECTION_REPLY = 25,
	PACKET_CONNECTION_COOKIE = 26,
	PACKET_RSA_PUBLIC_KEY_MISMATCH = 28,
	PACKET_CONNECTION_ATTEMPT_FAILED = 29,
	PACKET_NEW_INCOMING_CONNECTION = 30,
	PACKET_NO_FREE_INCOMING_CONNECTIONS = 31,
	PACKET_DISCONNECTION_NOTIFICATION = 32,
	PACKET_CONNECTION_LOST = 33,
	PACKET_CONNECTION_REQUEST_ACCEPTED = 34,
	PACKET_INITIALIZE_ENCRYPTION = 35,
	PACKET_CONNECTION_BANNED = 36,
	PACKET_INVALID_PASSWORD = 37,
	PACKET_MODIFIED_PACKET = 38,
	PACKET_PONG = 39,
	PACKET_TIMESTAMP = 40,
	PACKET_RECEIVED_STATIC_DATA = 41,
	PACKET_REMOTE_DISCONNECTION_NOTIFICATION = 42,
	PACKET_REMOTE_CONNECTION_LOST = 43,
	PACKET_REMOTE_NEW_INCOMING_CONNECTION = 44,
	PACKET_REMOTE_EXISTING_CONNECTION = 45,
	PACKET_REMOTE_STATIC_DATA = 46,
	PACKET_ADVERTISE_SYSTEM = 56,
	
	PACKET_VEHICLE_SYNC = 200,
	PACKET_RCON_COMMAND = 201,
	PACKET_RCON_RESPONCE = 202,
	PACKET_AIM_SYNC = 203,
	PACKET_WEAPONS_UPDATE = 204,
	PACKET_STATS_UPDATE = 205,
	PACKET_BULLET_SYNC = 206,
	PACKET_PLAYER_SYNC = 207,
	PACKET_MARKERS_SYNC = 208,
	PACKET_UNOCCUPIED_SYNC = 209,
	PACKET_TRAILER_SYNC = 210,
	PACKET_PASSENGER_SYNC = 211,
	PACKET_SPECTATOR_SYNC = 212,

	-- Gamestates
	GAMESTATE_NONE = 0,
	GAMESTATE_WAIT_CONNECT = 1,
	GAMESTATE_AWAIT_JOIN = 2,
	GAMESTATE_CONNECTED = 3,
	GAMESTATE_RESTARTING = 4,
	GAMESTATE_DISCONNECTED = 5,

	-- BitStream
	BS_TYPE_BYTE = 0,
	BS_TYPE_BOOL = 1,
	BS_TYPE_SHORT = 2,
	BS_TYPE_INT = 3,
	BS_TYPE_FLOAT = 4,
	BS_TYPE_ARRAY = 5,
	BS_TYPE_BITSTREAM = 6,

	-- Priorities
	SYSTEM_PRIORITY = 0,
	HIGH_PRIORITY = 1,
	MEDIUM_PRIORITY = 2,
	LOW_PRIORITY = 3,

	-- Reliability
	UNRELIABLE = 6,
	UNRELIABLE_SEQUENCED = 7,
	RELIABLE = 8,
	RELIABLE_ORDERED = 9,
	RELIABLE_SEQUENCED = 10,

	-- Sendrates
	ONFOOTSENDRATE = 1,
	INCARSENDRATE = 2,
	AIMSENDRATE = 3,

	-- SAMP SCM Events
	SCMEVENT_PAINTJOB = 1,
	SCMEVENT_UPGRADE = 2,
	SCMEVENT_COLOR = 3,
	SCMEVENT_MODSHOPENTEREXIT = 4,

	-- Special Actions
	SPECIAL_ACTION_NONE = 0,
	SPECIAL_ACTION_DUCK = 1,
	SPECIAL_ACTION_USEJETPACK = 2,
	SPECIAL_ACTION_ENTER_VEHICLE = 3,
	SPECIAL_ACTION_EXIT_VEHICLE = 4,
	SPECIAL_ACTION_DANCE1 = 5,
	SPECIAL_ACTION_DANCE2 = 6,
	SPECIAL_ACTION_DANCE3 = 7,
	SPECIAL_ACTION_DANCE4 = 8,
	SPECIAL_ACTION_HANDSUP = 10,
	SPECIAL_ACTION_USECELLPHONE = 11,
	SPECIAL_ACTION_SITTING = 12,
	SPECIAL_ACTION_STOPUSECELLPHONE = 13,
	SPECIAL_ACTION_DRINK_BEER = 20,
	SPECIAL_ACTION_SMOKE_CIGGY = 21,
	SPECIAL_ACTION_DRINK_WINE = 22,
	SPECIAL_ACTION_DRINK_SPRUNK = 23,
	SPECIAL_ACTION_CUFFED = 24,
	SPECIAL_ACTION_CARRY = 25,
	SPECIAL_ACTION_URINATE = 68,

	-- SAMP Cursor Modes
	CMODE_DISABLED = 0,
	CMODE_LOCKKEYS_NOCURSOR = 1,
	CMODE_LOCKCAMANDCONTROL = 2,
	CMODE_LOCKCAM = 3,
	CMODE_LOCKCAM_NOCURSOR = 4,

	sflua = {
		_VERSION = '1.0-beta'
	}
}

local samp_dll = getModuleHandle('samp.dll')

local samp_C = {
	-- stSAMP
	sendSCM = cast('void(__cdecl *)(void *this, int type, WORD id, int param1, int param2)', samp_dll + 0x1A50),
	sendGiveDmg = cast('void(__stdcall *)(WORD id, float damage, DWORD weapon, DWORD bodypart)', samp_dll + 0x6770),
	sendTakeDmg = cast('void(__stdcall *)(WORD id, float damage, DWORD weapon, DWORD bodypart)', samp_dll + 0x6660),
	sendReqSpwn = cast('void(__cdecl *)()', samp_dll + 0x3A20),

	-- stDialogInfo
	showDialog = cast('void(__thiscall *)(void* this, WORD wID, BYTE iStyle, PCHAR szCaption, PCHAR szText, PCHAR szButton1, PCHAR szButton2, bool bSend)', samp_dll + 0x6B9C0),
	closeDialog = cast('void(__thiscall *)(void* this, int button)', samp_dll + 0x6C040),
	getElementSturct = cast('char*(__thiscall *)(void* this, int a, int b)', samp_dll + 0x82C50),
	getEditboxText = cast('char*(__thiscall *)(void* this)', samp_dll + 0x81030),
	setEditboxText = cast('void(__thiscall *)(void* this, char* text, int i)', samp_dll + 0x80F60),

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
	sendEnterVehicle = cast('void (__thiscall*)(void* this, int id, bool passenger)', samp_dll + 0x58C0),
	sendExitVehicle = cast('void (__thiscall*)(void* this, int id)', samp_dll + 0x59E0),

	-- stInputInfo
	sendCMD = cast('void(__thiscall *)(void* this, PCHAR message)', samp_dll + 0x65C60),
	regCMD = cast('void(__thiscall *)(void* this, PCHAR command, CMDPROC function)', samp_dll + 0x65AD0),
	enableInput = cast('void(__thiscall *)(void* this)', samp_dll + 0x6AD30),
	disableInput = cast('void(__thiscall *)(void* this)', samp_dll + 0x658E0),

	-- stTextdrawPool
	createTextDraw = cast('void(__thiscall *)(void* this, WORD id, struct SFL_TextDrawTransmit* transmit, PCHAR text)', samp_dll + 0x1AE20),
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
	readDecodeString = cast('void (__thiscall*)(void* this, char* buf, size_t size_buf, SFL_BitStream* bs, int unk)', samp_dll + 0x507E0),
	writeEncodeString = cast('void (__thiscall*)(void* this, const char* str, size_t size_str, SFL_BitStream* bs, int unk)', samp_dll + 0x506B0)
}

setmetatable(samp_C, { __newindex = function(t, k, v)
    if samp_C[k] then
        print('[SAMPFUNCSLUA] Warning! Overwriting existing key "'..k..'"!')
    end
    rawset(t, k, v)
end})

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
	assert(sf.isSampLoaded(), 'SA-MP is not loaded.')
	return memory.getint32( sf.sampGetBase() + SAMP_INFO )
end

function sf.sampGetDialogInfoPtr()
	assert(sf.isSampLoaded(), 'SA-MP is not loaded.')
	return memory.getint32( sf.sampGetBase() + SAMP_DIALOG_INFO )
end

function sf.sampGetMiscInfoPtr()
	assert(sf.isSampLoaded(), 'SA-MP is not loaded.')
	return memory.getint32( sf.sampGetBase() + SAMP_MISC_INFO )
end

function sf.sampGetInputInfoPtr()
	assert(sf.isSampLoaded(), 'SA-MP is not loaded.')
	return memory.getint32( sf.sampGetBase() + SAMP_INPUIT_INFO )
end

function sf.sampGetChatInfoPtr()
	assert(sf.isSampLoaded(), 'SA-MP is not loaded.')
	return memory.getint32( sf.sampGetBase() + SAMP_CHAT_INFO )
end

function sf.sampGetKillInfoPtr()
	assert(sf.isSampLoaded(), 'SA-MP is not loaded.')
	return memory.getint32( sf.sampGetBase() + SAMP_KILL_INFO )
end

function sf.sampGetSampPoolsPtr()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return kernel.getAddressByCData(samp_C.pools)
end

function sf.sampGetServerSettingsPtr()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return kernel.getAddressByCData(samp_C.samp.pSettings)
end

function sf.sampGetTextdrawPoolPtr()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return kernel.getAddressByCData(samp_C.textdraw)
end

function sf.sampGetObjectPoolPtr()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return kernel.getAddressByCData(samp_C.object)
end

function sf.sampGetGangzonePoolPtr()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return kernel.getAddressByCData(samp_C.gangzone)
end

function sf.sampGetTextlabelPoolPtr()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return kernel.getAddressByCData(samp_C.text3d)
end

function sf.sampGetTextlabelPoolPtr()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return kernel.getAddressByCData(samp_C.text3d)
end

function sf.sampGetPlayerPoolPtr()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return kernel.getAddressByCData(samp_C.player)
end

function sf.sampGetVehiclePoolPtr()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return kernel.getAddressByCData(samp_C.car)
end

function sf.sampGetPickupPoolPtr()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return kernel.getAddressByCData(samp_C.pickup)
end

function sf.sampGetRakclientInterface()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return kernel.getAddressByCData(samp_C.samp.pRakClientInterface)
end

local availables = {
	{ 'sampGetSampInfoPtr', 'samp', 'SAMP' },
	{ 'sampGetDialogInfoPtr', 'dialog', 'DialogInfo' },
	{ 'sampGetMiscInfoPtr', 'misc', 'GameInfo' },
	{ 'sampGetInputInfoPtr', 'input', 'InputInfo' },
	{ 'sampGetChatInfoPtr', 'chat', 'ChatInfo' },
	{ 'sampGetKillInfoPtr', 'killinfo', 'KillInfo' },
	{ 'sampGetScoreboardInfoPtr', 'scoreboard', 'ScoreboardInfo' }
}

function sf.isSampAvailable()
	assert(sf.isSampLoaded(), 'SA-MP is not loaded.')
	local addr, result = 0, true
	for i = 1, #availables do
		local ptr = availables[i]
		addr = sf[ ptr[1] ]()
		result = result and addr > 0
		if result then
			samp_C[ ptr[2] ] = kernel.getStruct(ptr[3], addr)
		else
			return result
		end
	end
	local anim_list = new('char[1811][36]')
	ffi.copy(anim_list, cast('void*', samp_dll + SAMP_ANIM), sizeof(anim_list))
	samp_C.color_table = cast('DWORD*', samp_dll + SAMP_COLOR)
	samp_C.anim_list = anim_list

	samp_C.pools = samp_C.samp.pPools
	samp_C.player = samp_C.pools.pPlayer
	samp_C.textdraw = samp_C.pools.pTextdraw
	samp_C.object = samp_C.pools.pObject
	samp_C.gangzone = samp_C.pools.pGangzone
	samp_C.text3d = samp_C.pools.pText3D
	samp_C.car = samp_C.pools.pVehicle
	samp_C.pickup = samp_C.pools.pPickup

	return result
end

-- stSAMP

function sf.sampGetCurrentServerName()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return str(samp_C.samp.szHostname)
end

function sf.sampGetCurrentServerAddress()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return str(samp_C.samp.szIP), samp_C.samp.ulPort
end

function sf.sampGetGamestate()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	local states = {
		[0] = sf.GAMESTATE_NONE,
		[9] = sf.GAMESTATE_WAIT_CONNECT,
		[15] = sf.GAMESTATE_AWAIT_JOIN,
		[14] = sf.GAMESTATE_CONNECTED,
		[18] = sf.GAMESTATE_RESTARTING,
		[13] = sf.GAMESTATE_DISCONNECTED
	}
	return states[samp_C.samp.iGameState]
end

function sf.sampSetGamestate(gamestate)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	gamestate = tonumber(gamestate) or 0
	local states = {
		[0] = 0, 9, 15, 14, 18, 13
	}
	samp_C.samp.iGameState = states[gamestate]
end

function sf.sampSendScmEvent(event, id, param1, param2)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	samp_C.sendSCM(id, event, param1, param1)
end

function sf.sampSendGiveDamage(id, damage, weapon, bodypart)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	samp_C.sendGiveDmg(id, damage, weapon, bodypart)
end

function sf.sampSendTakeDamage(id, damage, weapon, bodypart)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	samp_C.sendTakeDmg(id, damage, weapon, bodypart)
end

function sf.sampSendRequestSpawn()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	samp_C.sendReqSpwn()
end

function sf.sampSetSendrate(_type, rate)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	type = tonumber(_type) or 0
	rate = tonumber(rate) or 0
	local addrs = {
		0xEC0A8, 0xEC0AC, 0xEC0B0
	}
	if addrs[type] then
		memory.setuint32(samp_dll + addrs[_type], rate, true)
	end
end

function sf.sampGetAnimationNameAndFile(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	local name, file = ffi.string(samp_C.anim_list[id - 1]):match('(.*):(.*)')
	return name or '', file or ''
end

function sf.sampFindAnimationIdByNameAndFile(file, name)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	for i = 0, sizeof(samp_C.anim_list) / 36 do
		local n, f = sf.sampGetAnimationNameAndFile(i)
		if n == name and f == file then return i end
	end
	return -1
end

-- stDialogInfo

function sf.sampIsDialogActive()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return samp_C.dialog.iIsActive == 1
end

function sf.sampGetDialogCaption()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return str(samp_C.dialog.szCaption)
end

function sf.sampGetCurrentDialogId()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return samp_C.dialog.DialogID
end

function sf.sampGetDialogText()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return str(samp_C.dialog.pText)
end

function sf.sampGetCurrentDialogType()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return samp_C.dialog.iType
end

function sf.sampShowDialog(id, caption, text, button1, button2, style)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	local caption = cast('PCHAR', tostring(caption))
	local text = cast('PCHAR', tostring(text))
	local button1 = cast('PCHAR', tostring(button1))
	local button2 = cast('PCHAR', tostring(button2))
	samp_C.showDialog(samp_C.dialog, id, style, caption, text, button1, button2, false)
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
	samp_C.closeDialog(samp_C.dialog, button)
end

function sf.sampGetCurrentDialogEditboxText()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	local char = samp_C.getEditboxText(samp_C.dialog.pEditBox)
	return str(char)
end

function sf.sampSetCurrentDialogEditboxText(text)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	samp_C.setEditboxText(samp_C.dialog.pEditBox, cast('PCHAR', text), 0)
end

function sf.sampIsDialogClientside()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return samp_C.dialog.bServerside ~= 0
end

function sf.sampSetDialogClientside(client)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	samp_C.dialog.bServerside = client and 0 or 1
end

-- stGameInfo

function sf.sampToggleCursor(showed)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	samp_C.showCursor(samp_C.misc, showed == true and sf.CMODE_LOCKCAM or sf.CMODE_DISABLED, showed)
	if showed ~= true then samp_C.cursorUnlockActorCam(samp_C.misc) end
end

function sf.sampIsCursorActive()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return samp_C.misc.iCursorMode > 0
end

function sf.sampGetCursorMode()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return samp_C.misc.iCursorMode
end

function sf.sampSetCursorMode(mode)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	samp_C.misc.iCursorMode = tonumber(mode) or 0
end

-- stPlayerPool

function sf.sampIsPlayerConnected(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	if id >= 0 and id < sf.SAMP_MAX_PLAYERS then
		return samp_C.player.iIsListed[id] == 1 or sf.sampGetLocalPlayerId() == id
	end
	return false
end

function sf.sampGetPlayerNickname(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	local char
	if sf.sampGetLocalPlayerId() == id then char = cast('PCSTR', samp_C.player.strLocalPlayerName)
	elseif sf.sampIsPlayerConnected(id) then char = cast('PCSTR', samp_C.player.pRemotePlayer[id].strPlayerName) end
	return char and str(char) or ''
end

function sf.sampSpawnPlayer()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	samp_C.reqSpawn(samp_C.player.pLocalPlayer)
	samp_C.spawn(samp_C.player.pLocalPlayer)
end

function sf.sampSendChat(msg)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	local char = cast('PCHAR', tostring(msg))
	if char[0] == 47 then
		samp_C.sendCMD(samp_C.input, char)
	else
		samp_C.say(samp_C.player.pLocalPlayer, char)
	end
end

function sf.sampIsPlayerNpc(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	return sf.sampIsPlayerConnected(id) and samp_C.player.pRemotePlayer[id].iIsNPC == 1
end

function sf.sampGetPlayerScore(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	local score = 0
	if sf.sampGetLocalPlayerId() == id then score = samp_C.player.iLocalPlayerScore
	elseif sf.sampIsPlayerConnected(id) then score = samp_C.player.pRemotePlayer[id].iScore end
	return score
end

function sf.sampGetPlayerPing(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	local ping = 0
	if sf.sampGetLocalPlayerId() == id then ping = samp_C.player.iLocalPlayerPing
	elseif sf.sampIsPlayerConnected(id) then ping = samp_C.player.pRemotePlayer[id].iPing end
	return ping
end

function sf.sampRequestClass(class)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	class = tonumber(class) or 0
	samp_C.reqClass(samp_C.player.pLocalPlayer, class)
end

function sf.sampGetPlayerColor(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	if sf.sampIsPlayerConnected(id) or sf.sampGetLocalPlayerId() == id then
		return kernel.convertRGBAToARGB(samp_C.color_table[id])
	end
end

function sf.sampSendInteriorChange(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	samp_C.sendInt(samp_C.player.pLocalPlayer, id)
end

function sf.sampForceUnoccupiedSyncSeatId(id, seat)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	seat = tonumber(seat) or 0
	samp_C.forceUnocSync(samp_C.player.pLocalPlayer, id, seat)
end

function sf.sampGetCharHandleBySampPlayerId(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	if id == sf.sampGetLocalPlayerId() then return true, playerPed
	elseif sf.sampIsPlayerDefined(id) then
		return true, getCharPointerHandle(kernel.getAddressByCData(samp_C.player.pRemotePlayer[id].pPlayerData.pSAMP_Actor.pGTA_Ped))
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
		return samp_C.player.pRemotePlayer[id].pPlayerData.fActorArmor
	end
	return 0
end

function sf.sampGetPlayerHealth(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	if sf.sampIsPlayerDefined(id) then
		if id == sf.sampGetLocalPlayerId() then return getCharHealth(playerPed) end
		return samp_C.player.pRemotePlayer[id].pPlayerData.fActorHealth
	end
	return 0
end

function sf.sampSetSpecialAction(action)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	action = tonumber(action) or 0
	if sf.sampIsPlayerDefined(sf.sampGetLocalPlayerId()) then
		samp_C.setAction(samp_C.player.pLocalPlayer, action)
	end
end

function sf.sampGetPlayerCount(streamed)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	if not streamed then return samp_C.scoreboard.iPlayersCount - 1 end
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
	if sf.sampIsPlayerConnected(id) then return samp_C.player.pRemotePlayer[i].pPlayerData.byteSpecialAction end
	return -1
end

function sf.sampStorePlayerOnfootData(id, data)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	data = tonumber(data) or 0
	local struct
	if id == sf.sampGetLocalPlayerId() then struct = samp_C.player.pLocalPlayer.onFootData
	elseif sf.sampIsPlayerDefined(id) then struct = samp_C.player.pRemotePlayer[id].pPlayerData.onFootData end
	if struct then memory.copy(data, kernel.getAddressByCData(struct), sizeof('struct onFootData')) end
end

function sf.sampIsPlayerPaused(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	if id == sf.sampGetLocalPlayerId() then return false end
	if sf.sampIsPlayerConnected(id) then return samp_C.player.pRemotePlayer[id].pPlayerData.iAFKState == 0 end
end

function sf.sampStorePlayerIncarData(id, data)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	data = tonumber(data) or 0
	local struct
	if id == sf.sampGetLocalPlayerId() then struct = samp_C.player.pLocalPlayer.inCarData
	elseif sf.sampIsPlayerDefined(id) then struct = samp_C.player.pRemotePlayer[id].pPlayerData.inCarData end
	if struct then memory.copy(data, kernel.getAddressByCData(struct), sizeof('struct stInCarData')) end
end

function sf.sampStorePlayerPassengerData(id, data)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	data = tonumber(data) or 0
	local struct
	if id == sf.sampGetLocalPlayerId() then struct = samp_C.player.pLocalPlayer.passengerData
	elseif sf.sampIsPlayerDefined(id) then struct = samp_C.player.pRemotePlayer[id].pPlayerData.passengerData end
	if struct then memory.copy(data, kernel.getAddressByCData(struct), sizeof('struct stPassengerData')) end
end

function sf.sampStorePlayerTrailerData(id, data)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	data = tonumber(data) or 0
	local struct
	if id == sf.sampGetLocalPlayerId() then struct = samp_C.player.pLocalPlayer.trailerData
	elseif sf.sampIsPlayerDefined(id) then struct = samp_C.player.pRemotePlayer[id].pPlayerData.trailerData end
	if struct then memory.copy(data, kernel.getAddressByCData(struct), sizeof('struct stTrailerData')) end
end

function sf.sampStorePlayerAimData(id, data)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	data = tonumber(data) or 0
	local struct
	if id == sf.sampGetLocalPlayerId() then struct = samp_C.player.pLocalPlayer.aimData
	elseif sf.sampIsPlayerDefined(id) then struct = samp_C.player.pRemotePlayer[id].pPlayerData.aimData end
	if struct then memory.copy(data, kernel.getAddressByCData(struct), sizeof('struct stAimData')) end
end

function sf.sampSendSpawn()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	samp_C.spawn(samp_C.player.pLocalPlayer)
end

function sf.sampGetPlayerAnimationId(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	if id == sf.sampGetLocalPlayerId() then return samp_C.player.pLocalPlayer.sCurrentAnimID end
	if sf.sampIsPlayerConnected(id) then return samp_C.player.pRemotePlayer[id].pPlayerData.onFootData.sCurrentAnimationID end
end

function sf.sampSetLocalPlayerName(name)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	local name = tostring(name)
	assert(#name <= sf.SAMP_MAX_PLAYER_NAME, 'Limit name - '..sf.SAMP_MAX_PLAYER_NAME..'.')
	samp_C.setName(kernel.getAddressByCData(samp_C.player) + offsetof('struct stPlayerPool', 'pVTBL_txtHandler'), name, #name)
end

function sf.sampGetPlayerStructPtr(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	if id == sf.sampGetLocalPlayerId() then return kernel.getAddressByCData(samp_C.player.pLocalPlayer) end
	if sf.sampIsPlayerConnected(id) then
		return kernel.getAddressByCData(samp_C.player.pRemotePlayer[id])
	end
end

function sf.sampSendEnterVehicle(id, passenger)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	samp_C.sendEnterVehicle(samp_C.player.pLocalPlayer, id, passenger)
end

function sf.sampSendExitVehicle(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	samp_C.sendExitVehicle(samp_C.player.pLocalPlayer, id)
end

-- stInputInfo

function sf.sampUnregisterChatCommand(name)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	for i = 0, sf.SAMP_MAX_CLIENTCMDS - 1 do
		if str(samp_C.input.szCMDNames[i]) == tostring(name) then
			samp_C.input.szCMDNames[i] = ffi.new('char[33]') --nchar(33)
			samp_C.input.pCMDs[i] = ffi.NULL
			samp_C.input.iCMDCount = samp_C.input.iCMDCount - 1
			return true
		end
	end
	return false
end

function sf.sampRegisterChatCommand(name, function_)
	local name = tostring(name)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	assert(type(function_) == 'function', '"'..tostring(function_)..'" is not function.')
	assert(samp_C.input.iCMDCount < sf.SAMP_MAX_CLIENTCMDS, 'Couldn\'t initialize "'..name..'". Maximum command amount reached.')
	assert(#name < 30, 'Command name "'..tostring(name)..'" was too long.')
	sf.sampUnregisterChatCommand(name)
	local char = cast('PCHAR', name)
	local func = ncmd(function(args)
		function_(str(args))
	end)
	samp_C.regCMD(samp_C.input, char, func)
	return true
end

function sf.sampSetChatInputText(text)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	samp_C.setEditboxText(samp_C.input.pDXUTEditBox, cast('PCHAR', text), 0)
end

function sf.sampGetChatInputText()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return str(samp_C.getEditboxText(samp_C.input.pDXUTEditBox))
end

function sf.sampSetChatInputEnabled(enabled)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	samp_C[enabled and 'enableInput' or 'disableInput'](samp_C.input)
end

function sf.sampIsChatInputActive()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return samp_C.input.pDXUTEditBox.bIsChatboxOpen == 1
end

function sf.sampIsChatCommandDefined(name)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	name = tostring(name)
	for i = 0, sf.SAMP_MAX_CLIENTCMDS - 1 do
		if str(samp_C.input.szCMDNames[i]) == name then return true end
	end
	return false
end

function sf.sampProcessChatInput(text)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	local char = cast('PCHAR', tostring(text))
	samp_C.say(samp_C.player.pLocalPlayer, char)
end

-- stChatInfo

function sf.sampAddChatMessage(text, color)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	sf.sampAddChatMessageEx(sf.CHAT_TYPE_DEBUG, text, '', color, -1)
end

function sf.sampGetChatDisplayMode()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return samp_C.chat.iChatWindowMode
end

function sf.sampSetChatDisplayMode(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	samp_C.chat.iChatWindowMode = id
end

function sf.sampGetChatString(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	return str(samp_C.chat.chatEntry[id].szText), str(samp_C.chat.chatEntry[id].szPrefix), samp_C.chat.chatEntry[id].clTextColor, samp_C.chat.chatEntry[id].clPrefixColor
end

function sf.sampSetChatString(id, text, prefix, color_t, color_p)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	samp_C.chat.chatEntry[id].szText = nchar(144, tostring(text))
	samp_C.chat.chatEntry[id].szPrefix = nchar(28, tostring(prefix))
	samp_C.chat.chatEntry[id].clTextColor = color_t
	samp_C.chat.chatEntry[id].clPrefixColor = color_p
end

function sf.sampIsChatVisible()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return sf.sampGetChatDisplayMode() > 0
end

-- stTextdrawPool

function sf.sampTextdrawIsExists(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	return samp_C.textdraw.iIsListed[id] == 1
end

function sf.sampTextdrawCreate(id, text, x, y)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	local transmit = new('stTextDrawTransmit[1]', { { fX = x, fY = y } })
	samp_C.createTextDraw(samp_C.textdraw, transmit, cast('PCHAR', tostring(text)))
end

function sf.sampTextdrawSetBoxColorAndSize(id, box, color, sizeX, sizeY)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	if sf.sampTextdrawIsExists(id) then
		samp_C.textdraw.textdraw[id].byteBox = box
		samp_C.textdraw.textdraw[id].dwBoxColor = color
		samp_C.textdraw.textdraw[id].fBoxSizeX = sizeX
		samp_C.textdraw.textdraw[id].fBoxSizeY = sizeY
	end
end

function sf.sampTextdrawGetString(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	if sf.sampTextdrawIsExists(id) then
		return samp_C.textdraw.textdraw[id].szText
	end
	return ''
end

function sf.sampTextdrawDelete(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	samp_C.deleteTextDraw(samp_C.textdraw, id)
end

function sf.sampTextdrawGetLetterSizeAndColor(id)
	if sf.sampTextdrawIsExists(id) then
		return samp_C.textdraw.textdraw[id].fLetterWidth, samp_C.textdraw.textdraw[id].fLetterHeight, kernel.convcolor(samp_C.textdraw.textdraw[id].dwLetterColor)
	end
end

function sf.sampTextdrawGetPos(id)
	if sf.sampTextdrawIsExists(id) then
		return samp_C.textdraw.textdraw[id].fX, samp_C.textdraw.textdraw[id].fY
	end
end

function sf.sampTextdrawGetShadowColor(id)
	if sf.sampTextdrawIsExists(id) then
		return samp_C.textdraw.textdraw[id].byteShadowSize, samp_C.textdraw.textdraw[id].dwShadowColor
	end
end

function sf.sampTextdrawGetOutlineColor(id)
	if sf.sampTextdrawIsExists(id) then
		return samp_C.textdraw.textdraw[id].byteOutline, samp_C.textdraw.textdraw[id].dwShadowColor
	end
end

function sf.sampTextdrawGetStyle(id)
	if sf.sampTextdrawIsExists(id) then
		return samp_C.textdraw.textdraw[id].iStyle
	end
end

function sf.sampTextdrawGetProportional(id)
	if sf.sampTextdrawIsExists(id) then
		return samp_C.textdraw.textdraw[id].byteProportional
	end
end

function sf.sampTextdrawGetAlign(id)
	if sf.sampTextdrawIsExists(id) then
		if samp_C.textdraw.textdraw[id].byteLeft == 1 then
			return 1
		elseif samp_C.textdraw.textdraw[id].byteCenter == 1 then
			return 2
		elseif samp_C.textdraw.textdraw[id].byteRight == 1 then
			return 3
		else
			return 0
		end
	end
end

function sf.sampTextdrawGetBoxEnabledColorAndSize(id)
	if sf.sampTextdrawIsExists(id) then
		return samp_C.textdraw.textdraw[id].byteBox, samp_C.textdraw.textdraw[id].dwBoxColor, samp_C.textdraw.textdraw[id].fBoxSizeX, samp_C.textdraw.textdraw[id].fBoxSizeY
	end
end

function sf.sampTextdrawGetModelRotationZoomVehColor(id)
	if sf.sampTextdrawIsExists(id) then
		return samp_C.textdraw.textdraw[id].sModel, samp_C.textdraw.textdraw[id].fRot[1], samp_C.textdraw.textdraw[id].fRot[2], samp_C.textdraw.textdraw[id].fRot[3], samp_C.textdraw.textdraw[id].fZoom, samp_C.textdraw.textdraw[id].sColor[1], samp_C.textdraw.textdraw[id].sColor[2]
	end
end

function sf.sampTextdrawSetLetterSizeAndColor(id, letSizeX, letSizeY, color)
	if sf.sampTextdrawIsExists(id) then
		samp_C.textdraw.textdraw[id].fLetterWidth = letSizeX
		samp_C.textdraw.textdraw[id].fLetterHeight = letSizeY
		samp_C.textdraw.textdraw[id].dwLetterColor = color
	end
end

function sf.sampTextdrawSetPos(id, posX, posY)
	if sf.sampTextdrawIsExists(id) then
		samp_C.textdraw.textdraw[id].fX = posX
		samp_C.textdraw.textdraw[id].fY = posY
	end
end

function sf.sampTextdrawSetString(id, str)
	if sf.sampTextdrawIsExists(id) then
		samp_C.textdraw.textdraw[id].szText = str
	end
end

function sf.sampTextdrawSetModelRotationZoomVehColor(id, model, rotX, rotY, rotZ, zoom, clr1, clr2)
	if sf.sampTextdrawIsExists(id) then
		samp_C.textdraw.textdraw[id].sModel = model
		samp_C.textdraw.textdraw[id].fRot[1] = rotX
		samp_C.textdraw.textdraw[id].fRot[2] = rotY
		samp_C.textdraw.textdraw[id].fRot[3] = rotZ
		samp_C.textdraw.textdraw[id].fZoom = zoom
		samp_C.textdraw.textdraw[id].sColor[1] = clr1
		samp_C.textdraw.textdraw[id].sColor[2] = clr2
	end
end

function sf.sampTextdrawSetOutlineColor(id, outline, color)
	if sf.sampTextdrawIsExists(id) then
		samp_C.textdraw.textdraw[id].byteOutline = outline
		samp_C.textdraw.textdraw[id].dwShadowColor = color
	end
end

function sf.sampTextdrawSetShadow(id, shadow, color)
	if sf.sampTextdrawIsExists(id) then
		samp_C.textdraw.textdraw[id].byteShadowSize = shadow
		samp_C.textdraw.textdraw[id].dwShadowColor = color
	end
end

function sf.sampTextdrawSetStyle(id, style)
	if sf.sampTextdrawIsExists(id) then
		samp_C.textdraw.textdraw[id].iStyle = style
	end
end

function sf.sampTextdrawSetProportional(id, proportional)
	if sf.sampTextdrawIsExists(id) then
		samp_C.textdraw.textdraw[id].byteProportional = proportional
	end
end

function sf.sampTextdrawSetAlign(id, align)
	if sf.sampTextdrawIsExists(id) then
		samp_C.textdraw.textdraw[id].byteLeft = 0
		samp_C.textdraw.textdraw[id].byteCenter = 0
		samp_C.textdraw.textdraw[id].byteRight = 0
		if align == 1 then
			samp_C.textdraw.textdraw[id].byteLeft = 1
		elseif align == 2 then
			samp_C.textdraw.textdraw[id].byteCenter = 1
		elseif align == 3 then
			samp_C.textdraw.textdraw[id].byteRight = 1
		end
	end
end

-- stScoreboardInfo

function sf.sampToggleScoreboard(showed)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	if showed then
		samp_C.enableScoreboard(samp_C.scoreboard)
	else
		samp_C.disableScoreboard(samp_C.scoreboard, true)
	end
end

function sf.sampIsScoreboardOpen()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	return samp_C.scoreboard.iIsEnabled == 1
end

-- stTextLabelPool

function sf.sampCreate3dText(text, color, x, y, z, dist, i_walls, id, vid)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	local text = cast('PCHAR', tostring(text))
	for i = 0, #sf.SAMP_MAX_3DTEXTS - 1 do
		if not sf.sampIs3dTextDefined(i) then
			samp_C.createTextLabel(samp_C.text3d, i, text, color, x, y, z, dist, i_walls, id, vid)
			return i
		end
	end
	return -1
end

function sf.sampIs3dTextDefined(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	return samp_C.text3d.iIsListed[id] == 1
end

function sf.sampGet3dTextInfoById(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	if sf.sampIs3dTextDefined(id) then
		local t = samp_C.text3d.textLabel[id]
		return str(t.pText), t.color, t.fPosition[0], t.fPosition[1], t.fPosition[2], t.fMaxViewDistance, t.byteShowBehindWalls == 1, t.sAttachedToPlayerID, t.sAttachedToVehicleID
	end
end

function sf.sampSet3dTextString(id, text)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	if sf.sampIs3dTextDefined(id) then
		samp_C.text3d.textLabel[id].pText = cast('PCHAR', tostring(text))
	end
end

function sf.sampDestroy3dText(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	if sf.sampIs3dTextDefined(id) then
		samp_C.deleteTextLabel(samp_C.text3d, id)
	end
end

function sf.sampCreate3dTextEx(i, text, color, x, y, z, dist, i_walls, id, vid)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	if sf.sampIs3dTextDefined(i) then sf.sampDestroy3dText(i) end
	local text = cast('PCHAR', tostring(text))
	samp_C.createTextLabel(samp_C.text3d, id, text, color, x, y, z, dist, i_walls, id, vid)
end

-- stVehiclePool

function sf.sampGetCarHandleBySampVehicleId(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	if sf.sampIsVehicleDefined(id) then return true, getVehiclePointerHandle(kernel.getAddressByCData(samp_C.car.pSAMP_Vehicle[id].pGTA_Vehicle)) end
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

function sf.raknetBitStreamReadBool(bitstream)
	bitstream = kernel.getStruct('BitStream', bitstream)
	return bitstream:ReadBit()
end

function sf.raknetBitStreamReadInt8(bitstream)
	bitstream = kernel.getStruct('BitStream', bitstream)
	local buf = nchar(1)
	bitstream:ReadBits(buf, 8, true)
	return buf[0]
end

function sf.raknetBitStreamReadInt16(bitstream)
	bitstream = kernel.getStruct('BitStream', bitstream)
	local buf = i16()
	bitstream:ReadBits(buf, 16, true)
	return buf[0]
end

function sf.raknetBitStreamReadInt32(bitstream)
	bitstream = kernel.getStruct('BitStream', bitstream)
	local buf = i32()
	bitstream:ReadBits(buf, 32, true)
	return buf[0]
end

function sf.raknetBitStreamReadFloat(bitstream)
	bitstream = kernel.getStruct('BitStream', bitstream)
	local buf = float()
	bitstream:ReadBits(buf, 32, true)
	return buf[0]
end

function sf.raknetBitStreamReadBuffer(bitstream, dest, size)
	bitstream = kernel.getStruct('BitStream', bitstream)
	bitstream:ReadBits(dest, size * 8, true)
end

function sf.raknetBitStreamReadString(bitstream, size)
	bitstream = kernel.getStruct('BitStream', bitstream)
	local buf = nchar(size + 1)
	bitstream:ReadBits(buf, size * 8, true)
	return str(buf)
end

function sf.raknetBitStreamResetReadPointer(bitstream)
	bitstream = kernel.getStruct('BitStream', bitstream)
	bitstream:ResetReadPointer()
end

function sf.raknetBitStreamResetWritePointer(bitstream)
	bitstream = kernel.getStruct('BitStream', bitstream)
	bitstream:ResetWritePointer()
end

function sf.raknetBitStreamIgnoreBits(bitstream, amount)
	bitstream = kernel.getStruct('BitStream', bitstream)
	bitstream:IgnoreBits(amount)
end

function sf.raknetBitStreamSetWriteOffset(bitstream, offset)
	bitstream = kernel.getStruct('BitStream', bitstream)
	bitstream:SetWriteOffset(offset)
end

function sf.raknetBitStreamSetReadOffset(bitstream, offset)
	bitstream = kernel.getStruct('BitStream', bitstream)
	bitstream.readOffset = offset
end

function sf.raknetBitStreamGetNumberOfBitsUsed(bitstream)
	bitstream = kernel.getStruct('BitStream', bitstream)
	return bitstream.numberOfBitsUsed
end

function sf.raknetBitStreamGetNumberOfBytesUsed(bitstream)
	local bits = sf.raknetBitStreamGetNumberOfBitsUsed(bitstream)
	return bit.rshift(bits + 7, 3)
end

function sf.raknetBitStreamGetNumberOfUnreadBits(bitstream)
	bitstream = kernel.getStruct('BitStream', bitstream)
	return bitstream.numberOfBitsAllocated - bitstream.numberOfBitsUsed
end

function sf.raknetBitStreamGetWriteOffset(bitstream)
	bitstream = kernel.getStruct('BitStream', bitstream)
	return bitstream.numberOfBitsUsed
end

function sf.raknetBitStreamGetReadOffset(bitstream)
	bitstream = kernel.getStruct('BitStream', bitstream)
	return bitstream.readOffset
end

function sf.raknetBitStreamGetDataPtr(bitstream)
	bitstream = kernel.getStruct('BitStream', bitstream)
	return kernel.getAddressByCData(bitstream.data)
end

function sf.raknetNewBitStream()
	local bitstream = bs()
	return kernel.getAddressByCData(bitstream)
end

function sf.raknetDeleteBitStream(bitstream)
	bitstream = kernel.getStruct('BitStream', bitstream)
	bitstream:__gc()
end

function sf.raknetResetBitStream(bitstream)
	bitstream = kernel.getStruct('BitStream', bitstream)
	bitstream:Reset()
end

function sf.raknetBitStreamWriteBool(bitstream, value)
	bitstream = kernel.getStruct('BitStream', bitstream)
	if value then bitstream:Write1()
	else bitstream:Write0() end
end

function sf.raknetBitStreamWriteInt8(bitstream, value)
	bitstream = kernel.getStruct('BitStream', bitstream)
	local buf = nchar(1, value)
	bitstream:WriteBits(buf, 8, true)
end

function sf.raknetBitStreamWriteInt16(bitstream, value)
	bitstream = kernel.getStruct('BitStream', bitstream)
	local buf = i16(value)
	bitstream:WriteBits(buf, 16, true)
end

function sf.raknetBitStreamWriteInt32(bitstream, value)
	bitstream = kernel.getStruct('BitStream', bitstream)
	local buf = i32(value)
	bitstream:WriteBits(buf, 32, true)
end

function sf.raknetBitStreamWriteFloat(bitstream, value)
	bitstream = kernel.getStruct('BitStream', bitstream)
	local buf = float(value)
	bitstream:WriteBits(buf, 32, true)
end

function sf.raknetBitStreamWriteBuffer(bitstream, dest, size)
	bitstream = kernel.getStruct('BitStream', bitstream)
	bitstream:WriteBits(dest, size * 8, true)
end

function sf.raknetBitStreamWriteString(bitstream, str)
	bitstream = kernel.getStruct('BitStream', bitstream)
	local buf = nchar(#str + 1, str)
	bitstream:WriteBits(buf, #str * 8, true)
end

function sf.raknetBitStreamDecodeString(bitstream, size)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	bitstream = kernel.getStruct('BitStream', bitstream)
	local buf = nchar(size + 1)
	local this = cast('void**', samp_dll + 0x10D894)
	samp_C.readDecodeString(this[0], buf, size, bitstream, 0)
	return str(buf)
end

function sf.raknetBitStreamEncodeString(bitstream, str)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	bitstream = kernel.getStruct('BitStream', bitstream)
	local buf = nchar(#str + 1, str)
	local this = cast('void**', samp_dll + 0x10D894)
	samp_C.writeEncodeString(this[0], buf, #str, bitstream, 0)
end

-- RakClient

--[[function sf.sampSendDeathByPlayer(id, reason)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	local bitstream = bs()
	bitstream:WriteBits(nchar(1, reason), 8, true)
	bitstream:WriteBits(i16(id), 16, true)
	sf.raknetSendRpcEx(53, kernel.getAddressByCData(bitstream), 1, 8, 0, false)
	bitstream:__gc()
end

function sf.raknetSendRpcEx(rpc, bitstream, priority, reliability, channel, timestamp)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	rpc = nchar(1, rpc)
	originals.onSendRpc(rpc, cast('PCHAR', bitstream), priority, reliability, channel, timestamp)
end]]

function sf.raknetGetRpcName(id)
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

function sf.raknetGetPacketName(id)
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

function sf.sampGetStreamedOutPlayerPos(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	local res, handle = sf.sampGetCharHandleBySampPlayerId(id)
	if res == true and doesCharExist(handle) then
		return false, getCharCoordinates(handle)
	else
		return hook.StreamedOutInfo(id)
	end
end

--- New functions

-- stVehiclePool

function sf.sampIsVehicleDefined(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	return samp_C.car.iIsListed[id] == 1 and samp_C.car.pSAMP_Vehicle[id] and samp_C.car.pSAMP_Vehicle[id].pGTA_Vehicle
end

-- stPlayerPool

function sf.sampIsPlayerDefined(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	if id == sf.sampGetLocalPlayerId() then return samp_C.player.pLocalPlayer ~= nil end
	return sf.sampIsPlayerConnected(id) and samp_C.player.pRemotePlayer[id] and samp_C.player.pRemotePlayer[id].pPlayerData and
		samp_C.player.pRemotePlayer[id].pPlayerData.pSAMP_Actor and samp_C.player.pRemotePlayer[id].pPlayerData.pSAMP_Actor.actor_info
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
	return samp_C.player.sLocalPlayerID
end

function sf.sampSetPlayerColor(id, color)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id)
	if sf.sampIsPlayerConnected(id) or sf.sampGetLocalPlayerId() == id then
		color_table[id] = kernel.convertARGBToRGBA(color)
	end
end

function sf.sampIsLocalPlayerSpawned()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	local local_player = samp_C.player.pLocalPlayer
	return local_player.iSpawnClassLoaded == 1 and local_player.iIsActorAlive == 1 and ( local_player.iIsActive == 1 or isCharDead(playerPed) )
end

-- Pointers to structures

function sf.sampGetScoreboardInfoPtr()
	assert(sf.isSampLoaded(), 'SA-MP is not loaded.')
	return memory.getint32( sf.sampGetBase() + SAMP_SCOREBOARD_INFO )
end

-- stChatInfo

function sf.sampAddChatMessageEx(_type, text, prefix, textColor, prefixColor)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	local char = cast('PCSTR', tostring(text))
	local charPrefix = prefix and cast('PCSTR', tostring(prefix))
	samp_C.addMessage(samp_C.chat, _type, char, charPrefix, textColor, prefixColor)
end

-- stPickupPool

function sf.sampGetPickupModelTypeBySampId(id)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	id = tonumber(id) or 0
	if samp_C.pickup.pickup[id] then return samp_C.pickup.pickup[id].iModelID, samp_C.pickup.pickup[id].iType end
	return -1, -1
end

-- stKillInfo

function sf.sampAddDeathMessage(killer, killed, clkiller, clkilled, reason)
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	local killer = cast('PCHAR', killer)
	local killed = cast('PCHAR', killed)
	samp_C.sendDeathMessage(samp_C.killinfo, killer, killed, clkiller, clkilled, reason)
end

-- stDialogInfo

function sf.sampGetDialogButtons()
	assert(sf.isSampAvailable(), 'SA-MP is not available.')
	local dialog = samp_C.dialog.pDialog
	local b1p = samp_C.getElementSturct(dialog, 20, 0) + 0x4D
	local b2p = samp_C.getElementSturct(dialog, 21, 0) + 0x4D
	return str(b1p), str(b2p)
end

--- Hook

if script.this.name == 'SFL_Hook' then return sf end

local res
res, hook = pcall(import, 'lib\\SAMPFUNCSLUA\\hook.lua')

return sf