# SF.lua
<p align="center"><img src="./logo.png" height="250px" /></p>

SF.lua is a lua library for [MoonLoader](https://www.blast.hk/moonloader) that interaction with SA:MP. This library doesn't replace all [SAMPFUNCS](https://www.blast.hk/sampfuncs), it just adds new functions for the Lua script.

Version: v1.1-beta.

## Progress
At the moment, SF.lua doens't have all the functionality of SAMPFUNCS:
* Events onSendRpc/onSendPacket/etc;
* Some RakNet functions;
* Custom handler for commands.

## Functional
Supporting versions of SA-MP: `0.3.7-R1`, `0.3.7-R3-1` and `0.3.7-R5-1`.

There will be no functions in SF.lua:
* Functions for manipulating of DXUT windows;
* Interaction with SAMPFUNCS/CLEO.

New functions:
```lua
sampAddChatMessageEx(type_msg, text, prefix, color, pcolor) -- Add a message with a specific type (CHAT/INFO/DEBUG)
sampAddDeathMessage(killer, killed, clkiller, clkilled, reason) -- Add a death message
sampGetLocalPlayerId() -- Get local player ID
sampGetLocalPlayerNickname() -- Get local player nickname
sampGetLocalPlayerColor() -- Get local player color
sampSetPlayerColor(id, color) -- Set player color (client-side)
sampIsPlayerDefined(id) -- Does player ped exist by player ID
sampIsVehicleDefined(id) -- Does vehicle exist by vehicle ID
```

## Installation
Copy the entire folder `sflua` into the `moonloader/lib` directory.

# Depends
SF.lua depends on the library [`SAMP-API.lua`](https://github.com/imring/SAMP-API.lua).

## Links
Official thread at BlastHack: https://blast.hk/threads/51388/