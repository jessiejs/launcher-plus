import 'constants'

function showPrompt() 
	gfx.clearClipRect()
	-- get sound
	bashSound = snd.sampleplayer.new("systemsfx/06-error-trimmed")
	bashSound:play()
	-- check if reduced flashing is enabled, if not, then flash the screen
	if not playdate.getReduceFlashing() then
		flashed = false
		i = 0
		repeat
			if flashed then
				gfx.clear(gfx.kColorWhite)
			else 
				gfx.clear(gfx.kColorBlack)
			end
			pd.display.flush()
			pd.wait(50)
			i += 1
			flashed = not flashed
		until i > 6
	end
	cursor = 0
	permissionPushback = 10
	while true do
		cursor += pd.getCrankChange() / 3

		if pd.buttonIsPressed(pd.kButtonUp) then
			permissionPushback += 0.15
		end

		if pd.buttonIsPressed(pd.kButtonDown) then
			permissionPushback -= 0.1
		end

		permissionPushback = math.floor(permissionPushback * 10) / 10

		if cursor > 0 then
			cursor -= permissionPushback
		end

		gfx.clear(gfx.kColorWhite)

		iconLeft = SCREEN_WIDTH/2-25
		iconTop = EDGE_PADDING

		gfx.setColor(gfx.kColorBlack)
		gfx.fillRoundRect(iconLeft,iconTop,50,50,12)

		gfx.setColor(gfx.kColorWhite)
		gfx.fillRoundRect(iconLeft+25-5,iconTop+10,10,18,5)
		gfx.fillRoundRect(iconLeft+25-5,iconTop+30,10,10,5)
		
		gfx.setColor(gfx.kColorBlack)
		text = "Settings would like to manage dark mode\nThere is not much harm to allowing this\n(darkMode.set)"
		text = "This would be a permission prompt.\nUp and down to control pushback\nPushback is " .. tostring(permissionPushback)
		fontBold:drawTextAligned(text,SCREEN_WIDTH/2,EDGE_PADDING + 50 + 20,kTextAlignment.center)
		
		iconSize = 23 -- FIXME MAKE THIS AUTOMATICALLY CHANGE
		
		gfx.setImageDrawMode(gfx.kDrawModeInverted)
		
		icons.check:draw(SCREEN_WIDTH-23-EDGE_PADDING,SCREEN_HEIGHT-23-EDGE_PADDING)
		icons.x:draw(EDGE_PADDING,SCREEN_HEIGHT-23-EDGE_PADDING)

		gfx.setImageDrawMode(gfx.kDrawModeCopy)

		gfx.setColor(gfx.kColorXOR)
		
		gfx.fillRoundRect(((SCREEN_WIDTH-iconSize)/2)+cursor,SCREEN_HEIGHT-iconSize-EDGE_PADDING,iconSize,iconSize,5)
		
		gfx.setColor(gfx.kColorBlack)

		pd.display.flush()
		pd.wait(20)
	end
	-- force screen update at end
	screenNeedsUpdate = true
end
