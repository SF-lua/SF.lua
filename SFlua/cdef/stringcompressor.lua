local sampapi = require 'sampapi'
--[[
    Project: SF.lua <https://github.com/imring/SF.lua>
    License: MIT License
    Author: imring
]]

local shared = require 'sampapi.shared'
local mt = require 'sampapi.metatype'
local ffi = shared.ffi

ffi.cdef[[
typedef struct StringCompressor StringCompressor;
]]

local Instance_addr = {
    [ffi.C.SAMP_VERSION_037R1] = 0x50140,
    [ffi.C.SAMP_VERSION_037R3_1] = 0x534F0,
    [ffi.C.SAMP_VERSION_037R5_1] = 0x53C30
}

local StringCompressor_DecodeString_addr = {
    [ffi.C.SAMP_VERSION_037R1] = 0x507E0,
    [ffi.C.SAMP_VERSION_037R3_1] = 0x53B90,
    [ffi.C.SAMP_VERSION_037R5_1] = 0x542D0
}

local StringCompressor_EncodeString_addr = {
    [ffi.C.SAMP_VERSION_037R1] = 0x506B0,
    [ffi.C.SAMP_VERSION_037R3_1] = 0x53A60,
    [ffi.C.SAMP_VERSION_037R5_1] = 0x541A0
}

local Instance = ffi.cast('StringCompressor*(__cdecl*)()', sampapi.GetAddress(Instance_addr[sampapi.GetSAMPVersion()]))

local StringCompressor_mt = {
    DecodeString = ffi.cast('bool(__thiscall*)(StringCompressor *, char *, int, SBitStream *, int)', sampapi.GetAddress(StringCompressor_DecodeString_addr[sampapi.GetSAMPVersion()])),
    EncodeString = ffi.cast('void(__thiscall*)(StringCompressor *, const char *, int, SBitStream *, int)', sampapi.GetAddress(StringCompressor_EncodeString_addr[sampapi.GetSAMPVersion()])),
}
mt.set_handler('StringCompressor', '__index', StringCompressor_mt)

return {
    Instance = Instance
}