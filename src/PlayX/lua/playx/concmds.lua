
function PlayX.SendSpawnDialog(ply, forRepeater, forProximity)
    if not ply or not ply:IsValid() then
        return
    elseif not PlayX.IsPermitted(ply) then
        PlayX.SendError(ply, "You do not have permission to use the player")
    else
        umsg.Start("PlayXSpawnDialog", ply)
			umsg.Bool(forRepeater or false)
			umsg.Bool(forProximity or false)
        umsg.End()
    end
end

--- Send the PlayXUpdateInfo umsg to a user.
function PlayX.SendUpdateInfo(ply, ver)
    umsg.Start("PlayXUpdateInfo", ply)
    umsg.String(ver)
    umsg.End()
end

--- Called for concmd playx_open.

local function ConCmdOpen_Queue(ply, cmd, args)
	if not ply or not ply:IsValid() then return end
	local instance, err = PlayX.GetInstance(ply)

	-- Is there a PlayX entity out?
	if not instance then
			PlayX.SendError(ply, err or "There is no player spawned! Go to the spawn menu > Entities")
	-- Is the user permitted to use the player?
	elseif not args[1] then
			ply:PrintMessage(HUD_PRINTCONSOLE, "playx_open requires a URI")
	else
			local uri = args[1]:Trim()
			
			local result, err = 
				PlayXQueue.QueueVideo(instance,ply,uri)
	end
end
		
		
local function ConCmdOpen(ply, cmd, args)
    if not ply or not ply:IsValid() then return end

    local instance, err = PlayX.GetInstance(ply)
	if(PlayXQueue ~= nil) then
		if(PlayXQueue.IsCinema~= nil and instance and instance:IsValid() and PlayXQueue.IsCinema(instance)) then
			ConCmdOpen_Queue(ply,cmd,args)
			return
		end
	end
    -- Is there a PlayX entity out?
    if not instance then
        PlayX.SendError(ply, err or "There is no player spawned! Go to the spawn menu > Entities")
    -- Is the user permitted to use the player?
    elseif not PlayX.IsPermitted(ply, instance) then
        PlayX.SendError(ply, "You do not have permission to use the player")
    -- Invalid arguments?
    elseif not args[1] then
        ply:PrintMessage(HUD_PRINTCONSOLE, "playx_open requires a URI")
    elseif instance:RaceProtectionTriggered() then
        PlayX.SendError(ply, "Someone started something too recently")
    else
        local uri = args[1]:Trim()
        local provider = playxlib.CastToString(args[2], ""):Trim()
        local start = playxlib.ParseTimeString(args[3])
        local forceLowFramerate = playxlib.CastToBool(args[4], false)
        local useJW = playxlib.CastToBool(args[5], true)

        if start == nil then
            PlayX.SendError(ply, "The time format you entered for \"Start At\" isn't understood")
        elseif start < 0 then
            PlayX.SendError(ply, "A non-negative start time is required")
        else
			provider = PlayX.ResolveProvider(provider,uri,false)
            if(provider~="SoundCloud") then
				local result, err = 
					instance:OpenMedia(provider, uri, start, forceLowFramerate, useJW)

				if not result then
					PlayX.SendError(ply, err)
				else
					hook.Call("PlayXConCmdOpened", GAMEMODE, instance, ply)
				end
			else
				local info = {}
				list.Get("PlayXProviders")["SoundCloud"].QueryMetadata(uri,function(tab)
					local result, err = instance:OpenMedia(provider,tab["URL"],start,forceLowFramerate,useJW)
					
					if not result then
						PlayX.SendError(ply, err)
					else
						hook.Call("PlayXConCmdOpened", GAMEMODE, instance, ply)
					end
				end)
			end
        end
    end
end

--- Called for concmd playx_close.
function ConCmdClose(ply, cmd, args)
    local instance, err = PlayX.GetInstance(ply)

	if not ply or not ply:IsValid() then
        return
    elseif not instance then
        PlayX.SendError(ply, err or "There is no player spawned!")
    elseif not PlayX.IsPermitted(ply, instance) then
        PlayX.SendError(ply, "You do not have permission to use the player")
    else
        instance:CloseMedia()
        hook.Call("PlayXConCmdClosed", GAMEMODE, instance, ply)
    end
end

--- Called for concmd playx_close.
function ConCmdCloseAll(ply, cmd, args)
    ply=IsValid(ply) or false -- Console

	for k,instance in pairs(PlayX.GetInstances()) do
		if not ply or PlayX.IsPermitted(ply, instance) then
			instance:CloseMedia()
			if ply then
				hook.Call("PlayXConCmdClosed", GAMEMODE, instance, ply)
			end
		end
	end

end

--- Called for concmd playx_spawn.
function ConCmdSpawn(ply, cmd, args)
    if not ply or not ply:IsValid() then
        return
    elseif not PlayX.IsPermitted(ply) then
        PlayX.SendError(ply, "You do not have permission to use the player")
    else
        if not args[1] or args[1]:Trim() == "" then
            PlayX.SendError(ply, "No model specified")
        else
            local model = args[1]:Trim()
            local result, err = PlayX.SpawnForPlayer(ply, model, cmd == "playx_spawn_repeater",cmd == 'playx_spawn_proximity')

            if not result then
                PlayX.SendError(ply, err)
            end
        end
    end
end


concommand.Add("playx_open", ConCmdOpen)
concommand.Add("playx_close", ConCmdClose)
concommand.Add("playx_closeall", ConCmdCloseAll)
concommand.Add("playx_spawn", ConCmdSpawn)
concommand.Add("playx_spawn_proximity", ConCmdSpawn)
concommand.Add("playx_spawn_repeater", ConCmdSpawn)