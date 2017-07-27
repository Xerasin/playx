pcall(include, "autorun/translation.lua") local L = translation and translation.L or function(s) return s end
include("playxlib.lua")

local cvar_playx_enabled = CreateClientConVar("playx_enabled", 1, true, false)
--local cvar_playx_mute_nofocus = CreateClientConVar("playx_mute_nofocus", 1, true, false)
local snd_mute_losefocus = GetConVar"snd_mute_losefocus"
local cvar_playx_volume = CreateClientConVar("playx_volume", 80, true, false)
local cvar_playx_provider = CreateClientConVar("playx_provider", "", false, false)
local cvar_playx_uri = CreateClientConVar("playx_uri", "", false, false)
local cvar_playx_start_time = CreateClientConVar("playx_start_time", "0:00", false, false)
local cvar_playx_force_low_framerate = CreateClientConVar("playx_force_low_framerate", 0, false, false)
local cvar_playx_use_jw = CreateClientConVar("playx_use_jw", 1, false, false)
local cvar_playx_error_windows = CreateClientConVar("playx_error_windows", 1, true, false)
local cvar_playx_debug = CreateClientConVar("playx_debug", 0, true, false)

PlayX = {}

include("playx/client/bookmarks.lua")
include("playx/client/panel.lua")
include("playx/client/ui.lua")
include("playx/client/concmds.lua")
PlayX.Enabled = GetConVar("playx_enabled"):GetBool()
PlayX.JWPlayerURL = "http://playx.xeras.in/player.swf"
PlayX.HostURL = "http://playx.xeras.in/host.html" -- "http://sk89q.github.com/playx/host/host.html"
PlayX.ShowRadioHUD = true
PlayX.Providers = {}
PlayX.CrashDetectionWindows = {}
PlayX.CrashDetected = file.Read("_playx_crash_detection.txt") == "BEGIN"

surface.CreateFont("PlayXHUDNumber",
	{
		font = "Trebuchet MS",
		size = 40,
		weight = 900
	}
)

local nextSoundThink = 0

--- Prints debugging messages. The cvar playx_debug must be enabled for the
-- debug messages to show.
-- @param msg Message
-- @param ... Vars for sprintf
function PlayX.Debug(msg, ...)
    if GetConVar("playx_debug"):GetBool() then
        local args = {...}
        MsgN(string.format("PlayX DEBUG: " .. msg, unpack(args)))
    end
end

--- Gets the player instance entity. When there are multiple instances out,
-- the behavior is undefined. A hook named PlayXSelectInstance can be
-- defined to return a specific entity. This function may return nil.
-- @param ply Player that can be passed to specify a user
-- @return Entity or nil
function PlayX.GetInstance(ply)
    -- First try the hook
    local result = hook.Call("PlayXSelectInstance", GAMEMODE, ply)
    if result then return result end

    return PlayX.GetInstances()[1]
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

--- Checks whether a player is spawned.
-- @return
function PlayX.PlayerExists()
    return #PlayX.GetInstances() > 0
end

--- Returns counts of instances having media, having resumable media, and
-- are playing.
-- @return Number of players that have media
-- @return Number of players that are resumable
-- @return Number of players that are playing
function PlayX.GetCounts()
    local numHasMedia = 0
    local numResumable = 0
    local numPlaying = 0

    for _, instance in pairs(PlayX.GetInstances()) do
        if IsValid(instance) and instance.HasMedia and instance:HasMedia() then
            numHasMedia = numHasMedia + 1

            if instance:IsResumable() then
                numResumable = numResumable + 1
            end
        end

        if instance.IsPlaying then
            numPlaying = numPlaying + 1
        end
    end

    return numHasMedia, numResumable, numPlaying
end

--- Checks whether the host URL is valid.
-- @return Whether the host URL is valid
function PlayX.HasValidHostURL()
    return PlayX.HostURL:Trim():gmatch("^https?://.+") and true or false
end

--- Enables the player.
function PlayX.Enable()
    RunConsoleCommand("playx_enabled", "1")
end

--- Disables the player.
function PlayX.Disable()
    RunConsoleCommand("playx_enabled", "0")
end

--- Gets the overall volume. This is the overall volume of all players.
-- The value will be between 0 and 100.
-- @return


function PlayX.IsEngineMuted()
	if not snd_mute_losefocus:GetBool() then return end
	if PlayX.__engine_muted then return true end
end



function PlayX.EngineFocusChanged(focus)

	-- gained focus back
	if focus and PlayX.__engine_muted then
		PlayX.__engine_muted = false
		PlayX.VolumeChangeCallback()
		return
	end
	
	-- lost focus and should mute
	if not focus and snd_mute_losefocus:GetBool() then
		PlayX.__engine_muted = true
		PlayX.VolumeChangeCallback()
	end
end

-- focus callback
	local engine_focused = true
	timer.Simple(1,function()
			
		hook.Add("Think","playx_focuspoll",function()
			local focus=system.HasFocus()
			if engine_focused~=focus then
				engine_focused = focus
				PlayX.EngineFocusChanged(focus)
			end
		end )
			
	end)



function PlayX.GetVolume()
	local vol = PlayX.IsEngineMuted() and 0 or cvar_playx_volume:GetInt() or 100
	vol = vol>100 and 100 or vol<0 and 0 or vol
    return vol
end

--- Sets the overall volume. This is the overall volume of all players.
--  The value is between 0 and 100.
-- @return
function PlayX.SetVolume(vol)
    RunConsoleCommand("playx_volume", vol)
end

--- Gets a handler by name. May return nil if the handler doesn't exist.
-- @param handler Handler name
-- @return Handler function or nil
function PlayX.GetHandler(handler)
    return list.Get("PlayXHandlers")[handler]
end

--- Resume playing if it is not already playing.
function PlayX.ResumePlay()
    for _, instance in pairs(PlayX.GetInstances()) do
        if instance.Media and instance.Media.ResumeSupported then
            if instance.IsPlaying then
                instance:Stop()
            end
            instance:Play()
        end
    end

    PlayX.UpdatePanels()
end

--- Hides the player and stops it.
function PlayX.StopPlay()
    for _, instance in pairs(PlayX.GetInstances()) do
        if instance.Media then
            instance:Stop()
        end
    end

    PlayX.UpdatePanels()
end

--- Reset the render bounds of the project screen.
function PlayX.ResetRenderBounds()
    for _, instance in pairs(PlayX.GetInstances()) do
        instance:ResetRenderBounds()
    end
end

--- Load the handlers. This is already done on PlayX load.
-- @hidden
function PlayX.LoadHandlers()
    -- Load handlers
	local p = {}
	p = file.Find("playx/client/handlers/*.lua","LUA")
    for _, file in pairs(p) do
        local status, err = pcall(function() include("playx/client/handlers/" .. file) end)
        if not status then
            ErrorNoHalt("Failed to load handler(s) in " .. file .. ": " .. err)
        end
    end
end

--- Think hook that processes the sound multipliers.
local function ProcessSound()
    if RealTime() < nextSoundThink then return end

    for _, instance in pairs(PlayX.GetInstances()) do
        local mult = hook.Call("PlayXGetSoundMultiplier", GAMEMODE, instance)
        if mult then instance:SetVolume(mult) end
    end

    nextSoundThink = RealTime() + 0.05
end

--- Register the sound processor if there is a player otherwise deregister
-- it. The sound processor hook calculates the local sound multiplier.
-- @hidden
function PlayX.RegisterSoundProcessor()
    local hooks = hook.GetTable().PlayXGetSoundMultiplier

    if PlayX.PlayerExists() and hooks and table.Count(hooks) > 0 then
        hook.Add("Think", "PlayXSoundProcessor", ProcessSound)
    else
        hook.Remove("Think", "PlayXSoundProcessor")
    end
end

--- Starts the window of crash detection. Called right when something is being
-- played by the entity.
-- @param instance Instance
-- @hidden
function PlayX.CrashDetectionOpen(instance)
    -- First instance
    if table.Count(PlayX.CrashDetectionWindows) == 0 then
        file.Write("_playx_crash_detection.txt", "BEGIN")
    end

    PlayX.CrashDetectionWindows[instance] = true

    timer.Destroy("PlayXCrashDetection" .. instance:EntIndex())
    timer.Create("PlayXCrashDetection" .. instance:EntIndex(),
       8, 1, PlayX.CrashDetectionClose, instance)
end

--- Ends the window of crash detection. Called by the entity after it has been
-- stopped or after a timeout after something had started playing.
-- @param instance Instance
-- @hidden
function PlayX.CrashDetectionClose(instance)
    if not PlayX.CrashDetectionWindows[instance] then return end

    PlayX.CrashDetectionWindows[instance] = nil

    if IsValid(instance) then
	    timer.Destroy("PlayXCrashDetection" .. instance:EntIndex())
	end

    if table.Count(PlayX.CrashDetectionWindows) == 0 then
        file.Write("_playx_crash_detection.txt", "OK")
    end
end

--- Checks to see if a crash occurred last time and disables PlayX if so.
-- Will return true if PlayX was just disabled.
-- @return Boolean
-- @hidden
function PlayX.DetectCrash()
    if PlayX.CrashDetected and PlayX.Enabled then
        RunConsoleCommand("playx_enabled", "0")
        PlayX.Enabled = false
		chat.AddText(
		    Color(255, 255, 0, 255),
		    L("PlayX has disabled itself following a detection of a crash in a previous " ..
		    "session. Re-enable PlayX via your tool menu under the \"Options\" tab.")
		)
        return true
    end

    return false
end

cvars.AddChangeCallback("playx_enabled", function(cvar, old, new)
    PlayX.Enabled = GetConVar("playx_enabled"):GetBool()

    if PlayX.Enabled then
        if PlayX.CrashDetected then
	        file.Write("_playx_crash_detection.txt", "CLEAR")
	        PlayX.CrashDetected = false
	    end
	    
        PlayX.ResumePlay()
        hook.Call("PlayXEnabled", GAMEMODE)
    else
        PlayX.StopPlay()
        hook.Call("PlayXDisabled", GAMEMODE)
    end

    -- Panels will be updated already
end)

function PlayX.VolumeChangeCallback()
    for _, instance in pairs(PlayX.GetInstances()) do
        if IsValid(instance) and instance.SetVolume then
            instance:SetVolume()
        end
    end

    hook.Call("PlayXVolumeSet", GAMEMODE, vol)
end

cvars.AddChangeCallback("playx_volume", function(cvar, old, new)
    local volume = PlayX.GetVolume()

	PlayX.VolumeChangeCallback()
end)

net.Receive("PlayXBegin",function(len)
	local decoded = net.ReadTable()
	local instance = decoded.Entity
	local handler = decoded.Handler
	local uri = decoded.URI
	local playAge = decoded.PlayAge
	local resumeSupported = decoded.ResumeSupported
	local lowFramerate = decoded.LowFramerate
	local handlerArgs = decoded.HandlerArgs

	PlayX.Debug("PlayXBegin received for %s (handler %s)", tostring(instance), handler)

	if not IsValid(instance) then
		Error("PlayX: PlayXBegin referenced non-existent entity (did you call BeginMedia() too early?)")
	elseif not table.HasValue(list.Get("PlayXScreenClasses"), instance:GetClass()) then
		Error("PlayX: PlayXBegin referenced non-PlayX entity (did you call BeginMedia() too early?)")
	end

	instance:BeginMedia(handler, uri, playAge, resumeSupported, lowFramerate, handlerArgs)
end)

net.Receive("PlayXProvidersList",function(len)
	local decoded = net.ReadTable()
	local list = decoded.List

	PlayX.Debug("Got providers list")

	PlayX.Providers = {}

	for k, v in pairs(list) do
		PlayX.Providers[k] = v[1]
	end

	PlayX.UpdatePanels()
end)


usermessage.Hook("PlayXBegin", function(um)
    local instance = um:ReadEntity()
    local handler = um:ReadString()
    local uri = um:ReadString()
    local playAge = um:ReadLong()
    local resumeSupported = um:ReadBool()
    local lowFramerate = um:ReadBool()

    PlayX.Debug("PlayXBegin received for %s (handler %s)", tostring(instance), handler)

    if not IsValid(instance) then
        Error("PlayX: PlayXBegin referenced non-existent entity (did you call BeginMedia() too early?)")
    elseif not table.HasValue(list.Get("PlayXScreenClasses"), instance:GetClass()) then
        Error("PlayX: PlayXBegin referenced non-PlayX entity (did you call BeginMedia() too early?)")
    end

    instance:BeginMedia(handler, uri, playAge, resumeSupported, lowFramerate, {})
end)

usermessage.Hook("PlayXEnd", function(um)
    local instance = um:ReadEntity()

    PlayX.Debug("PlayXEnd received for %s", tostring(instance))

    if not IsValid(instance) then
        Error("PlayX: PlayXEnd referenced non-existent entity")
    elseif not table.HasValue(list.Get("PlayXScreenClasses"), instance:GetClass()) then
        Error("PlayX: PlayXEnd referenced non-PlayX entity")
    end

    instance:EndMedia()
end)

usermessage.Hook("PlayXSpawnDialog", function(um)
    PlayX.OpenSpawnDialog(um:ReadBool(),um:ReadBool())
end)



usermessage.Hook("PlayXError", function(um)
    local err = um:ReadString()
    PlayX.ShowError(err)
end)

usermessage.Hook("PlayXMetadataStd", function(um)
    local instance = um:ReadEntity()
    local title = um:ReadString()

    PlayX.Debug("Got PlayXMetadataStd umsg for %s", tostring(instance))

    -- We can just ignore the usermessage in this situation
    if not IsValid(instance) or not
        table.HasValue(list.Get("PlayXScreenClasses"), instance:GetClass()) then
        return
    end

    instance:UpdateMetadata({ Title = title })
end)

hook.Add("InitPostEntity", "PlayXCrashProtection", function()
    PlayX.DetectCrash()
end)

PlayX.LoadHandlers()