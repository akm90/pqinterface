local AddOnName, Env = ... local ADDON = Env[1] 
-- ~~| Development |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local DT = ADDON.development
-- ~~| Libraries |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local LibDBIcon			= LibStub("LibDBIcon-1.0",true)
local AceDB					= LibStub("AceDB-3.0")
local AceDBOptions 		= LibStub("AceDBOptions-3.0")
local AceConfigRegistry	= LibStub("AceConfigRegistry-3.0")
local AceConfigDialog 	= LibStub("AceConfigDialog-3.0")
local LibDataBroker		= LibStub("LibDataBroker-1.1")
local LibDBIcon 			= LibStub("LibDBIcon-1.0",true)
-- ~~| Lua Upvalues |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local select, print						= select, print
local type, tostring, tonumber		= type, tostring, tonumber
local getmetatable						= getmetatable
local sub, find, format, split		= string.sub, string.find, string.format, string.split
local floor 								= math.floor
local remove 								= table.remove
-- ~~| WoW Upvalues |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local GetSpellInfo, GetTime  			= GetSpellInfo, GetTime
-- ~~| Locals |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- ~~| ADDON States |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function ADDON:OnInitialize()
	-- Database	
	self.db = AceDB:New("PQInterfaceDB", self.defaults, true);
	self.db.RegisterCallback(self, "OnProfileChanged", "ProfileUpdate")
	self.db.RegisterCallback(self, "OnProfileCopied", "ProfileUpdate")
	self.db.RegisterCallback(self, "OnProfileReset", "ProfileUpdate")	
	-- Options
	self.options.args.profile = AceDBOptions:GetOptionsTable(self.db)
	self.options.args.profile.order = -10
	AceConfigRegistry:RegisterOptionsTable(AddOnName, ADDON.options)
	self.optionsFrame = AceConfigDialog:AddToBlizOptions(AddOnName, nil, nil, "general")	
	AceConfigDialog:AddToBlizOptions(AddOnName, "Profiles", AddOnName, "profile")
	-- DataBroker Launcher Plugin
	self.launcher = LibDataBroker:NewDataObject(AddOnName,{
		type 				= "launcher",
		label 			= AddOnName,
		icon 				= ADDON.mediaPath.."LDBIcon",
		OnClick 			= function(self,button)
			if button == "LeftButton" then 
			if ADDON:IsEnabled() then ADDON:Disable() else ADDON:Enable() end
			AceConfigRegistry:NotifyChange(AddOnName)	
			else
				InterfaceOptionsFrame_OpenToCategory(ADDON.optionsFrame)		
			end
		end,	
		OnTooltipShow 	= function(tooltip)
			tooltip:AddLine(AddOnName, 0, .66, 1)
			tooltip:AddLine(" ")			
			tooltip:AddDoubleLine("Left Click:","Toggle Addon", 0, .66, 1, 1, .83, 0)
			tooltip:AddDoubleLine("Right Click:","Open Config", 0, .66, 1, 1, .83, 0)

		end,      
	})
	RegisterAddonMessagePrefix('Diesal')
	-- Minimap button
	LibDBIcon:Register(AddOnName,self.launcher,self.db.global.minimap) 	
	-- Slash commands
	self:RegisterChatCommand('PQI','CommandHandler')		
	-- Construction
	self.CastLog:SetMax(ADDON.db.profile.abilityLog.castLogMax)	
	
	self.Remote = ADDON:constructRemote()	
	self.Remote:Update()	
	self.AbilityLog = ADDON:constructAbilityLog()	
	self.AbilityLog:Update()
	
	DT.Explore('AbilityLog',self.AbilityLog,3)	
	self:Print("v"..ADDON.version.." Loaded.")		
end
function ADDON:OnEnable() 
	-- self.garbageCollectionTimer = self:ScheduleRepeatingTimer('GarbageCollection', 100) 	
	self.Remote:Show()

	self:Update()	
	self:Print("Visible.")			
end
function ADDON:OnDisable()	
	self.Remote:Hide()
	
	self:Print("Hidden.")	
end
-- ~~| ADDON Update |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function ADDON:ProfileUpdate()
	self.db = AceDB:New("PQInterfaceDB", self.defaults, true);
	self.db.RegisterCallback(self, "OnProfileChanged", "ProfileUpdate")
	self.db.RegisterCallback(self, "OnProfileCopied", "ProfileUpdate")
	self.db.RegisterCallback(self, "OnProfileReset", "ProfileUpdate")	
	-- Update Database Pointers
	self.Remote.db = ADDON.db.profile.remote
	self.AbilityLog.db = ADDON.db.profile.abilityLog
	-- Update	
	self:Update()	
end
function ADDON:Update()
	if not ADDON:IsEnabled() then return false end	
	-- Minimap icon	
	if self.db.global.minimap.hide then	LibDBIcon:Hide(AddOnName) else LibDBIcon:Show(AddOnName) end
		
	self.Remote:Update()	
	self.AbilityLog:Update()
end

