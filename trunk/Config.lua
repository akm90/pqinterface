local AddOnName, Env = ... local ADDON = Env[1] 
-- ~~| Libraries |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- ~~| Lua Upvalues |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- ~~| Default Database |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ADDON.defaults = {
	global = {
		enabled = true,
		locked = false,
		minimap = {
			hide = false,
		},			
	},
	profile = {
		debugLevel = 1,	
		
		remote = {
			executeCount = true,				
			width = 200,
			customText = true,			
		},
		abilityLog = {
			show = false,			
			tooltips = true,
			width			= 420,		
			height 		= 218,						
		},
		configurator = {
			show = true,
			showOnConfig = true,
			lock = false,			
			width = 200,			
			mouseWheel = true,
			toolTips = true,
			rotationToolTips = true,
			varDebug = 1,
			configs = {},			
		},				
	},		
}
-- ~~| Options |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ADDON.options = {
	type = "group",
	name = AddOnName,	
	args = {
		general = {
			order = 10,
			type = "group",
			name = "General Settings",
			cmdInline = true,
			get = GetGlobalOption,
			set = SetGlobalOption,
			args = {
			},
		},
	},
}