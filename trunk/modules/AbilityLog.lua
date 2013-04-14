local AddOnName, Env = ... local ADDON = Env[1]
-- ~~| Development |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local DT = ADDON.development
-- ~~| Libraries |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local AceConfigRegistry	= LibStub("AceConfigRegistry-3.0")
local DiesalStyle 		= LibStub("DiesalStyle-1.0")
local DiesalGUI 			= LibStub("DiesalGUI-1.0")
local DiesalMenu 			= LibStub('DiesalMenu-1.0')
-- ~~| Lua Upvalues |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local pairs, ipairs							= pairs,ipairs
local type	 									= type
local sub, find, format 					= string.sub, string.find, string.format
local floor, ceil, min, max				= math.floor, math.ceil, math.min, math.max
-- ~~| WoW Upvalues |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local GetTime  								= GetTime
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
	['header-outline'] = {
		type			= 'outline',
		layer			= 'BORDER',
		color			= '000000',
		offset		= 1,
	},	
	['content-background'] = {		
		type			= 'texture',
		layer			= 'BACKGROUND',
		color			= '0e0e0e',
		offset		= {0,0,-1,0},
	},
	['content-outline'] = {		
		type			= 'outline',
		layer			= 'BORDER',
		color			= 'FFFFFF',		
		alpha			= .03,
		offset		= {0,0,-1,0},
	},		
}
local styleSheet = {
	['headerCount-background'] = {
		type			= 'texture',
		layer			= 'BACKGROUND',
		gradient		= 'VERTICAL',
		color			= 'FFFFFF',
		alpha			= .10,
		alphaEnd		= .15,		
	},
	['headerCount-outline'] = {
		type			= 'outline',
		layer			= 'BORDER',
		color			= 'ffffff',
		alpha			= .03,
	},	
	['headerSpell-background'] = {
		type			= 'texture',
		layer			= 'BACKGROUND',
		gradient		= 'VERTICAL',
		color			= 'FFFFFF',
		alpha			= .10,
		alphaEnd		= .15,		
	},
	['headerSpell-outline'] = {
		type			= 'outline',
		layer			= 'BORDER',
		color			= 'ffffff',
		alpha			= .03,
	},
	['headerAbility-background'] = {
		type			= 'texture',
		layer			= 'BACKGROUND',
		gradient		= 'VERTICAL',
		color			= 'FFFFFF',
		alpha			= .10,
		alphaEnd		= .15,		
	},
	['headerAbility-outline'] = {
		type			= 'outline',
		layer			= 'BORDER',
		color			= 'ffffff',
		alpha			= .03,
	},
	['headerSend-background'] = {
		type			= 'texture',
		layer			= 'BACKGROUND',
		gradient		= 'VERTICAL',
		color			= 'FFFFFF',
		alpha			= .10,
		alphaEnd		= .15,		
	},
	['headerSend-outline'] = {
		type			= 'outline',
		layer			= 'BORDER',
		color			= 'ffffff',
		alpha			= .03,
	},
	['headerCast-background'] = {
		type			= 'texture',
		layer			= 'BACKGROUND',
		gradient		= 'VERTICAL',
		color			= 'FFFFFF',
		alpha			= .10,
		alphaEnd		= .15,		
	},
	['headerCast-outline'] = {
		type			= 'outline',
		layer			= 'BORDER',
		color			= 'ffffff',
		alpha			= .03,
	},	
}
-- ~~| AbilityLog Locals |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local BLUE			= ADDON:GetTxtColor('00aaff')
local ORANGE		= ADDON:GetTxtColor('ffaa00')
local GREY80		= ADDON:GetTxtColor('cbcbcb')
local RED			= ADDON:GetTxtColor('ff0000')
local GREEN			= ADDON:GetTxtColor('00ff2b')
local YELLOW		= ADDON:GetTxtColor('ffff00')
local WHITE			= ADDON:GetTxtColor('ffffff')

local lastRefreshTime = 0
local refreshThrottle = CreateFrame('Frame')
refreshThrottle:Hide()
function refreshThrottle:Check()
	if lastRefreshTime >= GetTime() then			
		self.throttle = .1
		self:Show()
	return true	end
	lastRefreshTime = GetTime() 	
end
refreshThrottle:SetScript('OnUpdate', function(this,elapsed)
	if this.throttle < 0 then
		ADDON.AbilityLog:RefreshLog()			
	else		
		this.throttle = this.throttle - elapsed			
	end	
end)
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
		frame[db.show and "Show" or "Hide"](frame)
		if db.top and db.left then
			frame:SetPoint("TOP",UIParent,"BOTTOM",0,db.top)
			frame:SetPoint("LEFT",UIParent,"LEFT",db.left,0)
		else
			frame:SetPoint("CENTER",UIParent,"CENTER")
		end
		frame:SetWidth(db.width)
		frame:SetHeight(db.height)
	end,
	['UpdateTooltip'] = function(self)

	end,
	['Show'] = function(self)
		self.frame:Show()
	end,
	['Hide'] = function(self)
		self.frame:Hide()
	end,	
	['SetSpellColWidth'] = function(self,width)		
		self.headerSpell:SetWidth(width)		
		self.settings.spellColWidth = width
		local rows = self.settings.rows
		for i = 1, #rows do
			rows[i].rowSpell:SetWidth(width)				
		end
	end,
	['SetNumRows'] = function(self,num)				
		if self.settings.numRows == num then return end
		self.settings.numRows = num
		self:RefreshLog()
	end,	
	['AddRow'] = function(self,row)
		local rows = self.settings.rows
		rows[#rows+1] = row
	end,
	['Clear'] = function(self,row)
		local rows = self.settings.rows
		for i =1, #rows do
			DiesalGUI:Release(rows[i])
			rows[i] = nil			
		end		
	end,
	['RefreshLog'] = function(self)
		refreshThrottle:Hide()
		if not self.frame:IsVisible() or not next(ADDON.CastLog) then return end
		-- throttle refresh
		if refreshThrottle:Check() then return end			
		
		self:Clear()
		
		local settings 	= self.settings
		local castLog 		= ADDON.CastLog		
		local castLogFrom = #castLog - settings.numRows
		local numRowsDrawn
		
		if castLogFrom < 1 then
			castLogFrom	= 0
			numRowsDrawn= #castLog 
		else 
			numRowsDrawn = settings.numRows
		end 			 
			
		for i = 1, numRowsDrawn do
			local row = DiesalGUI:Create('AbilityLogRow')
			self:AddRow(row)
			row:SetParentObject(self.window)
			row:SetSettings({
				spellColWidth	= settings.spellColWidth,				
				rowHeight		= settings.rowHeight,
				rows				= settings.rows,								
				position			= i,
				data				= castLog[i+castLogFrom],										
			},true)	
		end				
	end,	
}
-- ~~| AbilityLog Constructor |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function ADDON:constructAbilityLog()
	local self = {}
	self.db = ADDON.db.profile.abilityLog
	-- ~~ Default Settings ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	local settings = {
		rows 			= {},
		numRows		= 10,
		rowHeight	= 18,		
	}
	self.settings = settings
	-- ~~ Construct ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	local window = DiesalGUI:Create('Window')
	window:ReleaseTextures()
	window:AddStyleSheet(windowStyleSheet)
	window:SetSettings({
		header			= true,
		headerHeight	= 18,
		minWidth 		= 420,
		minHeight 		= 218,
		height			= self.db.height,
		width				= self.db.width,
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
		self:SetNumRows(floor((this.content:GetHeight()+1)*.0555556))	-- * .0555556 == /18		
		self:SetSpellColWidth(ADDON:Round((width-100) * .3))			
	end)
	window:SetEventListener('OnDragStop', function(this,event,left,top)
		self.db.left 	= left
		self.db.top 	= top					
	end)
	window:SetEventListener('OnHide', function(this,event)
		self.db.show = false
		AceConfigRegistry:NotifyChange(AddOnName)					
	end)
	window:SetEventListener('OnShow', function(this,event)
		self.db.show = true
		AceConfigRegistry:NotifyChange(AddOnName)	
		self:RefreshLog()			
	end)	

	local headerCount	= CreateFrame('Frame',nil,window.header)	
	local headerSpell = CreateFrame('Frame',nil,window.header)	
	local headerAbility = CreateFrame('Frame',nil,window.header)
	local headerSend = CreateFrame('Frame',nil,window.header)	
	local headerCast = CreateFrame('Frame',nil,window.header)
	
	headerCount:SetPoint('TOPLEFT')
	headerCount:SetPoint('BOTTOMLEFT')
	headerCount:SetWidth(settings.rowHeight-1)
	local headerCountText = headerCount:CreateFontString(nil)
	headerCountText:SetHeight(1)
	headerCountText:SetPoint('TOPLEFT',6,-9)	
	headerCountText:SetJustifyH("LEFT")
	headerCountText:SetFont(DiesalFontNormal:GetFont())
	headerCountText:SetText(format("%s#",GREY80))	
	
	headerSpell:SetPoint('TOPLEFT',headerCount,'TOPRIGHT',1,0)
	headerSpell:SetPoint('BOTTOMLEFT',headerCount,'BOTTOMRIGHT',1,0)
	local headerSpellText = headerSpell:CreateFontString(nil)
	headerSpellText:SetHeight(1)
	headerSpellText:SetPoint('TOPLEFT',5,-9)
	headerSpellText:SetJustifyH("TOP")	
	headerSpellText:SetJustifyH("LEFT")	
	headerSpellText:SetFont(DiesalFontNormal:GetFont())
	headerSpellText:SetText(format("%sSpell",GREY80))	
	
	headerAbility:SetPoint('TOPLEFT',headerSpell,'TOPRIGHT',1,0)
	headerAbility:SetPoint('BOTTOMRIGHT',headerSend,'BOTTOMLEFT',-1,0)
	local headerAbilityText = headerAbility:CreateFontString(nil)
	headerAbilityText:SetPoint('TOPLEFT',5,-4)	
	headerAbilityText:SetJustifyH("LEFT")	
	headerAbilityText:SetFont(DiesalFontNormal:GetFont())
	headerAbilityText:SetText(format("%sAbility",GREY80))		
	
	headerSend:SetPoint('TOPRIGHT',headerCast,'TOPLEFT',-1,0)
	headerSend:SetPoint('BOTTOMRIGHT',headerCast,'BOTTOMLEFT',-1,0)	
	headerSend:SetWidth(63) 
	local headerSendText = headerSend:CreateFontString(nil)
	headerSendText:SetPoint('TOPLEFT',5,-4)	
	headerSendText:SetJustifyH("LEFT")	
	headerSendText:SetFont(DiesalFontNormal:GetFont())
	headerSendText:SetText(format("%sSend",GREY80))	
	
	headerCast:SetPoint('TOPRIGHT')
	headerCast:SetPoint('BOTTOMRIGHT')
	headerCast:SetWidth(63) 
	local headerCastText = headerCast:CreateFontString(nil)
	headerCastText:SetPoint('TOPLEFT',5,-4)	
	headerCastText:SetJustifyH("LEFT")	
	headerCastText:SetFont(DiesalFontNormal:GetFont())
	headerCastText:SetText(format("%sCast",GREY80))	
		
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
	-- ~~ Style ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	self.textures = {}
	DiesalStyle:AddObjectStyleSheet(self,styleSheet)
	-- ~~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	return self
end