require "ISUI/ISPanelJoypad"

ISPortableMicrowaveUI = ISPanelJoypad:derive("ISPortableMicrowaveUI");
ISPortableMicrowaveUI.messages = {};

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

--************************************************************************--
--** ISPortableMicrowaveUI:initialise
--**
--************************************************************************--

function ISPortableMicrowaveUI:initialise()
    ISPanel.initialise(self);
    local btnWid = 100
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
    local padBottom = 10

    self.close = ISButton:new(self:getWidth() - btnWid - 10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("UI_Cancel"), self, ISPortableMicrowaveUI.onClick);
    self.close.internal = "CLOSE";
    self.close.anchorTop = false
    self.close.anchorBottom = true
    self.close:initialise();
    self.close:instantiate();
    self.close.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.close);

    self.tempKnob = ISKnob:new(20,40,getTexture("media/ui/Knobs/KnobDial.png"), getTexture("media/ui/Knobs/KnobBGMicrowaveTemp.png"), getText("IGUI_Temperature"), self.character);
    self.tempKnob:initialise();
    self.tempKnob:instantiate();
    self.tempKnob.onMouseUpFct = ISPortableMicrowaveUI.ChangeKnob;
    self.tempKnob.target = self;
    self:addChild(self.tempKnob);

    self.timerKnob = ISKnob:new(self.tempKnob.width + 70,40,getTexture("media/ui/Knobs/KnobDial.png"), getTexture("media/ui/Knobs/KnobBGMicrowaveTimer.png"), getText("IGUI_Timer"), self.character);
    self.timerKnob:initialise();
    self.timerKnob:instantiate();
    self.timerKnob.onMouseUpFct = ISPortableMicrowaveUI.ChangeKnob;
    self.timerKnob.target = self;
    self:addChild(self.timerKnob);
    

    
    -- self:setHeight(self.close:getBottom() + padBottom)
    
    self:addKnobValues();
    self:updateButtons();
    
    self:insertNewLineOfButtons(self.tempKnob, self.timerKnob, self.ok, self.close)
end

function ISPortableMicrowaveUI:ChangeKnob()
    self.oven:getModData().tsarslib.maxTemperature = self.tempKnob:getValue()
    self.oven:getModData().tsarslib.timer = self.timerKnob:getValue()
    self.vehicle:getEmitter():playSound("ToggleStove")
    if self.oven:getModData().tsarslib.timer > 0 then
        sendClientCommand(self.character, 'commonlib', 'usePortableMicrowave', {vehicle = self.vehicle:getId(), oven = self.oven:getId(), on = true, timer = self.oven:getModData().tsarslib.timer, maxTemperature = self.oven:getModData().tsarslib.maxTemperature})
        if not self.vehicle:getEmitter():isPlaying("MicrowaveRunning") then
            self.vehicle:getEmitter():playSoundLooped("MicrowaveRunning")
        end
    else
        sendClientCommand(self.character, 'commonlib', 'usePortableMicrowave', {vehicle = self.vehicle:getId(), oven = self.oven:getId(), on = false, timer = self.oven:getModData().tsarslib.timer, maxTemperature = self.oven:getModData().tsarslib.maxTemperature})
        self.vehicle:getEmitter():stopSoundByName("MicrowaveRunning")
        if self.oven:getModData().tsarslib.timePassed > 0 then
            self.vehicle:getEmitter():playSound("MicrowaveTimerExpired")
        end
    end
end

function ISPortableMicrowaveUI:update()
    self:updateButtons();
    if not self.character:getVehicle() or not (self.vehicle:getSeat(self.character) == self.seat) then
        self:setVisible(false);
        self:removeFromUIManager();
    end
end

function ISPortableMicrowaveUI:updateButtons()
    if not self.timerKnob.dragging then
        if self.oven:getModData().tsarslib.timePassed > 0 then
            self.timerKnob:setKnobPosition(math.ceil((self.oven:getModData().tsarslib.timer - self.oven:getModData().tsarslib.timePassed)))
        else
            self.timerKnob:setKnobPosition(self.oven:getModData().tsarslib.timer);
        end
    end
    if not self.tempKnob.dragging then
        self.tempKnob:setKnobPosition(self.oven:getModData().tsarslib.maxTemperature);
    end
end

function ISPortableMicrowaveUI:addKnobValues()
    self.tempKnob:addValue(0, 90);
    self.tempKnob:addValue(45, 110);
    self.tempKnob:addValue(90, 130);
    self.tempKnob:addValue(270, 50);
    self.tempKnob:addValue(315, 70);

    self.timerKnob:addValue(0, 0);
    self.timerKnob:addValue(18, 1);
    self.timerKnob:addValue(36, 2);
    self.timerKnob:addValue(54, 3);
    self.timerKnob:addValue(72, 4);
    self.timerKnob:addValue(90, 5);
    self.timerKnob:addValue(108, 6);
    self.timerKnob:addValue(126, 7);
    self.timerKnob:addValue(144, 8);
    self.timerKnob:addValue(162, 9);
    self.timerKnob:addValue(180, 10);
    self.timerKnob:addValue(198, 15);
    self.timerKnob:addValue(216, 20);
    self.timerKnob:addValue(234, 25);
    self.timerKnob:addValue(252, 30);
    self.timerKnob:addValue(270, 45);
    self.timerKnob:addValue(288, 60);
end

function ISPortableMicrowaveUI:render()
    ISPanelJoypad.render(self);
--    self:drawTextCentre(math.floor(self.oven:getCurrentTemperature()) .. "", self.width/2, 5, 1, 1, 1, 1, self.font);
end

function ISPortableMicrowaveUI:prerender()
    ISPanelJoypad.prerender(self);
end

function ISPortableMicrowaveUI:onClick(button)
    if button.internal == "CLOSE" then
        self:setVisible(false);
        self:removeFromUIManager();
        local player = self.character:getPlayerNum()
        if JoypadState.players[player+1] then
            setJoypadFocus(player, self.prevFocus)
        end
    end
    -- if button.internal == "OK" then
        
    -- end
end

function ISPortableMicrowaveUI:onGainJoypadFocus(joypadData)
    ISPanelJoypad.onGainJoypadFocus(self, joypadData)
    self.joypadIndexY = 1
    self.joypadIndex = 1
    self.joypadButtons = self.joypadButtonsY[self.joypadIndexY]
    self.joypadButtons[self.joypadIndex]:setJoypadFocused(true)
    self:setISButtonForA(self.ok)
    self:setISButtonForB(self.close)
end

function ISPortableMicrowaveUI:onJoypadDown(button)
    ISPanelJoypad.onJoypadDown(self, button)
    if button == Joypad.AButton then
        self:onClick(self.ok)
    end
    if button == Joypad.BButton then
        self:onClick(self.close)
    end
end

--************************************************************************--
--** ISPortableMicrowaveUI:new
--**
--************************************************************************--
function ISPortableMicrowaveUI:new(x, y, width, height, character, vehicle, part)
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
    o.anchorLeft = true;
    o.anchorRight = true;
    o.anchorTop = true;
    o.anchorBottom = true;
    return o;
end
