-- if debugScenarios == nil then
	-- debugScenarios = {}
-- end


debugScenarios.IBrRusScenario_ATA = {
	name = "ATA",
	isCustom = true,
--	forceLaunch = true, -- use this to force the launch of THIS scenario right after main menu was loaded, save more clicks! Don't do multiple scenarii with this options
	startLoc = {x=3685, y=5790, z=0 }, 
	
	setSandbox = function()
		SandboxVars.MaxFogIntensity = 3;	-- low fog
		SandboxVars.VehicleStoryChance = 6;
		SandboxVars.Helicopter = 1;	-- never helicopter
		SandboxVars.Zombies = 2; -- 5 = no zombies, 1 = insane (then 2 = low, 3 normal, 4 high..)
		SandboxVars.StarterKit = false;
		SandboxVars.StartTime = 23;
		SandboxVars.WaterShutModifier = -1;
        SandboxVars.ElecShutModifier = -1;
	end,

	onStart = function()
		-- climate
		-- local clim = getClimateManager();
		-- local w = clim:getWeatherPeriod();
		-- if w:isRunning() then
			-- clim:stopWeatherAndThunder();
		-- end
		-- remove fog
		-- local var = clim:getClimateFloat(5);
		-- var:setEnableOverride(true);
		-- var:setOverride(0, 1);
		--------------------------------

		-- Player
		local playerObj = getPlayer();
		local inv = playerObj:getInventory();
		local visual = playerObj:getHumanVisual();

		playerObj:setGhostMode(true);
		-- playerObj:setGodMod(true)
		
		playerObj:clearWornItems();
		playerObj:getInventory():clear();

		-- Visual
		playerObj:setFemale(false);
		playerObj:getDescriptor():setFemale(false);
		playerObj:getDescriptor():setForename("IBrRus")
		playerObj:getDescriptor():setSurname("")
		visual:setBeardModel("Full");
		visual:setHairModel("Messy");
		local immutableColor = ImmutableColor.new(0.105, 0.09, 0.086, 1)
		visual:setHairColor(immutableColor)
		visual:setBeardColor(immutableColor)
		visual:setSkinTextureIndex(2);
		playerObj:resetModel();

		clothe = inv:AddItem("Base.Tshirt_DefaultTEXTURE_TINT");
		local color = ImmutableColor.new(0.25, 0.36, 0.36, 1)
		clothe:getVisual():setTint(color);
		playerObj:setWornItem(clothe:getBodyLocation(), clothe);
		clothe = inv:AddItem("Base.Trousers_Denim");
		clothe:getVisual():setTextureChoice(1);
		playerObj:setWornItem(clothe:getBodyLocation(), clothe);
		clothe = inv:AddItem("Base.Socks_Ankle");
		playerObj:setWornItem(clothe:getBodyLocation(), clothe);
		clothe = inv:AddItem("Base.Shoes_Black");
		playerObj:setWornItem(clothe:getBodyLocation(), clothe);
		--------------------------------------

		-- Skills
		for i=1, 10 do
			playerObj:LevelPerk(Perks.Mechanics);
		end
		-- all the perks are: Agility, Cooking, Melee, Crafting, Fitness, Strength, Blunt, Axe, Sprinting, Lightfoot, 
		--Nimble, Sneak, Woodwork, Aiming, Reloading, Farming, Survivalist, Fishing, Trapping, Passiv, Firearm, PlantScavenging, 
		--Doctor, Electricity, Blacksmith, MetalWelding, Melting, Mechanics, Spear, Maintenance, SmallBlade, LongBlade, SmallBlunt, Combat,

		getPlayer():getKnownRecipes():add("Basic Mechanics");
		getPlayer():getKnownRecipes():add("Intermediate Mechanics");
		getPlayer():getKnownRecipes():add("Advanced Mechanics");
		getPlayer():getKnownRecipes():add("Generator");

		-- Items
		-- playerObj:getInventory():AddItem("TowingCar.TowBar");
		playerObj:getInventory():AddItem("Base.Wrench");
		playerObj:getInventory():AddItem("Base.LugWrench");
		playerObj:getInventory():AddItem("Base.Screwdriver");
		playerObj:getInventory():AddItem("Base.Jack");
		playerObj:getInventory():AddItem("Base.Paintbrush");
		playerObj:getInventory():AddItem("Base.PaintRed");
		
		playerObj:getInventory():AddItem("Base.556Clip");
		for i=1,20 do
			playerObj:getInventory():AddItem("Base.556Bullets");
		end
		playerObj:getInventory():AddItem("Base.AssaultRifle");
		-- playerObj:getInventory():AddItem("Base.Generator");
		-- playerObj:getInventory():AddItem("Base.EmptyPetrolCan");
		-- playerObj:getInventory():AddItem("Base.PetrolCan");
		-- playerObj:getInventory():AddItem("Base.PotOfSoupRecipe");
		-- playerObj:getInventory():AddItem("Base.PotOfSoupRecipe");
		-- itemB = playerObj:getInventory():AddItem("Base.Battery");
		-- itemB:setUsedDelta(0)
		-- itemB = playerObj:getInventory():AddItem("Base.Battery");
		-- itemB:setUsedDelta(0)
		-- itemB = playerObj:getInventory():AddItem("Base.Battery");
		-- itemB:setUsedDelta(0)

		-- Trailers
		local vehY = 5785.5
		local vehX = 3671
		local yShift = 3.2
		
		-- addVehicleDebug("Base.TrailerGenerator", IsoDirections.E, nil, getCell():getGridSquare(vehX, vehY-yShift*1, 0));
		-- addVehicleDebug("Base.TrailerFirst", IsoDirections.E, nil, getCell():getGridSquare(vehX, vehY, 0));
		local car = addVehicleDebug("Base.ATAJeepArcher", IsoDirections.E, nil, getCell():getGridSquare(vehX, vehY + yShift*1, 0));
		inv:AddItem(car:createVehicleKey());
		-- car = addVehicleDebug("Base.ATAArmyBus", IsoDirections.E, nil, getCell():getGridSquare(vehX, vehY + yShift*2, 0));
		-- inv:AddItem(car:createVehicleKey());
		-- addVehicleDebug("Base.TrailerKbac", IsoDirections.E, nil, getCell():getGridSquare(vehX, vehY + yShift*3, 0));
		-- addVehicleDebug("Base.TrailerHomeHartman", IsoDirections.E, nil, getCell():getGridSquare(vehX, vehY + yShift*4, 0));
		-- addVehicleDebug("Base.TrailerHomeExplorer", IsoDirections.E, nil, getCell():getGridSquare(vehX, vehY + yShift*5, 0));
		-- addVehicleDebug("Base.TrailerAdvert", IsoDirections.E, nil, getCell():getGridSquare(vehX, vehY + yShift*6, 0));
	
		-- Cars
		car = addVehicleDebug("Base.ATAJeepArcher", IsoDirections.E, nil, getCell():getGridSquare(3685.5, 5789, 0));
		-- car:repair();
		inv:AddItem(car:createVehicleKey());			
	end
}
