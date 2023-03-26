require "ISUI/ISCollapsableWindow"
require "ATA2TuningTable"

ISVehicleTuning2 = ISCollapsableWindow:derive("ISVehicleTuning2");
ISVehicleTuning2.instance = nil
ISVehicleTuning2.largeFontHeight = getTextManager():getFontHeight(UIFont.Large)
ISVehicleTuning2.mediumFontHeight = getTextManager():getFontHeight(UIFont.Medium)
ISVehicleTuning2.smallFontHeight = getTextManager():getFontHeight(UIFont.Small)
ISVehicleTuning2.bottomInfoHeight = ISVehicleTuning2.smallFontHeight * 2
ISVehicleTuning2.qwertyConfiguration = true
ISVehicleTuning2.bottomTextSpace = "     ";
ISVehicleTuning2.leftCategory = Keyboard.KEY_LEFT
ISVehicleTuning2.rightCategory = Keyboard.KEY_RIGHT
ISVehicleTuning2.upArrow = Keyboard.KEY_UP
ISVehicleTuning2.downArrow = Keyboard.KEY_DOWN

-- Создание объекта для тюнинг-меню
function ISVehicleTuning2:new (x, y, width, height, character, vehicle)
    local o = {};
    if x == 0 and y == 0 then
       x = (getCore():getScreenWidth() / 2) - (width / 2);
       y = (getCore():getScreenHeight() / 2) - (height / 2);
    end
    o = ISCollapsableWindow:new(x, y, width, height);
    o.minimumWidth = 800
    o.minimumHeight = 700
    setmetatable(o, self);
    if getCore():getKey("Forward") ~= 44 then -- hack, seriously, need a way to detect qwert/azerty keyboard :(
        ISVehicleTuning2.qwertyConfiguration = false
    end

    o.LabelDash = "-"
    o.LabelDashWidth = getTextManager():MeasureStringX(UIFont.Small, o.LabelDash)
    o.LabelInstall = getText("IGUI_TuningUI_Install")
    o.LabelUninstall = getText("IGUI_TuningUI_Uninstall")
    o.LabelAddIngredient = getText("IGUI_CraftUI_ButtonAddIngredient")
    o.LabelClose = getText("IGUI_CraftUI_Close")
    
    o.bottomInfoText1 = getText("IGUI_CraftUI_Controls1",
        getKeyName(ISVehicleTuning2.upArrow), getKeyName(ISVehicleTuning2.downArrow),
        getKeyName(ISVehicleTuning2.leftCategory), getKeyName(ISVehicleTuning2.rightCategory));
    
    o.bottomInfoText2 = getText("IGUI_CraftUI_Controls2",
        getKeyName(ISVehicleTuning2.upArrow), getKeyName(ISVehicleTuning2.downArrow),
        getKeyName(ISVehicleTuning2.leftCategory), getKeyName(ISVehicleTuning2.rightCategory));

    o.title = getText("IGUI_TuningUI_Title");
    self.__index = self
    o.character = character
    o.vehicle = vehicle
    o.playerNum = character and character:getPlayerNum() or -1
    o:setResizable(true);
    o.lineH = 10
    o.fgBar = {r=0, g=0.6, b=0, a=0.7 }
    o.craftInProgress = false
    o.selectedIndex = {}
    o.recipeListHasFocus = true
    o.ingredientPanelHasFocus = false
    o.toolsPanelHasFocus = false
    o.resultPanelHasFocus = false
    o.TreeExpanded = getTexture("media/ui/TreeExpanded.png")
    o.PoisonTexture = getTexture("media/ui/SkullPoison.png")
    o:setWantKeyEvents(true);
    return o
end


function ISVehicleTuning2:initialise()
    ISCollapsableWindow.initialise(self);
end

function ISVehicleTuning2:setVisible(bVisible, joypadData)
-- print("ISVehicleTuning2:setVisible")
    if self.javaObject == nil then
        self:instantiate();
    end
    self.javaObject:setVisible(bVisible)
    self.javaObject:setEnabled(bVisible)
    
    if not bVisible then -- save the selected index
        self.selectedIndex = {};
        for i,v in ipairs(self.categories) do
            self.selectedIndex[v.category] = v.recipes.selected
        end
    end
--    if getPlayer() then
--        self.character:setBlockMovement(bVisible);
--    end
    if bVisible and self.recipesList then
        self:refresh();
    end
    
    if bVisible and joypadData then
		joypadData.focus = self
		updateJoypadFocus(joypadData)
	end
    
    -- load saved selected index
    if bVisible then
        for i,v in ipairs(self.categories) do
            if self.selectedIndex[v.category] then
                v.recipes.selected = self.selectedIndex[v.category];
            end
        end
    end

    self.craftInProgress = false
    local recipeListBox = self:getRecipeListBox()
    recipeListBox:ensureVisible(recipeListBox.selected);
end


function ISVehicleTuning2:createChildren()
    -- print("ISVehicleTuning2:createChildren")
    ISCollapsableWindow.createChildren(self);
    local th = self:titleBarHeight();
    local rh = self.resizable and self:resizeWidgetHeight() or 0
    self.panel = ISTabPanel:new(0, th, self.width, self.height-th-rh-ISVehicleTuning2.bottomInfoHeight);
    self.panel:initialise();
    self.panel:setAnchorRight(true)
    self.panel:setAnchorBottom(true)
    self.panel.borderColor = { r = 0, g = 0, b = 0, a = 0};
    self.panel.onActivateView = ISVehicleTuning2.onActivateView
    self.panel.target = self
    self.panel:setEqualTabWidth(false)
    self:addChild(self.panel);
--    self.panel:setOnTabTornOff(self, ISVehicleTuning2.onTabTornOff)

    -- populate all the recipes, splitted in categories
    self:populateRecipesList();
    self.categories = {};
    local k
    for k = 1 , #self.recipesListH, 1 do
        local i = self.recipesListH[k]
        local l = self.recipesList[i]
    --for i,l in pairs(self.recipesList) do
        -- print("self.character")
        -- print(self.character)
       local cat1 = ISVehicleTuning2Category:new(0, 0, self.width, self.panel.height - self.panel.tabHeight, self);
       cat1:initialise();
       cat1:setAnchorRight(true)
       cat1:setAnchorBottom(true)
       local catName = getTextOrNull("IGUI_CraftCategory_"..i) or i
       self.panel:addView(catName, cat1);
       cat1.infoText = getText("IGUI_InfoPanel_Tuning");
       cat1.parent = self
       cat1.category = i
       for s,d in ipairs(l) do
          cat1.recipes:addItem(s,d);
       end
       table.insert(self.categories, cat1);
    end

    self.craftOneButton = ISButton:new(0, self.height-ISVehicleTuning2.bottomInfoHeight-20-15, 50,25,getText("IGUI_TuningUI_Uninstall"),self, ISVehicleTuning2.onInstallPart);
    self.craftOneButton:initialise()
    self:addChild(self.craftOneButton);

    self.debugGiveIngredientsButton = ISButton:new(0, 0, 50, 25, "DBG: Give Ingredients", self, ISVehicleTuning2.debugGiveIngredients);
    self.debugGiveIngredientsButton:initialise();
    self:addChild(self.debugGiveIngredientsButton);

    self.taskLabel = ISLabel:new(4,5,19,"",1,1,1,1,UIFont.Small, true);
    self:addChild(self.taskLabel);

    self.addIngredientButton = ISButton:new(0, self.height-ISVehicleTuning2.bottomInfoHeight-20-15, 50,25,getText("IGUI_CraftUI_ButtonAddIngredient"),self, ISVehicleTuning2.onAddIngredient);
    self.addIngredientButton:initialise()
    self:addChild(self.addIngredientButton);
    self.addIngredientButton:setVisible(false);

    -- For non-evolved recipes
    self.ingredientPanel = ISScrollingListBox:new(1, 30, self.width / 3, self.height - (59 + ISVehicleTuning2.bottomInfoHeight));
    self.ingredientPanel:initialise()
    self.ingredientPanel:instantiate()
    self.ingredientPanel.itemheight = math.max(ISVehicleTuning2.smallFontHeight, 22)
    self.ingredientPanel.font = UIFont.NewSmall
    self.ingredientPanel.doDrawItem = self.drawNonEvolvedIngredient
    self.ingredientPanel.drawBorder = true
    self.ingredientPanel:setVisible(false)
    self:addChild(self.ingredientPanel)

-- For non-evolved recipes
    self.toolsPanel = ISScrollingListBox:new(1, 30, self.width / 3, self.height - (59 + ISVehicleTuning2.bottomInfoHeight));
    self.toolsPanel:initialise()
    self.toolsPanel:instantiate()
    self.toolsPanel.itemheight = math.max(ISVehicleTuning2.smallFontHeight, 22)
    self.toolsPanel.font = UIFont.NewSmall
    self.toolsPanel.doDrawItem = self.drawNonEvolvedIngredient
    self.toolsPanel.drawBorder = true
    self.toolsPanel:setVisible(false)
    self:addChild(self.toolsPanel)
    
    self.resultPanel = ISScrollingListBox:new(1, 30, self.width / 3, self.height - (59 + ISVehicleTuning2.bottomInfoHeight));
    self.resultPanel:initialise()
    self.resultPanel:instantiate()
    self.resultPanel.itemheight = math.max(ISVehicleTuning2.smallFontHeight, 22)
    self.resultPanel.font = UIFont.NewSmall
    self.resultPanel.doDrawItem = self.drawNonEvolvedIngredient
    self.resultPanel.drawBorder = true
    self.resultPanel:setVisible(false)
    self:addChild(self.resultPanel)

    self.noteRichText = ISRichTextLayout:new(self.width)
    self.noteRichText:setMargins(0, 0, 0, 0)
    self.noteRichText:setText(getText("IGUI_CraftUI_Note"))
    self.noteRichText.textDirty = true

    self.keysRichText = ISRichTextLayout:new(self.width)
    self.keysRichText:setMargins(5, 0, 5, 0)
    -- self:refresh();
end


 -- составляет таблицу со всеми доступными типами предметов, используемых в рецепте
 -- тип предмета = количество найденное во всех доступных инвентарях
 -- {fullType = 4,}
function ISVehicleTuning2:getAvailableItemsType(RecipeItem)
    local result = {};
    local recipeListBox = self:getRecipeListBox()
    RecipeItem = RecipeItem or recipeListBox.items[recipeListBox.selected].item
    if RecipeItem.use then
        for _, itemInList in pairs(RecipeItem.use) do
            local fullType = itemInList.fullType
            for _, itemCont in pairs(self.containerListLua) do
                if itemInList.isDrainable then -- если предмет расходуемый, считает количество доступного использования
                    local array = itemCont:FindAll(fullType)
                    local count = 0
                    for i=0,array:size()-1 do
                        local itemFromInventory = array:get(i)
                        local availableUses = itemFromInventory:getDrainableUsesInt()
                        if availableUses > 0 then
                            result[#result+1] = itemFromInventory
                            count = count + availableUses
                        end
                        if count > itemInList.count then break end
                    end
                    result[fullType] = (result[fullType] or 0) + count
                else
                    local arraySize = itemCont:FindAll(fullType):size()
                    result[fullType] = (result[fullType] or 0) + arraySize
                end
            end
        end
    end
    if RecipeItem.tools then
        for _, itemInList in pairs(RecipeItem.tools) do
            local fullType = itemInList.fullType
            for _, itemCont in pairs(self.containerListLua) do
                local arraySize = itemCont:FindAll(fullType):size()
                result[fullType] = (result[fullType] or 0) + arraySize
            end
        end
    end
    return result
end

-- определяет достаточно ли предметов для крафта
function ISVehicleTuning2:HasAllRequiredItems(RecipeItem)
    -- print("ISVehicleTuning2:HasAllRequiredItems")
    local result = true
    local typesAvailable = self:getAvailableItemsType(RecipeItem)
    if RecipeItem.use then
        for _, item in pairs(RecipeItem.use) do
            if item.count > typesAvailable[item.fullType] then
                result = false
            end
        end
    end
    if RecipeItem.tools then
        for _, item in pairs(RecipeItem.tools) do
            if not typesAvailable[item.fullType] or typesAvailable[item.fullType] < 1 then
                result = false
            end
        end
    end
    return result
end

function ISVehicleTuning2:GetNotLearnRecipes(RecipeItem)
    local recipeNotLearn = ""
    for _, recipeName in ipairs(RecipeItem.recipes) do
        if not self.character:isRecipeKnown(recipeName) then
            if recipeNotLearn ~= "" then
                recipeNotLearn = recipeNotLearn .. ", "
            end
            recipeNotLearn = recipeNotLearn .. getRecipeDisplayName(recipeName)
            if string.len(recipeNotLearn) > 40 then
                recipeNotLearn = string.sub(recipeNotLearn,1,40) .. "..."
                break
            end
        end
    end
    return recipeNotLearn
end

-- проверка выполняются ли условия для крафта
function ISVehicleTuning2:IsRecipeValid(RecipeItem)
    if RecipeItem.recipeNotLearn and RecipeItem.recipeNotLearn ~= "" then 
        -- print("IsRecipeValid: recipeNotLearn")
        return false 
    end
    local vehiclePart = self.vehicle:getPartById(RecipeItem.partName)
    if not vehiclePart then 
        -- print("IsRecipeValid: not vehiclePart")
        return false 
    end
    
    if RecipeItem.type == "install" then
        if RecipeItem.requireModel then
            if vehiclePart:getModData().tuning2 and  vehiclePart:getModData().tuning2.model ~= RecipeItem.requireModel then
                -- RecipeItem.error = getText("IGUI_TuningUI_NotInstall")
                return false
            end
        elseif vehiclePart:getInventoryItem() then 
            RecipeItem.error = getText("IGUI_TuningUI_AlreadyInstall")
            return false 
        else
            RecipeItem.error = nil
        end
    else
        -- проверяет, что контейнер пустой
        if round(vehiclePart:getContainerContentAmount(), 3) > 0 then
            RecipeItem.error = getText("IGUI_TuningUI_NeedBeEmpty")
            return false 
        end
        if not vehiclePart:getInventoryItem() then 
            RecipeItem.error = getText("IGUI_TuningUI_NotInstall")
        else
            RecipeItem.error = nil
        end
    end
    -- проверка скиллов
    if RecipeItem.skills then
        for perkName, perkLevel in pairs(RecipeItem.skills) do
            local perk = Perks.FromString(perkName)
            local playerLevel = self.character and self.character:getPerkLevel(perk) or 0
            if self.character and (playerLevel < perkLevel) then
                return false 
            end
        end
    end
    -- проверяет, что игрок имеет всё нужно для рецепта
    if not self:HasAllRequiredItems(RecipeItem) then 
        -- print("IsRecipeValid: not HasAllRequiredItems")
        return false 
    end
    return true
end

local FakeRecipeItem = {}
FakeRecipeItem.type = "fake"
FakeRecipeItem.category = getText("IGUI_TuningCategory_General")
FakeRecipeItem.icon = getTexture("media/ui/commonlibrary/no.png")
FakeRecipeItem.itemName = getText("IGUI_NoAvailableParts")
FakeRecipeItem.available = false

-- Создание RecipeItem
function ISVehicleTuning2:createRecipeItemFor(infoTable, partName, partTuningInfo, modelName, actionType, specialCategory) -- actionType = install or uninstall
    local RecipeItem = {}; -- пункт меню слева
    RecipeItem.type = actionType
    RecipeItem.partName = partName
    RecipeItem.modelName = modelName
    RecipeItem.hideIfNotValid = partTuningInfo.hideIfNotValid
    
    if partTuningInfo[actionType].requireModel and partTuningInfo[actionType].requireModel ~= "" then
        RecipeItem.requireModel = partTuningInfo[actionType].requireModel
        if infoTable[RecipeItem.requireModel].name and infoTable[RecipeItem.requireModel].name ~= "" then
            RecipeItem.requireModelName = getText(infoTable[RecipeItem.requireModel].name)
        else
            RecipeItem.requireModelName = getText("IGUI_VehiclePart" .. partName)
        end
    end
    
    if partTuningInfo[actionType].area and partTuningInfo[actionType].area ~= "" then
        RecipeItem.area = partTuningInfo[actionType].area
    end
    
    if partTuningInfo[actionType].recipes and #partTuningInfo[actionType].recipes > 0 then
        RecipeItem.recipes = partTuningInfo[actionType].recipes
        RecipeItem.recipeNotLearn = self:GetNotLearnRecipes(RecipeItem)
    end
    
    if partTuningInfo.protection and #partTuningInfo.protection > 0 then
        RecipeItem.protection = partTuningInfo.protection
    end
    
    if specialCategory then
        RecipeItem.category = specialCategory
    elseif partTuningInfo.category and partTuningInfo.category ~= "" then
        RecipeItem.category = getText("IGUI_TuningCategory_" .. partTuningInfo.category)
    else
        RecipeItem.category = getText("IGUI_TuningCategory_General")
    end
    
    RecipeItem.icon = getTexture(partTuningInfo.icon); -- +++
    if partTuningInfo.name and partTuningInfo.name ~= "" then
        RecipeItem.itemName = getText(partTuningInfo.name)
    else
        RecipeItem.itemName = getText("IGUI_VehiclePart" .. partName)
    end
    
    RecipeItem.time = partTuningInfo[actionType].time
    
    if partTuningInfo[actionType].tools and type(partTuningInfo[actionType].tools) == "table" then
        RecipeItem.tools = {};
        local filled = false
        for useType, tool in pairs(partTuningInfo[actionType].tools) do
            local item = nil
            item = self:GetItemInstance(tool);
            if item then
                local toolInList = {};
                toolInList.count = 1
                toolInList.icon = item:getTex();
                toolInList.name = item:getDisplayName()
                toolInList.fullType = item:getFullType()
                RecipeItem.tools[useType] = toolInList
                filled = true
            end
        end
        if not filled then RecipeItem.tools = nil end
    end
    
    if partTuningInfo[actionType].use and type(partTuningInfo[actionType].use) == "table" then
        RecipeItem.use = {};
        local filled = false
        for itemName, count in pairs(partTuningInfo[actionType].use) do
            local item = nil
            itemName = itemName:gsub("__", ".")
            item = self:GetItemInstance(itemName)
            if item then
                local itemInList = {}
                itemInList.count = count
                itemInList.isDrainable = item:IsDrainable()
                itemInList.icon = item:getTex()
                itemInList.name = item:getDisplayName()
                itemInList.fullType = item:getFullType()
                RecipeItem.use[#RecipeItem.use+1] = itemInList
                filled = true
            end
        end
        if not filled then RecipeItem.use = nil end
    end
    
    if partTuningInfo[actionType].result and type(partTuningInfo[actionType].result) == "table" then
        RecipeItem.resultTable = {};
        RecipeItem.result = {};
        local filled = false
        for itemName, count in pairs(partTuningInfo[actionType].result) do
            local item = nil
            itemName = itemName:gsub("__", ".")
            item = self:GetItemInstance(itemName)
            if item then
                local itemInList = {}
                if ATA2TuningSpecialSpawnCount[itemName] then
                    itemInList.count = count * ATA2TuningSpecialSpawnCount[itemName]
                else
                    itemInList.count = count
                end
                itemInList.result = true
                itemInList.icon = item:getTex()
                itemInList.name = item:getDisplayName()
                itemInList.fullType = item:getFullType()
                RecipeItem.resultTable[item:getFullType()] = count
                RecipeItem.result[#RecipeItem.result+1] = itemInList
                filled = true
            end
        end
        if not filled then RecipeItem.result = nil end
    end
    
    RecipeItem.skills = partTuningInfo[actionType].skills
    RecipeItem.requireInstalled = partTuningInfo[actionType].requireInstalled
    RecipeItem.requireUninstalled = partTuningInfo[actionType].requireUninstalled
    
    if self.character then
        RecipeItem.available = self:IsRecipeValid(RecipeItem)
    end
    
    return RecipeItem
end

function ISVehicleTuning2:populateRecipesList()
    -- print("ISVehicleTuning2:populateRecipesList")
    local allRecipes = getAllRecipes();
    self.allRecipesList = {};
    self.recipesList = {};
    self.recipesListH = {};
    -- self.recipesList[getText("IGUI_CraftCategory_General")] = {};
    -- self.recipesListH[#self.recipesListH+1] = getText("IGUI_CraftCategory_General")
    self:getContainers();
    if self.vehicle then
        local tuningTable = ATA2TuningTable[self.vehicle:getScript():getName()]
        
        -- считываем всю таблицу тюнинга, составляем список запчастей, которые могут быть установлены
        -- проверяем какие предметы установлены и добавляем их список в категорию "Установлено".
        local installPartList = {}
        for partName, infoTable in pairs(tuningTable.parts) do
            local part = self.vehicle:getPartById(partName)
            if part and part:getInventoryItem() then
                local partTuningInfo = {}
                local modelName = "Default"
                if part:getModData().tuning2 and part:getModData().tuning2.model and infoTable[part:getModData().tuning2.model] then
                    modelName = part:getModData().tuning2.model
                    partTuningInfo = infoTable[part:getModData().tuning2.model]
                else
                    for k,v in pairs (infoTable) do 
                        modelName = k
                        partTuningInfo = v
                        break
                    end
                end
                RecipeItem = self:createRecipeItemFor(infoTable, partName, partTuningInfo, modelName, "uninstall", getText("IGUI_TuningCategory_Installed"))
                RecipeItem.condition = part:getCondition()
                installPartList[partName] = modelName
                
                if not self.recipesList[RecipeItem.category] then
                    self.recipesList[RecipeItem.category] = {};
                    self.recipesListH[#self.recipesListH+1] = RecipeItem.category
                end
                table.insert(self.recipesList[getText("IGUI_TuningCategory_Installed")], RecipeItem);
                table.insert(self.allRecipesList, RecipeItem);
            end
        end
        
        for partName, infoTable in pairs(tuningTable.parts) do
            local part = self.vehicle:getPartById(partName)
            if part then
                for modelName, partTuningInfo in pairs(infoTable) do
                    if not installPartList[partName] or installPartList[partName] ~= modelName then
                        RecipeItem = self:createRecipeItemFor(infoTable, partName, partTuningInfo, modelName, "install")
                        if not RecipeItem.hideIfNotValid or (RecipeItem.hideIfNotValid and RecipeItem.available) then
                            if not self.recipesList[RecipeItem.category] then
                                self.recipesList[RecipeItem.category] = {};
                                self.recipesListH[#self.recipesListH+1] = RecipeItem.category
                            end
                            table.insert(self.recipesList[RecipeItem.category], RecipeItem);
                            table.insert(self.allRecipesList, RecipeItem);
                        end
                    else
                        RecipeItem = self:createRecipeItemFor(infoTable, partName, partTuningInfo, modelName, "uninstall")
                        RecipeItem.condition = part:getCondition()
                        if not RecipeItem.hideIfNotValid or (RecipeItem.hideIfNotValid and RecipeItem.available) then
                            if not self.recipesList[RecipeItem.category] then
                                self.recipesList[RecipeItem.category] = {};
                                self.recipesListH[#self.recipesListH+1] = RecipeItem.category
                            end
                            table.insert(self.recipesList[RecipeItem.category], RecipeItem);
                            table.insert(self.allRecipesList, RecipeItem);
                        end
                    end
                end
            end
        end
    end
    
    -- защита от пустых таблиц
    local haveList = false
    for _,list in pairs(self.recipesList) do
        haveList = true
        break
    end
    
    if not haveList then
        self.recipesList[FakeRecipeItem.category] = {};
        self.recipesListH[#self.recipesListH+1] = FakeRecipeItem.category
        table.insert(self.recipesList[FakeRecipeItem.category], FakeRecipeItem);
        table.insert(self.allRecipesList, FakeRecipeItem);
    end
--    if #self.recipesList["Favorite"] == 0 then self.recipesList["Favorite"] = nil end
end

-- возвращает список рецептов
function ISVehicleTuning2:getRecipeListBox() 
    -- print("ISVehicleTuning2:getRecipeListBox()")
    return self.panel.activeView.view.recipes
end

-- отвечает за заполнение левого списка
function ISVehicleTuning2:refresh()
    -- print("ISVehicleTuning2:refresh")
    local recipeListBox = self:getRecipeListBox()
    local selectedView = self.panel.activeView.name
    self:getContainers();
    self:populateRecipesList();
    for i=#self.categories,1,-1 do
        local categoryUI = self.categories[i];
        self.panel:removeView(categoryUI);
        table.remove(self.categories, i);
    end
    self.panel:activateView(selectedView);

    -- create the new categories if needed
    local k
    for k = 1 , #self.recipesListH, 1 do
        local tuningCategory = self.recipesListH[k]
        local recipesListTable = self.recipesList[tuningCategory] -- таблица {Item, Item, Item}
    --for tuningCategory,recipesListTable in pairs(self.recipesList) do
        local found = false
        for k,l in ipairs(self.categories) do
            if tuningCategory == l.category then
                found = true
                break
            end
        end
        if not found then
            local cat1 = ISVehicleTuning2Category:new(0, 0, self.width, self.panel.height - self.panel.tabHeight, self);
            cat1:initialise();
            local catName = getTextOrNull("IGUI_CraftCategory_"..tuningCategory) or tuningCategory
            self.panel:addView(catName, cat1);
            cat1.infoText = getText("IGUI_InfoPanel_Tuning");
            cat1.parent = self
            cat1.category = tuningCategory
            for num, RecipeItem in ipairs(recipesListTable) do
                cat1.recipes:addItem(num, RecipeItem);
            end
            table.insert(self.categories, cat1);
        end
    end
    -- switch panel if there's no item in this list
    if #recipeListBox.items == 0 then
        self.panel:activateView(getText("IGUI_CraftCategory_General"));
    end
end

function ISVehicleTuning2:isWaterSource(item, count)
    -- Fk'n rounding differences between Java and Lua broke simple getUsedDelta()/getUseDelta() here, so I added getDrainableUsesInt()
    return instanceof(item, "DrainableComboItem") and item:isWaterSource() and item:getDrainableUsesInt() >= count
end

function ISVehicleTuning2:close()
    ISCollapsableWindow.close(self)
    if JoypadState.players[self.playerNum+1] then
        setJoypadFocus(self.playerNum, nil)
    end
end

ISVehicleTuning2.sortByName = function(a,b)
    return string.sort(b.itemName, a.itemName);
end

function ISVehicleTuning2:getContainers()
    -- print("ISVehicleTuning2:getContainers()")
    if not self.character then return end
    -- get all the surrounding inventory of the player, gonna check for the item in them too
    self.containerListLua = {};

    for i,v in ipairs(getPlayerInventory(self.playerNum).inventoryPane.inventoryPage.backpacks) do
        self.containerListLua[#self.containerListLua + 1] = v.inventory
    end
    for i,v in ipairs(getPlayerLoot(self.playerNum).inventoryPane.inventoryPage.backpacks) do
        self.containerListLua[#self.containerListLua + 1] = v.inventory
    end
end

-- выделяем предметы, которые есть в инвентаре
function ISVehicleTuning2:drawNonEvolvedIngredient(y, item, alt)
    -- print("ISVehicleTuning2:drawNonEvolvedIngredient")
    -- print(item)
    -- print(item.text)
    -- print(item.result)
    -- print(item.fullType)
    -- print(item.item.fullType)
    -- print(item.item.count)
    -- print(item.item.result)
    if y + self:getYScroll() >= self.height then return y + self.itemheight end
    if y + self.itemheight + self:getYScroll() <= 0 then return y + self.itemheight end

    if not self.parent.recipeListHasFocus and self.selected == item.index then
        self:drawRectBorder(1, y, self:getWidth()-2, self.itemheight, 1.0, 0.5, 0.5, 0.5);
    end

    -- if item.item.multipleHeader then
        -- local r,g,b = 1,1,1
        -- if not item.item.available then
            -- r,g,b = 0.54,0.54,0.54
        -- end
        -- self:drawText(item.text, 12, y + 2, r, g, b, 1, self.font)
        -- self:drawTexture(item.item.icon, 4, y + (item.height - item.item.icon:getHeight()) / 2 - 2, 1,1,1,1)
    -- else
        local r,g,b
        local r2,g2,b2,a2
        local typesAvailable = item.item.RecipeItem.typesAvailable
        if typesAvailable and (not typesAvailable[item.item.fullType] or typesAvailable[item.item.fullType] < item.item.count) and not item.item.result then
            r,g,b = 0.54,0.54,0.54
            r2,g2,b2,a2 = 1,1,1,0.3
        else
            r,g,b = 1,1,1
            r2,g2,b2,a2 = 1,1,1,0.9
        end

        local imgW = 20
        local imgH = 20
        local dx = 6 + (item.item.multiple and 10 or 0)
        
        self:drawText(item.text, dx + imgW + 4, y + (item.height - ISVehicleTuning2.smallFontHeight) / 2, r, g, b, 1, self.font)
        
        if item.item.icon then
            local texWidth = item.item.icon:getWidth()
            local texHeight = item.item.icon:getHeight()
            self:drawTextureScaledAspect(item.item.icon, dx, y + (self.itemheight - imgH) / 2, 20, 20, a2,r2,g2,b2)
        end
    -- end

    return y + self.itemheight
end

function ISVehicleTuning2:refreshIngredientPanel()
-- print("ISVehicleTuning2:refreshIngredientPanel()")
    local hasFocus = not self.recipeListHasFocus
    self.recipeListHasFocus = true

    self.ingredientPanel:setVisible(false)
    self.toolsPanel:setVisible(false)
    self.resultPanel:setVisible(false)

    local recipeListbox = self:getRecipeListBox()
    if not recipeListbox.items or #recipeListbox.items == 0 or not recipeListbox.items[recipeListbox.selected] then return end
    local RecipeItem = recipeListbox.items[recipeListbox.selected].item
    if not RecipeItem then return end

    RecipeItem.typesAvailable = self:getAvailableItemsType()

    self.recipeListHasFocus = not hasFocus
    -- self.ingredientPanel:setVisible(true) 
    -- self.toolsPanel:setVisible(true) 

    self.ingredientPanel:clear()
    self.toolsPanel:clear()
    self.resultPanel:clear()
    
    if RecipeItem.tools then
        for typeName,item in pairs(RecipeItem.tools) do
            local data = {}
            data.RecipeItem = RecipeItem
            data.name = item.name
            data.icon = item.icon
            data.fullType = item.fullType
            data.count = item.count
            -- data.recipe = RecipeItem.recipe
            data.multiple = false
            self.toolsPanel:addItem(item.name, data)
        end
    end
    if RecipeItem.use then
        for _,item in ipairs(RecipeItem.use) do
            local data = {}
            data.RecipeItem = RecipeItem
            data.name = item.name
            data.icon = item.icon
            data.fullType = item.fullType
            data.count = item.count
            -- data.recipe = RecipeItem.recipe
            data.multiple = false
            
            if item.count > 1 then
                self.ingredientPanel:addItem(getText("IGUI_CraftUI_CountNumber", item.name, item.count), data)
            else
                self.ingredientPanel:addItem(item.name, data)
            end
        end
    end
    if RecipeItem.result then
        for _,item in ipairs(RecipeItem.result) do
            local data = {}
            data.RecipeItem = RecipeItem
            data.name = item.name
            data.icon = item.icon
            data.fullType = item.fullType
            data.count = item.count
            data.result = true
            -- data.recipe = RecipeItem.recipe
            data.multiple = false
            
            if item.count > 1 then
                self.resultPanel:addItem(getText("IGUI_CraftUI_CountNumber", item.name, item.count), data)
            else
                self.resultPanel:addItem(item.name, data)
            end
        end
    end
    
    self.refreshTypesAvailableMS = getTimestampMs()
    self.ingredientPanel.doDrawItem = ISVehicleTuning2.drawNonEvolvedIngredient
    self.toolsPanel.doDrawItem = ISVehicleTuning2.drawNonEvolvedIngredient
    self.resultPanel.doDrawItem = ISVehicleTuning2.drawNonEvolvedIngredient
end

local function tableSize(table1)
    if not table1 then return 0 end
    local count = 0
    for _,v in pairs(table1) do
        count = count + 1
    end
    return count
end

local function areTablesDifferent(table1, table2)
    local size1 = tableSize(table1)
    local size2 = tableSize(table2)
    if size1 ~= size2 then return true end
    if size1 == 0 then return false end
    for k1,v1 in pairs(table1) do
        if table2[k1] ~= v1 then
            return true
        end
    end
    -- print("SAME")
    return false
end

function ISVehicleTuning2:render()
    ISCollapsableWindow.render(self);
    if self.isCollapsed then return end
    self.addIngredientButton:setVisible(false);
    -- draw bottom infos
    local rh = self.resizable and self:resizeWidgetHeight() or 0
    self:drawRectBorder(0, 0, self:getWidth(), self:getHeight(), self.borderColor.a, self.borderColor.r,self.borderColor.g,self.borderColor.b);
    self.javaObject:DrawTextureScaledColor(nil, 0, self:getHeight() - rh - ISVehicleTuning2.bottomInfoHeight, self:getWidth(), 1, self.borderColor.r, self.borderColor.g,self.borderColor.b,self.borderColor.a);

    local textY = self:getHeight() - rh - ISVehicleTuning2.bottomInfoHeight + (ISVehicleTuning2.bottomInfoHeight - ISVehicleTuning2.smallFontHeight) / 2
    local buttonSize = 24
    local buttonSpace = 8
    local buttonY = self:getHeight() - rh - ISVehicleTuning2.bottomInfoHeight + (ISVehicleTuning2.bottomInfoHeight - buttonSize) / 2
    local spacing = 32 
    
    local recipeListBox = self:getRecipeListBox()
    local RecipeItem = recipeListBox.items[recipeListBox.selected].item
    
    if self.drawJoypadFocus then
        local width1 = buttonSize + buttonSpace + getTextManager():MeasureStringX(UIFont.Small, self.LabelUninstall)
        local width4 = buttonSize + buttonSpace + getTextManager():MeasureStringX(UIFont.Small, self.LabelClose)
        local totalWidth = width1 + width4 + spacing * 3 -- + width2 + width3
        local left = (self.width - totalWidth) / 2

        self:drawTextureScaled(Joypad.Texture.AButton, left, buttonY, buttonSize, buttonSize, 1, 1, 1, 1)
        
        if RecipeItem.type == "install" then
            self:drawText(self.LabelInstall, left + buttonSize + buttonSpace, textY, 1, 1, 1, 1, UIFont.Small)
        else
            self:drawText(self.LabelUninstall, left + buttonSize + buttonSpace, textY, 1, 1, 1, 1, UIFont.Small)
        end
        
        left = left + width1 + spacing

        self:drawTextureScaled(Joypad.Texture.BButton, left, buttonY, buttonSize, buttonSize, 1, 1, 1, 1)
        self:drawText(self.LabelClose, left + buttonSize + buttonSpace, textY, 1, 1, 1, 1, UIFont.Small)
    else
        local noteX = 0
        local noteWidth = self.width
        if noteWidth ~= self.keysRichText.width then
            self.keysRichText:setWidth(noteWidth)
            self.keysRichText.textDirty = true
        end
        if text ~= self.keysText then
            self.keysText = text
            self.keysRichText:setText(" <CENTRE> " .. text)
            self.keysRichText.textDirty = true
        end
        local noteY = self:getHeight() - rh - ISVehicleTuning2.bottomInfoHeight
        noteY = noteY + (ISVehicleTuning2.bottomInfoHeight - self.keysRichText.height) / 2
        self.keysRichText:render(noteX, noteY, self)
    end

    local noteX = self:getWidth() / 3 + 10
    local noteWidth = self.width - 10 - noteX
    if noteWidth ~= self.noteRichText.width then
        self.noteRichText:setWidth(noteWidth)
        self.noteRichText.textDirty = true
    end
    local noteY = self:getHeight() - rh - ISVehicleTuning2.bottomInfoHeight - self.noteRichText.height - 4
    if noteY >= self.craftOneButton:getBottom() + 10 then
        self.noteRichText:render(noteX, noteY, self)
    end

    
    if not recipeListBox.items or #recipeListBox.items == 0 or not recipeListBox.items[recipeListBox.selected] then
        self.craftOneButton:setVisible(false);
        -- self.craftAllButton:setVisible(false);
        self.debugGiveIngredientsButton:setVisible(false);
        self.ingredientPanel:setVisible(false);
        self.toolsPanel:setVisible(false);
        self.selectedRecipeItem = nil
        return
    end
    
    -- Информация о крафте
    local x = self:getWidth()/3 + 80
    local y = 40


    local now = getTimestampMs()
    if not self.refreshTypesAvailableMS or (self.refreshTypesAvailableMS + 500 < now) then
        self.refreshTypesAvailableMS = now
        local typesAvailable = self:getAvailableItemsType();
        self.needRefreshIngredientPanel = self.needRefreshIngredientPanel or areTablesDifferent(RecipeItem.typesAvailable, typesAvailable);
        RecipeItem.typesAvailable = typesAvailable
    end
    self:getContainers();
    if RecipeItem.type ~= "fake" then
        RecipeItem.available = self:IsRecipeValid(RecipeItem)
    end
    self.craftOneButton:setVisible(true);
    -- self.craftAllButton:setVisible(true);
    self.debugGiveIngredientsButton:setVisible(getDebug());

    -- render the right part, the craft information
    self:drawRectBorder(x, y, 32 + 10, 32 + 10, 1.0, 1.0, 1.0, 1.0);
    if RecipeItem.icon then
        if RecipeItem.icon:getWidth() <= 32 and RecipeItem.icon:getHeight() <= 32 then
            local newX = (32 - RecipeItem.icon:getWidthOrig()) / 2
            local newY = (32 - RecipeItem.icon:getHeightOrig()) / 2
            self:drawTexture(RecipeItem.icon,x+5 + newX,y+5 + newY,1,1,1,1);
        else
            self:drawTextureScaledAspect(RecipeItem.icon,x+5,y+5,32,32,1,1,1,1);
        end
    end
    -- Название предмета
    self:drawText(RecipeItem.itemName , x + 32 + 15, y, 1,1,1,1, UIFont.Large);
    
    -- Состояние предмета, либо причины почему нельзя его установить
    if RecipeItem.recipeNotLearn and RecipeItem.recipeNotLearn ~= "" then
        self:drawText(getText("IGUI_TuningUI_NotLearn") .. " " .. RecipeItem.recipeNotLearn, x + 32 + 15, y + self.largeFontHeight, 1, 0, 0, 1, UIFont.Small);
    elseif RecipeItem.error then
        self:drawText(RecipeItem.error, x + 32 + 15, y + self.largeFontHeight, 1, 0, 0, 1, UIFont.Small);
    elseif RecipeItem.condition then
        local condRGB = ISVehicleMechanics:getConditionRGB(RecipeItem.condition)
        self:drawText(getText("IGUI_TuningUI_Condition") .. " " .. tostring(RecipeItem.condition) .. "%", x + 32 + 15, y + self.largeFontHeight, condRGB.r, condRGB.g, condRGB.b, 1, UIFont.Small);
    end
    
    -- local name = RecipeItem.evolved and RecipeItem.resultName or RecipeItem.itemName
    -- self:drawText(name, x + 32 + 15, y + ISVehicleTuning2.largeFontHeight, 1,1,1,1, UIFont.Small);
    
    y = y + math.max(45, ISVehicleTuning2.largeFontHeight + ISVehicleTuning2.smallFontHeight);
    -- local imgW = 20
    -- local imgH = 20
    -- local imgPadX = 4
    -- local dyText = (imgH - ISVehicleTuning2.smallFontHeight) / 2
    
    -- Информация о элементах, которым предоставляется защита
    if RecipeItem.protection and #RecipeItem.protection > 0 then
        self:drawText(getText("IGUI_TuningUI_ProtectionFor"), x, y, 1,1,1,1, UIFont.Medium);
        y = y + ISVehicleTuning2.mediumFontHeight
        for _, partName in pairs(RecipeItem.protection) do
            local text = " - " .. getText("IGUI_VehiclePart" .. partName)
            self:drawText(text, x + 15, y, 1,1,1,1, UIFont.Small);
            y = y + ISVehicleTuning2.smallFontHeight
        end
        y = y + 4
    end
    
    if RecipeItem.use and #RecipeItem.use > 0 then
        self:drawText(getText("IGUI_TuningUI_RequiredItems"), x, y + 3, 1,1,1,1, UIFont.Medium);

        y = y + ISVehicleTuning2.mediumFontHeight + 6

        self.ingredientPanel:setX(x + 15)
        self.ingredientPanel:setY(y)
        self.ingredientPanel:setHeight(self.ingredientPanel.itemheight * 5) -- количество строк для предметов
        self.ingredientPanel:setVisible(true)
        y = self.ingredientPanel:getBottom()
    else
        self.ingredientPanel:setVisible(false)
    end
    
    -- print(RecipeItem.tools)
    if RecipeItem.tools then
        self:drawText(getText("IGUI_TuningUI_RequiredTools"), x, y + 3, 1,1,1,1, UIFont.Medium);
        y = y + ISVehicleTuning2.mediumFontHeight + 6
        self.toolsPanel:setX(x + 15)
        self.toolsPanel:setY(y)
        self.toolsPanel:setHeight(self.toolsPanel.itemheight * 3) -- количество строк для инструментов
        self.toolsPanel:setVisible(true)
        y = self.toolsPanel:getBottom()
    else
        self.toolsPanel:setVisible(false)
    end
    
    if RecipeItem.result and #RecipeItem.result > 0 then
        self:drawText(getText("IGUI_TuningUI_Result"), x, y + 5, 1,1,1,1, UIFont.Medium);

        y = y + ISVehicleTuning2.mediumFontHeight + 7

        self.resultPanel:setX(x + 15)
        self.resultPanel:setY(y)
        self.resultPanel:setHeight(self.resultPanel.itemheight * 3) -- количество строк для предметов
        self.resultPanel:setVisible(true)
        y = self.resultPanel:getBottom()
    else
        self.resultPanel:setVisible(false)
    end
    
    if RecipeItem ~= self.selectedRecipeItem then
        self:refreshIngredientPanel()
        self.selectedRecipeItem = RecipeItem
    end

    y = y + 4
    
    -- проверяет выучил ли персонаж рецепты при открытом меню тюнинга
    if RecipeItem.recipes and #RecipeItem.recipes > 0 then
        RecipeItem.recipeNotLearn = self:GetNotLearnRecipes(RecipeItem)
    end
    
    if RecipeItem.skills then
        self:drawText(getText("IGUI_CraftUI_RequiredSkills"), x, y, 1,1,1,1, UIFont.Medium);
        y = y + ISVehicleTuning2.mediumFontHeight
        for perkName, perkLevel in pairs(RecipeItem.skills) do
            local perk = Perks.FromString(perkName)
            local playerLevel = self.character and self.character:getPerkLevel(perk) or 0
            local perkNameLand = perk and perk:getName()
            local text = " - " .. perkNameLand .. ": " .. tostring(playerLevel) .. " / " .. tostring(perkLevel);
            local r,g,b = 1,1,1
            if self.character and (playerLevel < perkLevel) then
                g = 0
                b = 0
            end
            self:drawText(text, x + 15, y, r,g,b,1, UIFont.Small);
            y = y + ISVehicleTuning2.smallFontHeight
        end
        y = y + 4
    end
    
    local requireUnInstalled = false
    if self.vehicle then
        if RecipeItem.requireInstalled then
            for _, partName in ipairs(RecipeItem.requireInstalled) do
                local part = self.vehicle:getPartById(partName)
                if part and not part:getInventoryItem() then
                    if not requireUnInstalled then
                        self:drawText(getText("IGUI_TuningUI_RequiredInstalled"), x, y, 1,1,1,1, UIFont.Medium);
                        y = y + ISVehicleTuning2.mediumFontHeight
                        requireUnInstalled = true
                    end
                    self:drawText(" - " .. getText("IGUI_VehiclePart" .. partName), x + 15, y, 1,0,0,1, UIFont.Small);
                    y = y + ISVehicleTuning2.smallFontHeight
                end
            end
        end
        if RecipeItem.requireModel then
            local vehiclePart = self.vehicle:getPartById(RecipeItem.partName)
            if vehiclePart
                    and vehiclePart:getModData().tuning2
                    and vehiclePart:getModData().tuning2.model ~= RecipeItem.requireModel then 
                if not requireUnInstalled then
                    self:drawText(getText("IGUI_TuningUI_RequiredInstalled"), x, y, 1,1,1,1, UIFont.Medium);
                    y = y + ISVehicleTuning2.mediumFontHeight
                    requireUnInstalled = true
                end
                self:drawText(" - " .. getText(RecipeItem.requireModelName), x + 15, y, 1,0,0,1, UIFont.Small);
                y = y + ISVehicleTuning2.smallFontHeight
            end
        end
        if RecipeItem.requireUninstalled then
            for _, partName in ipairs(RecipeItem.requireUninstalled) do
                local part = self.vehicle:getPartById(partName)
                if part and part:getInventoryItem() then
                    if not requireUnInstalled then
                        self:drawText(getText("IGUI_TuningUI_RequiredUninstalled"), x, y, 1,1,1,1, UIFont.Medium);
                        y = y + ISVehicleTuning2.mediumFontHeight
                        requireUnInstalled = true
                    end
                    self:drawText(" - " .. getText("IGUI_VehiclePart" .. partName), x + 15, y, 1,0,0,1, UIFont.Small);
                    y = y + ISVehicleTuning2.smallFontHeight
                end
            end
        end
        y = y + 4
    end
    
    if RecipeItem.time and RecipeItem.time > 0 then
        self:drawText(getText("IGUI_CraftUI_RequiredTime", RecipeItem.time), x, y, 1,1,1,1, UIFont.Medium);
        y = y + ISVehicleTuning2.mediumFontHeight
    end
    
    y = y + 10
    self.craftOneButton:setX(x);
    self.craftOneButton:setY(y);
    if requireUnInstalled then
        self.craftOneButton.enable = false
    else
        self.craftOneButton.enable = RecipeItem.available
    end
    if RecipeItem.type == "install" then
        self.craftOneButton:setTitle(self.LabelInstall)
    else
        self.craftOneButton:setTitle(self.LabelUninstall)
    end

    self.debugGiveIngredientsButton:setX(self.craftOneButton:getX() + 5 + self.craftOneButton:getWidth())
    self.debugGiveIngredientsButton:setY(y);

        -- y = y + self.craftAllButton:getHeight() + 10
    
    -- stop allowing crafting while driving
    self.craftOneButton.tooltip = nil
    -- self.craftAllButton.tooltip = nil
    if self.character:isDriving() then
        -- self.craftAllButton.enable = false
        self.craftOneButton.enable = false
        self.craftOneButton.tooltip = getText("Tooltip_CantCraftDriving");
        -- self.craftAllButton.tooltip = getText("Tooltip_CantCraftDriving");
    end
    
    if RecipeItem.type == "fake" then
        self.craftOneButton:setVisible(false)
        self.debugGiveIngredientsButton:setVisible(false)
    end

    if self.drawJoypadFocus and self.recipeListHasFocus then
        local ui = self:getRecipeListBox()
        local dx,dy = 0,self:titleBarHeight()
        local parent = ui.parent
        while parent ~= self do
            dx = dx + parent:getX()
            dy = dy + parent:getY()
            parent = parent.parent
        end
        self:drawRectBorder(ui:getX(), dy + ui:getY(), ui:getWidth(), ui:getHeight(), 0.4, 0.2, 1.0, 1.0);
        self:drawRectBorder(ui:getX()+1, dy + ui:getY()+1, ui:getWidth()-2, ui:getHeight()-2, 0.4, 0.2, 1.0, 1.0);
    elseif self.drawJoypadFocus and self.ingredientPanelHasFocus then
        local ui = self.ingredientPanel
        self:drawRectBorder(ui:getX(), ui:getY(), ui:getWidth(), ui:getHeight(), 0.4, 0.2, 1.0, 1.0);
        self:drawRectBorder(ui:getX()+1, ui:getY()+1, ui:getWidth()-2, ui:getHeight()-2, 0.4, 0.2, 1.0, 1.0);
    elseif self.drawJoypadFocus and self.toolsPanelHasFocus then
        local ui = self.toolsPanel
        self:drawRectBorder(ui:getX(), ui:getY(), ui:getWidth(), ui:getHeight(), 0.4, 0.2, 1.0, 1.0);
        self:drawRectBorder(ui:getX()+1, ui:getY()+1, ui:getWidth()-2, ui:getHeight()-2, 0.4, 0.2, 1.0, 1.0);
    elseif self.drawJoypadFocus and self.resultPanelHasFocus then
        local ui = self.resultPanel
        self:drawRectBorder(ui:getX(), ui:getY(), ui:getWidth(), ui:getHeight(), 0.4, 0.2, 1.0, 1.0);
        self:drawRectBorder(ui:getX()+1, ui:getY()+1, ui:getWidth()-2, ui:getHeight()-2, 0.4, 0.2, 1.0, 1.0);
    end
end

function ISVehicleTuning2:onActivateView()
    local recipeListBox = self:getRecipeListBox()
    recipeListBox:ensureVisible(recipeListBox.selected);
end

ISVehicleTuning2.toggleCraftingUI = function()
    local ui = getPlayerTuningUI(0)
    if ui then
        if ui:getIsVisible() then
            ui:setVisible(false)
            ui:removeFromUIManager() -- avoid update() while hidden
        else
            ui:setVisible(true)
            ui:addToUIManager()
        end
    end
end

function ISVehicleTuning2:isKeyConsumed(key)
    return key == Keyboard.KEY_ESCAPE or
            key == ISVehicleTuning2.upArrow or
            key == ISVehicleTuning2.downArrow or
            key == ISVehicleTuning2.leftCategory or
            key == ISVehicleTuning2.rightCategory or
            key == Keyboard.KEY_C or
            key == Keyboard.KEY_R or
            key == Keyboard.KEY_F
end

function ISVehicleTuning2:onKeyRelease(key)
    local ui = self
    if not ui.panel or not ui.panel.activeView then return end
    -- if key == getCore():getKey("Crafting UI") then
        -- ISVehicleTuning2.toggleCraftingUI();
        -- return
    -- end
    if key == Keyboard.KEY_ESCAPE then
        ISVehicleTuning2.toggleCraftingUI();
        return
    end
    local self = ui.panel.activeView.view.recipes
    if key == ISVehicleTuning2.upArrow then
        self.selected = self.selected - 1
        if self.selected <= 0 then
            self.selected = self.count
        end
    elseif key == ISVehicleTuning2.downArrow then
        self.selected = self.selected + 1
        if self.selected > self.count then
            self.selected = 1
        end
    end
    local viewIndex = ui.panel:getActiveViewIndex()
    local oldViewIndex = viewIndex
    if key == ISVehicleTuning2.leftCategory then
        if viewIndex == 1 then
            viewIndex = #ui.panel.viewList
        else
            viewIndex = viewIndex - 1
        end
    elseif key == ISVehicleTuning2.rightCategory then
        if viewIndex == #ui.panel.viewList then
            viewIndex = 1
        else
            viewIndex = viewIndex + 1
        end
    end
    if oldViewIndex ~= viewIndex then
        ui.panel:activateView(ui.panel.viewList[viewIndex].name)
    end
    ui.panel.activeView.view.recipes:ensureVisible(ui.panel.activeView.view.recipes.selected)
end

function ISVehicleTuning2:update()
    -- if self.craftInProgress then
        -- local currentAction = ISTimedActionQueue.getTimedActionQueue(self.character);
        -- if not currentAction or not currentAction.queue or not currentAction.queue[1] then
            -- self:refresh();
            -- self.craftInProgress = false
        -- end
    -- end
    if self.vehicle and self.character:DistToProper(self.vehicle) > 6 then
		self:close()
	elseif not self.vehicle or not self.vehicle:getSquare() or self.vehicle:getSquare():getMovingObjects():indexOf(self.vehicle) < 0 then
		self:close() -- handle vehicle being removed by admin/cheat command
	end
    if self.needRefreshIngredientPanel then
        self.needRefreshIngredientPanel = false
        self:refreshIngredientPanel()
    end
end

function ISVehicleTuning2:onResize()
    self.ingredientPanel:setWidth(self.width / 3)
    self.toolsPanel:setWidth(self.width / 3)
    self.resultPanel:setWidth(self.width / 3)
    if self.catListButtons then
        for _,button in ipairs(self.catListButtons) do
            button:setX(self.toolsPanel:getRight() + 10)
            button:setX(self.resultPanel:getRight() + 10)
        end
    end
end

-- создает список предметов, которые будут использованы для крафта
function ISVehicleTuning2:getAllRequiredItems(RecipeItem)
    local result = {}
    if RecipeItem.use then
        for _, itemInList in pairs(RecipeItem.use) do
            local fullType = itemInList.fullType
            local count = 0
            for _, itemCont in pairs(self.containerListLua) do
                local array = itemCont:FindAll(fullType)
                for i=0,array:size()-1 do
                    local itemFromInventory = array:get(i)
                    if itemFromInventory:IsDrainable() then -- если предмет расходуемый, считает количество доступного использования
                        local availableUses = itemFromInventory:getDrainableUsesInt()
                        if availableUses > 0 then
                            result[#result+1] = itemFromInventory
                            count = count + availableUses
                        end
                    else
                        result[#result+1] = itemFromInventory
                        count = count + 1
                    end
                    if count > itemInList.count then
                        break
                    end
                end
                if count > itemInList.count then
                    break
                end
            end
        end
    end
    if RecipeItem.tools then
        for _, itemInList in pairs(RecipeItem.tools) do
            local fullType = itemInList.fullType
            local count = 0
            for _, itemCont in pairs(self.containerListLua) do
                local array = itemCont:FindAll(fullType)
                for i=0,array:size()-1 do
                    result[#result+1] = array:get(i)
                    count = count + 1
                    if itemInList.count == count then
                        break
                    end
                end
                if itemInList.count == count then
                    break
                end
            end
        end
    end
    return result
end

function ISVehicleTuning2:equipRequiredItems(playerObj, tools, itemsUsed)
    -- print("ISVehicleTuning2:equipRequiredItems")
    for equip,toolItem in pairs(tools) do
        local item = nil
        for _,itemObj in ipairs(itemsUsed) do
            if itemObj:getFullType() == toolItem.fullType then
                item = itemObj
                break
            end
        end
        if item then
            if equip == "primary" then
                ISWorldObjectContextMenu.equip(playerObj, playerObj:getPrimaryHandItem(), item, true)
            elseif equip== "secondary" then
                ISWorldObjectContextMenu.equip(playerObj, playerObj:getSecondaryHandItem(), item, false)
            elseif equip == "both" then
                ISWorldObjectContextMenu.equip(playerObj, playerObj:getPrimaryHandItem(), item, false, true)
            elseif equip == "bodylocation" then
                if item:getCategory() == "Clothing" and item:getBodyLocation() ~= "" then
                    if not playerObj:getWornItem(item:getBodyLocation()) or 
                            (playerObj:getWornItem(item:getBodyLocation()) and 
                            playerObj:getWornItem(item:getBodyLocation()):getFullType() ~= toolItem.fullType) then
                        ISTimedActionQueue.add(ISWearClothing:new(playerObj, item, 50));
                    end
                end
            end
        end
    end
end

function ISVehicleTuning2:transferItems()
    local recipeListBox = self:getRecipeListBox()
    local RecipeItem = recipeListBox.items[recipeListBox.selected].item
    
    local items = self:getAllRequiredItems(RecipeItem)
    if #items == 0 then return result end
    for _,item in ipairs(items) do
        if item:getContainer() ~= self.character:getInventory() then
            ISTimedActionQueue.add(ISInventoryTransferAction:new(self.character, item, item:getContainer(), self.character:getInventory(), nil));
        end
    end
    return items
end

function ISVehicleTuning2:onInstallPart(button)
    -- print("ISVehicleTuning2:onInstallPart")
    self.craftInProgress = false
    local recipeListBox = self:getRecipeListBox()
    local RecipeItem = recipeListBox.items[recipeListBox.selected].item
    if not self:IsRecipeValid(RecipeItem) then return end
        if self.character:getVehicle() then
        ISVehicleMenu.onExit(self.character)
    end
    
    local itemsUsed = nil
    if not getPlayer() then return end
    if RecipeItem.use or RecipeItem.tools then
        itemsUsed = self:transferItems();
        if #itemsUsed == 0 then
            self:refresh();
            return
        end
    end

    -- TODO одевает и берет инструменты в руки
    if RecipeItem.tools then
        ISVehicleTuning2:equipRequiredItems(self.character, RecipeItem.tools, itemsUsed)
    end
    
    local part = self.vehicle:getPartById(RecipeItem.partName)
    local area = part:getArea()
    -- print(area)
    if RecipeItem.area then
        area = RecipeItem.area
    end
    -- print(area)
    if not area then print("ATA2: AREA for part not found: " .. RecipeItem.partName) end
    ISTimedActionQueue.add(ISPathFindAction:pathToVehicleArea(self.character, self.vehicle, area))
    
    if RecipeItem.type == "install" then
        -- print("install")
        local action = ISInstallTuningVehiclePart:new(self.character, part, RecipeItem.time, RecipeItem.modelName)
        ISTimedActionQueue.add(action);
    else
        -- print("uninstall")
        local action = ISUninstallTuningVehiclePart:new(self.character, part, RecipeItem.time, RecipeItem.modelName)
        ISTimedActionQueue.add(action);
    end
    -- print("close")
    self:close()
end

--***********************************************************
--**                         JOYPAD                        **
--***********************************************************

function ISVehicleTuning2:onGainJoypadFocus(joypadData)
	ISPanel.onGainJoypadFocus(self, joypadData)
    self.drawJoypadFocus = true
end

function ISVehicleTuning2:onJoypadDown(button)
    if button == Joypad.AButton then
        -- if self.ingredientListbox:getIsVisible() and not self.recipeListHasFocus then
            -- local item = self.ingredientListbox.items[self.ingredientListbox.selected]
            -- if item and item.item.available then
                -- self:addItemInEvolvedRecipe(item.item)
            -- end
        if self.craftOneButton.enable then
            self:onInstallPart()
        end
    end
    if button == Joypad.BButton then
        self:setVisible(false)
        setJoypadFocus(self.playerNum, nil)
    end

    if button == Joypad.LBumper or button == Joypad.RBumper then
        local viewIndex = self.panel:getActiveViewIndex()
        if button == Joypad.LBumper then
            if viewIndex == 1 then
                viewIndex = #self.panel.viewList
            else
                viewIndex = viewIndex - 1
            end
        elseif button == Joypad.RBumper then
            if viewIndex == #self.panel.viewList then
                viewIndex = 1
            else
                viewIndex = viewIndex + 1
            end
        end
        self.panel:activateView(self.panel.viewList[viewIndex].name)
        local recipeListBox = self:getRecipeListBox()
        recipeListBox:ensureVisible(recipeListBox.selected)
    end
end

function ISVehicleTuning2:onJoypadDirUp()
    if self.recipeListHasFocus then
        self:getRecipeListBox():onJoypadDirUp()
    elseif self.ingredientPanelHasFocus then
        self.ingredientPanel:onJoypadDirUp()
    elseif self.toolsPanelHasFocus then
        self.toolsPanel:onJoypadDirUp()
    elseif self.resultPanelHasFocus then
        self.resultPanel:onJoypadDirUp()
    end
end

function ISVehicleTuning2:onJoypadDirDown()
    if self.recipeListHasFocus then
        self:getRecipeListBox():onJoypadDirDown()
    elseif self.ingredientPanelHasFocus then
        self.ingredientPanel:onJoypadDirDown()
    elseif self.toolsPanelHasFocus then
        self.toolsPanel:onJoypadDirDown()
    elseif self.resultPanelHasFocus then
        self.resultPanel:onJoypadDirDown()
    end
end

function ISVehicleTuning2:onJoypadDirLeft()
    if self.resultPanelHasFocus then
        if self.toolsPanel:getIsVisible() then
            self.recipeListHasFocus = false
            self.ingredientPanelHasFocus = false
            self.toolsPanelHasFocus = true
            self.resultPanelHasFocus = false
        elseif self.ingredientPanel:getIsVisible() then
            self.recipeListHasFocus = false
            self.ingredientPanelHasFocus = true
            self.toolsPanelHasFocus = false
            self.resultPanelHasFocus = false
        else
            self.recipeListHasFocus = true
            self.ingredientPanelHasFocus = false
            self.toolsPanelHasFocus = false
            self.resultPanelHasFocus = false
        end
    elseif self.toolsPanelHasFocus then
        if self.ingredientPanel:getIsVisible() then
            self.recipeListHasFocus = false
            self.ingredientPanelHasFocus = true
            self.toolsPanelHasFocus = false
            self.resultPanelHasFocus = false
        else
            self.recipeListHasFocus = true
            self.ingredientPanelHasFocus = false
            self.toolsPanelHasFocus = false
            self.resultPanelHasFocus = false
        end
    elseif self.ingredientPanelHasFocus then
        self.recipeListHasFocus = true
        self.ingredientPanelHasFocus = false
        self.toolsPanelHasFocus = false
        self.resultPanelHasFocus = false
    end
end

function ISVehicleTuning2:onJoypadDirRight()
    if self.recipeListHasFocus then
        if self.ingredientPanel:getIsVisible() then
            self.recipeListHasFocus = false
            self.ingredientPanelHasFocus = true
            self.toolsPanelHasFocus = false
            self.resultPanelHasFocus = false
        elseif self.toolsPanel:getIsVisible() then
            self.recipeListHasFocus = false
            self.ingredientPanelHasFocus = false
            self.toolsPanelHasFocus = true
            self.resultPanelHasFocus = false
        elseif self.resultPanel:getIsVisible() then
            self.recipeListHasFocus = false
            self.ingredientPanelHasFocus = false
            self.toolsPanelHasFocus = false
            self.resultPanelHasFocus = true
        end
    elseif self.ingredientPanelHasFocus then
        if self.toolsPanel:getIsVisible() then
            self.recipeListHasFocus = false
            self.ingredientPanelHasFocus = false
            self.toolsPanelHasFocus = true
            self.resultPanelHasFocus = false
        elseif self.resultPanel:getIsVisible() then
            self.recipeListHasFocus = false
            self.ingredientPanelHasFocus = false
            self.toolsPanelHasFocus = false
            self.resultPanelHasFocus = true
        end
    elseif self.toolsPanelHasFocus then
        if self.resultPanel:getIsVisible() then
            self.recipeListHasFocus = false
            self.ingredientPanelHasFocus = false
            self.toolsPanelHasFocus = false
            self.resultPanelHasFocus = true
        end
    end
end


--***********************************************************
--**                          UTILS                        **
--***********************************************************

function ISVehicleTuning2.ReturnItemsToOriginalContainer(playerObj, items)
    for _,item in ipairs(items) do
        if item:getContainer() ~= playerObj:getInventory() then
            local action = ISInventoryTransferAction:new(playerObj, item, playerObj:getInventory(), item:getContainer(), nil)
            action:setAllowMissingItems(true)
            ISTimedActionQueue.add(action)
        end
    end
end

function ISVehicleTuning2:GetItemInstance(type)
    if not self.ItemInstances then self.ItemInstances = {} end
    local item = self.ItemInstances[type]
    if not item then
        item = InventoryItemFactory.CreateItem(type)
        if item then
            self.ItemInstances[type] = item
            self.ItemInstances[item:getFullType()] = item
        end
    end
    return item
end

function ISVehicleTuning2:debugGiveIngredients()
    -- print("ISVehicleTuning2:debugGiveIngredients()")
    local recipeListBox = self:getRecipeListBox()
    local RecipeItem = recipeListBox.items[recipeListBox.selected].item
    -- local recipe = RecipeItem.recipe
    local items = {}
    local options = {}
    if RecipeItem.use then
        for _,itemInList in ipairs(RecipeItem.use) do
            if itemInList.isDrainable then
                local count = 0
                while count < itemInList.count do
                    -- print("RecipeItem.use isDrainable count=" .. tostring(count))
                    -- print(itemInList.fullType)
                    -- print(itemInList.count)
                    local item = self.character:getInventory():AddItem(itemInList.fullType)
                    count = count + item:getDrainableUsesInt()
                end
            else
                for i=self.character:getInventory():FindAll(itemInList.fullType):size(),itemInList.count do
                    self.character:getInventory():AddItem(itemInList.fullType)
                end
            end
        end
    end
    if RecipeItem.tools then
        for _,itemInList in pairs(RecipeItem.tools) do
            for i=self.character:getInventory():FindAll(itemInList.fullType):size(),itemInList.count do
                self.character:getInventory():AddItem(itemInList.fullType)
            end
        end
    end
    if RecipeItem.recipes then
        for _,recipeName in pairs(RecipeItem.recipes) do
            if not self.character:isRecipeKnown(recipeName) then
                self.character:getKnownRecipes():add(recipeName);
            end
        end
    end
end
