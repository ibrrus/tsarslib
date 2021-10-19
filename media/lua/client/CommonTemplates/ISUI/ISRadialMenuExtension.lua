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
			if newcommand then
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