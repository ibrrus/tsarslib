-- require "CommonTemplates/ISUI/ISContextMenuExtension" 

function ISContextMenu:updateOptionTsar(id, name, target, onSelect, param1, param2, param3, param4, param5, param6, param7, param8, param9, param10)
	local option = self:allocOption(name, target, onSelect, param1, param2, param3, param4, param5, param6, param7, param8, param9, param10);
	self.options[id] = option;
	return option;
end

function ISContextMenu:updateSubOptionTsar(subMenu, id, name, target, onSelect, param1, param2, param3, param4, param5, param6, param7, param8, param9, param10)
	local option = self:allocOption(name, target, onSelect, param1, param2, param3, param4, param5, param6, param7, param8, param9, param10);
	subMenu.options[id] = option;
	return option;
end

function ISContextMenu:updateSubOption2Tsar(parentMenuName, subMenuName, newFunc, param1, param2, param3, param4, param5, param6, param7, param8, param9, param10)
	local numSubOption = self:getOptionFromName(parentMenuName).subOption
	local subContext = self.instanceMap[numSubOption] -- context
	local subMenu = subContext:getOptionFromName(subMenuName)
	local option = self:allocOption(subMenu.name, subMenu.target, newFunc, param1, param2, param3, param4, param5, param6, param7, param8, param9, param10);
	subContext.options[subMenu.id] = option;
	return option;
end

function ISContextMenu:removeOptionTsar(option)
	-- print("ISContextMenu:removeOption")
	if option then
		table.insert(self.optionPool, self.options[option.id])
		self.options[option.id] =  nil;
		for i = option.id, self.numOptions - 1 do
			self.options[i] = self.options[i+1]
			if self.options[i] then
				self.options[i].id = i
			end
		end
		self.numOptions = self.numOptions - 1;
		self:calcHeight()
	end
end

-- function ISContextMenu:getOptionFromItemNameTsar(name)
	-- for i,v in ipairs(self.options) do
		-- for m,n in pairs(v) do
			
		-- end
		-- -- if v.name == name then
			-- -- return v;
		-- -- end
	-- end
-- end

-- Examples
-- context:removeOptionTsar(context:getOptionFromName(getText("ContextMenu_GeneratorFix")))

-- local old_option_update = context:getOptionFromName(getText("ContextMenu_GeneratorUnplug"))
-- if old_option_update then
	-- context:updateOptionTsar(old_option_update.id, old_option_update.name, old_option_update.target, ISWorldObjectContextMenuForTrailerGenerator.generatorUnplug, playerObj, trailer)
-- end	