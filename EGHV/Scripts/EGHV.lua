--[[ =========================================================================
	EGHV : Enhanced Goodies and Hostile Villagers for Civilization VI
	Copyright (C) 2020-2021 zzragnar0kzz
	All rights reserved
=========================================================================== ]]

--[[ =========================================================================
	begin EGHV.lua gameplay script
=========================================================================== ]]

--[[ =========================================================================
	context sharing : initialize and/or fetch ExposedMembers here
	pre-init+ : these should be defined prior to any exposed globals
=========================================================================== ]]
-- fetch or initialize global exposed members
if not ExposedMembers.GUE then ExposedMembers.GUE = {}; end
GUE = ExposedMembers.GUE;
-- fetch any available Wondrous Goody Hut exposed members
WGH = ExposedMembers.WGH;

--[[ =========================================================================
	exposed globals : define any needed EGHV globally shared component(s) here
	pre-init : these should be defined prior to Initialize()
=========================================================================== ]]
-- make DebugPrint() more conveniently globally accessible, as otherwise this declaration must be made in a local scope within each function below
Dprint = GUE.DebugPrint;

--[[ =========================================================================
	listener function OnTurnBegin( iTurn )
	for Expansion1 ruleset and beyond; global Era for all Players
	pre-init: this should be defined prior to Initialize()
=========================================================================== ]]
function OnTurnBegin( iTurn )
	GUE.CurrentTurn = iTurn;			-- update the global current turn
	local iPreviousEra = GUE.CurrentEra;
	local iEraThisTurn = Game.GetEras():GetCurrentEra();		-- fetch the current era
	-- local Dprint = GUE.DebugPrint;
	if (iPreviousEra ~= iEraThisTurn) then			-- true when the current era differs from the stored global era
		GUE.CurrentEra = iEraThisTurn;			-- update the global era
		Dprint("Turn " .. tostring(iTurn) .. ": The current global game Era has changed from " .. tostring(GUE.Eras[iPreviousEra]) .. " to " .. tostring(GUE.Eras[iEraThisTurn]));
		if (GUE.HostilesAfterReward > 2) then Dprint("Hostility > 2: Hostile villagers will now appear with increased intensity following most goody hut rewards");
		elseif (GUE.HostilesAfterReward > 1) then Dprint("Hostility > 1: Hostile villagers will now appear with increased frequency and intensity following most goody hut rewards");
		end
	else
		Dprint("Turn " .. tostring(iTurn) .. ": The current global game Era is " .. tostring(GUE.Eras[iEraThisTurn]));
	end
end

--[[ =========================================================================
	listener function OnPlayerTurnStarted( iPlayerID )
	for Standard ruleset; per-Player Eras
	pre-init: this should be defined prior to Initialize()
=========================================================================== ]]
function OnPlayerTurnStarted( iPlayerID )
	local iTurn = Game.GetCurrentGameTurn();
	if (GUE.CurrentTurn ~= iTurn) then GUE.CurrentTurn = iTurn; end
	local pPlayer = Players[iPlayerID];
	local pPlayerConfig = PlayerConfigurations[iPlayerID];
	-- local Dprint = GUE.DebugPrint;
	if (pPlayer == nil) or (pPlayerConfig == nil) then
		Dprint("Turn " .. tostring(iTurn) .. " | Player " .. tostring(iPlayerID) .. ": Players and/or PlayerConfigurations data is 'nil' for this Player; aborting.");
		return;
	elseif not pPlayer:IsMajor() then
		-- Dprint("Turn " .. tostring(iTurn) .. " | Player " .. tostring(iPlayerID) .. ": This Player is 'NOT' a valid major civilization; aborting.");
		return;
	end
	local iPreviousEra = GUE.PlayerData[iPlayerID].Era;
	local iEraThisTurn = pPlayer:GetEras():GetEra();		-- fetch the current era for this Player
	if (iPreviousEra ~= iEraThisTurn) then			-- true when the current era differs from the stored era value for this Player
		GUE.PlayerData[iPlayerID].Era = iEraThisTurn;			-- update the era for this Player
		Dprint("Turn " .. tostring(iTurn) .. " | Player " .. tostring(iPlayerID) .. ": The current Era for this Player has changed from " .. tostring(GUE.Eras[iPreviousEra]) .. " to " .. tostring(GUE.Eras[iEraThisTurn]));
		if (GUE.HostilesAfterReward > 2) then Dprint("Hostility > 2: Hostile villagers will now appear with increased intensity following most goody hut rewards");
		elseif (GUE.HostilesAfterReward > 1) then Dprint("Hostility > 1: Hostile villagers will now appear with increased frequency and intensity following most goody hut rewards");
		end
	else
		Dprint("Turn " .. tostring(iTurn) .. " | Player " .. tostring(iPlayerID) .. ": The current Era for this Player is " .. tostring(GUE.Eras[iEraThisTurn]));
	end
end

--[[ =========================================================================
	listener function OnGoodyHutReward( iPlayerID, iUnitID, iTypeHash, iSubTypeHash )
	fires whenever a goody hut is popped, including the meteor strike reward
	pre-init : this should be defined prior to Initialize()
=========================================================================== ]]
function OnGoodyHutReward( iPlayerID, iUnitID, iTypeHash, iSubTypeHash )
	-- abort here if this is the meteor strike reward, as Events.ImprovementActivated does not appear to fire for it
	if (GUE.GoodyHutTypes[iTypeHash].GoodyHutType == "METEOR_GOODIES" and GUE.GoodyHutRewards[iSubTypeHash].SubTypeGoodyHut == "METEOR_GRANT_GOODIES") then return; end
	-- define function entry message(s)
	local sPriEntryMsg = "ENTER EG_OnGoodyHutReward( iPlayerID = " .. iPlayerID .. ", iUnitID = " .. iUnitID .. ", iTypeHash = " .. iTypeHash .. ", iSubTypeHash = " .. iSubTypeHash .. " )";
	-- print entry message(s) to the log when debugging
	Dprint(sPriEntryMsg);
	-- initialize the local event results table; any pertinent argument(s) go here
	local tGoodyHutReward = {};
	-- store all passed arguments within the results table
	tGoodyHutReward.PlayerID, tGoodyHutReward.UnitID, tGoodyHutReward.TypeHash, tGoodyHutReward.SubTypeHash, tGoodyHutReward.Units = iPlayerID, iUnitID, iTypeHash, iSubTypeHash, { Count = 0 };
	-- set the expansion and exploration flags based on the passed PlayerID and UnitID values
	tGoodyHutReward.IsExpand, tGoodyHutReward.IsExplore = (iUnitID == -1 and iPlayerID == -1) and true or false, (iUnitID > -1 and iPlayerID > -1) and true or false;
	-- this fires when Events.GoodyHutReward has fired BEFORE Events.ImprovementActivated this turn
	if (#GUE.QueueImprovementActivated == 0) then
		-- insert the local table into the global QueueGoodyHutReward
		table.insert(GUE.QueueGoodyHutReward, tGoodyHutReward);
		-- initialize debugging message(s)
		local sPriDebugMsg = "Events.GoodyHutReward fired FIRST; pushing argument(s) to GUE.QueueGoodyHutReward[ " .. #GUE.QueueGoodyHutReward .. " ]: ";
		local sSecDebugMsg = "iPlayerID = " .. tGoodyHutReward.PlayerID  .. ", iUnitID = " .. tGoodyHutReward.UnitID 
			.. ", bIsExpand = " .. tostring(tGoodyHutReward.IsExpand) .. ", bIsExplore = " .. tostring(tGoodyHutReward.IsExplore) 
			.. ", iTypeHash = " .. tGoodyHutReward.TypeHash .. ", iSubTypeHash = " .. tGoodyHutReward.SubTypeHash;
		-- debugging output
		Dprint(sPriDebugMsg .. sSecDebugMsg);
	-- this fires when Events.GoodyHutReward has fired AFTER Events.ImprovementActivated this turn
	elseif (#GUE.QueueImprovementActivated > 0) then
		-- initialize a table to store this other Event's fetched argument(s)
		tImprovementActivated = {};
		-- iterate over the first index in the global QueueGoodyHutReward and add its data to the other Event table
		for k, v in pairs(GUE.QueueImprovementActivated[1]) do tImprovementActivated[k] = v; end
		-- remove the first index from the global QueueGoodyHutReward
		table.remove(GUE.QueueImprovementActivated, 1);
		-- debugging log output
		local sPriDebugMsg = "Events.GoodyHutReward fired SECOND; pulling argument(s) from GUE.QueueImprovementActivated[ 1 ] ( " .. #GUE.QueueImprovementActivated .. " item(s) remaining in this queue )";
		Dprint(sPriDebugMsg);
		-- use the consolidated arguments to validate and execute enhanced method(s), if any, on this reward
		GUE.ValidateGoodyHutReward(tImprovementActivated, tGoodyHutReward);
	end
	-- define function exit message(s)
	local sPriExitMsg = "EXIT EG_OnGoodyHutReward()";
	-- print exit message(s) to the log when debugging
	Dprint(sPriExitMsg);
end

--[[ =========================================================================
	listener function OnImprovementActivated( iX, iY, iOwnerID, iUnitID, iImprovementIndex, iImprovementOwnerID, iActivationType )
	fires whenever an improvement is activated, including any goody hut other than the meteor strike reward
	pre-init : this should be defined prior to Initialize()
=========================================================================== ]]
function OnImprovementActivated( iX, iY, iOwnerID, iUnitID, iImprovementIndex, iImprovementOwnerID, iActivationType )
	-- if the activated improvement IS NOT a barbarian camp AND IS NOT a goody hut, do nothing and abort
	if (iImprovementIndex ~= GUE.BarbCampIndex and iImprovementIndex ~= GUE.GoodyHutIndex) then return; end
	-- initialize flags for a barbarian camp and a goody hut
	local bIsBarbCamp, bIsGoodyHut = (iImprovementIndex == GUE.BarbCampIndex) and true or false, (iImprovementIndex == GUE.GoodyHutIndex) and true or false;
	-- determine whether this player is Sumeria and will generate a goody hut reward from clearing a barbarian camp
	local bIsSumeria = ((iOwnerID > -1 and GUE.PlayerData[iOwnerID] and GUE.PlayerData[iOwnerID].IsSumeria) or (iImprovementOwnerID > -1 and GUE.PlayerData[iImprovementOwnerID] and GUE.PlayerData[iImprovementOwnerID].IsSumeria)) and true or false;
	-- if the activated improvement IS a barbarian camp AND this player IS NOT Sumeria, there should be nothing else to catch, so do nothing and abort
	if bIsBarbCamp and not bIsSumeria then return; end
	-- define function entry messages
	local sPriEntryMsg = "ENTER EG_OnImprovementActivated( iX = " .. iX .. ", iY = " .. iY .. ", iOwnerID = " .. iOwnerID .. ", iUnitID = " .. iUnitID
		.. ", iImprovementIndex = " .. iImprovementIndex .. ", iImprovementOwnerID = " .. iImprovementOwnerID .. ", iActivationType = " .. iActivationType .. " )";
	-- print entry messages to the log when debugging
	Dprint(sPriEntryMsg);
	-- initialize the local event results table; any pertinent argument(s) go here
	local tImprovementActivated = {};
	-- store the passed (x, y) Plot coordinate values, and the OwnerID, ImprovementOwnerID, and UnitID values in the results table
	tImprovementActivated.X, tImprovementActivated.Y, tImprovementActivated.OwnerID, tImprovementActivated.ImprovementOwnerID, tImprovementActivated.UnitID = iX, iY, iOwnerID, iImprovementOwnerID, iUnitID;
	-- initialize the table of popping unit(s)
	tImprovementActivated.Units = { Count = 0 };
	-- set the expansion and exploration flags based on the passed UnitID, OwnerID, and ImprovementOwnerID values; store these flags in the results table
	tImprovementActivated.IsExpand, tImprovementActivated.IsExplore = (iUnitID == -1 and iImprovementOwnerID > -1) and true or false, (iUnitID ~= -1 and iOwnerID > -1) and true or false;
	-- set the PlayerID based on the status of the expansion flag; store this value in the results table
	tImprovementActivated.PlayerID = tImprovementActivated.IsExpand and iImprovementOwnerID or iOwnerID;
	-- store the values of the flags defined above
	tImprovementActivated.IsBarbCamp, tImprovementActivated.IsGoodyHut, tImprovementActivated.IsSumeria = bIsBarbCamp, bIsGoodyHut, bIsSumeria;
	-- this fires when Events.ImprovementActivated has fired BEFORE Events.GoodyHutReward this turn
	if (#GUE.QueueGoodyHutReward == 0) then
		-- insert the local table into the global QueueImprovementActivated
		table.insert(GUE.QueueImprovementActivated, tImprovementActivated);
		-- initialize debugging message(s)
		local sPriDebugMsg = "Events.ImprovementActivated fired FIRST; pushing argument(s) to GUE.QueueImprovementActivated[ " .. #GUE.QueueImprovementActivated .. " ]: ";
		local sSecDebugMsg = "iX = " .. tImprovementActivated.X .. ", iY = " .. tImprovementActivated.Y .. ", iPlayerID = " .. tImprovementActivated.PlayerID  .. ", iUnitID = " .. tImprovementActivated.UnitID 
			.. ", bIsExpand = " .. tostring(tImprovementActivated.IsExpand) .. ", bIsExplore = " .. tostring(tImprovementActivated.IsExplore) 
			.. ", bIsBarbCamp = " .. tostring(tImprovementActivated.IsBarbCamp) .. ", bIsGoodyHut = " .. tostring(tImprovementActivated.IsGoodyHut) .. ", bIsSumeria = " .. tostring(tImprovementActivated.IsSumeria);
		-- debugging log output
		Dprint(sPriDebugMsg .. sSecDebugMsg);
	-- this fires when Events.ImprovementActivated has fired AFTER Events.GoodyHutReward this turn
	elseif (#GUE.QueueGoodyHutReward > 0) then
		-- initialize a table to store this other Event's fetched argument(s)
		tGoodyHutReward = {};
		-- iterate over the first index in the global QueueGoodyHutReward and add its data to the other Event table
		for k, v in pairs(GUE.QueueGoodyHutReward[1]) do tGoodyHutReward[k] = v; end
		-- remove the first index from the global QueueGoodyHutReward
		table.remove(GUE.QueueGoodyHutReward, 1);
		-- debugging log output
		local sPriDebugMsg = "Events.ImprovementActivated fired SECOND; pulling argument(s) from GUE.QueueGoodyHutReward[ 1 ] ( " .. #GUE.QueueGoodyHutReward .. " item(s) remaining in this queue )";
		Dprint(sPriDebugMsg);
		-- use the consolidated arguments to validate and execute enhanced method(s), if any, on this reward
		GUE.ValidateGoodyHutReward(tImprovementActivated, tGoodyHutReward);
	end
	-- define function exit message(s)
	local sPriExitMsg = "EXIT EG_OnImprovementActivated()";
	-- print exit message(s) to the log when debugging
	Dprint(sPriExitMsg);
end

--[[ =========================================================================
	listener function OnPlayerTurnDeactivated( iPlayerID )
	resets event argument queue(s) if their counts differ at the end of a Player's turn
	when this fires, some enhanced method(s) may not fire on any orphaned reward(s), and earlier enhanced method(s) may not have been entirely accurate in their delivery
		however, this should prevent similar future problem(s), unless the queues become misaligned again, in which case we end up back here
	as the queue(s) usually properly maintain themselves, this should only fire in rare circumstances; multiple firings in a session indicate something screwy in that session
	pre-init : this should be defined prior to Initialize()
=========================================================================== ]]
function OnPlayerTurnDeactivated( iPlayerID )
	-- this fires when these queue(s) are misaligned in any way at end-of-turn
	if #GUE.QueueGoodyHutReward ~= #GUE.QueueImprovementActivated then
		-- reset argument queue(s), and initialize or increment the forced resets tracker
		GUE.QueueGoodyHutReward, GUE.QueueImprovementActivated, GUE.ForcedQueueResets = {}, {}, (GUE.ForcedQueueResets) and GUE.ForcedQueueResets + 1 or 1;
		-- define function entry message(s)
		local sPriEntryMsg = "ERROR EG_OnPlayerTurnDeactivated() Resetting misaligned argument queue(s) at end-of-turn for iPlayerID " .. iPlayerID .. "; this has now happened " .. GUE.ForcedQueueResets 
			.. " total time(s) this session";
		-- print entry message(s) to the log when debugging
		print(sPriEntryMsg);
	end
end

--[[ =========================================================================
	hook function OnTurnBeginHook()
	actions related to a global game Era change
	init: this should be hooked to Events.LoadScreenClose in Initialize()
=========================================================================== ]]
function OnTurnBeginHook() Events.TurnBegin.Add(OnTurnBegin); end

--[[ =========================================================================
	hook function OnPlayerTurnStartedHook()
	actions related to an Era change for an individual Player
	init: this should be hooked to Events.LoadScreenClose in Initialize()
=========================================================================== ]]
function OnPlayerTurnStartedHook() GameEvents.PlayerTurnStarted.Add(OnPlayerTurnStarted); end

--[[ =========================================================================
	hook function OnGoodyHutRewardHook()
	
	init: this should be hooked to Events.LoadScreenClose in Initialize()
=========================================================================== ]]
function OnGoodyHutRewardHook() Events.GoodyHutReward.Add(OnGoodyHutReward); end

--[[ =========================================================================
	hook function OnImprovementActivatedHook()
	
	init: this should be hooked to Events.LoadScreenClose in Initialize()
=========================================================================== ]]
function OnImprovementActivatedHook() Events.ImprovementActivated.Add(OnImprovementActivated); end

--[[ =========================================================================
	hook function OnPlayerTurnDeactivatedHook()
	
	init: this should be hooked to Events.LoadScreenClose in Initialize()
=========================================================================== ]]
function OnPlayerTurnDeactivatedHook() Events.PlayerTurnDeactivated.Add(OnPlayerTurnDeactivated); end

--[[ =========================================================================
	function Initialize()
	final configuration prior to startup
=========================================================================== ]]
function Initialize()
    print(GUE.RowOfDashes);
    print("Loading EGHV gameplay script EGHV.lua . . .");
    print(GUE.RowOfDashes);
	Dprint("Available Player(s):");
    local iNumPlayers, iNumCityStates = 0, 0;
    for p = 0, 63 do 
        if GUE.PlayerData[p] then 
            local sPlayerInfo = "Player " .. p .. ": ";
    		if GUE.PlayerData[p].IsHuman then sPlayerInfo = sPlayerInfo .. "Human";
		    else sPlayerInfo = sPlayerInfo .. "AI";
	    	end
    		sPlayerInfo = sPlayerInfo .. " Major (" .. GUE.PlayerData[p].CivTypeName .. ") | Difficulty " .. GUE.PlayerData[p].Difficulty .. " (" .. GUE.PlayerData[p].DifficultyType .. ")";
		    if (GUE.Ruleset == "RULESET_STANDARD") then
	    		sPlayerInfo = sPlayerInfo .. " | Era " .. GUE.PlayerData[p].Era .. " (" .. GUE.Eras[GUE.PlayerData[p].Era] .. ")";
    		end
		    iNumPlayers = iNumPlayers + 1;
	    	Dprint(sPlayerInfo);
        end
    end
    for p = iNumPlayers, 63 do 
        if GUE.CityStatesData[p] then 
            local sPlayerInfo = "Player " .. p .. ": City-State (" .. GUE.CityStatesData[p].CivTypeName .. ") ";
	    	if (iNumCityStates < GUE.CityStatesCount) then sPlayerInfo = sPlayerInfo .. "is active at startup";
		    else sPlayerInfo = sPlayerInfo .. "is reserved by game mode at startup";
    		end
	    	iNumCityStates = iNumCityStates + 1;
		    Dprint(sPlayerInfo);
        end
    end
    if not GUE.NoBarbarians then Dprint("Player " .. GUE.BarbarianID .. ": Barbarians"); end
    print("There are " .. iNumPlayers .. " active major Player(s) and " .. GUE.CityStatesCount .. "/" .. iNumCityStates .. " active/total City-State(s) at startup");
    print("Selected ruleset at startup: " .. GUE.Ruleset);
    if (GUE.Ruleset ~= "RULESET_STANDARD") then print("Global game Era at startup: " .. GUE.CurrentEra .. " (" .. GUE.Eras[GUE.CurrentEra] .. ")"); end
    print("Game turn at startup: " .. GUE.CurrentTurn);
    print(GUE.RowOfDashes);
    print("Configuring required hook(s) for ingame Event(s) . . .");
	if (GUE.Ruleset == "RULESET_STANDARD") then
		Events.LoadScreenClose.Add(OnPlayerTurnStartedHook);
		Dprint("Standard ruleset in use: OnPlayerTurnStarted() successfully hooked to GameEvents.PlayerTurnStarted");
	else
		Events.LoadScreenClose.Add(OnTurnBeginHook);
		Dprint("Non-Standard ruleset in use: OnTurnBegin() successfully hooked to Events.TurnBegin");
	end
    Events.LoadScreenClose.Add(OnGoodyHutRewardHook);
    Dprint("OnGoodyHutReward() successfully hooked to Events.GoodyHutReward");
    Events.LoadScreenClose.Add(OnImprovementActivatedHook);
    Dprint("OnImprovementActivated() successfully hooked to Events.ImprovementActivated");
    Events.LoadScreenClose.Add(OnPlayerTurnDeactivatedHook);
    Dprint("OnPlayerTurnDeactivated() successfully hooked to Events.PlayerTurnDeactivated");
    print(GUE.RowOfDashes);
	print("EGHV configuration complete. Proceeding . . .");
end

Initialize();

--[[ =========================================================================
	references
==============================================================================

	[1] web : https://forums.civfanatics.com/threads/getting-an-extra-bonus-from-goody-huts.616695/#post-14780879
	[2] web : https://steamcommunity.com/sharedfiles/filedetails/?id=2164194796
	[3] web : https://forums.civfanatics.com/threads/add-a-feature-to-a-plot-during-game-time-with-lua.645149/#post-15435909
	[4] web : https://forums.civfanatics.com/threads/ongoodyhutreward-event-what-are-the-parameters.642591/#post-15398744
	[5] web : https://forums.civfanatics.com/threads/how-do-you-catch-an-era-change-event-in-lua.614454/#post-15144387

=========================================================================== ]]

--[[ =========================================================================
	end EGHV.lua gameplay script
=========================================================================== ]]
