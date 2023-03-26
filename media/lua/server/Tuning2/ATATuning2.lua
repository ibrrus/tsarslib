-- print("Autotsar tunning load start")

require "ATA2TuningTable"

if not ATATuning2 then ATATuning2 = {} end
if not ATATuning2Utils then ATATuning2Utils = {} end
if not ATATuning2.CheckEngine then ATATuning2.CheckEngine = {} end
if not ATATuning2.CheckOperate then ATATuning2.CheckOperate = {} end
if not ATATuning2.ContainerAccess then ATATuning2.ContainerAccess = {} end
if not ATATuning2.Create then ATATuning2.Create = {} end
if not ATATuning2.Init then ATATuning2.Init = {} end
if not ATATuning2.InstallComplete then ATATuning2.InstallComplete = {} end
if not ATATuning2.InstallTest then ATATuning2.InstallTest = {} end
if not ATATuning2.UninstallComplete then ATATuning2.UninstallComplete = {} end
if not ATATuning2.UninstallTest then ATATuning2.UninstallTest = {} end
if not ATATuning2.Update then ATATuning2.Update = {} end
if not ATATuning2.Use then ATATuning2.Use = {} end

function ATATuning2.ContainerAccess.BlockSeat(vehicle, part, playerObj)
    return false
end


function ATATuning2.Create.Chance0(vehicle, part)
    part:setInventoryItem(nil) -- + vehicle:transmitPartItem(part)
    vehicle:transmitPartItem(part)
    vehicle:doDamageOverlay()
end

function ATATuning2.Create.Chance5(vehicle, part)
    if ZombRand(100) <= 5 then
        ATATuning2.Create.Tuning(vehicle, part)
    else
        ATATuning2.Create.Chance0(vehicle, part)
    end
end

function ATATuning2.Create.Chance15(vehicle, part)
    if ZombRand(100) <= 15 then
        ATATuning2.Create.Tuning(vehicle, part)
    else
        ATATuning2.Create.Chance0(vehicle, part)
    end
end

function ATATuning2.Create.Chance30(vehicle, part)
    if ZombRand(100) <= 30 then
        ATATuning2.Create.Tuning(vehicle, part)
    else
        ATATuning2.Create.Chance0(vehicle, part)
    end
end

function ATATuning2.Create.Chance45(vehicle, part)
    if ZombRand(100) <= 45 then
        ATATuning2.Create.Tuning(vehicle, part)
    else
        ATATuning2.Create.Chance0(vehicle, part)
    end
end

--***********************************************************
--**                                                       **
--**                        Lights                             **
--**                                                       **
--***********************************************************

function ATATuning2.Create.ATALight(vehicle, part)
    -- local item = VehicleUtils.createPartInventoryItem(part)
    -- xOffset,yOffset,distance,intensity,dot,focusing
    -- NOTE: distance,intensity,focusing values are ignored, instead they are
    -- set based on part condition.
    ATATuning2.Create.Chance0(vehicle, part)
    if part:getId() == "ATARoofLampLeft" then
        part:createSpotLight(4.5, -1, 0.1, 0.1, 1.4, 200) -- (2, -0.8, 0.1, 0.1, 2, 200)
    elseif part:getId() == "ATARoofLampRight" then
        part:createSpotLight(-4.5, -1, 0.1, 0.1, 1.4, 200)
    elseif part:getId() == "ATARoofLampRear" then
        part:createSpotLight(0, -4.5, 0.1, 0.1, 1.35, 100)    
    elseif part:getId() == "ATARoofLampFront" then
        part:createSpotLight(0, 2.0, 8.0+ZombRand(16.0), 0.75, 0.96, ZombRand(200))
    end
end

--***********************************************************
--**                                                       **
--**                        Fake Wheels                     **
--**                                                       **
--***********************************************************

function ATATuning2.InstallComplete.ATAMotoTireFrontWheel(vehicle, part)
    VehicleUtils.createPartInventoryItem(vehicle:getPartById("TireFrontLeft"))
    vehicle:getPartById("TireFrontLeft"):setCondition(part:getCondition());
    vehicle:transmitPartItem(vehicle:getPartById("TireFrontLeft"))
    VehicleUtils.createPartInventoryItem(vehicle:getPartById("TireFrontRight"))
    vehicle:getPartById("TireFrontRight"):setCondition(part:getCondition());
    vehicle:transmitPartItem(vehicle:getPartById("TireFrontRight"))
    Vehicles.InstallComplete.Tire(vehicle, vehicle:getPartById("TireFrontLeft"))
    Vehicles.InstallComplete.Tire(vehicle, vehicle:getPartById("TireFrontRight"))
    if vehicle:getPartById("ATAMotoTireRearWheel") and vehicle:getPartById("ATAMotoTireRearWheel"):getInventoryItem() then
        VehicleUtils.createPartInventoryItem(vehicle:getPartById("TireRearRight"))
        vehicle:getPartById("TireRearRight"):setCondition(part:getCondition());
        Vehicles.InstallComplete.Tire(vehicle, vehicle:getPartById("TireRearRight"))
        vehicle:transmitPartItem(vehicle:getPartById("TireRearRight"))
    end
end

function ATATuning2.UninstallComplete.ATAMotoTireFrontWheel(vehicle, part, item)
    vehicle:getPartById("TireFrontLeft"):setInventoryItem(nil) -- + vehicle:transmitPartItem(part)
    vehicle:getPartById("TireFrontRight"):setInventoryItem(nil) -- + vehicle:transmitPartItem(part)
    vehicle:transmitPartItem(vehicle:getPartById("TireFrontLeft"))
    vehicle:transmitPartItem(vehicle:getPartById("TireFrontRight"))
    Vehicles.UninstallComplete.Tire(vehicle, vehicle:getPartById("TireFrontLeft"))
    Vehicles.UninstallComplete.Tire(vehicle, vehicle:getPartById("TireFrontRight"))
    vehicle:getPartById("TireRearRight"):setInventoryItem(nil)  -- + vehicle:transmitPartItem(part)
    vehicle:transmitPartItem(vehicle:getPartById("TireRearRight"))
    Vehicles.UninstallComplete.Tire(vehicle, vehicle:getPartById("TireRearRight"))
end

function ATATuning2.Update.ATAMotoTireFrontWheel(vehicle, part, elapsedMinutes)
    Vehicles.Update.Tire(vehicle, part, elapsedMinutes)
    local wPart1 = vehicle:getPartById("TireFrontLeft")
    local wPart2 = vehicle:getPartById("TireFrontRight")
    local wPart3 = vehicle:getPartById("TireRearRight")
    if part:getInventoryItem() then
        if wPart1:getInventoryItem() then
            if wPart1:getContainerContentAmount() ~= part:getContainerContentAmount() then
                wPart1:setContainerContentAmount(part:getContainerContentAmount())
                local wheelIndex = wPart1:getWheelIndex()
                -- TODO: sync inflation
                vehicle:setTireInflation(wheelIndex, wPart1:getContainerContentAmount() / wPart1:getContainerCapacity())
                vehicle:transmitPartModData(part)
            end
            if wPart1:getCondition() ~= part:getCondition() then
                wPart1:setCondition(part:getCondition())
            end
        end
        if wPart2:getInventoryItem() then
            if wPart2:getContainerContentAmount() ~= part:getContainerContentAmount() then
                wPart2:setContainerContentAmount(part:getContainerContentAmount())
                local wheelIndex = wPart2:getWheelIndex()
                -- TODO: sync inflation
                vehicle:setTireInflation(wheelIndex, wPart2:getContainerContentAmount() / wPart2:getContainerCapacity())
                vehicle:transmitPartModData(part)
            end
            if wPart2:getCondition() ~= part:getCondition() then
                wPart2:setCondition(part:getCondition())
            end
        end
        vehicle:transmitPartCondition(wPart1)
        vehicle:transmitPartCondition(wPart2)
    else
        if wPart1:getInventoryItem() then
            VehicleUtils.RemoveTire(wPart1, false);
        end
        if wPart2:getInventoryItem() then
            VehicleUtils.RemoveTire(wPart2, false);
        end
        if wPart3:getInventoryItem() then
            VehicleUtils.RemoveTire(wPart3, false);
        end
    end
end

function ATATuning2.InstallComplete.ATAMotoTireRearWheel(vehicle, part)
    VehicleUtils.createPartInventoryItem(vehicle:getPartById("TireRearLeft"))
    vehicle:getPartById("TireRearLeft"):setCondition(part:getCondition());
    Vehicles.InstallComplete.Tire(vehicle, vehicle:getPartById("TireRearLeft"))
    vehicle:transmitPartItem(vehicle:getPartById("TireRearLeft"))
    if vehicle:getPartById("ATAMotoTireFrontWheel") and vehicle:getPartById("ATAMotoTireFrontWheel"):getInventoryItem() then
        VehicleUtils.createPartInventoryItem(vehicle:getPartById("TireRearRight"))
        vehicle:getPartById("TireRearRight"):setCondition(part:getCondition());
        Vehicles.InstallComplete.Tire(vehicle, vehicle:getPartById("TireRearRight"))
        vehicle:transmitPartItem(vehicle:getPartById("TireRearRight"))
    end
end

function ATATuning2.UninstallComplete.ATAMotoTireRearWheel(vehicle, part, item)
    vehicle:getPartById("TireRearLeft"):setInventoryItem(nil) -- + vehicle:transmitPartItem(part)
    vehicle:transmitPartItem(vehicle:getPartById("TireRearLeft")) 
    Vehicles.UninstallComplete.Tire(vehicle, vehicle:getPartById("TireRearLeft"))
    vehicle:getPartById("TireRearRight"):setInventoryItem(nil) -- + vehicle:transmitPartItem(part)
    vehicle:transmitPartItem(vehicle:getPartById("TireRearRight"))
    Vehicles.UninstallComplete.Tire(vehicle, vehicle:getPartById("TireRearRight"))
end

function ATATuning2.Update.ATAMotoTireRearWheel(vehicle, part, elapsedMinutes)
    Vehicles.Update.Tire(vehicle, part, elapsedMinutes)
    local wPart1 = vehicle:getPartById("TireRearLeft")
    local wPart2 = vehicle:getPartById("TireRearRight")
    if part:getInventoryItem() then
        if wPart1:getInventoryItem() then
            if wPart1:getContainerContentAmount() ~= part:getContainerContentAmount() then
                wPart1:setContainerContentAmount(part:getContainerContentAmount())
                local wheelIndex = wPart1:getWheelIndex()
                -- TODO: sync inflation
                vehicle:setTireInflation(wheelIndex, wPart1:getContainerContentAmount() / wPart1:getContainerCapacity())
                vehicle:transmitPartModData(part)
            end
            if wPart1:getCondition() ~= part:getCondition() then
                wPart1:setCondition(part:getCondition())
            end
        end
        if wPart2:getInventoryItem() then
            if wPart2:getContainerContentAmount() ~= part:getContainerContentAmount() then
                wPart2:setContainerContentAmount(part:getContainerContentAmount())
                local wheelIndex = wPart2:getWheelIndex()
                -- TODO: sync inflation
                vehicle:setTireInflation(wheelIndex, wPart2:getContainerContentAmount() / wPart2:getContainerCapacity())
                vehicle:transmitPartModData(part)
            end
            if wPart2:getCondition() ~= part:getCondition() then
                wPart2:setCondition(part:getCondition())
            end
        end
        vehicle:transmitPartCondition(wPart1)
        vehicle:transmitPartCondition(wPart2)
    else
        if wPart1:getInventoryItem() then
            VehicleUtils.RemoveTire(wPart1, false);
        end
        if wPart2:getInventoryItem() then
            VehicleUtils.RemoveTire(wPart2, false);
        end
    end
end

function ATATuning2.Use.Door(vehicle, part, character)
    for seat=0,vehicle:getMaxPassengers()-1 do
        if vehicle:getPassengerDoor(seat) == part then
            if not vehicle:getCharacter(seat) then
                ISVehicleMenu.onEnter(character, vehicle, seat)
                break
            end
        end
        if vehicle:getPassengerDoor2(seat) == part then
            if not vehicle:getCharacter(seat) then
                ISVehicleMenu.onEnter(character, vehicle, seat)
                break
            end
        end
    end
end

function ATATuning2.ContainerAccess.MotoBags(vehicle, part, chr)
    if chr:getVehicle() == vehicle then return true end
    if not vehicle:isInArea(part:getArea(), chr) then return false end
    return true
end

--***********************************************************
--**                                                       **
--**                       Tuning                          **
--**                                                       **
--***********************************************************


function ATATuning2Utils.createPartInventoryItem(part)
    if part:getTable("ATA2ItemSpawnChance") then
        if not part:getItemType() or part:getItemType():isEmpty() then return nil end
        local item;
        if not part:getInventoryItem() then
            if #part:getTable("ATA2ItemSpawnChance") == part:getItemType():size() then
                local v = part:getVehicle();
                local itemType = nil
                local previousChance = 0
                local newChanceTable = {}
                for id, chance in pairs(part:getTable("ATA2ItemSpawnChance")) do
                    if tonumber(chance) > 0 then
                        newChanceTable[id] = previousChance + chance
                        previousChance = newChanceTable[id]
                    end
                end
                if previousChance > 0 then
                    local luck = ZombRand(previousChance)
                    for id, checkLuck in pairs(newChanceTable) do
                        if luck <= checkLuck then
                            itemType = part:getItemType():get(id - 1);
                            break
                        end
                    end
                    
                    item = InventoryItemFactory.CreateItem(itemType);
                    local conditionMultiply = 100/item:getConditionMax();
                    if part:getContainerCapacity() and part:getContainerCapacity() > 0 then
                        item:setMaxCapacity(part:getContainerCapacity());
                    end
                    item:setConditionMax(item:getConditionMax()*conditionMultiply); 
                    item:setCondition(item:getCondition()*conditionMultiply); -- no need transmit
                    part:setRandomCondition(item);
                    part:setInventoryItem(item)
                end
            else
                print("ATA ERROR: For part " .. part:getId() .. "the spawn table 'ATA2ItemSpawnChance' is set incorrectly. The number of elements in the table (now " .. #part:getTable("ATA2ItemSpawnChance") .. ") must equal the number of possible items (now " .. part:getItemType():size() .. ").")
                part:throwError()
            end
        end
        return part:getInventoryItem()
    else
        return VehicleUtils.createPartInventoryItem(part)
    end
end

function ATATuning2Utils.ModelByItemName(vehicle, part, item)
-- print("ATATuning2Utils.ModelByItemName")
    if not part:getItemType() or part:getItemType():isEmpty() then return end
    if part:getTable("ATA2ItemToModel") then
        part:setAllModelsVisible(false)
        if item then
            local t = part:getTable("ATA2ItemToModel")
            if t[item:getType()] then
                part:setModelVisible(t[item:getType()], true)
            else
                part:setModelVisible(t["Another"], true)
            end
        end
    end
end

function ATATuning2Utils.ModelByModData(vehicle, part, item)
    -- print("ATATuning2Utils.ModelByModData")
    part:setAllModelsVisible(false)
    local vehicleName = vehicle:getScript():getName()
    local partName = part:getId()
    if not part:getItemType() or part:getItemType():isEmpty() then
        print("ATATuning2Utils.ModelByModData ERROR: не предусмотренное использование функции")
        part:setModelVisible("Default", true)
        part:setModelVisible("StaticPart", true)
    else
        if part:getModData().tuning2 then
            if part:getModData().tuning2.model then
                local modelName = part:getModData().tuning2.model
                if item then
                    part:setModelVisible(modelName, true)
                    if ATA2TuningTable[vehicleName] 
                            and ATA2TuningTable[vehicleName].parts[partName] 
                            and ATA2TuningTable[vehicleName].parts[partName][modelName] then 
                        local modelInfo = ATA2TuningTable[vehicleName].parts[partName][modelName]
                        
                        -- активируем вторую модель (пример использования - анимированная защита для окон)
                        if modelInfo.secondModel then
                            part:setModelVisible(modelInfo.secondModel, true)
                        end
                        
                        -- активируем модели на всех защищаемых предметах (пример использования - цепи на колеса)
                        if modelInfo.protectionModel and type(modelInfo.protection) == "table" then
                            part:getModData().tuning2.setModelForAnotherPart = {}
                            for _, protectionPart in ipairs(modelInfo.protection) do
                                if vehicle:getPartById(protectionPart) then
                                    vehicle:getPartById(protectionPart):setModelVisible(modelName, true)
                                    part:getModData().tuning2.setModelForAnotherPart[protectionPart] = modelName
                                    vehicle:transmitPartModData(part)
                                end
                            end
                        end
                        
                        -- интерактивный багажник
                        if modelInfo.interactiveTrunk and part:getItemContainer() then
                            local fillingRate = part:getItemContainer():getContentsWeight() / part:getItemContainer():getCapacity()
                            if fillingRate > 0 then
                                if modelInfo.interactiveTrunk.filling then
                                    local tableSize = #modelInfo.interactiveTrunk.filling
                                    for num, itemTrunkModel in ipairs(modelInfo.interactiveTrunk.filling) do
                                        if num <= math.floor(fillingRate * tableSize + 1) then
                                            part:setModelVisible(itemTrunkModel, true)
                                        else
                                            break;
                                        end
                                    end
                                elseif modelInfo.interactiveTrunk.fillingOnlyOne then
                                    local tableSize = #modelInfo.interactiveTrunk.fillingOnlyOne
                                    for num, itemTrunkModel in ipairs(modelInfo.interactiveTrunk.fillingOnlyOne) do
                                        if num == math.floor(fillingRate * tableSize + 1) then
                                            part:setModelVisible(itemTrunkModel, true)
                                        end
                                    end
                                end
                                if modelInfo.interactiveTrunk.items then
                                    for _, itemInfoTable in pairs(modelInfo.interactiveTrunk.items) do
                                        local itemcount = 0
                                        local maxItemCount = #itemInfoTable.modelNameByCount
                                        for _,itemNameNew in ipairs(itemInfoTable.itemTypes) do
                                            if itemcount < maxItemCount then
                                                itemcount = itemcount + part:getItemContainer():getCountType(itemNameNew)
                                            else
                                                break
                                            end
                                        end
                                        if itemcount > 0 then
                                            for num=1,itemcount do
                                                if num <= maxItemCount then
                                                    part:setModelVisible(itemInfoTable.modelNameByCount[num], true)
                                                else
                                                    break;
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            elseif part:getModData().tuning2.setModelForAnotherPart then
                -- отключаем модели с защищаемых деталей (параметр "protectionModel")
                for partName, modelName in pairs(part:getModData().tuning2.setModelForAnotherPart) do
                    if vehicle:getPartById(partName) then
                        vehicle:getPartById(partName):setModelVisible(modelName, false)
                    end
                end
                part:getModData().tuning2.setModelForAnotherPart = nil
                vehicle:transmitPartModData(part)
            end
        end
    end
    vehicle:doDamageOverlay()
end

function ATATuning2.Create.Tuning(vehicle, part)
    local vehicleName = vehicle:getScript():getName()
    local partName = part:getId()
    local item = nil
    part:getModData().tuning2 = {}
    if ATA2TuningTable[vehicleName] 
            and ATA2TuningTable[vehicleName].parts[partName] then
        -- обходим таблицу доступных моделей и проверяем их шанс спавна
        for modelName, tableInfo in pairs(ATA2TuningTable[vehicleName].parts[partName]) do
            if tableInfo.spawnChance and tableInfo.spawnChance > ZombRand(100) then
                item = ATATuning2Utils.createPartInventoryItem(part)
                part:getModData().tuning2.model = modelName
                break;
            end
        end
    end
    vehicle:transmitPartModData(part)
    ATATuning2Utils.ModelByModData(vehicle, part, item)
end

function ATATuning2.Init.Tuning(vehicle, part)
    ATATuning2Utils.ModelByModData(vehicle, part, part:getInventoryItem())
    if part:isContainer() then
        part:setContainerContentAmount(part:getItemContainer():getCapacityWeight());
    end
end

function ATATuning2.InstallTest.Tuning(vehicle, part, chr)
    -- print("ATATuning2.InstallTest.tuning")
    local vehicleName = vehicle:getScript():getName()
    local partName = part:getId()
    local modelName = chr:getModData().tryInstallTuning2Model

    if part:getInventoryItem() then 
        if not (ATA2TuningTable[vehicleName] -- проверка для requireModel
                and ATA2TuningTable[vehicleName].parts[partName] 
                and ATA2TuningTable[vehicleName].parts[partName][modelName] 
                and ATA2TuningTable[vehicleName].parts[partName][modelName].install.requireModel) then
            return false 
        end
    end
    if not part:getItemType() or part:getItemType():isEmpty() then return false end
    return true
end

-- функция обязательна для всех запчастей из Tuning2
function ATATuning2.InstallComplete.Tuning(vehicle, part)
-- print("ATATuning2.InstallComplete.Tuning")
    local item = part:getInventoryItem();
    if not item then return; end
    ATATuning2Utils.ModelByModData(vehicle, part, item)
    local vehicleName = vehicle:getScript():getName()
    local partName = part:getId()
    if part:getModData().tuning2 and part:getModData().tuning2.model then
        local modelName = part:getModData().tuning2.model
        if ATA2TuningTable[vehicleName] 
                and ATA2TuningTable[vehicleName].parts[partName] 
                and ATA2TuningTable[vehicleName].parts[partName][modelName] then 
            local modelInfo = ATA2TuningTable[vehicleName].parts[partName][modelName]
            
            -- отключение функции открытия окна
            if modelInfo.disableOpenWindowFromSeat then
                local seatPart = vehicle:getPartById(modelInfo.disableOpenWindowFromSeat)
                if seatPart then
                    seatPart:getModData().t2disableOpenWindow = true
                    vehicle:transmitPartModData(seatPart)
                end
                part:getModData().tuning2.disableOpenWindowFromSeat = modelInfo.disableOpenWindowFromSeat
                -- закрытие окна
                local windowPart = vehicle:getPartById("Window" .. string.sub(modelInfo.disableOpenWindowFromSeat, 5))
                if windowPart and windowPart:getWindow() then
                    windowPart:getWindow():setOpen(false)
                    vehicle:transmitPartWindow(windowPart)
                end
            end
            
            -- активация защиты (сохранение состояний предметов)
            if modelInfo.protection then
                part:getModData().tuning2.protection = modelInfo.protection
                for _, protectionPartName in ipairs(modelInfo.protection) do
                    if protectionPartName ~= "Engine" then -- защита кода от "защиты двигателя"
                        local savePart = vehicle:getPartById(protectionPartName)
                        if savePart then
                            if not savePart:getModData().tuning2 then
                                savePart:getModData().tuning2 = {}
                            end
                            
                            -- добавление запрета на снятие предмета, до снятия защиты
                            if not savePart:getModData().tuning2.protectionRequireUninstalled then
                                local t = {}
                                t[partName] = true
                                savePart:getModData().tuning2.protectionRequireUninstalled = t
                            else
                                local t = savePart:getModData().tuning2.protectionRequireUninstalled
                                t[partName] = true
                            end
                            
                            vehicle:transmitPartModData(savePart)
                            if savePart:getInventoryItem() then
                                savePart:getModData().tuning2.health = savePart:getCondition()
                                savePart:setCondition(100) -- transmit
                                vehicle:transmitPartCondition(savePart)
                            end
                        end
                    end
                end
            end
            -- активация защиты (сохранение состояний предметов)
            if modelInfo.removeIfBroken then
                part:getModData().tuning2.removeIfBroken = modelInfo.removeIfBroken
            end
            
        end
    end
    if part:isContainer() then
        part:setContainerContentAmount(part:getItemContainer():getCapacityWeight());
    end
    vehicle:transmitPartModData(part)
    vehicle:doDamageOverlay()
end

-- ничего лишнего, все проверки проводятся в интерфейсе тюнинга
function ATATuning2.UninstallTest.Tuning(vehicle, part, chr)
    -- print("ATATuning2.UninstallTest.Tuning")
    if ISVehicleMechanics.cheat then return true; end
    if not part:getInventoryItem() then return false end
    if not part:getItemType() or part:getItemType():isEmpty() then return false end
    return true
end

-- функция обязательна для всех запчастей из Tuning2
-- в ней мы больше не можем обращаться к ATA2TuningTable, т.к. Имя_модели == nil
function ATATuning2.UninstallComplete.Tuning(vehicle, part, item)
-- print("ATATuning2.UninstallComplete.Tuning")
    ATATuning2Utils.ModelByModData(vehicle, part)
    local vehicleName = vehicle:getScript():getName()
    local partName = part:getId()
    if part:getModData().tuning2 then
        -- восстановление функции открытия окна
        if part:getModData().tuning2.disableOpenWindowFromSeat then
            local seatPart = vehicle:getPartById(part:getModData().tuning2.disableOpenWindowFromSeat)
            if seatPart then
                seatPart:getModData().t2disableOpenWindow = nil
                vehicle:transmitPartModData(seatPart)
            end
            part:getModData().tuning2.disableOpenWindowFromSeat = nil
        end
        -- отключение защиты
        if part:getModData().tuning2.protection then
            for _, protectionPartName in ipairs(part:getModData().tuning2.protection) do
                if protectionPartName ~= "Engine" then -- защита кода от "защиты двигателя"
                    local savePart = vehicle:getPartById(protectionPartName)
                    if savePart then
                        if savePart:getModData().tuning2 and savePart:getModData().tuning2.health then 
                            savePart:setCondition(savePart:getModData().tuning2.health) -- transmit
                            vehicle:transmitPartCondition(savePart)
                            
                            savePart:getModData().tuning2.health = nil -- transmit
                            -- снятие запрета на деинсталляцию предмета
                            if savePart:getModData().tuning2.protectionRequireUninstalled then
                                local t = savePart:getModData().tuning2.protectionRequireUninstalled
                                t[partName] = nil
                            end
                            vehicle:transmitPartModData(savePart)
                        end
                    end
                end
            end
        end
    end
    if part:isContainer() then
        part:setContainerContentAmount(part:getItemContainer():getCapacityWeight());
    end
    vehicle:transmitPartModData(part)
    vehicle:doDamageOverlay()
end

function ATATuning2.ContainerAccess.Tuning(vehicle, part, chr)
    ATATuning2Utils.ModelByModData(vehicle, part, part:getInventoryItem(), "ContainerAccess")
    if chr:getVehicle() then return false end
    if not vehicle:isInArea(part:getArea(), chr) then return false end
    return true
end

function ATATuning2.Update.Protection(vehicle, part, elapsedMinutes)
    -- print("ATATuning2.Update.Protection")
    local item = part:getInventoryItem();
    if not item then return; end

    local areaCenter = vehicle:getAreaCenter(part:getArea()) -- зона для выбрасывания поврежденных деталей
    local vehicleName = vehicle:getScript():getName()
    local partName = part:getId()
    if part:getModData().tuning2 and part:getModData().tuning2.model then
        if part:getModData().tuning2.removeIfBroken and not part:getItemContainer() and areaCenter and part:getCondition() == 0 then
            local square = getCell():getGridSquare(areaCenter:getX(), areaCenter:getY(), vehicle:getZ())
            
            part:setInventoryItem(nil)-- + vehicle:transmitPartItem(part)
            vehicle:transmitPartItem(part)
            
            square:AddWorldInventoryItem(item, 0.5, 0.5, 0)
            ATATuning2.UninstallComplete.Tuning(vehicle, part, item)
        -- отработка защиты
        elseif part:getModData().tuning2.protection then
            for _, protectionPartName in ipairs(part:getModData().tuning2.protection) do
                if protectionPartName ~= "Engine" then -- защита кода от "защиты двигателя"
                    local savePart = vehicle:getPartById(protectionPartName)
                    if savePart and savePart:getInventoryItem() then
                        if not savePart:getModData().tuning2 then
                            savePart:getModData().tuning2 = {}
                            vehicle:transmitPartModData(savePart)
                        end
                        if not savePart:getModData().tuning2.health then
                            savePart:getModData().tuning2.health = savePart:getCondition()
                            vehicle:transmitPartModData(savePart)
                        end
                        
                        if (savePart:getCondition() < 80) then
                            part:setCondition(part:getCondition()-1) -- transmit
                            vehicle:transmitPartCondition(part)
                            
                            savePart:setCondition(100) -- transmit
                            vehicle:transmitPartCondition(savePart)
                        end
                        if string.match(savePart:getId(), "Tire") and savePart:getContainerContentAmount() < 10 then
                            savePart:setContainerContentAmount(20, false, true);
                        end
                    end
                end
            end
        end
    end
end


--***********************************************************
--**                                                       **
--**                     Common Protection                     **
--**                                                       **
--***********************************************************

function ATATuning2.UninstallComplete.Window(vehicle, part, item)
    Vehicles.UninstallComplete.Default(vehicle, part, item)
    if not part:getModData().atatuning or not part:getModData().atatuning.health then return end
    item:setCondition(part:getModData().atatuning.health) -- no need transmit
    part:getModData().atatuning.health = nil
    vehicle:transmitPartModData(part)
end

--***********************************************************
--**                                                       **
--**                         Wheels                           **
--**                                                       **
--***********************************************************

-- Функции для шин у которых установлен параметр "setAllModelsVisible = false," 
-- В общем случае, в скрипт нужно добавить:
    -- part Tire*
    -- {
        -- setAllModelsVisible = false,
        -- table install
        -- {
            -- complete = ATATuning2.InstallComplete.TireNotAllModelsVisible,
        -- }
        -- table uninstall
        -- {
            -- requireUninstalled = ATA2ProtectionWheels,
            -- complete = ATATuning2.UninstallComplete.TireNotAllModelsVisible,
        -- }
        -- lua
        -- {
            -- create = Vehicles.Create.Tire,
            -- init = ATATuning2.Init.TireNotAllModelsVisible,
            -- checkOperate = Vehicles.CheckOperate.Tire,
            -- update = Vehicles.Update.Tire,
        -- }
    -- }
--***********************************************************


function ATATuning2.Create.TireNotAllModelsVisible(vehicle, part)
    Vehicles.Create.Tire(vehicle, part)
    ATATuning2Utils.ModelByItemName(vehicle, part, part:getInventoryItem())
end

function ATATuning2.Init.TireNotAllModelsVisible(vehicle, part)
    local wheelIndex = part:getWheelIndex()
    vehicle:setTireRemoved(wheelIndex, part:getInventoryItem() == nil)
    part:setModelVisible("InflatedTirePlusWheel", part:getInventoryItem() ~= nil)
    ATATuning2Utils.ModelByItemName(vehicle, part, part:getInventoryItem())
end

function ATATuning2.InstallComplete.TireNotAllModelsVisible(vehicle, part)
    local wheelIndex = part:getWheelIndex()
    vehicle:setTireRemoved(wheelIndex, false)
    part:setModelVisible("InflatedTirePlusWheel", true)
    ATATuning2Utils.ModelByItemName(vehicle, part, part:getInventoryItem())
end

function ATATuning2.UninstallComplete.TireNotAllModelsVisible(vehicle, part, item)
    local wheelIndex = part:getWheelIndex()
    vehicle:setTireRemoved(wheelIndex, true)
    part:setModelVisible("InflatedTirePlusWheel", false)
    ATATuning2Utils.ModelByItemName(vehicle, part)
end

--************************************************************

function ATATuning2.Create.DefaultModel(vehicle, part)
    local item = ATATuning2Utils.createPartInventoryItem(part)
    ATATuning2Utils.ModelByItemName(vehicle, part, item)
    vehicle:transmitPartCondition(part)
    vehicle:transmitPartItem(part)
    vehicle:doDamageOverlay()
end

function ATATuning2.Init.DefaultModel(vehicle, part)
    ATATuning2Utils.ModelByItemName(vehicle, part, part:getInventoryItem())
    vehicle:doDamageOverlay()
end

function ATATuning2.Create.Chance0(vehicle, part)
    part:setInventoryItem(nil)
    vehicle:transmitPartItem(part)
    ATATuning2Utils.ModelByItemName(vehicle, part)
    vehicle:doDamageOverlay()
end

--************************************************************
--**                                                           **
--**                       Engine Door                             **
--**                                                           **
--************************************************************

function ATATuning2.Init.Door(vehicle, part)
    Vehicles.Init.Door(vehicle, part)
    ATATuning2Utils.ModelByItemName(vehicle, part, part:getInventoryItem())
end

function ATATuning2.InstallComplete.Door(vehicle, part)
    Vehicles.InstallComplete.Door(vehicle, part)
    ATATuning2Utils.ModelByItemName(vehicle, part, part:getInventoryItem())
end

function ATATuning2.UninstallComplete.Door(vehicle, part, item)
    Vehicles.UninstallComplete.Door(vehicle, part, item)
    ATATuning2Utils.ModelByItemName(vehicle, part)
end

--***********************************************************
--**                                                       **
--**                        Roof Tent                           **
--**                                                       **
--***********************************************************

function ATATuning2.ContainerAccess.RoofTent(vehicle, part, chr)
    if chr:getVehicle() == vehicle then
        local seat = vehicle:getSeat(chr)
        return seat == 2 or seat == 3;
    else
        return false
    end
end

function ATATuning2.Init.RoofTent(vehicle, part)
    -- print("ATATuning2.Init.DefaultModel")
    if part:getInventoryItem() then
        -- print("ATATuning2.Init.DefaultModel: VISIBLE")
        part:setModelVisible("Default", true)
        if part:getModData().tuning2.status == "open" then
            part:setModelVisible("Close", false)
            part:setModelVisible("Open", true)
        else
            part:setModelVisible("Close", true)
            part:setModelVisible("Open", false)
        end
    end
end

function ATATuning2.InstallComplete.RoofTent(vehicle, part)
    local item = part:getInventoryItem()
    if not item then return end
    part:setModelVisible("Default", true)
    part:setModelVisible("Close", true)
    part:setModelVisible("Open", false)
    part:getModData().tuning2.status = "close"
    vehicle:transmitPartModData(part)
    vehicle:doDamageOverlay()
end

function ATATuning2.UninstallComplete.RoofTent(vehicle, part, item)
    if not item then return end
    part:setModelVisible("Default", false)
    part:setModelVisible("Close", false)
    part:setModelVisible("Open", false)
    part:getModData().tuning2 = {}
    vehicle:transmitPartModData(part)
    vehicle:doDamageOverlay()
end

function ATATuning2.UninstallTest.RoofTent(vehicle, part, chr)
    if ATATuning2.UninstallTest.Tuning(vehicle, part, chr) then
        return ATATuning2.UninstallTest.RoofClose(vehicle, vehicle:getPartById("SeatMiddleLeft"), chr) and
        ATATuning2.UninstallTest.RoofClose(vehicle, vehicle:getPartById("SeatMiddleRight"), chr)
    else
        return false
    end
end

function ATATuning2.Use.RoofTent(vehicle, part, character)
    if part:getModData().tuning2.status == "close" then
        part:setModelVisible("Close", false)
        part:setModelVisible("Open", true)
        part:getModData().tuning2.status = "open"
        vehicle:transmitPartModData(part)
        VehicleUtils.createPartInventoryItem(vehicle:getPartById("SeatMiddleLeft"))
        vehicle:getPartById("SeatMiddleLeft"):setContainerContentAmount(0)
        vehicle:getPartById("DoorMiddleLeft"):repair()
        VehicleUtils.createPartInventoryItem(vehicle:getPartById("SeatMiddleRight"))
        vehicle:getPartById("SeatMiddleRight"):setContainerContentAmount(0)
        vehicle:getPartById("DoorMiddleRight"):repair()
        vehicle:transmitPartItem(vehicle:getPartById("SeatMiddleLeft"))
        vehicle:transmitPartItem(vehicle:getPartById("SeatMiddleRight"))
    else
        part:setModelVisible("Close", true)
        part:setModelVisible("Open", false)
        vehicle:getPartById("SeatMiddleLeft"):setInventoryItem(nil) -- + vehicle:transmitPartItem(part)
        vehicle:getPartById("SeatMiddleRight"):setInventoryItem(nil) -- + vehicle:transmitPartItem(part)
        vehicle:transmitPartItem(vehicle:getPartById("SeatMiddleLeft"))
        vehicle:transmitPartItem(vehicle:getPartById("SeatMiddleRight"))
        part:getModData().tuning2.status = "close"
        vehicle:transmitPartModData(part)
    end
    ATATuning2.Init.RoofTent(vehicle, part)
end

function ATATuning2.UninstallTest.RoofClose(vehicle, part, chr)
    -- if not part:getInventoryItem() then return false end
    -- if not part:getItemType() or part:getItemType():isEmpty() then return false end
    -- local typeToItem = VehicleUtils.getItems(chr:getPlayerNum())
    if round(part:getItemContainer():getContentsWeight(), 3) > 0 then return false end -- вместо part:getContainerContentAmount()
    local seatNumber = part:getContainerSeatNumber()
    local seatOccupied = (seatNumber ~= -1) and vehicle:isSeatOccupied(seatNumber)
    if seatOccupied then return false end
    return true
end

--***********************************************************
--**                                                       **
--**      Multi Require Install and Uninstall table           **
--**                                                       **
--***********************************************************

function ATATuning2.InstallTest.multiRequire(vehicle, part, chr)
    if ISVehicleMechanics.cheat then return true; end
    local keyvalues = part:getTable("install")
    if not keyvalues then return false end
    if part:getInventoryItem() then return false end
    if not part:getItemType() or part:getItemType():isEmpty() then return false end
    local typeToItem = VehicleUtils.getItems(chr:getPlayerNum())
    if keyvalues.requireInstalled then
        local split = keyvalues.requireInstalled:split(";");
        for i,v in ipairs(split) do
            if not vehicle:getPartById(v) or not vehicle:getPartById(v):getInventoryItem() then return false; end
        end
    end
    if keyvalues.requireUninstalled then
        local split = keyvalues.requireUninstalled:split(";");
        for i,v in ipairs(split) do
            if vehicle:getPartById(v) and vehicle:getPartById(v):getInventoryItem() then return false; end
        end
    end
    if not VehicleUtils.testProfession(chr, keyvalues.professions) then return false end
    -- allow all perk, but calculate success/failure risk
--    if not VehicleUtils.testPerks(chr, keyvalues.skills) then return false end
    if not VehicleUtils.testRecipes(chr, keyvalues.recipes) then return false end
    if not VehicleUtils.testTraits(chr, keyvalues.traits) then return false end
    if not VehicleUtils.testItems(chr, keyvalues.items, typeToItem) then return false end
    -- if doing mechanics on this part require key but player doesn't have it, we'll check that door or windows aren't unlocked also
    if VehicleUtils.RequiredKeyNotFound(part, chr) then
        return false;
    end
    return true
end

function ATATuning2.UninstallTest.multiRequire(vehicle, part, chr)
    if ISVehicleMechanics.cheat then return true; end
    local keyvalues = part:getTable("uninstall")
    if not keyvalues then return false end
    if not part:getInventoryItem() then return false end
    if not part:getItemType() or part:getItemType():isEmpty() then return false end
    local typeToItem = VehicleUtils.getItems(chr:getPlayerNum())
    if keyvalues.requireInstalled then
        local split = keyvalues.requireInstalled:split(";");
        for i,v in ipairs(split) do
            if not vehicle:getPartById(v) or not vehicle:getPartById(v):getInventoryItem() then return false; end
        end
    end
    if keyvalues.requireUninstalled then
        local split = keyvalues.requireUninstalled:split(";");
        for i,v in ipairs(split) do
            if vehicle:getPartById(v) and vehicle:getPartById(v):getInventoryItem() then return false; end
        end
    end
    if not VehicleUtils.testProfession(chr, keyvalues.professions) then return false end
    -- allow all perk, but calculate success/failure risk
--    if not VehicleUtils.testPerks(chr, keyvalues.skills) then return false end
    if not VehicleUtils.testRecipes(chr, keyvalues.recipes) then return false end
    if not VehicleUtils.testTraits(chr, keyvalues.traits) then return false end
    if not VehicleUtils.testItems(chr, keyvalues.items, typeToItem) then return false end
    if keyvalues.requireEmpty and round(part:getContainerContentAmount(), 3) > 0 then return false end
    local seatNumber = part:getContainerSeatNumber()
    local seatOccupied = (seatNumber ~= -1) and vehicle:isSeatOccupied(seatNumber)
    if keyvalues.requireEmpty and seatOccupied then return false end
    -- if doing mechanics on this part require key but player doesn't have it, we'll check that door or windows aren't unlocked also
    if VehicleUtils.RequiredKeyNotFound(part, chr) then
        return false
    end
    return true
end
