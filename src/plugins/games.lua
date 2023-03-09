local button = behaviour("addButton")
local gameListGetter = behaviour("getGameList")
local openApp = behaviour("openApp")
local header = behaviour("addHeader")
local text = behaviour("addText")
local getMetadata = behaviour("sysGetMetadata")

function uiHandler(name,state) 
	if name == "mainMenu" then
		if text == nil then
			return
		end

		if gameListGetter == nil then
			text("The game list plugin depends upon the Launcher+ behaviour getGameList, which is not available, rendering has been canceled")
			return
		end

		if openApp == nil then
			text("The game list plugin depends upon the Launcher+ behaviour openApp, which is not available, rendering has been canceled")
			return
		end

		if header == nil then
			text("The game list plugin depends upon the Launcher+ behaviour header, which is not available, rendering has been canceled")
			return
		end

		if button == nil then
			text("The game list plugin depends upon the Launcher+ behaviour button, which is not available, rendering has been canceled")
			return
		end

		if getMetadata == nil then
			text("The game list plugin depends upon the Launcher+ behaviour sysGetMetadata, which is not available, rendering has been canceled")
			return
		end

		for i, category in pairs(gameListGetter()) do
			header(category.name)
			for x, game in pairs(category) do
				if game.getTitle ~= nil then
					button(game:getTitle(),function() 
						local metadata = getMetadata(game:getPath() .. "/pdxinfo")
						print(metadata.contentWarning)
						print(metadata.contentWarning2)
						printTable(metadata)
						openApp(game:getPath())
					end);
				end
			end
		end
	end
end
