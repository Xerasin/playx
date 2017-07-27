pcall(include, "autorun/translation.lua") local L = translation and translation.L or function(s) return s end

PlayX.SeenNotice = false

local spawnWindow = nil

--- Shows a hint. This only works on sandbox gamemodes and gamemodes that
-- implement GAMEMODE.AddNotify. If AddNotify is not available, the
-- message will not be shown anywhere.
-- @param msg
function PlayX.ShowHint(msg)
    if GAMEMODE and GAMEMODE.AddNotify then
	    GAMEMODE:AddNotify(msg, NOTIFY_GENERIC, 10);
	    surface.PlaySound("ambient/water/drip" .. math.random(1, 4) .. ".wav")
	end
end

--- Show the first play notice. This will only show anything if
-- hints exist in the gameode.
function PlayX.ShowNotice()
    if PlayX.SeenNotice then return end

    PlayX.ShowHint(L"Want to stop what's playing? Go to the Q menu > Options > PlayX")
    PlayX.SeenNotice = true
end

--- Shows an error message. It will be shown in a popup if it is enabled
-- or if hints do not exist in this gamemode.
-- @param err
function PlayX.ShowError(err)
    local hasHint = GAMEMODE and GAMEMODE.AddNotify

    if GetConVar("playx_error_windows"):GetBool() or not hasHint then
        Derma_Message(err, L"Error", L"OK")
        gui.EnableScreenClicker(true)
        gui.EnableScreenClicker(false)
    else
	    GAMEMODE:AddNotify(L"PlayX error: " .. tostring(err), NOTIFY_ERROR, 7);
	    surface.PlaySound("ambient/water/drip" .. math.random(1, 4) .. ".wav")
	end
end

--- Opens the update window.
function PlayX.OpenUpdateWindow(ver)
end

--- Opens the dialog for choosing a model to spawn the player with.
-- @param forRepeater
function PlayX.OpenSpawnDialog(forRepeater,forProximity)
    if spawnWindow and spawnWindow:IsValid() then
        return
    end

    local frame = vgui.Create("DFrame")
    frame:SetDeleteOnClose(true)
    frame:SetTitle(L"Select Model for PlayX " .. (forRepeater and L"Repeater" or L"Player"))
    frame:SetSize(275, 400)
    frame:SetSizable(true)
    frame:Center()
    frame:MakePopup()
    spawnWindow = frame

    local modelList = vgui.Create("DPanelList", frame)
    modelList:EnableHorizontal(true)
    modelList:SetPadding(5)

    for model, info in pairs(PlayXScreens) do
        if not forRepeater or not info.NoScreen then
	        local spawnIcon = vgui.Create("SpawnIcon", modelList)
	        
	        spawnIcon:SetModel(model)
	        spawnIcon.Model = model
	        spawnIcon.DoClick = function()
	            surface.PlaySound("ui/buttonclickrelease.wav")
	            RunConsoleCommand("playx_spawn" .. (forRepeater and "_repeater" or forProximity and "_proximity" or ""), spawnIcon.Model)
	            frame:Close()
	        end
	        
	        modelList:AddItem(spawnIcon)
        end
    end

    local cancelButton = vgui.Create("DButton", frame)
    cancelButton:SetText("Cancel")
    cancelButton:SetWide(80)
    cancelButton.DoClick = function()
        frame:Close()
    end

    local customModelButton = vgui.Create("DButton", frame)
    customModelButton:SetText("Custom...")
    customModelButton:SetWide(80)
    customModelButton:SetTooltip(L"Try PlayX's \"best attempt\" at using an arbitrary model")
    customModelButton.DoClick = function()
        Derma_StringRequest("Custom Model", L"Enter a model path (i.e. models/props_lab/blastdoor001c.mdl)", "",
            function(text)
                local text = text:Trim()
                if text ~= "" then
                    RunConsoleCommand("playx_spawn" .. (forRepeater and "_repeater" or forProximity and "_proximity" or ""), text)
                    frame:Close()
                else
                    Derma_Message(L"You didn't enter a model path.", L"Error", L"OK")
                end
            end)
    end

    local oldPerform = frame.PerformLayout
    frame.PerformLayout = function()
        oldPerform(frame)
        modelList:StretchToParent(5, 25, 5, 35)
	    cancelButton:SetPos(frame:GetWide() - cancelButton:GetWide() - 5,
	                        frame:GetTall() - cancelButton:GetTall() - 5)
	    customModelButton:SetPos(frame:GetWide() - cancelButton:GetWide() - customModelButton:GetWide() - 8,
	                        frame:GetTall() - customModelButton:GetTall() - 5)
    end

    frame:InvalidateLayout(true, true)
end