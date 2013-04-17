local AddOnName, Env = ...; local ADDON, DT = Env[1], Env[1].development
-- ~~| Libraries |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local AceConfigDialog 	= LibStub("AceConfigDialog-3.0")
-- ~~| Lua Upvalues |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- ~~| WoW Upvalues |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local SetCVar						= SetCVar
-- ~~|  |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function ADDON:OpenOptions()
	AceConfigDialog:Open(AddOnName)
	AceConfigDialog.OpenFrames[AddOnName].status.groups.treewidth = 100 -- CBF using GetStatusTable
	LibStub("AceConfigRegistry-3.0"):NotifyChange(AddOnName)	
end
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
			configs = {},
			varDebug = false,			
		},				
	},		
}
-- ~~| Options |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ADDON.options = {
	type = "group",
	name = AddOnName,
	args = {
		settings = {
			order = 10,
			type = "group",
			name = "Settings",
			args = {
				minimap = {
					type = "toggle",
					name = "Minimap Button",
					order = 10,
					disabled = function() return not ADDON:IsEnabled() end,
					get = function() return not ADDON.db.global.minimap.hide end,
					set = function(info,value)
						ADDON.db.global.minimap.hide = not value
						ADDON:Update()
					end,
					width = "normal",
				},
				spacer = {
					order = 20,
					type = "description",
					name = " ",
					width = "full",
				},
				-- ~~ remote ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
				remoteTitle = {
					order = 50,
					type = "description",
					name = "|cff00aaffRemote",
					fontSize = "large",
					width = "full",
				},
				executeCount = {
					type = "toggle",
					name = "Execute Count",
					order = 60,
					desc = "Toggles the execute count for the current ablity on the remote. Hint: the number overlaying the spell icon.",
					disabled = function() return not ADDON:IsEnabled() end,
					get = function() return ADDON.db.profile.remote.executeCount end,
					set = function(info,value) ADDON.db.profile.remote.executeCount = value; ADDON.Remote:Update() end,
					width = "normal",
				},
				remoteWidth = {
					type = "range",
					name = "Width",
					order = 70,
					desc = "Sets the remotes width.",
					min = 200, max = 600, step = 10,
					disabled = function() return not ADDON:IsEnabled() end,
					get = function() return ADDON.db.profile.remote.width end,
					set = function(info,value) ADDON.db.profile.remote.width = value; ADDON.Remote:Update() end,
					width = "normal",
				},
			},
		},
		debugging = {
			order = 20,
			type = "group",
			name = "Debugging",
			args = {
				varDebug = {
					type = "toggle",
					name = "PQR Variables",
					desc = "Print Variable updates for PQR Abilities to the chat frame.",
					order = 50,
					disabled = function() return not ADDON:IsEnabled() end,
					get = function() return ADDON.db.profile.configurator.varDebug end,
					set = function(info,value)
						ADDON.db.profile.configurator.varDebug = value
						SetCVar('PQIVariablePrint',value and 1 or 0)
					end,
					width = "normal",
				},				
			},
		},
	},
}