--[[ =========================================================================
	C6GUE : Gameplay and Usability Enhancements for Civilization VI
	Copyright (C) 2020-2023 zzragnar0kzz
	All rights reserved
=========================================================================== ]]

--[[ =========================================================================
	begin EGHV component script EGHV_RewardGenerator.lua
=========================================================================== ]]
if g_iLoggingLevel > 1 then print("Loading component script EGHV_RewardGenerator.lua . . ."); end

--[[ =========================================================================
	RewardGenerator object
    this table stores pertinent details about a Goody Hut reward and the function(s) needed to apply that reward
=========================================================================== ]]
RewardGenerator = {};
RewardGenerator.__index = RewardGenerator;
setmetatable(RewardGenerator, {
    __call = function (class, t) 
        local self = setmetatable({}, class);
        return self:New(t);
    end, 
});

--[[ =========================================================================
	function RewardGenerator:New(t) 
    creates a new RewardGenerator object
    adds fields from arguments table
    adds as members frequently used functions which are not explicitly part of the class
    returns RewardGenerator object
=========================================================================== ]]
function RewardGenerator:New(t) 
    t = (type(t) == "table") and t or {};
    local keys = {};
    for key in pairs(t) do keys[(#keys + 1)] = key; end
    table.sort(keys);
    for _, key in ipairs(keys) do self[key] = t[key]; end
    keys = nil;
    self:GetPlayer();    -- add Player data
    self:GetCities();    -- add Player's Cities data
    self:GetUnits();     -- add Player's Units data
    return self;
end

--[[ =========================================================================
	function RewardGenerator:GetPlayer()
    stores in field Player a table containing target Player's data
    retrieves additional pertinent session data
    field PlayerID must be defined
    returns field Player
=========================================================================== ]]
function RewardGenerator:GetPlayer() 
    self.Player = Players[self.PlayerID];
    self.Era = (g_sRuleset == "RULESET_STANDARD") and self.Player:GetEras():GetEra() or Game.GetEras():GetCurrentEra();
    self.EraType = g_tEras[self.Era];
    self.EraName = Locale.Lookup(GameInfo.Eras[self.EraType].Name);
    self.Turn = Game.GetCurrentGameTurn();
    return self.Player; 
end

--[[ =========================================================================
	function RewardGenerator:GetCities()
    stores in field Cities a table containing city data for all of target player's cities
    field Player must be defined
    returns field Cities
=========================================================================== ]]
function RewardGenerator:GetCities() 
    self.Cities = {};
    for _, pCity in self.Player:GetCities():Members() do 
        table.insert(self.Cities, pCity); 
    end
    return self.Cities; 
end

--[[ =========================================================================
	function RewardGenerator:GetUnits()
    stores in field Units a table containing unit data for all of target player's units in formation with the popping Unit
    field Player must be defined
    field UnitID must be defined and valid
    returns field Units
=========================================================================== ]]
function RewardGenerator:GetUnits() 
    self.Units = {};
    if self.UnitID ~= -1 then 
        local pThisUnit = self.Player:GetUnits():FindID(self.UnitID);
        local tUnits = pThisUnit:GetFormationUnits();
        for i, pUnit in ipairs(tUnits) do 
            self.Units[i] = pUnit;
            self.Units[i].ID = pUnit:GetID();
            self.Units[i].Type = GameInfo.Units[pUnit:GetType()].UnitType or nil;
            self.Units[i].Name = Locale.Lookup(GameInfo.Units[pUnit:GetType()].Name) or nil;
            self.Units[i].PromotionClass = GameInfo.Units[pUnit:GetType()].PromotionClass or nil;
            self.Units[i].FormationClass = GameInfo.Units[pUnit:GetType()].FormationClass or nil;
            self.Units[i].FormationID = pUnit:GetFormationID() or nil;
            self.Units[i].FormationCount = pUnit:GetFormationUnitCount() or nil;
            if pUnit:GetExperience() then 
                self.Units[i].VeteranName = pUnit:GetExperience():GetVeteranName() or nil;
                self.Units[i].XP = pUnit:GetExperience():GetExperiencePoints() or nil;
                self.Units[i].XPFNL = pUnit:GetExperience():GetExperienceForNextLevel() or nil;
            end
        end
    end
    return self.Units;
end

--[[ =========================================================================
	function RewardGenerator:GetHostilityModifiers()
    stores in field Modifiers a table containing applicable hostile villager modifers
    adds as member function GetHostilityLevel()
    field Player must be defined
    field IsExpand must be defined
    field IsExplore must be defined
    returns field Modifiers
=========================================================================== ]]
function RewardGenerator:GetHostilityModifiers(i) 
    i = (type(i) == "number" and i > -1) and i or 0;
    self.Modifiers = {};
    self.Modifiers.Era = self.Era + 1;
    self.Modifiers.Reward = i;
    self.Modifiers.Difficulty = self.Player:GetProperty("Difficulty");
    if self.IsExpand or (self.IsExplore and GameInfo.IncreasedHostilityTargets[self.Units[1].Type]) then 
        self.Modifiers.Discovery = 3;
    elseif self.IsExplore and GameInfo.DecreasedHostilityTargets[self.Units[1].PromotionClass] then 
        self.Modifiers.Discovery = 1;
    else 
        self.Modifiers.Discovery = 2;
    end
    self.GetHostilityLevel = GetHostilityLevel;
    return self.Modifiers;
end

--[[ =========================================================================
    function RewardGenerator:GetSummaryHeader(sHutsLeft) 
    logs basic information about any reward(s) received from a goody hut or barbarian camp
=========================================================================== ]]
function RewardGenerator:GetSummaryHeader(sHutsLeft) 
    sHutsLeft = (type(sHutsLeft) == "string") and sHutsLeft or self.IsGoodyHut and RemoveGoodyHutPlot(self.X, self.Y) or nil;
    local sPlayer = string.format("Turn %d | Era %d (%s) | Player %d (%s)", self.Turn, self.Era, self.EraName, self.PlayerID, self.CivName);
    local sSource = self.IsGoodyHut and string.format("discovered a Tribal Village (%s)", sHutsLeft) or self.IsBarbCamp and "dispersed a Barbarian Outpost" or "activated an unknown improvement";
    local sDiscovery;
    if self.IsExplore then 
        local sUnits = self.Units[1].Name;
    	if #self.Units > 1 then 
    	    sUnits = string.format("formation of %s", sUnits);
	        for u = 2, #self.Units do 
                sUnits = string.format("%s/%s", sUnits, self.Units[u].Name);
        	end
    	end
    	sDiscovery = string.format("with a %s", sUnits);
	elseif self.IsExpand then 
    	sDiscovery = "via border expansion";
	else 
    	sDiscovery = "through unknown means";
	end
    local sLocation = string.format("at plot (x %d, y %d)", self.X, self.Y);
    return string.format("%s %s %s %s", sPlayer, sSource, sDiscovery, sLocation);
end

--[[ =========================================================================
	function RewardGenerator:GetStrategicResources()
    determines if target Player has access to strategic resources
    when field Hostiles is defined and true, instead determines if strategic resources are located in any plots in table Plots
    each strategic ResourceType is a key in table Resources, whose value is true or false based on the above parameters
    returns table Resources
=========================================================================== ]]
function RewardGenerator:GetStrategicResources() 
    local print = (g_iLoggingLevel > 2) and print or function (s, ...) return; end;    -- disable print function locally when logging level is not Verbose or higher
    local sFunc = "GetStrategicResources():";
    local sName, sSummary;
    self.Resources = {};
    for _, v in ipairs(g_tStrategicResources) do 
        self.Resources[v.ResourceType] = self.Hostile and (GetResourceCountInPlots(self.Plots, v.Index) > 0) or self.Player:GetResources():HasResource(v.Index);
        if self.Resources[v.ResourceType] then 
            sName = Locale.Lookup(GameInfo.Resources[v.ResourceType].Name);
            sSummary = self.Hostile and string.format("Found %s in one or more nearby plots", sName) or string.format("Player %d has access to %s", self.PlayerID, sName);
            print(string.format("[i]: %s %s", sFunc, sSummary));
        end
    end
    return self.Resources;
end

--[[ =========================================================================
	function RewardGenerator:GetAllValidPlots()
    stores in table Plots all plots within a radius of target Plot that is defined by field Radius
    identifies any strategic resources contained in the plots in table Plots
    identifies any plots in table Plots that are valid spawn locations for land and water units
    when field Hostiles is defined and true, and villager hostility is maximum, identifies any plots in table Plots that are valid locations for a barbarian camp
    returns nothing
=========================================================================== ]]
function RewardGenerator:GetAllValidPlots() 
    self.Plots = GetAdjacentPlotsInRadius(self.X, self.Y, self.Radius);
    self:GetStrategicResources();
    self.LandUnitPlots, self.WaterUnitPlots = GetValidUnitSpawnPlots(self.Plots);
    if (self.Hostile and self.RewardTier == 4) then self.BarbCampPlots = GetValidPlotsForImprovement(self.Plots, g_iBarbCampIndex); end
    return;
end

--[[ =========================================================================
	function RewardGenerator:GetEligibleUnitOfClass(sClass)
    identifies the most advanced Era-appropriate unit of the provided class which can be placed
    the effective Era will be capped based on resources that are available in table Resources
    if Horses are not available and the provided class is "LightCavalry", resets the provided class to "HeavyCavalry"
    there are no resource requirements for Ranged, Recon, and Support unit types
    returns: 
        when field Hostiles is defined and true, the identified unit from game DB table HostileUnits, or
        the identified unit from game DB UnitRewards otherwise
=========================================================================== ]]
function RewardGenerator:GetEligibleUnitOfClass(sClass) 
    sClass = (type(sClass) == "string" and sClass ~= "") and sClass or self.UnitClass;
    local print = (g_iLoggingLevel > 2) and print or function (s, ...) return; end;    -- disable print function locally when logging level is not Verbose or higher
    local sFunc = "GetEligibleUnitOfClass():";
    local iPlayerID = self.Hostile and g_iBarbarianID or self.PlayerID;
    local pPlayer = self.Hostile and Players[g_iBarbarianID] or self.Player;
    local pPlayerTechs = pPlayer:GetTechs();
    local tUnits = self.Hostile and GameInfo.HostileUnits or GameInfo.UnitRewards;
    local sUnit, sUnitName, sValidUnit;
    for e = self.Era, 0, -1 do 
        sUnit = tUnits[e][sClass];
        sUnitName = Locale.Lookup(GameInfo.Units[sUnit].Name);
        sClassName = Locale.Lookup(GameInfo.UnitPromotionClasses[GameInfo.Units[sUnit].PromotionClass].Name);
        sValidUnit = string.format("[i]: %s %s is the most advanced %s unit that Player %d's research and resources can accommodate", sFunc, sUnitName, sClassName, iPlayerID)
        local sPrereqTech = GameInfo.Units[sUnit].PrereqTech;
        if sPrereqTech then 
            if pPlayerTechs:HasTech(GameInfo.Technologies[sPrereqTech].Index) then 
                local sResource = GameInfo.Units[sUnit].StrategicResource;
                if sResource then 
                    if self.Resources[sResource] then 
                        print(sValidUnit);
                        break;
                    end
                elseif not sResource then 
                    print(sValidUnit);
                    break;
                end
            end
        elseif not sPrereqTech then 
            print(sValidUnit);
            break;
        end
    end
    return sUnit;
end

--[[ =========================================================================
	function RewardGenerator:RefreshRewardDetails(t)
    adds or updates reward-related fields from table t, which should be a row from GameInfo.GoodyHutSubTypes_EGHV
    adds additional fields relevant to the provided reward
    returns RewardGenerator object
=========================================================================== ]]
function RewardGenerator:RefreshRewardDetails(t) 
    -- local sFunc = "RefreshRewardDetails():";
    self.Type = t.GoodyHut or nil;
    self.TypeHash = GameInfo.GoodyHuts_EGHV[self.Type].Hash or nil;
    self.Reward = t.SubTypeGoodyHut or nil;
    self.RewardHash = t.Hash or nil;
    self.RewardTier = t.Tier or nil;
    self.RewardTierType = t.TierType or nil;
    self.Description = Locale.Lookup(GameInfo.GoodyHutSubTypes_EGHV[self.Reward].Description) or nil;
    self.OncePerEra = t.OncePerEra or nil;
    self.PrereqCivic = t.PrereqCivic or nil;
    self.PrereqTech1 = t.PrereqTech1 or nil;
    self.PrereqTech2 = t.PrereqTech2 or nil;
    self.ModifierID = t.ModifierID or nil;
    self.UpgradeUnit = t.UpgradeUnit or nil;
    self.MinTurn = t.Turn or nil;
    self.Experience = t.Experience or nil;
    self.Relic = t.Relic or nil;
    self.MinOneCity = t.MinOneCity or nil;
    self.RequiresUnit = t.RequiresUnit or nil;
    self.Hostile = t.Hostile or nil;
    self.Fallback = t.Fallback or nil;
    self.Unit = t.Unit or nil;
    self.Radius = self.Hostile and 3 or self.Unit and 1 or nil;
    if self.Radius then self:GetAllValidPlots(); end
    self.UnitAbility = t.UnitAbility or nil;
    self.UnitClass = t.UnitClass or nil;
    self.UnitType = t.UnitType and t.UnitType or self.UnitClass and self:GetEligibleUnitOfClass() or nil;
    self.UnitName = self.UnitType and Locale.Lookup(GameInfo.Units[self.UnitType].Name) or nil;
    self.ExperienceMultiplier = t.ExperienceMultiplier or nil;
    self.GrantReward = g_tGrantReward[self.RewardHash] or nil;
    if (self.Reward == "GOODYHUT_ADD_POP") or (self.Unit and self.UnitType) then 
        self.NumToPlace = (g_iBonusUnitOrPop == 7 or (g_iBonusUnitOrPop > 1 and RollDieWithSides(g_iBonusUnitOrPop) == 1)) and 2 or 1;
    end
    return self;
end

--[[ =========================================================================
	function RewardGenerator:ValidateReward(t)
    determines if the reward represented by table t is currently valid
        t should be a row from GameInfo.GoodyHutSubTypes_EGHV
    returns (1) true or false, and (2) a validation string for logging purposes
=========================================================================== ]]
function RewardGenerator:ValidateReward(t) 
    local sInvalid = "is 'NOT' valid:";
    local sPrereqTechFail = string.format("%s Minimum technology requirement of", sInvalid);
    -- affirmative validation: return true when any part of the inner chain here is true, otherwise return false when the entire inner chain is false
    if t.GoodyHut == "GOODYHUT_RESOURCES" then 
        if self.Player:GetTechs():HasTech(GameInfo.Technologies[t.PrereqTech1].Index) or self.Player:GetTechs():HasTech(GameInfo.Technologies[t.PrereqTech2].Index) then 
            return true, "is valid";
        else 
            return false, string.format("%s %s or %s not met", sPrereqTechFail, Locale.Lookup(GameInfo.Technologies[t.PrereqTech1].Name), Locale.Lookup(GameInfo.Technologies[t.PrereqTech2].Name));
        end
    end
    -- negative validation: return false when any part of the chain here is true, otherwise return true when the entire chain is false
    if g_bNoDuplicateRewards and self.Previous[t.SubTypeGoodyHut] then 
        return false, string.format("%s This village has already provided this exact reward", sInvalid);
    elseif self.Failed[t.GoodyHut] then 
        return false, string.format("%s This village has previously failed in an attempt to provide a reward of this Type", sInvalid);
    elseif t.MinOneCity and (not self.Cities or #self.Cities < 1) then 
        return false, string.format("%s Minimum one City requirement not met", sInvalid);
    elseif t.RequiresUnit and (not self.Units or #self.Units < 1) then 
        return false, string.format("%s Minimum one activating unit requirement not met", sInvalid);
    elseif self.Turn < t.MinTurn or (t.Hostile and self.Turn < g_iHostilesMinTurn) then 
        return false, string.format("%s Minimum Turn requirement of %d not met", sInvalid, t.Hostile and g_iHostilesMinTurn or t.MinTurn);
    elseif t.PrereqTech1 and not self.Player:GetTechs():HasTech(GameInfo.Technologies[t.PrereqTech1].Index) then 
        return false, string.format("%s %s not met", sPrereqTechFail, Locale.Lookup(GameInfo.Technologies[t.PrereqTech1].Name));
    elseif t.PrereqTech2 and not self.Player:GetTechs():HasTech(GameInfo.Technologies[t.PrereqTech2].Index) then 
        return false, string.format("%s %s not met", sPrereqTechFail, Locale.Lookup(GameInfo.Technologies[t.PrereqTech2].Name));
    elseif t.PrereqCivic and not self.Player:GetCulture():HasCivic(GameInfo.Civics[t.PrereqCivic].Index) then 
        return false, string.format("%s Minimum civic requirement of %s not met", sInvalid, Locale.Lookup(GameInfo.Civics[t.PrereqCivic].Name));
    elseif t.OncePerEra and self.Player:GetProperty(t.ModifierID) and self.Player:GetProperty(t.ModifierID) > self.Era then 
        return false, string.format("%s Player %d has already received this reward once per Era", sInvalid, self.PlayerID);
    elseif t.Hostile and self.IsBarbCamp then 
        return false, string.format("%s No hostile 'reward' from dispersing barbarian outpost", sInvalid);
    else 
        return true, "is valid";
    end
end

--[[ =========================================================================
	function RewardGenerator:ValidateAllRewards(d)
    does exactly what it says on the tin
    returns nothing
=========================================================================== ]]
function RewardGenerator:ValidateAllRewards(d) 
    d = (type(d) == "boolean") and d or false;
    local sFunc = "ValidateAllRewards():";
    local b, s;
    for reward in GameInfo.GoodyHutSubTypes_EGHV() do 
        b, s = self:ValidateReward(reward);
        print(string.format("[i]: %s %s %s", sFunc, reward.SubTypeGoodyHut, s));
        if d then 
            self:RefreshRewardDetails(reward);
            self:GrantReward();
        end
    end
    return;
end

--[[ =========================================================================
	function RewardGenerator:GetSpecificReward(r, d) 
    returns: 
=========================================================================== ]]
function RewardGenerator:GetSpecificReward(r, d) 
    r = (type(r) == "string") and r or nil;
    d = (type(d) == "boolean") and d or false;
    local sFunc = "GetSpecificReward():";
    local b = false;
    local s, t;
    if r and GameInfo.GoodyHutSubTypes_EGHV[r] then 
        t = GameInfo.GoodyHutSubTypes_EGHV[r];
        if t then 
            b, s = self:ValidateReward(t);
        else 
            s = "was 'NOT' able to be fetched from the gameplay DB table";
        end
    else 
        s = "is 'NOT' a valid SubTypeGoodyHut";
    end
    if d then print(string.format("[i]: %s %s %s", sFunc, tostring(r), s)); end
    return b, s, t;
end

--[[ =========================================================================
	function RewardGenerator:GenerateReward(t, n)
    t is a table containing two keys, Types and Rewards, whose values are tables
    table t.Types is indexed numerically, with GoodyHutTypes as values
        each GoodyHutType will be represented as x values, where x is the Weight of the GoodyHutType in gameplay DB table GoodyHuts_EGHV
        each unique GoodyHutType with Weight > 0 is a key in t.Rewards, whose value is a table
        for each, table t.Rewards[GoodyHutType] is indexed numerically, with SubTypeGoodyHuts as values
            each SubTypeGoodyHut will be represented as y values, where y is the Weight of the SubTypeGoodyHut in gameplay DB table GoodyHutSubTypes_EGHV
    randomly selects a valid GoodyHutType from t.Types
    randomly selects a valid SubTypeGoodyHut from t.Rewards[GoodyHutType]
    fetches the relevant gameplay DB row for the selected SubTypeGoodyHut
    adds or updates reward-related fields
    returns: 
        true if a valid reward is obtained in n or fewer attempts, or 
        false otherwise
=========================================================================== ]]
function RewardGenerator:GenerateReward(t, n) 
    t = (type(t) == "table") and t or g_tValidRewards.All;                             -- default to the global active rewards table if t is invalid
    n = (type(n) == "number" and n > 0) and n or g_iActiveRewardCount;                 -- default to the global active rewards count if n is invalid
    local print = (g_iLoggingLevel > 2) and print or function (s, ...) return; end;    -- disable print function locally when logging level is not Verbose or higher
    local sFunc = "GenerateReward():";
    if not t.Types then 
        print(string.format("[-]: %s The supplied reward table is not formatted properly, subtable Types is missing, aborting", sFunc));
        return false;
    elseif #t.Types < 1 then 
        print(string.format("[-]: %s There are no valid Types in the supplied reward table, aborting", sFunc));
        return false;
    end
    local iNumRolls, iTypeRoll, iRewardRoll, bIsValidRoll = 0, 0, 0, false;
    local sValidation, tReward;
    while not bIsValidRoll and iNumRolls < n do 
        iNumRolls = iNumRolls + 1;
        iTypeRoll = RollDieWithSides(#t.Types);
        local sType = t.Types[iTypeRoll];
        if not sType then 
            print(string.format("[-]: %s 'FAILED' to obtain a valid reward Type, aborting", sFunc));
            return false;
        elseif not t.Rewards then 
            print(string.format("[-]: %s The supplied reward table is not formatted properly, subtable Rewards is missing, aborting", sFunc));
            return false;
        elseif #t.Rewards[sType] < 1 then 
            print(string.format("[-]: %s There are no valid Rewards for Type %s in the supplied reward table, aborting", sFunc, sType));
            return false;
        end
        iRewardRoll = RollDieWithSides(#t.Rewards[sType]);
        local sReward = t.Rewards[sType][iRewardRoll];
        if not sReward then 
            print(string.format("[-]: %s 'FAILED' to obtain a valid reward SubType, aborting", sFunc));
            return false;
        end
        local tReward = GameInfo.GoodyHutSubTypes_EGHV[sReward];
        if not tReward then 
            print(string.format("[-]: %s 'FAILED' to fetch gameplay DB table for %s, aborting", sFunc, sReward));
            return false;
        end
        bIsValidRoll, sValidation = self:ValidateReward(tReward);
        local sThisRoll = string.format("[%d]: Roll %d/%d:", self.RewardNum or -1, iNumRolls, n);
        local sRollDetails = string.format("[%d | %d | %s (%d)]:", iTypeRoll, iRewardRoll, tReward.TierType, tReward.Tier);
        local sRewardDetails = string.format("%d %s | %d %s", GameInfo.GoodyHuts_EGHV[sType].Hash, sType, tReward.Hash, sReward);
        print(string.format("%s %s %s %s", sThisRoll, sRollDetails, sRewardDetails, sValidation));
        if bIsValidRoll then 
            self:RefreshRewardDetails(tReward);
            if self.NumToPlace and self.NumToPlace > 1 then 
                local sUnitOrPop = self.UnitName and self.UnitName or "citizen";
                print(string.format("[i]: %s Critical roll! An additional %s will be granted (%d total)", sFunc, sUnitOrPop, self.NumToPlace));
            end
        end
    end
    if not bIsValidRoll then 
        print(string.format("[-]: %s 'FAILED' to generate a valid reward in %d %s", sFunc, iNumRolls, SingularOrPlural(iNumRolls, "attempt")));
    end
    return bIsValidRoll;
end

--[[ =========================================================================
	function AttachModifierToPlayer(self, bOnceOnly)
	attaches target Modifier with ID (Extra)ModifierID to target Player with ID PlayerID
    returns: 
        false when the provided Player table is invalid, or 
        false when the provided ModifierID field is invalid, or 
        false when bOnceOnly is true and target Modifier has previously been attached to target Player, or 
        true otherwise
    this should be added to a RewardGenerator object when needed
=========================================================================== ]]
function AttachModifierToPlayer(self, bOnceOnly) 
    bOnceOnly = (type(bOnceOnly) == "boolean") and bOnceOnly or false;
    local print = (g_iLoggingLevel > 2) and print or function (s, ...) return; end;    -- disable print function locally when logging level is not Verbose or higher
    local sFunc = "AttachModifierToPlayer():";
    if not self.Player then 
        print(string.format("[-]: %s Invalid Player table; aborting", sFunc));
        return false;
    elseif not self.ModifierID then 
        print(string.format("[-]: %s Invalid ModifierID; aborting", sFunc));
        return false;
    end
    local bIsAttached = false;
	if bOnceOnly then 
		if not self.Player:GetProperty(self.ModifierID) then 
			self.Player:AttachModifierByID(self.ModifierID);
			self.Player:SetProperty(self.ModifierID, true);
            bIsAttached = true;
            print(string.format("[+]: %s Successfully attached one-time Modifier %s to Player %d", sFunc, self.ModifierID, self.PlayerID));
		else 
            print(string.format("[i]: %s One-time Modifier %s has previously been attached to Player %d", sFunc, self.ModifierID, self.PlayerID));
		end
    elseif self.OncePerEra then 
        local iNumTimes = self.Player:GetProperty(self.ModifierID) or 0;
        self.Player:AttachModifierByID(self.ModifierID);
		self.Player:SetProperty(self.ModifierID, (iNumTimes + 1));
        bIsAttached = true;
        local sNumTimes = string.format("this Modifier has now been attached %d total %s to this Player", (iNumTimes + 1), SingularOrPlural((iNumTimes + 1), "time"));
        print(string.format("[+]: %s Successfully attached once-per-Era Modifier %s to Player %d; %s", sFunc, self.ModifierID, self.PlayerID, sNumTimes));
	else 
		self.Player:AttachModifierByID(self.ModifierID);
        bIsAttached = true;
        print(string.format("[+]: %s Successfully attached Modifier %s to Player %d", sFunc, self.ModifierID, self.PlayerID));
	end
    return bIsAttached;
end

--[[ =========================================================================
	function CreateUnitInCity(self)
	spawns one or more units belonging to target Player in a random City belonging to target Player
    returns: 
        false when the provided Unit field is invalid, or 
        false when the provided UnitType field is invalid, or 
        false when the provided Cities table is invalid or empty, or 
        false when the number of spawned units is zero, or 
        true otherwise
	this should be added to a RewardGenerator object when needed
=========================================================================== ]]
function CreateUnitInCity(self) 
    local print = (g_iLoggingLevel > 2) and print or function (s, ...) return; end;    -- disable print function locally when logging level is not Verbose or higher
    local sFunc = "CreateUnitInCity():";
    if not self.Unit then 
        print(string.format("[-]: %s Reward %s does not provide a unit; aborting", sFunc, self.Reward));
        return false;
    elseif not self.UnitType then 
        print(string.format("[-]: %s Invalid UnitType; aborting", sFunc));
        return false;
    elseif not self.Cities or #self.Cities < 1 then 
        print(string.format("[-]: %s Invalid or empty Cities table; aborting", sFunc));
        return false;
    end
    local bIsNaval = (GameInfo.Units[self.UnitType].FormationClass == "FORMATION_CLASS_NAVAL");
    local iNumPlaced = 0;
    for n = 1, self.NumToPlace do 
        local iCity = (#self.Cities > 1) and RollDieWithSides(#self.Cities) or 1;
        local pCity = self.Cities[iCity];
        local sCityName = Locale.Lookup(pCity:GetName());
	    local cX, cY = pCity:GetX(), pCity:GetY();
        local bHasEncampment = pCity:GetDistricts():HasDistrict(g_iEncampmentIndex);
        local bHasHarbor = pCity:GetDistricts():HasDistrict(g_iHarborIndex);
        local sThisCity = string.format("Player %d's City of %s", self.PlayerID, sCityName);
        local sThisUnit = string.format("[%d/%d]:", n, self.NumToPlace);
        if bHasHarbor and bIsNaval then 
            local pHarbor = pCity:GetDistricts():GetDistrict(g_iHarborIndex);
            local hX, hY = pHarbor:GetX(), pHarbor:GetY();
            UnitManager.InitUnit(self.PlayerID, self.UnitType, hX, hY);
            iNumPlaced = iNumPlaced + 1;
            print(string.format("[+]: %s %s Successfully created 1 %s in the Harbor District of %s", sFunc, sThisUnit, self.UnitName, sThisCity));
        elseif bHasEncampment and GameInfo.Units[self.UnitType].FormationClass == "FORMATION_CLASS_LAND_COMBAT" then 
            local pEncampment = pCity:GetDistricts():GetDistrict(g_iEncampmentIndex);
            local eX, eY = pEncampment:GetX(), pEncampment:GetY();
            UnitManager.InitUnit(self.PlayerID, self.UnitType, eX, eY);
            iNumPlaced = iNumPlaced + 1;
            print(string.format("[+]: %s %s Successfully created 1 %s in the Encampment District of %s", sFunc, sThisUnit, self.UnitName, sThisCity));
        else 
            if not bIsNaval then 
                UnitManager.InitUnit(self.PlayerID, self.UnitType, cX, cY);
                iNumPlaced = iNumPlaced + 1;
                print(string.format("[+]: %s %s Successfully created 1 %s in the City Center District of %s", sFunc, sThisUnit, self.UnitName, sThisCity));
            else 
                print(string.format("[-]: %s %s 'FAILED' to create 1 %s in %s", sFunc, sThisUnit, self.UnitName, sThisCity));
            end
        end
    end
    return (iNumPlaced > 0);
end

--[[ =========================================================================
	function CreateUnitInPlot(self)
    spawns one or more units belonging to target Player near plot (X, Y)
    when there are no valid spawn plots, and target Player is not the Barbarian Player, remaining units are spawned in a random City belonging to target Player
    returns: 
        false when the provided Hostile field and the provided Unit field are both invalid, or 
        false when the provided UnitType field is invalid, or 
        false when the number of spawned units is zero, or 
        the result of CreateUnitInCity() if it is called, or 
        true otherwise
	this should be added to a RewardGenerator object when needed
=========================================================================== ]]
function CreateUnitInPlot(self) 
    local print = (g_iLoggingLevel > 2) and print or function (s, ...) return; end;    -- disable print function locally when logging level is not Verbose or higher
    local sFunc = "CreateUnitInPlot():";
    if not self.Hostile and not self.Unit then 
        print(string.format("[-]: %s Reward %s does not provide a unit; aborting", sFunc, self.Reward));
        return false;
    elseif not self.UnitType then 
        print(string.format("[-]: %s Invalid UnitType; aborting", sFunc));
        return false;
    end
    self.CreateUnitInCity = CreateUnitInCity;    -- add fallback function
    if self.UnitType == "UNIT_TRADER" then return self:CreateUnitInCity(); end    -- skip directly to City placement for Trader
    local iPlayerID = self.Hostile and g_iBarbarianID or self.PlayerID;
    local bIsNaval = (GameInfo.Units[self.UnitType].FormationClass == "FORMATION_CLASS_NAVAL");
    local tValidPlots = bIsNaval and self.WaterUnitPlots or self.LandUnitPlots;
    local sDistance = string.format("within a %d plot radius of plot (x %d, y %d)", self.Radius, self.X, self.Y);
    if #tValidPlots < 1 then 
        local sSummary = string.format("[i]: %s There are no valid plots %s in which a new %s may be created", sFunc, sDistance, self.UnitName);
        if iPlayerID ~= g_iBarbarianID then 
            print(string.format("%s; attempting City placement instead . . .", sSummary));
            return self:CreateUnitInCity();    -- skip directly to City placement when there are no valid plots
        else 
            print(string.format("%s", sSummary));
            return false;
        end
    end
    local sValidPlots = string.format("Identified %d valid %s %s", #tValidPlots, SingularOrPlural(#tValidPlots, "plot"), sDistance);
    print(string.format("[i]: %s %s in which a new %s may be created", sFunc, sValidPlots, self.UnitName));
    local iNumRemaining = self.NumToPlace;
    local iNumPlaced = 0;
    for n = 1, self.NumToPlace do 
        if #tValidPlots > 0 then 
            local bUnitPlaced = false;
            local tFailedPlots = {};
            local pSpawnPlot;
            bUnitPlaced, pSpawnPlot, tValidPlots, tFailedPlots = PlaceUnitInRandomPlot(tValidPlots, self.UnitType, iPlayerID);
            if bIsNaval then self.WaterUnitPlots = tValidPlots; 
            else self.LandUnitPlots = tValidPlots;
            end
            local iAttempts = bUnitPlaced and #tFailedPlots + 1 or #tFailedPlots;
            local sAttempts = string.format("%d %s", iAttempts, SingularOrPlural(iAttempts, "attempt"));
            if bUnitPlaced then 
                iNumRemaining = iNumRemaining - 1;
                iNumPlaced = iNumPlaced + 1;
                local sX, sY = pSpawnPlot:GetX(), pSpawnPlot:GetY();
                if iPlayerID == g_iBarbarianID then 
                    local sI = pSpawnPlot:GetIndex();
                    PlayersVisibility[self.PlayerID]:ChangeVisibilityCount(sI, 0);    -- mark this plot as explored by this Player
                    if self.IsHuman then 
                        local sHostileUnitMessage = string.format("%s %s %s", g_tNotification.Hostile.UnitMessage1, sUnitName, g_tNotification.Hostile.UnitMessage2);
                        NotificationManager.SendNotification(self.PlayerID, g_tNotification.Hostile.UnitTypeHash, g_tNotification.Hostile.Title, sHostileUnitMessage, sX, sY);
                    end
                end
                local sThisUnit = string.format("[%d/%d]: Successfully created 1 %s", n, self.NumToPlace, self.UnitName);
                print(string.format("[+]: %s %s in plot (x %d, y %d) under the control of Player %d (%s)", sFunc, sThisUnit, sX, sY, iPlayerID, sAttempts));
            else 
                local sThisUnit = string.format("[%d/%d]: 'FAILED' to create 1 %s", n, self.NumToPlace, self.UnitName);
                local sSummary = string.format("[-]: %s %s under the control of Player %d in %s", sFunc, sThisUnit, iPlayerID, sAttempts);
                if iPlayerID ~= g_iBarbarianID then 
                    print(string.format("%s; attempting City placement for this unit . . .", sSummary));
                    local bSuccess = self:CreateUnitInCity();    --fallback to City placement for this unit
                    if bSuccess then 
                        iNumRemaining = iNumRemaining - 1;
                        iNumPlaced = iNumPlaced + 1;
                    end
                else 
                    print(string.format("%s", sSummary));
                    return (iNumPlaced > 0);
                end
            end
        else 
            local sSummary = string.format("[i]: %s [%d/%d]: There are no remaining valid plots %s in which a new %s may be created", sFunc, n, self.NumToPlace, sDistance, self.UnitName);
            if iPlayerID ~= g_iBarbarianID then 
                print(string.format("%s; attempting City placement for %d remaining %s . . .", sSummary, iNumRemaining, SingularOrPlural(iNumRemaining, "unit")));
                self.NumToPlace = iNumRemaining;
                return self:CreateUnitInCity();    -- fallback to City placement for remaining unit(s)
            else 
                print(string.format("%s", sSummary));
                return (iNumPlaced > 0);
            end
        end
    end
    return (iNumPlaced > 0);
end

--[[ =========================================================================
	function AddPopulationToCity(self)
    places one or more citizens in one or more random Cities belonging to target Player
    returns: 
        false when the provided Cities table is invalid or empty, or 
        false when the number of placed citizens is zero, or 
        true otherwise
	this should be added to a RewardGenerator object when needed
=========================================================================== ]]
function AddPopulationToCity(self) 
    local print = (g_iLoggingLevel > 2) and print or function (s, ...) return; end;    -- disable print function locally when logging level is not Verbose or higher
    local sFunc = "AddPopulationToCity():";
	if not self.Cities or #self.Cities < 1 then 
        print(string.format("[-]: %s Invalid or empty Cities table; aborting", sFunc));
        return false;
    end
    local iNumPlaced = 0;
    for n = 1, self.NumToPlace do 
        local iCity = (#self.Cities > 1) and RollDieWithSides(#self.Cities) or 1;
	    local pCity = self.Cities[iCity];
        local sCityName = Locale.Lookup(pCity:GetName());
        local iCurrentPop = pCity:GetPopulation();
        pCity:ChangePopulation(1);
        local sThisPop = string.format("[%d/%d]:", n, self.NumToPlace);
        if pCity:GetPopulation() == (iCurrentPop + 1) then 
            iNumPlaced = iNumPlaced + 1;
            print(string.format("[+]: %s %s Successfully increased the population of Player %d's City of %s by 1 citizen", sFunc, sThisPop, self.PlayerID, sCityName));
        else 
            print(string.format("[-]: %s %s 'FAILED' to increase the population of Player %d's City of %s by 1 citizen", sFunc, sThisPop, self.PlayerID, sCityName));
        end
    end
    return (iNumPlaced > 0);
end

--[[ =========================================================================
	function AddXPToUnit(self)
    adds combat experience to eligible units in table Units
    returns: 
        false when the provided Units table is invalid or empty, or 
        false when the provided Experience field is invalid, or 
        false when the provided ExperienceMultiplier field is invalid, or 
        false when the number of affected units is zero, or 
        true otherwise
	this should be added to a RewardGenerator object when needed
=========================================================================== ]]
function AddXPToUnit(self) 
    local print = (g_iLoggingLevel > 2) and print or function (s, ...) return; end;    -- disable print function locally when logging level is not Verbose or higher
    local sFunc = "AddXPToUnit():";
    if not self.Units or #self.Units < 1 then 
        print(string.format("[-]: %s Invalid or empty Units table; aborting", sFunc));
        return false;
    elseif not self.Experience or not self.ExperienceMultiplier then 
        print(string.format("[-]: %s Reward %s does not provide combat experience; aborting", sFunc, self.Reward));
        return false;
    end
    local iNumAffected = 0;
    for i, pUnit in ipairs(self.Units) do 
        local sThisUnit = string.format("%s [%d/%d]: Player %d's %s in or near plot (x %d, y %d)", sFunc, i, #self.Units, self.PlayerID, pUnit.Name, self.X, self.Y);
        if (pUnit.FormationClass == "FORMATION_CLASS_LAND_COMBAT") or (pUnit.FormationClass == "FORMATION_CLASS_NAVAL") or (pUnit.FormationClass == "FORMATION_CLASS_AIR") then 
            local pUnitExperience = pUnit:GetExperience();
            if pUnitExperience then 
                local iXPFNL = pUnitExperience:GetExperienceForNextLevel();
                local iXP = math.floor(GameInfo.PromotionLevels[iXPFNL].XPTNL * self.ExperienceMultiplier);
                pUnitExperience:ChangeExperience(iXP);
                iNumAffected = iNumAffected + 1;
                print(string.format("[+]: %s has received %d experience points towards its next promotion", sThisUnit, iXP));
            end
        else 
            print(string.format("[-]: %s is ineligible for combat experience", sThisUnit));
        end
    end
    return (iNumAffected > 0);
end

--[[ =========================================================================
	function AttachAbilityToUnit(self)
    attaches target ability to eligible units in table Units
    returns: 
        false when the provided Units table is invalid or empty, or 
        false when the provided UnitAbility field is invalid, or 
        false when target Ability or a substitute is not attached to any valid units, or 
        false when the number of affected units is zero, or 
        true otherwise
	this should be added to a RewardGenerator object when needed
=========================================================================== ]]
function AttachAbilityToUnit(self) 
    local print = (g_iLoggingLevel > 2) and print or function (s, ...) return; end;    -- disable print function locally when logging level is not Verbose or higher
    local sFunc = "AttachAbilityToUnit():";
	if not self.Units or #self.Units < 1 then 
        print(string.format("[-]: %s Invalid or empty Units table", sFunc));
        return false;
    elseif not self.UnitAbility then 
        print(string.format("[-]: %s Reward %s does not provide a unit ability", sFunc, self.Reward));
        return false;
    end
    local iNumAffected = 0;
    for i, pUnit in ipairs(self.Units) do 
        local sAbility = self.UnitAbility;
        local pUnitAbility = pUnit:GetAbility();
        local sThisUnit = string.format("%s [%d/%d]: Player %d's %s in or near plot (x %d, y %d)", sFunc, i, #self.Units, self.PlayerID, pUnit.Name, self.X, self.Y);
        if (sAbility == "ABILITY_IMPROVED_HEALING" or sAbility == "ABILITY_IMPROVED_STRENGTH") and (pUnit.FormationClass ~= "FORMATION_CLASS_LAND_COMBAT" and pUnit.FormationClass ~= "FORMATION_CLASS_NAVAL") then 
            local sSummary = string.format("[i]: %s is ineligible for ability %s", sThisUnit, sAbility);
            local iReplacementRoll = g_bEqualizeRewards and FlipCoin() or RollDieWithSides(6);
            sAbility = (iReplacementRoll == 1) and "ABILITY_IMPROVED_MOVEMENT" or "ABILITY_IMPROVED_SIGHT";
            print(string.format("%s; selecting substitute ability instead . . .", sSummary));
        end
        if pUnitAbility:GetAbilityCount(sAbility) > 0 then 
            print(string.format("[i]: %s has previously had ability %s attached to it", sThisUnit, sAbility));
        else 
            pUnitAbility:ChangeAbilityCount(sAbility, 1);
            if pUnitAbility:GetAbilityCount(sAbility) > 0 then 
                iNumAffected = iNumAffected + 1;
                print(string.format("[+]: %s has successfully had ability %s attached to it", sThisUnit, sAbility));
            else 
                print(string.format("[-]: %s has 'FAILED' to have ability %s attached to it", sThisUnit, sAbility));
            end
        end
    end
    return (iNumAffected > 0);
end

--[[ =========================================================================
	function PlaceImprovementInPlot(self, i, n, r, e) 
	places up to n new Improvements with index i in random nearby plots within a radius of (e + 1) to r plots from target plot
    returns: 
        false when there are no valid nearby plots in which to place the Improvement, or 
        false when the number of placed Improvements is zero, or
        true otherwise
    this should be added to a RewardGenerator object when needed
=========================================================================== ]]
function PlaceImprovementInPlot(self, tValidPlots, i, n, r, e) 
    local print = (g_iLoggingLevel > 2) and print or function (s, ...) return; end;    -- disable print function locally when logging level is not Verbose or higher
    local sFunc = "PlaceImprovementInPlot():";
    i = (type(i) == "number" and i > -1) and i or self.Hostile and g_iBarbCampIndex or g_iGoodyHutIndex;
    n = (type(n) == "number" and n >= 2) and n or (i == g_iGoodyHutIndex) and self.RewardTier or 1;
    r = (type(r) == "number" and r >= 2) and r or (i == g_iGoodyHutIndex) and 8 or (i == g_iBarbCampIndex) and 3 or 1;
    e = (type(e) == "number" and e >= 1 and e < r) and e or (i == g_iGoodyHutIndex) and 2 or 0;
    tValidPlots = (type(tValidPlots) == "table" and #tValidPlots > 0) and tValidPlots or GetValidPlotsForImprovement(GetAdjacentPlotsInRadius(self.X, self.Y, r, e), i);
    local sImprovement = GameInfo.Improvements[i] and Locale.Lookup(GameInfo.Improvements[i].Name) or "unspecified improvement";
    local sDistance = string.format("within a %s plot radius of plot (x %d, y %d)", e > 0 and string.format("%d to %d", (e + 1), r) or string.format("%d", r), self.X, self.Y);
    if #tValidPlots < 1 then 
        print(string.format("[i]: %s There are no valid plots %s in which a new %s may be created", sFunc, sDistance, sImprovement));
        return false;
    end
    local sValidPlots = string.format("Identified %d valid %s %s", #tValidPlots, SingularOrPlural(#tValidPlots, "plot"), sDistance);
    print(string.format("[i]: %s %s in which a new %s may be created", sFunc, sValidPlots, sImprovement));
    local iNumPlaced = 0;
    for a = 1, n do 
        local sThisImprovement = string.format("[%d/%d]:", a, n);
        if #tValidPlots > 0 then 
            local bImprovementPlaced = false;
            local tFailedPlots = {};
            local pSpawnPlot;
            bImprovementPlaced, pSpawnPlot, tValidPlots, tFailedPlots = PlaceImprovementInRandomPlot(tValidPlots, i);
            local iAttempts = bImprovementPlaced and #tFailedPlots + 1 or #tFailedPlots;
            local sAttempts = string.format("%d %s", iAttempts, SingularOrPlural(iAttempts, "attempt"));
            if bImprovementPlaced then 
                iNumPlaced = iNumPlaced + 1;
                local sI, sX, sY = pSpawnPlot:GetIndex(), pSpawnPlot:GetX(), pSpawnPlot:GetY();
                PlayersVisibility[self.PlayerID]:ChangeVisibilityCount(sI, 0);    -- mark this plot as explored by this Player
                if self.Hostile and self.IsHuman then 
                    NotificationManager.SendNotification(self.PlayerID, g_tNotification.Hostile.CampTypeHash, g_tNotification.Hostile.Title, g_tNotification.Hostile.CampMessage, sX, sY);
                end
                local sSummary = string.format("[+]: %s %s Successfully created a new %s in plot (x %d, y %d) in %s", sFunc, sThisImprovement, sImprovement, sX, sY, sAttempts);
                if i == g_iGoodyHutIndex then 
                    table.insert(g_tGoodyHutPlots, pSpawnPlot);
                    sSummary = string.format("%s; now %d remaining", sSummary, #g_tGoodyHutPlots);
                end
                print(sSummary);
            else 
                print(string.format("[-]: %s %s 'FAILED' to create a new %s in %s", sFunc, sThisImprovement, sImprovement, sAttempts));
            end
        else 
            print(string.format("[i]: %s %s There are no remaining valid plots %s in which a new %s may be created", sFunc, sThisImprovement, sDistance, sImprovement));
            return (iNumPlaced > 0);
        end
    end
    return (iNumPlaced > 0);
end

--[[ =========================================================================
	function GetHostilityLevel(self)
	calculate villager hostility after a reward, based on popping method and/or unit, selected difficulty, current Game/Player Era, and rarity of any received reward(s)
	when this value equals or exceeds the spawn threshold, hostile villagers will be created
    returns the calculated hostility level as a GoodyHutSubType
    this should be added to a RewardGenerator object when needed
=========================================================================== ]]
function GetHostilityLevel(self) 
    local print = (g_iLoggingLevel > 2) and print or function (s, ...) return; end;    -- disable print function locally when logging level is not Verbose or higher
    local sFunc = "GetHostilityLevel():";
    local iSpawn = 100;
	local sHostile;
    local sHostileChance = g_tHostilesAfterReward[g_iHostilesAfterReward];
    local iBase = ((self.Modifiers.Discovery * self.Modifiers.Difficulty) + self.Modifiers.Reward) * self.Modifiers.Era;
    local sBase = string.format("((%d * %d) + %d) * %d", self.Modifiers.Discovery, self.Modifiers.Difficulty, self.Modifiers.Reward, self.Modifiers.Era);
    local iRandom = RollDieWithSides(iSpawn);
	local iInitial = iBase + iRandom;
	if (g_iHostilesAfterReward > 2) then 
        while (iInitial < iSpawn) do iInitial = iInitial * 2; end 
    end
    local tThresholds = { iSpawn, (iSpawn * 1.33), (iSpawn * 1.67), (iSpawn * 2) };
    local iThreshold = iSpawn;
    local iExtra = (g_iHostilesAfterReward > 3) and iSpawn or 0;
	if (iInitial >= iSpawn) then 
		local iFinal = iInitial + iExtra;
        for h = 4, 1, -1 do 
            if iFinal >= tThresholds[h] then 
                sHostile = g_tHostileRewards[h];
                iThreshold = tThresholds[h];
                break;
            end
        end
        print(string.format("[H]: %s Hostility Check: [(%s) + %d + %d = %d | %d]: Villager hostility level %s", sFunc, sBase, iRandom, iExtra, iFinal, iThreshold, tostring(sHostile)));
	else 
        print(string.format("[H]: %s Hostility Check: [(%s) + %d + %d = %d | %d]: Villager hostility level %s", sFunc, sBase, iRandom, iExtra, iInitial, iThreshold, tostring(sHostile)));
	end
	return sHostile;
end

--[[ =========================================================================
	function CreateHostileVillagers(self)
	spawns hostile barbarian units (and barbarian camps, if applicable) near the specified plot
	ingame notification sent to Player that received reward if human
    returns: 
        false when the number of spawned barbarian (camps and) units is zero, or 
        true otherwise
    this should be added to a RewardGenerator object when needed
=========================================================================== ]]
function CreateHostileVillagers(self) 
    local print = (g_iLoggingLevel > 2) and print or function (s, ...) return; end;    -- disable print function locally when logging level is not Verbose or higher
    local sFunc = "CreateHostileVillagers():";
    if not self.LandUnitPlots and not self.WaterUnitPlots then 
        print(string.format("[i]: %s Neither of the provided unit spawn plot tables are valid", sFunc));
        return false;
    elseif (#self.LandUnitPlots + #self.WaterUnitPlots) == 0 then 
        print(string.format("[i]: %s There are no valid land or water plots in which a new hostile unit may be created", sFunc));
        return false;
    end
    self.CreateUnitInPlot = CreateUnitInPlot;
    self.NumToPlace = 1;
    self.Adverb = g_tHostilityAdverbs[self.RewardTier];
    local iNumUnits = (self.RewardTier > (#self.LandUnitPlots + #self.WaterUnitPlots)) and (#self.LandUnitPlots + #self.WaterUnitPlots) or self.RewardTier;
    local iMaxLandUnits = (#self.LandUnitPlots == 0) and 0 or (self.RewardTier > #self.LandUnitPlots) and #self.LandUnitPlots or self.RewardTier;
    local iMaxWaterUnits = (#self.WaterUnitPlots == 0) and 0 or (self.RewardTier > #self.WaterUnitPlots) and #self.WaterUnitPlots or self.RewardTier;
    local tLandClasses = { "Melee", "Ranged", "AntiCavalry" };
    if self.Resources["RESOURCE_HORSES"] then 
        tLandClasses[(#tLandClasses + 1)] = "HeavyCavalry";
        tLandClasses[(#tLandClasses + 1)] = "LightCavalry";
    end
    local tWaterClasses = { "NavalMelee", "NavalRanged" };
    local tHostileClasses = {};
    for n = 1, iNumUnits do 
        if iMaxLandUnits > 0 and iMaxWaterUnits > 0 then 
            local iRandomClass = RollDieWithSides((#tLandClasses + #tWaterClasses));
            if iRandomClass > #tWaterClasses then 
                if #self.WaterUnitPlots > #self.LandUnitPlots then 
                    tHostileClasses[(#tHostileClasses + 1)] = tWaterClasses[RollDieWithSides(#tWaterClasses)];
                    iMaxWaterUnits = iMaxWaterUnits - 1;
                else 
                    tHostileClasses[(#tHostileClasses + 1)] = tLandClasses[RollDieWithSides(#tLandClasses)];
                    iMaxLandUnits = iMaxLandUnits - 1;
                end
            else 
                if #self.LandUnitPlots > #self.WaterUnitPlots then 
                    tHostileClasses[(#tHostileClasses + 1)] = tLandClasses[RollDieWithSides(#tLandClasses)];
                    iMaxLandUnits = iMaxLandUnits - 1;
                else 
                    tHostileClasses[(#tHostileClasses + 1)] = tWaterClasses[RollDieWithSides(#tWaterClasses)];
                    iMaxWaterUnits = iMaxWaterUnits - 1;
                end
            end
        elseif iMaxLandUnits == 0 then 
            tHostileClasses[(#tHostileClasses + 1)] = tWaterClasses[RollDieWithSides(#tWaterClasses)];
            iMaxWaterUnits = iMaxWaterUnits - 1;
        elseif iMaxWaterUnits == 0 then 
            tHostileClasses[(#tHostileClasses + 1)] = tLandClasses[RollDieWithSides(#tLandClasses)];
            iMaxLandUnits = iMaxLandUnits - 1;
        end
    end
    local iNumPlaced = 0;
    if (self.RewardTier == 4) then 
        self.PlaceImprovementInPlot = PlaceImprovementInPlot;    -- add this only when a camp is scheduled to be spawned
        print(string.format("[i]: %s The villagers are %s hostile, and will attempt to establish a new Barbarian Outpost near plot (x %d, y %d)!", sFunc, self.Adverb, self.X, self.Y));
        local bSuccess = self:PlaceImprovementInPlot(self.BarbCampPlots, g_iBarbCampIndex);
        if bSuccess then iNumPlaced = iNumPlaced + 1; end
    end
    local iValidPlots = #self.LandUnitPlots + #self.WaterUnitPlots;
    local sDistance = string.format("within a %d plot radius of plot (x %d, y %d)", self.Radius, self.X, self.Y);
    local sValidPlots = string.format("Identified %d valid %s %s", iValidPlots, SingularOrPlural(iValidPlots, "plot"), sDistance);
    print(string.format("[i]: %s %s in which a new hostile unit may be created", sFunc, sValidPlots));
    for i, class in ipairs(tHostileClasses) do 
        self.UnitType = self:GetEligibleUnitOfClass(class);
        self.UnitName = Locale.Lookup(GameInfo.Units[self.UnitType].Name);
        local sClass = string.format("a new %s near plot (x %d, y %d)!", self.UnitName, self.X, self.Y);
        print(string.format("[i]: %s The villagers are %s hostile, and will attempt to organize into %s", sFunc, self.Adverb, sClass));
        local bSuccess = self:CreateUnitInPlot();
        if bSuccess then iNumPlaced = iNumPlaced + 1; end
    end
    return (iNumPlaced > 0);
end

--[[ =========================================================================
	function UnlockVillagerSecrets(self)
	unlocks the ability to construct the target Tribal Totem building for target Player
    if this ability has previously been unlocked for target Player, instead place the target Tribal Totem building in a randomly selected City belonging to target Player
    returns: 
        false when the provided Player table is invalid, or 
        false when the provided Cities table is invalid or empty, or 
        false when the provided ModifierID field is invalid, or 
        false when the target Tribal Totem building is unable to be constructed in any of target Player's Cities, or 
        true otherwise
    this should be added to a RewardGenerator object when needed
=========================================================================== ]]
function UnlockVillagerSecrets(self) 
    local print = (g_iLoggingLevel > 2) and print or function (s, ...) return; end;    -- disable print function locally when logging level is not Verbose or higher
    local sFunc = "UnlockVillagerSecrets():";
    if not self.Player then 
        print(string.format("[-]: %s Invalid Player table; aborting", sFunc));
        return false;
    elseif not self.Cities or #self.Cities < 1 then 
        print(string.format("[-]: %s Invalid or empty Cities table; aborting", sFunc));
        return false;
    elseif not self.ModifierID then 
        print(string.format("[-]: %s Invalid ModifierID; aborting", sFunc));
        return false;
    end
    self.AttachModifierToPlayer = AttachModifierToPlayer;
    if not self.Player:GetProperty(self.ModifierID) then 
        print(string.format("[i]: %s Modifier %s has 'NOT' previously been attached to Player %d; unlocking villager secrets . . .", sFunc, self.ModifierID, self.PlayerID));
        if self.IsHuman then 
            NotificationManager.SendNotification(self.PlayerID, g_tNotification.Secret.TypeHash, g_tNotification.Secret.Title, g_tNotification.Secret.Message); 
        end
        return self:AttachModifierToPlayer(true);
    else 
        local iTotemIndex = g_tVillagerTotems[self.Reward];
        local sTotemName = Locale.Lookup(GameInfo.Buildings[iTotemIndex].Name);
        print(string.format("[i]: %s Modifier %s has previously been attached to Player %d; attempting to place the %s building in one of this Player's Cities . . .", sFunc, self.ModifierID, self.PlayerID, sTotemName));
        local bValidCityFound = false;
        while not bValidCityFound and #self.Cities > 0 do 
            local iCity = (#self.Cities > 1) and RollDieWithSides(#self.Cities) or 1;
            local pCity = self.Cities[iCity];
            table.remove(self.Cities, iCity);
            local sThisCity = string.format("in Player %d's City of %s", self.PlayerID, Locale.Lookup(pCity:GetName()));
            if not pCity:GetBuildings():HasBuilding(iTotemIndex) then 
                print(string.format("[i]: %s The %s building is 'NOT' already present %s; attempting to place this building . . .", sFunc, sTotemName, sThisCity));
                local pPlot = Map.GetPlot(pCity:GetX(), pCity:GetY());
                local pCityBuildQueue = pCity:GetBuildQueue();
                pCityBuildQueue:CreateIncompleteBuilding(iTotemIndex, pPlot:GetIndex(), 100);
                if pCity:GetBuildings():HasBuilding(iTotemIndex) then 
                    bValidCityFound = true;
                    print(string.format("[+]: %s Successfully created the %s building %s", sFunc, sTotemName, sThisCity));
                else 
                    print(string.format("[-]: %s 'FAILED' to create the %s building %s", sFunc, sTotemName, sThisCity));
                end
            else 
                print(string.format("[i]: %s The %s building is alrady present %s", sFunc, sTotemName, sThisCity));
            end
        end
        if not bValidCityFound then 
            print(string.format("[-]: %s 'FAILED' to create the %s building in any of Player %d's Cities", sFunc, sTotemName, self.PlayerID));
        end
        return bValidCityFound;
    end
end

--[[ =========================================================================
	function UpgradeUnit(self)
    "upgrades" eligible units in table Units
    this consists of destroying an eligible unit and placing a new unit which the old one would have upgraded to
    existing promotions will be lost; experience and stored promotions will be added to the new unit to be able to promote it one level beyond the old unit's level
    existing abilities will be transferred
    existing formation configuration will be lost
    returns: 
        false when the provided Units table is invalid or empty, or 
        false when the number of affected units is zero, or 
        true otherwise
	this should be added to a RewardGenerator object when needed
=========================================================================== ]]
function UpgradeUnit(self) 
    local print = (g_iLoggingLevel > 2) and print or function (s, ...) return; end;    -- disable print function locally when logging level is not Verbose or higher
    local sFunc = "UpgradeUnit():";
    if not self.Units or #self.Units < 1 then 
        print(string.format("[-]: %s Invalid or empty Units table; aborting", sFunc));
        return false;
    end
    local tNewUnits = {};
    local iNumAffected = 0;
    for i, pUnit in ipairs(self.Units) do 
        local bPoppingUnit = (pUnit.ID == self.UnitID);
        local sVeteranName = Locale.Lookup(pUnit.VeteranName);
        local sOldUnit = string.format("%s%s", pUnit.Name, (sVeteranName ~= nil and sVeteranName ~= "") and string.format(" named %s", sVeteranName) or "");
        local iX, iY = pUnit:GetX(), pUnit:GetY();
        local sThisUnit = string.format("%s [%d/%d]: Player %d's %s in or near plot (x %d, y %d)", sFunc, i, #self.Units, self.PlayerID, sOldUnit, iX, iY);
        if GameInfo.UnitUpgrades[pUnit.Type] then 
            local sUpgradeUnit = GameInfo.UnitUpgrades[pUnit.Type].UpgradeUnit;
            local sUpgradeUnitName = Locale.Lookup(GameInfo.Units[sUpgradeUnit].Name);
            print(string.format("[i]: %s has a valid upgrade path to %s", sThisUnit, sUpgradeUnitName));
            local bCanUpgrade = false;
            local sPrereqTech = GameInfo.Units[sUpgradeUnit].PrereqTech;
            local sResource = GameInfo.Units[sUpgradeUnit].StrategicResource;
            if self.Player:GetTechs():HasTech(GameInfo.Technologies[sPrereqTech].Index) then 
                if sResource then 
                    if self.Player:GetResources():HasResource(GameInfo.Resources[sResource].Index) then 
                        bCanUpgrade = true;
                    end
                elseif not sResource then 
                    bCanUpgrade = true;
                end
            end
            if bCanUpgrade then 
                print(string.format("[i]: %s Player %d possesses the resources and/or technology required to upgrade this unit; performing 'upgrade'", sFunc, self.PlayerID));
                local pUnitAbility = pUnit:GetAbility();
                local pUnitExperience = pUnit:GetExperience();
                local tAbilities = pUnitAbility:GetAbilities();
                local iLevel = GameInfo.PromotionLevels[pUnit.XPFNL].Level;
                UnitManager.Kill(pUnit);
                print(string.format("[-]: %s Existing %s destroyed", sFunc, pUnit.Name));
	    		UnitManager.InitUnit(self.PlayerID, sUpgradeUnit, iX, iY, 1);
                for n, kUnit in ipairs(Units.GetUnitsInPlotLayerID(iX, iY, MapLayers.ANY)) do 
			    	if kUnit:GetOwner() == self.PlayerID and GameInfo.Units[kUnit:GetType()].UnitType == sUpgradeUnit then 
                        print(string.format("[+]: %s New %s created", sFunc, sUpgradeUnitName));
                        iNumAffected = iNumAffected + 1;
                        if bPoppingUnit then self.UnitID = kUnit:GetID(); end
                        local kUnitAbility = kUnit:GetAbility();
                        local kUnitExperience = kUnit:GetExperience();
                        for _, a in ipairs(tAbilities) do 
                            local sAbility = GameInfo.UnitAbilities[a.Ability].UnitAbilityType;
                            if kUnitAbility:GetAbilityCount(sAbility) < 1 then 
                                kUnitAbility:ChangeAbilityCount(sAbility, 1);
                                print(string.format("[i]: %s Ability %s reapplied to new %s", sFunc, sAbility, sUpgradeUnitName));
                            end
                        end
                        local iXPFNL = kUnitExperience:GetExperienceForNextLevel();
			    		kUnitExperience:ChangeExperience(iXPFNL);
                        print(string.format("[i]: %s %d combat experience granted to new %s", sFunc, iXPFNL, sUpgradeUnitName));
                        if (iLevel > 1) then 
                            kUnitExperience:ChangeStoredPromotions(iLevel - 1);
                            print(string.format("[i]: %s %d stored %s added to new %s", sFunc, (iLevel - 1), SingularOrPlural((iLevel - 1), "promotion"), sUpgradeUnitName));
                        end
                        if (sVeteranName ~= nil and sVeteranName ~= "") then 
				    	    kUnitExperience:SetVeteranName(sVeteranName);
                            print(string.format("[i]: %s Veteran name %s restored to new %s", sFunc, sVeteranName, sUpgradeUnitName));
                        end
	    				UnitManager.FinishMoves(kUnit);
                        print(string.format("[i]: %s Current movement for new %s reset to zero", sFunc, sUpgradeUnitName));
                        table.insert(tNewUnits, kUnit);
                        local sNewUnit = string.format("%s%s", sUpgradeUnitName, (sVeteranName ~= nil and sVeteranName ~= "") and string.format(" named %s", sVeteranName) or "");
                        print(string.format("[+]: %s has been successfully 'upgraded' to a %s", sThisUnit, sNewUnit));
                        break;
                    end
                end
            else 
                table.insert(tNewUnits, pUnit);
                print(string.format("[i]: %s Player %d does 'NOT' possess the resources and/or technology required to upgrade this unit", sFunc, self.PlayerID));
            end
        else 
            table.insert(tNewUnits, pUnit);
            print(string.format("[i]: %s does 'NOT' have a valid upgrade path", sThisUnit));
        end
    end
    if #tNewUnits > 0 then 
        self.Units = {};
        for i, pUnit in ipairs(tNewUnits) do 
            self.Units[i] = pUnit;
            self.Units[i].ID = pUnit:GetID();
            self.Units[i].Type = GameInfo.Units[pUnit:GetType()].UnitType or nil;
            self.Units[i].Name = Locale.Lookup(GameInfo.Units[pUnit:GetType()].Name) or nil;
            self.Units[i].PromotionClass = GameInfo.Units[pUnit:GetType()].PromotionClass or nil;
            self.Units[i].FormationClass = GameInfo.Units[pUnit:GetType()].FormationClass or nil;
            self.Units[i].FormationID = pUnit:GetFormationID() or nil;
            self.Units[i].FormationCount = pUnit:GetFormationUnitCount() or nil;
            if pUnit:GetExperience() then 
                self.Units[i].VeteranName = pUnit:GetExperience():GetVeteranName() or nil;
                self.Units[i].XP = pUnit:GetExperience():GetExperiencePoints() or nil;
                self.Units[i].XPFNL = pUnit:GetExperience():GetExperienceForNextLevel() or nil;
            end
        end
    end
    return (iNumAffected > 0);
end

--[[ =========================================================================
    end EGHV component script EGHV_RewardGenerator.lua; below here is deprecated code
=========================================================================== ]]

--[[ =========================================================================
	function RewardGenerator:GetBonusRewards(n)
    generate and apply up to n bonus reward(s)
    returns: 
        -1 if a hostile 'reward' is selected as any bonus reward, or 
        -2 if GenerateReward() fails to identify a valid reward and a fallback, or 
        cumulative hostile modifier h if n bonus rewards are successfully generated
=========================================================================== ]]
-- function RewardGenerator:GetBonusRewards(n) 
--     local h = self.RewardTier;
--     for i = 1, n do 
--         -- local bSuccess = self:GenerateReward(g_iActiveRewardCount);
--         local bSuccess = self.IsExplore and self:GenerateReward() or self:GenerateReward(g_tValidRewards.Expansion, g_iExpansionRewardCount);
--         if not bSuccess then bSuccess = self:GenerateReward(g_tValidRewards.Fallback, g_iFallbackRewardCount); end
--         if not bSuccess then return -2; end
--         if self.Type == "GOODYHUT_SAILOR_WONDROUS" then 
--             WGH.Sailor_WGH(self.PlayerID, self.UnitID, self.TypeHash, self.RewardHash);
--         else 
--             local tSummary = self:GrantReward();
--             table.insert(self.Summary, tSummary);
--         end
--         if self.Player:IsHuman() then 
--             local pAdjacentPlot = Map.GetAdjacentPlot(self.X, self.Y, (i - 1));
-- 			local aX, aY = pAdjacentPlot:GetX(), pAdjacentPlot:GetY();
--             local sRewardTitle, sRewardMessage = g_tNotification.Reward.Title, string.format("%s %s.", g_tNotification.Reward.Message, self.Description);
--             NotificationManager.SendNotification(self.PlayerID, g_tNotification.Reward.TypeHash, sRewardTitle, sRewardMessage, aX, aY);
--             Game.AddWorldViewText(self.PlayerID, self.Description, self.X, self.Y, 0);
--         end
--         if self.Hostile then return -1; end
--         h = h + self.RewardTier;
--     end
--     return h;
-- end

--[[ =========================================================================
	function RewardGenerator:Execute()
    apply primary reward if this has not already been done by another context
    obtain and apply any applicable bonus reward(s)
    calculate and apply any applicable hostile reward after other rewards
    returns ShowSummary()
=========================================================================== ]]
-- function RewardGenerator:Execute() 
--     local tSummary = self:GrantReward();
--     table.insert(self.Summary, tSummary);
--     if self.Player:IsHuman() then 
--         Game.AddWorldViewText(self.PlayerID, self.Description, self.X, self.Y, 0);
--     end
--     if not (self.IsBarbCamp and self.IsSumeria) then 
--         RemoveGoodyHutPlot(self.X, self.Y);
--         if not self.Hostile then 
--             local iCumulativeHostileModifier = (g_iBonusRewardsPerGoodyHut > 0) and self:GetBonusRewards(g_iBonusRewardsPerGoodyHut) or self.RewardTier;
--             if iCumulativeHostileModifier > -1 and g_iHostilesAfterReward > 1 then 
--                 self:GetHostilityModifiers(iCumulativeHostileModifier);
--                 local sHostile = self:GetHostilityLevel();
--                 if GameInfo.GoodyHutSubTypes_EGHV[sHostile] then 
--                     self:RefreshRewardDetails(GameInfo.GoodyHutSubTypes_EGHV[sHostile]);
--                     tSummary = self:GrantReward();
--                     table.insert(self.Summary, tSummary);
--                 end
--             end
--         end
--     end
--     return self:ShowSummary();
-- end

--[[ =========================================================================
	function RewardGenerator:ShowSummary()
    prints to the log a summary of granted reward(s)
    creates an ingame notification containing a condensed summary of granted reward(s)
    returns true
=========================================================================== ]]
-- function RewardGenerator:ShowSummary() 
--     local sSource = self.IsGoodyHut and g_sGoodyHutName or g_sBarbCampName;
--     local sTitle = string.format("%s %s", g_tNotification.Reward.Title, sSource);
--     local sNotification = string.format("%s", g_tNotification.Reward.Message);
--     local iNumRewards = (#self.Rewards <= g_iTotalRewardsPerGoodyHut) and #self.Rewards or g_iTotalRewardsPerGoodyHut;
--     local sHostilesAppear = (#self.Rewards > g_iTotalRewardsPerGoodyHut) and "; the villagers reacted aggressively" or "";
--     if g_iLoggingLevel > 1 then 
--         print(string.format("%s and received %d %s%s", self.SummaryHeader, iNumRewards, SingularOrPlural(iNumRewards, "reward"), sHostilesAppear));
--     end
--     for i, v in ipairs(self.Rewards) do 
--         sNotification = string.format("%s[NEWLINE][%d] %s", sNotification, i, v[11]);
--         if g_iLoggingLevel > 2 then 
--             print(string.format("[%d/%d]: Roll %d/%d: [%d | %d | %s (%d)]: %d %s | %d %s", i, iNumRewards, v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8], v[9], v[10]));
--             if g_iLoggingLevel > 3 then 
--                 for _, s in ipairs(self.Summary[i]) do 
--                     print(string.format("[%s]: %s", s[1] and "+" or "-", s[2]));
--                 end
--             end
--         end
--     end
--     if self.Player:IsHuman() then NotificationManager.SendNotification(self.PlayerID, g_tNotification.Reward.TypeHash, sTitle, sNotification, self.X, self.Y); end
--     return true;
-- end

--[[ =========================================================================
	function RewardGenerator:GetRewards(n)
    generates and applies up to n reward(s)
    calculates and applies any applicable hostile reward after other rewards
    returns ShowSummary()
=========================================================================== ]]
-- function RewardGenerator:GetRewards(n) 
--     n = (type(n) == "number" and n > 0) and n or g_iTotalRewardsPerGoodyHut;    -- default to the total rewards game configuration option if n is invalid
--     n = self.IsBarbCamp and 1 or n;                                             -- reset n for that sneaky bastard Gilgamesh; no bonus rewards from a barbarian camp
--     local sFunc = "GetRewards():";
--     if self.IsGoodyHut then RemoveGoodyHutPlot(self.X, self.Y); end
--     if self.Player:IsHuman() then Game.AddWorldViewText(self.PlayerID, Locale.Lookup("LOC_GOODYHUT_EGHV_PLACEHOLDER_DESC"), self.X, self.Y, 0); end
--     local h = 0;
--     for i = 1, n do 
--         local bSuccess = self.IsExplore and self:GenerateReward() or self:GenerateReward(g_tValidRewards.Expansion, g_iExpansionRewardCount);
--         if not bSuccess then bSuccess = self:GenerateReward(g_tValidRewards.Fallback, g_iFallbackRewardCount); end
--         if not bSuccess then return false; end
--         local tSummary = {};
--         if self.Type == "GOODYHUT_SAILOR_WONDROUS" then tSummary = Sailor_WGH(self.PlayerID, self.UnitID, self.TypeHash, self.RewardHash);
--         else tSummary = self:GrantReward();
--         end
--         -- if self.Hostile then table.insert(tSummary, { false, string.format("%s Hostiles received as 'reward' %d of %d; skipping hostiles check after rewards", sFunc, i, n) }); end
--         table.insert(self.Summary, tSummary);
--         if self.Player:IsHuman() and not self.Experience and not self.UnitAbility then Game.AddWorldViewText(self.PlayerID, self.Description, self.X, self.Y, 0); end
--         if self.Hostile and n > 1 then 
--             table.insert(self.Summary[i], { false, string.format("%s Hostiles received as 'reward' %d of up to %d; skipping any potential additional rewards and post-reward hostiles check", sFunc, i, n) });
--             return self:ShowSummary();
--         end
--         h = h + self.RewardTier;
--     end
--     if g_iHostilesAfterReward > 1 and not self.IsBarbCamp then 
--         self:GetHostilityModifiers(h);
--         local sHostile = self:GetHostilityLevel();
--         if GameInfo.GoodyHutSubTypes_EGHV[sHostile] then 
--             self:RefreshRewardDetails(GameInfo.GoodyHutSubTypes_EGHV[sHostile]);
--             local tSummary = self:GrantReward();
--             table.insert(self.Summary, tSummary);
--             if self.Player:IsHuman() then Game.AddWorldViewText(self.PlayerID, self.Description, self.X, self.Y, 0); end
--         end
--     end
--     return self:ShowSummary();
-- end

--[[ =========================================================================
	function PlaceUnitInPlot(self, sUnit, iNumUnits, iPlayerID) 
	spawns one or more units belonging to target Player near plot (X, Y)
    when the number of units left to spawn exceeds the amount of valid spawn plots, remaining units are spawned in a random City belonging to target Player
    returns: 
        false when the provided Hostile field and the provided Unit field are both invalid, or 
        the result of PlaceUnitInCity() if it is called, or 
        true otherwise
	this should be added to a RewardGenerator object as soon as it is created
=========================================================================== ]]
-- function PlaceUnitInPlot(self, sUnit, iNumUnits, iPlayerID) 
--     local sFunc = "PlaceUnitInPlot():";
--     if not self.Hostile and not self.Unit then 
--         self.Summary[(#self.Summary + 1)] = string.format("[-]: %s Reward %s does not provide a unit; aborting", sFunc, self.Reward);
--         return false;
--     end
--     sUnit = (type(sUnit) == "string") and sUnit or self.UnitType and self.UnitType or GameInfo.UnitRewards[self.Era][self.UnitClass];
--     iPlayerID = (type(iPlayerID) == "number" and iPlayerID > -1 and iPlayerID < 64) and iPlayerID or self.PlayerID;
--     iNumUnits = (type(iNumUnits) == "number" and iNumUnits > 0) and iNumUnits or (iPlayerID == g_iBarbarianID) and 1 or (g_iBonusUnitOrPop == 7 or (g_iBonusUnitOrPop > 1 and RollDieWithSides(g_iBonusUnitOrPop) == 1)) and 2 or 1;
--     local sUnitName = Locale.Lookup(GameInfo.Units[sUnit].Name);
--     if iNumUnits > 1 and not self.Hostile then 
--         self.Summary[(#self.Summary + 1)] = string.format("[+]: %s Critical roll! An additional %s will be granted (%d total)", sFunc, sUnitName, iNumUnits);
--     end
--     local bIsNaval = (GameInfo.Units[sUnit].FormationClass == "FORMATION_CLASS_NAVAL");
--     local iRadius = (iPlayerID ~= g_iBarbarianID) and 1 or 3;
--     local tPlots = GetAdjacentPlotsInRadius(self.X, self.Y, iRadius);
--     local tLandUnitPlots, tWaterUnitPlots = GetValidUnitSpawnPlots(tPlots);
--     local tValidPlots = bIsNaval and tWaterUnitPlots or tLandUnitPlots;
--     local sDistance = string.format("within a %d plot radius of plot (x %d, y %d)", iRadius, self.X, self.Y);
--     if #tValidPlots < 1 then 
--         local sSummary = string.format("[-]: %s There are no valid plots %s in which a new %s may be created", sFunc, sDistance, sUnitName);
--         local bFallback = false;
--         if iPlayerID ~= g_iBarbarianID then 
--             self.Summary[(#self.Summary + 1)] = string.format("%s; attempting City placement instead . . .", sSummary);
--             self.PlaceUnitInCity = PlaceUnitInCity;
--             bFallback = self:PlaceUnitInCity(sUnit, iNumUnits, iPlayerID);
--         else 
--             self.Summary[(#self.Summary + 1)] = string.format("%s; doing nothing", sSummary);
--         end
--         return bFallback;
--     end
--     local sValidPlots = string.format("Identified %d valid %s %s", #tValidPlots, SingularOrPlural(#tValidPlots, "plot"), sDistance);
--     self.Summary[(#self.Summary + 1)] = string.format("[+]: %s %s in which a new %s may be created", sFunc, sValidPlots, sUnitName);
--     local iNumPlaced = 0;
--     for n = 1, iNumUnits do 
--         if #tValidPlots > 0 then 
--             local bUnitPlaced = false;
--             local tFailedPlots = {};
--             local pSpawnPlot;
--             bUnitPlaced, pSpawnPlot, tValidPlots, tFailedPlots = PlaceUnitInRandomPlot(tValidPlots, sUnit, iPlayerID);
--             local iAttempts = bUnitPlaced and #tFailedPlots + 1 or #tFailedPlots;
--             local sAttempts = string.format("%d %s", iAttempts, SingularOrPlural(iAttempts, "attempt"));
--             if bUnitPlaced then 
--                 iNumPlaced = iNumPlaced + 1;
--                 local sX, sY = pSpawnPlot:GetX(), pSpawnPlot:GetY();
--                 if iPlayerID == g_iBarbarianID then 
--                     local sI = pSpawnPlot:GetIndex();
--                     PlayersVisibility[self.PlayerID]:ChangeVisibilityCount(sI, 0);    -- mark this plot as explored by this Player
--                     if self.IsHuman then 
--                         local sHostileUnitMessage = string.format("%s %s %s", g_tNotification.Hostile.UnitMessage1, sUnitName, g_tNotification.Hostile.UnitMessage2);
--                         NotificationManager.SendNotification(self.PlayerID, g_tNotification.Hostile.UnitTypeHash, g_tNotification.Hostile.Title, sHostileUnitMessage, sX, sY);
--                     end
--                 end
--                 local sThisUnit = string.format("[%d/%d]: Successfully created 1 %s", n, iNumUnits, sUnitName);
--                 self.Summary[(#self.Summary + 1)] = string.format("[+]: %s %s in plot (x %d, y %d) under the control of Player %d (%s)", sFunc, sThisUnit, sX, sY, iPlayerID, sAttempts);
--             else 
--                 local sThisUnit = string.format("[%d/%d]: 'FAILED' to create 1 %s", n, iNumUnits, sUnitName);
--                 self.Summary[(#self.Summary + 1)] = string.format("[-]: %s %s under the control of Player %d in %s", sFunc, sThisUnit, iPlayerID, sAttempts);
--             end
--         else 
--             self.Summary[(#self.Summary + 1)] = string.format("[-]: %s [%d/%d]: There are no remaining valid plots %s in which a new %s may be created", sFunc, n, iNumUnits, sDistance, sUnitName);
--         end
--     end
--     local iNumRemaining = iNumUnits - iNumPlaced;
--     if iNumRemaining > 0 then 
--         local bFallback = false;
--         if iPlayerID ~= g_iBarbarianID then 
--             self.PlaceUnitInCity = PlaceUnitInCity;
--             bFallback = self:PlaceUnitInCity(sUnit, iNumRemaining, iPlayerID);
--         else 
--             self.Summary[(#self.Summary + 1)] = string.format("[-]: %s Unable to create %d %s %s under the control of Player %d", sFunc, iNumRemaining, sUnitName, SingularOrPlural(iNumRemaining, "unit"), iPlayerID);
--         end
--         return bFallback;
--     end
--     if #self.Summary < 1 then 
--         self.Summary[(#self.Summary + 1)] = string.format("[-]: %s Strange things are afoot at the Circle K", sFunc);
--         return false;
--     end
--     return true;
-- end

--[[ =========================================================================
	function PlaceUnitInCity(self)
	spawns one or more units belonging to target Player in a random City belonging to Player
    returns: 
        false when the provided Unit field is invalid, or 
        false when the provided Cities table is invalid or empty, or 
        true otherwise
	this should be added to a RewardGenerator object as soon as it is created
=========================================================================== ]]
-- function PlaceUnitInCity(self, sUnit, iNumUnits, iPlayerID) 
--     local sFunc = "PlaceUnitInCity():";
--     if not self.Unit then 
--         self.Summary[(#self.Summary + 1)] = string.format("[-]: %s Reward %s does not provide a unit; aborting", sFunc, self.Reward);
--         return false;
--     elseif not self.Cities or #self.Cities < 1 then 
--         self.Summary[(#self.Summary + 1)] = string.format("[-]: %s Invalid or empty Cities table; aborting", sFunc);
--         return false;
--     end
--     sUnit = (type(sUnit) == "string") and sUnit or self.UnitType and self.UnitType or GameInfo.UnitRewards[self.Era][self.UnitClass];
--     iPlayerID = (type(iPlayerID) == "number" and iPlayerID > -1 and iPlayerID < 63) and iPlayerID or self.PlayerID;
--     iNumUnits = (type(iNumUnits) == "number" and iNumUnits > 0) and iNumUnits or 1;
--     local sUnitName = Locale.Lookup(GameInfo.Units[sUnit].Name);
--     if sUnit == "UNIT_TRADER" then 
--         iNumUnits = (g_iBonusUnitOrPop == 7 or (g_iBonusUnitOrPop > 1 and RollDieWithSides(g_iBonusUnitOrPop) == 1)) and 2 or 1;
--         if iNumUnits > 1 then 
--             self.Summary[(#self.Summary + 1)] = string.format("[+]: %s Critical roll! An additional %s will be granted (%d total)", sFunc, sUnitName, iNumUnits);
--         end
--     end
--     local bIsNaval = (GameInfo.Units[sUnit].FormationClass == "FORMATION_CLASS_NAVAL");
--     for n = 1, iNumUnits do 
--         local iCity = (#self.Cities > 1) and RollDieWithSides(#self.Cities) or 1;
--         local pCity = self.Cities[iCity];
--         local sCityName = Locale.Lookup(pCity:GetName());
-- 	    local cX, cY = pCity:GetX(), pCity:GetY();
--         local bHasEncampment = pCity:GetDistricts():HasDistrict(g_iEncampmentIndex);
--         local bHasHarbor = pCity:GetDistricts():HasDistrict(g_iHarborIndex);
--         local sThisCity = string.format("Player %d's City of %s", iPlayerID, sCityName);
--         local sThisUnit = string.format("[%d/%d]:", n, iNumUnits);
--         if bHasHarbor and bIsNaval then 
--             local pHarbor = pCity:GetDistricts():GetDistrict(g_iHarborIndex);
--             local hX, hY = pHarbor:GetX(), pHarbor:GetY();
--             UnitManager.InitUnit(iPlayerID, sUnit, hX, hY);
--             self.Summary[(#self.Summary + 1)] = string.format("[+]: %s %s Successfully created 1 %s in the Harbor District of %s", sFunc, sThisUnit, sUnitName, sThisCity);
--         elseif bHasEncampment and GameInfo.Units[sUnit].FormationClass == "FORMATION_CLASS_LAND_COMBAT" then 
--             local pEncampment = pCity:GetDistricts():GetDistrict(g_iEncampmentIndex);
--             local eX, eY = pEncampment:GetX(), pEncampment:GetY();
--             UnitManager.InitUnit(iPlayerID, sUnit, eX, eY);
--             self.Summary[(#self.Summary + 1)] = string.format("[+]: %s %s Successfully created 1 %s in the Encampment District of %s", sFunc, sThisUnit, sUnitName, sThisCity);
--         else 
--             local sSummary;
--             if not bIsNaval then 
--                 UnitManager.InitUnit(iPlayerID, sUnit, cX, cY);
--                 self.Summary[(#self.Summary + 1)] = string.format("[+]: %s %s Successfully created 1 %s in the City Center District of %s", sFunc, sThisUnit, sUnitName, sThisCity);
--             else 
--                 self.Summary[(#self.Summary + 1)] = string.format("[-]: %s %s 'FAILED' to create 1 %s in %s", sFunc, sThisUnit, sUnitName, sThisCity);
--             end
--         end
--     end
--     if #self.Summary < 1 then 
--         self.Summary[(#self.Summary + 1)] = string.format("[-]: %s Strange things are afoot at the Circle K", sFunc);
--         return false;
--     end
--     return true;
-- end
