local AddOnName, Env = ... local ADDON = Env[1]
-- ~~| Development |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local DT = ADDON.development
-- ~~| Libraries |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local DiesalGUI = LibStub('DiesalGUI-1.0')
-- ~~| Lua Upvalues |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local type, select, tostring, tonumber				= type, select, tostring, tonumber
local ipairs, pairs	 									= ipairs, pairs
local floor, modf 										= math.floor, math.modf
local sub, format, match, lower						= string.sub, string.format, string.match, string.lower
-- ~~| WoW Upvalues |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- ~~| AbilityLogRow |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local Type 		= 'AbilityLogRow'
local Version 	= 1
-- ~~| AbilityLogRow StyleSheets |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local styleSheet = {
	['frame-background'] = {				
		type			= 'texture',
		layer			= 'BACKGROUND',		
		color			= '131313',		
		offset		= 0,		
	},
	['frame-topHighlight'] = {				
		type			= 'outline',
		layer			= 'BORDER',			
		color			= 'FFFFFF',		
		alpha			= .01,		
		offset		= {-18,0,0,nil},
		height		= 1,			
	},	
	['frame-inline'] = {				
		type			= 'outline',
		layer			= 'BORDER',			
		color			= 'FFFFFF',		
		alpha			= .03,		
		offset		= {-18,0,0,-1},	
	},		
	['frame-outline'] = {				
		type			= 'outline',
		layer			= 'BORDER',
		color			= '000000',
		offset		= {1,1,1,0},	
	},	
	['frame-iconDivide'] = {				
		type			= 'texture',
		layer			= 'BORDER',
		color			= '000000',
		offset		= {-17,nil,0,0},
		width			= 1,	
	},	
	
}
-- ~~| AbilityLogRow Locals |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 80% Brightness
local BLUE			= ADDON:GetTxtColor('008fd9')
local ORANGE		= ADDON:GetTxtColor('daa300')
local GREY			= ADDON:GetTxtColor('cbcbcb')
local RED			= ADDON:GetTxtColor('d90000')
local GREEN			= ADDON:GetTxtColor('00d905')
local YELLOW		= ADDON:GetTxtColor('ffff00')
local WHITE			= ADDON:GetTxtColor('ffffff')
local modeColor = {
	manual		= ORANGE,
	auto			= GREEN,
	interrupt 	= BLUE,	
}

local function formatGetTime(num)
	if type(num) ~= 'number' then return '' end
	local seconds,ms = modf (num)
	
	local d = format("%02.f", floor(num/86400))
	local h = format("%02.f", floor(num/3600 - (d*24)))
	local m = format("%02.f", floor(num/60 - (h*60) -(d*1440)));
	local s = format("%02.f", floor(num - (m*60) - (h*3600) - (d*86400) ));
	s = s + ms	
	return format("%s%s:%s%02.3f",BLUE,m,GREY,s)
end
-- ~~| AbilityLogRow Methods |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local methods = {
	['OnAcquire'] = function(self)
		self:AddStyleSheet(styleSheet)
		-- self:AddStyleSheet(wireFrameSheet)
		self:Show()
	end,
	['OnRelease'] = function(self)

	end,
	['ApplySettings'] = function(self)
		local settings = self.settings
		local data 		= settings.data
		
		self:SetHeight(settings.rowHeight)		
		if settings.position == 1 then
			self:SetPoint('TOPLEFT') 
			self:SetPoint('RIGHT')			
		else			
			self:SetPoint('TOPLEFT',settings.rows[settings.position-1].frame,'BOTTOMLEFT',0,0)
			self:SetPoint('RIGHT')
		end
		local alpha = type(data.cast) == 'number' and 1 or .3		
		
		self.rowIcon:SetTexture(select(3,GetSpellInfo(data.spellID == 0 and 4038 or data.spellID or 4038)))
		self.rowIcon:SetAlpha(alpha)
		self.rowCount:SetText(data.executeCount)
		self.rowCount:SetTextColor(1,1,1,alpha == .3 and .6 or 1)		
		self.rowAbility:SetText(format('%s%s',modeColor[data.mode],data.abilityName))
		self.rowAbility:SetTextColor(1,1,1,alpha)
		self.rowSpell:SetText(format('%s%s',GREY,data.spell))	
		self.rowSpell:SetTextColor(1,1,1,alpha)
		self.rowSend:SetText(formatGetTime(data.start))
		self.rowSend:SetTextColor(1,1,1,alpha)
		self.rowCast:SetText(formatGetTime(data.cast))
		self.rowCast:SetTextColor(1,1,1,alpha)
		self.rowSpell:SetWidth(settings.spellColWidth or 1)				
	end,
	['ShowTooltip'] = function(self)					
		if not ADDON.db.profile.abilityLog.tooltips then return end
		local data 	= self.settings.data				
		GameTooltip:SetOwner(self.frame, "ANCHOR_CURSOR" , 0, 0)		
		GameTooltip:AddDoubleLine("Spell:",data.spell, 0, .66, 1, 1, 1,1)
		GameTooltip:AddDoubleLine("SpellID:",data.spellID, 0, .66, 1, 1, 1,1)
		GameTooltip:AddDoubleLine("Ability:",data.abilityName, 0, .66, 1, 1, 1,1)
		GameTooltip:AddDoubleLine("Rotation:",format("%s|cff00aaff %s",data.rotation,data.author), 0, .66, 1, 1, 1,1)	
		GameTooltip:AddDoubleLine("PQR Mode:",data.mode, 0, .66, 1, 1, 1,1)
		GameTooltip:AddDoubleLine("Execute Count:",data.executeCount, 0, .66, 1, 1, 1,1)		
		GameTooltip:Show()
	end,		
}
-- ~~| AbilityLogRow Constructor |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Constructor()
	local self 		= DiesalGUI:GetObjectBase(Type)
	local frame 	= self.frame	
	-- ~~ Default Settings ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	self.defaults = {

	}
	-- ~~ Registered Events ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	-- ~~ Construct ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	frame:SetScript("OnEnter", function(this)				
		self:ShowTooltip()
	end) 
	frame:SetScript("OnLeave", function(this)		
		GameTooltip:Hide()
	end) 	
	
	
	local rowIcon		= self:CreateRegion("Texture", 'rowIcon', frame)
	local rowCount		= self:CreateRegion("FontString", 'rowCount', frame, PQIFont_pixel)
	local rowSpell 	= self:CreateRegion("FontString", 'rowSpell', frame)
	local rowAbility 	= self:CreateRegion("FontString", 'rowAbility', frame)
	local rowSend 		= self:CreateRegion("FontString", 'rowSend', frame)
	local rowCast 		= self:CreateRegion("FontString", 'rowCast', frame)

	rowCount:SetPoint('TOPLEFT',1,-4)
	rowCount:SetWidth(17)	
	rowCount:SetJustifyH("CENTER")	
	
	rowIcon:SetPoint('TOPLEFT')
	rowIcon:SetWidth(17)
	rowIcon:SetHeight(17)
	rowIcon:SetTexCoord(.08, .92, .08, .92)	
	
	rowSpell:SetPoint('TOPLEFT',rowIcon,'TOPRIGHT',6,-4)	
	rowSpell:SetJustifyH("LEFT")		

	rowAbility:SetPoint('TOPLEFT',rowSpell,'TOPRIGHT',1,0)
	rowAbility:SetPoint('TOPRIGHT',rowSend,'TOPLEFT',-10,0)	
	rowAbility:SetJustifyH("LEFT")		
	
	rowSend:SetPoint('TOPRIGHT',rowCast,'TOPLEFT',-8,0)
	rowSend:SetWidth(57)	
	rowSend:SetJustifyH("LEFT")	
	
	rowCast:SetPoint('TOPRIGHT',0,-4)
	rowCast:SetWidth(57)	
	rowCast:SetJustifyH("LEFT")	
	
	-- ~~ Methods ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	for method, func in pairs(methods) do
		self[method] = func
	end
	-- ~~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	DiesalGUI:RegisterObject(self)
	return self
end
DiesalGUI:RegisterObjectConstructor(Type,Constructor,Version)
