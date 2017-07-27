-- PlayX
-- Copyright (c) 2009, 2010 sk89q <http://www.sk89q.com>
-- 
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 2 of the License, or
-- (at your option) any later version.
-- 
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
-- 
-- $Id$

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

    PlayX.ShowHint("Want to stop what's playing? Go to the Q menu > Options > PlayX")
    PlayX.SeenNotice = true
end

--- Shows an error message. It will be shown in a popup if it is enabled
-- or if hints do not exist in this gamemode.
-- @param err
function PlayX.ShowError(err)
    local hasHint = GAMEMODE and GAMEMODE.AddNotify

    if GetConVar("playx_error_windows"):GetBool() or not hasHint then
        Derma_Message(err, "Error", "OK")
        gui.EnableScreenClicker(true)
        gui.EnableScreenClicker(false)
    else
	    GAMEMODE:AddNotify("PlayX error: " .. tostring(err), NOTIFY_ERROR, 7);
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
    frame:SetTitle("Select Model for PlayX " .. (forRepeater and "Repeater" or "Player"))
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
    customModelButton:SetTooltip("Try PlayX's \"best attempt\" at using an arbitrary model")
    customModelButton.DoClick = function()
        Derma_StringRequest("Custom Model", "Enter a model path (i.e. models/props_lab/blastdoor001c.mdl)", "",
            function(text)
                local text = text:Trim()
                if text ~= "" then
                    RunConsoleCommand("playx_spawn" .. (forRepeater and "_repeater" or ""), text)
                    frame:Close()
                else
                    Derma_Message("You didn't enter a model path.", "Error", "OK")
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
function PlayX.RenderBoundsUI()
	local devpanel = vgui.Create( "DPanel" )
	surface.CreateFont( "LargeTitle", {font = "Trebuchet24",size = 60,weight = 1000} )
	devpanel:SetPos( 0, 30 ) -- Set the position of the panel
	devpanel:SetSize( ScrW(), ScrH()/4.3 ) -- Set the size of the panel
	function devpanel:Paint( w, h )
		local stripes = surface.GetTextureID( "vgui/gradient-u" )
		surface.SetTexture( stripes )
		surface.SetDrawColor(200,0,0,255)
		surface.DrawTexturedRectRotated( devpanel:GetPos()+devpanel:GetWide(), 0, w, ScrW(), 90 )
		surface.DrawTexturedRectRotated( devpanel:GetPos(), 0, w, ScrW(), 270 )
	end
	local devlabel = vgui.Create( "DLabel", devpanel )
	devlabel:SetPos((devpanel:GetWide()/2)-155,10)
	devlabel:SetText( "RenderBounds error: Rejoin the server" )
	devlabel:SetFont( "LargeTitle" )
	devlabel:SizeToContents()
	devlabel:SetTextColor( Color( 0, 0, 0 ) )
	devlabel:SetPos((devpanel:GetWide()/2)-(devlabel:GetWide()/2),20)
	local devlabel2 = vgui.Create( "DLabel", devpanel )
	devlabel2:SetText( "You will not be able to watch any videos until you rejoin the server." )
	devlabel2:SetFont( "DermaLarge" )
	devlabel2:SizeToContents()
	devlabel2:SetTextColor( Color( 0, 0, 0 ) )
	devlabel2:SetPos((devpanel:GetWide()/2)-(devlabel2:GetWide()/2),devpanel:GetTall()*(1.5/3))
	local devlabel3 = vgui.Create( "DLabel", devpanel )
	devlabel3:SetText( "Please type !retry into chat." )
	devlabel3:SetFont( "DermaLarge" )
	devlabel3:SizeToContents()
	devlabel3:SetTextColor( Color( 0, 0, 0 ) )
	devlabel3:SetPos((devpanel:GetWide()/2)-(devlabel3:GetWide()/2),devpanel:GetTall()*(2.2/3))
end