local transportAppliance = {}

transportAppliance["fixtures_bathroom_01_28"] = {"TransportMedicine",}
transportAppliance["fixtures_bathroom_01_29"] = {"TransportMedicine",}
transportAppliance["fixtures_bathroom_01_28"] = {"TransportMedicine",}
transportAppliance["fixtures_bathroom_01_37"] = {"TransportMedicine",}
transportAppliance["fixtures_bathroom_01_38"] = {"TransportMedicine",}

transportAppliance["appliances_cooking_01_0"] = {"TransportOven",}
transportAppliance["appliances_cooking_01_1"] = {"TransportOven",}
transportAppliance["appliances_cooking_01_2"] = {"TransportOven",}
transportAppliance["appliances_cooking_01_3"] = {"TransportOven",}
transportAppliance["appliances_cooking_01_4"] = {"TransportOven",}
transportAppliance["appliances_cooking_01_5"] = {"TransportOven",}
transportAppliance["appliances_cooking_01_6"] = {"TransportOven",}
transportAppliance["appliances_cooking_01_7"] = {"TransportOven",}
transportAppliance["appliances_cooking_01_8"] = {"TransportOven",}
transportAppliance["appliances_cooking_01_9"] = {"TransportOven",}
transportAppliance["appliances_cooking_01_10"] = {"TransportOven",}
transportAppliance["appliances_cooking_01_11"] = {"TransportOven",}
transportAppliance["appliances_cooking_01_12"] = {"TransportOven",}
transportAppliance["appliances_cooking_01_13"] = {"TransportOven",}
transportAppliance["appliances_cooking_01_14"] = {"TransportOven",}
transportAppliance["appliances_cooking_01_15"] = {"TransportOven",}

transportAppliance["appliances_cooking_01_20"] = {"TransportOven",}
transportAppliance["appliances_cooking_01_21"] = {"TransportOven",}
transportAppliance["appliances_cooking_01_22"] = {"TransportOven",}
transportAppliance["appliances_cooking_01_23"] = {"TransportOven",}

transportAppliance["appliances_cooking_01_24"] = {"TransportMicrowave",}
transportAppliance["appliances_cooking_01_25"] = {"TransportMicrowave",}
transportAppliance["appliances_cooking_01_26"] = {"TransportMicrowave",}
transportAppliance["appliances_cooking_01_27"] = {"TransportMicrowave",}
transportAppliance["appliances_cooking_01_28"] = {"TransportMicrowave",}
transportAppliance["appliances_cooking_01_29"] = {"TransportMicrowave",}
transportAppliance["appliances_cooking_01_30"] = {"TransportMicrowave",}
transportAppliance["appliances_cooking_01_31"] = {"TransportMicrowave",}


transportAppliance["appliances_refrigeration_01_0"] = {"TransportFridge", "TransportFreezer"}
transportAppliance["appliances_refrigeration_01_1"] = {"TransportFridge", "TransportFreezer"}
transportAppliance["appliances_refrigeration_01_2"] = {"TransportFridge", "TransportFreezer"}
transportAppliance["appliances_refrigeration_01_3"] = {"TransportFridge", "TransportFreezer"}
transportAppliance["appliances_refrigeration_01_4"] = {"TransportFridge", "TransportFreezer"}
transportAppliance["appliances_refrigeration_01_5"] = {"TransportFridge", "TransportFreezer"}
transportAppliance["appliances_refrigeration_01_6"] = {"TransportFridge", "TransportFreezer"}
transportAppliance["appliances_refrigeration_01_7"] = {"TransportFridge", "TransportFreezer"}
transportAppliance["appliances_refrigeration_01_8"] = {"TransportFridge", "TransportFreezer"}
transportAppliance["appliances_refrigeration_01_9"] = {"TransportFridge", "TransportFreezer"}
transportAppliance["appliances_refrigeration_01_10"] = {"TransportFridge", "TransportFreezer"}
transportAppliance["appliances_refrigeration_01_11"] = {"TransportFridge", "TransportFreezer"}
transportAppliance["appliances_refrigeration_01_12"] = {"TransportFridge", "TransportFreezer"}
transportAppliance["appliances_refrigeration_01_13"] = {"TransportFridge", "TransportFreezer"}
transportAppliance["appliances_refrigeration_01_14"] = {"TransportFridge", "TransportFreezer"}
transportAppliance["appliances_refrigeration_01_15"] = {"TransportFridge", "TransportFreezer"}

transportAppliance["appliances_refrigeration_01_22"] = {"TransportFridge", "TransportFreezer"}
transportAppliance["appliances_refrigeration_01_23"] = {"TransportFridge", "TransportFreezer"}
transportAppliance["appliances_refrigeration_01_24"] = {"TransportFridge", "TransportFreezer"}
transportAppliance["appliances_refrigeration_01_25"] = {"TransportFridge", "TransportFreezer"}
transportAppliance["appliances_refrigeration_01_26"] = {"TransportFridge", "TransportFreezer"}
transportAppliance["appliances_refrigeration_01_27"] = {"TransportFridge", "TransportFreezer"}
transportAppliance["appliances_refrigeration_01_28"] = {"TransportFridge", "TransportFreezer"}
transportAppliance["appliances_refrigeration_01_29"] = {"TransportFridge", "TransportFreezer"}
transportAppliance["appliances_refrigeration_01_30"] = {"TransportFridge", "TransportFreezer"}
transportAppliance["appliances_refrigeration_01_31"] = {"TransportFridge", "TransportFreezer"}
transportAppliance["appliances_refrigeration_01_32"] = {"TransportFridge", "TransportFreezer"}
transportAppliance["appliances_refrigeration_01_33"] = {"TransportFridge", "TransportFreezer"}
transportAppliance["appliances_refrigeration_01_34"] = {"TransportFridge", "TransportFreezer"}
transportAppliance["appliances_refrigeration_01_35"] = {"TransportFridge", "TransportFreezer"}
transportAppliance["appliances_refrigeration_01_36"] = {"TransportFridge", "TransportFreezer"}
transportAppliance["appliances_refrigeration_01_37"] = {"TransportFridge", "TransportFreezer"}

transportAppliance["appliances_refrigeration_01_40"] = {"TransportFridge", "TransportFreezer"}
transportAppliance["appliances_refrigeration_01_41"] = {"TransportFridge", "TransportFreezer"}
transportAppliance["appliances_refrigeration_01_42"] = {"TransportFridge", "TransportFreezer"}
transportAppliance["appliances_refrigeration_01_43"] = {"TransportFridge", "TransportFreezer"}


ISInventoryMenuElements = ISInventoryMenuElements or {};

function ISInventoryMenuElements.TCContextMovable()
    local self 					= ISMenuElement.new();
    self.invMenu			    = ISContextManager.getInstance().getInventoryMenu();

    function self.init()
    end

    function self.createMenu( _item )
        if instanceof(_item, "Moveable") then
            if _item:getContainer() ~= self.invMenu.inventory then
                return;
            end
            if self.invMenu.player:getPrimaryHandItem() ~= _item and self.invMenu.player:getSecondaryHandItem() ~= _item then
				if transportAppliance[_item:getWorldSprite()] then
                    for _, newItemName in ipairs(transportAppliance[_item:getWorldSprite()]) do
                        self.invMenu.context:addOption(getText("ContextMenu_TCConvertAppliance", InventoryItemFactory.CreateItem(newItemName):getName()), self.invMenu, self.createTransportItem, _item, newItemName);
                    end
                end                
            end
        end
    end

    function self.createTransportItem( _p, _item, newItemName )
        ISTimedActionQueue.add(TCISConvertAppliance:new(_p.player, _item, newItemName, 1000))
    end
    return self;
end

