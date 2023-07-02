--[[
    Project: SF.lua <https://github.com/imring/SF.lua>
    License: MIT License
    Author: imring
]]

local sampapi = require 'sampapi'
local shared = require 'sampapi.shared'
local ffi = shared.ffi

local netgame = sampapi.require('CNetGame', true)
local rakluaLoaded, raklua = pcall(require, 'RakLua')

if not rakluaLoaded then
require 'sflua.cdef.bitstream'
local StringCompressor = require 'sflua.cdef.stringcompressor'

function raknetBitStreamReadBool(bitstream)
    bitstream = ffi.cast('SBitStream*', bitstream)
    return bitstream:ReadBit()
end

function raknetBitStreamReadBuffer(bitstream, dest, size)
    bitstream = ffi.cast('SBitStream*', bitstream)
    bitstream:ReadBits(dest, size * 8, true)
end

function raknetBitStreamReadInt8(bitstream)
    local buf = ffi.new('char[1]')
    raknetBitStreamReadBuffer(bitstream, buf, ffi.sizeof(buf))
    return buf[0]
end

function raknetBitStreamReadInt16(bitstream)
    local buf = ffi.new('short[1]')
    raknetBitStreamReadBuffer(bitstream, buf, ffi.sizeof(buf))
    return buf[0]
end

function raknetBitStreamReadInt32(bitstream)
    local buf = ffi.new('long [1]')
    raknetBitStreamReadBuffer(bitstream, buf, ffi.sizeof(buf))
    return buf[0]
end

function raknetBitStreamReadFloat(bitstream)
    local buf = ffi.new('float[1]')
    raknetBitStreamReadBuffer(bitstream, buf, ffi.sizeof(buf))
    return buf[0]
end

function raknetBitStreamReadString(bitstream, size)
    local buf = ffi.new('char[?]', size + 1)
    raknetBitStreamReadBuffer(bitstream, buf, ffi.sizeof(buf) - 1)
    buf[size] = 0
    return ffi.string(buf)
end

function raknetBitStreamResetReadPointer(bitstream)
    bitstream = ffi.cast('SBitStream*', bitstream)
    bitstream:ResetReadPointer()
end

function raknetBitStreamResetWritePointer(bitstream)
    bitstream = ffi.cast('SBitStream*', bitstream)
    bitstream:ResetWritePointer()
end

function raknetBitStreamIgnoreBits(bitstream, amount)
    bitstream = ffi.cast('SBitStream*', bitstream)
    bitstream:IgnoreBits(amount)
end

function raknetBitStreamSetWriteOffset(bitstream, offset)
    bitstream = ffi.cast('SBitStream*', bitstream)
    bitstream:SetWriteOffset(offset)
end

function raknetBitStreamSetReadOffset(bitstream, offset)
    bitstream = ffi.cast('SBitStream*', bitstream)
    bitstream.readOffset = offset
end

function raknetBitStreamGetNumberOfBitsUsed(bitstream)
    bitstream = ffi.cast('SBitStream*', bitstream)
    return bitstream.numberOfBitsUsed
end

function raknetBitStreamGetNumberOfBytesUsed(bitstream)
    local bits = raknetBitStreamGetNumberOfBitsUsed(bitstream)
    return bit.rshift(bits + 7, 3)
end

function raknetBitStreamGetNumberOfUnreadBits(bitstream)
    bitstream = ffi.cast('SBitStream*', bitstream)
    return bitstream.numberOfBitsAllocated - bitstream.numberOfBitsUsed
end

function raknetBitStreamGetWriteOffset(bitstream)
    bitstream = ffi.cast('SBitStream*', bitstream)
    return bitstream.numberOfBitsUsed
end

function raknetBitStreamGetReadOffset(bitstream)
    bitstream = ffi.cast('SBitStream*', bitstream)
    return bitstream.readOffset
end

function raknetBitStreamGetDataPtr(bitstream)
    bitstream = ffi.cast('SBitStream*', bitstream)
    return shared.get_pointer(bitstream.data)
end

function raknetNewBitStream()
    local bitstream = bs()
    return shared.get_pointer(bitstream)
end

function raknetDeleteBitStream(bitstream)
    bitstream = ffi.cast('SBitStream*', bitstream)
    bitstream:__gc()
end

function raknetResetBitStream(bitstream)
    bitstream = ffi.cast('SBitStream*', bitstream)
    bitstream:Reset()
end

function raknetBitStreamWriteBool(bitstream, value)
    bitstream = ffi.cast('SBitStream*', bitstream)
    if value then bitstream:Write1()
    else bitstream:Write0() end
end

function raknetBitStreamWriteInt8(bitstream, value)
    local buf = ffi.new('char[1]', value)
    raknetBitStreamWriteBuffer(bitstream, buf, ffi.sizeof(buf))
end

function raknetBitStreamWriteInt16(bitstream, value)
    local buf = ffi.new('short[1]', value)
    raknetBitStreamWriteBuffer(bitstream, buf, ffi.sizeof(buf))
end

function raknetBitStreamWriteInt32(bitstream, value)
    local buf = ffi.new('long[1]', value)
    raknetBitStreamWriteBuffer(bitstream, buf, ffi.sizeof(buf))
end

function raknetBitStreamWriteFloat(bitstream, value)
    local buf = ffi.new('float[1]', value)
    raknetBitStreamWriteBuffer(bitstream, buf, ffi.sizeof(buf))
end

function raknetBitStreamWriteBuffer(bitstream, dest, size)
    bitstream = ffi.cast('SBitStream*', bitstream)
    bitstream:WriteBits(dest, size * 8, true)
end

function raknetBitStreamWriteString(bitstream, str)
    local buf = ffi.new('char[?]', #str + 1, str)
    raknetBitStreamWriteBuffer(bitstream, buf, ffi.sizeof(buf) - 1)
end

function raknetBitStreamDecodeString(bitstream, size)
    bitstream = ffi.cast('SBitStream*', bitstream)
    local buf = ffi.new('char[?]', size + 1)
    StringCompressor.Instance():DecodeString(buf, size, bitstream, 0)
    buf[size] = 0
    return ffi.string(buf)
end

function raknetBitStreamEncodeString(bitstream, str)
    bitstream = ffi.cast('SBitStream*', bitstream)
    local buf = ffi.new('char[?]', #str + 1, str)
    StringCompressor.Instance():EncodeString(buf, #str, bitstream, 0)
end

function raknetBitStreamWriteBitStream(bitstream, bitStream)
    bitstream = ffi.cast('SBitStream*', bitstream)
    bitstream:Write(bitStream)
end

function raknetSendRpcEx(rpc, bs, priority, reliability, channel, timestamp)
    local rakclient = ffi.cast('void***', netgame.m_pRakClient)
    local vtbl = rakclient[0]
    rpc = ffi.new('int[1]', rpc)
    bs = ffi.cast('SBitStream*', bs)

    -- RPC(int *uniqueID, RakNet::BitStream *bitStream, PacketPriority priority, PacketReliability reliability, char orderingChannel, bool shiftTimestamp)
    local RPC = ffi.cast('bool(__thiscall *)(void *, int *, SBitStream *, int, int, char, bool)', vtbl[25])
    return RPC(rakclient, rpc, bs, priority, reliability, channel, timestamp)
end

function raknetSendBitStreamEx(bs, priority, reliability, channel)
    local rakclient = ffi.cast('void***', netgame.m_pRakClient)
    local vtbl = rakclient[0]
    bs = ffi.cast('SBitStream*', bs)

    -- Send(RakNet::BitStream *bitStream, PacketPriority priority, PacketReliability reliability, char orderingChannel)
    local Send = ffi.cast('bool(__thiscall *)(void *, SBitStream *, int, int, char)', vtbl[6])
    return Send(rakclient, bs, priority, reliability, channel)
end

function raknetSendRpc(rpc, bs)
    return raknetSendRpcEx(rpc, bs, HIGH_PRIORITY, RELIABLE, 0, false)
end

function raknetSendBitStream(bs)
    return raknetSendBitStreamEx(bs, HIGH_PRIORITY, UNRELIABLE_SEQUENCED, 0)
end

end

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

function sampGetRakclientInterface()
    return shared.get_pointer(netgame.m_pRakClient)
end

function sampGetRakpeer()
    return shared.get_pointer(netgame.m_pRakClient) - 0xDDE -- 0xDDE = sizeof(RakPeer)
end

function sampSendAimData(data)
    local bs = raknetNewBitStream()
    raknetBitStreamReadInt8(bs, PACKET_AIM_SYNC)
    raknetBitStreamWriteBuffer(bs, data, ffi.sizeof('SAimData'))
    raknetSendBitStream(bs)
    raknetDeleteBitStream(bs)
end

function sampSendBulletData(data)
    local bs = raknetNewBitStream()
    raknetBitStreamReadInt8(bs, PACKET_BULLET_SYNC)
    raknetBitStreamWriteBuffer(bs, data, ffi.sizeof('SBulletData'))
    raknetSendBitStream(bs)
    raknetDeleteBitStream(bs)
end

function sampSendIncarData(data)
    local bs = raknetNewBitStream()
    raknetBitStreamReadInt8(bs, PACKET_VEHICLE_SYNC)
    raknetBitStreamWriteBuffer(bs, data, ffi.sizeof('SIncarData'))
    raknetSendBitStream(bs)
    raknetDeleteBitStream(bs)
end

function sampSendOnfootData(data)
    local bs = raknetNewBitStream()
    raknetBitStreamReadInt8(bs, PACKET_PLAYER_SYNC)
    raknetBitStreamWriteBuffer(bs, data, ffi.sizeof('SOnfootData'))
    raknetSendBitStream(bs)
    raknetDeleteBitStream(bs)
end

function sampSendSpectatorData(data)
    local bs = raknetNewBitStream()
    raknetBitStreamReadInt8(bs, PACKET_SPECTATOR_SYNC)
    raknetBitStreamWriteBuffer(bs, data, ffi.sizeof('SSpectatorData'))
    raknetSendBitStream(bs)
    raknetDeleteBitStream(bs)
end

function sampSendTrailerData(data)
    local bs = raknetNewBitStream()
    raknetBitStreamReadInt8(bs, PACKET_TRAILER_SYNC)
    raknetBitStreamWriteBuffer(bs, data, ffi.sizeof('STrailerData'))
    raknetSendBitStream(bs)
    raknetDeleteBitStream(bs)
end

function sampSendPassengerData(data)
    local bs = raknetNewBitStream()
    raknetBitStreamReadInt8(bs, PACKET_PASSENGER_SYNC)
    raknetBitStreamWriteBuffer(bs, data, ffi.sizeof('SPassengerData'))
    raknetSendBitStream(bs)
    raknetDeleteBitStream(bs)
end

function sampSendUnoccupiedData(data)
    local bs = raknetNewBitStream()
    raknetBitStreamReadInt8(bs, PACKET_UNOCCUPIED_SYNC)
    raknetBitStreamWriteBuffer(bs, data, ffi.sizeof('SUnoccupiedData'))
    raknetSendBitStream(bs)
    raknetDeleteBitStream(bs)
end

function sampSendDamageVehicle(car, panel, doors, lights, tires)
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt16(bs, car) -- TODO: is car a handle or an id?
    raknetBitStreamWriteInt32(bs, panel)
    raknetBitStreamWriteInt32(bs, doors)
    raknetBitStreamWriteInt8(bs, lights)
    raknetBitStreamWriteInt8(bs, tires)
    raknetSendRpc(RPC_DAMAGEVEHICLE, bs)
    raknetDeleteBitStream(bs)
end

function sampSendScmEvent(event, id, param1, param2)
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt32(bs, id)
    raknetBitStreamWriteInt32(bs, param1)
    raknetBitStreamWriteInt32(bs, param2)
    raknetBitStreamWriteInt32(bs, event)
    raknetSendRpc(RPC_SCMEVENT, bs)
    raknetDeleteBitStream(bs)
end

function sampSendGiveDamage(id, damage, weapon, bodypart)
    local bs = raknetNewBitStream()
    raknetBitStreamWriteBool(bs, false)
    raknetBitStreamWriteInt16(bs, id)
    raknetBitStreamWriteFloat(bs, damage)
    raknetBitStreamWriteInt32(bs, weapon)
    raknetBitStreamWriteInt32(bs, bodypart)
    raknetSendRpc(RPC_GIVETAKEDAMAGE, bs)
    raknetDeleteBitStream(bs)
end

function sampSendTakeDamage(id, damage, weapon, bodypart)
    local bs = raknetNewBitStream()
    raknetBitStreamWriteBool(bs, true)
    raknetBitStreamWriteInt16(bs, id)
    raknetBitStreamWriteFloat(bs, damage)
    raknetBitStreamWriteInt32(bs, weapon)
    raknetBitStreamWriteInt32(bs, bodypart)
    raknetSendRpc(RPC_GIVETAKEDAMAGE, bs)
    raknetDeleteBitStream(bs)
end

function sampSendRequestSpawn()
    local bs = raknetNewBitStream()
    raknetSendRpc(RPC_REQUESTSPAWN, bs)
    raknetDeleteBitStream(bs)
end

function sampSendClickPlayer(id, source)
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt16(bs, id)
    raknetBitStreamWriteInt8(bs, source)
    raknetSendRpc(RPC_CLICKPLAYER, bs)
    raknetDeleteBitStream(bs)
end

function sampSendClickTextdraw(id)
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt16(bs, id)
    raknetSendRpc(RPC_CLICKTEXTDRAW, bs)
    raknetDeleteBitStream(bs)
end

function sampSendDeathByPlayer(playerId, reason)
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt8(bs, reason)
    raknetBitStreamWriteInt16(bs, playerId)
    raknetSendRpc(RPC_DEATH, bs)
    raknetDeleteBitStream(bs)
end

function sampSendDialogResponse(id, button, listitem, input)
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt16(bs, id)
    raknetBitStreamWriteInt8(bs, button)
    raknetBitStreamWriteInt16(bs, listitem)
    raknetBitStreamWriteInt8(bs, #input)
    raknetBitStreamWriteString(bs, input)
    raknetSendRpc(RPC_DIALOGRESPONSE, bs)
    raknetDeleteBitStream(bs)
end

function sampSendEditAttachedObject(response, index, model, bone, offsetX, offsetY, offsetZ, rotX, rotY, rotZ, scaleX, scaleY, scaleZ)
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt32(bs, response)
    raknetBitStreamWriteInt32(bs, index)
    raknetBitStreamWriteInt32(bs, model)
    raknetBitStreamWriteInt32(bs, bone)
    raknetBitStreamWriteFloat(bs, offsetX)
    raknetBitStreamWriteFloat(bs, offsetY)
    raknetBitStreamWriteFloat(bs, offsetZ)
    raknetBitStreamWriteFloat(bs, rotX)
    raknetBitStreamWriteFloat(bs, rotY)
    raknetBitStreamWriteFloat(bs, rotZ)
    raknetBitStreamWriteFloat(bs, scaleX)
    raknetBitStreamWriteFloat(bs, scaleY)
    raknetBitStreamWriteFloat(bs, scaleZ)
    -- TODO: color1/color2?
    raknetSendRpc(RPC_EDITATTACHEDOBJECT, bs)
    raknetDeleteBitStream(bs)
end

function sampSendEditObject(playerObject, objectId, response, posX, posY, posZ, rotX, rotY, rotZ)
    local bs = raknetNewBitStream()
    raknetBitStreamWriteBool(bs, playerObject)
    raknetBitStreamWriteInt16(bs, objectId)
    raknetBitStreamWriteInt32(bs, response)
    raknetBitStreamWriteFloat(bs, posX)
    raknetBitStreamWriteFloat(bs, posY)
    raknetBitStreamWriteFloat(bs, posZ)
    raknetBitStreamWriteFloat(bs, rotX)
    raknetBitStreamWriteFloat(bs, rotY)
    raknetBitStreamWriteFloat(bs, rotZ)
    raknetSendRpc(RPC_EDITOBJECT, bs)
    raknetDeleteBitStream(bs)
end

function sampSendMenuQuit()
    local bs = raknetNewBitStream()
    raknetSendRpc(RPC_MENUQUIT, bs)
    raknetDeleteBitStream(bs)
end

function sampSendMenuSelectRow(id)
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt8(bs, id)
    raknetSendRpc(RPC_MENUSELECT, bs)
    raknetDeleteBitStream(bs)
end

function sampSendPickedUpPickup(id)
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt32(bs, id)
    raknetSendRpc(RPC_PICKEDUPPICKUP, bs)
    raknetDeleteBitStream(bs)
end

function sampSendRconCommand(cmd)
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt8(bs, PACKET_RCON_COMMAND)
    raknetBitStreamWriteInt32(bs, #cmd)
    raknetBitStreamWriteString(bs, cmd)
    raknetSendBitStream(bs)
    raknetDeleteBitStream(bs)
end

function sampSendVehicleDestroyed(id)
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt16(bs, id)
    raknetSendRpc(RPC_VEHICLEDESTROYED, bs)
    raknetDeleteBitStream(bs)
end