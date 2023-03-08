ATA2TuningTable = {}

local shaderValues = {
    vehiclewheel = true,
    vehicle = true,
}

ATA2TuningAutoUninstallList = {
    MetalPipe = true,
    MetalBar = true,
    SheetMetal = true,
    Screws = true,
    SmallSheetMetal = true,
    ScrapMetal = true,
    UnusableMetal = true,
}

local function incorrectType (fieldName, field, correctType)
    if type(field) ~= correctType then
        print("---------- ATA2Tuning ERROR|Wrong field: ".. fieldName .. " = ".. tostring(field) .. ". Type must be " .. correctType)
        return true
    end
    return false
end

function ATA2Tuning_AddNewCars(carsTable)
    for vehicleName, carTable in pairs(carsTable) do
        local haveError = false
        -- проверка что машина с таким имеем существует
        local scriptManager = getScriptManager()
        local vehileScript = nil
        if scriptManager:getVehicle(vehicleName) then
            print("ATA2Tuning|" ..vehicleName .. " is vehicle.")
            vehileScript = scriptManager:getVehicle(vehicleName)
        elseif scriptManager:getVehicleTemplate(vehicleName) then
            print("ATA2Tuning|" ..vehicleName .. " is vehicle template.")
            -- vehileScript = scriptManager:getVehicleTemplate(vehicleName):getScript()
        else
            print("---------- ATA2Tuning ERROR|" ..vehicleName .. " script not found.")
            haveError = true
        end
        for partName, partTable in pairs(carTable.parts) do
            if vehileScript then
                if vehileScript:getPartById(partName) then
                    print("ATA2Tuning|" ..vehicleName .. "|part " .. partName .. " is found.")
                else
                    print("---------- ATA2Tuning WARNING|Part not found: ".. partName)
                end
            end
            for modelName, modelTable in pairs(partTable) do
                -- проверка, что шейдер выбран из доступных
                if modelTable.shader and not shaderValues[modelTable.shader] then
                    print("---------- ATA2Tuning ERROR|Wrong field: shader = " .. tostring(modelTable.shader) .. ". Only available: vehiclewheel, vehicle")
                    haveError = true
                end
                -- проверка, что спавн задан числом в диапазоне от 0 до 100
                if modelTable.spawnChance then
                    local err = incorrectType("spawnChance", modelTable.spawnChance, "number")
                    haveError = haveError and err
                    if not err then
                        if modelTable.spawnChance < 0 or modelTable.spawnChance > 100 then
                            print("---------- ATA2Tuning ERROR|spawnChance must have values between 0 and 100")
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
                        print("---------- ATA2Tuning ERROR|Icon not found: ".. tostring(modelTable.icon))
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
                                            print("---------- ATA2Tuning ERROR|no obligatory table is specified: interactiveTrunk.items.itemTypes")
                                            haveError = true
                                        end
                                        if interItemsTable.modelNameByCount then
                                            haveError = haveError and incorrectType("interactiveTrunk.items.modelNameByCount", interItemsTable.modelNameByCount, "table")
                                        else
                                            print("---------- ATA2Tuning ERROR|no obligatory table is specified: interactiveTrunk.items.modelNameByCount")
                                            haveError = true
                                        end
                                    end
                                end
                            else
                                print("---------- ATA2Tuning WARNING|interactiveTrunk has an unknown table: " .. tostring(interType))
                            end
                        end
                    end
                end
                -- проверка, что для параметра существует обязательная таблица
                if modelTable.protectionModel and not modelTable.protection then
                     print("---------- ATA2Tuning WARNING|protectionModel will not work because there is no 'protection' table")
                end 
                -- проверка, что параметр задан таблицей
                if modelTable.protection then
                    local err = incorrectType("protection", modelTable.protection, "table")
                    haveError = haveError and err
                    if not err and vehileScript then
                        -- проверяем, что список защищаемых элементов есть в скрипте
                        for _, partNameProtection in ipairs(modelTable.protection) do
                            if not vehileScript:getPartById(partNameProtection) then
                                print("---------- ATA2Tuning WARNING|protection: part not found: " .. partNameProtection)
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
                        print("---------- ATA2Tuning ERROR|protectionHealthDelta cannot be negative")
                    end
                end
                -- проверка, что параметр задан числом в диапазоне 
                if modelTable.protectionTriger then
                    local err = incorrectType("protectionTriger", modelTable.protectionTriger, "number")
                    haveError = haveError and err
                    if not err and (modelTable.protectionTriger < 20 and modelTable.protectionTriger > 80) then
                        haveError = true
                        print("---------- ATA2Tuning ERROR|protectionTriger should be between 20 and 80")
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
                                    print("---------- ATA2Tuning ERROR|install AREA not found in vehicle script.")
                                    haveError = true
                                end
                            end
                        end
                        if installTable.sound then
                            haveError = haveError and incorrectType("install.sound", installTable.sound, "string")
                        end
                        if installTable.animation then
                            haveError = haveError and incorrectType("install.animation", installTable.animation, "string")
                        end
                        if installTable.use then
                            haveError = haveError and incorrectType("install.use", installTable.use, "table")
                        end
                        if installTable.tools then
                            haveError = haveError and incorrectType("install.tools", installTable.tools, "table")
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
                        if installTable.requireUninstalled then
                            haveError = haveError and incorrectType("install.requireUninstalled", installTable.requireUninstalled, "table")
                        end
                        if installTable.time then
                            haveError = haveError and incorrectType("install.time", installTable.time, "number")
                        end
                    end
                else
                    haveError = true
                    print("---------- ATA2Tuning ERROR|modelTable.install mandatory")
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
                                    print("---------- ATA2Tuning ERROR|uninstall AREA not found in vehicle script.")
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
                            haveError = haveError and incorrectType("uninstall.use", uninstallTable.use, "table")
                        end
                        if uninstallTable.tools then
                            haveError = haveError and incorrectType("uninstall.tools", uninstallTable.tools, "table")
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
                                    if ATA2TuningAutoUninstallList[itemName] then
                                        if math.floor(count/2) > 0 then newUninstallTable[itemName] = math.floor(count/2) end
                                        unusableMetal = unusableMetal + count/2
                                    end
                                end
                                unusableMetal = math.floor(unusableMetal/2)
                                if unusableMetal > 0 and not newUninstallTable["UnusableMetal"] then newUninstallTable["UnusableMetal"] = unusableMetal end
                                uninstallTable.result = newUninstallTable
                            else
                                haveError = haveError and incorrectType("uninstall.result", uninstallTable.result, "number")
                            end
                        end
                    end
                else
                    haveError = true
                    print("---------- ATA2Tuning ERROR|modelTable.uninstall mandatory!")
                end
            end
        end
        if not haveError then
            ATA2TuningTable[vehicleName] = carTable
            print("ATA2Tuning|" ..vehicleName .. " added successfully.")
        else
            print("---------- ATA2Tuning ERROR|" ..vehicleName .. " fix the configuration errors!!!")
            error("Fix the configuration errors")
        end
    end
end

local hideBagIfNotValid = true

ATA2TuningTableTemplate = {}
ATA2TuningTableTemplate.Bags = {
    Bag_ShotgunDblSawnoffBag = {
        hideIfNotValid = hideBagIfNotValid,
        texture = "Item_DuffelBagWhite",
        secondModel = "DuffelBagWhite",
        category = "Another",
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
        texture = "Item_DuffelBagWhite",
        secondModel = "DuffelBagWhite",
        category = "Another",
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
        texture = "Item_DuffelBagWhite",
        secondModel = "DuffelBagWhite",
        category = "Another",
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
        texture = "Item_DuffelBagWhite",
        secondModel = "DuffelBagWhite",
        category = "Another",
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
        texture = "Item_AliceBag",
        secondModel = "ALICEpack",
        category = "Another",
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
        texture = "Item_AliceBag",
        secondModel = "ALICEpack",
        category = "Another",
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
        texture = "Item_AliceBag_Camo",
        secondModel = "ALICEpack_Army",
        category = "Another",
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
        texture = "Item_BigHiking_Green",
        secondModel = "BigHikingBag",
        category = "Another",
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
        texture = "Item_Hiking_Blue",
        secondModel = "NormalHikingBag",
        category = "Another",
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
        texture = "Item_DuffelBag_Grey",
        secondModel = "DuffelBagGrey",
        category = "Another",
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
        texture = "Item_DuffelBag_Green",
        secondModel = "DuffelBagGreen",
        category = "Another",
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
        texture = "Item_DuffelBagWhite",
        secondModel = "DuffelBagBlue",
        category = "Another",
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
        texture = "Item_DuffelBag_Green",
        secondModel = "DuffelBagGreen",
        category = "Another",
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
        texture = "Item_DuffelBag_Grey",
        secondModel = "DuffelBagGrey",
        category = "Another",
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
        texture = "Item_DuffelBagWhite",
        secondModel = "DuffelBagBlue",
        category = "Another",
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
        texture = "Item_GolfBag_Red",
        secondModel = "GolfBag",
        category = "Another",
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
        texture = "Item_Backpack_Spiffo",
        secondModel = "Schoolbag",
        category = "Another",
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