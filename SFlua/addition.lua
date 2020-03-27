--[[
	Project: SF.lua <https://github.com/imring/SF.lua>
	License: MIT License
	Authors: look in file <AUTHORS>.
]]

local ffi = require("ffi");
local bit = require("bit");

local add = {};

function add.GET_POINTER(cdata)
	return tonumber(ffi.cast("uintptr_t", ffi.cast("void *", cdata)));
end

function add.explode_color(color)
	local a = bit.band(bit.rshift(color, 24), 0xFF);
	local r = bit.band(bit.rshift(color, 16), 0xFF);
	local g = bit.band(bit.rshift(color, 8), 0xFF);
	local b = bit.band(color, 0xFF);
	return a, r, g, b;
end

function add.join_color(a, r, g, b)
	local color = b;  -- b
	color = bit.bor(color, bit.lshift(g, 8));  -- g
	color = bit.bor(color, bit.lshift(r, 16)); -- r
	color = bit.bor(color, bit.lshift(a, 24)); -- a
	return color % 0x100000000;
end

function add.convertARGBToRGBA(color)
	local a, r, g, b = add.explode_color(tonumber(color));
	return add.join_color(r, g, b, a);
end

function add.convertRGBAToARGB(color)
	local r, g, b, a = add.explode_color(tonumber(color));
	return add.join_color(a, r, g, b);
end

function add.convertABGRtoARGBA(color)
	local a, r, g, b = add.explode_color(tonumber(color));
	return add.join_color(a, b, g, r);
end

return add;