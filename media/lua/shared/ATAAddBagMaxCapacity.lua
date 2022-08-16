local bagsMaxCapacity = {
    Bag_ShotgunDblSawnoffBag = 18,
    Bag_ShotgunDblBag = 18,
    Bag_ShotgunBag = 18,
    Bag_ShotgunSawnoffBag = 18,
    Bag_SurvivorBag = 27,
    Bag_ALICEpack_Army = 28,
    Bag_ALICEpack = 27,
    Bag_BigHikingBag = 22,
    Bag_NormalHikingBag = 20,
    Bag_DuffelBagTINT = 18,
    Bag_InmateEscapedBag = 18,
    Bag_WorkerBag = 18,
    Bag_WeaponBag = 18,
    Bag_DuffelBag = 18,
    Bag_MoneyBag = 18,
    Bag_GolfBag = 18,
    Bag_Schoolbag = 15,
    Drawer = 10,
}

local function OnGameBoot()
    for bagName, MaxCapacity in pairs(bagsMaxCapacity) do
        local item = getScriptManager():getItem("Base." .. bagName)
        if item ~= nil then
            item:DoParam("MaxCapacity = " .. MaxCapacity)
        end
    end
end

Events.OnGameBoot.Add(OnGameBoot)