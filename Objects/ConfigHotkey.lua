local AddOnName, Env = ... local ADDON = Env[1]
-- ~~| Development |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local DT = ADDON.development
-- ~~| Libraries |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local DiesalGUI 	= LibStub('DiesalGUI-1.0')
local DiesalStyle = LibStub("DiesalStyle-1.0")
-- ~~| Lua Upvalues |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local tostring										= tostring
local format 										= string.format
local concat 										= table.concat
-- ~~| WoW Upvalues |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- ~~| ConfigHotkey |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local TYPE 		= 'ConfigHotkey'
local VERSION 	= 1
-- ~~| ConfigHotkey StyleSheets |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local styleSheet = {
	['frame-background'] = {			
		type			= 'texture',
		layer			= 'BACKGROUND',								
		color			= '171717',		
		offset		= 0,		
	},
	['frame-left'] = {		
		type			= 'texture',
		layer			= 'BORDER',	
		color			= 'ffffff',
		alpha			= .031,
		offset		= {0,nil,0,0},	
		width			= 1,	
	},	
	['frame-right'] = {		
		type			= 'texture',
		layer			= 'BORDER',	
		color			= 'ffffff',
		alpha			= .03,
		offset		= {nil,0,0,0},	
		width			= 1,		
	},	
	['name-color'] = {		
		type			= 'Font',		
		color			= 'cbcbcb',		
	},
	['enable-shadow'] = {		
		type			= 'outline',
		layer			= 'BORDER',	
		color			= '000000',
		alpha 		= .17,
		offset		= {-2,-2,-3,-3},		
	},	
	['enable-highlight'] = {		
		type			= 'texture',
		layer			= 'BORDER',
		gradient		= 'VERTICAL',		
		color			= 'ffffff',
		alpha 		= 0,
		alphaEnd		= .07,
		offset		= {-3,-3,-4,-4},		
	},	
	['enable-innerShadow'] = {		
		type			= 'texture',
		layer			= 'BORDER',	
		color			= '000000',		
		offset		= {-4,-4,-5,-5},		
	},	
	['enable-innerColor'] = {		
		type			= 'texture',
		layer			= 'BORDER',	
		color			= '080808',		
		offset		= {-5,-5,-6,-6},		
	},	
	
}
-- ~~| ConfigHotkey Locals |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local function serializeValueTable(t)
	local buf = {}
	for i = 1, #t do
		buf[#buf+1] = format("%q", t[i])
	end		
	return format('{%s}',concat(buf,','))
end
-- ~~| ConfigHotkey Methods |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
		
		self:SetHeight(settings.height)		
		if settings.position == 1 then
			self:SetPoint('TOPLEFT') 
			self:SetPoint('RIGHT')			
		else			
			self:SetPoint('TOPLEFT',settings.rows[settings.position-1].frame,'BOTTOMLEFT',0,0)
			self:SetPoint('RIGHT')
		end		
				
		self.name:SetText(data.name)			
	end,	
	['Update'] = function(self)
		local db = self.settings.db
		SetCVar('PQISendChannel',format('return "%s_Enable",%s',db.id,tostring(db.enable)),'setVaraiable')
		SetCVar('PQISendChannel',format('return "%s_Value",%s',self.settings.db.id,serializeValueTable(db.value)),'setVaraiable')			
		self.enable:SetChecked(db.enable)
		self.dropdown:SetValueTable(db.value)
	end,
	['Lock'] = function(self,lock)		
		self.enable:EnableMouse(false)
		self.dropdown:EnableMouse(false)
	end,
	['Unlock'] = function(self,lock)		
		self.enable:EnableMouse(true)
		self.dropdown:EnableMouse(true)
	end,	
}
-- ~~| ConfigHotkey Constructor |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local function Constructor()
	local self 		= DiesalGUI:GetObjectBase(TYPE)
	local frame 	= self.frame
	-- ~~ Default Settings ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	self.defaults = {

	}
	-- ~~ Registered Events ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	-- ~~ Construct ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	local enable = self:CreateRegion("CheckButton", 'enable', frame)
	local check = self:CreateRegion("Texture", 'check', enable)
	DiesalStyle:StyleTexture(check,{		
		type			= 'texture',
		layer			= 'ARTWORK',			
		texFile		= 'DiesalGUIcons',
		texCoord		= {10,5,16,256,128},
		texColor		= 'ffff00',
		offset		= {-1,nil,-1,nil},
		width			= 16,
		height		= 16,	
	})
	enable:SetPoint("TOPLEFT",0,0)
	enable:SetPoint("BOTTOMLEFT",0,0)
	enable:SetWidth(16)
	enable:SetCheckedTexture(check)
	enable:SetScript('OnClick', function(this)		
		self.settings.db.enable = this:GetChecked() and true or false
		SetCVar('PQISendChannel',format('return "%s_Enable",%s',self.settings.db.id,tostring(self.settings.db.enable)),'setVaraiable')
	end)	

	local dropdown = DiesalGUI:Create('Dropdown') 
	dropdown:SetParent(frame)
	dropdown:SetPoint('TOPRIGHT',-2,-1)	
	dropdown:SetSettings({
		multiSelect = true,
		width			= 45,		
	},true)	
	dropdown:SetList({ la="la", ra="ra", ls="ls", rs="rs", lc="lc", rc="rc" },{ "la","ra","ls","rs","lc","rc" })	
	dropdown:SetEventListener('OnValueSelected', function(this,event,key,valuue,selectionTable)			
		self.settings.db.value = selectionTable		
		SetCVar('PQISendChannel',format('return "%s_Value",%s',self.settings.db.id,serializeValueTable(selectionTable)),'setVaraiable')		
	end)

	local name = self:CreateRegion("FontString", 'name', frame)
	name:SetPoint("TOPLEFT",enable,'TOPRIGHT',0,-10)
	name:SetPoint("TOPRIGHT",dropdown.frame,'TOPLEFT',-2,-10)
	name:SetHeight(1)		
	name:SetJustifyH("LEFT")
	name:SetWordWrap(false)		
	
	-- ~~ Frames ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	self.dropdown	= dropdown
	-- ~~ Methods ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	for method, func in pairs(methods) do
		self[method] = func
	end
	-- ~~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	DiesalGUI:RegisterObject(self)
	return self
end
DiesalGUI:RegisterObjectConstructor(TYPE,Constructor,VERSION)
