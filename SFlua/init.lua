--[[
	Project: SF.lua <https://github.com/imring/SF.lua>
	License: MIT License

	Authors: look in file <AUTHORS>.
]]

local memory = require("memory");

local versions = {
    ["0.3.7-R1"] = { "SFlua.037-r1", 0xD8 }
};

local currentVersion, sampModule = nil, getModuleHandle("samp.dll");

function isSampLoaded()
    if(not currentVersion) then
        -- Getting version taken from SAMP-UDF (https://github.com/SAMP-UDF/SAMP-UDF-for-AutoHotKey/blob/b6707af19c7e02a021f432fedad0b6c30a6b8f9f/SAMP.ahk#L3557)
        local versionByte = memory.getuint8(sampModule + 0x1036);
        for i, k in pairs(versions) do
            if(versionByte == k[2]) then
                require(k[1]);
                currentVersion = i;
                break;
            end
        end
        if(not currentVersion) then
            error(string.format("Unknown version of SA-MP (samp.dll + 0x1036 = 0x%02X)", versionByte));
        end
    end
    return sampModule > 0;
end

function isSampfuncsLoaded()
    return true;
end

function sampGetBase()
    return sampModule;
end

isSampLoaded();