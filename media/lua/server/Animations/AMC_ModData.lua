if not isClient() and not isServer() then return end

local tsarslibOnInitGlobalModData = function(_module, _packet)
	if not ModData.exists("tsaranimations") then
		local t = ModData.create("tsaranimations")
	end
end

local tsarslibOnReceiveGlobalModData = function(_module, _packet)
	if _module ~= "tsaranimations" then return; end;
	-- print("SERVER" .. _module)
	if (not _packet) then
		print("aborted OnReceiveGlobalModData in trueClient "
				.. (_packet or "missing _packet."));
	else
        -- if isClient() then
            -- print("tsarslib ModData isClient")
        -- elseif isServer() then
            -- print("tsarslib ModData isServer")
        -- else
            -- print("tsarslib ModData local")
        -- end
        -- for i, k in pairs(_packet) do
            -- print("tsaranimations")
            -- print(i)
            -- print(k)
        -- end
		ModData.add(_module, _packet);
	end;
end

Events.OnInitGlobalModData.Add(tsarslibOnInitGlobalModData);
Events.OnReceiveGlobalModData.Add(tsarslibOnReceiveGlobalModData);


local function tsarlibAnimModDataClear()
    for playerOnlineID, needAnim in pairs(ModData.getOrCreate("tsaranimations")) do
        if needAnim then
            local player = getPlayerByOnlineID(playerOnlineID)
            if not player then
                ModData.getOrCreate("tsaranimations")[playerOnlineID] = nil
            end
        end
    end
end

Events.EveryHours.Add(tsarlibAnimModDataClear)