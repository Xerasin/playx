
include("playxlib.lua")

util.AddNetworkString("PlayXProvidersList")
-- Hardcoding ftw...
local defaultJWURL = "http://ohmyrocketworks.googlecode.com/svn/trunk/jwplayer/player.swf"
local defaultHostURL = "http://88.191.109.120:20080/host.html"
CreateConVar("playx_jw_youtube", "1", { FCVAR_ARCHIVE })
CreateConVar("playx_race_protection", "1", { FCVAR_ARCHIVE })
CreateConVar("playx_wire_input", "0", { FCVAR_ARCHIVE })
CreateConVar("playx_wire_input_delay", "2", { FCVAR_ARCHIVE })

PlayX = {}

include("playx/concmds.lua")

-- @return Whether the JW player is enabled
function PlayX.IsUsingJW()
    return defaultJWURL:Trim():gmatch("^https?://.+") and true or false
end

--- Gets the URL of the JW player.
-- @return
function PlayX.GetJWURL()
    return defaultJWURL:Trim()
end

--- Returns whether the JW player supports YouTube.
-- @return
function PlayX.JWPlayerSupportsYouTube()
    return GetConVar("playx_jw_youtube"):GetBool()
end

--- Gets the URL of the host file.
-- @return
function PlayX.GetHostURL()
    return defaultHostURL:Trim()
end

--- Returns whether a player is permitted to use the player. The
-- PlayXIsPermitted hook allows this function to be overridden.
-- @param ply Player
-- @param instance Instance to check against (may be nil)
-- @return
function PlayX.IsPermitted(ply, instance)
    local result = hook.Call("PlayXIsPermitted", GAMEMODE, ply, instance)

    if result ~= nil then
        return result
    else
        return ply:IsAdmin() or ply:IsSuperAdmin()
    end
end

--- Gets the player instance entity. When there are multiple instances out,
-- default behavior is to get the closest one to the player (if a player is
-- provided). If no player is provided, the behavior is undefined.
-- A hook named PlayXSelectInstance can be -- defined to return a specific
-- entity. This function may return nil. An error message can be returned
-- to indicate why an instance could not be found.
-- @param ply Player that can be passed to specify a user
-- @return Entity or nil
-- @return Error message (optional)
function PlayX.GetInstance(ply)
    -- First try the hook
    local result, err = hook.Call("PlayXSelectInstance", GAMEMODE, ply)
    if result ~= nil then return result, err end

    local instances = PlayX.GetInstances()
    if #instances <= 1 or not ply then return instances[1] end

    local plyPos = ply:GetPos()
    table.sort(instances, function(a, b)
        return a:GetPos():Distance(plyPos) < b:GetPos():Distance(plyPos)
    end)
    return instances[1]
end

--- Gets a list of instances.
-- @return List of entities
function PlayX.GetInstances()
    local classes = list.Get("PlayXScreenClasses")

    if #classes == 1 then
        return ents.FindByClass(classes[1])
    end

    -- Time to build a list
    local props = {}
    for _, cls in pairs(classes) do
        table.Add(props, ents.FindByClass(cls))
    end
    return props
end

--- Checks if a player instance exists in the game.
-- @return Whether a player exists
function PlayX.PlayerExists()
    return #PlayX.GetInstances() > 0
end

--- Gets a list of instances that a player has subscribed to.
-- @return List of entities
function PlayX.GetSubscribed(ply)
    local subscribed = {}
    for _, instance in pairs(PlayX.GetInstances()) do
        if instance:IsSubscribed(ply) then
            table.insert(subscribed, instance)
        end
    end
    return subscribed
end

--- Subscribe a user to only one instance. The user will be unsubscribed from
-- all other players. If the user is already only subscribed to the instance,
-- then nothing will happen.
-- @param ply Player
-- @param instance Instance to subscribe to
function PlayX.SubscribeOnly(ply, instance)
    local subscribed = PlayX.GetSubscribed(ply)
    local alreadySubscribed = false
    for _, ent in pairs(subscribed) do
        if ent == instance then
            alreadySubscribed = true
        else
            ent:Unsubscribe(ply)
        end
    end
    if not alreadySubscribed then
        instance:Subscribe(ply)
    end
end

--- Unsubscribes a user from all players.
-- @param ply Player
function PlayX.UnsubscribeAll(ply)
    for _, instance in pairs(PlayX.GetSubscribed(ply)) do
        instance:Unsubscribe(ply)
    end
end

--- Spawns the player at the location that a player is looking at. This
-- function will check whether there is already a player or not.
-- @param ply Player
-- @param model Model path
-- @param repeater Spawn repeater
-- @return Success, and error message
function PlayX.SpawnForPlayer(ply, model, repeater, proximity)
    if not util.IsValidModel(model) then
        return false, "The server doesn't have the selected model"
    end

    local cls = "gmod_playx" .. (repeater and "_repeater" or proximity and "_proximity" or "")
    local pos, ang = hook.Call("PlayXSpawnPlayX", GAMEMODE, ply, model, repeater, proximity)
    local ent

    -- No hook?
    if pos == nil or pos == true then
	    /*if pos ~= true and not repeater and PlayX.PlayerExists() then
	        return false, "There is already a PlayX player somewhere on the map"
	    end*/
	    
	    local tr = ply.GetEyeTraceNoCursor and ply:GetEyeTraceNoCursor() or
	        ply:GetEyeTrace()
	        
		ent = ents.Create(cls)
	    ent:SetModel(model)
	    
		local info = PlayXScreens[model:lower()]
	    
		if not info or not info.IsProjector or
		   not ((info.Up == 0 and info.Forward == 0) or
		        (info.Forward == 0 and info.Right == 0) or
		        (info.Right == 0 and info.Up == 0)) then
	        ent:SetAngles(Angle(0, (ply:GetPos() - tr.HitPos):Angle().y, 0))
		    ent:SetPos(tr.HitPos - ent:OBBCenter() +
		       ((ent:OBBMaxs().z - ent:OBBMins().z) + 10) * tr.HitNormal)
	        ent:DropToFloor()
	    else
	        local ang = Angle(0, 0, 0)
	        
	        if info.Forward > 0 then
	            ang = ang + Angle(180, 0, 180)
	        elseif info.Forward < 0 then
	            ang = ang + Angle(0, 0, 0)
	        elseif info.Right > 0 then
	            ang = ang + Angle(90, 0, 90)
	        elseif info.Right < 0 then
	            ang = ang + Angle(-90, 0, 90)
	        elseif info.Up > 0 then
	            ang = ang + Angle(-90, 0, 0)
	        elseif info.Up < 0 then
	            ang = ang + Angle(90, 0, 0)
	        end
	        
	        local tryDist = math.min(ply:GetPos():Distance(tr.HitPos), 4000)
	        local data = {}
	        data.start = tr.HitPos + tr.HitNormal * (ent:OBBMaxs() - ent:OBBMins()):Length()
	        data.endpos = tr.HitPos + tr.HitNormal * tryDist
	        data.filter = player.GetAll()
	        local dist = util.TraceLine(data).Fraction * tryDist -
	            (ent:OBBMaxs() - ent:OBBMins()):Length() / 2
	        
	        ent:SetAngles(ang + tr.HitNormal:Angle())
	        ent:SetPos(tr.HitPos - ent:OBBCenter() + dist * tr.HitNormal)
	    end
    -- Error?
    elseif pos == false then
        return false, ang
    -- Custom spawn location
    else
        ent = ents.Create("gmod_playx")
        ent:SetModel(model)
        ent:SetAngles(ang)
        ent:SetPos(pos)
    end

    ent:Spawn()
    ent:Activate()

    local phys = ent:GetPhysicsObject()
    if phys:IsValid() then
        phys:EnableMotion(false)
        phys:Sleep()
    end

    if ply.AddCleanup then
        ply:AddCleanup(cls, ent)

        undo.Create("#" .. cls)
        undo.AddEntity(ent)
        undo.SetPlayer(ply)
        undo.Finish()
    end
    if repeater then
		local src=ent:GetClosestInstance()
		if IsValid(src) then
			ent:SetSource(src)
		end
	end
    return true
end

--- Resolves a provider to a handler.
-- @param provider Name of provider, leave blank to auto-detect
-- @param uri URI to play
-- @param useJW True to allow the use of the JW player, false for otherwise, nil to default true
-- @return Provider name (detected) or nil
-- @return Result or error message
function PlayX.ResolveProvider(provider, uri, useJW)
    -- See if there is a hook for resolving providers
    local result = nil--hook.Call("PlayXResolveProvider", GAMEMODE, provider, uri, useJW)

    if result then
        return result
    end

    if provider ~= "" then -- Provider detected
        if not list.Get("PlayXProviders")[provider] then
            return nil, "Unknown provider specified"
        end

        local newURI = list.Get("PlayXProviders")[provider].Detect(uri)
        result = list.Get("PlayXProviders")[provider].GetPlayer(newURI and newURI or uri, useJW)

        if not result then
            return nil, "The provider did not recognize the media URI"
        end
    else -- Time to detect the provider
        for id, p in pairs(list.Get("PlayXProviders")) do
            local newURI = p.Detect(uri)

            if newURI then
                provider = id
                result = p.GetPlayer(newURI, useJW)
                break
            end
        end

        if not result then
            return nil, "No provider was auto-detected"
        end
    end

    return provider, result
end

--- Gets a provider by name.
-- @param id ID of provider
-- @return Provider function or nil
function PlayX.GetProvider(id)
    return list.Get("PlayXProviders")[id]
end

--- Send the PlayXEnd umsg to clients. You should not have much of a
-- a reason to call this method.
function PlayX.SendError(ply, err)
    umsg.Start("PlayXError", ply)
	umsg.String(err)
    umsg.End()
end

--- Attempt to detect the PlayX version and put it in PlayX.Version.
-- @hidden
function PlayX.DetectVersion()
    PlayX.Version = ""
end

--- Load the providers.
-- @hidden
function PlayX.LoadProviders()
	local p = {}
	p = file.Find("playx/providers/*.lua","LUA")
    for _, file in pairs(p) do
        local status, err = pcall(function() include("playx/providers/" .. file) end)
        if not status then
            ErrorNoHalt("Failed to load provider(s) in " .. file .. ": " .. err)
        end
    end
end

-- Must replicate vars and auto-subscribe
hook.Add("PlayerInitialSpawn", "PlayXPlayerInitialSpawn", function(ply)

    -- Send providers list.
	net.Start("PlayXProvidersList")
		net.WriteTable({
			List = list.Get("PlayXProvidersList"),
		})
	net.Send(ply)
    -- Tell the user the playing media in three seconds
    -- Tell the user the playing media in three seconds
    timer.Simple(5, function()
        if not IsValid(ply) then return end

        ply.PlayXReady = true

        for _, instance in pairs(PlayX.GetInstances()) do
            if instance:ShouldAutoSubscribe(ply) then
                instance:Subscribe(ply)
            end
        end
    end)
end)

-- Must remove subscriptions on disconnect.
hook.Add("PlayerDisconnected", "PlayXPlayerDisconnected", function(ply)
    for _, instance in pairs(PlayX.GetSubscribed(ply)) do
        instance:Unsubscribe(instance)
    end
end)

PlayX.LoadProviders()