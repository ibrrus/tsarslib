ATA2TuningTable = {}

local shaderValues = {
    vehiclewheel = true,
    vehicle = true,
}

-- список металлических предметов для высчитывания веса и добавления "ScrapMetal"
local ATA2TuningItemWeightList = {
    MetalPipe = 1.5,
    MetalBar = 1.5,
    SheetMetal = 1.5,
    SmallSheetMetal = 0.4,
    ScrapMetal = 0.1,
    UnusableMetal = 1,
}

-- список предметов с необычным спавном (болты спавнятся по 5 штук)
ATA2TuningSpecialSpawnCount = {}
ATA2TuningSpecialSpawnCount["Screws"] = 5
ATA2TuningSpecialSpawnCount["Base.Screws"] = 5


local writeFile = nil
if getDebug() then
    writeFile = getFileWriter("console_ata2tuning.txt", true, false)
    Events.OnGameStart.Add(function()
        writeFile:close()
    end)
end

local function logprint(str)
    print(str)
    if writeFile then
        print("WRITE")
        writeFile:write(str .. "\n");
    end
end

local function incorrectType (fieldName, field, correctType)
    if type(field) ~= correctType then
        logprint("---------- ATA2Tuning ERROR|Wrong field: ".. fieldName .. " = ".. tostring(field) .. ". Type must be " .. correctType)
        return true
    end
    return false
end

local function getSoundByTools(toolsTable)
    if toolsTable.primary == "Base.Crowbar" or toolsTable.both == "Base.Crowbar" then
        return "ATA2InstallGeneral"
    elseif toolsTable.bodylocation == "Base.WeldingMask" then
        return "ATA2BlowTorch2"
    elseif toolsTable.primary == "Base.Wrench" or toolsTable.both == "Base.Wrench" then
        return "RepairWithWrench"
    elseif toolsTable.primary == "Base.Hammer" or toolsTable.both == "Base.Hammer" then
        return "ATA2Hammer"
    elseif toolsTable.primary == "Base.Sledgehammer" or toolsTable.both == "Base.Sledgehammer" then
        return "ATA2Sledgehammer"
    elseif toolsTable.primary == "Base.Paintbrush" or toolsTable.secondary == "Base.Paintbrush" then
        return "Painting"
    else
        return "GeneratorRepair"
    end
end

function ATA2Tuning_AddNewCars(carsTable)
    for vehicleName, carTable in pairs(carsTable) do
        local haveError = false
        -- проверка что машина с таким имеем существует
        local scriptManager = getScriptManager()
        local vehileScript = nil
        if scriptManager:getVehicle(vehicleName) then
            logprint("ATA2Tuning|" ..vehicleName .. " is vehicle.")
            vehileScript = scriptManager:getVehicle(vehicleName)
        elseif scriptManager:getVehicleTemplate(vehicleName) then
            logprint("ATA2Tuning|" ..vehicleName .. " is vehicle template.")
            -- vehileScript = scriptManager:getVehicleTemplate(vehicleName):getScript()
        else
            logprint("---------- ATA2Tuning ERROR|" ..vehicleName .. " script not found.")
            haveError = true
        end
        for partName, partTable in pairs(carTable.parts) do
            if vehileScript then
                if vehileScript:getPartById(partName) then
                    logprint("ATA2Tuning|" ..vehicleName .. "|part " .. partName .. " is found.")
                else
                    logprint("---------- ATA2Tuning WARNING|Part not found: ".. partName)
                end
            end
            for modelName, modelTable in pairs(partTable) do
                -- проверка, что шейдер выбран из доступных
                if modelTable.shader and not shaderValues[modelTable.shader] then
                    logprint("---------- ATA2Tuning ERROR|Wrong field: shader = " .. tostring(modelTable.shader) .. ". Only available: vehiclewheel, vehicle")
                    haveError = true
                end
                -- проверка, что спавн задан числом в диапазоне от 0 до 100
                if modelTable.spawnChance then
                    local err = incorrectType("spawnChance", modelTable.spawnChance, "number")
                    haveError = haveError and err
                    if not err then
                        if modelTable.spawnChance < 0 or modelTable.spawnChance > 100 then
                            logprint("---------- ATA2Tuning ERROR|spawnChance must have values between 0 and 100")
                            haveError = true
                        end
                    end
                end
                -- проверка, что параметр задан логическим типом
                if modelTable.hideIfNotValid then
                    haveError = haveError and incorrectType("hideIfNotValid", modelTable.hideIfNotValid, "boolean")
                end
                -- проверка, что иконка задана строкой
                if modelTable.icon then
                    local err = incorrectType("icon", modelTable.icon, "string")
                    haveError = haveError and err
                    -- проверка, что иконка существует
                    if not err and getTexture(modelTable.icon) == nil then
                        logprint("---------- ATA2Tuning ERROR|Icon not found: ".. tostring(modelTable.icon))
                        haveError = true
                    end
                end
                -- проверка, что параметр задан строкой
                if modelTable.name then
                    haveError = haveError and incorrectType("name", modelTable.name, "string")
                end
                -- проверка, что параметр задан строкой
                if modelTable.secondModel then
                    haveError = haveError and incorrectType("secondModel", modelTable.secondModel, "string")
                end

                -- проверка, что параметр задан строкой
                if modelTable.category then
                    haveError = haveError and incorrectType("category", modelTable.category, "string")
                end
                
                if modelTable.containerCapacity then
                    local err = incorrectType("install.containerCapacity", modelTable.containerCapacity, "number")
                    haveError = haveError and err
                    if not err and (modelTable.containerCapacity < 1) then
                        logprint("---------- ATA2Tuning ERROR|modelTable.containerCapacity < 1")
                        haveError = true
                    end
                end
                -- проверяем параметры интерактивного багажника
                if modelTable.interactiveTrunk then
                    local err = incorrectType("interactiveTrunk", modelTable.interactiveTrunk, "table")
                    haveError = haveError and err
                    if not err then
                        for interType, interModelTable in pairs(modelTable.interactiveTrunk) do
                            if interType == "filling" then
                                haveError = haveError and incorrectType("interactiveTrunk.filling", interModelTable, "table")
                            elseif interType == "fillingOnlyOne" then
                                haveError = haveError and incorrectType("interactiveTrunk.fillingOnlyOne", interModelTable, "table")
                            elseif interType == "items" then
                                local err2 = incorrectType("interactiveTrunk.items", interModelTable, "table")
                                haveError = haveError and err2
                                if not err2 then
                                    for _,interItemsTable in ipairs(interModelTable) do
                                        if interItemsTable.itemTypes then
                                            haveError = haveError and incorrectType("interactiveTrunk.items.itemTypes", interItemsTable.itemTypes, "table")
                                        else
                                            logprint("---------- ATA2Tuning ERROR|no obligatory table is specified: interactiveTrunk.items.itemTypes")
                                            haveError = true
                                        end
                                        if interItemsTable.modelNameByCount then
                                            haveError = haveError and incorrectType("interactiveTrunk.items.modelNameByCount", interItemsTable.modelNameByCount, "table")
                                        else
                                            logprint("---------- ATA2Tuning ERROR|no obligatory table is specified: interactiveTrunk.items.modelNameByCount")
                                            haveError = true
                                        end
                                    end
                                end
                            else
                                logprint("---------- ATA2Tuning WARNING|interactiveTrunk has an unknown table: " .. tostring(interType))
                            end
                        end
                    end
                end
                
                -- проверка, что для параметра существует обязательная таблица
                if modelTable.protectionModel and not modelTable.protection then
                     logprint("---------- ATA2Tuning WARNING|protectionModel will not work because there is no 'protection' table")
                end 
                
                -- проверка параметра для задания блокировки открытия окна
                if modelTable.disableOpenWindowForSeat then
                    local err = incorrectType("disableOpenWindowForSeat", modelTable.disableOpenWindowForSeat, "string")
                    haveError = haveError and err
                    -- проверяем, что такая запчасть существует в скрипте
                    if not err and vehileScript then
                        if not vehileScript:getPartById(modelTable.disableOpenWindowForSeat) then
                            logprint("---------- ATA2Tuning WARNING|disableOpenWindowForSeat: part not found: " .. modelTable.disableOpenWindowForSeat)
                        end
                    end
                end
                
                -- проверка, что параметр задан таблицей
                if modelTable.protection then
                    local err = incorrectType("protection", modelTable.protection, "table")
                    haveError = haveError and err
                    if not err and vehileScript then
                        -- проверяем, что список защищаемых элементов есть в скрипте
                        for _, partNameProtection in ipairs(modelTable.protection) do
                            if not vehileScript:getPartById(partNameProtection) then
                                logprint("---------- ATA2Tuning WARNING|protection: part not found: " .. partNameProtection)
                            end
                        end
                    end
                end
                -- проверка, что параметр задан числом
                if modelTable.protectionHealthDelta then
                    local err = incorrectType("protectionHealthDelta", modelTable.protectionHealthDelta, "number")
                    haveError = haveError and err
                    if not err and modelTable.protectionHealthDelta < 0 then
                        haveError = true
                        logprint("---------- ATA2Tuning ERROR|protectionHealthDelta cannot be negative")
                    end
                end
                -- проверка, что параметр задан числом в диапазоне 
                if modelTable.protectionTriger then
                    local err = incorrectType("protectionTriger", modelTable.protectionTriger, "number")
                    haveError = haveError and err
                    if not err and (modelTable.protectionTriger < 20 and modelTable.protectionTriger > 80) then
                        haveError = true
                        logprint("---------- ATA2Tuning ERROR|protectionTriger should be between 20 and 80")
                    end
                end
                -- проверка, что параметр задан логическим типом
                if modelTable.removeIfBroken then
                    haveError = haveError and incorrectType("removeIfBroken", modelTable.removeIfBroken, "boolean")
                end
                
                -- проверка таблицы установки
                if modelTable.install then
                    local err = incorrectType("install", modelTable.install, "table")
                    haveError = haveError and err
                    if not err then
                        local installTable = modelTable.install
                        if installTable.area then
                            local err2 = incorrectType("install.area", installTable.area, "string")
                            haveError = haveError and err2
                            if not err2 and vehileScript then
                                if not vehileScript:getAreaById(installTable.area) then
                                    logprint("---------- ATA2Tuning ERROR|install AREA not found in vehicle script.")
                                    haveError = true
                                end
                            end
                        end
                        if installTable.animation then
                            haveError = haveError and incorrectType("install.animation", installTable.animation, "string")
                        end
                        if installTable.use then
                            local err2 = incorrectType("install.use", installTable.use, "table")
                            haveError = haveError and err2
                            if not err2 then
                                for itemName,count in pairs(installTable.use) do
                                    itemName = itemName:gsub("__", ".")
                                    local item = InventoryItemFactory.CreateItem(itemName)
                                    if not item then
                                        logprint("---------- ATA2Tuning WARNING|install.use: item not found " .. tostring(itemName))
                                    end
                                    -- количество предметов кратно числу спавна
                                    if ATA2TuningSpecialSpawnCount[itemName] then
                                        installTable.use[itemName] = math.ceil(count/ATA2TuningSpecialSpawnCount[itemName]) * ATA2TuningSpecialSpawnCount[itemName]
                                    end
                                end
                            end
                        end
                        if installTable.sound then
                            haveError = haveError and incorrectType("install.sound", installTable.sound, "string")
                        end
                        if installTable.tools then
                            local err2 = incorrectType("install.tools", installTable.tools, "table")
                            haveError = haveError and err2
                            if not err2 then
                                -- проверка, что предметы существуют
                                for _,itemName in pairs(installTable.tools) do
                                    itemName = itemName:gsub("__", ".")
                                    local item = InventoryItemFactory.CreateItem(itemName)
                                    if not item then
                                        logprint("---------- ATA2Tuning WARNING|install.tools: item not found " .. tostring(itemName))
                                    end
                                end
                                -- установка звуков в соответствии с заданными предметами
                                if not installTable.sound then
                                    installTable.sound = getSoundByTools(installTable.tools)
                                end
                            end
                        end
                        if installTable.skills then
                            haveError = haveError and incorrectType("install.skills", installTable.skills, "table")
                        end
                        if installTable.recipes then
                            haveError = haveError and incorrectType("install.recipes", installTable.recipes, "table")
                        end
                        if installTable.requireInstalled then
                            haveError = haveError and incorrectType("install.requireInstalled", installTable.requireInstalled, "table")
                        end
                        
                        -- проверка, что модель существует в таблице
                        if installTable.requireModel then
                            local err = incorrectType("icon", installTable.requireModel, "string")
                            haveError = haveError and err
                            if not err and not partTable[installTable.requireModel] then
                                logprint("---------- ATA2Tuning ERROR|requireModel not found: ".. tostring(installTable.requireModel))
                                haveError = true
                            end
                        end
                        
                        if installTable.requireUninstalled then
                            haveError = haveError and incorrectType("install.requireUninstalled", installTable.requireUninstalled, "table")
                        end
                        if installTable.time then
                            haveError = haveError and incorrectType("install.time", installTable.time, "number")
                        end
                        if installTable.weight == "auto" and installTable.use then
                            local weight = 0
                            for itemName, count in pairs(modelTable.install.use) do
                                if ATA2TuningItemWeightList[itemName] then
                                    weight = weight + ATA2TuningItemWeightList[itemName] * count
                                end
                            end
                            installTable.weight = weight / 2
                        else
                            haveError = haveError and incorrectType("installTable.weight", installTable.weight, "number")
                        end
                    end
                else
                    haveError = true
                    logprint("---------- ATA2Tuning ERROR|modelTable.install mandatory")
                end
                
                -- проверки и обработка таблицы снятия
                if modelTable.uninstall then
                    local err = incorrectType("uninstall", modelTable.uninstall, "table")
                    haveError = haveError and err
                    if not err then
                        local uninstallTable = modelTable.uninstall
                        if uninstallTable.area then
                            local err2 = incorrectType("uninstall.area", uninstallTable.area, "string")
                            haveError = haveError and err2
                            if not err2 and vehileScript then
                                if not vehileScript:getAreaById(uninstallTable.area) then
                                    logprint("---------- ATA2Tuning ERROR|uninstall AREA not found in vehicle script.")
                                    haveError = true
                                end
                            end
                        end
                        if uninstallTable.sound then
                            haveError = haveError and incorrectType("uninstall.sound", uninstallTable.sound, "string")
                        end
                        if uninstallTable.animation then
                            haveError = haveError and incorrectType("uninstall.animation", uninstallTable.animation, "string")
                        end
                        if uninstallTable.use then
                            local err2 = incorrectType("uninstall.use", uninstallTable.use, "table")
                            haveError = haveError and err2
                            if not err2 then
                                for itemName,count in pairs(uninstallTable.use) do
                                    itemName = itemName:gsub("__", ".")
                                    local item = InventoryItemFactory.CreateItem(itemName)
                                    if not item then
                                        logprint("---------- ATA2Tuning WARNING|uninstall.use: item not found " .. tostring(itemName))
                                    end
                                    -- количество предметов кратно числу спавна
                                    if ATA2TuningSpecialSpawnCount[itemName] then
                                        uninstallTable.use[itemName] = math.ceil(count/ATA2TuningSpecialSpawnCount[itemName]) * ATA2TuningSpecialSpawnCount[itemName]
                                    end
                                end
                            end
                        end
                        if uninstallTable.tools then
                            local err2 = incorrectType("uninstall.tools", uninstallTable.tools, "table")
                            haveError = haveError and err2
                            if not err2 then
                                -- проверка, что предметы существуют
                                for _,itemName in pairs(uninstallTable.tools) do
                                    itemName = itemName:gsub("__", ".")
                                    local item = InventoryItemFactory.CreateItem(itemName)
                                    if not item then
                                        logprint("---------- ATA2Tuning WARNING|uninstall.tools: item not found " .. tostring(itemName))
                                    end
                                end
                                -- установка звуков в соответствии с заданными предметами
                                if not uninstallTable.sound then
                                    uninstallTable.sound = getSoundByTools(uninstallTable.tools)
                                end
                            end
                        end
                        if uninstallTable.skills then
                            haveError = haveError and incorrectType("uninstall.skills", uninstallTable.skills, "table")
                        end
                        if uninstallTable.recipes then
                            haveError = haveError and incorrectType("uninstall.recipes", uninstallTable.recipes, "table")
                        end
                        if uninstallTable.requireInstalled then
                            haveError = haveError and incorrectType("uninstall.requireInstalled", uninstallTable.requireInstalled, "table")
                        end
                        if uninstallTable.requireUninstalled then
                            haveError = haveError and incorrectType("uninstall.requireUninstalled", uninstallTable.requireUninstalled, "table")
                        end
                        if uninstallTable.time then
                            haveError = haveError and incorrectType("uninstall.time", uninstallTable.time, "number")
                        end
                        if uninstallTable.result then
                            -- автоматическое составление таблицы с результатом
                            if uninstallTable.result == "auto" and modelTable.install and modelTable.install.use then
                                local newUninstallTable = {}
                                local unusableMetal = 0
                                for itemName, count in pairs(modelTable.install.use) do
                                    if ATA2TuningItemWeightList[itemName] then
                                        if math.floor(count/2) > 0 then 
                                            newUninstallTable[itemName] = math.floor(count/2) 
                                            -- количество предметов разделено на число спавна
                                            if ATA2TuningSpecialSpawnCount[itemName] then
                                                newUninstallTable[itemName] = math.ceil(newUninstallTable[itemName]/ATA2TuningSpecialSpawnCount[itemName])
                                            end
                                        end
                                        unusableMetal = unusableMetal + count/2
                                    end
                                end
                                unusableMetal = math.floor(unusableMetal/2)
                                if unusableMetal > 0 and not newUninstallTable["UnusableMetal"] then newUninstallTable["UnusableMetal"] = unusableMetal end
                                uninstallTable.result = newUninstallTable
                            else
                                local err2 = incorrectType("uninstall.result", uninstallTable.result, "table")
                                haveError = haveError and err2
                                if not err2 then
                                    for itemName,count in pairs(uninstallTable.result) do
                                        itemName = itemName:gsub("__", ".")
                                        local item = InventoryItemFactory.CreateItem(itemName)
                                        if not item then
                                            logprint("---------- ATA2Tuning WARNING|uninstall.result: item not found" .. tostring(itemName))
                                        end
                                        -- количество предметов разделено на число спавна
                                        if ATA2TuningSpecialSpawnCount[itemName] then
                                            uninstallTable.result[itemName] = math.ceil(count/ATA2TuningSpecialSpawnCount[itemName])
                                        end
                                    end
                                end
                            end
                        end
                    end
                else
                    haveError = true
                    logprint("---------- ATA2Tuning ERROR|modelTable.uninstall mandatory!")
                end
            end
        end
        if not haveError then
            ATA2TuningTable[vehicleName] = carTable
            logprint("ATA2Tuning|" ..vehicleName .. " added successfully.")
        else
            logprint("---------- ATA2Tuning ERROR|" ..vehicleName .. " fix the configuration errors!!!")
            error("Fix the configuration errors")
        end
    end
end

local hideBagIfNotValid = true

ATA2TuningTableTemplate = {}
ATA2TuningTableTemplate.Bags = {
    Bag_ShotgunDblSawnoffBag = {
        hideIfNotValid = hideBagIfNotValid,
        icon = "Item_DuffelBagWhite",
        secondModel = "DuffelBagWhite",
        category = "Another",
        containerCapacity = 18,
        install = {
            use = {
                Bag_ShotgunDblSawnoffBag = 1,
            },
            time = 10,
        },
        uninstall = {
            result = {
                Bag_ShotgunDblSawnoffBag = 1,
            },
            time = 10,
        }
    },
    Bag_ShotgunDblBag = {
        hideIfNotValid = hideBagIfNotValid,
        icon = "Item_DuffelBagWhite",
        secondModel = "DuffelBagWhite",
        category = "Another",
        containerCapacity = 18,
        install = {
            use = {
                Bag_ShotgunDblBag = 1,
            },
            time = 10,
        },
        uninstall = {
            result = {
                Bag_ShotgunDblBag = 1,
            },
            time = 10,
        }
    },
    Bag_ShotgunBag = {
        hideIfNotValid = hideBagIfNotValid,
        icon = "Item_DuffelBagWhite",
        secondModel = "DuffelBagWhite",
        category = "Another",
        containerCapacity = 18,
        install = {
            use = {
                Bag_ShotgunBag = 1,
            },
            time = 10,
        },
        uninstall = {
            result = {
                Bag_ShotgunBag = 1,
            },
            time = 10,
        }
    },
    Bag_ShotgunSawnoffBag = {
        hideIfNotValid = hideBagIfNotValid,
        icon = "Item_DuffelBagWhite",
        secondModel = "DuffelBagWhite",
        category = "Another",
        containerCapacity = 18,
        install = {
            use = {
                Bag_ShotgunSawnoffBag = 1,
            },
            time = 10,
        },
        uninstall = {
            result = {
                Bag_ShotgunSawnoffBag = 1,
            },
            time = 10,
        }
    },
    Bag_SurvivorBag = {
        hideIfNotValid = hideBagIfNotValid,
        icon = "Item_AliceBag",
        secondModel = "ALICEpack",
        category = "Another",
        containerCapacity = 27,
        install = {
            use = {
                Bag_SurvivorBag = 1,
            },
            time = 10,
        },
        uninstall = {
            result = {
                Bag_SurvivorBag = 1,
            },
            time = 10,
        }
    },
    Bag_ALICEpack = {
        hideIfNotValid = hideBagIfNotValid,
        icon = "Item_AliceBag",
        secondModel = "ALICEpack",
        category = "Another",
        containerCapacity = 27,
        install = {
            use = {
                Bag_ALICEpack = 1,
            },
            time = 10,
        },
        uninstall = {
            result = {
                Bag_ALICEpack = 1,
            },
            time = 10,
        }
    },
    Bag_ALICEpack_Army = {
        hideIfNotValid = hideBagIfNotValid,
        icon = "Item_AliceBag_Camo",
        secondModel = "ALICEpack_Army",
        category = "Another",
        containerCapacity = 28,
        install = {
            use = {
                Bag_ALICEpack_Army = 1,
            },
            time = 10,
        },
        uninstall = {
            result = {
                Bag_ALICEpack_Army = 1,
            },
            time = 10,
        }
    },
    Bag_BigHikingBag = {
        hideIfNotValid = hideBagIfNotValid,
        icon = "Item_BigHiking_Green",
        secondModel = "BigHikingBag",
        category = "Another",
        containerCapacity = 22,
        install = {
            use = {
                Bag_BigHikingBag = 1,
            },
            time = 10,
        },
        uninstall = {
            result = {
                Bag_BigHikingBag = 1,
            },
            time = 10,
        }
    },
    Bag_NormalHikingBag = {
        hideIfNotValid = hideBagIfNotValid,
        icon = "Item_Hiking_Blue",
        secondModel = "NormalHikingBag",
        category = "Another",
        containerCapacity = 20,
        install = {
            use = {
                Bag_NormalHikingBag = 1,
            },
            time = 10,
        },
        uninstall = {
            result = {
                Bag_NormalHikingBag = 1,
            },
            time = 10,
        }
    },
    Bag_DuffelBagTINT = {
        hideIfNotValid = hideBagIfNotValid,
        icon = "Item_DuffelBag_Grey",
        secondModel = "DuffelBagGrey",
        category = "Another",
        containerCapacity = 18,
        install = {
            use = {
                Bag_DuffelBagTINT = 1,
            },
            time = 10,
        },
        uninstall = {
            result = {
                Bag_DuffelBagTINT = 1,
            },
            time = 10,
        }
    },
    Bag_InmateEscapedBag = {
        hideIfNotValid = hideBagIfNotValid,
        icon = "Item_DuffelBag_Green",
        secondModel = "DuffelBagGreen",
        category = "Another",
        containerCapacity = 18,
        install = {
            use = {
                Bag_InmateEscapedBag = 1,
            },
            time = 10,
        },
        uninstall = {
            result = {
                Bag_InmateEscapedBag = 1,
            },
            time = 10,
        }
    },
    Bag_WorkerBag = {
        hideIfNotValid = hideBagIfNotValid,
        icon = "Item_DuffelBagWhite",
        secondModel = "DuffelBagBlue",
        category = "Another",
        containerCapacity = 18,
        install = {
            use = {
                Bag_WorkerBag = 1,
            },
            time = 10,
        },
        uninstall = {
            result = {
                Bag_WorkerBag = 1,
            },
            time = 10,
        }
    },
    Bag_WeaponBag = {
        hideIfNotValid = hideBagIfNotValid,
        icon = "Item_DuffelBag_Green",
        secondModel = "DuffelBagGreen",
        category = "Another",
        containerCapacity = 18,
        install = {
            use = {
                Bag_WeaponBag = 1,
            },
            time = 10,
        },
        uninstall = {
            result = {
                Bag_WeaponBag = 1,
            },
            time = 10,
        }
    },
    Bag_DuffelBag = {
        hideIfNotValid = hideBagIfNotValid,
        icon = "Item_DuffelBag_Grey",
        secondModel = "DuffelBagGrey",
        category = "Another",
        containerCapacity = 18,
        install = {
            use = {
                Bag_DuffelBag = 1,
            },
            time = 10,
        },
        uninstall = {
            result = {
                Bag_DuffelBag = 1,
            },
            time = 10,
        }
    },
    Bag_MoneyBag = {
        hideIfNotValid = hideBagIfNotValid,
        icon = "Item_DuffelBagWhite",
        secondModel = "DuffelBagBlue",
        category = "Another",
        containerCapacity = 18,
        install = {
            use = {
                Bag_MoneyBag = 1,
            },
            time = 10,
        },
        uninstall = {
            result = {
                Bag_MoneyBag = 1,
            },
            time = 10,
        }
    },
    Bag_GolfBag = {
        hideIfNotValid = hideBagIfNotValid,
        icon = "Item_GolfBag_Red",
        secondModel = "GolfBag",
        category = "Another",
        containerCapacity = 18,
        install = {
            use = {
                Bag_GolfBag = 1,
            },
            time = 10,
        },
        uninstall = {
            result = {
                Bag_GolfBag = 1,
            },
            time = 10,
        }
    },
    Bag_Schoolbag = {
        hideIfNotValid = hideBagIfNotValid,
        icon = "Item_Backpack_Spiffo",
        secondModel = "Schoolbag",
        category = "Another",
        containerCapacity = 15,
        install = {
            use = {
                Bag_Schoolbag = 1,
            },
            time = 10,
        },
        uninstall = {
            result = {
                Bag_Schoolbag = 1,
            },
            time = 10,
        }
    },
}