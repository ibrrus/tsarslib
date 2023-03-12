local old_removeInventoryUI = removeInventoryUI

function removeInventoryUI(id)
    old_removeInventoryUI(id)
    local data = getPlayerData(id);
    if data == nil then return end;
    if data.tuningUI then
        print("removing tuningUI")
        data.tuningUI:removeFromUIManager()
    end
    data.tuningUI = nil
end

function getPlayerTuningUI(id)
    local data = getPlayerData(id)
    return data and data.tuningUI
end

local old_ISPlayerDataObject_createInventoryInterface = ISPlayerDataObject.createInventoryInterface

function ISPlayerDataObject:createInventoryInterface()
    old_ISPlayerDataObject_createInventoryInterface(self)
    
    local playerObj = getSpecificPlayer(self.id);
    local register = self.id == 0;
    if isMouse then
	    print("player ".. self.id .. " is mouse");
        zoom = 1.34;
    else
        register = false;
    end
    
    
    self.tuningUI = ISVehicleTuning2:new(0,0, 800, 700, playerObj);
    self.tuningUI:initialise();
    self.tuningUI:setVisible(false);
    self.tuningUI:setEnabled(false);
    
    if register then
        ISLayoutManager.RegisterWindow('tuning'..self.id, ISVehicleTuning2, self.tuningUI)
    end
end