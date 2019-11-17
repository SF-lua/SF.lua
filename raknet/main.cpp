#include "main.h"

std::function<bool(int, uint32_t, int, int, char, bool)> OnSendRPC;
std::function<bool(uint32_t, int, int, char)> OnSendPacket;
std::function<bool(uint16_t, UINT, uint16_t, UINT, UINT, uint32_t, bool)> OnReceivePacket;

uint32_t address_interface;

sol::table open(sol::this_state ts)
{
	sol::state_view lua(ts);
	sol::table module = lua.create_table();

	module.set_function("initialize", [](uint32_t rk) {
		if (g_RakClient != nullptr) return;

		address_interface = rk;

		void **rk_ = reinterpret_cast<void**>(rk);
		g_RakClient = new RakClient(*rk_);
		*rk_ = new HookedRakClientInterface();
	});
	module.set_function("destructor", []() {
		OnSendRPC = nullptr;
		OnSendPacket = nullptr;
		OnReceivePacket = nullptr;
	});
	module.set_function("setSendRPC", [](std::function<bool(int, uint32_t, int, int, char, bool)> func) {
		OnSendRPC = func;
	});
	module.set_function("setSendPacket", [](std::function<bool(uint32_t, int, int, char)> func) {
		OnSendPacket = func;
	});
	module.set_function("setReceivePacket", [](std::function<bool(uint16_t, UINT, uint16_t, UINT, UINT, uint32_t, bool)> func) {
		OnReceivePacket = func;
	});

	return module;
}

BOOL WINAPI DllMain(HINSTANCE hinstDLL, DWORD fdwReason, LPVOID lpvReserved)
{
	if (fdwReason == DLL_PROCESS_ATTACH)
	{
		// pin DLL to prevent unloading
		HMODULE module;
		GetModuleHandleExW(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_PIN, reinterpret_cast<LPCWSTR>(&DllMain), &module);
	}
	return TRUE;
}

SOL_MODULE_ENTRYPOINT(open);
