local hitbox = {}

function hitbox.Detect(uri)   
    local m = playxlib.FindMatch(uri, {
            "^http[s]?://www%.hitbox%.tv/embed/([%w_-]+)",
            "^http[s]?://www%.hitbox%.tv/([%w_-]+)",
            "^www%.hitbox%.tv/([%w_-]+)",
            "^hitbox%.tv/([%w_-]+)",
        })
    if m then
        return m[1]
    end
end

function hitbox.GetPlayer(uri, useJW)
    if uri:lower():find("^[a-zA-Z0-9_]+$") then
        return {
            ["Handler"] = "hitbox.tv",
            ["URI"] = "http://www.hitbox.tv/embed/" .. uri .. "?popout=true&autoplay=true",
            ["ResumeSupported"] = true,
            ["LowFramerate"] = false,
            ["QueryMetadata"] = function(callback, failCallback)
                hitbox.QueryMetadata(uri, callback, failCallback)
            end,
        }
    end
end

function hitbox.QueryMetadata(uri, callback, failCallback)
    callback({
        ["URL"] = "http://www.hitbox.tv/embed/" .. uri .. "?popout=true&autoplay=true",
        ["Title"] = uri.."'s Hitbox channel",
    })
end

list.Set("PlayXProviders", "hitbox.tv", hitbox)
list.Set("PlayXProvidersList", "hitbox.tv", {"hitbox.tv"})