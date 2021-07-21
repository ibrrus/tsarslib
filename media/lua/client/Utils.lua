function unsupported_mods_off()
	if getActivatedMods():contains("vehicle_additions") then
		toggleModActive(getModInfoByID("vehicle_additions"), false)
	end
	-- if getActivatedMods():contains("FuelTanker") then
		-- toggleModActive(getModInfoByID("FuelTanker"), false)
	-- end
end

function unsupported_mods_sleep()
	if ActiveMods.getById("currentGame"):isModActive("vehicle_additions") or 
			ActiveMods.getById("currentGame"):isModActive("some_trucks_have_gun_racks") or 
			ActiveMods.getById("currentGame"):isModActive("Siphoning Needs Hoses") then
		ActiveMods.getById("currentGame"):removeMod("vehicle_additions")
		ActiveMods.getById("currentGame"):removeMod("some_trucks_have_gun_racks")
		ActiveMods.getById("currentGame"):removeMod("Siphoning Needs Hoses")
		saveGame()
		arr = getLatestSave()
		pathToSave = arr[2] .. "\\" .. arr[1]
		manipulateSavefile(pathToSave,"WriteModsDotTxt")
	end
	
	-- if ActiveMods.getById("currentGame"):isModActive("FuelTanker") then
		-- --print("TSARCRAFT OFF")
		-- ActiveMods.getById("currentGame"):removeMod("FuelTanker")
		-- saveGame()
		-- arr = getLatestSave()
		-- pathToSave = arr[2] .. "\\" .. arr[1]
		-- manipulateSavefile(pathToSave,"WriteModsDotTxt")
	-- end
end

-- function require_mods_on()
	-- if not ActiveMods.getById("currentGame"):isModActive("tsarslib") then
		-- ActiveMods.getById("currentGame"):setModActive("tsarslib", true)
		-- saveGame()
		-- arr = getLatestSave()
		-- pathToSave = arr[2] .. "\\" .. arr[1]
		-- manipulateSavefile(pathToSave,"WriteModsDotTxt")
	-- end
-- end

-- Events.OnGameBoot.Add(unsupported_mods_off)
-- Events.OnGameStart.Add(unsupported_mods_sleep)
-- Events.OnGameStart.Add(require_mods_on)
