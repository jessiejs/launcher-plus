import "rect"
import "constants"

class("Allocation").extends()

function Allocation:init(config)
	if config == nil then
		error("Allocation:init / config may not be nil")
	end

	if config.height == nil then
		error("Allocation:init / config must contain property 'height'")
	end
	if config.top == nil then
		error("Allocation:init / config must contain property 'top'")
	end

	self.height = config.height;
	self.top = config.top;
end

function Allocation:rect() 
	-- UIRect:init runs hot so we just don't do it :)
	return {
		top=self.top,
		bottom=self.top+self.height,
		left=EDGE_PADDING,
		right=SCREEN_WIDTH-EDGE_PADDING
	}
end
