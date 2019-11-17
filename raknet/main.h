#pragma once
#include <string>
#include <thread>
#include <chrono>
#include <list>
#include <functional>
#include <tuple>

#include <Windows.h>

#include "sol.hpp"
#include "lua_module.h"

#include "libs/raknet/BitStream.h"
#include "libs/raknet/RakClient.h"
#include "libs/raknet/HookedRakClient.h"

extern std::function<bool(int, uint32_t, int, int, char, bool)> OnSendRPC;
extern std::function<bool(uint32_t, int, int, char)> OnSendPacket;
extern std::function<bool(uint16_t, UINT, uint16_t, UINT, UINT, uint32_t, bool)> OnReceivePacket;