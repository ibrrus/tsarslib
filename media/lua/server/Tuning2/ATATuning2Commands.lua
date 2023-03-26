if isClient() then return end
require "ATA2TuningTable"

local Commands = {}

-- sendClientCommand(playerObj, 'atatuning2', 'installTuning', {vehicle = vehicle:getId(), part = self.part:getId(),})
function Commands.installTuning(playerObj, args)
    if args.vehicle then
        local vehicle = getVehicleById(args.vehicle)
        local part = vehicle:getPartById(args.partName)
        local item = VehicleUtils.createPartInventoryItem(part);
        if part and item then
            -- part:setInventoryItem(item)
            local vehicleName = vehicle:getScript():getName()
            if ATA2TuningTable[vehicleName]
                    and ATA2TuningTable[vehicleName].parts[args.partName] 
                    and ATA2TuningTable[vehicleName].parts[args.partName][args.modelName] then
                local modelTable = ATA2TuningTable[vehicleName].parts[args.partName][args.modelName]
                if modelTable.containerCapacity then
                    item:setMaxCapacity(modelTable.containerCapacity)
                end
                if modelTable.install.weight then
                    item:setWeight(modelTable.install.weight)
                end
                if args.condition 
                        and modelTable.install.transmitFirstItemCondition 
                        and modelTable.install.use then
                    item:setCondition(args.condition);
                    part:setCondition(args.condition)
                else
                    item:setCondition(100);
                    part:setCondition(100)
                end
            end
            part:setInventoryItem(item)
            part:getModData().tuning2 = {}
            part:getModData().tuning2.model = args.modelName
            vehicle:transmitPartModData(part)
            vehicle:transmitPartItem(part)
            local tbl = part:getTable("install")
            if tbl and tbl.complete then
                VehicleUtils.callLua(tbl.complete, vehicle, part, nil)
            end
        end
    end
end

-- sendClientCommand(playerObj, 'atatuning2', 'uninstallTuning', {vehicle = vehicle:getId(), partName = self.part:getId(),})
function Commands.uninstallTuning(playerObj, args)
    if args.vehicle then
        local vehicle = getVehicleById(args.vehicle)
        if vehicle then
            local vehicleName = vehicle:getScript():getName()
            local part = vehicle:getPartById(args.partName)
            if part then
                local resultTable = {}
                if ATA2TuningTable[vehicleName] and 
                        ATA2TuningTable[vehicleName].parts[args.partName] and 
                        ATA2TuningTable[vehicleName].parts[args.partName][args.modelName].uninstall.result then
                    resultTable = ATA2TuningTable[vehicleName].parts[args.partName][args.modelName].uninstall.result
                end
                if part:getInventoryItem() then
                    part:setInventoryItem(nil)
                    local tbl = part:getTable("uninstall")
                    part:getModData().tuning2 = part:getModData().tuning2 or {}
                    part:getModData().tuning2.model = nil
                    vehicle:transmitPartModData(part)
                    if tbl and tbl.complete then
                        VehicleUtils.callLua(tbl.complete, vehicle, part, nil)
                    end
                    vehicle:transmitPartItem(part)
                    local transmitCondition = ATA2TuningTable[vehicleName].parts[args.partName][args.modelName].uninstall.transmitConditionOnFirstItem
                    for itemType, num in pairs(resultTable) do
                        itemType = itemType:gsub("__", ".")
                        -- transmitCondition означает вернуть один предмет того же состояния, что и деталь
                        if transmitCondition then
                            local item = InventoryItemFactory.CreateItem(itemType);
                            item:setCondition(part:getCondition())
                            playerObj:sendObjectChange("addItem", { item = item })
                            transmitCondition = false
                        else
                            playerObj:sendObjectChange('addItemOfType', { type = itemType, count = num })
                        end
                    end
                end
            end
        end
    end
end

-- sendClientCommand(playerObj, 'atatuning2', 'usePart', {vehicle = vehicle:getId(), partName = self.part:getId(),})
function Commands.usePart(playerObj, args)
    if args.vehicle then
        local vehicle = getVehicleById(args.vehicle)
        if vehicle then
            local vehicleName = vehicle:getScript():getName()
            local part = vehicle:getPartById(args.partName)
            if part then
                VehicleUtils.callLua(part:getLuaFunction("use"), vehicle, part, playerObj)
            end
        end
    end
end

Events.OnClientCommand.Add(function(module, command, playerObj, args)
    --print("Tuning2Commands.OnClientCommand")
    if module == 'atatuning2' and Commands[command] then
        --print("trailer")
        local argStr = ''
        args = args or {}
        for k,v in pairs(args) do
            argStr = argStr..' '..k..'='..tostring(v)
        end
        --noise('received '..module..' '..command..' '..tostring(trailer)..argStr)
        Commands[command](playerObj, args)
    end
end)
