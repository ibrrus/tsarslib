require "TimedActions/ISBaseTimedAction"

TCISConvertAppliance = ISBaseTimedAction:derive("TCISConvertAppliance");

function TCISConvertAppliance:isValid()
    return true;
end

function TCISConvertAppliance:update()
    self.item:setJobDelta(self:getJobDelta());
    self.character:setMetabolicTarget(Metabolics.UsingTools);
end

function TCISConvertAppliance:start()
	self.item:setJobDelta(0.0);
    self:setActionAnim(CharacterActionAnims.Craft);
end

function TCISConvertAppliance:stop()
    self.item:setJobDelta(0.0);
    ISBaseTimedAction.stop(self);
end

function TCISConvertAppliance:perform()
    self.container:Remove(self.item);
    self.container:AddItem("Base." .. self.newItemName)
    --self.item:ToggleWindow(self.character);
    -- self.character:smashWindow(self.item);
    -- needed to remove from queue / start next.
    ISBaseTimedAction.perform(self);
end

function TCISConvertAppliance:new(character, item, newItemName, time)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character;
    o.item = item;
    o.newItemName = newItemName;
    o.container = character:getInventory();
    o.stopOnWalk = true;
    o.stopOnRun = true;
    o.maxTime = time;
    if character:isTimedActionInstant() then
		o.maxTime = 1;
	end
    o.forceProgressBar = true;
    return o;
end
