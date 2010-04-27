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

require("chrome")

local isInstalled = chrome ~= nil and chrome.NewBrowser ~= nil
local isSupported = false
local mat = nil
local matSq = nil

-- We need to check whether gm_chrome is installed and whether the PlayX
-- gm_chrome materials exist.
if isInstalled then
    mat = Material("playx/screen")
    matSq = Material("playx/screen_sq")

    if mat and matSq and not mat:IsError() and not matSq:IsError() then
        isSupported = true
    end
end

local ChromeEngine = {}
mkclass(ChromeEngine)

--- Returns on the status of this engine's support.
-- @return Boolean indicating statues
function ChromeEngine.IsSupported()
    return isSupported
end

--- Constructs the object.
-- @param isSquare
-- @param fps
-- @param resource
function ChromeEngine:Initialize(isSquare, fps, resource)
    -- If we are using a square screen, then a square material works much
    -- better, so we need to differentiate.
    if isSquare then
        self.Material = matSq
        self.Teture = matSq:GetMaterialTexture("$basetexture")
        self.TextureID = surface.GetTextureID("playx/screen_sq")
        self.Width = 1024
        self.Height = 1024
    else
        self.Material = mat
        self.Teture = mat:GetMaterialTexture("$basetexture")
        self.TextureID = surface.GetTextureID("playx/screen")
        self.Width = 1024
        self.Height = 512
    end
    
    self.Browser = chrome.NewBrowser(self.Width, self.Height, self.Texture,
                                     self:GetTable())
    
    self.Resource = resource
end

--- Gets the dimensions of the object drawn by this engine.
-- @return Width, height
function ChromeEngine:GetDimensions()
    return self.Width, self.Height
end

function ChromeEngine:Start()
    self:Load(self.Resource)
end

function ChromeEngine:Stop()
    self:Load(self.Resource)
end

--- Loads media.
function ChromeEngine:Load(resource)
    self.Resource = resource
    
    if resource:GetURL() then
        self.Browser:LoadURL(resource:GetURL())
    else
        if PlayX.HostURL == "" then
            Error("PlayX: Host URL is invalid")
        end
        self.Browser:LoadURL(PlayX.HostURL)
    end
end

--- Renders to a surface.
function ChromeEngine:Paint()
    self.Browser:Update() -- Need to redraw
    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawRect(0, 0, self.Width, self.Height)
    surface.SetTexture(self.TextureID)
    surface.DrawTexturedRect(0, 0, self.Width, self.Height)
end

--- Changes the FPS.
-- @param fps
function ChromeEngine:SetFPS(fps)
    -- We don't need to set an FPS
end

--- Changes the volume.
-- @param volume
function ChromeEngine:SetVolume(volume)
    local js = self.Resource:GetVolumeJS(volume)
    if js then
        self.Browser:Exec(js)
    end
end

--- Returns where the content should be centered.
-- @return
function ChromeEngine:IsCentered()
    return self.resource.Centered
end

--- Destroys the browser instance.
function ChromeEngine:Destroy()
    self.Browser:Free()
end

--- Called by gm_chrome when the page has finished loading. We need to do
-- our dirty work here.
function ChromeEngine:onFinishLoading()
    -- Don't have to do much if it's a URL that we are loading
    if self.Resource:GetURL() then
        -- But let's remove the scrollbar
        self.Browser:Exec([[
document.body.style.overflow = 'hidden';
]])
        return
    else
        -- Execute JavaScript
        self.Browser:Exec(self.Resource:GetJS())
        
        -- Include a JavaScript file
        if self.Resource:GetJSURL() then
            self.Browser:Exec([[
var script = document.createElement('script');
script.type = 'text/javascript';
script.src = ']] .. PlayX.JSEncodeString(self.Resource:GetJSURL()) .. [[';
document.body.appendChild(script);
    ]])
        -- Or set the HTML
        else
            self.Browser:Exec([[
document.body.innerHTML = ']] .. PlayX.JSEncodeString(self.Resource:GetBody()) .. [[';
    ]])
        end
        
        -- This ensures that the host page will work (For the most part)
        self.Browser:Exec([[
document.body.style.margin = '0';
document.body.style.padding = '0';
document.body.style.border = '0';
document.body.style.background = '#000000';
document.body.style.overflow = 'hidden';
    ]])
        
        -- Add CSS
        self.Browser:Exec([[
var style = document.createElement('style');
style.type = 'text/css';
style.styleSheet.cssText = ']] .. PlayX.JSEncodeString(self.Resource:GetCSS()) .. [[';
document.getElementsByTagName('head')[0].appendChild(style);
    ]])
    end
end

-- For gm_chrome
function ChromeEngine:onBeginNavigation(url) end
function ChromeEngine:onBeginLoading(url, status) end
function ChromeEngine:onChangeFocus(focus) end