# SAMPFUNCS_LUA

This library is addition for Moonloader, expanding capabilities scripters.  
[Official theme SAMPFUNCS.asi](https://blast.hk/threads/17/)  
Authors: [FYP](https://blast.hk/members/2/) [imring](https://blast.hk/members/106094/) [DonHomka](https://blast.hk/members/161656/)  
Thanks BH Team for development.  
Structuers/addresses/other were taken in s0beit 0.3.7: https://github.com/BlastHackNet/mod_s0beit_sa  

```lua
require 'SAMPFUNCS.init' -- Load library.

function main()
	while not isSampAvailable() do wait(0) end -- While SA-MP not Available then wait 1 frame.
	sampAddChatMessage('SA-MP available.', -1) -- Send message to chat.
	sampRegisterChatCommand('dialog', function()
		sampShowDialog(5, 'Test dialog', 'Click "Button 1"', 'Button 1', 'Button 2', 0) -- Show dialog "Test dialog".
	end) -- Register cmd /dialog.
	wait(-1) -- Endless wait.
end
```

```lua
require 'SAMPFUNCS.init' -- Load library.

function main()
	while not isSampAvailable() do wait(0) end -- While SA-MP not Available then wait 1 frame.
	while true do wait(0) -- Endless cycle with wait 1 frame.
		if sampGetCurrentDialogListItem() == 5 then -- If dialog list item is number 5 then..
			sampSetCurrentDialogListItem(4) -- Set dialog list item number 4.
		end
	end
end
```
