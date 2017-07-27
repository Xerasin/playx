local TwitchTV = {}

function TwitchTV.Detect(uri)
    local m = playxlib.FindMatch(uri:gsub("%?.*$", ""), {
        "^http://www%.twitch%.tv/([a-zA-Z0-9_]+)$",
        "^http://twitch%.tv/([a-zA-Z0-9_]+)$",
    })

    if m then
        return m[1]
    end
end

function TwitchTV.GetPlayer(uri, useJW)
    if uri:lower():find("^[a-zA-Z0-9_]+$") then
        return {
            ["Handler"] = "twitch.tv",
            ["URI"] = uri,
            ["ResumeSupported"] = true,
            ["LowFramerate"] = false,
            ["QueryMetadata"] = function(callback, failCallback)
                TwitchTV.QueryMetadata(uri, callback, failCallback)
            end,
        }
    end
end

function TwitchTV.QueryMetadata(uri, callback, failCallback)
    callback({
        ["URL"] = "http://www.twitch.tv/" .. uri,
    })
end

list.Set("PlayXProviders", "twitch.tv", TwitchTV)
list.Set("PlayXProvidersList", "twitch.tv", {"twitch.tv"})