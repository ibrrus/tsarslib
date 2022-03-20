function doAgroMapZones()
-- print("doAgroMapZones")
	local dirs = getLotDirectories()
    for i=dirs:size(),1,-1 do
        local file = 'media/mapszones/'..dirs:get(i-1)..'/tsarzones.lua'
        if fileExists(file) then
			-- print("doAgroMapZones fileExists")
			tsarzones = {}
            reloadLuaFile(file)
			for k,v in ipairs(tsarzones) do
				if v.type == "Mannequin" then
					handleMannequinZone(file, v)
				elseif v.type == "SpawnOrigin" then
					handleSpawnOrigin(file, v)
				elseif v.type == "WaterFlow" then
					handleWaterFlow(file, v)
				elseif v.type == "WaterZone" then
					handleWaterZone(file, v)
				elseif v.geometry ~= nil then
					if tonumber(v.lineWidth) then
						v.properties = v.properties or {}
						v.properties.LineWidth = v.lineWidth
					end
					getWorld():getMetaGrid():registerGeometryZone(v.name, v.type, v.z, v.geometry, v.points, v.properties)
				else
					local vzone = getWorld():registerVehiclesZone(v.name, v.type, v.x, v.y, v.z, v.width, v.height, v.properties)
					-- print("doAgroMapZones vzone")
					-- print(vzone)
					if vzone == nil then
						getWorld():registerZone(v.name, v.type, v.x, v.y, v.z, v.width, v.height)
					end
				end
				table.wipe(v)
			end
			table.wipe(tsarzones)
		else
			print('can\'t find map tsarzones file: '..file)
		end
		getWorld():checkVehiclesZones();
	end
end

Events.OnLoadMapZones.Add(doAgroMapZones);