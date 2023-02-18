import 'constants'
import 'darkModeManager'

behaviors = {
	getGameList=function ()
		return GAMELIST		
	end,
	addButton=simpleButton,
	tableContains=tableContains,
	addText=addText,
	addHeader=header,
	allocate=allocate,
	selection=selection,
	openApp=openApp,
	getDarkModeManager=DarkModeManager,
	switchState=function (name,state) 
		if stateName ~= name then
			screenNeedsUpdate = true
			hoverIndex = 1
			stateName = name
		end
		stateData = state
	end,
	forceScreenUpdate=function ()
		screenNeedsUpdate = true
	end
};
