AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

--- Initialize the entity.
-- @hidden
function ENT:Initialize()
	self.Subscribers = {}
    if self.KVModel then
        self.Entity:SetModel(self.KVModel)
    end

    self.Entity:PhysicsInit(SOLID_VPHYSICS)
    self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
    self.Entity:SetSolid(SOLID_VPHYSICS)
    self.Entity:DrawShadow(false)

    self:SetUseType(SIMPLE_USE)
end

function ENT:SpawnFunction(ply, tr)
    if hook.Call("PlayXSpawnFunction", GAMEMODE, ply, tr) == false then return end

    PlayX.SendSpawnDialog(ply,true,false)
end


--- Set the PlayX entity to be the source. Pass nil or NULL to clear.
-- @param src Source
function ENT:SetSource(src)
    src = src or NULL
    self.dt.Source = src
end

--- Add a user to the source's subscription list. The user will start
-- seeing the media if something is already playing. If the player is already
-- subscribed, nothing will happen.
-- @param ply
-- @return False if the player was already subscribed
function ENT:Subscribe(ply)
	if(not ply or not ply:IsValid() or not ply:IsPlayer()) then return end
    local src = self:GetSource()
	if not IsValid(src) then return false end
	if(src:Subscribe(ply)) then
		self.Subscribers[ply] = true
		return true
	end
end

--- Remove the user from the source's subscription list. The media will stop
-- for the player. If the player was not subscribed, then nothing will happen.
-- @param ply
-- @return False if the player was not subscribed to begin with
function ENT:Unsubscribe(ply)
    if(not ply or not ply:IsValid() or not ply:IsPlayer()) then return end
    local src = self:GetSource()
	if not IsValid(src) then return false end
	if(src:Unsubscribe(ply)) then
		self.Subscribers[ply] = nil
		return true
	end
end

--- Returns true if the passed player has subscribed to this instance's source.
-- @return Boolean
function ENT:IsSubscribed(ply)
	local src = self:GetSource()
	if not IsValid(src) then return false end
    return src.Subscribers[ply] and true or false
end

--- Get the server-side set source entity. May return nil.
-- @return Source
function ENT:GetSource()
    return IsValid(self.dt.Source) and self.dt.Source or nil
end

--- Do nothing UpdateTransmitState (the entity doesn't need to
-- always be known by the client).
-- @hidden
function ENT:UpdateTransmitState()
end

--- Spawn function.
-- @hidden
function ENT:SpawnFunction(ply, tr)
    if hook.Call("PlayXRepeaterSpawnFunction", GAMEMODE, ply, tr) == false then return end

    PlayX.SendSpawnDialog(ply, true, false)
end

--- When the entity is used.
-- @hidden
function ENT:Use(activator, caller)
    hook.Call("PlayXRepeaterUse", GAMEMODE, self, activator, caller)
end

--- Removal function.
-- @hidden
function ENT:OnRemove()
	for k,_ in pairs(self.Subscribers) do
		self:Unsubscribe(k)
	end
end

--- Duplication function.
-- @hidden
local function PlayXRepeaterEntityDuplicator(ply, model, pos, ang)
    if not PlayX.IsPermitted(ply) then
        return nil
    end

    local ent = ents.Create("gmod_playx_repeater")
    ent:SetModel(model)
    ent:SetPos(pos)
    ent:SetAngles(ang)
    ent:Spawn()
    ent:Activate()

    if ply.AddCleanup then
        ply:AddCleanup("gmod_playx_repeater", ent)
    end

    return ent
end

duplicator.RegisterEntityClass("gmod_playx_repeater", PlayXRepeaterEntityDuplicator, "Model", "Pos", "Ang")