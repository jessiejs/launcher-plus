class("DarkModeManager").extends()

function DarkModeManager:init()
	self.getDarkModeEnabled = function () 
		return useDarkMode
	end
	self.setDarkMode = function (darkMode) 
		useDarkMode = darkMode
		settings.useDarkMode = darkMode
		saveSettings()
	end
end
