
if isClient() then return end

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

-- sendClientCommand(playerObj, 'commonlib', 'bulbSmash', {vehicle = vehicle:getId(),})
function Commands.bulbSmash(playerObj, args)
    if args.vehicle then
        local vehicle = getVehicleById(args.vehicle)
        local part = vehicle:getPartById("LightCabin")
        if part and part:getInventoryItem() then
            part:setCondition(0)
            vehicle:transmitPartCondition(part)
        end
    end
end

-- sendClientCommand(playerObj, 'commonlib', 'cabinlightsOn', {vehicle = vehicle:getId(),})
function Commands.cabinlightsOn(playerObj, args)
    if args.vehicle then
        local vehicle = getVehicleById(args.vehicle)
        local part = vehicle:getPartById("LightCabin")
        if part and part:getInventoryItem() then
            local apipart = vehicle:getPartById("HeadlightRearRight")
            local newItem = InventoryItemFactory.CreateItem("Base.LightBulb")
            local partCondition = part:getCondition()
            newItem:setCondition(partCondition)
            apipart:setInventoryItem(newItem, 10) -- transmit
            vehicle:transmitPartItem(apipart)
            partCondition = partCondition - 1
            part:setCondition(partCondition)
            vehicle:transmitPartCondition(part)
        end
    end
end


-- sendClientCommand(self.character, 'commonlib', 'updatePaintVehicle', {vehicle = self.vehicle:getId(),})
function Commands.updatePaintVehicle(playerObj, args)
    if args.vehicle then
        local vehicle = getVehicleById(args.vehicle)
        local part = vehicle:getPartById("TireFrontLeft")
        local invItem = part:getInventoryItem()
        part:setInventoryItem(nil)
        vehicle:transmitPartItem(part)
        part:setInventoryItem(invItem)
        vehicle:transmitPartItem(part)
        part = vehicle:getPartById("TireFrontRight")
        invItem = part:getInventoryItem()
        part:setInventoryItem(nil)
        vehicle:transmitPartItem(part)
        part:setInventoryItem(invItem)
        vehicle:transmitPartItem(part)
        part = vehicle:getPartById("TireRearLeft")
        invItem = part:getInventoryItem()
        part:setInventoryItem(nil)
        vehicle:transmitPartItem(part)
        part:setInventoryItem(invItem)
        vehicle:transmitPartItem(part)
        part = vehicle:getPartById("TireRearRight")
        invItem = part:getInventoryItem()
        part:setInventoryItem(nil)
        vehicle:transmitPartItem(part)
        part:setInventoryItem(invItem)
        vehicle:transmitPartItem(part)
    end
end


-- sendClientCommand(self.character, 'commonlib', 'addVehicle', {trailer=self.trailer:getId(), activate = self.activate})
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