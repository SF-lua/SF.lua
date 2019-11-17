--[[
    Project: SAMPFUNCSLUA
    URL: https://github.com/imring/SAMPFUNCSLUA

    File: init.lua
    License: MIT License

	Authors: FishLake Scripts <fishlake-scripts.ru> and BH Team <blast.hk>.
]]
local sf = require 'SAMPFUNCSLUA.functions'

for k, v in pairs(sf) do
	_G[k] = v
end
