if not ATA_ISVehicleMenu then ATA_ISVehicleMenu = {} end
ATA_ISVehicleMenu.old_ISVehicleMenu_showRadialMenuOutside = ISVehicleMenu.showRadialMenuOutside
ATA_ISVehicleMenu.old_ISVehiclePartMenu_onSmashWindow = ISVehiclePartMenu.onSmashWindow

local vec = Vector3f.new()

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
        -- Добавление радиального меню для автомобиля или прицепа с функциональностью эвакуатора
        local part = vehicle:getPartById("ATAVehicleWrecker")
        if part and part:getTable("ATAVehicleWrecker") then
            if part:getInventoryItem() then
                -- print("ATA_ISVehicleMenu.launchFromTrailerRadialMenu")
                if ATA_ISVehicleMenu.canLaunchVehicle(vehicle, part:getTable("ATAVehicleWrecker")) then
                    menu:addSlice(getText("ContextMenu_LaunchVehicle"), getTexture("media/ui/ata/ata_unload_from_trailer.png"), ATA_ISVehicleMenu.launchVehicle, playerObj, vehicle, part:getTable("ATAVehicleWrecker"))
                else
                    menu:addSlice(getText("ContextMenu_CantLaunchVehicle"), getTexture("media/ui/commonlibrary/no.png"), nil)
                end
            else
                local vehicle2 = ATA_ISVehicleMenu.getVehicleAtRearOfTrailer(vehicle)
                if vehicle2 then
                    menu:addSlice(getText("ContextMenu_LoadVehicleOntoTrailer"), getTexture("media/ui/ata/ata_load_on_trailer.png"), ATA_ISVehicleMenu.loadOntoTrailer, playerObj, vehicle, vehicle2)
                else
                    menu:addSlice(getText("ContextMenu_CantLoadVehicleOntoTrailer"), getTexture("media/ui/commonlibrary/no.png"), nil)
                end
            end
        end
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

function ATA_ISVehicleMenu.launchVehicle(playerObj, vehicle, wreckerinfo)
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

function ATA_ISVehicleMenu.getVehicleAtRearOfTrailer(trailer)
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

function ATA_ISVehicleMenu.loadOntoTrailer(playerObj, trailer, vehicle)
    if luautils.walkAdj(playerObj, trailer:getSquare()) then
        ISTimedActionQueue.add(ATAISLoadVehicle:new(playerObj, trailer, vehicle));
    end
end
