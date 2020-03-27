# SF.lua
SF.lua (o.n. SAMPFUNCSLUA) - is library that allows you to interact with SA-MP. Is a translation of [SAMPFUNCS](https://www.blast.hk/threads/17/) in Lua.  
Version: 0.78-alpha.

## Authors
Look in file [AUTHORS](https://github.com/imring/SF.lua/blob/master/AUTHORS).  
Also thanks to BlastHack Team for help in developing.

## Progress
SF.lua is currently 78% developed.

## New functions
```lua
bool result = sampIsPlayerDefined(int id)
uint scorePtr = sampGetScoreboardInfoPtr()
zstring nick = sampGetLocalPlayerNickname()
int id = sampGetLocalPlayerId()
uint color = sampGetLocalPlayerColor()
sampAddChatMessageEx(int type, zstring text, zstring prefix, uint color, uint pcolor)
sampSetPlayerColor(int id, uint color)
bool result = sampIsVehicleDefined(int id)
int model, int type = sampGetPickupModelTypeBySampId(int id)
sampAddDeathMessage(zstring killer, zstring killed, uint clKiller, uint clKilled, int reason)
zstring button1, zstring button2 = sampGetDialogButtons()
```