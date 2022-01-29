local function Set (list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end

function ISRadialMenu:updateSliceTsar(oldtext, newtext, newtexture, newcommand, arg1, arg2, arg3, arg4, arg5, arg6)
	for sliceIndex, slice in ipairs(self.slices) do
		if slice.text == oldtext then
			if newtext then
				slice.text = newtext
				if self.javaObject then
					self.javaObject:setSliceText(sliceIndex-1, newtext)
				end
			end
			if newtexture then
				slice.texture = newtexture
				if self.javaObject then
					self.javaObject:setSliceTexture(sliceIndex-1, newtexture)
				end
			end
			if newcommand == false then
                slice.command = { nil, nil, nil, nil, nil, nil, nil }
            elseif newcommand then
				slice.command = { newcommand, arg1, arg2, arg3, arg4, arg5, arg6 }
			end
			return true
		end
	end
	return false
end

function ISRadialMenu:blockSliceTsar(oldtext)
	for sliceIndex, slice in ipairs(self.slices) do
		if slice.text == oldtext then
			slice.text = getText("IGUI_XP_Locked")
			slice.texture = getTexture("media/ui/commonlibrary/no.png")
			if self.javaObject then
				self.javaObject:setSliceText(sliceIndex-1, slice.text)
				self.javaObject:setSliceTexture(sliceIndex-1, slice.texture)
			end
			slice.command = { nil, nil, nil, nil, nil, nil, nil }
			return true
		end
	end
	return false
end


--menu:deleteMultiSliceTsar({text1, text2, text3})
function ISRadialMenu:deleteMultiSliceTsar(textTableForDelete)
	if type(textTableForDelete) == "table" then
		local textTableForDeleteSet = Set(textTableForDelete)
		local oldSlices = self.slices
		self.slices = {}
		if self.javaObject then
			self.javaObject:clear()
		end
		for sliceIndex, oldSlice in ipairs(oldSlices) do
			if not textTableForDeleteSet[oldSlice.text] then
				local slice = {}
				slice.text = oldSlice.text
				slice.texture = oldSlice.texture
				slice.command = oldSlice.command
				table.insert(self.slices, slice)
				if self.javaObject then
					self.javaObject:addSlice(oldSlice.text, oldSlice.texture)
				end
			end
		end
	end
end