local menu = nil
local menuOpen = false
local menuBlocked = false

local menuKey = input.LookupBinding("+menu_context")
local menuButtonCode = input.GetKeyCode(menuKey)

local function PlayTaunt(categoryID, soundID)
    net.Start("SimpleTaunts/Play")
    net.WriteUInt(categoryID, 8)
    net.WriteUInt(soundID, 8)
    net.SendToServer()
end

local function CreateMenu()
    menu = DermaMenu()
    for categoryID, categoryData in ipairs(TAUNTS_TABLE) do

        local allowedSounds = {}
        for soundID, soundData in ipairs(categoryData["sounds"]) do
            local canUseTaunt = hook.Run("SimpleTaunts/CanUseTaunt", LocalPlayer(), categoryID, categoryData["category"], soundData)
            if canUseTaunt == nil or canUseTaunt then
                allowedSounds[soundID] = soundData
            end
        end

        if #allowedSounds > 0 then
            local submenu = menu:AddSubMenu(
                categoryData["category"],
                -- Category clicked
                function()
                    -- Menu auto hides
                    menuOpen = false
                    menuBlocked = true
                end
            )

            for soundID, soundData in pairs(allowedSounds) do
                submenu:AddOption(
                    soundData["name"],
                    -- Taunt clicked
                    function()
                        PlayTaunt(categoryID, soundID)
                        -- Menu auto hides
                        menuOpen = false
                        menuBlocked = true
                    end
                )
            end

            menu:AddSpacer()
        end
    end
end

local function OpenMenu()
    menu:Open()
    menuOpen = true
end

local function HideMenu()
    menu:Hide()
    menuOpen = false
end

hook.Add(
    "Think",
    "SimpleTaunts",
    function()
        if TAUNTS_TABLE == nil then
            return
        end

        if not IsValid(menu) then
            CreateMenu()
            HideMenu()
        end

        if input.IsButtonDown(menuButtonCode) and not LocalPlayer():IsTyping() then
            if not menuOpen and not menuBlocked then
                OpenMenu()
            end
        else
            menuBlocked = false
            if menuOpen then
                HideMenu()
            end
        end
    end
)

-- Invalidate menu on these events
hook.Add("PlayerSpawn", "SimpleTaunts_ClearCache_OnSpawn", function()
     HideMenu()
     menu = nil
end)

hook.Add("PlayerChangedTeam", "SimpleTaunts_ClearCache_OnTeamChange", function() 
    HideMenu()
    menu = nil
end)
