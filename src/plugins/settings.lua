local button = behavior("addButton")
local header = behavior("addHeader")
local darkMode = behavior("getDarkModeManager")
local text = behavior("addText")
local switchState = behavior("switchState")

function uiHandler(name, state)
	if name == "settings" then
		if text == nil then
			return
		end

		if header == nil then
			text(
				"The settings plugin depends upon the Launcher+ behavior header, which is not available, rendering has been canceled")
			return
		end

		if button == nil then
			text(
				"The settings plugin depends upon the Launcher+ behavior button, which is not available, rendering has been canceled")
			return
		end

		if darkMode == nil then
			text(
				"The settings plugin depends upon the Launcher+ behavior getDarkModeManager, which is not available, rendering has been canceled")
			return
		end

		if switchState == nil then
			text(
				"The settings plugin depends upon the Launcher+ behavior switchState, which is not available, rendering has been canceled")
			return
		end

		local darkModeManager = darkMode()

		if darkModeManager == nil then
			text("The settings plugin failed to render because it failed to aquire a darkModeManager")
			return
		end

		header("Settings")

		local tickIcon = " ";

		if darkModeManager.getDarkModeEnabled() then
			tickIcon = "X"
		end

		button("[" .. tickIcon .. "] toggle dark mode", function()
			darkModeManager.setDarkMode(not darkModeManager.getDarkModeEnabled())
		end);

		button("home", function ()
			switchState("mainMenu",{})
		end)
	end
	if name == "mainMenu" then
		if text == nil then
			return
		end

		if header == nil then
			text(
				"The settings plugin depends upon the Launcher+ behavior header, which is not available, rendering has been canceled")
			return
		end

		if button == nil then
			text(
				"The settings plugin depends upon the Launcher+ behavior button, which is not available, rendering has been canceled")
			return
		end

		if switchState == nil then
			text(
				"The settings plugin depends upon the Launcher+ behavior switchState, which is not available, rendering has been canceled")
			return
		end

		header("Settings")

		button("open settings", function()
			switchState("settings",{})
		end)
	end
end
