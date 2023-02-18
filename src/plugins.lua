import 'behaviors'

plugins = {}

class("Plugin").extends()

function Plugin:init(path)
	local pluginNamespace = {
		behavior=function(name)
			return behaviors[name]
		end,
		hasBehavior=function(name)
			return behaviors[name] ~= nil
		end
	}

	--TODO: Expose a limited version of json, we dont expose normal json because that would give access to the file system
	local legalLuaPrimitives = {"math","pairs","error","table","print","printTable","tostring"}

	for i, id in pairs(legalLuaPrimitives) do
		pluginNamespace[id] = _G[id]
	end

	pluginNamespace.uiHandler = nil
	playdate.file.load(path,pluginNamespace)()
	
	if pluginNamespace.uiHandler ~= nil then
		self.uiHandler = pluginNamespace.uiHandler
	else 
		self.uiHandler = function () end
	end
end

function Plugin:register()
	plugins[#(plugins)+1] = self
end
