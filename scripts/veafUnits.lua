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
-- * This script requires DCS 2.5.1 or higher and MIST 4.3.74 or higher.
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
--     * OPEN --> Browse to the location of MIST and click OK.
--     * ACTION "DO SCRIPT FILE"
--     * OPEN --> Browse to the location of veaf.lua and click OK.
--     * ACTION "DO SCRIPT FILE"
--     * OPEN --> Browse to the location of dcsUnits.lua and click OK.
--     * ACTION "DO SCRIPT FILE"
--     * OPEN --> Browse to the location where you saved the script and click OK.
--
-------------------------------------------------------------------------------------------------------------------------------------------------------------

veafUnits = {}

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Global settings. Stores the root VEAF constants
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Identifier. All output in DCS.log will start with this.
veafUnits.Id = "VEAFUNITS - "

--- Version.
veafUnits.Version = "0.1.1"

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
    for type, u in pairs(dcsUnits.DcsUnitsDatabase) do
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
                    local u = group.units[i]
                    local unitType = u[1]
                    local cell = u[2]
                    local unit = veafUnits.findUnit(unitType)
                    if unit then
                        unit = veafUnits.findDcsUnit(unit.unitType)
                    else
                        unit = veafUnits.findDcsUnit(unitType)
                    end
                    if not(unit) then 
                        veafUnits.logInfo("cannot find unit [" .. unitType .. "] listed in group [" .. group.groupName .. "]")
                    end
                    group.units[i] = veafUnits.makeUnitFromDcsStructure(unit, cell)
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
function veafUnits.makeUnitFromDcsStructure(dcsUnit, cell)
    local result = {}
    if not(dcsUnit) then 
        return nil 
    end

    result.typeName = dcsUnit.desc.typeName
    result.displayName = dcsUnit.desc.displayName
    result.naval = (dcsUnit.desc.attributes.Ships == true)
    result.size = { x = dcsUnit.desc.box.max.x - dcsUnit.desc.box.min.x, y = dcsUnit.desc.box.max.y - dcsUnit.desc.box.min.y, z = dcsUnit.desc.box.max.z - dcsUnit.desc.box.min.z}
    result.width = result.size.x
    result.height= result.size.y -- TODO check if this is correct ; may as well be z !
    -- invert if width > height
    if result.width > result.height then
        local width = result.width
        result.width = result.height
        result.height = width
    end
    result.cell = cell

    return result
end

--- Adds a placement point to every unit of the group, centering the whole group around the spawnPoint, and adding an optional spacing
function placeUnitsOfGroup(spawnPoint, group, spacing)
-- {
--     aliases = {"Tarawa"},
--     group = {
--         disposition = { h = 3, w = 3},
--         units = {{"tarawa", 2}, {"PERRY", 7}, {"PERRY", 9}},
--         description = "Tarawa battle group",
--         groupName = "Tarawa",
--     }
-- }

    local defaultWidth = 10
    local defaultHeight = 10
    local nRows = group.disposition.h
    local nCols = group.disposition.w

    -- sort the units by occupied cell
    local fixedUnits = {}
    local freeUnits = {}
    for _, unit in pairs(group.units) do
        if unit.cell then
            table.insert(fixedUnits, unit)
        else
            table.insert(freeUnits, unit)
        end
    end

    -- place units in the cells, adding the spacing
    local cells = {}
    for cellNum = 1, nRows*nCols do
        -- place units in the cells
        local foundUnit = nil
        -- browse the fixed units, searching for one that wants to go in this cell
        for u = 1, #fixedUnits do
            local unit = fixedUnits[u]
            if unit.cell == cellNum then
                -- found a fixed unit, set it
                foundUnit = unit
                table.remove(fixedUnits, u)
                break
            end
        end
        if not(foundUnit) then
            -- place one of the free units
            foundUnit = freeUnits[1]
            table.remove(freeUnits, 1)
        end
        
        if foundUnit then
            -- place the found unit
            cells[cellNum] = {}
            cells[cellNum].unit = foundUnit
            if foundUnit.width and foundUnit.width > 0 then 
                cells[cellNum].width = foundUnit.width + spacing
            else
                cells[cellNum].width = defaultWidth + spacing
            end
            if foundUnit.height and foundUnit.height > 0 then 
                cells[cellNum].height = foundUnit.height + spacing
            else
                cells[cellNum].height = defaultHeight + spacing
            end
        end
    end

    -- compute the size of the rows and columns
    local cols = {}
    local rows = {}
    for nRow = 1, nRows do 
        for nCol = 1, nCols do
            local cellNum = (nRow - 1) * nCols + nCol
            local cell = cells[cellNum]
            local colWidth = defaultWidth
            local rowHeight = defaultHeight
            if cols[nCol] then 
                colWidth = cols[nCol].width
            end
            if rows[nRow] then 
                rowHeight = rows[nRow].height
            end
            if cell then
                if cell.width > colWidth then
                    colWidth = cell.width
                end
                if cell.height > rowHeight then
                    rowHeight = cell.height
                end
            end
            cols[nCol] = {}
            cols[nCol].width = colWidth
            rows[nRow] = {}
            rows[nRow].height = rowHeight
        end
    end

    -- compute the size of the grid
    local totalWidth = 0
    local totalHeight = 0
    for nCol = 1, #cols do
        cols[nCol].left = totalWidth
        totalWidth = totalWidth + cols[nCol].width
        cols[nCol].right= totalWidth
    end
    for nRow = 1, #rows do
        rows[nRow].top = totalHeight
        totalHeight = totalHeight + rows[nRow].height
        rows[nRow].bottom = totalHeight
    end
    
    -- compute the centers and extents of the cells
    for nRow = 1, nRows do 
        for nCol = 1, nCols do
            local cellNum = (nRow - 1) * nCols + nCol
            local cell = cells[cellNum]
            if cell then
                cell.top = rows[nRow].top
                cell.bottom = rows[nRow].bottom
                cell.left = cols[nCol].left
                cell.right = cols[nCol].right
                cell.center = {}
                cell.center.x = cell.left + (cell.right - cell.left) / 2
                cell.center.y = cell.top + (cell.bottom - cell.top) / 2
            end            
        end
    end
    
    -- randomly place the units
    for _, cell in pairs(cells) do
        local unit = cell.unit
        if unit then
            unit.spawnPoint = {}
            unit.spawnPoint.x = cell.center.x + math.random(-spacing/2, spacing/2)
            unit.spawnPoint.y = cell.center.y + math.random(-spacing/2, spacing/2)
        end
    end

   
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

--- Syntax :
------------
-- 
--  aliases     = list of aliases which can be used to designate this group, case insensitive
--  layout      = height and width (in cells) of the group layout template (see picture unitSpawnGridExplanation-01)
--  units       = list of all the units composing the group. Each unit in the list is composed of :
--          alias   = alias of the unit in the VEAF units database, or actual DCS type name in the DCS units database
--          cell    = preferred layout cell ; the unit will be spawned in this cell, in the layout defined in the *layout* field
--                    (see pictures unitSpawnGridExplanation-02 and unitSpawnGridExplanation-03)
--  description = human-friendly name for the group
--  groupName   = name used when spawning this group (will be flavored with a numerical suffix)

veafUnits.GroupsDatabase = {
    {
        aliases = {"sa9", "sa-9"},
        group = {
            units = {{"sa-9",}},
            description = "SA-9 SAM site",
            groupName = "SA9"
        },
    },
    {
        aliases = {"sa13", "sa-13"},
        group = {
            units = {{"sa-13",}},
            description = "SA-13 SAM site",
            groupName = "SA13"
        }
    },
    {
        aliases = {"Tarawa"},
        group = {
            disposition = { h = 3, w = 3},
            units = {{"tarawa", 2}, {"PERRY", 7}, {"PERRY", 9}, {"MOLNIYA"}},
            description = "Tarawa battle group",
            groupName = "Tarawa",
        }
    }
}