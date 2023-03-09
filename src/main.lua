if playdate.system == nil then
	playdate.graphics.clear()
	playdate.graphics.drawText("Launcher+ failed to launch\n\nplaydate.system is inaccessible\nPlease install Launcher+ to /System/, not /Games/",0,0,playdate.graphics.getSystemFont("bold"));
	playdate.display.flush()
	playdate.update = function ()
		
	end
	return
end

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

-- fix memory leak
import 'memory-leak-fix'

-- allocator stuff
local currentAllocationHeight = 0;

-- repaints
screenNeedsUpdate = true

-- catalog ost
local catalogMusic = snd.fileplayer.new("/System/Catalog.pdx/sounds/background-music.pda")

if catalogMusic ~= nil then
	catalogMusic:play(0)
end

--fun junk
--playdate.system.showSystemDialog("testetst","is this ever used, or is this api just here for no reason?")

-- hover stuff
hoverIndex = 1
local selectionCount = 1

local selectionLeft = 0.0
local selectionRight = 0.0
local selectionTop = 0.0
local selectionBottom = 0.0
local selectionRadius = 0.0

local lastSelectionLeft = 0.0
local lastSelectionRight = 0.0
local lastSelectionTop = 0.0
local lastSelectionBottom = 0.0
local lastSelectionBump = 0.0

local scrollY = 0.0
local lastScrollY = 0.0

local bPaint = 100


-- states
stateName = "mainMenu"
stateData = {}

-- delta time stuff
local lastFrameTimeForDeltaTimeCalculation = playdate.getCurrentTimeMilliseconds() / 1000
deltaTime = 0

-- dark mode *duh*
useDarkMode = false

-- confirm state
local confirmText, confirmYesFunction, confirmNoFunction
local confirmA, confirmB

-- uncap refresh rate
pd.display.setRefreshRate(0)


-- a little bit of animation junk
local selectionBump = 0

playdate.file.mkdir("/Data/LauncherPlus/plugins")

function lerp(a,b,t)
	if t < 0 then
		return a
	end
	if t > 1 then
		return b
	end
	return playdate.math.lerp(a,b,t)
end

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

function openApp(app)
	sys.switchToGame(app)
end

function returnToMainMenu()
	playdate.update = mainMenu
end

function confirm(text, yes, no)

end

function mainMenu()
	for i, plugin in pairs(plugins) do
		plugin.uiHandler(stateName,stateData)
	end
end

function mainUpdate() 	
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

	playdate.AButtonDown = nil
	playdate.BButtonDown = nil
	playdate.leftButtonDown = nil
	playdate.rightButtonDown = nil	

	currentAllocationHeight = EDGE_PADDING
	currentTime = playdate.getCurrentTimeMilliseconds() / 1000
	deltaTime = currentTime - lastFrameTimeForDeltaTimeCalculation
	lastFrameTimeForDeltaTimeCalculation = currentTime
	selectionCount = 0

	ticks = playdate.getCrankTicks(6)

	if ticks > 0 then
		playdate.downButtonDown()
	end

	if ticks < 0 then
		playdate.upButtonDown()
	end

	if bPaint > 0 then
		bPaint -= 1
		print("b(oot)painting (" .. tostring(100 - bPaint) .. ")")
		screenNeedsUpdate = true
	end

	if screenNeedsUpdate then
		screenNeedsUpdate = false
	else
		compositeLeft = math.min(selectionLeft,lastSelectionLeft) - math.abs(selectionBump*2)
		compositeTop = math.min(selectionTop+selectionBump,lastSelectionTop+lastSelectionBump) - math.abs(selectionBump*2)
		compositeRight = math.max(selectionRight,lastSelectionRight) + math.abs(selectionBump*2)
		compositeBottom = math.max(selectionBottom+selectionBump,lastSelectionBottom+lastSelectionBump) + math.abs(selectionBump*2)

		playdate.graphics.setClipRect(compositeLeft, compositeTop + selectionBump, compositeRight - compositeLeft, compositeBottom - compositeTop)

		lastSelectionBottom = selectionBottom
		lastSelectionLeft = selectionLeft
		lastSelectionRight = selectionRight
		lastSelectionTop = selectionTop
		lastSelectionBump = selectionBump
	end

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
		selectionBottom - selectionTop, selectionRadius)
end

playdate.update = mainUpdate

function addText(text,font) 
	if font == nil then
		font = fontBold
	end
	local width, height = playdate.graphics.getTextSizeForMaxWidth(text, SCREEN_WIDTH - EDGE_PADDING - EDGE_PADDING, 0, font);
	local allocation = allocate(height)
	playdate.graphics.drawTextInRect(text,allocation:rect().left,allocation:rect().top,allocation:rect().width,allocation:rect().height,0,"",kTextAlignment.left,font)
end

function simpleButton(text,action,customActions) 
	allocation = allocate(BUTTON_HEIGHT);
	local y = allocation.top + scrollY
	if customActions == nil then
		customActions = {
		}
	end
	customActions.select = action
	selectionGetter(function ()
		return allocation:rect()
	end, customActions);
	if y > -BUTTON_HEIGHT and y < SCREEN_HEIGHT then
		local rect = allocation:rect()
		playdate.graphics.drawText("*" .. text .. "*",rect.left,rect.top+9)
	end
end

function simpleTickbox(text,get,set) 
	value = get()
	allocation = allocate(BUTTON_HEIGHT);
	rect = allocation:rect()
	selection(rect, {
		select = function ()
			set(not value)
		end
	});
	tickSize = BUTTON_HEIGHT - 10
	tickMargin = 5
	playdate.graphics.fillRoundRect(rect.left, rect.top + tickMargin,tickSize,tickSize,2)
	if value then
		tickboxTexture:draw(rect.left, rect.top + tickMargin)
	end
	playdate.graphics.drawText("*" .. text .. "*",rect.left + tickSize + tickMargin + tickMargin,rect.top+9)
end

function header(text) 
	if currentAllocationHeight == EDGE_PADDING then
		currentAllocationHeight = 0
	end
	allocation = allocate(BUTTON_HEIGHT);
	rect = allocation:rect()
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.drawText("*" .. text .. "*",rect.left,rect.top+9)
	playdate.graphics.setColor(playdate.graphics.kColorXOR)
	playdate.graphics.fillRect(0,allocation.top,SCREEN_WIDTH,allocation.height);
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	indentation = 0
	--[[while indentation < BUTTON_HEIGHT / 2 do
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.fillRect(indentation,allocation.top+indentation,1,allocation.height-indentation-indentation);
		playdate.graphics.fillRect(SCREEN_WIDTH-indentation,allocation.top+indentation,1,allocation.height-indentation-indentation);
		indentation += 1
	end]]
end

function allocate(height)
	-- allocate has to be heavily optimized, so this is going to be quite confusing
	local allocation = {
		top = currentAllocationHeight,
		height = height,
		rect = function (slf)
			return {
				top=slf.top,
				bottom=slf.top+slf.height,
				left=EDGE_PADDING,
				right=SCREEN_WIDTH-EDGE_PADDING,
				width=SCREEN_WIDTH-EDGE_PADDING-EDGE_PADDING,
				height=slf.height
			}
		end
	}
	currentAllocationHeight = currentAllocationHeight + height + SMALL_GAP

	scrollY = -selectionBottom + SCREEN_HEIGHT - (EDGE_PADDING-10)
	if scrollY > 0 then
		scrollY = 0
	end
	gfx.setDrawOffset(0,scrollY)

	return allocation
end

function selection(rect,actions,cornerRadius)
	selectionGetter(function ()
		return rect
	end,actions,cornerRadius)
end

function selectionGetter(rct,actions,cornerRadius)
	if actions == nil then
		actions = {}
	end
	if cornerRadius == nil then
		cornerRadius = 5
	end
	selectionCount = selectionCount + 1
	if selectionCount == hoverIndex then
		local rect = rct()
		selectionTop = lerp(selectionTop, rect.top, deltaTime * 10);
		selectionBottom = lerp(selectionBottom, rect.bottom, deltaTime * 10);
		selectionLeft = lerp(selectionLeft, rect.left-10, deltaTime * 10);
		selectionRight = lerp(selectionRight, rect.right+10, deltaTime * 10);
		selectionRadius = lerp(selectionRadius, cornerRadius, deltaTime * 10);

		if actions.select ~= nil then
			playdate.AButtonDown = function ()
				snd.playSystemSound(snd.kSoundAction)
				actions.select()
			end
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
	if lastScrollY ~= scrollY then
		lastScrollY = scrollY
		screenNeedsUpdate = true
	end
end

function updateOffset()
	--gfx.setDrawOffset(20 + accelerometerX * 2 + shakeX, 20 + h - scrollY + accelerometerY * 2 + shakeY)
end

-- add plugins
import 'plugins'

Plugin("./plugins/games"):register()
Plugin("./plugins/settings"):register()
Plugin("./plugins/system"):register()

local plugins = playdate.file.listFiles("/Data/LauncherPlus/plugins")

for index, name in pairs(plugins) do
	Plugin("/Data/LauncherPlus/plugins/".. name):register()
end
