# Launcher+ Plugin Quickstart

Launcher+ plugins are simply pdz files that can be built by pdc.

Let's create our first plugin, shall we?

Create a file, call it something like "example-plugin.lua"

Start out the file like this

```lua
function uiHandler(name,state)

end
```

## Behaviours

Behaviours are the primary way you interact with the Launcher+ API.

You can expect a behaviour to always behave in the same way.

We need to add a few behaviours to our plugin.

```lua
local button = behavior("addButton")
local header = behavior("addHeader")
local text = behavior("addText")

function uiHandler(name,state)

end
```

But the behaviours may have been removed in the latest version, so we need some error text!

```lua
local button = behavior("addButton")
local header = behavior("addHeader")
local text = behavior("addText")

function uiHandler(name,state)
	--make sure we're in the main menu
	if name == "mainMenu" then
		if text == nil then
			-- if we can't display errors as text, we have to just quit immediately
			return
		end
		if header == nil then
			-- tell the user about the error
			text("The example plugin depends upon the Launcher+ behavior header, which is not available, rendering has been canceled")
			return
		end
		if button == nil then
			-- again, tell user about error
			text("The example plugin depends upon the Launcher+ behavior button, which is not available, rendering has been canceled")
			return
		end
	end
end
```

## UI

UI in Launcher+ is expressed declaratively, that means you don't have to initialize tons of junk.

Let's add some basic UI

```lua
local button = behavior("addButton")
local header = behavior("addHeader")
local text = behavior("addText")

function uiHandler(name,state)
	--make sure we're in the main menu
	if name == "mainMenu" then
		if text == nil then
			-- if we can't display errors as text, we have to just quit immediately
			return
		end
		if header == nil then
			-- tell the user about the error
			text("The example plugin depends upon the Launcher+ behavior header, which is not available, rendering has been canceled")
			return
		end
		if button == nil then
			-- again, tell user about error
			text("The example plugin depends upon the Launcher+ behavior button, which is not available, rendering has been canceled")
			return
		end

		header("Example")
		text("This is a demo plugin for Launcher+")
	end
end
```

Now for some interactivity! Let's add a button that enables dark mode, like the one in settings.

```lua
local button = behavior("addButton")
local header = behavior("addHeader")
local text = behavior("addText")
--DARK MODE
local darkMode = behavior("getDarkModeManager")

function uiHandler(name,state)
	--make sure we're in the main menu
	if name == "mainMenu" then
		if text == nil then
			-- if we can't display errors as text, we have to just quit immediately
			return
		end
		if header == nil then
			-- tell the user about the error
			text("The example plugin depends upon the Launcher+ behavior header, which is not available, rendering has been canceled")
			return
		end
		if button == nil then
			-- again, tell user about error
			text("The example plugin depends upon the Launcher+ behavior button, which is not available, rendering has been canceled")
			return
		end
		if darkMode == nil then
			-- again, tell user about error
			text("The example plugin depends upon the Launcher+ behavior getDarkModeManager, which is not available, rendering has been canceled")
			return
		end

		-- initialize dark mode manager

		local darkModeManager = darkMode()

		-- make sure we initialized it
		if darkModeManager == nil then
			-- again, tell user about error
			text("Failed to initialize darkModeManager")
			return
		end

		header("Example")
		text("This is a demo plugin for Launcher+")

		--now let's add our fancy button

		button("enable dark mode",function()
			darkModeManager.setDarkMode(true)
		end);
	end
end
```

Now build your app, and take your example-plugin.pdz file, and copy it into "${PLAYDATE_DISK_GO_HERE}/Data/LauncherPlus/plugins"

✨Tada!✨

## Conclusion

Over the course of this guide we managed to make a simple plugin that adds a dark mode button to the main menu!
