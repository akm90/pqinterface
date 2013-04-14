local AddOnName, Env = ...
local ADDON = LibStub("AceAddon-3.0"):NewAddon(AddOnName,'AceHook-3.0',"AceConsole-3.0","AceEvent-3.0",'DiesalTools-1.0')
Env[1], _G[AddOnName] = ADDON, ADDON
ADDON.mediaPath = [[Interface\AddOns\]]..AddOnName..[[\media\]]
-- ~~| Development |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ADDON.development = DiesalDevelopment and DiesalDevelopment.Tools or {}
setmetatable(ADDON.development,{ __index = function(t, k) return function() return end end })
local DT = ADDON.development
-- ~~| Lua Upvalues |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local print, type, select, tostring, tonumber						= print, type, select, tostring, tonumber
local ipairs, pairs	 														= ipairs, pairs
local floor, modf 															= math.floor, math.modf
local table_remove, table_concat 										= table.remove, table.concat
local sub, format, match, lower											= string.sub, string.format, string.match, string.lower
-- ~~| WoW Upvalues |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local GetSpecialization, GetSpecializationInfo						= GetSpecialization, GetSpecializationInfo
local RegisterCVar, SetCVar, GetCVar									= RegisterCVar, SetCVar, GetCVar
-- ~~| ADDON Media |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

CreateFont("PQIFont_pixel")
PQIFont_pixel:SetFont( ADDON.mediaPath..[[FFF Intelligent Thin Condensed.ttf]], 8, "OUTLINE, MONOCHROME" )
-- ~~| ADDON constants |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ADDON.version 		= GetAddOnMetadata(AddOnName, "Version")
ADDON.myname  		= UnitName("player")
ADDON.myrealm 		= GetRealmName()
ADDON.defaultIcon = select(3,GetSpellInfo(4038))

-- ~~| Register CVars |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
RegisterCVar("PQREventsEnabled",'1') -- enables PQR events to fire
RegisterCVar("PQISendChannel",'') -- used to send data to PQI

-- ~~| StaticPopupDialogs |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
StaticPopupDialogs["PQI_RENAMESET"] = {
	text = "Are you sure you want to rename this set?",
	button1 = TEXT(YES),
	button2 = TEXT(NO),
	OnAccept = function(self)
		ADDON.Configurator:RenameSet(self.key,self.value)	
	end,
	OnCancel = function(self) 
		ADDON.Configurator:RenameSet(self.key)     
  	end,
	timeout = 0,
	hideOnEscape = 1,
	exclusive = 1,
	whileDead = 1,	
	preferredIndex = 3,
}
-- ~~| ADDON API |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--  [1] = 'Disabled', [2] = 'Spell Logging', [10] = 'All'
function	ADDON:Debug(debugLevel,s)	
	if ADDON.db.global.debugLevel == debugLevel then
		ChatFrame1:AddMessage(format("|cff00ffff<|cff00aaff%s|cff00ffff>|r %s",'PQI Debug',s))	 
	end
end
function ADDON:Print(s,...)
	if not s then return end
	print(format("|cff00ffff<|cff00aaff%s|cff00ffff>|r %s",AddOnName,s))	 
	return self:Print(...)
end
function ADDON:Error(s,...)
	if not s then return end
	print(format("|cff00aaff<%s>|cffff0000 %s",AddOnName,s))	
	return self:Error(...)
end
function ADDON:SendMsg(p,m,c,t)	
	SendAddonMessage(p,m,c,t)
end 




