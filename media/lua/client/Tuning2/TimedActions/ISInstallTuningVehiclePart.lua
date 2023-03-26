require "TimedActions/ISBaseTimedAction"

ISInstallTuningVehiclePart = ISBaseTimedAction:derive("ISInstallTuningVehiclePart")

function ISInstallTuningVehiclePart:isValid()
-- print("ISInstallTuningVehiclePart:isValid")
    if ISVehicleMechanics.cheat then return true; end
    self.character:getModData().tryInstallTuning2Model = self.modelName
    return self.vehicle:canInstallPart(self.character, self.part)
end

function ISInstallTuningVehiclePart:waitToStart()
    if ISVehicleMechanics.cheat then return false; end
    self.character:faceThisObject(self.vehicle)
    return self.character:shouldBeTurning()
end

function ISInstallTuningVehiclePart:update()
    self.character:faceThisObject(self.vehicle)
    self.character:setMetabolicTarget(Metabolics.MediumWork);
    if not self.vehicle:getEmitter():isPlaying(self.sound) then
        self.vehicle:getEmitter():playSound(self.sound)
    end
end

function ISInstallTuningVehiclePart:start()
-- print("ISInstallTuningVehiclePart:start")
    if self.animation then
        self:setActionAnim(self.animation)
    elseif self.part:getWheelIndex() ~= -1 or self.part:getId():contains("Brake") then
        self:setActionAnim("VehicleWorkOnTire")
    else
        self:setActionAnim("VehicleWorkOnMid")
    end
    -- print(self.sound)
    self.vehicle:getEmitter():playSound(self.sound) -- getPlayer():getVehicle():getEmitter():playSound("BlowTorch")
--    self:setOverrideHandModels(nil, nil)
end

function ISInstallTuningVehiclePart:stop()
-- print("ISInstallTuningVehiclePart:stop")
    self.vehicle:getEmitter():stopSoundByName(self.sound)
    ISBaseTimedAction.stop(self)
end

local function ReduceUses(inventoryItem, availableUses)
    inventoryItem:setUsedDelta(inventoryItem:getUsedDelta() - inventoryItem:getUseDelta() * availableUses)
    if inventoryItem:getDrainableUsesInt() < 0 then inventoryItem:setUsedDelta(0.0f) end
end

local RandomSoundPerform = {
    "BuildMetalStructureSmall",
    "BuildMetalStructureMedium",
    "BuildMetalStructureSmallScrap",
    "BuildMetalStructureLargePoleFence",
    "BuildMetalStructureSmallPoleFence",
    "BuildMetalStructureLargeWiredFence",
    "BuildMetalStructureSmallWiredFence",
    "BuildMetalStructureWallFrame",
}

function ISInstallTuningVehiclePart:perform()
-- print("ISInstallTuningVehiclePart:perform")
    local inventory = self.character:getInventory()
    -- сохраняем состояние первого предмета для передачи в состояние детали.
    local firstCondition = nil
    -- удаляем у игрока, используемые в рецепте, предметы
    if self.use then
        
        for itemName, num in pairs(self.use) do
            itemName = itemName:gsub("__", ".")
            local item = inventory:getBestCondition(itemName)
            if not firstCondition and item then
                firstCondition = item:getCondition()
            end
            if item:IsDrainable() then
                local array = inventory:FindAll(itemName)
                for i=0,array:size()-1 do
                    item = array:get(i)
                    local availableUses = item:getDrainableUsesInt()
                    if availableUses >= num then
                        ReduceUses(item, num, self.character)
                        num = 0
                    else
                        ReduceUses(item, availableUses, self.character)
                        num = num - availableUses
                    end
                    if num == 0 then break end
                end
            else
                for i=1,num do
                    self.character:getInventory():RemoveOneOf(itemName)
                end
            end
        end
    end

    local args = { vehicle = self.vehicle:getId(), 
                    partName = self.part:getId(),
                    modelName = self.modelName,
                    condition = firstCondition}
    sendClientCommand(self.character, 'atatuning2', 'installTuning', args)

    local pdata = getPlayerData(self.character:getPlayerNum());
    if pdata ~= nil then
        pdata.playerInventory:refreshBackpacks();
        pdata.lootInventory:refreshBackpacks();
    end
    
    self.vehicle:getEmitter():stopSoundByName(self.sound)
    self.character:playSound(RandomSoundPerform[ZombRand(#RandomSoundPerform) + 1])
    UIManager.getSpeedControls():SetCurrentGameSpeed(1);
    -- needed to remove from queue / start next.
    ISBaseTimedAction.perform(self)
end

function ISInstallTuningVehiclePart:new(character, part, time, modelName)
-- print("ISInstallTuningVehiclePart:new")
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.vehicle = part:getVehicle()
    o.part = part
    o.modelName = modelName
    o.stopOnWalk = true
    o.stopOnRun = true
    o.maxTime = (time - (character:getPerkLevel(Perks.Mechanics) * (time/15))) * 100;
    if character:isTimedActionInstant() then
        o.maxTime = 1;
    end
    if ISVehicleMechanics.cheat then o.maxTime = 1; end
    
    -- заполнение переменных из таблицы тюнинга
    local vehicleName = o.vehicle:getScript():getName()
    local partName = part:getId()
    if ATA2TuningTable[vehicleName] 
            and ATA2TuningTable[vehicleName].parts[partName] 
            and ATA2TuningTable[vehicleName].parts[partName][modelName].install then
        local ltable = ATA2TuningTable[vehicleName].parts[partName][modelName].install
        if ltable.sound and GameSounds.isKnownSound(ltable.sound) then
            o.sound = ltable.sound
        else
            o.sound = "ATA2InstallGeneral"
        end
        if ltable.use then
            o.use = ltable.use
        end
        if ltable.animation then
            o.animation = ltable.animation
        end
    end
    
    -- o.jobType = getText("Tooltip_Vehicle_Installing", item:getDisplayName());
    return o
end

