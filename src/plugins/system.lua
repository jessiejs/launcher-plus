local button = behaviour("addButton")
local header = behaviour("addHeader")
local text = behaviour("addText")
local reboot = behaviour("reboot")
local switchState = behaviour("switchState")

function uiHandler(name, state)
	if name == "mainMenu" then
		if text == nil then
			return
		end

		if header == nil then
			text(
				"The system plugin depends upon the Launcher+ behaviour addHeader, which is not available, rendering has been canceled")
			return
		end

		if button == nil then
			text(
				"The system plugin depends upon the Launcher+ behaviour addButton, which is not available, rendering has been canceled")
			return
		end

		if reboot == nil then
			text(
				"The system plugin depends upon the Launcher+ behaviour reboot, which is not available, rendering has been canceled")
			return
		end

		if switchState == nil then
			text(
				"The system plugin depends upon the Launcher+ behaviour switchState, which is not available, rendering has been canceled")
			return
		end

		header("System")

		button("reboot", reboot, {
			cancel=function ()
				switchState("sadness",{})
			end
		})
	end
	if name == "sadness" then
		if text == nil then
			return
		end

		if switchState == nil then
			text(
				"The system plugin depends upon the Launcher+ behaviour switchState, which is not available, rendering has been canceled")
			return
		end

		if header == nil then
			text(
				"The system plugin depends upon the Launcher+ behaviour addHeader, which is not available, rendering has been canceled")
			return
		end

		header("Sadness")

		text("im still not over him :'(")

		button("home", function ()
			switchState("mainMenu",{})
		end)
	end
end
