
if isClient() then return end

local CommonCommands = {}
local Commands = {}


function CommonCommands.exchangePartsVehicleToTrailer(veh1, trailer)
    local partsTable = {}
    for i=1, veh1:getScript():getPartCount() do
        local part = veh1:getPartByIndex(i-1)
        partsTable["wrecker_" .. part:getId()] = {}
        partsTable["wrecker_" .. part:getId()]["InventoryItem"] = part:getInventoryItem()
        partsTable["wrecker_" .. part:getId()]["Condition"] = part:getCondition()
        partsTable["wrecker_" .. part:getId()]["modData"] = part:getModData()
        partsTable["wrecker_" .. part:getId()]["ItemContainer"] = part:getItemContainer()
    end
    for i=1, trailer:getScript():getPartCount() do
        local part = trailer:getPartByIndex(i-1)
        if part:getId() == "ATAVehicleWrecker" then
            part:setInventoryItem(InventoryItemFactory.CreateItem(part:getItemType():get(0)))
            part:getModData()["scriptName"] = veh1:getScript():getName()
            part:getModData()["skin"] = veh1:getSkinIndex()
            part:getModData()["rust"] = veh1:getRust()
        elseif partsTable[part:getId()] then
            part:setInventoryItem(partsTable[part:getId()]["InventoryItem"])
            part:setCondition(partsTable[part:getId()]["Condition"])
            if partsTable[part:getId()]["ItemContainer"] then
                part:setItemContainer(partsTable[part:getId()]["ItemContainer"])
            end
            if partsTable[part:getId()]["modData"] then
                for a, b in pairs(partsTable[part:getId()]["modData"]) do 
                    part:getModData()[a] = b
                end
            end
        end
        trailer:transmitPartItem(part)
    end
    -- print("veh1 keyId: ", veh1:getKeyId())
    -- print("veh2 keyId: ", veh2:getKeyId())
    trailer:setRust(veh1:getRust())
    trailer:setKeyId(veh1:getKeyId())
    -- print("veh2 new keyId: ", veh2:getKeyId())
    return trailer
end

function CommonCommands.exchangePartsTrailerToVehicle(trailer, veh1)
    local partsTable = {}
    for i=1, trailer:getScript():getPartCount() do
        local part = trailer:getPartByIndex(i-1)
        local partNameTrim = string.sub(part:getId(), 9)
        if partNameTrim ~= "" then
            partsTable[partNameTrim] = {}
            partsTable[partNameTrim]["InventoryItem"] = part:getInventoryItem()
            partsTable[partNameTrim]["Condition"] = part:getCondition()
            partsTable[partNameTrim]["modData"] = part:getModData()
            partsTable[partNameTrim]["ItemContainer"] = part:getItemContainer()
        end
    end
    for i=1, veh1:getScript():getPartCount() do
        local part = veh1:getPartByIndex(i-1)
        if partsTable[part:getId()] then
            part:setInventoryItem(partsTable[part:getId()]["InventoryItem"])
            part:setCondition(partsTable[part:getId()]["Condition"])
            if partsTable[part:getId()]["ItemContainer"] then
                part:setItemContainer(partsTable[part:getId()]["ItemContainer"])
            end
            if partsTable[part:getId()]["modData"] then
                for a, b in pairs(partsTable[part:getId()]["modData"]) do 
                    part:getModData()[a] = b
                end
            end
            veh1:transmitPartItem(part)
        end
    end
    -- print("veh1 keyId: ", veh1:getKeyId())
    -- print("veh2 keyId: ", veh2:getKeyId())
    veh1:setRust(trailer:getRust())
    veh1:setKeyId(trailer:getKeyId())
    -- print("veh2 new keyId: ", veh2:getKeyId())
    return veh1
end



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

-- sendClientCommand(playerObj, 'commonlib', 'installTuning', {vehicle = vehicle:getId(), part = self.part:getId(),})
function Commands.installTuning(playerObj, args)
    if args.vehicle then
        local vehicle = getVehicleById(args.vehicle)
        local part = vehicle:getPartById(args.part)
        local item = InventoryItemFactory.CreateItem("Base.LightBulb")
        if part then
            part:setInventoryItem(item)
            part:getModData().tuning2 = {}
            part:getModData().tuning2.model = args.model
            vehicle:transmitPartModData(part)
            local tbl = part:getTable("install")
			if tbl and tbl.complete then
				VehicleUtils.callLua(tbl.complete, vehicle, part, nil)
			end
            vehicle:transmitPartItem(part)
        end
    end
end

-- sendClientCommand(playerObj, 'commonlib', 'uninstallTuning', {vehicle = vehicle:getId(), part = self.part:getId(),})
function Commands.uninstallTuning(playerObj, args)
    if args.vehicle then
        local vehicle = getVehicleById(args.vehicle)
        local part = vehicle:getPartById(args.part)
        if part and part:getInventoryItem() then
            part:setInventoryItem(nil)
            local tbl = part:getTable("uninstall")
            part:getModData().tuning2 = {}
            vehicle:transmitPartModData(part)
			if tbl and tbl.complete then
				VehicleUtils.callLua(tbl.complete, vehicle, part, nil)
			end
            vehicle:transmitPartItem(part)
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

-- sendClientCommand(self.character, 'commonlib', 'loadVehicle', {trailer = self.trailer:getId(), vehicle = self.vehicle:getId()})
function Commands.loadVehicle(playerObj, args)
    -- print("Commands.loadVehicle")
    if args.trailer and args.vehicle then
        local trailer = getVehicleById(args.trailer)
        local vehicle = getVehicleById(args.vehicle)
        -- local newTrailerName = AquaConfig.Trailers[trailer:getScript():getName()].trailerWithBoatTable[vehicle:getScript():getName()]
        -- if isServer() then
        -- trailer = TCLConfig.replaceVehicle(trailer, newTrailerName, vehicle:getSkinIndex())
        -- else
            -- AquaConfig.replaceVehicleScript(trailer, newTrailerName)
        -- end
        CommonCommands.exchangePartsVehicleToTrailer(vehicle, trailer)
        vehicle:permanentlyRemove()
    end
end

function Commands.launchVehicle(playerObj, args)
    if args.trailer then
        local trailer = getVehicleById(args.trailer)
        local wreckerPart = trailer:getPartById("ATAVehicleWrecker")
        if wreckerPart then
            local scriptName = wreckerPart:getModData()["scriptName"]
            local square = getSquare(args.x, args.y, 0)
            if square then
                local vehicle = addVehicleDebug(scriptName, IsoDirections.N, trailer:getSkinIndex(), square)
                vehicle:setAngles(trailer:getAngleX(), trailer:getAngleY(), trailer:getAngleZ())
                vehicle:setSkinIndex(wreckerPart:getModData()["skin"])
                CommonCommands.exchangePartsTrailerToVehicle(trailer, vehicle)
                wreckerPart:setInventoryItem(nil)
                trailer:transmitPartItem(wreckerPart)

                -- Delete key
                local xx = vehicle:getX()
                local yy = vehicle:getY()

                for z=0, 3 do
                    for i=xx - 15, xx + 15 do
                        for j=yy - 15, yy + 15 do
                            local tmpSq = getCell():getGridSquare(i, j, z)
                            if tmpSq ~= nil then
                                for k=0, tmpSq:getObjects():size()-1 do
                                    local ttt =    tmpSq:getObjects():get(k)
                                    if ttt:getContainer() ~= nil then
                                        local items = ttt:getContainer():getItems()
                                        for ii=0, items:size()-1 do
                                            if items:get(ii):getKeyId() == vehicle:getKeyId() then
                                                items:remove(ii)
                                            end
                                        end
                                    elseif instanceof(ttt, "IsoWorldInventoryObject") then
                                        if ttt:getItem() and ttt:getItem():getContainer() then
                                            local items = ttt:getItem():getContainer():getItems()
                                            for ii=0, items:size()-1 do
                                                if items:get(ii):getKeyId() == vehicle:getKeyId() then
                                                    items:remove(ii)
                                                end
                                            end
                                        end
                                        
                                        if ttt:getItem() and ttt:getItem():getKeyId() == vehicle:getKeyId() then
                                            tmpSq:removeWorldObject(ttt)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
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
