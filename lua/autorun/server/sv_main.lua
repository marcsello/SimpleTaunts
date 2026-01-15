util.AddNetworkString("SimpleTaunts/Play")

local function PlayTaunt(ply, categoryID, soundID)
    -- Check if the player is allowed to taunt at all
    local canTaunt = hook.Run("SimpleTaunts/CanTaunt", ply)
    if canTaunt ~= nil && not canTaunt then
        -- A hook prevented running
        return
    end

    -- Check if the player can use this specific taunt
    local category = TAUNTS_TABLE[categoryID]
    local sound = category["sounds"][soundID]

    local canUseTaunt = hook.Run("SimpleTaunts/CanUseTaunt", ply, categoryID, category["category"], sound)
    if canUseTaunt ~= nil && not canUseTaunt then
        -- The player can not use this taunt
        return
    end


    -- Check if player is not spectating
    if ply:GetObserverMode() ~= OBS_MODE_NONE then
        return
    end

    -- Check if player is alive
    if not ply:Alive() then
        ply:ChatPrint("You can not taunt while you are dead.")
        return
    end

    -- Check for cooldown
    if (ply.simpleTauntsCooldown ~= nil && ply.simpleTauntsCooldown >= UnPredictedCurTime()) then
        ply.simpleTauntsCooldown = ply.simpleTauntsCooldown + 1
        local secondsRemaining = math.Round(ply.simpleTauntsCooldown - UnPredictedCurTime())
        ply:ChatPrint("Please wait " .. secondsRemaining .. " seconds before taunting again.")
        return
    end
    ply.simpleTauntsCooldown = UnPredictedCurTime() + 5

    ply:ChatPrint("Playing " .. category["category"] .. " / " .. sound["name"])

    local soundPath = sound["sound"]
    ply:EmitSound(soundPath, 100)
end

net.Receive(
    "SimpleTaunts/Play",
    function(len, ply)
        local categoryID = net.ReadUInt(8)
        local soundID = net.ReadUInt(8)
        PlayTaunt(ply, categoryID, soundID)
    end
)

hook.Add(
    "ShowSpare1",
    "SimpleTaunts_random_taunt",
    function(ply)
        local categoryID = math.random(#TAUNTS_TABLE)
        local cat = TAUNTS_TABLE[categoryID]
        local soundID = math.random(#cat["sounds"])
        PlayTaunt(ply, categoryID, soundID)
        return false -- prevent Default handler
    end
)

print("SimpleTaunts loaded!")
