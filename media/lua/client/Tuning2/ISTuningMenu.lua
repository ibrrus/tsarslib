require "ATA2TuningTable"

if ISTuningMenu == nil then ISTuningMenu = {} end
-- ISTuningMenu.old_ISVehicleMenu_FillMenuOutsideVehicle = ISVehicleMenu.FillMenuOutsideVehicle
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
        -- Функционал палатки
        local part = vehicle:getPartById("ATA2RoofTent");
        if part and part:getInventoryItem() then
            if part:getModData().tuning2 then
                if part:getModData().tuning2.status == "close" then
                    menu:addSlice(getText("ContextMenu_OpenTent"), getTexture("media/ui/commonlibrary/UI_commonlib_open_tent.png"), ISTuningMenu.openTent, playerObj, vehicle, part, true);
                elseif part:getModData().tuning2.status == "open" then
                    menu:addSlice(getText("ContextMenu_CloseTent"), getTexture("media/ui/commonlibrary/UI_commonlib_close_tent.png"), ISTuningMenu.openTent, playerObj, vehicle, part, false);
                end
            end
        end
    end
end

-------------------------
-- Tuning 2.0
-------------------------

function ISTuningMenu.openTent(playerObj, vehicle, part, open)
    if part and (open or (ATATuning2.UninstallTest.RoofClose(vehicle, part, playerObj) and ATATuning2.UninstallTest.RoofClose(vehicle, vehicle:getPartById("SeatMiddleLeft"), playerObj) and ATATuning2.UninstallTest.RoofClose(vehicle, vehicle:getPartById("SeatMiddleRight"), playerObj))) then
        ISTimedActionQueue.add(ISPathFindAction:pathToVehicleArea(playerObj, vehicle, part:getArea()))
        ISTimedActionQueue.add(ISOpenTent:new(playerObj, vehicle, part, open, 500))
    else
        playerObj:Say(getText("IGUI_PlayerText_ATA_TentDontOpen"))
    end
end

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

-- Добавление меню открытия палатки, через контекстное меню
-- function ISVehicleMenu.FillMenuOutsideVehicle(player, context, vehicle, test)
    -- local playerObj = getSpecificPlayer(player)
    -- if vehicle then
        -- local part = vehicle:getPartById("ATARoofTent");
        -- if part and part:getInventoryItem() then
            -- if part:getModData()["atatuning"] then
                -- if part:getModData()["atatuning"].status == "close" then
                    -- context:addOption(getText("ContextMenu_OpenTent"), playerObj, ISTuningMenu.openTent, vehicle, part, true);
                -- elseif part:getModData()["atatuning"].status == "open" then
                    -- context:addOption(getText("ContextMenu_CloseTent"), playerObj, ISTuningMenu.openTent, vehicle, part, false);
                -- end
            -- end
        -- end
        -- ISTuningMenu.old_ISVehicleMenu_FillMenuOutsideVehicle(player, context, vehicle, test)
    -- end
-- end
