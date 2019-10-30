--[[
	Authors: FYP, imring, DonHomka.
	Thanks BH Team for the source code of s0beit provided.
	fishlake-scripts.ru & blast.hk (c) 2018-2019.
]]
local sf = require 'SAMPFUNCSLUA.functions'

for k, v in pairs(sf) do
	_G[k] = v
end
