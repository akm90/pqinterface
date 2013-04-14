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
local gsub, sub, find, format 			= string.gsub, string.sub, string.find, string.format
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
		offset		= {1,1,1,0},
	},
	['header-contentTop'] = {
		type			= 'outline',
		layer			= 'BORDER',
		color			= '1c1c1c',		
		offset		= {0,0,nil,0},
		height		= 1,		
	},
	['footer-background'] = {
		type			= 'texture',
		layer			= 'BACKGROUND',
		color			= '000000',
	},
	['footer-foreground'] = {
		type			= 'texture',
		layer			= 'BORDER',
		gradient		= 'VERTICAL',						
		color			= '232323',
		colorEnd		= '272727',
		offset 		= {0,0,-3,0},	
	},
	['footer-outline'] = {			
		type			= 'outline',
		layer			= 'ARTWORK',
		color			= 'FFFFFF',
		gradient		= 'VERTICAL',
		alpha			= .02,
		alphaEnd		= .05,
		offset		= {0,0,-3,0},			
	},	
	['footer-contentTop'] = {
		type			= 'outline',
		layer			= 'BORDER',
		color			= '1c1c1c',		
		offset		= {0,0,0,nil},
		height		= 1,		
	},	
}
local dropdownStyleSheet = {
	['frame-background'] = {
		type			= 'texture',
		layer			= 'BACKGROUND',
		gradient		= 'VERTICAL',
		color			= 'ffffff',
		alpha 		= .12,
		alphaEnd		= .15,
		offset		= 0,
	},
	['frame-outline'] = {
		type			= 'outline',
		layer			= 'BORDER',
		color			= 'ffffff',
		alpha 		= .03,
	},
	['frame-inline'] = {		
		type			= 'outline',		
		alpha 		= 0,
		alphaEnd		= 0,			
	},	
	['frame-hover'] = {
		type			= 'outline',			
		offset		= 0,		
	},
	['frame-arrow'] = {
		type			= 'texture',
		layer			= 'BORDER',
		alpha 		= 0,
	},
	['text-color'] = {
		type			= 'Font',
		color			= 'cccccc',
	},
}
local lockButtonStyle = {
	type			= 'texture',
	texFile		='DiesalGUIcons',
	texCoord		= {11,5,16,256,128},
	alpha 		= .7,	
	offset		= {-2,nil,-2,nil},
	width			= 16,
	height		= 16,			
}
local lockButtonNormal = {
	type			= 'texture',	
	alpha 		= .7,			
}
local lockButtonOver = {
	type			= 'texture',	
	alpha 		= 1,		
} 
local lockButtonDisabled = {
	type			= 'texture',	
	alpha 		= .3,
}

-- ~~| AbilityLog Locals |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local GREY80		= ADDON:GetTxtColor('cbcbcb')
local BLUE90		= ADDON:GetTxtColor('0099e6')


-- ~~| AbilityLog Methods |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local methods = {
	['SetSettings'] = function(self,settings,update)
		for key,value in pairs(settings) do
			self.settings[key] = value
		end
		if update then self:Update()	end
	end,
	['Update'] = function(self)
		-- Only called from core
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
		
		self:UpdateButtons()
		
		if next(self.settings.configs) then
			-- ~~ Update Database ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			for key,value in pairs(self.settings.configs) do
				self:SetupConfigDB(value)
			end
			self:UpdateRows()
		end		
	end,
	['UpdateButtons'] = function(self)			
		-- lockButton
		if self.db.lock then 
			self.lockButton:SetStyle('frame',{ type = 'texture', texCoord = {11,5,16,256,128} })	
		else
			self.lockButton:SetStyle('frame',{ type = 'texture', texCoord = {12,5,16,256,128} })				
		end			
	end,		
	['UpdateTooltip'] = function(self)

	end,	
	['AddConfig'] = function(self,config,force)
		local settings = self.settings
		local name 	 	= gsub((gsub(config.name,'[^%w]','')),'c%x%x%x%x%x%x%x%x','')
		local author 	= gsub((gsub(config.author,'[^%w]','')),'c%x%x%x%x%x%x%x%x','')
		config.id	 	= format('PQI_%s%s',author,name)
		-- check rotation dosnt already exist
		if not force and settings.configs[config.id] then return end
		-- ~~ set option IDs ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		for i = 1, #config do
			local option = config[i]
			if option.name then
				option.type = option.type or 'Toggle'
				option.id = format('%s_%s_%s',config.id,option.type,gsub((gsub(option.name,'[^%w]','')),'c%x%x%x%x%x%x%x%x','')	)
			end
		end		
		-- ~~ add / update config ~~~~~~~~~~~~~~~~~~~~~~~~~~~
		settings.configs[config.id] = config
		-- ~~ Update configSelect ~~~~~~~~~~~~~~~~~~~~~~~~~	
		settings.configList[config.id] = format('%s%s %s%s',GREY80,config.name,BLUE90,config.author)
		self.configSelect:SetList(settings.configList)		
		-- ~~ Update ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		if self.db.showOnConfig then self.window:Show() end		
		self.window:SetSettings({
			footer			= true,
			footerHeight	= 23,		
		},true)		
		self:SetupConfigDB(config)
		self:SetActiveConfig(config.id)
	end,
	['SetupConfigDB'] = function(self,config)
		-- setup new Database entry
		if not self.db.configs[config.id] then
			self.db.configs[config.id] = {
				currentSet 		= 1,
				id 				= config.id,
				sets 				= {},
			}
		end
		-- update database entry
		local configDB = self.db.configs[config.id]
		for setnum = 1, 9 do	-- NUMBER OF SETS
			-- setup new set entry
			if not configDB.sets[setnum] then
				configDB.sets[setnum] = {
					name	= "set"..setnum,
					id 	= configDB.id,
				}
			end
			-- update options
			for i = 1, #config do
				if config[i].name then
					local option = config[i]					
					if not configDB.sets[setnum][option.id] then
						-- setup new option entry
						configDB.sets[setnum][option.id] = {
							id			= option.id,
							enable	= option.enable,
							value		= option.value,
							type		= option.type,
						}
					else
						-- update option entry
						local optionDB = configDB.sets[setnum][option.id]
						if optionDB.type ~= option.type then 
							optionDB.type	= option.type
							optionDB.value	= option.value
						end
					end
				end
			end
		end
	end,
	['SetActiveConfig'] = function(self,configID)
		if not self.settings.configs[configID] then return end
		
		local settings = self.settings
		local config	= settings.configs[configID]				 
		settings.activeConfig 	= config
		settings.activeConfigID = config.id		
		
		self:ClearRows()	
		self.configSelect:SetValue(configID)	
		-- ~~ Draw Rows ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~		
		for i = 1, #config do
			local option = config[i]			
			local height = option.name and 18 or 4	-- option or section 				 
			local row = DiesalGUI:Create('Config'..ADDON:Capitalize(option.type))
			self:AddRow(row)
			row:SetParentObject(self.window)
			row:SetSettings({						
				height		= height,
				rows			= settings.rows,
				position		= i,
				data			= option,
				db				= self.db.configs[config.id]
			},true)						
		end
		self:UpdateRows()		
		-- ~~ Set height ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~		
		local height = self.window.settings.height - self.window.content:GetHeight()
		for i = 1, #settings.rows do height = height + settings.rows[i]:GetHeight() end
		self.frame:SetHeight(height)	
	end,
	['AddRow'] = function(self,row)
		local rows = self.settings.rows
		rows[#rows + 1] = row
	end,
	['ClearRows'] = function(self)
		local rows = self.settings.rows
		for i = 1 , #rows do
			DiesalGUI:Release(rows[i])
			rows[i] = nil			
		end
	end,	
	['UpdateRows'] = function(self)		
		local activeConfigDB = self.db.configs[self.settings.activeConfigID]
		local rows = self.settings.rows
		for i = 1, #rows do
			rows[i][self.db.lock and "Lock" or "Unlock"](rows[i])				
			rows[i]:SetSettings({ db = activeConfigDB.sets[activeConfigDB.currentSet][rows[i].settings.data.id] })	
			rows[i]:Update()
		end
		self:UpdateSetList()	
	end,
	['UpdateSetList'] = function(self)
		local activeConfigDB = self.db.configs[self.settings.activeConfigID]		
		for i = 1, #activeConfigDB.sets do
			self.settings.orderedSetList[i] = i
			self.settings.setList[i] = activeConfigDB.sets[i].name			
		end
		self.setSelect:SetList(self.settings.setList,self.settings.orderedSetList)
		self.setSelect:SetValue(activeConfigDB.currentSet)	
	end,
	['RenameSet'] = function(self,key,value)	
		if value then  	
			self.db.configs[self.settings.activeConfigID].sets[key].name = value
			self:UpdateSetList()
		else
			self.setSelect:SetValue(key)	
		end
	end,
	['Show'] = function(self)		
		self.frame:Show()
	end,
	['Hide'] = function(self)
		self.frame:Hide()
	end,
}
-- ~~| AbilityLog Constructor |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function ADDON:constructConfigurator()
	local self = {}
	self.db = ADDON.db.profile.configurator
	-- ~~ Default Settings ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	local settings = {
		configs 			= {},
		rows 				= {},
		configList 		= {},
		setList			= {},
		orderedSetList	= {},
	}
	self.settings = settings
	-- ~~ Construct ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	local window = DiesalGUI:Create('Window')
	window:ReleaseTextures()
	window:AddStyleSheet(windowStyleSheet)
	window:SetSettings({
		header			= true,
		headerHeight	= 19,
		height	 		= 50,
		width				= self.db.width,
		minWidth 		= 180,
		minHeight 		= 218,
		sizerWidth		= 10,
		sizerB			= false,
		sizerBR			= false,
	},true)
	window:SetTitle('Configurator')
	window:SetEventListener('OnSizeChanged', function(this,event,width,height)
		self.db.width 	= width
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
	end)

	local configSelect = DiesalGUI:Create('Dropdown')
	configSelect:AddStyleSheet(dropdownStyleSheet)
	configSelect:SetParent(window.header)
	configSelect:SetPoint('TOPLEFT')
	configSelect:SetPoint('TOPRIGHT')
	configSelect:SetHeight(16)
	configSelect.text:SetJustifyH("CENTER")
	configSelect.text:SetPoint("BOTTOMRIGHT", -4, -2)
	configSelect:SetText('No Configurations Loaded')
	configSelect:SetEventListener('OnValueSelected', function(this,event,key)		
		self:SetActiveConfig(key)
	end)
	
	local setSelect = DiesalGUI:Create('ComboBox')
	setSelect:SetParent(window.footer)
	setSelect:SetPoint('TOPLEFT',18,-5)
	setSelect:SetPoint('TOPRIGHT',-2,-5)
	setSelect:SetHeight(16)	
	setSelect:SetEventListener('OnValueSelected', function(this,event,key)
		self.db.configs[self.settings.activeConfigID].currentSet = key
		self:UpdateRows()
	end)
	setSelect:SetEventListener('OnRenameValue', function(this,event,key,value)
		local PQI_RENAMESET = StaticPopup_Show("PQI_RENAMESET")    
		PQI_RENAMESET.key  	= key                       
		PQI_RENAMESET.value 	= value
	end)
	
	local lockButton = DiesalGUI:Create('Button')
	lockButton:SetParent(window.footer)
	lockButton:SetPoint('TOPLEFT',0,-3)	
	lockButton:SetSettings({		
		width			= 20,		
		height		= 20,
	},true)
	lockButton:SetStyle('frame',lockButtonStyle)	
	lockButton:SetEventListener('OnEnter', 	function() lockButton:SetStyle('frame',lockButtonOver) 		end)		
	lockButton:SetEventListener('OnLeave', 	function() lockButton:SetStyle('frame',lockButtonNormal)		end)		
	lockButton:SetEventListener('OnDisable', 	function() lockButton:SetStyle('frame',lockButtonDisabled)	end)		
	lockButton:SetEventListener('OnEnable', 	function() lockButton:SetStyle('frame',lockButtonNormal)		end)
	lockButton:SetEventListener('OnClick', 	function() 
		self.db.lock = not self.db.lock
		local rows = self.settings.rows
		for i = 1, #rows do
			rows[i][self.db.lock and "Lock" or "Unlock"](rows[i])		
		end
		self:UpdateButtons()
	end)
	
	-- ~~ Frames ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	self.window 				= window
	self.frame 					= window.frame

	self.configSelect 		= configSelect
	self.setSelect 			= setSelect	
	self.lockButton 			= lockButton	
	-- ~~ Methods ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	for method, func in pairs(methods) do
		self[method] = func
	end
	-- ~~ Style ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- self.textures = {}
	-- DiesalStyle:AddObjectStyleSheet(self,styleSheet)
	-- ~~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	return self
end