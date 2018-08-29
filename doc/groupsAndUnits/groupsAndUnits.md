# Units and groups 

## Units databases

### dcsUnits
The *dcsUnits.lua* script defines a database named *dcsUnits.DcsUnitsDatabase*, which lists all the units in the current DCS World universe. 

### veafUnits
The *veafUnits.lua* script provides a *veafUnits.UnitsDatabase* list containing aliases, referencing units in the *dcsUnits.DcsUnitsDatabase* list.  
It also defines functions that scan these databases for a specific unit.

## Groups definitions
In the *veafUnits.lua* script, we also define groups.

A group is a list of units that are used together to form a usable battle group.  
It has a layout template, used to make the group units spawn at the correct place.

###Syntax###

**Example of a group definition :**

```
{
    aliases = {"Tarawa"},
    group = {
        disposition = { h = 3, w = 3},
        units = {{"tarawa", 2}, {"PERRY", 7}, {"PERRY", 9}},
        description = "Tarawa battle group",
        groupName = "Tarawa",
    }
}
```

**Explanation of the fields :**

- aliases : list of aliases which can be used to designate this group, case insensitive
- layout : height and width (in cells) of the group layout template (see picture unitSpawnGridExplanation-01)
![unitSpawnGridExplanation-01](./unitSpawnGridExplanation-01.png?raw=true "unitSpawnGridExplanation-01")

- units : list of all the units composing the group. Each unit in the list is composed of :
    - alias : alias of the unit in the VEAF units database, or actual DCS type name in the DCS units database
    - cell : preferred layout cell ; the unit will be spawned in this cell, in the layout defined in the *layout* field. 
                      (see pictures unitSpawnGridExplanation-02 and unitSpawnGridExplanation-03)
- description = human-friendly name for the group
- groupName   = name used when spawning this group (will be flavored with a numerical suffix)
