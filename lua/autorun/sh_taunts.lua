if TAUNTS_TABLE == nil then
    -- If the autorun script ran before loading the addons, we shouldn't override the table then
    TAUNTS_TABLE = {}
end

-- Note: this must be called from shared environment so both client and server will be consistent
function RegisterTaunt(category, name, sound, meta)
    if TAUNTS_TABLE == nil then
        TAUNTS_TABLE = {}
    end

    local newItem = {
        ["sound"] = sound, -- The sound file itself
        ["name"] = name, -- Name of the sound that appears in the list
        ["meta"] = meta -- Meta is some optional extra data that can be used for decision making
    }

    -- Try to find existing category
    for i, cat in ipairs(TAUNTS_TABLE) do
        if cat["category"] == category then
            table.insert(cat["sounds"], newItem)
            return i, #cat["sounds"]
        end
    end

    -- Not found: create new category at end
    local newCat = { ["category"] = category, ["sounds"] = { newItem } }
    table.insert(TAUNTS_TABLE, newCat)
    return #TAUNTS_TABLE, 1
end
