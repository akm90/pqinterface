local AddOnName, Env = ... local ADDON = Env[1] 


local function commandHelp()
	ADDON:Print('-------------- /PQI commands -----------------')	
	ADDON:Print('"/PQI show||hide"')
	ADDON:Print('"/PQI remote width <width>"')
	ADDON:Print('"/PQI config show||hide"')
	ADDON:Print('"/PQI config width <width>"')
	ADDON:Print('"/PQI log show||hide"')
	ADDON:Print('"/PQI log rows <rows>"')	
end
function ADDON:CommandHandler(msg)
	local command, args = msg:match("^([^%s]+)%s*(.*)$")
	if args then
		local s = args
		args = {} 
		for a in s:gmatch("([^%s]+)%s*") do
			args[#args+1] = a		
		end
	end		
	-- dump('arg',args)
	if command =='help' then commandHelp() return end
	if command =='show' then return ADDON:Enable() end
	if command =='hide' then return ADDON:Disable() end
	if command =='remote' then		
		if args and args[1] == 'width' then
			if type(tonumber(args[2]))  == 'number' then	self.interface.db.width = args[2] self.interface:Update() return end						
		end
	end
	if command =='config' then
		if args and args[1] == 'show' then self.rotationConfig.db.show = true self.rotationConfig:Update() return end
		if args and args[1] == 'hide' then self.rotationConfig.db.show = false self.rotationConfig:Update() return end
		if args and args[1] == 'width' then
			if type(tonumber(args[2]))  == 'number' then	self.rotationConfig.db.width = args[2] self.rotationConfig:Update() return end						
		end
	end
	if command =='log' then
		if args and args[1] == 'show' then self.abilityLog.db.show = true self.abilityLog:Update() return end
		if args and args[1] == 'hide' then self.abilityLog.db.show = false self.abilityLog:Update() return end
		if args and args[1] == 'rows' then
			if type(tonumber(args[2]))  == 'number' then	self.abilityLog.db.rows = args[2] self.abilityLog:Update() return end						
		end
	end
	
	-- D.CommandHandler(command, args)
	ADDON:Error('Invalid command "/PQI help" for valid commands') 
end
