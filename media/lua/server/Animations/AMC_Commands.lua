-- if not isServer() then return end

local CommonCommands = {}
local Commands = {}

-- sendClientCommand(playerObj, 'autotsaranim', 'updateVariables', {vehicle = vehicle:getId(), seatId = vehicle:getSeat(playerObj), status = "forward",})
function Commands.updateVariables(playerObj, args)
    local vehicle = getVehicleById(args.vehicle)
    if vehicle then
        local seatPart = vehicle:getPartForSeatContainer(args.seatId);
        if seatPart then
            -- if args.status == "clear" then
                -- seatPart:getModData()["tsaranimation"] = nil
            -- else
                seatPart:getModData()["tsaranimation"] = args.status
            -- end
            vehicle:transmitPartModData(seatPart)
        end
    end
end

CommonCommands.OnClientCommand = function(module, command, playerObj, args)
	--print("CommonCommands.OnClientCommand")
	if module == 'autotsaranim' and Commands[command] then
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