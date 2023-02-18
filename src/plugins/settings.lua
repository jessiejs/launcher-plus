local button = behaviour("addButton")
local header = behaviour("addHeader")
local darkMode = behaviour("getDarkModeManager")
local text = behaviour("addText")
local switchState = behaviour("switchState")
local tickbox = behaviour("addTickbox")

function uiHandler(name, state)
	if name == "settings" then
		if text == nil then
			return
		end

		if header == nil then
			text(
				"The settings plugin depends upon the Launcher+ behaviour addHeader, which is not available, rendering has been canceled")
			return
		end

		if button == nil then
			text(
				"The settings plugin depends upon the Launcher+ behaviour addButton, which is not available, rendering has been canceled")
			return
		end

		if darkMode == nil then
			text(
				"The settings plugin depends upon the Launcher+ behaviour getDarkModeManager, which is not available, rendering has been canceled")
			return
		end

		if switchState == nil then
			text(
				"The settings plugin depends upon the Launcher+ behaviour switchState, which is not available, rendering has been canceled")
			return
		end

		if tickbox == nil then
			text(
				"The settings plugin depends upon the Launcher+ behaviour addTickbox, which is not available, rendering has been canceled")
			return
		end

		local darkModeManager = darkMode()

		if darkModeManager == nil then
			text("The settings plugin failed to render because it failed to aquire a darkModeManager")
			return
		end

		header("Settings")

		tickbox("dark mode", darkModeManager.getDarkModeEnabled, darkModeManager.setDarkMode);

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
				"The settings plugin depends upon the Launcher+ behaviour addHeader, which is not available, rendering has been canceled")
			return
		end

		if button == nil then
			text(
				"The settings plugin depends upon the Launcher+ behaviour addButton, which is not available, rendering has been canceled")
			return
		end

		if switchState == nil then
			text(
				"The settings plugin depends upon the Launcher+ behaviour switchState, which is not available, rendering has been canceled")
			return
		end

		header("Settings")

		button("open settings", function()
			switchState("settings",{})
		end)
	end
end
