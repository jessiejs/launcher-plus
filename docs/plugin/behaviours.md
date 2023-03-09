# Behaviours Overview

Behaviours are small little functions you can call that are guarenteed to always work the same way.

To get a behaviour, we reccomend following this convention:

```lua
local text = behaviour("addText")
local mayNotExist = behaviour("behaviourThatMightBeDeprecated")

function uiHandler(name,state) 
	if text == nil then
		return
	end

	if mayNotExist == nil then
		text("<show the user some warning about not having the plugin>")
		return
	end
end
```

Here's all the available behaviours.

- [getGameList](./behaviours/getGameList.md)
- [addButton](./behaviours/addButton.md)
- [addTickbox](./behaviours/addTickbox.md)
- [tableContains](./behaviours/tableContains.md)
- [addText](./behaviours/addText.md)
- [addHeader](./behaviours/addHeader.md)
- [allocate](./behaviours/allocate.md)
- [selection](./behaviours/selection.md)
- [openApp](./behaviours/openApp.md)
- [getDarkModeManager](./behaviours/getDarkModeManager.md)
- [switchState](./behaviours/switchState.md)
- [forceScreenUpdate](./behaviours/forceScreenUpdate.md)
- [getGraphics](./behaviours/getGraphics.md)
- [reboot](./behaviours/reboot.md)
- [sysGetMetadata](./behaviours/sysGetMetadata.md)
- [takeOverTicks](./behaviours/switchToMainUpdate.md)
- [switchToMainUpdate](./behaviours/switchToMainUpdate.md)
