--[[
    Project: SF.lua <https://github.com/imring/SF.lua>
    License: MIT License
    Author: imring
]]

local module = {}

-- from https://www.blast.hk/threads/13380/post-124527
function module.explode_color(color)
    local a = bit.band(bit.rshift(color, 24), 0xFF)
    local r = bit.band(bit.rshift(color, 16), 0xFF)
    local g = bit.band(bit.rshift(color, 8), 0xFF)
    local b = bit.band(color, 0xFF)
    return a, r, g, b
end

function module.join_color(a, r, g, b)
    local color = b  -- b
    color = bit.bor(color, bit.lshift(g, 8))  -- g
    color = bit.bor(color, bit.lshift(r, 16)) -- r
    color = bit.bor(color, bit.lshift(a, 24)) -- a
    return color % 0x100000000
end

function module.argb_to_rgba(color)
    local a, r, g, b = module.explode_color(color)
    return module.join_color(r, g, b, a)
end

function module.rgba_to_argb(color)
    local r, g, b, a = module.explode_color(color)
    return module.join_color(a, r, g, b)
end

function module.abgr_to_argb(color)
    local a, r, g, b = module.explode_color(color)
    return module.join_color(a, b, g, r)
end

return module