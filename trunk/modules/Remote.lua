local AddOnName, Env = ...; local ADDON, DT = Env[1], Env[1].development
-- ~~| Libraries |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local AceConfigRegistry	= LibStub("AceConfigRegistry-3.0")
local DiesalStyle 		= LibStub("DiesalStyle-1.0")
local DiesalGUI 			= LibStub("DiesalGUI-1.0")
local DiesalMenu 			= LibStub('DiesalMenu-1.0')
-- ~~| Lua Upvalues |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local select, unpack						= select, unpack
local type	 								= type
local sub, find, format 				= string.sub, string.find, string.format
local floor, ceil, min, max			= math.floor, math.ceil, math.min, math.max
-- ~~| WoW Upvalues |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local GetSpellInfo, GetTime  = GetSpellInfo, GetTime
-- ~~| Remote |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- ~~| Remote StyleSheets |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local styleSheet = {
	['frame-background'] = {
		type			= 'texture',
		layer			= 'BACKGROUND',
		color			= '000000',
	},
	['frame-shadow'] = {
		type			= 'shadow',
		edgeFile		= ADDON.mediaPath..'shadow',
		alpha 		= .4,
	},
	['statusIcon-icon'] = {
		type			= 'texture',
		layer			= 'BACKGROUND',
		texFile		= ADDON.mediaPath..'PQRIcon',
		texCoord		= {2,1,18,64,32},
		offset		= -1,
	},
	['statusIcon-border'] = {
		type			= 'outline',
		layer			= 'BORDER',
		color			= 'ffffff',
		gradient		= 'VERTICAL',
		alpha 		= .07,
		alphaEnd 	= .12,
		offset		= -1,
	},
	['statusIcon-highlight'] = {
		type			= 'texture',
		layer			= 'BORDER',
		color			= 'ffffff',
		gradient		= 'VERTICAL',
		alpha 		= .07,
		alphaEnd 	= .2,
		offset		= {-1,-1,-1,nil},
		height		= 9,
	},
	['statusBar-border'] = {
		type			= 'outline',
		layer			= 'BORDER',
		color			= 'ffffff',
		gradient		= 'VERTICAL',
		alpha 		= .07,
		alphaEnd 	= .12,
		offset		= {0,0,-1,-1},
	},
	['statusBar-highlight'] = {
		type			= 'texture',
		layer			= 'BORDER',
		color			= 'ffffff',
		gradient		= 'VERTICAL',
		alpha 		= .07,
		alphaEnd		= .2,
		offset		= {0,0,-1,nil},
		height		= 9,
	},
	['interrupt-icon'] = {
		type			= 'texture',
		layer			= 'BACKGROUND',
		color			= '660000',
		offset		= -1,
	},
	['interrupt-border'] = {
		type			= 'outline',
		layer			= 'BORDER',
		color			= 'ffffff',
		gradient		= 'VERTICAL',
		alpha 		= .07,
		alphaEnd 	= .12,
		offset		= -1,
	},
	['interrupt-highlight'] = {
		type			= 'texture',
		layer			= 'BORDER',
		color			= 'ffffff',
		gradient		= 'VERTICAL',
		alpha 		= .07,
		alphaEnd 	= .2,
		offset		= {-1,-1,-1,nil},
		height		= 9,
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
-- ~~| Remote Locals |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local rotation, ability, rotationMode

local BLUE			= ADDON:GetTxtColor('00aaff')
local ORANGE		= ADDON:GetTxtColor('ffaa00')
local GREY			= ADDON:GetTxtColor('7f7f7f')
local RED			= ADDON:GetTxtColor('ff0000')
local GREEN			= ADDON:GetTxtColor('00ff2b')
local YELLOW		= ADDON:GetTxtColor('ffff00')
local WHITE			= ADDON:GetTxtColor('ffffff')
local modeColor = {
	manual		= ORANGE,
	auto			= GREEN,
	interrupt 	= BLUE,
}

local menuData = {
	{	name = 'Ability Log',
		onClick = function()
			local frame = ADDON.AbilityLog.frame
			frame[frame:IsVisible() and "Hide" or "Show"](frame)
			ADDON.AbilityLog.db.show = frame:IsVisible()
			AceConfigRegistry:NotifyChange(AddOnName)
		end,
		check	= function()
			return ADDON.AbilityLog.db.show
		end,
	},
	{	name = 'Configurator',
		onClick = function()
			local frame = ADDON.Configurator.frame
			frame[frame:IsVisible() and "Hide" or "Show"](frame)
			ADDON.Configurator.db.show = frame:IsVisible()
			AceConfigRegistry:NotifyChange(AddOnName)
		end,
		check	= function()
			return ADDON.Configurator.db.show
		end,
	},
	{	name = 'Options',
		onClick = function()
			ADDON:OpenOptions()
		end,
	},
}

local function GetTooltipAnchor(frame,yOffset)
	local x, y = frame:GetCenter()
	local screenHeight = GetScreenHeight()
	local anchor

	if not x then return "ANCHOR_TOP", yOffset end
	if y > (screenHeight / 4)*3 then
		anchor,yOffset = "ANCHOR_BOTTOM", -yOffset 	-- TOP
	else
		anchor,yOffset = "ANCHOR_TOP", yOffset  		-- BOTTOM
	end
	return anchor,yOffset
end
-- ~~| Remote Methods |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

		frame:SetWidth(db.width)
		frame:ClearAllPoints()

		if db.top and db.left then
			frame:SetPoint("TOP",UIParent,"BOTTOM",0,db.top)
			frame:SetPoint("LEFT",UIParent,"LEFT",db.left,0)
		else
			frame:SetPoint("CENTER",UIParent,"CENTER")
		end
	end,
	['UpdateTooltip'] = function(self)
		if GameTooltip:GetOwner() ~= self.frame then return end

		local rotations = ADDON.rotations
		GameTooltip:ClearLines()
		GameTooltip:AddLine(format('%sPQInterface Remote',BLUE))
		if ADDON.PQRLoaded then
			GameTooltip:AddLine(' ')
			for i = 1 , 4 do
				GameTooltip:AddDoubleLine(format('%sRotation %s:',BLUE,i),format("%s%s %s%s",WHITE,rotations[i].rotation or '<not set>',BLUE,rotations[i].author or ''))
			end
			GameTooltip:AddDoubleLine(format('%sInterrupt:',BLUE),format("%s%s %s%s",WHITE,rotations[5].rotation or '<not set>',BLUE,rotations[5].author or ''))
		end
		GameTooltip:AddLine(' ')
		GameTooltip:AddDoubleLine(format('%sRight Click:',BLUE),format('%sWindow Menu',YELLOW))
		GameTooltip:AddDoubleLine(format('%sMouse Wheel:',BLUE),format('%sAdjust Width',YELLOW))

		GameTooltip:Show()
	end,
	['SetStatus'] = function(self,status,data)
		self.settings.status = status
		if status == 'count' then
			self:SetCount(data)
		elseif status == 'ability' then
			self:SetText(format('%s%s: %s%s',modeColor[data.mode],data.rotation,WHITE,data.abilityName))
			self:SetCount(data.executeCount)
			local spellID = data.spellID == 0 and 4038 or data.spellID or 4038
			self:SetIcon( select(3,GetSpellInfo(spellID)), {.08, .92, .08, .92} )
		elseif status == 'autoRotationStart' then
			self:SetCount('')
			self:SetText(format('%s%s: %s%s',GREEN,data[1],YELLOW,data[2]))
		elseif status == 'ready' then
			self:SetText(format('%sReady',BLUE))
			self:SetCount('')
			self:SetIcon(ADDON.mediaPath..'PQRIcon',ADDON:Pack(ADDON:GetIconCoords(1,1,18,64,32)))
		elseif status == 'unloaded' then
			self:SetText(format('%sPQR Unloaded.',RED))
			self:SetCount('')
			self:SetIcon(ADDON.mediaPath..'PQRIcon',ADDON:Pack(ADDON:GetIconCoords(2,1,18,64,32)))
		end
	end,
	['GetStatus'] = function(self)
		return self.settings.status
	end,
	['SetText'] = function(self,text)
		self.statusText:SetText(text)
	end,
	['SetCount'] = function(self,count)
		self.statusIconCount:SetText(count)
	end,
	['SetIcon'] = function(self, icon, coords)
		self.textures['statusIcon-icon']:SetTexture(icon)
		self.textures['statusIcon-icon']:SetTexCoord(coords[1],coords[2],coords[3],coords[4])
	end,
	['SetInterrupt'] = function(self,enabled)
		if enabled then
			DiesalStyle:StyleTexture(self.textures['interrupt-icon'],{color = '006600',})
		else
			DiesalStyle:StyleTexture(self.textures['interrupt-icon'],{color = '660000',})
		end
	end,
	['Show'] = function(self)
		self.frame:Show()
	end,
	['Hide'] = function(self)
		self.frame:Hide()
	end,
}
-- ~~| Remote Constructor |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function ADDON:constructRemote()
	local self = {}
	self.db = ADDON.db.profile.remote
	-- ~~ Default Settings ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	local settings = {
		height	= 20,
	}
	self.settings = settings
	-- ~~ Construct ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		local frame = CreateFrame('Frame',nil,UIParent)
	frame:SetHeight(settings.height)
	frame:EnableMouse()
	frame:SetMovable(true)
	frame:SetResizable(true)
	frame:SetToplevel(true)
	frame:SetScript("OnMouseDown", function(this,button)
		DiesalGUI:OnMouse(this,button)
		GameTooltip:Hide()

		if button == 'LeftButton' then
			frame:StartMoving()
		elseif button == 'RightButton' then

			DiesalMenu:Menu(menuData,this,2,-21)
		end
	end)
	frame:SetScript("OnMouseUp", function(this)
		frame:StopMovingOrSizing()

		self.db.top 	= ADDON:Round(frame:GetTop())
		self.db.left	= ADDON:Round(frame:GetLeft())

		self:Update()
	end)
	frame:SetScript("OnMouseWheel", function(this,delta)

		if delta > 0 then
			self.db.width = min(self.db.width + 10, 600 )
		else
			self.db.width = max(self.db.width - 10, 200 )
		end
		self:Update()
		AceConfigRegistry:NotifyChange(AddOnName)
	end)
	frame:SetScript("OnEnter", function(this)
		local anchor,yOffset =  GetTooltipAnchor(self.frame,5)
		GameTooltip:SetOwner(self.frame, anchor, 0, yOffset)
		self:UpdateTooltip()
	end)
	frame:SetScript("OnLeave", function(this)
		GameTooltip:Hide()
	end)

	local statusIcon = CreateFrame("Frame",nil,frame)
	statusIcon:SetPoint("TOPLEFT")
	statusIcon:SetWidth(settings.height)
	statusIcon:SetHeight(settings.height)
	local statusIconCount = statusIcon:CreateFontString(nil,"OVERLAY",'PQIFont_pixel')
	statusIconCount:SetPoint("CENTER",1,1)

	local statusBar = CreateFrame("Frame",nil,frame)
	statusBar:SetPoint("TOPLEFT",settings.height,0)
	statusBar:SetPoint("TOPRIGHT",-settings.height,0)
	statusBar:SetHeight(settings.height)
	local statusText = statusBar:CreateFontString(nil,"OVERLAY",'DiesalFontNormal')
	statusText:SetPoint("TOPLEFT",3,-5)
	statusText:SetPoint("BOTTOMRIGHT",-3,0)
	statusText:SetJustifyH("LEFT")
	statusText:SetJustifyV("TOP")
	statusText:SetWordWrap(false)
	statusText:SetText(format('%sPQR Not Loaded.',RED))

	local interrupt = CreateFrame("Frame",nil,frame)
	interrupt:SetPoint("TOPRIGHT")
	interrupt:SetWidth(settings.height)
	interrupt:SetHeight(settings.height)
	-- ~~ Frames ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	self.frame 					= frame

	self.statusIcon 			= statusIcon
	self.statusIconCount 	= statusIconCount
	self.statusBar 			= statusBar
	self.statusText 			= statusText
	self.interrupt 			= interrupt
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