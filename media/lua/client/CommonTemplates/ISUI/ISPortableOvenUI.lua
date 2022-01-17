require "ISUI/ISPanelJoypad"
--***********************************************************
--**              	  ROBERT JOHNSON                       **
--***********************************************************

ISPortableOvenUI = ISPanelJoypad:derive("ISPortableOvenUI");
ISPortableOvenUI.messages = {};

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

--************************************************************************--
--** ISPortableOvenUI:initialise
--**
--************************************************************************--

function ISPortableOvenUI:initialise()
    ISPanel.initialise(self);
    local btnWid = 100
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
    local padBottom = 10

    self.close = ISButton:new(self:getWidth() - btnWid - 10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("UI_Cancel"), self, ISPortableOvenUI.onClick);
    self.close.internal = "CLOSE";
    self.close.anchorTop = false
    self.close.anchorBottom = true
    self.close:initialise();
    self.close:instantiate();
    self.close.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.close);


    self.tempKnob = ISKnob:new(20,40,self.knobTex, getTexture("media/ui/Knobs/KnobBGFarhenOvenTemp.png"), getText("IGUI_Temperature"), self.character);
    self.tempKnob:initialise();
    self.tempKnob:instantiate();
    self.tempKnob.onMouseUpFct = ISPortableOvenUI.ChangeKnob;
    self.tempKnob.target = self;
    self:addChild(self.tempKnob);

    self.tempType = ISTickBox:new(20, self.tempKnob.y + self.tempKnob.height + 10, getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_Oven_Fahrenheit")) + 20, 18, "", self, ISPortableOvenUI.onChangeTempType);
    self.tempType:initialise();
    self.tempType:instantiate();
    self.tempType:addOption(getText("IGUI_Oven_Fahrenheit"));
    self.tempType:addOption(getText("IGUI_Oven_Celsius"));
    self.tempType.selected[1] = not getCore():isCelsius();
    self.tempType.selected[2] = getCore():isCelsius();
    self:addChild(self.tempType);

    self:changeTempType();

    self.timerKnob = ISKnob:new(self.tempKnob.width + 70,40,self.knobTex, getTexture("media/ui/Knobs/KnobBGOvenTimer.png"), getText("IGUI_Timer"), self.character);
    self.timerKnob:initialise();
    self.timerKnob:instantiate();
    self.timerKnob.onMouseUpFct = ISPortableOvenUI.ChangeKnob;
    self.timerKnob.target = self;
    self:addChild(self.timerKnob);

    self.ok = ISButton:new(10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("ContextMenu_Turn_On"), self, ISPortableOvenUI.onClick);
    self.ok.internal = "OK";
    self.ok.anchorTop = false
    self.ok.anchorBottom = true
    self.ok:initialise();
    self.ok:instantiate();
    self.ok.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.ok);

    self:addKnobValues();
    self:updateButtons();
	
	self:insertNewLineOfButtons(self.tempKnob, self.timerKnob, self.tempType)
    self:insertNewLineOfButtons(self.ok, self.close)
end

function ISPortableOvenUI:onChangeTempType(clickedOption, enabled)
    self.tempType.selected[1] = false;
    self.tempType.selected[2] = false;
    self.tempType.selected[clickedOption] = true;
    getCore():setCelsius(self.tempType.selected[2]);
    getCore():saveOptions();
    self:changeTempType();
end

function ISPortableOvenUI:changeTempType()
    if not getCore():isCelsius() then -- farenheit
        self.tempKnob.valuesBg = getTexture("media/ui/Knobs/KnobBGFarhenOvenTemp.png");
    else -- celsius
        self.tempKnob.valuesBg = getTexture("media/ui/Knobs/KnobBGCelciusOvenTemp.png");
    end
end

function ISPortableOvenUI:ChangeKnob()
    self.oven:getModData().maxTemperature = self.tempKnob:getValue()
    self.oven:getModData().timer = self.timerKnob:getValue()
	self.oven:getModData().timePassed = 0
    self.vehicle:transmitPartModData(self.oven)
end

function ISPortableOvenUI:update()
    self:updateButtons();
	if not self.character:getVehicle() or not (self.vehicle:getSeat(self.character) == self.seat) then
        self:setVisible(false);
        self:removeFromUIManager();
    end
end

function ISPortableOvenUI:updateButtons()
    if not self.timerKnob.dragging then	
        if self.oven:getModData().timePassed > 0 then
            self.timerKnob:setKnobPosition(math.ceil((self.oven:getModData().timer - self.oven:getModData().timePassed)));
        else
            self.timerKnob:setKnobPosition(self.oven:getModData().timer);
        end
    end
    if not self.tempKnob.dragging then
        self.tempKnob:setKnobPosition(self.oven:getModData().maxTemperature);
    end
    if self.oven:getItemContainer():isActive() then
		self.ok:setTitle(getText("ContextMenu_Turn_Off"))
    else
        self.ok:setTitle(getText("ContextMenu_Turn_On"))
    end
    self.ok:setEnable(true)
end

function ISPortableOvenUI:addKnobValues()
    self.tempKnob:addValue(0, 0);
    self.tempKnob:addValue(45, 50);
    self.tempKnob:addValue(90, 100);
    self.tempKnob:addValue(135, 150);
    self.tempKnob:addValue(180, 200);
    self.tempKnob:addValue(225, 250);
    self.tempKnob:addValue(270, 300);

    self.timerKnob:addValue(0, 0);
    self.timerKnob:addValue(18, 1);
    self.timerKnob:addValue(36, 2);
    self.timerKnob:addValue(54, 3);
    self.timerKnob:addValue(72, 4);
    self.timerKnob:addValue(90, 5);
    self.timerKnob:addValue(108, 10);
    self.timerKnob:addValue(126, 15);
    self.timerKnob:addValue(144, 20);
    self.timerKnob:addValue(162, 25);
    self.timerKnob:addValue(180, 30);
    self.timerKnob:addValue(198, 40);
    self.timerKnob:addValue(216, 50);
    self.timerKnob:addValue(234, 60);
    self.timerKnob:addValue(252, 90);
    self.timerKnob:addValue(270, 120);
end

function ISPortableOvenUI:render()
    ISPanelJoypad.render(self);
--    self:drawTextCentre(math.floor(self.oven:getCurrentTemperature()) .. "", self.width/2, 5, 1, 1, 1, 1, self.font);
end

function ISPortableOvenUI:prerender()
    ISPanelJoypad.prerender(self);
end

function ISPortableOvenUI:onClick(button)
    if button.internal == "CLOSE" then
        self:setVisible(false);
        self:removeFromUIManager();
		local player = self.character:getPlayerNum()
        if JoypadState.players[player+1] then
            setJoypadFocus(player, self.prevFocus)
        end
    end
    if button.internal == "OK" then
        self.oven:getModData().maxTemperature = self.tempKnob:getValue()
		self.oven:getModData().timer = self.timerKnob:getValue()
        self.vehicle:transmitPartModData(self.oven)
		CommonTemplates.Use.DefaultDevice(self.vehicle, self.oven, self.character)
        -- self.oven:Toggle();
    end
end

function ISPortableOvenUI:onGainJoypadFocus(joypadData)
    ISPanelJoypad.onGainJoypadFocus(self, joypadData)
    self.joypadIndexY = 1
    self.joypadIndex = 1
    self.joypadButtons = self.joypadButtonsY[self.joypadIndexY]
    self.joypadButtons[self.joypadIndex]:setJoypadFocused(true)
    self:setISButtonForA(self.ok)
    self:setISButtonForB(self.close)
end

function ISPortableOvenUI:onJoypadDown(button)
    ISPanelJoypad.onJoypadDown(self, button)
    if button == Joypad.AButton then
        self:onClick(self.ok)
    end
    if button == Joypad.BButton then
        self:onClick(self.close)
    end
end

--************************************************************************--
--** ISPortableOvenUI:new
--**
--************************************************************************--
function ISPortableOvenUI:new(x, y, width, height, character, vehicle, part)
    local o = {}
    o = ISPanelJoypad:new(x, y, width, height);
    setmetatable(o, self)
    self.__index = self
	local player = character:getPlayerNum()
    if y == 0 then
        o.y = getPlayerScreenTop(player) + (getPlayerScreenHeight(player) - height) / 2
        o:setY(o.y)
    end
    if x == 0 then
        o.x = getPlayerScreenLeft(player) + (getPlayerScreenWidth(player) - width) / 2
        o:setX(o.x)
    end
    o.backgroundColor.a = 0.75
    o.width = width;
    o.height = height;
	
    o.character = character;
	o.vehicle = vehicle
	o.seat = vehicle:getSeat(character)
    o.oven = part;
	
    o.moveWithMouse = true;
    o.knobTex = getTexture("media/ui/Knobs/KnobDial.png");
    o.anchorLeft = true;
    o.anchorRight = true;
    o.anchorTop = true;
    o.anchorBottom = true;
    return o;
end
