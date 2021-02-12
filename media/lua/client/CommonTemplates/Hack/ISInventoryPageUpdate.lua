
function ISInventoryPage:initialise()
	self.containerIconMaps["portablemicrowave"] = getTexture("media/ui/Container_Microwave.png")
	self.containerIconMaps["seatboxwooden"] = getTexture("media/ui/commonlibrary/Container_seatBoxWooden.png")
	ISPanel.initialise(self);
end