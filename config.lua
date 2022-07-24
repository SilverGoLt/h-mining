Config = {}

-- Random rock location generation BS
Config.Area = {
    minX = 663.00,
    maxX = 689.00,
    minY = 3102.00,
    maxY = 3132.00,
    z = 44
}

-- Ores that the player can get from washing rocks
-- Ores that the player can get from washing rocks
Config.Ores = {
    {
        item = 'uncut_diamond',
        chance = 10
    },
    {
        item = 'copper_ore',
        chance = 90
    },
    {
        item = 'iron_ore',
        chance = 70
    },
    {
        item = 'aliminium_ore',
        chance = 80
    },
    {
        item = 'gold_nugget',
        chance = 20
    }
}

Config.Refined = {
    {
        dirty = 'copper_ore',
        refined = 'copper_ingot',
        required = 2
    },
    {
        dirty = 'iron_ore',
        refined = 'iron_ingot',
        required = 2
    },
    {
        dirty = 'gold_nugget',
        refined = 'gold_bar',
        required = 10
    },
    {
        dirty = 'aliminium_ore',
        refined = 'aliminium_ingot',
        required = 2
    }
}

-- Gay ass the rock prop
Config.Rock = {
    prop = 'cs_x_rubweec'
}
