
local CommonCommands = {}
local Commands = {}

function Commands.toggleBatteryHeater(playerObj, args)
	-- print("Commands.toggleBatteryHeater")
	local vehicle = playerObj:getVehicle();
	if vehicle then
		local part = vehicle:getPartById("BatteryHeater");
		if part then
			part:getModData().active = args.on;
			part:getModData().temperature = args.temp;
			vehicle:transmitPartModData(part);
		end
	else
		noise('player not in vehicle');
	end
end


CommonCommands.OnClientCommand = function(module, command, playerObj, args)
	--print("CommonCommands.OnClientCommand")
	if module == 'commonlib' and Commands[command] then
		--print("trailer")
		local argStr = ''
		args = args or {}
		for k,v in pairs(args) do
			argStr = argStr..' '..k..'='..tostring(v)
		end
		--noise('received '..module..' '..command..' '..tostring(trailer)..argStr)
		Commands[command](playerObj, args)
	end
end

Events.OnClientCommand.Add(CommonCommands.OnClientCommand)