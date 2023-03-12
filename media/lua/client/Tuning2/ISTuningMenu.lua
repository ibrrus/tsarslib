require "ATA2TuningTable"

if ISTuningMenu == nil then ISTuningMenu = {} end

if not ISTuningMenu.oldShowRadialMenu then
    ISTuningMenu.oldShowRadialMenu = ISVehicleMenu.showRadialMenu
end

if not ISTuningMenu.old_ISVehicleMenu_showRadialMenuOutside then
    ISTuningMenu.old_ISVehicleMenu_showRadialMenuOutside = ISVehicleMenu.showRadialMenuOutside
end

function ISVehicleMenu.showRadialMenu(playerObj)
    ISTuningMenu.oldShowRadialMenu(playerObj)
    ISTuningMenu.showRadialMenu(playerObj)
end

function ISTuningMenu.showRadialMenu(playerObj)
    local isPaused = UIManager.getSpeedControls() and UIManager.getSpeedControls():getCurrentGameSpeed() == 0
    if isPaused then return end
    local vehicle = playerObj:getVehicle()
    -- радиально меню внутри машины
    if vehicle then
        local vehicleName = vehicle:getScript():getName()
        local menu = getPlayerRadialMenu(playerObj:getPlayerNum())
        local seatNum = vehicle:getSeat(playerObj)
        local seatPart = vehicle:getPartForSeatContainer(seatNum)
        local seatName = seatPart:getId()
        
        -- отключение функции открытия окна. Устанавливается через параметр "disableOpenWindowFromSeat"
        if seatPart and seatPart:getModData().t2disableOpenWindow then
            menu:deleteMultiSliceTsar({getText("ContextMenu_Open_window"),})
        end
    end
end

function ISVehicleMenu.showRadialMenuOutside(playerObj)
    ISTuningMenu.old_ISVehicleMenu_showRadialMenuOutside(playerObj)
    if playerObj:getVehicle() then return end
    local playerIndex = playerObj:getPlayerNum()
    local menu = getPlayerRadialMenu(playerIndex)
    if menu:isReallyVisible() then
        if menu.joyfocus then
            setJoypadFocus(playerIndex, nil)
        end
        menu:undisplay()
        return
    end
    local vehicle = ISVehicleMenu.getVehicleToInteractWith(playerObj)
    if vehicle then
        -- Добавление меню для тюнинга2.0
        if ATA2TuningTable[vehicle:getScript():getName()] then
            menu:addSlice(getText("ContextMenu_OpenTuningMenu"), getTexture("media/ui/tuning2/vehicle_tuning.png"), ISTuningMenu.onTuning, playerObj, vehicle)
        end
    end
end

-------------------------
-- Tuning 2.0
-------------------------

function ISTuningMenu.onTuning(playerObj, vehicle)
    local ui = getPlayerTuningUI(playerObj:getPlayerNum())
    if ui:isReallyVisible() then
        ui:close()
        return
    end
    ISTimedActionQueue.add(ISOpenTuningUIAction:new(playerObj, vehicle))
end


-- function ISOpenMechanicsUIAction:perform()
	-- local ui = getPlayerMechanicsUI(self.character:getPlayerNum());
	-- ui.vehicle = self.vehicle;
	-- ui.usedHood = self.usedHood
	-- ui:initParts();
	-- ui:setVisible(true, JoypadState.players[self.character:getPlayerNum()+1])
	-- ui:addToUIManager()
	-- -- needed to remove from queue / start next.
	-- ISBaseTimedAction.perform(self)
-- end