-- require "ISUI/ISPanelJoypad"

ISBatteryACUI = ISPanelJoypad:derive("ISBatteryACUI");

--************************************************************************--
--** ISBatteryACUI:initialise
--**
--************************************************************************--

function ISBatteryACUI:createChildren()
	local btnWid = 100
	local btnHgt = 25
	local padBottom = 10
	
	self.close = ISButton:new(self:getWidth() - btnWid - 10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("UI_Close"), self, ISBatteryACUI.onClick);
	self.close.internal = "CLOSE";
	self.close.anchorTop = false
	self.close.anchorBottom = true
	self.close:initialise();
	self.close:instantiate();
	self.close.borderColor = {r=1, g=1, b=1, a=0.1};
	self:addChild(self.close);
	
	
	self.tempKnob = ISKnob:new(self:getWidth() / 2 - getTexture("media/ui/Knobs/KnobBG_AC.png"):getWidth() / 2,20,self.knobTex, getTexture("media/ui/Knobs/KnobBG_AC.png"), getText("IGUI_Temperature"), self.character);
	self.tempKnob:initialise();
	self.tempKnob:instantiate();
	self.tempKnob.onMouseUpFct = ISBatteryACUI.changeKnob;
	self.tempKnob.target = self;
	self:addChild(self.tempKnob);
		
	self.ok = ISButton:new(10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("ContextMenu_Turn_On"), self, ISBatteryACUI.onClick);
	self.ok.internal = "OK";
	self.ok.anchorTop = false
	self.ok.anchorBottom = true
	self.ok:initialise();
	self.ok:instantiate();
	self.ok.borderColor = {r=1, g=1, b=1, a=0.1};
	self:addChild(self.ok);
	
	self:addKnobValues();
	self:updateButtons();
	
	local currentTemp = self.heater:getModData().temperature;
	self.tempKnob:setKnobPosition(currentTemp);
	
	self:insertNewLineOfButtons(self.tempKnob)
	self:insertNewLineOfButtons(self.ok, self.close)
end

function ISBatteryACUI:changeKnob()
	sendClientCommand(self.character, 'commonlib', 'toggleBatteryHeater', { on = self.heater:getModData().active, temp = self.tempKnob:getValue() })
end

function ISBatteryACUI:update()
	self:updateButtons();
	self:centerOnScreen()
	if not self.character:getVehicle() or not (self.vehicle:getSeat(self.character) == self.seat) then
		self:removeFromUIManager()
	end
end

function ISBatteryACUI:updateButtons()
	if self.vehicle:getPartById("Battery"):getInventoryItem():getUsedDelta() > 0.1 then
		self.ok:setEnable(true);
		self.ok:setTooltip(nil);
	else
		self.ok:setEnable(false);
		self.ok:setTooltip(getText("Tooltip_Boat_LowBattery"));
	end
	if self.heater:getModData().active then
		self.ok:setTitle(getText("ContextMenu_Turn_Off"))
	else
		self.ok:setTitle(getText("ContextMenu_Turn_On"))
	end
end

function ISBatteryACUI:addKnobValues()
	self.tempKnob:addValue(0, 0);
	self.tempKnob:addValue(30, 8);
	self.tempKnob:addValue(60, 15);
	self.tempKnob:addValue(90, 25);
	self.tempKnob:addValue(270, -25);
	self.tempKnob:addValue(300, -15);
	self.tempKnob:addValue(330, -8);
end

function ISBatteryACUI:render()
	ISPanelJoypad.render(self);
	if self.vehicle:windowsOpen() > 0 then
		self:drawTextCentre(getText("UI_Vehicle_WindowOpen"), self:getWidth() / 2, 5, 1, 0, 0, 1, UIFont.Small);
	end
end

function ISBatteryACUI:prerender()
	self.backgroundColor.a = 0.7
	ISPanelJoypad.prerender(self);
end

function ISBatteryACUI:onClick(button)
	if button.internal == "CLOSE" then
		self:undisplay()
	end
	if button.internal == "OK" then
		CommonTemplates.Use.BatteryHeater(self.vehicle, not self.heater:getModData().active, self.tempKnob:getValue())
		-- sendClientCommand(self.character, 'vehicle', 'toggleHeater', { on = not self.heater:getModData().active, temp = self.tempKnob:getValue() })
		-- CommonTemplates.Use.BatteryHeater(part)
		-- self:undisplay()
	end
end

function ISBatteryACUI:undisplay()
	self:removeFromUIManager()
	if JoypadState.players[self.playerNum+1] then
		setJoypadFocus(self.playerNum, nil)
	end
end

function ISBatteryACUI:onGainJoypadFocus(joypadData)
	ISPanelJoypad.onGainJoypadFocus(self, joypadData)
	self.joypadIndexY = 1
	self.joypadIndex = 1
	self.joypadButtons = self.joypadButtonsY[self.joypadIndexY]
	self.joypadButtons[self.joypadIndex]:setJoypadFocused(true)
	self:setISButtonForA(self.ok)
	self:setISButtonForB(self.close)
end

function ISBatteryACUI:onJoypadDown(button)
	ISPanelJoypad.onJoypadDown(self, button)
	if button == Joypad.AButton then
		self:onClick(self.ok)
	end
	if button == Joypad.BButton then
		self:onClick(self.close)
	end
end

function ISBatteryACUI:centerOnScreen()
	local width = self:getWidth()
	local height = self:getHeight()
	local x = getPlayerScreenLeft(self.playerNum) + (getPlayerScreenWidth(self.playerNum) - width) / 2
	local y = getPlayerScreenTop(self.playerNum) + (getPlayerScreenHeight(self.playerNum) - height) / 2
	self:setX(x)
	self:setY(y)
end

function ISBatteryACUI:setVehicle(vehicle)
	self.vehicle = vehicle
	self.heater = vehicle:getPartById("BatteryHeater")
	self.seat = vehicle:getSeat(self.character)
	if not self.heater:getModData().temperature then
		self.heater:getModData().temperature = 0
	end
	local currentTemp = self.heater:getModData().temperature
	self.tempKnob:setKnobPosition(currentTemp)
end

--************************************************************************--
--** ISBatteryACUI:new
--**
--************************************************************************--
function ISBatteryACUI:new(x, y, character)
	local o = {}
	local width = 300;
	local height = 250;
	o = ISPanelJoypad:new(x, y, width, height);
	setmetatable(o, self)
	self.__index = self
	o.playerNum = character:getPlayerNum()
	if y == 0 then
		o.y = getPlayerScreenTop(o.playerNum) + (getPlayerScreenHeight(o.playerNum) - height) / 2
		o:setY(o.y)
	end
	if x == 0 then
		o.x = getPlayerScreenLeft(o.playerNum) + (getPlayerScreenWidth(o.playerNum) - width) / 2
		o:setX(o.x)
	end
	o.width = width;
	o.height = height;
	o.character = character;
	o.vehicle = character:getVehicle();
	o.heater = o.vehicle:getPartById("BatteryHeater");
	
	if not o.heater:getModData().temperature then o.heater:getModData().temperature = 0 end
	o.moveWithMouse = true;
	o.knobTex = getTexture("media/ui/Knobs/KnobDial.png");
	o.anchorLeft = true;
	o.anchorRight = true;
	o.anchorTop = true;
	o.anchorBottom = true;
	return o;
end
