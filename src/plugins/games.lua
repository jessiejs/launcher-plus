local button = behavior("addButton")
local gameListGetter = behavior("getGameList")
local openApp = behavior("openApp")
local header = behavior("addHeader")
local text = behavior("addText")

function uiHandler(name,state) 
	if name == "mainMenu" then
		if text == nil then
			return
		end

		if gameListGetter == nil then
			text("The game list plugin depends upon the Launcher+ behavior getGameList, which is not available, rendering has been canceled")
			return
		end

		if openApp == nil then
			text("The game list plugin depends upon the Launcher+ behavior openApp, which is not available, rendering has been canceled")
			return
		end

		if header == nil then
			text("The game list plugin depends upon the Launcher+ behavior header, which is not available, rendering has been canceled")
			return
		end

		if button == nil then
			text("The game list plugin depends upon the Launcher+ behavior button, which is not available, rendering has been canceled")
			return
		end

		for i, category in pairs(gameListGetter()) do
			header(category.name)
			for x, game in pairs(category) do
				if game.getTitle ~= nil then
					button(game:getTitle(),function() 
						openApp(game:getPath())
					end);
				end
			end
		end
	end
end
