local AddOnName, Env = ...; local ADDON, DT = Env[1], Env[1].development
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
-- ~~ Garbage Collector ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ADDON.garbageCollector = CreateFrame('Frame')
ADDON.garbageCollector.time = 30
ADDON.garbageCollector:SetScript('OnUpdate', function(this,elapsed)
	if this.time < 0 then
		this.time = 30 -- 30 second garbage collection
		collectgarbage()
	else
		this.time = this.time - elapsed
	end
end)

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
	AceConfigDialog:AddToBlizOptions(AddOnName, nil, nil, "settings")
	AceConfigDialog:AddToBlizOptions(AddOnName, "Profiles", AddOnName, "profile")	
	-- DataBroker Launcher Plugin
	self.launcher = LibDataBroker:NewDataObject(AddOnName,{
		type 				= "launcher",
		label 			= AddOnName,
		icon 				= ADDON.mediaPath.."LDBIcon",
		OnClick 			= function(this,button)			
			ADDON:OpenOptions()				
		end,
		OnTooltipShow = function(tooltip)
			tooltip:AddLine(AddOnName, 0, .66, 1)
			tooltip:AddLine(" ")
			tooltip:AddDoubleLine("Click:","Open Config", 0, .66, 1, 1, .83, 0)
		end,
	})
	RegisterAddonMessagePrefix('Diesal')
	-- Minimap button
	LibDBIcon:Register(AddOnName,self.launcher,self.db.global.minimap)
	-- Slash commands
	self:RegisterChatCommand('PQI','CommandHandler')
	-- Construction
	self.Remote = ADDON:constructRemote()
	self.AbilityLog = ADDON:constructAbilityLog()
	self.Configurator = ADDON:constructConfigurator()
	-- Update
	self:Update()

	self:Print("v"..ADDON.version.." Loaded.")
	-- ~~ End of Function ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	DT.Explore('PQInterface',self,2)
end
function ADDON:OnEnable()
	-- self.garbageCollectionTimer = self:ScheduleRepeatingTimer('GarbageCollection', 100)
end
function ADDON:OnDisable()

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
	self.Configurator.db = ADDON.db.profile.configurator
	-- Update
	-- self.Remote:ProfileUpdate
	-- self.AbilityLog
	self.Configurator:ProfileUpdate()	
	self:Update()
end
function ADDON:Update()
	if not ADDON:IsEnabled() then return false end
	-- Minimap icon
	if self.db.global.minimap.hide then	LibDBIcon:Hide(AddOnName) else LibDBIcon:Show(AddOnName) end

	self.Remote:Update()
	self.AbilityLog:Update()
	self.Configurator:Update()
end

