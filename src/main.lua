-- import corelibs
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"
import "CoreLibs/math"

-- define constants
import 'constants'

-- import allocation stuff
import 'ui-allocation'

-- allocator stuff
local currentAllocationHeight = 0;

-- hover stuff
local hoverIndex = 1
local selectionCount = 1

local selectionLeft = 0.0
local selectionRight = 0.0
local selectionTop = 0.0
local selectionBottom = 0.0

-- delta time stuff
local lastFrameTimeForDeltaTimeCalculation = playdate.getCurrentTimeMilliseconds() / 1000
deltaTime = 0

-- dark mode *duh*
local useDarkMode = false

-- system menu
local menu = pd.getSystemMenu()

-- confirm state
local confirmText, confirmYesFunction, confirmNoFunction
local confirmA, confirmB

-- uncap refresh rate
pd.display.setRefreshRate(0)

-- add dark mode toggle
menu:addCheckmarkMenuItem("Dark Mode", false, function(value)
	useDarkMode = value
end)

-- a little bit of animation junk
local selectionBump = 0

-- add pdx
function addPdx(path, final)
	local name = string.sub(final, 0, #(final) - 5)

	--if addedApp(name) then return end
	menuOptions[#(menuOptions) + 1] = {
		name = name,
		path = path
	}
end

-- utility function
function tableContains(tab, val)
	for index, value in ipairs(tab) do
		if value == val then
			return true
		end
	end

	return false
end

function openApp()
	sys.switchToGame(appToOpen)
end

function returnToMainMenu()
	playdate.update = mainMenu
end

function confirm(text, yes, no)

end

function mainMenu()
	simpleButton("toggle dark mode",function() 
		useDarkMode = not useDarkMode
	end);
	simpleButton("wooo2",function() 
		print(2)
	end);
	simpleButton("wooo3",function() 
		print(3)
	end);
end

function playdate.update()
	playdate.display.setInverted(useDarkMode)
	playdate.downButtonDown = function ()
		hoverIndex = hoverIndex + 1
		selectionBump = 10
		snd.playSystemSound(snd.kSoundSelectNext)
	end
	playdate.upButtonDown = function ()
		hoverIndex = hoverIndex - 1
		selectionBump = -10
		snd.playSystemSound(snd.kSoundSelectPrevious)
	end
	
	currentAllocationHeight = EDGE_PADDING
	currentTime = playdate.getCurrentTimeMilliseconds() / 1000
	deltaTime = currentTime - lastFrameTimeForDeltaTimeCalculation
	lastFrameTimeForDeltaTimeCalculation = currentTime
	selectionCount = 0
	playdate.graphics.clear()
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	mainMenu()
	if hoverIndex < 1 then
		hoverIndex = 1
		snd.playSystemSound(snd.kSoundDenial)
	end
	if hoverIndex > selectionCount then
		hoverIndex = selectionCount
		snd.playSystemSound(snd.kSoundDenial)
	end
	selectionBump *= 1 - (deltaTime * 5)
	playdate.graphics.setColor(playdate.graphics.kColorXOR)
	playdate.graphics.fillRoundRect(selectionLeft, selectionTop + selectionBump, selectionRight - selectionLeft,
		selectionBottom - selectionTop, 5)
end

function simpleButton(text,action) 
	allocation = allocate(35);
	selection(allocation:rect(), {
		select = action
	});
	playdate.graphics.drawText("*" .. text .. "*",allocation:rect().left+9,allocation:rect().top+9)
end

function allocate(height)
	local allocation = Allocation({
		top = currentAllocationHeight,
		height = height
	})
	currentAllocationHeight = currentAllocationHeight + height
	return allocation
end

function selection(rect,actions)
	if actions == nil then
		actions = {}
	end
	selectionCount = selectionCount + 1
	if selectionCount == hoverIndex then
		selectionTop = playdate.math.lerp(selectionTop, rect.top, deltaTime * 10);
		selectionBottom = playdate.math.lerp(selectionBottom, rect.bottom, deltaTime * 10);
		selectionLeft = playdate.math.lerp(selectionLeft, rect.left, deltaTime * 10);
		selectionRight = playdate.math.lerp(selectionRight, rect.right, deltaTime * 10);
		if actions.select ~= nil then
			playdate.AButtonDown = actions.select
		end
		if actions.cancel ~= nil then
			playdate.BButtonDown = actions.cancel
		end
		if actions.up ~= nil then
			playdate.upButtonDown = actions.up
		end
		if actions.down ~= nil then
			playdate.downButtonDown = actions.down
		end
		if actions.left ~= nil then
			playdate.leftButtonDown = actions.left
		end
		if actions.right ~= nil then
			playdate.rightButtonDown = actions.right
		end
	end
end

function updateOffset()
	--gfx.setDrawOffset(20 + accelerometerX * 2 + shakeX, 20 + h - scrollY + accelerometerY * 2 + shakeY)
end
