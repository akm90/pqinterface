local AddOnName, Env = ...; local ADDON, DT = Env[1], Env[1].development
-- ~~| Libraries |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local AceConfigRegistry	= LibStub("AceConfigRegistry-3.0")
local DiesalStyle 		= LibStub("DiesalStyle-1.0")
local DiesalGUI 			= LibStub("DiesalGUI-1.0")
local DiesalMenu 			= LibStub('DiesalMenu-1.0')
-- ~~| Lua Upvalues |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local pairs, ipairs							= pairs,ipairs
local type	 									= type
local gsub, sub, find, format 			= string.gsub, string.sub, string.find, string.format
local concat									= table.concat
-- ~~| WoW Upvalues |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
local GREY50		= ADDON:GetTxtColor('808080')
local BLUE			= ADDON:GetTxtColor('0099e6')	-- 90%
local ORANGE		= ADDON:GetTxtColor('e6c000') -- 90%
local PURPLE		= ADDON:GetTxtColor('9900e5') -- 90%
local RED90			= ADDON:GetTxtColor('e50000') -- 90%
local varUse		= format('\n\n%sThe following is a suggested use of variables for profile developers, there modular statements to make working with them easier as opposed to nesting.\nUsage: copy each lua statement into the first line of its respective PQR ability code.\n',GREY50)
local varRaw		= format('\n%sThe following values are just the variables sent by PQInterface for personal/advanced use.\n',GREY50)
-- ~~| AbilityLog Methods |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local methods = {	
	['ProfileUpdate'] = function(self)
		local db			= self.db
		local frame		= self.frame
		
		if next(self.settings.configs) then
			for key,config in pairs(self.settings.configs) do
				self:SetConfigDB(config)
			end
			self:UpdateRows()
		end
		-- ~~ Update Position ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~		
		frame:ClearAllPoints()		
		if db.top and db.left then
			frame:SetPoint("TOP",UIParent,"BOTTOM",0,db.top)
			frame:SetPoint("LEFT",UIParent,"LEFT",db.left,0)
		else
			frame:SetPoint("CENTER",UIParent,"CENTER")
		end
		frame:SetWidth(db.width)		
	end,
	['Update'] = function(self)
		-- Only called from core
		local db			= self.db
		local frame		= self.frame
		
		frame[db.show and "Show" or "Hide"](frame)	
		SetCVar('PQIVariablePrint',self.db.varDebug and 1 or 0)				
	end,	
	['AddConfig'] = function(self,config)
		local settings = self.settings		
		-- ~~ set option IDs ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		for i = 1, #config do
			local option = config[i]
			option.type = option.type and ADDON:Capitalize(option.type) or 'Toggle'
			if option.name then			
				option.id = format( '%s_%s_%s',config.id,option.type,gsub((gsub(option.name,'[^%w]','')),'c%x%x%x%x%x%x%x%x','') )
			end
		end
		-- ~~ add / update config ~~~~~~~~~~~~~~~~~~~~~~~~~~~
		settings.configs[config.id] = config
		-- ~~ Update configSelect ~~~~~~~~~~~~~~~~~~~~~~~~~
		settings.configList[config.id] = format('%s%s %s%s',GREY80,config.name,BLUE,config.author)
		self.configSelect:SetList(settings.configList)
		-- ~~ Update ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		if self.db.showOnConfig then self.window:Show() end
		self.window:SetSettings({
			footer			= true,
			footerHeight	= 23,
		},true)
		self:SetConfigDB(config)
		self:SetActiveConfig(config.id)
	end,
	['SetConfigDB'] = function(self,config)
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
	['SetActiveConfig'] = function(self, configID)
		if not self.settings.configs[configID] then return end				
		SetCVar('PQISendChannel',configID,'SetActiveConfigID')
		-- ~~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		local settings = self.settings
		local config	= settings.configs[configID]
		local rows 		= settings.rows
		local window	= self.window
		settings.activeConfig 	= config
		settings.activeConfigID = configID		
		-- ~~ Clear Rows ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		for i = 1 , #rows do
			DiesalGUI:Release(rows[i])
			rows[i] = nil
		end
		-- ~~ Set Rows ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		for i = 1, #config do
			local option 	= config[i]
			local height 	= option.name and 18 or 4	-- option or section
			local row 		= DiesalGUI:Create('Config'..option.type)
			rows[#rows+1] 	= row
			row:SetParentObject(window)
			row:SetSettings({
				height		= height,
				rows			= settings.rows,
				position		= i,
				data			= option,
			},true)
		end		
		-- ~~ Set height ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		local height = window.settings.height - window.content:GetHeight()
		for i = 1, #rows do
			height = height + rows[i]:GetHeight()
		end
		self.frame:SetHeight(height)
		-- ~~ Update ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		self.configSelect:EnableMouse(true)
		self.configSelect:SetValue(configID)
		self:UpdateVars()
		self:UpdateRows()		
	end,
	['UpdateRows'] = function(self)
		local activeConfigDB = self.db.configs[self.settings.activeConfigID]
		local rows = self.settings.rows
		for i = 1, #rows do
			rows[i][self.db.lock and "Lock" or "Unlock"](rows[i])			
			rows[i]:Update(activeConfigDB.sets[activeConfigDB.currentSet][rows[i].settings.data.id])
		end
		self:UpdateSetList()
	end,
	['UpdateVars'] = function(self)
		if not self.configVars:IsVisible() then return end
		
		local config	= self.settings.activeConfig		
		local vars = {format('%sConfigID: %s%s%s',BLUE,GREY80,config.id,varUse)}		
		for i = 1, #config do
			local option = config[i]
			if option.type ~='Section' then
				vars[#vars+1] = format('%sif not %s%s_Enable %sthen return false end',BLUE,GREY80,option.id,BLUE)				
				if option.type =='Hotkey' then
					vars[#vars+1] = format('%sif not %sPQI%s:%sIsHotkeys%s( %s%s_Value %s)',BLUE,PURPLE,ORANGE,PURPLE,ORANGE,GREY80,option.id,ORANGE)
				else
					vars[#vars+1] = format('%slocal %svalue %s= %s%s_Value',BLUE,GREY80,ORANGE,GREY80,option.id)	
				end
			end
		end		
		vars[#vars+1] = varRaw
		for i = 1, #config do
			local option = config[i]
			if option.type ~='Section' then
				vars[#vars+1] = format('%s%s_Enable',GREY80,option.id)				
				if option.type ~='Toggle' then vars[#vars+1] = format('%s%s_Value',GREY80,option.id) end
			end
		end
		self.scrollingEditBox:SetText(concat(vars,'\n'))
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
		self.db.configs[self.settings.activeConfigID].sets[key].name = value
		self:UpdateSetList()		
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
		top				= self.db.top,
		left				= self.db.left,
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
	configSelect:EnableMouse(false)
	configSelect:SetEventListener('OnValueSelected', function(this,event,key)
		self:SetActiveConfig(key)
	end)
	configSelect:SetEventListener('OnMouseUp', function(this,event,button)
		if button =='RightButton' then
			local configVars = self.configVars
			configVars[configVars:IsVisible() and 'Hide' or 'Show'](configVars)
			self:UpdateVars()
		end
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
		local PQI_RENAMESET 	= StaticPopup_Show("PQI_RENAMESET")
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
	lockButton:SetStyle('frame',{
		type			= 'texture',
		texFile		='DiesalGUIcons',
		texCoord		= {ADDON.db.profile.configurator.lock and 11 or 12,5,16,256,128},
		alpha 		= .7,
		offset		= {-2,nil,-2,nil},
		width			= 16,
		height		= 16,
	})
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
		lockButton:SetStyle('frame',{ type = 'texture', texCoord = {self.db.lock and 11 or 12,5,16,256,128} })	
	end)

	local configVars = DiesalGUI:Create('Window')
	configVars:SetSettings({
		height	 		= 500,
		width				= 500,
		minWidth 		= 500,
		maxWidth 		= 500,
		minHeight 		= 200,
		sizerR			= false,
		sizerB			= false,
		sizerBRHeight	= 32,
		sizerBRWidth	= 32,
	},true)
	configVars:SetTitle('Config Variables')
	configVars:SetStyle('content-background',{
		type			= 'texture',
		layer			= 'BACKGROUND',
		color			= '171717',
		offset		= 0,
	})
	configVars.sizerBR:SetPoint("BOTTOMRIGHT",configVars.frame,"BOTTOMRIGHT",-8,0)
	configVars.sizerBR:SetFrameLevel(100)
	configVars:Hide()
	local scrollingEditBox = DiesalGUI:Create('ScrollingEditBox')
	scrollingEditBox:SetParentObject(configVars)
	scrollingEditBox:SetSettings({
		contentPadTop		= 4,
		contentPadBottom	= 3,
		contentPadLeft		= 3,
		contentPadRight	= 3,
	},true)
	scrollingEditBox:SetPoint('TOPLEFT',-1,-1)
	scrollingEditBox:SetPoint('BOTTOMRIGHT',-2,1)
	-- ~~ Frames ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	self.window 				= window
	self.frame 					= window.frame

	self.configSelect 		= configSelect
	self.setSelect 			= setSelect
	self.lockButton 			= lockButton

	self.configVars 			= configVars
	self.scrollingEditBox 	= scrollingEditBox
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