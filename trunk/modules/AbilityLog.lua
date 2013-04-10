local AddOnName, Env = ... local ADDON = Env[1]
-- ~~| Development |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local DT = ADDON.development
-- ~~| Libraries |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local AceConfigRegistry	= LibStub("AceConfigRegistry-3.0")
local DiesalStyle 		= LibStub("DiesalStyle-1.0")
local DiesalGUI 			= LibStub("DiesalGUI-1.0")
local DiesalMenu 			= LibStub('DiesalMenu-1.0')
local LibDBIcon 			= LibStub("LibDBIcon-1.0",true)
-- ~~| Lua Upvalues |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local select, unpack						= select, unpack
local type	 								= type
local sub, find, format 				= string.sub, string.find, string.format
local floor, ceil, min, max			= math.floor, math.ceil, math.min, math.max
-- ~~| WoW Upvalues |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local GetSpellInfo, GetTime  = GetSpellInfo, GetTime
-- ~~| AbilityLog |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- ~~| AbilityLog StyleSheets |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local windowStyleSheet = {
	['frame-background'] = {
		type			= 'texture',
		layer			= 'BACKGROUND',
		color			= '080808',
		offset		= 0,
	},
	['frame-shadow'] = {
		type			= 'shadow',
	},
	['frame-outline'] = {
		type			= 'outline',
		layer			= 'BORDER',
		color			= '000000',
		offset		= 0,
	},
	['frame-inline'] = {
		type			= 'outline',
		layer			= 'BORDER',
		color			= '000000',
		offset		= {-2,-2,-17,-2},
	},
	['titleBar-background'] = {
		type			= 'texture',
		layer			= 'BACKGROUND',
		gradient		= 'VERTICAL',
		color			= 'FFFFFF',
		alpha			= .01,
		alphaEnd		= .02,
		offset 		= -1,
	},
	['titleBar-outline'] = {
		type			= 'outline',
		layer			= 'ARTWORK',
		gradient		= 'VERTICAL',
		color			= 'FFFFFF',
		alpha			= .01,
		alphaEnd		= .03,
		offset		= -1,
	},
	['titletext-Font'] = {
		type			= 'font',
		color			= 'd8d8d8',
	},
	['closeButton-icon'] = {
		type			= 'texture',
		layer			= 'ARTWORK',
		texFile		= 'DiesalGUIcons',
		texCoord		= {9,5,16,256,128},
		alpha 		= .4,
		offset		= {-2,nil,-2,nil},
		width			= 16,
		height		= 16,
	},
	['closeButton-iconHover'] = {
		type			= 'texture',
		layer			= 'HIGHLIGHT',
		texFile		= 'DiesalGUIcons',
		texCoord		= {9,5,16,256,128},
		texColor		= 'b30000',
		alpha			= 1,
		offset		= {-2,nil,-2,nil},
		width			= 16,
		height		= 16,
	},
	['header-background'] = {
		type			= 'texture',
		layer			= 'BACKGROUND',
		color			= '000000',
	},
}


local wireframe = {
	['frame-red'] = {
		type			= 'outline',
		layer			= 'BACKGROUND',
		color			= 'ff0000',
	},
	['statusIcon-yellow'] = {
		type			= 'outline',
		layer			= 'BACKGROUND',
		color			= 'fffc00',
	},
	['statusBar-green'] = {
		type			= 'outline',
		layer			= 'BACKGROUND',
		color			= '00ff00',
	},
	['interruptIcon-blue'] = {
		type			= 'outline',
		layer			= 'BACKGROUND',
		color			= '0000ff',
	},
}
-- ~~| AbilityLog Locals |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local BLUE			= ADDON:GetTxtColor('00aaff')
local ORANGE		= ADDON:GetTxtColor('ffaa00')
local GREY			= ADDON:GetTxtColor('7f7f7f')
local RED			= ADDON:GetTxtColor('ff0000')
local GREEN			= ADDON:GetTxtColor('00ff2b')
local YELLOW		= ADDON:GetTxtColor('ffff00')
local WHITE			= ADDON:GetTxtColor('ffffff')

-- ~~| AbilityLog Methods |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local methods = {
	['SetSettings'] = function(self,settings,update)
		for key,value in pairs(settings) do
			self.settings[key] = value
		end
		if update then self:Update()	end
	end,
	['Update'] = function(self)
		local db			= self.db
		local frame		= self.frame


		frame:ClearAllPoints()

		if db.top and db.left then
			frame:SetPoint("TOP",UIParent,"BOTTOM",0,db.top)
			frame:SetPoint("LEFT",UIParent,"LEFT",db.left,0)
		else
			frame:SetPoint("CENTER",UIParent,"CENTER")
		end
	end,
	['UpdateTooltip'] = function(self)

	end,
	['Show'] = function(self)
		self.frame:Show()
	end,
	['Hide'] = function(self)
		self.frame:Hide()
	end,
}
-- ~~| AbilityLog Constructor |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function ADDON:constructAbilityLog()
	local self = {}
	self.db = ADDON.db.profile.abilityLog
	-- ~~ Default Settings ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	local settings = {
		rowHeight	= 17,
		rowSpacing	= 1,
	}
	self.settings = settings
	-- ~~ Construct ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	local window = DiesalGUI:Create('Window')
	window:ReleaseTextures()
	window:AddStyleSheet(windowStyleSheet)
	window:SetSettings({
		header			= true,
		headerHeight	= 18,
		width				= 500,
		minWidth 		= 400,
		sizerR			= false,
		sizerB			= false,
		sizerBRHeight	= 32,
		sizerBRWidth	= 32,
	},true)
	window:SetTitle('Ability Log')
	window.sizerBR:SetPoint("BOTTOMRIGHT",window.frame,"BOTTOMRIGHT",0,0)
	window.sizerBR:SetFrameLevel(100)
	window:SetEventListener('OnSizeChanged', function(this,event,width,height)
		self.db.width 	= width
		self.db.height = height
	end)

	local headerCount	= CreateFrame('Frame',nil,window.header)
	headerCount:SetPoint('TOPLEFT')
	headerCount:SetPoint('BOTTOMLEFT')
	headerCount:SetWidth(settings.rowHeight)
	local headerSpell = CreateFrame('Frame',nil,window.header)
	headerSpell:SetPoint('TOPLEFT',headerCount,'TOPRIGHT',1,0)
	headerSpell:SetPoint('BOTTOMLEFT',headerCount,'TOPRIGHT',1,0)
	headerSpell:SetWidth(180) -- temp
	
	local headerAbility = CreateFrame('Frame',nil,window.header)

	local headerSend = CreateFrame('Frame',nil,window.header)

	local headerCast = CreateFrame('Frame',nil,window.header)




	-- ~~ Frames ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	self.window 				= window
	self.frame 					= window.frame

	self.headerCount 			= headerCount
	self.headerSpell 			= headerSpell
	self.headerAbility 		= headerAbility
	self.headerSend 			= headerSend
	self.headerCast 			= headerCast

	-- ~~ Methods ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	for method, func in pairs(methods) do
		self[method] = func
	end
	-- ~~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	return self
end