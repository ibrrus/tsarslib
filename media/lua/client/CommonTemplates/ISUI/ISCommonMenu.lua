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


function ISCommonMenu.showRadialMenu(playerObj)
	local isPaused = UIManager.getSpeedControls() and UIManager.getSpeedControls():getCurrentGameSpeed() == 0
	if isPaused then return end
	local vehicle = playerObj:getVehicle()
	if vehicle then
		local menu = getPlayerRadialMenu(playerObj:getPlayerNum())
		local seat = seatNameTable[vehicle:getSeat(playerObj)+1]
		local oven = vehicle:getPartById("Oven" .. seat)
		local fridge = vehicle:getPartById("Fridge" .. seat)
		local freezer = vehicle:getPartById("Freezer" .. seat)
		local microwave = vehicle:getPartById("Microwave" .. seat)
		local inCabin = vehicle:getPartById("InCabin" .. seat)
		local inRoofTent = vehicle:getPartById("InRoofTent" .. seat)
		local mattress = vehicle:getPartById("Mattress" .. seat)
		local lightIsOn = true
		local timeHours = getGameTime():getHour()
		
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
			menu:deleteMultiSliceTsar({getText("ContextMenu_Unlock_Doors"), getText("ContextMenu_Unlock_Doors"), getText("ContextMenu_Lock_Doors"), getText("ContextMenu_VehicleHeaterOn"), getText("ContextMenu_VehicleHeaterOff"), getText("ContextMenu_VehicleMechanics")})
			menu:updateSliceTsar(getText("IGUI_ExitVehicle"), getText("IGUI_ExitVehicleTent"), getTexture("media/ui/commonlibrary/tent_exit.png"))
			menu:updateSliceTsar(getText("ContextMenu_Close_window"), getText("ContextMenu_Close_window"), getTexture("media/ui/commonlibrary/UI_commonlib_close_tent_window.png"))
			menu:updateSliceTsar(getText("ContextMenu_Open_window"), getText("ContextMenu_Open_window"), getTexture("media/ui/commonlibrary/UI_commonlib_open_tent_window.png"))
			menu:updateSliceTsar(getText("IGUI_SwitchSeat"), getText("IGUI_SwitchSeat"), getTexture("media/ui/commonlibrary/UI_commonlib_sleep_bag_change.png"))
		end
		
		if mattress and (not isClient() or getServerOptions():getBoolean("SleepAllowed")) then
			local mattressTex = getTexture("media/ui/commonlibrary/mattress.png")
			if inRoofTent then
				mattressTex = getTexture("media/ui/commonlibrary/sleeping_bag.png")
			end
			if menu:updateSliceTsar(getText("IGUI_Sleep_NotTiredEnough"), nil, mattressTex, nil, playerObj, vehicle) or
			menu:updateSliceTsar(getText("IGUI_PlayerText_CanNotSleepInMovingCar"), nil, mattressTex, nil, playerObj, vehicle) or
			menu:updateSliceTsar(getText("ContextMenu_PainNoSleep"), nil, mattressTex, nil, playerObj, vehicle) or
			menu:updateSliceTsar(getText("ContextMenu_PanicNoSleep"), nil, mattressTex, nil, playerObj, vehicle) or
			menu:updateSliceTsar(getText("ContextMenu_NoSleepTooEarly"), nil, mattressTex, nil, playerObj, vehicle)  or
			menu:updateSliceTsar(getText("ContextMenu_Sleep"), getText("ContextMenu_Sleep"), mattressTex, ISVehicleMenu.onSleep, playerObj, vehicle) then end
		end

		
		if vehicle:getPartById("BatteryHeater") and lightIsOn and inCabin then
			-- print("BatteryHeater")
			local tex = getTexture("media/ui/commonlibrary/UI_temperatureHC.png")
			if (vehicle:getPartById("BatteryHeater"):getModData().temperature or 0) < 0 then
				tex = getTexture("media/ui/vehicles/vehicle_temperatureCOLD.png")
			elseif (vehicle:getPartById("BatteryHeater"):getModData().temperature or 0) > 0 then
				tex = getTexture("media/ui/vehicles/vehicle_temperatureHOT.png")
			end		
			if vehicle:getPartById("BatteryHeater"):getModData().active then
				menu:addSlice(getText("ContextMenu_AirCondOff"), tex, ISCommonMenu.onToggleHeater, playerObj )
			else
				menu:addSlice(getText("ContextMenu_AirCondOn"), tex, ISCommonMenu.onToggleHeater, playerObj )
			end
		end
		
		
		
		if oven and lightIsOn then
			menu:addSlice(getText("IGUI_UseStove"), getTexture("media/ui/Container_Oven"), ISCommonMenu.onStoveSetting, playerObj, vehicle, oven)
			-- if oven:getItemContainer():isActive() then
				-- menu:addSlice(getText("IGUI_Turn_Oven_Off"), getTexture("media/ui/Container_Oven"), ISCommonMenu.ToggleDevice, playerObj, vehicle, oven)
			-- else
				-- menu:addSlice(getText("IGUI_Turn_Oven_On"), getTexture("media/ui/Container_Oven"), ISCommonMenu.ToggleDevice, playerObj, vehicle, oven)
			-- end
		end
		
		if microwave and lightIsOn then
			menu:addSlice(getText("IGUI_UseMicrowave"), getTexture("media/ui/Container_Microwave"), ISCommonMenu.onMicrowaveSetting, playerObj, vehicle, microwave)
			-- if microwave:getItemContainer():isActive() then
				-- menu:addSlice(getText("IGUI_Turn_Oven_Off"), getTexture("media/ui/Container_Microwave"), ISCommonMenu.ToggleMicrowave, playerObj, vehicle, microwave, false)
			-- else
				-- menu:addSlice(getText("IGUI_Turn_Oven_On"), getTexture("media/ui/Container_Microwave"), ISCommonMenu.ToggleMicrowave, playerObj, vehicle, microwave, true)
			-- end
		end
			
		if fridge and lightIsOn then
			-- print(fridge:getModData().tsarslib)
			-- print(fridge:getModData().tsarslib.active)
			if fridge:getModData().tsarslib and fridge:getModData().tsarslib.active then
				menu:addSlice(getText("IGUI_Turn_Fridge_Off"), getTexture("media/ui/Container_Fridge"), ISCommonMenu.ToggleDeviceFridge, playerObj, vehicle, fridge)
			else
				menu:addSlice(getText("IGUI_Turn_Fridge_On"), getTexture("media/ui/Container_Fridge"), ISCommonMenu.ToggleDeviceFridge, playerObj, vehicle, fridge)
			end
		end
		
		if freezer and lightIsOn then
			if freezer:getModData().tsarslib and freezer:getModData().tsarslib.active then
				menu:addSlice(getText("IGUI_Turn_Freezer_Off"), getTexture("media/ui/Container_Freezer"), ISCommonMenu.ToggleDeviceFridge, playerObj, vehicle, freezer)
			else
				menu:addSlice(getText("IGUI_Turn_Freezer_On"), getTexture("media/ui/Container_Freezer"), ISCommonMenu.ToggleDeviceFridge, playerObj, vehicle, freezer)
			end
		end
	end
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

function ISCommonMenu.ToggleMicrowave(playerObj, vehicle, part, on)
	CommonTemplates.Use.Microwave(vehicle, part, playerObj, on)
end

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
			part:setCondition(0)
			vehicle:getEmitter():playSound("BulbSmash")
		else
			local apipart = vehicle:getPartById("HeadlightRearRight")
			local newItem = InventoryItemFactory.CreateItem("Base.LightBulb")
			newItem:setCondition(partCondition)
			apipart:setInventoryItem(newItem, 10)
			partCondition = partCondition - 1
			part:setCondition(partCondition)

			vehicle:getEmitter():playSound("SwitchLamp")
			sendClientCommand(playerObj, 'vehicle', 'setHeadlightsOn', { on = true })
		end
        vehicle:transmitPartCondition(part)
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