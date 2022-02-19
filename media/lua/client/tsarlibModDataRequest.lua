local tickControl = 100 -- Сокращает количество срабатываний скрипта. Больше число - меньше срабатываний

local tsarlibModData = {}
local tickStart = 0
function tsarlibModData.main()
    tickStart = tickStart + 1
    if tickStart % tickControl == 0 then
        tickStart = 0
        if isClient() then
            ModData.request("tsaranimations");
        end
    end
end

Events.OnTick.Add(tsarlibModData.main)