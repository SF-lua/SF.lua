--[[
    Project: SF.lua <https://github.com/imring/SF.lua>
    License: MIT License
    Author: imring
]]

local sampapi = require 'sampapi'
local shared = require 'sampapi.shared'
local mt = require 'sampapi.metatype'
local ffi = shared.ffi

sampapi.require 'CRect'

ffi.cdef[[
struct DXUTComboBoxItem {
    char   strText[256];
    void*  pData;
    SCRect rcActive;
    bool   bVisible;
};
]]

local CDXUTEditBox_GetText_addr = {
    [ffi.C.SAMP_VERSION_037R1] = 0x81030,
    [ffi.C.SAMP_VERSION_037R3_1] = 0x84F40,
    [ffi.C.SAMP_VERSION_037R5_1] = 0x85650
}

local CDXUTEditBox_SetText_addr = {
    [ffi.C.SAMP_VERSION_037R1] = 0x80F60,
    [ffi.C.SAMP_VERSION_037R3_1] = 0x84E70,
    [ffi.C.SAMP_VERSION_037R5_1] = 0x85580
}

local CDXUTEditBox_mt = {
    GetText = ffi.cast('const char*(__thiscall*)(struct CDXUTIMEEditBox*)', sampapi.GetAddress(CDXUTEditBox_GetText_addr[sampapi.GetSAMPVersion()])),
    SetText = ffi.cast('void(__thiscall*)(struct CDXUTIMEEditBox*, const char *, bool)', sampapi.GetAddress(CDXUTEditBox_SetText_addr[sampapi.GetSAMPVersion()])),
}
mt.set_handler('struct CDXUTEditBox', '__index', CDXUTEditBox_mt)