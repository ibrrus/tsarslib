-- tsarZonesSupportMapList = {} 
-- table.insert(tsarZonesSupportMapList, "media/mapszones/Muldraugh, KY/tsarzones.lua")
globalTsarZones = {}

function loadTsarZone(file, tableName)
    if fileExists(file) then
        globalTsarZones[tableName] = {}
        reloadLuaFile(file)
        for _,v in ipairs(globalTsarZones[tableName]) do
            local vzone = getWorld():registerVehiclesZone(v.name, v.type, v.x, v.y, v.z, v.width, v.height, v.properties)
            if vzone == nil then
                getWorld():registerZone(v.name, v.type, v.x, v.y, v.z, v.width, v.height)
            end
            table.wipe(v)
        end
        globalTsarZones[tableName] = {}
    else
        print('can\'t find map tsarzones file: '..file)
    end
    getWorld():checkVehiclesZones();
end

Events.OnLoadMapZones.Add(function()
    loadTsarZone("media/mapszones/Muldraugh, KY/tsarzones.lua", "bigtrailer")
end);