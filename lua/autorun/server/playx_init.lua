AddCSLuaFile("autorun/client/playx_init.lua")
AddCSLuaFile("playxlib.lua")
AddCSLuaFile("playx/client/playx.lua")
AddCSLuaFile("playx/client/bookmarks.lua")
AddCSLuaFile("playx/client/concmds.lua")
AddCSLuaFile("playx/client/panel.lua")
AddCSLuaFile("playx/client/ui.lua")

-- Add handlers
local p = {}
p = file.Find("playx/client/handlers/*.lua","LUA")

for _, file in pairs(p) do
    AddCSLuaFile("playx/client/handlers/" .. file)
end

include("playx/playx.lua")