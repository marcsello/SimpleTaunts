util.AddNetworkString("SimpleTaunts/Play")
util.AddNetworkString("SimpleTaunts/Taunts")

local function SendTauntsToAll(tauntsTable)
    net.Start("SimpleTaunts/Taunts")
    net.WriteTable(tauntsTable)
    net.Broadcast()
end

local function SendTauntsToPlayer(ply, tauntsTable)
    net.Start("SimpleTaunts/Taunts")
    net.WriteTable(tauntsTable)
    net.Send(ply)
end

net.Receive(
    "SimpleTaunts/Play",
    function(len, ply)
        -- Check if player is not spectating
        if ply:GetObserverMode() ~= OBS_MODE_NONE then
            return
        end

        -- Check if player is alive
        if not ply:Alive() then
            return
        end

        local soundPath = net.ReadString()
        ply:EmitSound(soundPath, 100)
    end
)

hook.Add(
    "PlayerInitialSpawn",
    "SimpleTaunts_initial_spawn",
    function(ply)
        SendTauntsToPlayer(ply, TAUNTS_TABLE)
    end
)

hook.Add(
    "Initialize",
    "SimpleTaunts_init",
    function()
        SendTauntsToAll(TAUNTS_TABLE)
    end
)
