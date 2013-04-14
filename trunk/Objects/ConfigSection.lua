local AddOnName, Env = ... local ADDON = Env[1]
-- ~~| Development |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local DT = ADDON.development
-- ~~| Libraries |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local DiesalGUI = LibStub('DiesalGUI-1.0')
-- ~~| Lua Upvalues |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- ~~| WoW Upvalues |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- ~~| ConfigSection |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local TYPE 		= 'ConfigSection'
local VERSION 	= 1
-- ~~| ConfigSection StyleSheets |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local styleSheet = {
	['frame-background'] = {			
		type			= 'texture',
		layer			= 'BACKGROUND',								
		color			= '000000',		
		offset		= 0,		
	},
	['frame-top'] = {		
		type			= 'texture',
		layer			= 'BORDER',	
		color			= '1c1c1c',		
		offset		= {0,0,0,nil},	
		height			= 1,	
	},	
	['frame-bottom'] = {		
		type			= 'texture',
		layer			= 'BORDER',	
		color			= '1c1c1c',		
		offset		= {0,0,nil,0},	
		height		= 1,		
	},	
}
-- ~~| ConfigSection Locals |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- ~~| ConfigSection Methods |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local methods = {
	['OnAcquire'] = function(self)		
		self:AddStyleSheet(styleSheet)
		self:Show()
	end,
	['OnRelease'] = function(self)
	end,
	['ApplySettings'] = function(self)
		local settings = self.settings		
		
		self:SetHeight(settings.height)		
		if settings.position == 1 then
			self:SetPoint('TOPLEFT') 
			self:SetPoint('RIGHT')			
		else			
			self:SetPoint('TOPLEFT',settings.rows[settings.position-1].frame,'BOTTOMLEFT',0,0)
			self:SetPoint('RIGHT')
		end
	end,
	['Update'] = function(self) 
	end,
	['Lock'] = function(self,lock)		
	end,
	['Unlock'] = function(self,lock)			
	end,	
}
-- ~~| ConfigSection Constructor |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local function Constructor()
	local self 		= DiesalGUI:GetObjectBase(TYPE)
	local frame 	= self.frame
	-- ~~ Default Settings ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	self.defaults = { }
	-- ~~ Registered Events ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- ~~ Construct ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	-- ~~ Methods ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	for method, func in pairs(methods) do
		self[method] = func
	end
	-- ~~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	DiesalGUI:RegisterObject(self)
	return self
end
DiesalGUI:RegisterObjectConstructor(TYPE,Constructor,VERSION)
