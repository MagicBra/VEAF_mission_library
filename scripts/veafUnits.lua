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
veafUnits.Id = "UNITS - "

--- Version.
veafUnits.Version = "0.1.1"

--- If no unit is spawned in a cell, it will default to this width
veafUnits.DefaultCellWidth = 10

--- If no unit is spawned in a cell, it will default to this height
veafUnits.DefaultCellHeight = 10
    
-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Do not change anything below unless you know what you are doing!
-------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Utility methods
-------------------------------------------------------------------------------------------------------------------------------------------------------------

function veafUnits.logInfo(message)
    if message then
        veaf.logInfo(veafUnits.Id .. message)
    end
end

function veafUnits.logDebug(message)
    if message then
        veaf.logDebug(veafUnits.Id .. message)
    end
end

function veafUnits.logTrace(message)
    if message then
        veaf.logTrace(veafUnits.Id .. message)
    end
end

function veafUnits.debugGroup(group, cells)
    veafUnits.logTrace("")
    veafUnits.logTrace(" Group : " .. group.description)
    veafUnits.logTrace("")
    local nCols = group.disposition.w
    local nRows = group.disposition.h
    
    local line1 = "|    |" 
    local line2 = "|----|" 
    
    for nCol = 1, nCols do
        line1 = line1 .. "                ".. string.format("%02d", nCol) .."              |" 
        line2 = line2 .. "--------------------------------|"
    end
    veafUnits.logTrace(line1)
    veafUnits.logTrace(line2)

    local unitCounter = 1
    for nRow = 1, nRows do 
        local line1 = "|    |"
        local line2 = "| " .. string.format("%02d", nRow) .. " |"
        local line3 = "|    |"
        local line4 = "|----|"
        for nCol = 1, nCols do
            local cellNum = (nRow - 1) * nCols + nCol
            local cell = cells[cellNum]
            local left = "        "
            local top = "        "
            local right = "        "
            local bottom = "        "
            local center = "                "
            
            if cell then 
            
                local unit = cell.unit
                if unit then
                    local unitName = unit.typeName
                    if unitName:len() > 11 then
                        unitName = unitName:sub(1,11)
                    end
                    unitName = string.format("%02d", unitCounter) .. "-" .. unitName
                    local spaces = 14 - unitName:len()
                    for i=1, math.floor(spaces/2) do
                        unitName = " " .. unitName
                    end
                    for i=1, math.ceil(spaces/2) do
                        unitName = unitName .. " "
                    end
                    center = " " .. unitName .. " "
                    unitCounter = unitCounter + 1
                end

                left = string.format("%08d",math.floor(cell.left))
                top = string.format("%08d",math.floor(cell.top))
                right = string.format("%08d",math.floor(cell.right))
                bottom = string.format("%08d",math.floor(cell.bottom))
            end
            
            line1 = line1 .. "  " .. top .. "                      " .. "|"
            line2 = line2 .. "" .. left .. center .. right.. "|"
            line3 = line3 .. "                      "  .. bottom.. "  |"
            line4 = line4 .. "--------------------------------|"

        end
        veafUnits.logTrace(line1)
        veafUnits.logTrace(line2)
        veafUnits.logTrace(line3)
        veafUnits.logTrace(line4)
    end
end

function veafUnits.debugUnit(unit)
    if unit then 
        local airnaval = ""
        if unit.naval then
            airnaval = ", naval"
        elseif unit.air then
            airnaval = ", air"
        end
        
        veafUnits.logDebug("unit " .. unit.displayName .. ", dcsType=" .. unit.typeName .. airnaval)
    end
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

--{
--    aliases = {"infantry section", "infsec"},
--    group = {
--        disposition = { h= 5, w= 4},
--        units = {{"IFV BTR-80", cell=18},{"IFV BTR-80", cell=19},{"INF Soldier AK", number = {min=8, max=16}}, {"SA-18 Igla manpad", number = {min=0, max=2}}}
--        description = "Mechanized infantry section with APCs",
--        groupName = "Mechanized infantry section"
--    }
--},

--- searches the database for a group having this alias (case insensitive)
function veafUnits.findGroup(groupAlias)
    veafUnits.logTrace("veafUnits.findGroup(groupAlias=" .. groupAlias .. ")")

    -- find the desired group in the groups database
    local result = nil

    for _, g in pairs(veafUnits.GroupsDatabase) do
        for _, alias in pairs(g.aliases) do
            if alias:lower() == groupAlias:lower() then
                group = g.group
                result = {}
                result.disposition = {}
                result.disposition.h = group.disposition.h
                result.disposition.w = group.disposition.w
                result.description = group.description
                result.groupName = group.groupName
                result.units = {}
                local unitNumber = 1
                -- replace all units with a simplified structure made from the DCS unit metadata structure
                for i = 1, #group.units do
                    local unitType
                    local cell = nil
                    local number = 1
                    local u = group.units[i]
                    if type(u) == "string" then 
                        -- information was skipped using simplified syntax
                        unitType = u
                    else
                        unitType = u[1]
                        cell = u.cell
                        number = u.number
                    end
                    if not(number) then 
                      number = 1
                    end
                    if type(number) == "table" then 
                        -- create a random number of units
                        local min = number.min
                        local max = number.max
                        if not(min) then min = 1 end
                        if not(max) then max = 1 end
                        number = math.random(min, max)
                    end
                    for numUnit = 1, number do
                        local unit = veafUnits.findUnit(unitType)
                        if not(unit) then 
                            veafUnits.logInfo("cannot find unit [" .. unitType .. "] listed in group [" .. group.groupName .. "]")
                        else 
                            unit.cell = cell
                            result.units[unitNumber] = unit
                            unitNumber = unitNumber + 1
                        end
                    end
                end
                break
            end
        end
    end
    
    -- check group type (WARNING : unit types should not be mixed !)
    for _, unit in pairs(result.units) do
        if unit.naval then 
            result.naval = true
            break
        end
        if unit.air then
            result.air = true
            break
        end
    end
    
       
    return result
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
       
    if unit then
        unit = veafUnits.findDcsUnit(unit.unitType)
    else
        unit = veafUnits.findDcsUnit(unitAlias)
    end
    if not(unit) then 
        veafUnits.logInfo("cannot find unit [" .. unitAlias .. "]")
    else
        unit = veafUnits.makeUnitFromDcsStructure(unit, cell)
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
    result.air = (dcsUnit.desc.attributes.Air == true)
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

--- checks if position is correct for the unit type
function veafUnits.correctPositionForUnit(spawnPosition, unit)
    veafUnits.logDebug("correctPositionForUnit()")
    veafUnits.logTrace(string.format("correctPositionForUnit: spawnPosition  x=%.1f y=%.1f, z=%.1f", spawnPosition.x, spawnPosition.y, spawnPosition.z))
    local vec2 = { x = spawnPosition.x, y = spawnPosition.z }
    veafUnits.logTrace(string.format("correctPositionForUnit: vec2  x=%.1f y=%.1f", vec2.x, vec2.y))
    local landType = land.getSurfaceType(vec2)
    if landType == land.SurfaceType.WATER then
        veafUnits.logTrace("landType = WATER")
    else
        veafUnits.logTrace("landType = GROUND")
    end
    veafUnits.debugUnit(unit)
    if spawnPosition then
        if unit.air then -- if the unit is a plane or helicopter
            if spawnPosition.z <= 10 then -- if lower than 10m don't spawn unit
                spawnPosition = nil
            end
        elseif unit.naval then -- if the unit is a naval unit
            if landType ~= land.SurfaceType.WATER then -- don't spawn over anything but water
                spawnPosition = nil 
            else -- place the point on the surface
                spawnPosition = veaf.placePointOnLand(spawnPosition)
            end
        else 
            if landType == land.SurfaceType.WATER then -- don't spawn over water
                spawnPosition = nil 
            else -- place the point on the surface
                spawnPosition = veaf.placePointOnLand(spawnPosition)
            end
        end
    end
    return spawnPosition
end

--- Adds a placement point to every unit of the group, centering the whole group around the spawnPoint, and adding an optional spacing
function veafUnits.placeGroup(group, spawnPoint, spacing)
    
    if not(group.disposition) then 
        -- default disposition is a square
        local l = math.ceil(math.sqrt(#group.units))
        group.disposition = { h = l, w = l}
    end 

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

    local cells = {}
    local allCells = {}
    for cellNum = 1, nRows*nCols do
        allCells[cellNum] = cellNum
    end
        
    -- place fixed units in their designated cells
    for i = 1, #fixedUnits do 
        local unit = fixedUnits[i]
        cells[unit.cell] = {}
        cells[unit.cell].unit = unit
        
        -- remove this cell from the list of available cells
        for cellNum = 1, #allCells do
            if allCells[cellNum] == unit.cell then
                table.remove(allCells, cellNum)
                break
            end
        end
    end
    -- randomly place non-fixed units in the remaining cells
    for i = 1, #freeUnits do 
        local randomCellNum = allCells[math.random(1, #allCells)]
        local unit = freeUnits[i]
        unit.cell = randomCellNum
        cells[unit.cell] = {}
        cells[randomCellNum].unit = unit
        
        -- remove this cell from the list of available cells
        for cellNum = 1, #allCells do
            if allCells[cellNum] == unit.cell then
                table.remove(allCells, cellNum)
                break
            end
        end
    end
    
    -- compute the size of the cells, rows and columns
    local cols = {}
    local rows = {}
    for nRow = 1, nRows do 
        for nCol = 1, nCols do
            local cellNum = (nRow - 1) * nCols + nCol
            local cell = cells[cellNum]
            local colWidth = 0
            local rowHeight = 0
            if cols[nCol] then 
                colWidth = cols[nCol].width
            end
            if rows[nRow] then 
                rowHeight = rows[nRow].height
            end
            if cell then
                cell.width = veafUnits.DefaultCellWidth + spacing
                cell.height = veafUnits.DefaultCellHeight + spacing
                local unit = cell.unit
                if unit then
                    unit.cell = cellNum
                    if unit.width and unit.width > 0 then 
                        cell.width = unit.width + spacing
                    end
                    if unit.height and unit.height > 0 then 
                        cell.height = unit.height + spacing
                    end
                end

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
        cols[nCol].left = totalWidth + spawnPoint.z
        totalWidth = totalWidth + cols[nCol].width
        cols[nCol].right= totalWidth + spawnPoint.z
    end
    for nRow = 1, #rows do -- bottom -> up
        rows[#rows-nRow+1].top = totalHeight + spawnPoint.x
        totalHeight = totalHeight + rows[#rows-nRow+1].height
        rows[#rows-nRow+1].bottom = totalHeight + spawnPoint.x
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
            unit.spawnPoint.z = cell.center.x + math.random(-spacing/2, spacing/2)
            unit.spawnPoint.x = cell.center.y + math.random(-spacing/2, spacing/2)
            unit.spawnPoint.y = spawnPoint.y
        end
    end 
    
    return group, cells
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
            units = {"sa-9"},
            description = "SA-9 SAM site",
            groupName = "SA9"
        },
    },
    {
        aliases = {"sa13", "sa-13"},
        group = {
            units = {"sa-13"},
            description = "SA-13 SAM site",
            groupName = "SA13"
        }
    },
    {
        aliases = {"infantry section", "infsec"},
        group = {
            disposition = { h= 10, w= 4},
            units = {{"IFV BTR-80", cell=38},{"IFV BTR-80", cell=39},{"INF Soldier AK", number = {min=12, max=30}}, {"SA-18 Igla manpad", number = {min=0, max=2}}},
            description = "Mechanized infantry section with APCs",
            groupName = "Mechanized infantry section"
        }
    },
    {
        aliases = {"Tarawa"},
        group = {
            disposition = { h = 3, w = 3},
            units = {{"Tarawa", 2}, {"Perry", 7}, {"Perry", 9}, {"Molniya"}},
            description = "Tarawa battle group",
            groupName = "Tarawa",
        }
    }  
}