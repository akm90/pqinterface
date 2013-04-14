local AddOnName, Env = ... local ADDON = Env[1] 
-- ~~| Development |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local DT = ADDON.development
-- ~~| Libraries |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- ~~| Lua Upvalues |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local select, print						= select, print
local type, tostring, tonumber		= type, tostring, tonumber
local getmetatable						= getmetatable
local sub, find, format, split		= string.sub, string.find, string.format, string.split
local floor 								= math.floor
local remove 								= table.remove
-- ~~| WoW Upvalues |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local GetSpellInfo, GetTime  			= GetSpellInfo, GetTime
-- ~~| Objects |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ADDON.rotations = {
	{},{},{},{},	-- Rotation  [1-4]
	{},				-- Interrupt [5]
}
local LOGMAX = 100
ADDON.CastLog = setmetatable({},{__index = {	
	['LogCast'] = function(self,data)
		local n = #self					
		self[n + 1] = data	
		if n >= LOGMAX then remove(self,1) end	
		ADDON.AbilityLog:RefreshLog()			
	end,	
}})
-- ~~| Upvalues |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local rotations 			= ADDON.rotations
local abilityLog 			= ADDON.abilityLog
local castLog				= ADDON.CastLog
-- ~~| Locals |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local activeAutoRotation, activeRotation, activeMode
local lastPQR_abilityName, lastRotation, lastMode

local executedAbilities = {}

local manualDelay = 5
local manualTimer = CreateFrame('Frame')
manualTimer:Hide()
manualTimer:SetScript('OnUpdate', function(this,elapsed)
	if this.count < 0 then
		if activeMode == 'manual' then ADDON.Remote:SetStatus('ready')	end
		this:Hide()		
	else		
		this.count = this.count - elapsed			
	end	
end)

-- blizzard has *fucked* some of the ids associated with spells 'CastSpellBy[ID or NAME]'. 
-- use this function on incoming spellID's from PQR_ExecutingAbility to correct
local function checkSpell(spell)	
	if spell == 'Blood Strike' then
		if GetSpecialization() == 1 then
			return 'Heart Strike'
		elseif GetSpecialization() == 2 then
			return 'Frost Strike'
		end		
	end
	return spell
end

-- DT.Explore('castLog',castLog,5)	
-- ~~| PQR Events |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function PQR_BotLoaded()
	ADDON.PQRLoaded = true
	ADDON.Remote:SetStatus('ready')		
end
function PQR_BotUnloaded()	
	ADDON.PQRLoaded = false
	ADDON.Remote:SetStatus('unloaded')		
end
function PQR_Selections(...)		
	local _,rotation,author
	for i=1,5 do		
		_,_,rotation,author = find(select(i,...),"^(.*) %((.-)%)$")				
		rotations[i].rotation 	= rotation
		rotations[i].author 		= author				
	end	
	ADDON.Remote:UpdateTooltip()		
end
function PQR_RotationChanged(rotationName)
	-- only fires when using Auto mode
	activeAutoRotation = rotationName		
	if rotationName then			
		ADDON.Remote:SetStatus("autoRotationStart",{rotationName,'<Nothing to Execute>'})			
	else -- fires when exiting auto mode
		lastRotation = nil				
		ADDON.Remote:SetStatus('ready')				
	end	
end
function PQR_InterruptChanged(interruptName)
	ADDON.Remote:SetInterrupt(interruptName)	
end
function PQR_ExecutingAbility(PQR_abilityName, spellID, rotationNumber)	
	if not PQR_abilityName or not rotationNumber or not spellID then return end
	-- print('PQR_ExecutingAbility',PQR_abilityName, spellID, rotationNumber)	
	-- set Active Rotation / Mode
	manualTimer:Hide()
			
	if rotationNumber == 0 then 		-- auto
		activeMode 		= 'auto'
		activeRotation = activeAutoRotation	
	elseif rotationNumber == 5 then 	-- interrupt
		activeMode 		= 'interrupt'
		activeRotation = rotations[rotationNumber].rotation		
	else										-- manual
		activeMode 		= 'manual'
		activeRotation = rotations[rotationNumber].rotation
		
		manualTimer.count = manualDelay
		manualTimer:Show()
	end	
	-- clear executedAbilities if new mode / rotation
	if lastRotation ~= activeRotation or lastMode ~= activeMode then 
		-- wipe executedAbilities
		for i = 1, #executedAbilities do
			executedAbilities[i] = nil
		end
		-- wipe last executedAbility
		lastPQR_abilityName = nil	
	end	
	
	if next(executedAbilities) and lastPQR_abilityName == PQR_abilityName then	-- increment execute count
		local executedAbility = executedAbilities[#executedAbilities]		 			
		executedAbility.executeCount = executedAbility.executeCount  + 1	
		if ADDON.Remote:GetStatus() == 'ready' then	-- manual mode timeout
			ADDON.Remote:SetStatus('ability',executedAbility )	
		else		
			ADDON.Remote:SetStatus('count',executedAbility.executeCount )	
		end	
	else -- add a new ability					
		local abilityName, author = select(3,find(PQR_abilityName,"^(.*) %((.-)%)$"))
		local executedAbility = {
			PQR_abilityName	= PQR_abilityName,
		 	abilityName			= abilityName,
		 	author				= author,
		 	spellID 				= spellID,
			spell					= checkSpell(GetSpellInfo(spellID)),
			executeCount		= 1,
			start					= GetTime(),
		 	mode					= activeMode,
		 	rotation				= activeRotation,
		}	
		executedAbilities[#executedAbilities + 1] = executedAbility 
		ADDON.Remote:SetStatus('ability',executedAbility)				
	end
	
	lastPQR_abilityName	= PQR_abilityName
	lastRotation			= activeRotation
	lastMode					= activeMode
	
end
function PQR_Text(text,fadeOut,color)	
	
end

function ADDON:UNIT_SPELLCAST_SUCCEEDED(event, unitID, spell, rank, lineID, spellID)		
	if unitID ~="player" then return end
	-- print(event, unitID, spell, rank, lineID, spellID)
	local cast = GetTime()	
	
	ADDON:Debug(2,'----- Begin check -----')	
	for i = 1, #executedAbilities do		
		 ADDON:Debug( 2,'CombatLog:',spell or 'nil', 'PQR_Spell:', executedAbilities[i].spell or 'nil' )
		if executedAbilities[i].spell == spell then -- Log to Spell
			ADDON:Debug(2,'Logged:',spell)						
			for j = 1, i do
				if i == j  then					
					executedAbilities[1].cast = cast
					castLog:LogCast(executedAbilities[1])
				elseif executedAbilities[1].executeCount > 1 then -- dont log overflow					
					castLog:LogCast(executedAbilities[1])
				end 				
				remove(executedAbilities, 1)				
			end				
		return end
	end	
end
function ADDON:CHAT_MSG_ADDON( event, prefix, message, channel, sender)
	
end
ADDON:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED')	
ADDON:RegisterEvent('CHAT_MSG_ADDON')


