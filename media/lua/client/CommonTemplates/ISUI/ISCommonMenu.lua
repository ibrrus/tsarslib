if ISCommonMenu == nil then ISCommonMenu = {} end
-- require 'Boats/ISUI/ISBoatMenu'

if not ISCommonMenu.oldShowRadialMenu then
    ISCommonMenu.oldShowRadialMenu = ISVehicleMenu.showRadialMenu
end

-- function ISCommonMenu.onKeyStartPressed(key)
    -- local playerObj = getPlayer()
    -- if not playerObj then return end
    -- if playerObj:isDead() then return end
    -- local vehicle = playerObj:getVehicle()
    -- if vehicle and key == getCore():getKey("VehicleRadialMenu") then
        -- ISCommonMenu.showRadialMenu(playerObj, vehicle)
    -- end
-- end

function ISVehicleMenu.showRadialMenu(playerObj)
    ISCommonMenu.oldShowRadialMenu(playerObj)
    ISCommonMenu.showRadialMenu(playerObj)
end


local old_ISVehicleMenu_doTowingMenu = ISVehicleMenu.doTowingMenu

-- Отключение функции для подсоединения прицепа вручную
function ISVehicleMenu.doTowingMenu(playerObj, vehicle, menu)
    if vehicle and vehicle:getPartById("TCLConfig") then
        if vehicle:getPartById("TCLConfig"):getTable("TCLConfig").trailerOutside == "false" then
            return
        end
    end
    old_ISVehicleMenu_doTowingMenu(playerObj, vehicle, menu)
end

function ISCommonMenu.showRadialMenu(playerObj)
    local isPaused = UIManager.getSpeedControls() and UIManager.getSpeedControls():getCurrentGameSpeed() == 0
    if isPaused then return end
    local vehicle = playerObj:getVehicle()
    if vehicle then
        local tclInfo = nil
        if vehicle:getPartById("TCLConfig") then
            tclInfo = vehicle:getPartById("TCLConfig"):getTable("TCLConfig")
        end
        local menu = getPlayerRadialMenu(playerObj:getPlayerNum())
        local seatNum = vehicle:getSeat(playerObj)
        local seatName = string.sub(vehicle:getPartForSeatContainer(seatNum):getId(), 5)
        local oven = vehicle:getPartById("Oven" .. seatName)
        local fridge = vehicle:getPartById("Fridge" .. seatName)
        local freezer = vehicle:getPartById("Freezer" .. seatName)
        local microwave = vehicle:getPartById("Microwave" .. seatName)
        local inCabin = vehicle:getPartById("InCabin" .. seatName)
        local inRoofTent = vehicle:getPartById("InRoofTent" .. seatName)
        local mattress = vehicle:getPartById("Mattress" .. seatName)
        local lightIsOn = true
        local timeHours = getGameTime():getHour()
        local freespace1 = vehicle:getPartById("Freeplace1" .. seatName)
        local freespace2 = vehicle:getPartById("Freeplace2" .. seatName)
        local freespace3 = vehicle:getPartById("Freeplace3" .. seatName)
        
        if inCabin then
            if vehicle:getPartById("HeadlightRearRight") and vehicle:getPartById("HeadlightRearRight"):getInventoryItem() then
                menu:addSlice(getText("ContextMenu_BoatCabinelightsOff"), getTexture("media/ui/boats/boat_switch_off.png"), ISCommonMenu.offToggleCabinlights, playerObj)
            else
                if (timeHours > 22 or timeHours < 7) then
                    menu:addSlice(getText("ContextMenu_BoatCabinelightsOn"), getTexture("media/ui/boats/boat_switch_on.png"), ISCommonMenu.onToggleCabinlights, playerObj)
                    lightIsOn = false
                else
                    menu:addSlice(getText("ContextMenu_BoatCabinelightsOn"), getTexture("media/ui/boats/boat_switch_on_day.png"), ISCommonMenu.onToggleCabinlights, playerObj)
                end
            end
        end
        if inRoofTent then
            menu:deleteMultiSliceTsar({getText("ContextMenu_Unlock_Doors"), getText("ContextMenu_Lock_Doors"), getText("ContextMenu_VehicleHeaterOn"), getText("ContextMenu_VehicleHeaterOff"), getText("ContextMenu_VehicleMechanics")})
            menu:updateSliceTsar(getText("IGUI_ExitVehicle"), getText("IGUI_ExitVehicleTent"), getTexture("media/ui/commonlibrary/tent_exit.png"))
            menu:updateSliceTsar(getText("ContextMenu_Close_window"), getText("ContextMenu_Close_window"), getTexture("media/ui/commonlibrary/UI_commonlib_close_tent_window.png"))
            menu:updateSliceTsar(getText("ContextMenu_Open_window"), getText("ContextMenu_Open_window"), getTexture("media/ui/commonlibrary/UI_commonlib_open_tent_window.png"))
            menu:updateSliceTsar(getText("IGUI_SwitchSeat"), getText("IGUI_SwitchSeat"), getTexture("media/ui/commonlibrary/UI_commonlib_sleep_bag_change.png"))
        end
        
        if mattress and (not isClient() or getServerOptions():getBoolean("SleepAllowed")) then
            ISCommonMenu.doMattressMenu(menu, playerObj, vehicle, inRoofTent)
        end

        if vehicle:getPartById("BatteryHeater") and lightIsOn and inCabin then
            -- print("BatteryHeater")
            local tex = getTexture("media/ui/commonlibrary/UI_temperatureHC.png")
            if (vehicle:getPartById("BatteryHeater"):getModData().tsarslib.temperature or 0) < 0 then
                tex = getTexture("media/ui/vehicles/vehicle_temperatureCOLD.png")
            elseif (vehicle:getPartById("BatteryHeater"):getModData().tsarslib.temperature or 0) > 0 then
                tex = getTexture("media/ui/vehicles/vehicle_temperatureHOT.png")
            end        
            if vehicle:getPartById("BatteryHeater"):getModData().tsarslib.active then
                menu:addSlice(getText("ContextMenu_AirCondOff"), tex, ISCommonMenu.onToggleHeater, playerObj )
            else
                menu:addSlice(getText("ContextMenu_AirCondOn"), tex, ISCommonMenu.onToggleHeater, playerObj )
            end
        end

        if oven and lightIsOn then
            ISCommonMenu.doOvenMenu(menu, playerObj, vehicle, oven)
        end
        
        if microwave and lightIsOn then
            ISCommonMenu.doMicrowaveMenu(menu, playerObj, vehicle, microwave)
        end
            
        if fridge and lightIsOn then
            ISCommonMenu.doFridgeMenu(menu, playerObj, vehicle, fridge)
        end
        
        if freezer and lightIsOn then
            ISCommonMenu.doFreezerMenu(menu, playerObj, vehicle, freezer)
        end
        
        if vehicle:isDriver(playerObj) then
            local doorPart = vehicle:getPartById("ATAHeadlightsPopUP")
            if doorPart and doorPart:getDoor() then
                if doorPart:getDoor():isOpen() then
                    menu:addSlice(getText("IGUI_CloseHeadlightsPopUP"), getTexture("media/ui/ata/ata_popup_headlight_close.png"), ISCommonMenu.onCloseHeadlight, playerObj, doorPart)
                else
                    menu:addSlice(getText("IGUI_OpenHeadlightsPopUP"), getTexture("media/ui/ata/ata_popup_headlight_open.png"), ISCommonMenu.onOpenDoor, playerObj, doorPart)
                    menu:updateSliceTsar(getText("ContextMenu_VehicleHeadlightsOn"), nil, nil, ISCommonMenu.onToggleHeadlights, playerObj, doorPart)
                end
            end
        end
        if seatNum == 0 and vehicle:getScript():getAttachmentById("trailerTruck") then
            ISCommonMenu.doTowingMenu(playerObj, vehicle, menu)
        end
        if tclInfo then
            -- Отключает возможность открывать/закрывать двери в машине
            if tclInfo.disableDoorLocker == "1" then
                menu:deleteMultiSliceTsar({getText("ContextMenu_Unlock_Doors"), getText("ContextMenu_Lock_Doors")})
            end
            -- Отключает возможность спать в автомобиле.
            if tclInfo.disableSleep == "1" then
                menu:deleteMultiSliceTsar({getText("IGUI_Sleep_NotTiredEnough"), getText("IGUI_PlayerText_CanNotSleepInMovingCar"), getText("ContextMenu_PainNoSleep"), getText("ContextMenu_PanicNoSleep"), getText("ContextMenu_NoSleepTooEarly"), getText("ContextMenu_Sleep")})
            end
            -- запрещает открывать окно, если установлена определенная запчасть
            if tclInfo.disableOpenWindowParts and tclInfo.disableOpenWindowParts[seatName] then
                if vehicle:getPartById(tclInfo.disableOpenWindowParts[seatName]) and vehicle:getPartById(tclInfo.disableOpenWindowParts[seatName]):getInventoryItem() then
                    menu:deleteMultiSliceTsar({getText("ContextMenu_Open_window"),})
                end
            end
        end
        
        if freespace1 and freespace1:getInventoryItem() then
            ISCommonMenu.doFreespaceMenu(playerObj, vehicle, freespace1, menu)
        end
        if freespace2 and freespace2:getInventoryItem() then
            ISCommonMenu.doFreespaceMenu(playerObj, vehicle, freespace2, menu)
        end
        if freespace3 and freespace3:getInventoryItem() then
            ISCommonMenu.doFreespaceMenu(playerObj, vehicle, freespace3, menu)
        end
    end
end

function ISCommonMenu.doFreespaceMenu(playerObj, vehicle, freespace, menu)
    -- print(freespaceInv:getType() == "TransportFreezer")
    local freespaceInv = freespace:getInventoryItem()
    local invItemName = freespaceInv:getType()
    if invItemName == "TransportFreezer" then
        ISCommonMenu.doFreezerMenu(menu, playerObj, vehicle, freespace)
    elseif invItemName == "TransportFridge" then
        ISCommonMenu.doFridgeMenu(menu, playerObj, vehicle, freespace)
    elseif invItemName == "Mattress" then
        ISCommonMenu.doMattressMenu(menu, playerObj, vehicle)
    elseif invItemName == "TransportMicrowave" then
        ISCommonMenu.doMicrowaveMenu(menu, playerObj, vehicle, freespace)
    elseif invItemName == "TransportOven" then
        ISCommonMenu.doOvenMenu(menu, playerObj, vehicle, freespace)
    -- elseif invItemName == "TvAntique" or invItemName == "TvWideScreen" or invItemName == "TvBlack" then
        -- menu:addSlice(getText("IGUI_DeviceOptions"), getTexture("media/ui/commonlibrary/vehicle_TV.png"), ISVehicleMenu.onSignalDevice, playerObj, freespace)
    end
end

function ISCommonMenu.doMattressMenu(menu, playerObj, vehicle, inRoofTent)
    if (not isClient() or getServerOptions():getBoolean("SleepAllowed")) then
        local mattressTex = getTexture("media/ui/commonlibrary/mattress.png")
        if inRoofTent then
            mattressTex = getTexture("media/ui/commonlibrary/sleeping_bag.png")
        end
        if menu:updateSliceTsar(getText("IGUI_Sleep_NotTiredEnough"), nil, mattressTex, nil, playerObj, vehicle) or
        menu:updateSliceTsar(getText("IGUI_PlayerText_CanNotSleepInMovingCar"), nil, mattressTex, nil, playerObj, vehicle) or
        menu:updateSliceTsar(getText("ContextMenu_PainNoSleep"), nil, mattressTex, nil, playerObj, vehicle) or
        menu:updateSliceTsar(getText("ContextMenu_PanicNoSleep"), nil, mattressTex, nil, playerObj, vehicle) or
        menu:updateSliceTsar(getText("ContextMenu_NoSleepTooEarly"), nil, mattressTex, nil, playerObj, vehicle)  or
        menu:updateSliceTsar(getText("ContextMenu_Sleep"), getText("ContextMenu_Sleep"), mattressTex, ISCommonMenu.onSleep, playerObj, vehicle) then end
    end
end

function ISCommonMenu.doFridgeMenu(menu, playerObj, vehicle, fridge)
    if fridge:getModData().tsarslib and fridge:getModData().tsarslib.active then
        menu:addSlice(getText("IGUI_Turn_Fridge_Off"), getTexture("media/ui/Container_Fridge"), ISCommonMenu.ToggleDeviceFridge, playerObj, vehicle, fridge)
    else
        menu:addSlice(getText("IGUI_Turn_Fridge_On"), getTexture("media/ui/Container_Fridge"), ISCommonMenu.ToggleDeviceFridge, playerObj, vehicle, fridge)
    end
end

function ISCommonMenu.doMicrowaveMenu(menu, playerObj, vehicle, microwave)
    menu:addSlice(getText("IGUI_UseMicrowave"), getTexture("media/ui/Container_Microwave"), ISCommonMenu.onMicrowaveSetting, playerObj, vehicle, microwave)
end

function ISCommonMenu.doOvenMenu(menu, playerObj, vehicle, oven)
    menu:addSlice(getText("IGUI_UseStove"), getTexture("media/ui/Container_Oven"), ISCommonMenu.onStoveSetting, playerObj, vehicle, oven)
    -- if oven:getItemContainer():isActive() then
        -- menu:addSlice(getText("IGUI_Turn_Oven_Off"), getTexture("media/ui/Container_Oven"), ISCommonMenu.ToggleDevice, playerObj, vehicle, oven)
    -- else
        -- menu:addSlice(getText("IGUI_Turn_Oven_On"), getTexture("media/ui/Container_Oven"), ISCommonMenu.ToggleDevice, playerObj, vehicle, oven)
    -- end
end

function ISCommonMenu.doFreezerMenu(menu, playerObj, vehicle, freezer)
    if freezer:getModData().tsarslib and freezer:getModData().tsarslib.active then
        menu:addSlice(getText("IGUI_Turn_Freezer_Off"), getTexture("media/ui/Container_Freezer"), ISCommonMenu.ToggleDeviceFridge, playerObj, vehicle, freezer)
    else
        menu:addSlice(getText("IGUI_Turn_Freezer_On"), getTexture("media/ui/Container_Freezer"), ISCommonMenu.ToggleDeviceFridge, playerObj, vehicle, freezer)
    end
end

function ISCommonMenu.onSleep(playerObj, vehicle)
    -- if vehicle:getCurrentSpeedKmHour() > 1 or vehicle:getCurrentSpeedKmHour() < -1 then
        -- playerObj:Say(getText("IGUI_PlayerText_CanNotSleepInMovingCar"))
        -- return;
    -- end
    local playerNum = playerObj:getPlayerNum()
    local modal = ISModalDialog:new(0,0, 250, 150, getText("IGUI_ConfirmSleep"), true, nil, ISCommonMenu.onConfirmSleep, playerNum, playerNum, nil);
    modal:initialise()
    modal:addToUIManager()
    if JoypadState.players[playerNum+1] then
        setJoypadFocus(playerNum, modal)
    end
end

function ISCommonMenu.onConfirmSleep(this, button, player, bed)
    if button.internal == "YES" then
        ISCommonMenu.onSleepWalkToComplete(player, "RV")
    end
end

function ISCommonMenu.onSleepWalkToComplete(player, bed)
    local playerObj = getSpecificPlayer(player)
    ISTimedActionQueue.clear(playerObj)
    if isClient() and getServerOptions():getBoolean("SleepAllowed") then
        playerObj:setAsleepTime(0.0)
        playerObj:setAsleep(true)
        UIManager.setFadeBeforeUI(player, true)
        UIManager.FadeOut(player, 1)
        return
    end
    playerObj:setBedType("goodBed")
    local modal = nil;
    local sleepFor = ZombRand(playerObj:getStats():getFatigue() * 10, playerObj:getStats():getFatigue() * 13);
    
    if playerObj:HasTrait("Insomniac") then
        sleepFor = sleepFor * 0.5;
    end
    if playerObj:HasTrait("NeedsLessSleep") then
        sleepFor = sleepFor * 0.75;
    end
    if playerObj:HasTrait("NeedsMoreSleep") then
        sleepFor = sleepFor * 1.18;
    end
    
    if sleepFor > 16 then sleepFor = 16; end
    if sleepFor < 3 then sleepFor = 3; end
    --    print("GONNA SLEEP " .. sleepHours .. " HOURS" .. " AND ITS " .. GameTime.getInstance():getTimeOfDay())
    local sleepHours = sleepFor + GameTime.getInstance():getTimeOfDay()
    if sleepHours >= 24 then
        sleepHours = sleepHours - 24
    end
    playerObj:setForceWakeUpTime(tonumber(sleepHours))
    playerObj:setAsleepTime(0.0)
    playerObj:setAsleep(true)
    getSleepingEvent():setPlayerFallAsleep(playerObj, sleepFor);

    UIManager.setFadeBeforeUI(playerObj:getPlayerNum(), true)
    UIManager.FadeOut(playerObj:getPlayerNum(), 1)

    if IsoPlayer.allPlayersAsleep() then
        UIManager.getSpeedControls():SetCurrentGameSpeed(3)
        save(true)
    end
end







local TowMenu = {}

function TowMenu.isBurnt(vehicle)
    return string.contains(vehicle:getScriptName(), "Burnt")
end

function TowMenu.isTrailer(vehicle)
    return string.contains(vehicle:getScriptName(), "Trailer")
end

function TowMenu.getTowableVehicleNear(square, ignoreVehicle, attachmentA, attachmentB)
    for y=square:getY() - 10,square:getY()+10 do
        for x=square:getX()-10,square:getX()+10 do
            local square2 = getCell():getGridSquare(x, y, square:getZ())
            if square2 then
                for i=1,square2:getMovingObjects():size() do
                    local obj = square2:getMovingObjects():get(i-1)
                    if instanceof(obj, "BaseVehicle") and obj ~= ignoreVehicle and ignoreVehicle:canAttachTrailer(obj, attachmentA, attachmentB) then
                        return obj
                    end
                end
            end
        end
    end
    return nil
end

function TowMenu.attachVehicleToOther(playerObj, vehicle, menu)
    local attachmentA, attachmentB = "trailerTruck", "trailerTruck"
    local vehicleB = TowMenu.getTowableVehicleNear(vehicle:getSquare(), vehicle, attachmentA, attachmentB)

    if not vehicleB then
        attachmentA, attachmentB = "trailerTruck", "trailerTruck"
        vehicleB = TowMenu.getTowableVehicleNear(vehicle:getSquare(), vehicle, attachmentA, attachmentB)
    end

    if not vehicleB then
        attachmentA, attachmentB = "trailerTruck", "trailerTruck"
        vehicleB = TowMenu.getTowableVehicleNear(vehicle:getSquare(), vehicle, attachmentA, attachmentB)
    end

    if not vehicleB then
        attachmentA, attachmentB = "trailerTruck", "trailerTruck"
        vehicleB = TowMenu.getTowableVehicleNear(vehicle:getSquare(), vehicle, attachmentA, attachmentB)
    end
    if vehicleB then
        if TowMenu.isBurnt(vehicleB) then
            TowMenu.addOption(playerObj, menu, vehicle, vehicleB, attachmentA, attachmentB)
        elseif TowMenu.isTrailer(vehicleB) then
            TowMenu.addOption(playerObj, menu, vehicle, vehicleB, attachmentA, attachmentB)
        else
            TowMenu.addOption(playerObj, menu, vehicle, vehicleB, attachmentA, attachmentB)
        end
    end
end

function TowMenu.addOption(playerObj, menu, vehicleA, vehicleB, attachmentA, attachmentB)
    local aName = ISVehicleMenu.getVehicleDisplayName(vehicleA)
    local bName = ISVehicleMenu.getVehicleDisplayName(vehicleB)
    local text = getText("ContextMenu_Vehicle_AttachTrailer", bName, aName);
    menu:addSlice(text, getTexture("media/ui/ZoomIn.png"), ISCommonMenu.onAttachTrailer, playerObj, vehicleA, vehicleB, attachmentA, attachmentB)
end

function ISCommonMenu.onAttachTrailer(playerObj, vehicle, vehicleB, attachmentA, attachmentB)
    local square = vehicle:getCurrentSquare()
    if not vehicleB then return end
    local args = { vehicleA = vehicle:getId(), vehicleB = vehicleB:getId(), attachmentA = attachmentA, attachmentB = attachmentB }
    sendClientCommand(playerObj, 'vehicle', 'attachTrailer', args)
end

function ISCommonMenu.onDetachTrailer(playerObj, vehicle, attachmentA)
    sendClientCommand(playerObj, 'vehicle', 'detachTrailer', { vehicle = vehicle:getId() })
    -- local nextAction = ISDetachTrailerFromVehicle:new(playerObj, vehicle, attachmentA)
    -- ISTimedActionQueue.add(nextAction)
    -- if not ISVehicleTrailerUtils.walkToTrailer(playerObj, vehicle, attachmentA, nextAction) then return end
end

function ISCommonMenu.doTowingMenu(playerObj, vehicle, menu)
    if vehicle:getVehicleTowing() then
        local bName = ISVehicleMenu.getVehicleDisplayName(vehicle:getVehicleTowing())
        menu:addSlice(getText("ContextMenu_Vehicle_DetachTrailer", bName), getTexture("media/ui/ZoomOut.png"), ISCommonMenu.onDetachTrailer, playerObj, vehicle, vehicle:getTowAttachmentSelf())
        return
    end
    TowMenu.attachVehicleToOther(playerObj, vehicle, menu)
end

function ISCommonMenu.onToggleHeadlights(playerObj, part)
-- print("ISCommonMenu.onToggleHeadlights")
    local vehicle = playerObj:getVehicle()
    if not vehicle then return end
    if vehicle:getHeadlightsOn() then
        ISCommonMenu.onCloseDoor(playerObj, part)
    else
        ISCommonMenu.onOpenDoor(playerObj, part)
    end
    sendClientCommand(playerObj, 'vehicle', 'setHeadlightsOn', { on = not vehicle:getHeadlightsOn() })
end

function ISCommonMenu.onCloseHeadlight(playerObj, part)
    local vehicle = playerObj:getVehicle()
    if not vehicle then return end
    if vehicle:getHeadlightsOn() then
        sendClientCommand(playerObj, 'vehicle', 'setHeadlightsOn', { on = not vehicle:getHeadlightsOn() })
    end
    ISTimedActionQueue.add(ATAISAnimatedPartClose:new(playerObj, part:getVehicle(), part))
end

function ISCommonMenu.onOpenDoor(playerObj, part)
    ISTimedActionQueue.add(ATAISAnimatedPartOpen:new(playerObj, part:getVehicle(), part))
end

function ISCommonMenu.onCloseDoor(playerObj, part)
    ISTimedActionQueue.add(ATAISAnimatedPartClose:new(playerObj, part:getVehicle(), part))
end

function ISCommonMenu.onToggleHeater(playerObj)
    local playerNum = playerObj:getPlayerNum()
    if not ISCommonMenu.acui then
        ISCommonMenu.acui = {}
    end
    local ui = ISCommonMenu.acui[playerNum]
    if not ui or ui.character ~= playerObj then
        ui = ISBatteryACUI:new(0,0,playerObj)
        ui:initialise()
        ui:instantiate()
        ISCommonMenu.acui[playerNum] = ui
    end
    if ui:isReallyVisible() then
        ui:removeFromUIManager()
        if JoypadState.players[playerNum+1] then
            setJoypadFocus(playerNum, nil)
        end
    else
        ui:setVehicle(playerObj:getVehicle())
        ui:addToUIManager()
        if JoypadState.players[playerNum+1] then
            JoypadState.players[playerNum+1].focus = ui
        end
    end
end    
    
function ISCommonMenu.ToggleDevice(playerObj, vehicle, part)
    CommonTemplates.Use.DefaultDevice(vehicle, part, playerObj)
end

function ISCommonMenu.ToggleDeviceFridge(playerObj, vehicle, part)
    CommonTemplates.Use.Fridge(vehicle, part, playerObj)
end

-- function ISCommonMenu.ToggleMicrowave(playerObj, vehicle, part, on)
    -- CommonTemplates.Use.Microwave(vehicle, part, playerObj, on)
-- end

function ISCommonMenu.onStoveSetting(playerObj, vehicle, part)
    local data = getPlayerData(playerObj:getPlayerNum())
    if not data.portableOvenUI or not data.portableOvenUI:getIsVisible() then
        data.portableOvenUI = ISPortableOvenUI:new(0,0,430,310, playerObj, vehicle, part)
        data.portableOvenUI:initialise()
        data.portableOvenUI:addToUIManager()
    else
        data.portableOvenUI:setVisible(false);
        data.portableOvenUI:removeFromUIManager();
        data.portableOvenUI = nil
    end
end

function ISCommonMenu.onMicrowaveSetting(playerObj, vehicle, part)
    local data = getPlayerData(playerObj:getPlayerNum())
    if not data.portableOvenUI or not data.portableOvenUI:getIsVisible() then
        data.portableOvenUI = ISPortableMicrowaveUI:new(0,0,430,310, playerObj, vehicle, part)
        data.portableOvenUI:initialise()
        data.portableOvenUI:addToUIManager()
    else
        data.portableOvenUI:setVisible(false);
        data.portableOvenUI:removeFromUIManager();
        data.portableOvenUI = nil
    end
end

function ISCommonMenu.onToggleCabinlights(playerObj)
    local vehicle = playerObj:getVehicle()
    if not vehicle then return end
    local part = vehicle:getPartById("LightCabin")
    local partCondition = part:getCondition()
    if part and part:getInventoryItem() and partCondition > 0 then
        local chanceFail = (100 - partCondition)/10
        if ZombRand(100) < chanceFail then
            sendClientCommand(playerObj, 'commonlib', 'bulbSmash', {vehicle = vehicle:getId(),})
            vehicle:getEmitter():playSound("BulbSmash")
        else
            sendClientCommand(playerObj, 'commonlib', 'cabinlightsOn', {vehicle = vehicle:getId(),})
            sendClientCommand(playerObj, 'vehicle', 'setHeadlightsOn', { on = true })
            vehicle:getEmitter():playSound("SwitchLamp")
        end
    else
        vehicle:getEmitter():playSound("SwitchLampFail")
        -- playerObj:Say(getText("IGUI_PlayerText_CabinlightDoNotWork"))
    end
    --sendClientCommand(playerObj, 'vehicle', 'setStoplightsOn', { on = not boat:getHeadlightsOn() })
end

function ISCommonMenu.offToggleCabinlights(playerObj)
    local vehicle = playerObj:getVehicle()
    if not vehicle then return end
    local part = vehicle:getPartById("HeadlightRearRight")
    part:setInventoryItem(nil)
    vehicle:getEmitter():playSound("SwitchLamp")
    local lightIsOn = false
    part = vehicle:getPartById("HeadlightLeft")
    if part then
        if part:getInventoryItem() then
            lightIsOn = true
        end
    end
    part = vehicle:getPartById("HeadlightRight")
    if part then
        if part:getInventoryItem() then
            lightIsOn = true
        end
    end
    if not lightIsOn then
        sendClientCommand(playerObj, 'vehicle', 'setHeadlightsOn', { on = false })
    end
    --sendClientCommand(playerObj, 'vehicle', 'setStoplightsOn', { on = not boat:getHeadlightsOn() })
end

-- Events.OnKeyStartPressed.Add(ISCommonMenu.onKeyStartPressed)