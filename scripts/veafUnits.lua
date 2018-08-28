-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VEAF groups and units database for DCS Workd
-- By zip (2018)
--
-- Features:
-- ---------
-- Contains all the units aliases and groups definitions used by the other VEAF scripts
--
-- Prerequisite:
-- ------------
-- * This script requires DCS 2.5.1 or higher
-- * It also requires the veaf.lua base script library (version 1.0 or higher)
-- * It also requires the dcsUnits.lua script library (version 1.0 or higher)
--
-- Load the script:
-- ----------------
-- 1.) Download the script and save it anywhere on your hard drive.
-- 2.) Open your mission in the mission editor.
-- 3.) Add a new trigger:
--     * TYPE   "4 MISSION START"
--     * ACTION "DO SCRIPT FILE"
--     * OPEN --> Browse to the location where you saved the script and click OK.
--
-------------------------------------------------------------------------------------------------------------------------------------------------------------

veafUnits = {}

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Global settings. Stores the root VEAF constants
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Identifier. All output in DCS.log will start with this.
veafUnits.Id = "UNITS - "

--- Version.
veafUnits.Version = "1.0.0"

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Do not change anything below unless you know what you are doing!
-------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Utility methods
-------------------------------------------------------------------------------------------------------------------------------------------------------------

function veafUnits.logInfo(message)
    veaf.logInfo(veafUnits.Id .. message)
end

function veafUnits.logDebug(message)
    veaf.logDebug(veafUnits.Id .. message)
end

function veafUnits.logTrace(message)
    veaf.logTrace(veafUnits.Id .. message)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Core methods
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- searches the DCS database for a unit having this type (case insensitive)
function veafUnits.findDcsUnit(unitType)
    veafUnits.logTrace("veafUnits.findDcsUnit(unitType=" .. unitType .. ")")

    -- find the desired unit in the DCS units database
    local unit = nil
    for type, u in pairs(veafUnits.DcsUnitsDatabase) do
        if unitType:lower() == type:lower() then
            unit = u
            break
        end
    end

    return unit
end

--- searches the database for a group having this alias (case insensitive)
function veafUnits.findGroup(groupAlias)
    veafUnits.logTrace("veafUnits.findGroup(groupAlias=" .. groupAlias .. ")")

    -- find the desired group in the groups database
    local group = nil

    for _, g in pairs(veafUnits.GroupsDatabase) do
        for _, alias in pairs(g.aliases) do
            if alias:lower() == groupAlias:lower() then
                group = g.group

                -- replace all units with a simplified structure made from the DCS unit metadata structure
                for i = 1, #group.units do
                    local unitType = group.units[i]
                    local unit = veafUnits.findUnit(unitType)
                    if unit then
                        unit = veafUnits.findDcsUnit(unit.unitType)
                    else
                        unit = veafUnits.findDcsUnit(unitType)
                    end
                    if not(unit) then 
                        veafUnits.logInfo("cannot find unit [" .. unitType .. "] listed in group [" .. group.groupName .. "]")
                    end
                    group.units[i] = veafUnits.makeUnitFromDcsStructure(unit)
                end
                break
            end
        end
    end
       
    return group
end

--- searches the database for a unit having this alias (case insensitive)
function veafUnits.findUnit(unitAlias)
    veafUnits.logTrace("veafUnits.findUnit(unitAlias=" .. unitAlias .. ")")
    
    -- find the desired unit in the units database
    local unit = nil

    for _, u in pairs(veafUnits.UnitsDatabase) do
        for _, alias in pairs(u.aliases) do
            if alias:lower() == unitAlias:lower() then
                unit = u
                break
            end
        end
    end
       
    return unit
end

--- Creates a simple structure from DCS complex metadata structure
function veafUnits.makeUnitFromDcsStructure(dcsUnit)
    local result = {}
    if not(dcsUnit) then 
        return nil 
    end

    result.typeName = dcsUnit.desc.typeName
    result.displayName = dcsUnit.desc.displayName
    result.naval = (dcsUnit.desc.attributes.Ships == true)
    result.size = { x = dcsUnit.desc.box.max.x - dcsUnit.desc.box.min.x, y = dcsUnit.desc.box.max.y - dcsUnit.desc.box.min.y, z = dcsUnit.desc.box.max.z - dcsUnit.desc.box.min.z}

    return result
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Units databases
-------------------------------------------------------------------------------------------------------------------------------------------------------------

veafUnits.UnitsDatabase = {
    {
        aliases = {"sa9", "sa-9"},
        unitType = "Strela-1 9P31"
    },
    {
        aliases = {"sa13", "sa-13"},
        unitType = "Strela-10M3",
    },
    {
        aliases = {"tarawa"},
        unitType = "LHA_Tarawa",
    }
}

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Groups databases
-------------------------------------------------------------------------------------------------------------------------------------------------------------

veafUnits.GroupsDatabase = {
    {
        aliases = {"sa9", "sa-9"},
        group = {
            units = {"Strela-1 9P31"},
            description = "SA9 SAM site",
            groupName = "SA9"
        },
    },
    {
        aliases = {"sa13", "sa-13"},
        group = {
            units = {"Strela-10M3"},
            description = "SA13 SAM site",
            groupName = "SA13"
        }
    },
    {
        aliases = {"Tarawa"},
        group = {
            units = {"tarawa", "PERRY", "PERRY"},
            description = "Tarawa battle group",
            groupName = "Tarawa",
        }
    }
}