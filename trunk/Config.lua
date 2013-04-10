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
			rows = 10,
			mouseWheel = true,
			tooltips = true,
			castLogMax = 100,			
		},
		rotationConfig = {
			show = false,
			lock = false,			
			width = 200,			
			mouseWheel = true,
			toolTips = true,
			rotationToolTips = true,
			varDebug = 1,
			rotations = {},			
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