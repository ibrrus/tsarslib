
if isClient() then return end

local CommonCommands = {}
local Commands = {}

function Commands.toggleBatteryHeater(playerObj, args)
    -- print("Commands.toggleBatteryHeater")
    local vehicle = playerObj:getVehicle();
    if vehicle then
        local part = vehicle:getPartById("BatteryHeater");
        if not part:getModData().tsarslib then part:getModData().tsarslib = {} end
        if part then
            part:getModData().tsarslib.active = args.on;
            part:getModData().tsarslib.temperature = args.temp;
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
-- sendClientCommand(self.character, 'commonlib', 'usePortableMicrowave', {vehicle = self.vehicle:getId(), oven = self.oven:getId(), on = true, timer = self.oven:getModData().tsarslib.timer, maxTemperature = self.oven:getModData().tsarslib.maxTemperature})
function Commands.usePortableMicrowave(playerObj, args)
    if args.vehicle then
        local vehicle = getVehicleById(args.vehicle)
        local part = vehicle:getPartById(args.oven)
        if not part:getModData().tsarslib then part:getModData().tsarslib = {} end
        part:getModData().tsarslib.maxTemperature = args.maxTemperature
        part:getModData().tsarslib.timer = args.timer
        if part:getItemContainer():isActive() and not args.on then
            part:getItemContainer():setActive(false)
            part:getModData().tsarslib.timer = 0
            part:getModData().tsarslib.timePassed = 0
        elseif part:getModData().tsarslib.timer > 0 and args.on then
            part:getItemContainer():setActive(true)
            part:getModData().tsarslib.timePassed = 0.001
            part:setLightActive(true)
        end
        vehicle:transmitPartModData(part)
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