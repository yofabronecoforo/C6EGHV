--[[ =========================================================================
	C6GUE : Gameplay and Usability Enhancements for Civilization VI
	Copyright (C) 2020-2023 zzragnar0kzz
	All rights reserved
=========================================================================== ]]

--[[ =========================================================================
	begin EGHV component script EGHV_Utilities.lua
=========================================================================== ]]
if g_iLoggingLevel > 1 then print("Loading component script EGHV_Utilities.lua . . ."); end

--[[ =========================================================================
	utility function spairs(t, order) 
    indexes the keys of table t and sorts them
    iterates t in the sorted order of its keys
    optional parameter order is a function that specifies a sorting order
    https://stackoverflow.com/questions/15706270/sort-a-table-in-lua
=========================================================================== ]]
function spairs(t, order)
    -- collect the keys of t
    local keys = {};
    for k in pairs(t) do keys[(#keys + 1)] = k; end

    -- if order is not nil, sort keys by passing it and keys a, b,
    -- otherwise sort keys in the default order
    if order then
        table.sort(keys, function(a, b) return order(t, a, b); end);
    else
        table.sort(keys);
    end

    -- return the iterator function
    local i = 0;
    return function()
        i = i + 1;
        if keys[i] then
            return keys[i], t[keys[i]];
        end
    end
end

--[[ =========================================================================
	utility function dedup(t) 
    parses table t and removes any duplicate values
    returns table t containing only unique values
=========================================================================== ]]
function dedup(t) 
    local s = {};
    for i, v in ipairs(t) do 
        if s[v] then table.remove(t, i);
        else s[v] = true;
        end
    end
    return t;
end

--[[ =========================================================================
	utility function GetGoodyHutPlots() 
	creates and returns a table containing all plots with goody huts
=========================================================================== ]]
function GetGoodyHutPlots() 
	local t = {};
	local tContinents = Map.GetContinentsInUse();
	for _, c in ipairs(tContinents) do 
		local tPlots = Map.GetContinentPlots(c);
		for i, v in ipairs(tPlots) do 
			local pPlot = Map.GetPlotByIndex(v);
            if (pPlot:GetImprovementType() == g_iGoodyHutIndex) then table.insert(t, pPlot); end
		end
	end
	return t;
end

--[[ =========================================================================
	utility function RemoveGoodyHutPlot(iX, iY) 
	if present, removes plot (x iX, y iY) from the global goody huts table
=========================================================================== ]]
function RemoveGoodyHutPlot(iX, iY) 
    local pThisPlot = Map.GetPlot(iX, iY);
    for i, pPlot in ipairs(g_tGoodyHutPlots) do 
        if (pPlot == pThisPlot) then 
            table.remove(g_tGoodyHutPlots, i);
            break;
        end
    end
    -- print(string.format("%d %s remaining on selected map", #g_tGoodyHutPlots, SingularOrPlural(#g_tGoodyHutPlots, "Tribal Village")));
    -- return;
    return string.format("%d remaining", #g_tGoodyHutPlots);
end

--[[ =========================================================================
	utility function GetAdjacentPlotsInRadius(iX, iY, r, e) 
	identifies all plots adjacent to target plot (x iX, y iY) in radius r
    excludes target plot, and all plots in optional radius e when e > 0 and e < r
    each valid identified plot is checked to ensure that 
        (1) the plot is not impassable, and
        (2) the plot does not contain a Natural Wonder, and 
        (3) the plot does not contain a mountain, and
        (4) the plot does not contain a lake, and
        (5) there are zero units currently in the plot, and
        (6) the plot has no owner, and 
        (7) the plot contains no improvements, and 
        (8) the plot contains no resources
    returns a table containing plots that meet the above criteria, or an empty table when e >= r
=========================================================================== ]]
function GetAdjacentPlotsInRadius(iX, iY, r, e) 
    r = (type(r) == "number" and r >= 2) and r or 1;
    e = (type(e) == "number" and e >= 1) and e or 0;
    if e >= r then return {}; end
    local pThisPlot = Map.GetPlot(iX, iY);
    local exclude, plots = {}, {};
    if e > 0 then 
        for eX = (e * -1), e do 
            for eY = (e * -1), e do 
                local pPlot = Map.GetPlotXYWithRangeCheck(iX, iY, eX, eY, e);
                if pPlot and pPlot ~= pThisPlot then 
                    exclude[pPlot] = true;
                end
            end
        end
    end
    for dX = (r * -1), r do 
        for dY = (r * -1), r do 
            local pPlot = Map.GetPlotXYWithRangeCheck(iX, iY, dX, dY, r);
            if pPlot and pPlot ~= pThisPlot and not exclude[pPlot] and not pPlot:IsImpassable() and not pPlot:IsNaturalWonder() and not pPlot:IsMountain() and not pPlot:IsLake() then 
                -- if #Units.GetUnitsInPlot(pPlot) == 0 and pPlot:GetOwner() == -1 and pPlot:GetImprovementType() == -1 and pPlot:GetResourceType() == -1 then 
                    table.insert(plots, pPlot);
                -- end
            end
        end
    end
    -- print(string.format("Identified %d valid %s within %d %s of plot (x %d, y %d)", #plots, SingularOrPlural(#plots, "plot"), r, SingularOrPlural(r, "plot"), iX, iY));
	return plots;
end

--[[ =========================================================================
	utility function GetResourceCountInPlots(t, i) 
    table t is indexed numerically, with plots as values
	parses t for plots containing resource with index i
    increments count by 1 for each plot that meets the above criteria
    returns count
=========================================================================== ]]
function GetResourceCountInPlots(t, i) 
    local count = 0;
    for _, pPlot in ipairs(t) do 
        if pPlot:GetResourceType() == i then count = count + 1; end
    end
    return count;
end

--[[ =========================================================================
	utility function GetValidPlotsForImprovement(t, i) 
    table t is indexed numerically, with plots as values
    parses t for plots that are valid locations for improvement with index i
	returns a table containing plots that meet the above criteria
=========================================================================== ]]
function GetValidPlotsForImprovement(t, i) 
    local res = {};
    for _, pPlot in ipairs(t) do 
        -- if ImprovementBuilder.CanHaveImprovement(pPlot, i, -1) then table.insert(res, pPlot); end
        if #Units.GetUnitsInPlot(pPlot) == 0 and pPlot:GetOwner() == -1 and pPlot:GetImprovementType() == -1 and pPlot:GetResourceType() == -1 and ImprovementBuilder.CanHaveImprovement(pPlot, i, -1) then 
            table.insert(res, pPlot); 
        end
    end
    return res;
end

--[[ =========================================================================
	utility function GetValidUnitSpawnPlots(t) 
    table t is indexed numerically, with plots as values
    parses t for plots that are valid spawn locations for land and water units
	returns two tables containing plots that meet the following criteria:
        (1) table land contains any plots that are not water plots, and
        (2) table water contains any plots that are water plots
=========================================================================== ]]
function GetValidUnitSpawnPlots(t) 
    local land, water = {}, {};
    for _, pPlot in ipairs(t) do 
        -- if #Units.GetUnitsInPlot(pPlot) == 0 and pPlot:GetOwner() == -1 and pPlot:GetImprovementType() == -1 then 
        if #Units.GetUnitsInPlot(pPlot) == 0 and pPlot:GetImprovementType() == -1 then 
            if not pPlot:IsWater() then table.insert(land, pPlot);
            elseif pPlot:IsWater() then table.insert(water, pPlot);
            end
        end
    end
    return land, water;
end

--[[ =========================================================================
	utility function PlaceImprovementInRandomPlot(t, imp) 
    table t is indexed numerically, with plots as values
    attempts to place Improvement with index imp in a random plot from t
    returns: false, nil, and two empty tables when t is not a table or is empty or imp is not a valid improvement index, or
        (1) boolean b: true when improvement is successfully placed, false otherwise, and
        (2) object plot: the last plot fetched from t when t is not empty, nil otherwise, and
        (3) table t: the remaining contents of this table, and
        (4) table f: the plots where attempts to place the improvement failed
=========================================================================== ]]
function PlaceImprovementInRandomPlot(t, imp) 
    if type(t) ~= "table" or #t < 1 or type(imp) ~= "number" or not GameInfo.Improvements[imp] then return false, nil, {}, {}; end
    local b = false;
    local f = {};
    local p = (imp == g_iBarbCampIndex) and g_iBarbarianID or -1;
    local plot;
    while not b and #t > 0 do 
        local i = RollDieWithSides(#t);
        plot = t[i];
        table.remove(t, i);
        ImprovementBuilder.SetImprovementType(plot, imp, p);
        if (plot:GetImprovementType() == imp) then 
            b = true;
        else 
            table.insert(f, plot);
        end
    end
    return b, plot, t, f;
end

--[[ =========================================================================
	utility function PlaceUnitInRandomPlot(t, unit, p) 
    table t is indexed numerically, with plots as values
    attempts to place Unit of type unit in a random plot from t under the control of Player p
    returns: false, nil, and two empty tables when t is not a table or is empty or unit is not a valid unit type or p is not a valid Player, or
        (1) boolean b: true when unit is successfully placed, false otherwise, and
        (2) object plot: the last plot fetched from t when t is not empty, nil otherwise, and
        (3) table t: the remaining contents of this table, and
        (4) table f: the plots where attempts to place unit failed
=========================================================================== ]]
function PlaceUnitInRandomPlot(t, unit, p) 
    if type(t) ~= "table" or #t < 1 or type(unit) ~= "string" or not GameInfo.Units[unit] or type(p) ~= "number" or p < 0 or p > 63 then return false, nil, {}, {}; end
    local b = false;
    local f = {};
    local plot;
    while not b and #t > 0 do 
        local i = RollDieWithSides(#t);
        plot = t[i];
        table.remove(t, i);
        local sX, sY = plot:GetX(), plot:GetY();
        UnitManager.InitUnit(p, unit, sX, sY);
        for _, pUnit in ipairs(Units.GetUnitsInPlot(plot)) do 
            if pUnit:GetOwner() == p and GameInfo.Units[pUnit:GetType()].UnitType == unit then 
                b = true;
                break;
            end
        end
        if not b then 
            table.insert(f, plot);
        end
    end
    return b, plot, t, f;
end

--[[ =========================================================================
	utility function SingularOrPlural(i, s) 
	returns string s when i equals 1, otherwise appends string "s" to string s and returns that
=========================================================================== ]]
function SingularOrPlural(i, s) 
    return (i == 1) and s or string.format("%ss", s);
end

--[[ =========================================================================
	utility function IsOrAre(i) 
	returns string "is a" when i equals 1, otherwise returns string "are"
=========================================================================== ]]
function IsOrAre(i) 
    return (i == 1) and "is a" or "are"; 
end

--[[ =========================================================================
	utility function FlipCoin(r) 
	returns 1 or 2 to simulate a coin flip
=========================================================================== ]]
function FlipCoin(r) 
    r = type(r) == "number" and r or 100;
    return ((Game.GetRandNum(r, "Coin flip") + 1) % 2) + 1;        -- (TerrainBuilder.GetRandomNumber(r, "Coin flip") + 1) % 2;
end

--[[ =========================================================================
	utility function RollDieWithSides(s) 
    returns a random value between 1 and s, inclusive, to simulate the roll of a die with s sides
=========================================================================== ]]
function RollDieWithSides(s) 
    s = type(s) == "number" and s or 100;
    return ((Game.GetRandNum((s * 100), string.format("D%s roll", s)) + 1) % s) + 1;
end

--[[ =========================================================================
    end EGHV component script EGHV_Utilities.lua
=========================================================================== ]]
