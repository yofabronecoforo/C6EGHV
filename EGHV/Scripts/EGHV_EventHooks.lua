--[[ =========================================================================
	C6GUE : Gameplay and Usability Enhancements for Civilization VI
	Copyright (C) 2020-2023 zzragnar0kzz
	All rights reserved
=========================================================================== ]]

--[[ =========================================================================
	begin EGHV component script EGHV_EventHooks.lua
=========================================================================== ]]
if g_iLoggingLevel > 1 then print("Loading component script EGHV_EventHooks.lua . . ."); end

--[[ =========================================================================
	listener function EGHV_OnImprovementActivated(iX, iY, iOwnerID, iUnitID, iImprovementIndex, iImprovementOwnerID, iActivationType)
	fires whenever an improvement is activated, including any goody hut other than the meteor strike reward
	packs Event arguments into a table
	creates new RewardGenerator objects using the Event arguments table
	executes generated rewards
	determines villager hostility when Hostiles After Rewards is enabled
	logs a condensed summary of received rewards when the logging level is Normal or higher
	logs results of reward rolls when the logging level is Verbose or higher
	logs results of reward functions when the logging level is Extra Verbose
=========================================================================== ]]
function EGHV_OnImprovementActivated(iX, iY, iOwnerID, iUnitID, iImprovementIndex, iImprovementOwnerID, iActivationType) 
	local bIsBarbCamp = iImprovementIndex == g_iBarbCampIndex;
	local bIsGoodyHut = iImprovementIndex == g_iGoodyHutIndex;
	if not bIsBarbCamp and not bIsGoodyHut then return; end
	local iPlayerID = iOwnerID > -1 and iOwnerID or iImprovementOwnerID;
	local sCivType = PlayerConfigurations[iPlayerID]:GetCivilizationTypeName();
    local bIsSumeria = sCivType == "CIVILIZATION_SUMERIA";
	if bIsBarbCamp and not bIsSumeria then return; end
	local print = (g_iLoggingLevel > 1) and print or function (s, ...) return; end;    -- disable print function locally when logging level is not Normal or higher
	-- local sFunc = "RewardGenerator():";
	-- local sArgs = string.format("X %d, Y %d, OwnerID %d, UnitID %d, ImprovementIndex %d, ImprovementOwnerID %d, ActivationType %d", iX, iY, iOwnerID, iUnitID, iImprovementIndex, iImprovementOwnerID, iActivationType);
	-- if g_iLoggingLevel > 1 then print(string.format("%s %s", sFunc, sArgs)); end
	local bIsExpand = (iUnitID == -1 and iImprovementOwnerID > -1);
	local bIsExplore = (iUnitID ~= -1 and iOwnerID > -1);
	local sCivName = Locale.Lookup(GameInfo.Civilizations[sCivType].Name);
	local bIsHuman = Players[iPlayerID]:IsHuman();
	local t = {
		X = iX, Y = iY, OwnerID = iOwnerID, UnitID = iUnitID, 
		ImprovementIndex = iImprovementIndex, ImprovementOwnerID = iImprovementOwnerID, ActivationType = iActivationType, 
		IsBarbCamp = bIsBarbCamp, IsGoodyHut = bIsGoodyHut, IsExpand = bIsExpand, IsExplore = bIsExplore, 
		PlayerID = iPlayerID, CivType = sCivType, CivName = sCivName, IsSumeria = bIsSumeria, IsHuman = bIsHuman, 
		Previous = {}, Failed = {} 
	};
	local iNumRewards = bIsBarbCamp and 1 or g_iTotalRewardsPerGoodyHut;
	local sHutsLeft = bIsGoodyHut and RemoveGoodyHutPlot(iX, iY) or nil;
	if bIsHuman then Game.AddWorldViewText(iPlayerID, Locale.Lookup("LOC_GOODYHUT_EGHV_PLACEHOLDER_DESC"), iX, iY, 0); end
	local sTitle = string.format("%s %s", g_tNotification.Reward.Title, bIsGoodyHut and g_sGoodyHutName or g_sBarbCampName);
    local sNotification = string.format("%s", g_tNotification.Reward.Message);
	local bHostilesAsReward, iCumulativeHostileModifier, tRewards = false, 0, {};
    for r = 1, iNumRewards do 
		tRewards[r] = RewardGenerator(t);
		tRewards[r].RewardNum = r;
		if (r == 1) then print(tRewards[r]:GetSummaryHeader(sHutsLeft)); end
		local bIsFallback = false;
        local bSuccess = bIsExplore and tRewards[r]:GenerateReward() or tRewards[r]:GenerateReward(g_tValidRewards.Expansion, g_iExpansionRewardCount);
        if not bSuccess then 
			bSuccess = tRewards[r]:GenerateReward(g_tValidRewards.Fallback, g_iFallbackRewardCount);
			bIsFallback = true;
		end
        if not bSuccess then 
			print(string.format("'FAILED' to generate a valid reward from both the %s and Fallback tables; aborting", (bIsExplore) and "All" or "Expansion"));
			return;
		end
		bSuccess = tRewards[r]:GrantReward();    -- grant generated reward
		if not bSuccess then 
			local sFailure = string.format("'FAILED' to apply %s", tRewards[r].Reward);
			t.Failed[tRewards[r].Type] = true;
			if not bIsFallback then 
				print(string.format("%s; attempting to generate Fallback reward . . .", sFailure));
			elseif bIsFallback then 
				print(string.format("%s as Fallback reward; strange things are afoot at the Circle K, aborting", sFailure));
				return;
			end
			bSuccess = tRewards[r]:GenerateReward(g_tValidRewards.Fallback, g_iFallbackRewardCount);
			if not bSuccess then 
				print(string.format("'FAILED' to generate a valid reward from the Fallback table; aborting"));
				return;
			end
			bSuccess = tRewards[r]:GrantReward();    -- grant generated fallback reward
			if not bSuccess then 
				print(string.format("'FAILED' to apply %s as Fallback reward; strange things are afoot at the Circle K, aborting", tRewards[r].Reward));
				return;
			end
		end
        if bIsHuman and not tRewards[r].Experience and not tRewards[r].UnitAbility then Game.AddWorldViewText(iPlayerID, tRewards[r].Description, iX, iY, 0); end
		sNotification = string.format("%s[NEWLINE][%d] %s", sNotification, r, tRewards[r].Description);
        if tRewards[r].Hostile then 
			bHostilesAsReward = true;
            break;
        end
        iCumulativeHostileModifier = iCumulativeHostileModifier + tRewards[r].RewardTier;
		if tRewards[r].UnitID ~= t.UnitID then t.UnitID = tRewards[r].UnitID; end
		t.Previous[tRewards[r].Reward] = true;
    end
	local sNumRewards = (#tRewards == iNumRewards) and "of" or "of up to";
	print(string.format("Player %d received %d %s %d %s", iPlayerID, #tRewards, sNumRewards, iNumRewards, SingularOrPlural(iNumRewards, "reward")));
	if bHostilesAsReward then 
		local sBonuses = (#tRewards ~= iNumRewards) and "potential additional rewards and " or "";
		print(string.format("%s hostile villagers received as 'reward' %d; skipping any %spost-reward hostiles check", tRewards[#tRewards].Adverb, #tRewards, sBonuses));
	elseif g_iHostilesAfterReward > 1 then 
		if bIsBarbCamp then 
			print("No hostiles check following dispersal of a Barbarian Outpost");
		elseif tRewards[1].Turn < g_iHostilesMinTurn then 
			local iTurnsRemaining = g_iHostilesMinTurn - tRewards[1].Turn;
			print(string.format("No hostiles check after reward(s) for %d more %s", iTurnsRemaining, SingularOrPlural(iTurnsRemaining, "turn")));
		else 
			tRewards[(#tRewards + 1)] = RewardGenerator(t);
			tRewards[#tRewards].RewardNum = #tRewards;
        	tRewards[#tRewards]:GetHostilityModifiers(iCumulativeHostileModifier);
	        local sHostile = tRewards[#tRewards]:GetHostilityLevel();
    	    if GameInfo.GoodyHutSubTypes_EGHV[sHostile] then 
        	    tRewards[#tRewards]:RefreshRewardDetails(GameInfo.GoodyHutSubTypes_EGHV[sHostile]);
            	local bSuccess = tRewards[#tRewards]:GrantReward();
	            if bIsHuman then Game.AddWorldViewText(iPlayerID, tRewards[#tRewards].Description, iX, iY, 0); end
				sNotification = string.format("%s[NEWLINE][%d] %s", sNotification, #tRewards, tRewards[#tRewards].Description);
				print(string.format("The villagers were %s hostile to the presence of outsiders", tRewards[#tRewards].Adverb));
			else 
				print("The villagers were unconcerned by the presence of outsiders");
        	end
		end
    end
	if bIsHuman then NotificationManager.SendNotification(iPlayerID, g_tNotification.Reward.TypeHash, sTitle, sNotification, iX, iY); end
	-- cleanup
	tRewards = nil;
	t = nil;
	return;
end

--[[ =========================================================================
	listener function EGHV_OnTurnBegin(iTurn)
	for Expansion1 ruleset and beyond; global Era for all Players
	tracks global Turn and Era changes
	logs potential changes in villager hostility when the logging level is Verbose or higher
=========================================================================== ]]
function EGHV_OnTurnBegin(iTurn) 
	-- local sFunc = "OnTurnBegin():";
	g_iCurrentTurn = iTurn;                                 -- update the global current turn
	local iPreviousEra = g_iCurrentEra;
	local iEraThisTurn = Game.GetEras():GetCurrentEra();    -- fetch the current era
	if (iPreviousEra ~= iEraThisTurn) then                  -- true when the current era differs from the stored global era
		g_iCurrentEra = iEraThisTurn;                       -- update the global era
		if g_iLoggingLevel > 2 then 
			local sPreviousEraName = Locale.Lookup(GameInfo.Eras[iPreviousEra].Name);
			local sEraThisTurnName = Locale.Lookup(GameInfo.Eras[iEraThisTurn].Name);
			local sHostileSpawn = string.format("; hostile villagers will now appear with increased%sintensity following most Tribal Village rewards", (g_iHostilesAfterReward == 2) and " frequency and " or " ");
			print(string.format("Turn %d: The current global Era has changed from %s to %s%s", iTurn, sPreviousEraName, sEraThisTurnName, (g_iHostilesAfterReward > 1) and sHostileSpawn or ""));
		end
	end
	return;
end

--[[ =========================================================================
	listener function EGHV_OnPlayerTurnStarted(iPlayerID)
	for Standard ruleset; per-Player Eras
	tracks global Turn and Player Era changes
	logs potential changes in villager hostility when the logging level is Verbose or higher
=========================================================================== ]]
function EGHV_OnPlayerTurnStarted(iPlayerID) 
	local sFunc = "EGHV_OnPlayerTurnStarted():";
	local iTurn = Game.GetCurrentGameTurn();
	if (g_iCurrentTurn ~= iTurn) then g_iCurrentTurn = iTurn; end
	local pPlayer = Players[iPlayerID];
	local pPlayerConfig = PlayerConfigurations[iPlayerID];
	if (pPlayer == nil) or (pPlayerConfig == nil) then 
		if g_iLoggingLevel > 2 then print(string.format("[-]: %s Turn %d: Players and/or PlayerConfigurations data is 'nil' for Player %d; aborting", sFunc, iTurn, iPlayerID)); end
		return;
	elseif not pPlayer:IsMajor() then    -- exit here if Player is not Major
		return;
	end
	local iPreviousEra = pPlayer:GetProperty("Era");
	local iEraThisTurn = pPlayer:GetEras():GetEra();    -- fetch the current era for this Player
	if (iPreviousEra ~= iEraThisTurn) then              -- true when the current era differs from the stored era value for this Player
		pPlayer:SetProperty("Era", iEraThisTurn);       -- update the era for this Player
		if g_iLoggingLevel > 2 then 
			local sPreviousEraName = Locale.Lookup(GameInfo.Eras[iPreviousEra].Name);
			local sEraThisTurnName = Locale.Lookup(GameInfo.Eras[iEraThisTurn].Name);
			local sHostileSpawn = string.format("; hostile villagers will now appear with increased%sintensity following most Tribal Village rewards", (g_iHostilesAfterReward == 2) and " frequency and " or " ");
			print(string.format("Turn %d: The current Era for Player %d has changed from %s to %s%s", iTurn, iPlayerID, sPreviousEraName, sEraThisTurnName, (g_iHostilesAfterReward > 1) and sHostileSpawn or ""));
		end
	end
	return;
end

--[[ =========================================================================
    function Init_EventHooks()
    add the listener functions defined above to the appropriate events
	this should be added to the LoadScreenClose event to ensure these hooks do not fire during game setup
=========================================================================== ]]
function Init_EventHooks() 
    print(g_sRowOfDashes);
    print("Configuring required hook(s) for ingame Event(s) . . .");
	if (g_sRuleset == "RULESET_STANDARD") then 
		GameEvents.PlayerTurnStarted.Add(EGHV_OnPlayerTurnStarted);
		print("Standard ruleset in use: EGHV_OnPlayerTurnStarted() successfully hooked to GameEvents.PlayerTurnStarted");
	else
		Events.TurnBegin.Add(EGHV_OnTurnBegin);
		print("Non-Standard ruleset in use: EGHV_OnTurnBegin() successfully hooked to Events.TurnBegin");
	end
    -- Events.GoodyHutReward.Add(EGHV_OnGoodyHutReward);
    -- print("EGHV_OnGoodyHutReward() successfully hooked to Events.GoodyHutReward");
    Events.ImprovementActivated.Add(EGHV_OnImprovementActivated);
    print("EGHV_OnImprovementActivated() successfully hooked to Events.ImprovementActivated");
    -- Events.PlayerTurnDeactivated.Add(EGHV_OnPlayerTurnDeactivated);
    -- print("EGHV_OnPlayerTurnDeactivated() successfully hooked to Events.PlayerTurnDeactivated");
	-- Events.ImprovementAddedToMap.Add(EGHV_OnImprovementAddedToMap);
    -- print("EGHV_OnImprovementAddedToMap() successfully hooked to Events.ImprovementAddedToMap");
	print(g_sRowOfDashes);
    print("Finished configuring ingame Event hook(s); proceeding . . .");
    print(g_sRowOfDashes);
end

--[[ =========================================================================
    end EGHV component script EGHV_EventHooks.lua; below here is deprecated code
=========================================================================== ]]

--[[ =========================================================================
	listener function EGHV_OnGoodyHutReward(iPlayerID, iUnitID, iTypeHash, iRewardHash)
	fires whenever a goody hut is popped, including the meteor strike reward
	packs all Event and additional arguments into a table
	passes the arguments table to a coroutine to be resumed by the ImprovementActivated Event, or
	resumes the first coroutine in the ImprovementActivated queue, retrieves its arguments table, and passes both tables to ValidateEventArguments()
=========================================================================== ]]
-- function EGHV_OnGoodyHutReward(iPlayerID, iUnitID, iTypeHash, iRewardHash) 
-- 	local sType = GameInfo.GoodyHutsByHash[iTypeHash].GoodyHutType;
--     local sReward = GameInfo.GoodyHutSubTypesByHash[iRewardHash].SubTypeGoodyHut;
-- 	if (g_tExcludedTypes[sType] or g_tExcludedRewards[sReward]) then 
-- 		return; 
-- 	end
-- 	local tGHR = {
-- 		PlayerID = iPlayerID, UnitID = iUnitID, 
-- 		TypeHash = iTypeHash, RewardHash = iRewardHash, 
-- 		Type = sType, Reward = sReward 
-- 	};
-- 	if (#g_tPlayerEventQueues[iPlayerID].ImprovementActivated == 0) then 
-- 		local thread = coroutine.create(function (t) 
-- 			coroutine.yield();
-- 			return t;
-- 		end);
-- 		coroutine.resume(thread, tGHR);
-- 		local status = coroutine.status(thread);
-- 		table.insert(g_tPlayerEventQueues[iPlayerID].GoodyHutReward, thread);
-- 		print(string.format("OnGoodyHutReward(): Coroutine %s | Status: %s", tostring(thread), tostring(status)));
-- 		return;
-- 	elseif (#g_tPlayerEventQueues[iPlayerID].ImprovementActivated > 0) then 
-- 		local thread = g_tPlayerEventQueues[iPlayerID].ImprovementActivated[1];
-- 		table.remove(g_tPlayerEventQueues[iPlayerID].ImprovementActivated, 1);
-- 		local status, tIA = coroutine.resume(thread);
-- 		print(string.format("OnGoodyHutReward(): Coroutine %s | Status: %s", tostring(thread), tostring(status)));
-- 		return ValidateEventArguments(tGHR, tIA);
-- 	end
-- end

--[[ =========================================================================
	listener function EGHV_OnImprovementActivated(iX, iY, iOwnerID, iUnitID, iImprovementIndex, iImprovementOwnerID, iActivationType)
	fires whenever an improvement is activated, including any goody hut other than the meteor strike reward
	packs all Event and additional arguments into a table
	passes the arguments table to a coroutine to be resumed by the GoodyHutReward Event, or
	resumes the first coroutine in the GoodyHutReward queue, retrieves its arguments table, and passes both tables to ValidateEventArguments()
=========================================================================== ]]
-- function EGHV_OnImprovementActivated(iX, iY, iOwnerID, iUnitID, iImprovementIndex, iImprovementOwnerID, iActivationType) 
-- 	local bIsBarbCamp = iImprovementIndex == g_iBarbCampIndex;
-- 	local bIsGoodyHut = iImprovementIndex == g_iGoodyHutIndex;
-- 	if not bIsBarbCamp and not bIsGoodyHut then return; end
-- 	local sCivTypeName = (iOwnerID > -1) and PlayerConfigurations[iOwnerID]:GetCivilizationTypeName() or PlayerConfigurations[iImprovementOwnerID]:GetCivilizationTypeName();
--     local bIsSumeria = sCivTypeName == "CIVILIZATION_SUMERIA";
-- 	if bIsBarbCamp and not bIsSumeria then return; end
-- 	local bIsExpand = (iUnitID == -1 and iImprovementOwnerID > -1);
-- 	local bIsExplore = (iUnitID ~= -1 and iOwnerID > -1);
-- 	local tIA = {
-- 		X = iX, Y = iY, OwnerID = iOwnerID, UnitID = iUnitID, 
-- 		ImprovementIndex = iImprovementIndex, ImprovementOwnerID = iImprovementOwnerID, 
-- 		ActivationType = iActivationType, IsExpand = bIsExpand, IsExplore = bIsExplore, 
-- 		IsBarbCamp = bIsBarbCamp, IsGoodyHut = bIsGoodyHut, 
-- 		CivTypeName = sCivTypeName, IsSumeria = bIsSumeria 
-- 	};
-- 	if (#g_tPlayerEventQueues[iOwnerID].GoodyHutReward == 0) then 
-- 		local thread = coroutine.create(function (t) 
-- 			coroutine.yield();
-- 			return t;
-- 		end);
-- 		coroutine.resume(thread, tIA);
-- 		local status = coroutine.status(thread);
-- 		table.insert(g_tPlayerEventQueues[iOwnerID].ImprovementActivated, thread);
-- 		print(string.format("OnImprovementActivated(): Coroutine %s | Status: %s", tostring(thread), tostring(status)));
-- 		return;
-- 	elseif (#g_tPlayerEventQueues[iOwnerID].GoodyHutReward > 0) then 
-- 		local thread = g_tPlayerEventQueues[iOwnerID].GoodyHutReward[1];
-- 		table.remove(g_tPlayerEventQueues[iOwnerID].GoodyHutReward, 1);
-- 		local status, tGHR = coroutine.resume(thread);
-- 		print(string.format("OnImprovementActivated(): Coroutine %s | Status: %s", tostring(thread), tostring(status)));
-- 		return ValidateEventArguments(tGHR, tIA);
-- 	end
-- end

--[[ =========================================================================
	listener function EGHV_OnPlayerTurnDeactivated(iPlayerID)
	resets event argument queue(s) if their counts differ at the end of a Player's turn
	when this fires, some enhanced method(s) may not fire on any orphaned reward(s), and earlier enhanced method(s) may not have been entirely accurate in their delivery
		however, this should prevent similar future problem(s), unless the queues become misaligned again, in which case we end up back here
	as the queue(s) usually properly maintain themselves, this should only fire in rare circumstances; multiple firings in a session indicate something screwy in that session
=========================================================================== ]]
-- function EGHV_OnPlayerTurnDeactivated(iPlayerID) 
--     local sFunc = "OnPlayerTurnDeactivated()";
-- 	-- exit here if Player is not Major
-- 	if not Players[iPlayerID]:IsMajor() then return; end
-- 	-- this fires when these queue(s) are misaligned in any way at end-of-turn
-- 	if #g_tPlayerEventQueues[iPlayerID].GoodyHutReward ~= #g_tPlayerEventQueues[iPlayerID].ImprovementActivated then 
-- 		-- reset argument queue(s), and initialize or increment the forced resets tracker
-- 		g_tPlayerEventQueues[iPlayerID].GoodyHutReward = {};
--         g_tPlayerEventQueues[iPlayerID].ImprovementActivated = {};
--         g_tPlayerEventQueues[iPlayerID].ForcedQueueResets = (g_tPlayerEventQueues[iPlayerID].ForcedQueueResets) and g_tPlayerEventQueues[iPlayerID].ForcedQueueResets + 1 or 1;
--         print(string.format("ERROR %s: Resetting misaligned event argument queues at end of turn for Player %d; this has now happened %d time(s) this session", sFunc, iPlayerID, g_tPlayerEventQueues[iPlayerID].ForcedQueueResets));
-- 	end
-- 	-- if #g_tPlayerVisiblePlots[iPlayerID] > 0 then 
-- 	-- 	for _, p in ipairs(g_tPlayerVisiblePlots[iPlayerID]) do 
-- 	-- 		PlayersVisibility[iPlayerID]:ChangeVisibilityCount(p, 0);
-- 	-- 	end
-- 	-- 	g_tPlayerVisiblePlots[iPlayerID] = {};
-- 	-- end
-- 	return;
-- end

--[[ =========================================================================
	listener function EGHV_OnImprovementAddedToMap(iX, iY, iImprovementIndex, iPlayerID)
	updates the global table of goody hut plots whenever one is placed
=========================================================================== ]]
-- function EGHV_OnImprovementAddedToMap(iX, iY, iImprovementIndex, iPlayerID) 
--     if (iImprovementIndex == g_iGoodyHutIndex) then 
--         local pPlot = Map.GetPlot(iX, iY);
--         table.insert(g_tGoodyHutPlots, pPlot);
--         print(string.format("1 new Goody Hut placed at (x %d, y %d); there are now %d remaining on selected map", iX, iY, #g_tGoodyHutPlots));
--     end
-- 	return;
-- end
