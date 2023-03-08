--***********************************************************
--**                    ROBERT JOHNSON                     **
--***********************************************************

-- Отвечает за вкладки в меню тюнинга и список всех рецептов

ISVehicleTuning2Category = ISPanelJoypad:derive("ISVehicleTuning2Category");
ISVehicleTuning2Category.instance = nil;
ISVehicleTuning2Category.SMALL_FONT_HGT = getTextManager():getFontFromEnum(UIFont.Small):getLineHeight()
ISVehicleTuning2Category.MEDIUM_FONT_HGT = getTextManager():getFontFromEnum(UIFont.Medium):getLineHeight()

function ISVehicleTuning2Category:initialise()
    ISPanelJoypad.initialise(self);
    self:create();
end

function ISVehicleTuning2Category:update()
    if not self.parent:getIsVisible() then return; end
    self.recipes:setWidth(self.width / 3)
end

function ISVehicleTuning2Category:prerender()
    self.recipes.backgroundColor.a = 0.8
    self.recipes.doDrawItem = ISVehicleTuning2Category.drawRecipesMap
end

function ISVehicleTuning2Category:drawRecipesMap(y, item, alt)
    local baseItemDY = 0
    local RecipeItem = item.item
    if RecipeItem.customRecipeName then
        baseItemDY = self.SMALL_FONT_HGT
        item.height = self.itemheight + baseItemDY
    end

    if y + self:getYScroll() >= self.height then return y + item.height end
    if y + item.height + self:getYScroll() <= 0 then return y + item.height end

    local a = 0.9;
    
    if not RecipeItem.available then
        a = 0.3;
    end

    self:drawRectBorder(0, (y), self:getWidth(), item.height - 1, a, self.borderColor.r, self.borderColor.g, self.borderColor.b);

    if self.selected == item.index then
        self:drawRect(0, (y), self:getWidth(), item.height - 1, 0.3, 0.7, 0.35, 0.15);
    end

    local textWidth = 0;
    if RecipeItem.icon then
        local texWidth = RecipeItem.icon:getWidthOrig();
        local texHeight = RecipeItem.icon:getHeightOrig();
        
        if texWidth <= 32 and texHeight <= 32 then
            self:drawTexture(RecipeItem.icon,6 + (32-texWidth)/2, y + 11 + (32-texHeight)/2,a,1,1,1);
        else
            self:drawTextureScaledAspect(RecipeItem.icon,6, y + 11,32,32,a,1,1,1);
        end
        
        -- local name = item.item.evolved and item.item.resultName or item.item.itemName
        -- self:drawText(name, texWidth + 20, y + 2 + self.MEDIUM_FONT_HGT + baseItemDY + (32 - self.SMALL_FONT_HGT) / 2 - 2, 1, 1, 1, a, UIFont.Small);
    end
    -- local r = 1
    -- local g = 1
    -- local b = 1
    if RecipeItem.condition then
        local condRGB = ISVehicleMechanics:getConditionRGB(RecipeItem.condition)
        -- local text = RecipeItem.itemName .. " (" .. tostring(RecipeItem.condition) .. "%)"
        self:drawText(getText("IGUI_TuningUI_Condition") .. " " .. tostring(RecipeItem.condition) .. "%", 6 + 32 + 6 + 115, y + 4, condRGB.r, condRGB.g, condRGB.b, 0.9, UIFont.Small);
        -- self:drawText(RecipeItem.itemName, 6 + 32 + 6, y + 15, condRGB.r, condRGB.g, condRGB.b, a, UIFont.Medium);
    -- else
        -- self:drawText(RecipeItem.itemName, 6 + 32 + 6, y + 15, 1, 1, 1, a, UIFont.Medium);
    end
    self:drawText(RecipeItem.itemName, 6 + 32 + 6, y + 15, 1, 1, 1, a, UIFont.Medium);
    -- if RecipeItem.customRecipeName then
        -- self:drawText(RecipeItem.customRecipeName, 6 + 32 + 6, y + 15 + self.MEDIUM_FONT_HGT, 1, 1, 1, a, UIFont.Small);
    -- end
    -- print(self.character)
    if RecipeItem.recipeNotLearn and RecipeItem.recipeNotLearn ~= "" then
        self:drawText(getText("IGUI_TuningUI_NotLearn"), 6 + 32 + 6, y + 15 + self.MEDIUM_FONT_HGT, 1, 0, 0, a, UIFont.Small);
    elseif RecipeItem.error then
        self:drawText(RecipeItem.error, 6 + 32 + 6, y + 15 + self.MEDIUM_FONT_HGT, 1, 0, 0, a, UIFont.Small);
    -- elseif RecipeItem.condition then
        -- local condRGB = ISVehicleMechanics:getConditionRGB(RecipeItem.condition)
        -- self:drawText(getText("IGUI_TuningUI_Condition") .. " " .. tostring(RecipeItem.condition) .. "%", 6 + 32 + 6, y + 15 + self.MEDIUM_FONT_HGT, condRGB.r, condRGB.g, condRGB.b, a, UIFont.Medium);
    end
    
    local categoryUI = self.parent
    return y + item.height;
end

function ISVehicleTuning2Category:onMouseDown_Recipes(x, y)
    local row = self:rowAt(x, y)
    if row == -1 then return end
    -- if self.parent:isMouseOverFavorite(x) then
        -- self.parent:addToFavorite(false)
    if not self:isMouseOverScrollBar() then
        self.selected = row;
    end
end

function ISVehicleTuning2Category:create()
    local fontHgtSmall = self.SMALL_FONT_HGT
    -- local entryHgt = fontHgtSmall + 2 * 2

    self.recipes = ISScrollingListBox:new(1, 0, self.width / 3, self.height);
    self.recipes:initialise();
    self.recipes:instantiate();
    self.recipes:setAnchorRight(false) -- resize in update()
    self.recipes:setAnchorBottom(true)
    self.recipes.itemheight = 2 + self.MEDIUM_FONT_HGT + 32 + 4;
    self.recipes.selected = 1;
    self.recipes.doDrawItem = ISVehicleTuning2Category.drawRecipesMap;
    self.recipes.onMouseDown = ISVehicleTuning2Category.onMouseDown_Recipes;
    -- self.recipes.onMouseDoubleClick = ISVehicleTuning2Category.onMouseDoubleClick_Recipes;
    self.recipes.joypadParent = self;
--    self.recipes.resetSelectionOnChangeFocus = true;
    self.recipes.drawBorder = false;
    self:addChild(self.recipes);

    self.recipes.SMALL_FONT_HGT = self.SMALL_FONT_HGT
    self.recipes.MEDIUM_FONT_HGT = self.MEDIUM_FONT_HGT
end


function ISVehicleTuning2Category:new (x, y, width, height, tuningUI)
    -- print("ISVehicleTuning2Category:new")
    local o = {};
    o = ISPanelJoypad:new(x, y, width, height);
    setmetatable(o, self);
    self.__index = self;
    o.tuningUI = tuningUI
    o.character = tuningUI.character;
    o:noBackground();
    ISVehicleTuning2Category.instance = o;
    return o;
end
