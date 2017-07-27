ENT.Type = "anim"
ENT.Base = "gmod_playx"

ENT.PrintName = "PlayX Repeater"
ENT.Author = "sk89q"
ENT.Contact = "http://www.sk89q.com"
ENT.Purpose = "Repeater of a PlayX screen"
ENT.Instructions = "Spawn a regular PlayX screen first."
ENT.Category = "PlayX"
ENT.Spawnable = true
ENT.AdminSpawnable = true

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

list.Add("PlayXRepeaterClasses", "gmod_playx")

--- For DTVars.
-- @hidden
function ENT:SetupDataTables()
    self:DTVar("Entity", 0, "Source")
end

function ENT:GetClosestInstance()
    local instances = PlayX.GetInstances()
    if #instances <= 1 or not self then return instances[1] end

    local plyPos = self:GetPos()
    table.sort(instances, function(a, b)
        return a:GetPos():Distance(plyPos) < b:GetPos():Distance(plyPos)
    end)
    return instances[1]
end

cleanup.Register("gmod_playx_repeater")