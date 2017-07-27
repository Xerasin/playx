
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

local function PlayXEntityDuplicator(ply, model, pos, ang)
   if not PlayX.IsPermitted(ply) then return nil end

    local ent = ents.Create("gmod_playx_proximity")
    ent:SetModel(model)
    ent:SetPos(pos)
    ent:SetAngles(ang)
    ent:Spawn()
    ent:Activate()

    -- Sandbox only
    if ply.AddCleanup then
        ply:AddCleanup("gmod_playx", ent)
    end

    return ent
end

function ENT:SpawnFunction(ply, tr)
    if hook.Call("PlayXSpawnFunction", GAMEMODE, ply, tr) == false then return end

    PlayX.SendSpawnDialog(ply,false,true)
end


duplicator.RegisterEntityClass("gmod_playx_proximity", PlayXEntityDuplicator, "Model", "Pos", "Ang")

