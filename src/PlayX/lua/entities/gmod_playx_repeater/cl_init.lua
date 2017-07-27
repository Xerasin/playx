-- PlayX
-- Copyright (c) 2009 sk89q <http://www.sk89q.com>
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

include("shared.lua")

language.Add("gmod_playx_repeater", "PlayX Repeater")
language.Add("Undone_gmod_playx_repeater", "Undone PlayX Repeater")
language.Add("Undone_#gmod_playx_repeater", "Undone PlayX Repeater")
language.Add("Cleanup_gmod_playx_repeater", "PlayX Repeaters")
language.Add("Cleaned_gmod_playx_repeater", "Cleaned up PlayX Repeaters")

ENT.CLSource = nil
ENT.SourceInstance = nil

--- Initialize the entity.
-- @hidden
function ENT:Initialize()
    if self.KVModel then
        self.Entity:SetModel(self.KVModel)
    end

    self.Entity:DrawShadow(false)

    self.DrawCenter = false
    self.NoScreen = false

    self:UpdateScreenBounds()
end

--- Set the PlayX entity to be the source. Pass nil or NULL to clear.
-- This will override the server set source.
-- @param src Source
function ENT:SetSource(src)
    self.CLSource = IsValid(src) and src or nil
end

--- Get the client set source entity. May return nil.
-- @return Source
function ENT:GetSource()
    return self.CLSource
end

--- Get the server set source entity. May return nil.
-- @return Source
function ENT:GetServerSource()
    return IsValid(self.dt.Source) and self.dt.Source or nil
end

--- Get the active source entity. May return nil.
-- @return Source
function ENT:GetActiveSource()
    return IsValid(self.SourceInstancee) and self.SourceInstance or nil
end

--- Used to draw the screen content. This function must be called once
-- a 3D2D context has been created.
-- @param centerX Center X
-- @param centerY Center Y
-- @param x Top left position
-- @param y Top left position
-- @param width Width of screen
-- @param height Height of screen
-- @hidden
function ENT:DrawScreen(centerX, centerY, x, y, width, height)
    if IsValid(self.SourceInstance) then
        if not self.SourceInstance.NoScreen then
            self.SourceInstance:DrawScreen(centerX, centerY, x, y, width, height)
        else
        draw.SimpleText("PlayX source has no screen",
                        "PlayXHUDNumber",
                        centerX, centerY, Color(255, 255, 255, 255),
                        TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    else
        draw.SimpleText("PlayX source is required for repeater",
                        "PlayXHUDNumber",
                        centerX, centerY, Color(255, 255, 255, 255),
                        TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

--- Think hook that gets the source instance.
-- @hidden
function ENT:Think()
    if IsValid(self.CLSource) then
        self.SourceInstance = self.CLSource
    elseif IsValid(self.dt.Source) then
        self.SourceInstance = self.dt.Source
    else
        self.SourceInstance = self:GetClosestInstance() or PlayX.GetInstance()
    end

    if IsValid(self.SourceInstance) then
        self.DrawCenter = self.SourceInstance.DrawCenter
    end

    self:NextThink(CurTime() + 0.1) -- does not work .. EEK
end

function ENT:Draw()
    --self.Entity:DrawModel()

    if self.NoScreen then return end
    if not self.DrawScale then return end

    -- No black screen if this global var is set
    if PLAYX_PLACEHOLDER_SCREEN == false and 
        (not self.Browser or not self.Browser:IsValid() or not self.Media) then
        return
    end

    render.SuppressEngineLighting(true)

    if self.IsProjector then
        local tr = self:GetProjectorTrace()

        if tr.Hit then
            local ang = tr.HitNormal:Angle()
            ang:RotateAroundAxis(ang:Forward(), 90) 
            ang:RotateAroundAxis(ang:Right(), -90)

            local width = tr.HitPos:Distance(self.Entity:LocalToWorld(self.Entity:OBBCenter())) * 0.001
            local height = width / 2
            local pos = tr.HitPos - ang:Right() * height * self.HTMLHeight / 2
                        - ang:Forward() * width * self.HTMLWidth / 2
                        + ang:Up() * 2

            -- This makes the screen show all the time
            self:SetRenderBoundsWS(Vector(-1100, -1100, -1100) + tr.HitPos,
                                   Vector(1100, 1100, 1100) + tr.HitPos)

            cam.Start3D2D(pos, ang, width)
            surface.SetDrawColor(0, 0, 0, 255)
            surface.DrawRect(0, 0, 1024, 512)
            self:DrawScreen(1024 / 2, 512 / 2, 0, 0, 1024, 512)
            cam.End3D2D()
        end
    else        
        local pos = self.Entity:LocalToWorld(self.ScreenOffset)
        local ang = self.Entity:GetAngles()
		local right,up,forward = self.RotateAroundRight,self.RotateAroundUp,self.RotateAroundForward
		if right then
			ang:RotateAroundAxis(ang:Right(), right)
        end
		if up then 
			ang:RotateAroundAxis(ang:Up(), up)
        end
		if forward then 
			ang:RotateAroundAxis(ang:Forward(), forward)
		end
        -- This makes the screen show all the time
        self:SetRenderBoundsWS(Vector(-1100, -1100, -1100) + self:GetPos(),
                               Vector(1100, 1100, 1100) + self:GetPos())

        cam.Start3D2D(pos, ang, self.DrawScale)

        -- Draw black background
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawRect(0, 0, self.DrawWidth, self.DrawHeight)

        -- Draw screen
        self:DrawScreen(self.DrawWidth / 2,
                        self.DrawHeight / 2,
                        self.DrawShiftX,
                        self.DrawShiftY,
                        self.DrawWidth, self.DrawHeight)
        cam.End3D2D()
    end

    render.SuppressEngineLighting(false)
end
--- Do nothing removal hook.
-- @hidden
function ENT:OnRemove() 
end  