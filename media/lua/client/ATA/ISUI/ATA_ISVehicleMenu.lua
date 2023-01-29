if not ATA_ISVehicleMenu then ATA_ISVehicleMenu = {} end

ATA_ISVehicleMenu.old_ISVehicleMenu_FillMenuOutsideVehicle = ISVehicleMenu.FillMenuOutsideVehicle
ATA_ISVehicleMenu.old_ISVehicleMenu_showRadialMenuOutside = ISVehicleMenu.showRadialMenuOutside
ATA_ISVehicleMenu.old_ISVehiclePartMenu_onSmashWindow = ISVehiclePartMenu.onSmashWindow

local vec = Vector3f.new()

function ISVehicleMenu.FillMenuOutsideVehicle(player, context, vehicle, test)
    local playerObj = getSpecificPlayer(player)
    if vehicle then
        local part = vehicle:getPartById("ATARoofTent");
        if part and part:getInventoryItem() then
            if part:getModData()["atatuning"] then
                if part:getModData()["atatuning"].status == "close" then
                    context:addOption(getText("ContextMenu_OpenTent"), playerObj, ATA_ISVehicleMenu.openTent, vehicle, part, true);
                elseif part:getModData()["atatuning"].status == "open" then
                    context:addOption(getText("ContextMenu_CloseTent"), playerObj, ATA_ISVehicleMenu.openTent, vehicle, part, false);
                end
            end
        end
        ATA_ISVehicleMenu.old_ISVehicleMenu_FillMenuOutsideVehicle(player, context, vehicle, test)
    end
end

function ISVehicleMenu.showRadialMenuOutside(playerObj)
    ATA_ISVehicleMenu.old_ISVehicleMenu_showRadialMenuOutside(playerObj)
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
        local part = vehicle:getPartById("ATARoofTent");
        if part and part:getInventoryItem() then
            if part:getModData()["atatuning"] then
                if part:getModData()["atatuning"].status == "close" then
                    menu:addSlice(getText("ContextMenu_OpenTent"), getTexture("media/ui/commonlibrary/UI_commonlib_open_tent.png"), ATA_ISVehicleMenu.openTent, playerObj, vehicle, part, true);
                elseif part:getModData()["atatuning"].status == "open" then
                    menu:addSlice(getText("ContextMenu_CloseTent"), getTexture("media/ui/commonlibrary/UI_commonlib_close_tent.png"), ATA_ISVehicleMenu.openTent, playerObj, vehicle, part, false);
                end
            end
        end
        
        -- Добавление радиального меню для автомобиля или прицепа с функциональностью эвакуатора
        part = vehicle:getPartById("ATAVehicleWrecker")
        if part and part:getTable("ATAVehicleWrecker") then
            if part:getInventoryItem() then
                ATA_ISVehicleMenu.launchFromTrailerRadialMenu(playerObj, vehicle, part:getTable("ATAVehicleWrecker"))
            else
                ATA_ISVehicleMenu.loadOntoTrailerRadialMenu(playerObj, vehicle, part:getTable("ATAVehicleWrecker"))
            end
        end
    end
end

function ATA_ISVehicleMenu.openTent(playerObj, vehicle, part, open)
    if part and (open or (ATATuning.UninstallTest.RoofClose(vehicle, part, playerObj) and ATATuning.UninstallTest.RoofClose(vehicle, vehicle:getPartById("SeatMiddleLeft"), playerObj) and ATATuning.UninstallTest.RoofClose(vehicle, vehicle:getPartById("SeatMiddleRight"), playerObj))) then
        ISTimedActionQueue.add(ISPathFindAction:pathToVehicleArea(playerObj, vehicle, part:getArea()))
        ISTimedActionQueue.add(ATAISOpenTent:new(playerObj, vehicle, part, open, 500))
    else
        playerObj:Say(getText("IGUI_PlayerText_ATA_TentDontOpen"))
    end
end

function ISVehiclePartMenu.onSmashWindow(playerObj, part, open)
    if part then
        local window = part:getWindow()
        if part:getTable("uninstall").requireUninstalled then
            local partProtection = part:getVehicle():getPartById(part:getTable("uninstall").requireUninstalled);
            if partProtection and partProtection:getInventoryItem() then
                processSayMessage(getText("IGUI_PlayerText_TRUEA_cant_vehicle_smash_window"))
                return
            end
        end
    end
    ATA_ISVehicleMenu.old_ISVehiclePartMenu_onSmashWindow(playerObj, part, open)
end


function ATA_ISVehicleMenu.getVehicleAtRearForTrailer(vehicle)
    -- Check line at rear of trailer
    for i=0, 8, 0.5 do    
        local point = vehicle:getWorldPos(0, 0, -vehicle:getScript():getPhysicsChassisShape():z()/2 - i, vec)
        local sq = getCell():getGridSquare(point:x(), point:y(), 0)
        
        local boat = sq:getVehicleContainer()
        if boat then
            if AquaConfig.isBoat(boat) and AquaConfig.Trailers[vehicle:getScript():getName()].trailerWithBoatTable[boat:getScript():getName()] then
                return boat
            end
        end
    end
end

-------------------------
-- Launch Vehicle
-------------------------

function ATA_ISVehicleMenu.canLaunchVehicle(vehicle, wreckerinfo)
    if not wreckerinfo.spawnDist then 
        return false 
    end
    local point = vehicle:getWorldPos(0, 0, -vehicle:getScript():getPhysicsChassisShape():z()/2 - tonumber(wreckerinfo.spawnDist), vec)
    local vehicleSqr = vehicle:getSquare()
    local placeSqr = getCell():getGridSquare(point:x(), point:y(), 0)
    -- if placeSqr == nil or not placeSqr:isFree(true) then return false end
    for i = 0, tonumber(wreckerinfo.spawnSize) do
        for j = 0, tonumber(wreckerinfo.spawnSize) do
            tempSqr = getCell():getGridSquare(point:x() + i, point:y() + j, 0)
            if tempSqr == nil or not tempSqr:isFree(true) or tempSqr:isVehicleIntersecting() or tempSqr:isSomethingTo(vehicleSqr) then return false end
        end
    end
    return true
end

function ATA_ISVehicleMenu.launchFromTrailerRadialMenu(playerObj, vehicle, wreckerinfo)
-- print("ATA_ISVehicleMenu.launchFromTrailerRadialMenu")
    local menu = getPlayerRadialMenu(playerObj:getPlayerNum())
    if ATA_ISVehicleMenu.canLaunchVehicle(vehicle, wreckerinfo) then
        menu:addSlice(getText("ContextMenu_LaunchVehicle"), getTexture("media/ui/ata/ata_unload_from_trailer.png"), ATA_ISVehicleMenu.launchBoat, playerObj, vehicle, wreckerinfo)
    else
        menu:addSlice(getText("ContextMenu_CantLaunchVehicle"), getTexture("media/ui/commonlibrary/no.png"), nil)
    end
end

function ATA_ISVehicleMenu.launchBoat(playerObj, vehicle, wreckerinfo)
    local point = vehicle:getWorldPos(0, 0, -vehicle:getScript():getPhysicsChassisShape():z()/2 - tonumber(wreckerinfo.spawnDist), vec)
    local sq = getCell():getGridSquare(point:x(), point:y(), 0)
    if sq == nil then return end
    if luautils.walkAdj(playerObj, vehicle:getSquare()) then
        ISTimedActionQueue.add(ATAISLaunchVehicle:new(playerObj, vehicle, sq));
    end
end

-------------------------
-- Load on Trailer
-------------------------

function ATA_ISVehicleMenu.getBoatAtRearOfTrailer(trailer)
    -- Check line at rear of trailer
    for i=0, 8, 0.5 do    
        local point = trailer:getWorldPos(0, 0, -trailer:getScript():getPhysicsChassisShape():z()/2 - i, vec)
        local sq = getCell():getGridSquare(point:x(), point:y(), 0)
        
        local vehicle = sq:getVehicleContainer()
        if vehicle and vehicle:getPartById("TCLConfig") and vehicle:getPartById("TCLConfig"):getTable("TCLConfig") then
            if vehicle:getPartById("TCLConfig"):getTable("TCLConfig").wreckerName == trailer:getScript():getName() then
                return vehicle
            end
        end
    end
end

function ATA_ISVehicleMenu.loadOntoTrailerRadialMenu(playerObj, trailer)
    local menu = getPlayerRadialMenu(playerObj:getPlayerNum())
    local vehicle = ATA_ISVehicleMenu.getBoatAtRearOfTrailer(trailer)
    if vehicle then
        menu:addSlice(getText("ContextMenu_LoadVehicleOntoTrailer"), getTexture("media/ui/ata/ata_load_on_trailer.png"), ATA_ISVehicleMenu.loadOntoTrailer, playerObj, trailer, vehicle)
    else
        menu:addSlice(getText("ContextMenu_CantLoadVehicleOntoTrailer"), getTexture("media/ui/commonlibrary/no.png"), nil)
    end
end

function ATA_ISVehicleMenu.loadOntoTrailer(playerObj, trailer, vehicle)
    if luautils.walkAdj(playerObj, trailer:getSquare()) then
        ISTimedActionQueue.add(ATAISLoadVehicle:new(playerObj, trailer, vehicle));
    end
end