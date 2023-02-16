class("UIRect").extends()

function UIRect:init(config)
	if config == nil then
		error("UIRect:init / config may not be nil")
	end

	if config.top == nil then
		error("UIRect:init / config must contain property 'top'")
	end
	if config.bottom == nil then
		error("UIRect:init / config must contain property 'bottom'")
	end
	if config.left == nil then
		error("UIRect:init / config must contain property 'left'")
	end
	if config.right == nil then
		error("UIRect:init / config must contain property 'right'")
	end

	self.top = config.top;
	self.bottom = config.bottom;
	self.left = config.left;
	self.right = config.right;
end
