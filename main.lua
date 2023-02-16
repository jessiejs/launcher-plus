import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"
import "CoreLibs/math"

local pd <const> = playdate
local gfx <const> = pd.graphics
local sys <const> = pd.system
local net <const> = pd.server
local scrollY = 0
local menuOptions = {}
local hoverIndex = 1
local hoverDisplayY = 58
local hoverDisplayHeight = 0
local pTime
local indexQueue
local lastCrankDockstate = false

local click = pd.sound.sampleplayer.new("click")
local denial = pd.sound.sampleplayer.new("denial")
local key = pd.sound.sampleplayer.new("key")
local selection = pd.sound.sampleplayer.new("selection")
local selectionReverse = pd.sound.sampleplayer.new("selection-reverse")
local useDarkMode = false

local shakeX, shakeY = 0, 0

local menu = pd.getSystemMenu()

local logs = {}

local subtleSelectionBump = 0

local accelerometerX, accelerometerY, accelerometerZ

local appToOpen = ""

local confirmText, confirmYesFunction, confirmNoFunction
local confirmA, confirmB

local bold = gfx.getSystemFont("bold")

local update

local easterEggTx = ""
local easterEggSequence = "uuddlrlrbllrr"

local selectables = {{0,0}}
local workingSelectables = {}

printTable(sys)
printTable(net)

pd.display.setRefreshRate(999999)
--pd.startAccelerometer()

--[[function print(tx)
    logs[#(logs)+1] = tx
end]] --

menu:addCheckmarkMenuItem("Dark Mode", false, function(value)
    useDarkMode = value
end)

function indexDirectory(dir)
    contents = pd.file.listFiles(dir .. "/", true)
    if contents == nil then
        return
    end
    if #(contents) == 0 then return end
    for i = 1, #(contents), 1 do
        if (contents == nil) then
            return
        end
        path = dir .. contents[i]
        if string.match(path, ".pdx") then
            addPdx(path)
        else
            indexDirectory(path)
        end
    end
end

function addPdx(path, final)
    local name = string.sub(final, 0, #(final) - 5)

    --if addedApp(name) then return end
    menuOptions[#(menuOptions) + 1] = {
        name = name,
        path = path
    }
end

function has_value(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function addedApp(name)
    for index, value in ipairs(menuOptions) do
        if value.name == name then
            return true
        end
    end

    return false
end

function indexSystem()
    indexQueue = { "/" }
    x = 1
    while x <= #(indexQueue) do
        contents = pd.file.listFiles(indexQueue[x])
        if contents ~= nil then
            for i = 1, #(contents), 1 do
                if string.sub(contents[i], -5) == ".pdx/" then
                    addPdx(indexQueue[x] .. contents[i], contents[i])
                else
                    if not has_value(indexQueue, indexQueue[x] .. contents[i]) then
                        indexQueue[#(indexQueue) + 1] = indexQueue[x] .. contents[i]
                    end
                end
            end
        else
        end
        x = x + 1
    end
end

function moveInDirection(direction)
    if direction == 0 then return end
    initial = hoverIndex
    hoverIndex = hoverIndex + direction
    if hoverIndex < 1 then
        hoverIndex = 1
    end
    if hoverIndex > #(selectables) then
        hoverIndex = #(selectables)
    end
    if initial ~= hoverIndex then
        if direction > 0 then
            selection:play()
        else
            selectionReverse:play()
        end
    else
        denial:play()
    end
    subtleSelectionBump = direction * 8
end

function openApp()
    sys.switchToGame(appToOpen)
    --pd.file.run(appToOpen.."main.pdz")
end

function returnToMainMenu()
    update = mainMenu
end

function confirmTick()
    scrollY = 0
    updateOffset()
    --gfx.drawText("*Confirm*",0,0)
    --section(30)
    gfx.drawTextInRect(confirmText, 0, 0, width - 40, height - 40, nil, nil, nil, bold)
    section(height - 50 - 20 - 8 - 33,false)
    local w = width - 40;
    if pd.buttonIsPressed(pd.kButtonA) then
        confirmA = confirmA + deltaTime
    else
        confirmA = confirmA - deltaTime * 5
    end
    if pd.buttonIsPressed(pd.kButtonB) then
        confirmB = confirmB + deltaTime * 5
    else
        confirmB = confirmB - deltaTime * 5
    end
    if confirmA < 0 then
        confirmA = 0
    end
    if confirmA > 1 then
        confirmYesFunction()
    end
    if confirmB < 0 then
        confirmB = 0
    end
    if confirmB > 1 then
        confirmNoFunction()
    end
    gfx.drawText("Ⓐ*   Yes*", 5, 5);
    gfx.fillRoundRect(0, 0, ((w - 28) * confirmA) + 28, 28, 15)
    section(28,false)
    gfx.drawText("Ⓑ*   No*", 5, 5);
    gfx.fillRoundRect(0, 0, ((w - 28) * confirmB) + 28, 28, 15)
end

function confirm(text, yes, no)
    confirmText = text
    confirmYesFunction = yes
    confirmNoFunction = no
    confirmA = 0
    confirmB = 0
    update = confirmTick
end

function mainMenu()
	hoverDisplayHeight = selectables[hoverIndex][2]
	selectables = workingSelectables
	workingSelectables = {}
	if #(selectables) == 0 then
		selectables = {{0,0}}
	end
    if pd.buttonJustPressed(pd.kButtonUp) then
        moveInDirection(-1)
    end
    if pd.buttonJustPressed(pd.kButtonDown) then
        moveInDirection(1)
    end
    moveInDirection(pd.getCrankTicks(6))
    --targetHoverDisplayY = 58 + (hoverIndex - 1) * 26
	printTable(selectables)
	printTable(selectables[hoverIndex])
    targetHoverDisplayY = selectables[hoverIndex][1]
	hoverDisplayY = pd.math.lerp(hoverDisplayY, targetHoverDisplayY, deltaTime * 20)
    maximum = hoverDisplayY + hoverDisplayHeight--24
    scrollY = maximum - pd.display.getHeight() + 10
    if (scrollY < 0) then scrollY = 0 end
    updateOffset()
    x,y,w,h = gfx.getScreenClipRect()
    gfx.clearClipRect()
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(0,0,width-40,20)
    gfx.setColor(gfx.kColorXOR)
    gfx.drawText("*Launcher+ " .. formatTime() .. "*", 0, 0)
    gfx.setScreenClipRect(x,y,w,h)
    section(30,false)
    for i = 1, #(menuOptions), 1 do
        gfx.drawText("*" .. menuOptions[i].name .. "*", 0, 0)
        section(16,true)
    end
    gfx.setDrawOffset(0, 0)
    gfx.fillRoundRect(12 + accelerometerX + shakeX, hoverDisplayY - 4 - scrollY + accelerometerY + shakeY +
        subtleSelectionBump - 6, pd.display.getWidth() - 24, hoverDisplayHeight + 12, 4)
    gfx.fillRect(width + shakeX, -height + shakeY, width, height * 3)
    gfx.fillRect(-width + shakeX, -height + shakeY, width, height * 3)
    gfx.fillRect(width + shakeX, -height + shakeY, width, height)
    gfx.fillRect(width + shakeX, height + shakeY, width, height)
    if pd.buttonJustPressed(pd.kButtonA) then
        if menuOptions[hoverIndex].path ~= nil then
            appToOpen = menuOptions[hoverIndex].path
            simulatorWarning = ""
            if (pd.isSimulator) then
                simulatorWarning = "Applications run in the simulator may compromise your system."
            end
            confirm("Are you sure you want to run " .. menuOptions[hoverIndex].name .. "?" .. "\n\n" .. simulatorWarning
                , openApp, returnToMainMenu)
        else
            print(":(")
        end
    end
end

function formatTime()
    local time = pd.getTime()
    local hour = tostring(time.hour)
    local minute = tostring(time.minute)
    local second = tostring(time.second)
    while string.len(hour) < 2 do
        hour = "0" .. hour
    end
    while string.len(minute) < 2 do
        minute = "0" .. minute
    end
    while string.len(second) < 2 do
        second = "0" .. second
    end
    return hour .. ":" .. minute .. ":" .. second
end

indexSystem()

if #(menuOptions) == 0 then
    menuOptions[#(menuOptions) + 1] = {
        name = "No Applications Found"
    };
end

pd.datastore.write(logs, "logs")

update = mainMenu
local h = 0
gfx.clear()
local lastRenderedOffsetX, lastRenderedOffsetY = 0, 0
local lastScrollY = 0
local lastUpdateTick

function math.round(value)
    return math.floor(value + 0.5) --TODO: Fix this
end

function pd.update()
    if pd.buttonJustPressed(pd.kButtonUp) then
        easterEggTx = easterEggTx .. "u"
    end
    if pd.buttonJustPressed(pd.kButtonDown) then
        easterEggTx = easterEggTx .. "d"
    end
    if pd.buttonJustPressed(pd.kButtonLeft) then
        easterEggTx = easterEggTx .. "l"
    end
    if pd.buttonJustPressed(pd.kButtonRight) then
        easterEggTx = easterEggTx .. "r"
    end
    if pd.buttonJustPressed(pd.kButtonB) then
        easterEggTx = easterEggTx .. "b"
    end
    if pTime == nil then
        pTime = pd.getCurrentTimeMilliseconds()
    end
    deltaTime = (pd.getCurrentTimeMilliseconds() - pTime) / 1000
    deltaTime = deltaTime * 0.4
    pTime = pd.getCurrentTimeMilliseconds()
    if pd.isCrankDocked() ~= lastCrankDockstate then
        lastCrankDockstate = not lastCrankDockstate
        if pd.isCrankDocked() then
            shakeX = -10
        else
            shakeX = 10
        end
    end
    if not pd.accelerometerIsRunning() then
        accelerometerX, accelerometerY, accelerometerZ = 0, 0, 0
    else
        accelerometerX, accelerometerY, accelerometerZ = pd.readAccelerometer()
        accelerometerX = accelerometerX * 0.3
        accelerometerY = accelerometerY * 0.3
        accelerometerZ = accelerometerZ * 0.3
    end
    if accelerometerX == nil or accelerometerY == nil or accelerometerZ == nil then
        accelerometerX, accelerometerY, accelerometerZ = 0, 0, 0
    end
    shakeX = shakeX * (1 - deltaTime * 20)
    shakeY = shakeY * (1 - deltaTime * 20)
    subtleSelectionBump = subtleSelectionBump * (1 - deltaTime * 8)
    pd.display.setInverted(useDarkMode)
    h = 0
    width = pd.display.getWidth()
    height = pd.display.getHeight()
    if lastUpdateTick ~= update then
        lastUpdateTick = update
        gfx.clear()
        gfx.clearClipRect()
    else
        if update == mainMenu then
            margin = math.abs(subtleSelectionBump)
            gfx.setScreenClipRect(12 + accelerometerX + shakeX - margin, hoverDisplayY - 4 - scrollY + accelerometerY + shakeY +
        subtleSelectionBump - 6 - margin, pd.display.getWidth() - 24 + margin + margin, hoverDisplayHeight + 12 + margin + margin)
        end
        if update == confirmTick then
            gfx.setScreenClipRect(20,height-66-20,width-40,66+20)
        end
        --    gfx.clearClipRect()
        --    gfx.clear()
        --end
    end
    if (lastRenderedOffsetX ~= math.round(shakeX) or lastRenderedOffsetY ~= math.round(shakeY)) then
        gfx.clearClipRect()
        gfx.clear()
        lastRenderedOffsetX = math.round(shakeX)
        lastRenderedOffsetY = math.round(shakeY)
    end
    if lastScrollY ~= math.round(scrollY) then
        lastScrollY = math.round(scrollY)
        gfx.clearClipRect()
        gfx.clear()
    end
    gfx.setColor(gfx.kColorWhite)
    gfx.setDrawOffset(0,0)
    gfx.fillRect(gfx.getScreenClipRect())
    gfx.setColor(gfx.kColorXOR)
    updateOffset()
    update()
    gfx.clearClipRect()
    pd.drawFPS(0,0)
    if string.len(easterEggTx) > string.len(easterEggSequence) then
        easterEggTx = easterEggTx:sub(2)
    end
    if easterEggTx == easterEggSequence then 
        print("0mg 1337 hax0r man1!?!?!!?!?!")
        if confirmText == "Designed by Jessie. \n\nLGBTQ rights are human rights." then
            confirmText = "Double easter egg!!!!!!"
            print(":o double hax0r??!?!?!!")
            lastUpdateTick = nil
        else 
            confirm("Designed by Jessie. \n\nLGBT rights are human rights.",returnToMainMenu,returnToMainMenu)
        end
        easterEggTx = ""
    end
end

function section(height,selectable)
	--if (selectable) then
		workingSelectables[#(workingSelectables)+1] = {h,height};
	--end
    h = h + height + 10
    updateOffset()
end

function updateOffset()
    gfx.setDrawOffset(20 + accelerometerX * 2 + shakeX, 20 + h - scrollY + accelerometerY * 2 + shakeY)
end
