-- require "ISUI/CommonISContextMenu" 

function ISContextMenu:updateOption(id, name, target, onSelect, param1, param2, param3, param4, param5, param6, param7, param8, param9, param10)
	local option = self:allocOption(name, target, onSelect, param1, param2, param3, param4, param5, param6, param7, param8, param9, param10);
	self.options[id] = option;
	return option;
end

function ISContextMenu:updateSubOption(subMenu, id, name, target, onSelect, param1, param2, param3, param4, param5, param6, param7, param8, param9, param10)
	local option = self:allocOption(name, target, onSelect, param1, param2, param3, param4, param5, param6, param7, param8, param9, param10);
	subMenu.options[id] = option;
	return option;
end

function ISContextMenu:removeOption(option)
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

-- Examples
-- context:removeOption(context:getOptionFromName(getText("ContextMenu_GeneratorFix")))

-- local old_option_update = context:getOptionFromName(getText("ContextMenu_GeneratorUnplug"))
-- if old_option_update then
	-- context:updateOption(old_option_update.id, old_option_update.name, old_option_update.target, ISWorldObjectContextMenuForTrailerGenerator.generatorUnplug, playerObj, trailer)
-- end	