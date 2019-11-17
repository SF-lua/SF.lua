#pragma once
#define LUAOPEN_MODULE_EXPAND(name) luaopen_##name
#define LUAOPEN_MODULE(name) LUAOPEN_MODULE_EXPAND name
#define LUA_MODULE_ENTRYPOINT extern "C" __declspec(dllexport) int LUAOPEN_MODULE((MODULE_NAME))
#define SOL_MODULE_ENTRYPOINT(func) LUA_MODULE_ENTRYPOINT(lua_State* L) { return (sol::c_call<decltype(&func), &func>)(L); }
