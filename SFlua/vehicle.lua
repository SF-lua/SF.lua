--[[
    Project: SF.lua <https://github.com/imring/SF.lua>
    License: MIT License
    Author: imring
]]

local sampapi = require 'sampapi'
local shared = require 'sampapi.shared'
local ffi = shared.ffi

local netgame = sampapi.require('CNetGame', true)
sampapi.require('CVehiclePool', true)

local function vehiclepool()
    return netgame.RefNetGame().m_pPools.m_pVehicle
end

function sampGetVehiclePoolPtr()
    return shared.get_pointer(vehiclepool())
end

function sampGetCarHandleBySampVehicleId(id)
    if sampIsVehicleDefined(id) then
        return true, getVehiclePointerHandle(shared.get_pointer(vehiclepool().m_pGameObject[id]))
    end
    return false, -1
end

function sampGetVehicleIdByCarHandle(car)
    for i = 0, ffi.C.MAX_VEHICLES - 1 do
        local res, handle = sampGetCarHandleBySampVehicleId(i)
        if res and handle == car then
            return true, i
        end
    end
end

-- New functions

function sampIsVehicleDefined(id)
    return vehiclepool().m_bNotEmpty[id] == 1 and vehiclepool().m_pObject[id] ~= nil and vehiclepool().m_pGameObject[id] ~= nil
end