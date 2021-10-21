

function Recipe.OnCreate.CutATAUnusableMetal(items, result, player)
    player:getInventory():AddItem("Base.UnusableMetal");
    player:getInventory():AddItem("Base.UnusableMetal");
    player:getInventory():AddItem("Base.UnusableMetal");
end

function Recipe.OnCreate.CutATAProtectionWindowFrontItem(items, result, player)
    player:getInventory():AddItem("Base.MetalBar");
    player:getInventory():AddItem("Base.MetalBar");
    player:getInventory():AddItem("Base.Screws");
    player:getInventory():AddItem("Base.Screws");
    player:getInventory():AddItem("Base.Screws");
    player:getInventory():AddItem("Base.UnusableMetal");
    player:getInventory():AddItem("Base.UnusableMetal");
end