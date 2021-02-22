ISVehicleMechanics.OnMechanicActionDone = function(chr, success, vehicleId, partId, itemId, installing)
	if success and itemId ~= -1 then
		local vehicle = getVehicleById(vehicleId);
		if not vehicle then noise('no such vehicle ' .. vehicleId); return; end
		local part = vehicle:getPartById(partId);
		if not part then noise('no such part in vehicle ' .. partId); return; end
		if installing then
			chr:addMechanicsItem(itemId .. vehicle:getMechanicalID() .. "1", part, getGameTime():getCalender():getTimeInMillis());
			
			local invItem = VehicleUtils.createPartInventoryItem(part)
			local text2 = invItem:getType()
			-- print( text2 )
			--getPlayer():Say( text2, 1.0, 1.0, 0.0, UIFont.Dialogue, 30.0, "radio" )
			if text2 == "HamRadio1" or text2 == "HamRadio2" or text2 == "RadioRed" or text2 == "RadioBlack" or text2 == "TvAntique" or text2 == "TvWideScreen" or text2 == "TvBlack" then
				--getPlayer():Say( "Radio!!!!", 1.0, 1.0, 0.0, UIFont.Dialogue, 30.0, "radio" )				
				local deviceData = part:createSignalDevice()deviceData:setIsTwoWay( invItem:getDeviceData():getIsTwoWay() )
				deviceData:setTransmitRange( invItem:getDeviceData():getTransmitRange() )
				deviceData:setMicRange( invItem:getDeviceData():getMicRange() )
				deviceData:setBaseVolumeRange( invItem:getDeviceData():getBaseVolumeRange() )
				deviceData:setIsTelevision( invItem:getDeviceData():getIsTelevision() )
				deviceData:setMinChannelRange( invItem:getDeviceData():getMinChannelRange() )
				deviceData:setMaxChannelRange( invItem:getDeviceData():getMaxChannelRange() )
			end
		else
			chr:addMechanicsItem(itemId .. vehicle:getMechanicalID() .. "0", part, getGameTime():getCalender():getTimeInMillis());
		end
	end
	
	local ui = getPlayerMechanicsUI(chr:getPlayerNum());
	if ui and ui:isReallyVisible() then
		if success then ui:startFlashGreen()
		else ui:startFlashRed() end
	end
	
	-- Give some exp if you fail
	if not success then
		chr:getXp():AddXP(Perks.Mechanics, 1);
	end
end

