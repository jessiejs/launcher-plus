--FIXES A VERY VERY BAD MEMORY LEAK!!!!
function playdate.graphics.drawTextAligned(str, x, y, textAlignment, lineHeightAdjustment)

	local font = g.getFont()
	if font == nil then print('error: no font set!') return 0, 0 end
	local lineHeight = font:getHeight() + font:getLeading() + math.floor(lineHeightAdjustment or 0)
	local ox = x
	str = ""..str -- if a number was passed in, convert it to a string
	local styleCharacterForNewline = ""

	-- gmatch create garbage!
	-- for line in str:gmatch("[^\r\n]*") do		-- split into hard-coded lines
		local line = str
		line = _addStyleToLine(styleCharacterForNewline, line)
		
		local width = g.getTextSize(line)
		
		if textAlignment == kTextAlignment.right then
			x = ox - width
		elseif textAlignment == kTextAlignment.center then
			x = ox - (width / 2)
		end
		
		g.drawText(line, x, y)
		
		y += lineHeight
		styleCharacterForNewline = _styleCharacterForNewline(line)
	-- end
	
end
