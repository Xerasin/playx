local JustinTV = {}

function JustinTV.Detect(uri)
    local m = playxlib.FindMatch(uri:gsub("%?.*$", ""), {
        "^http://www%.justin%.tv/([a-zA-Z0-9_]+)$",
        "^http://justin%.tv/([a-zA-Z0-9_]+)$",
    })

    if m then
        return m[1]
    end
end

function JustinTV.GetPlayer(uri, useJW)
    if uri:lower():find("^[a-zA-Z0-9_]+$") then
        return {
            ["Handler"] = "justin.tv",
            ["URI"] = uri,
            ["ResumeSupported"] = true,
            ["LowFramerate"] = false,
            ["QueryMetadata"] = function(callback, failCallback)
                JustinTV.QueryMetadata(uri, callback, failCallback)
            end,
        }
    end
end

function JustinTV.QueryMetadata(uri, callback, failCallback)
    callback({
        ["URL"] = "http://www.justin.tv/" .. uri,
    })
end

list.Set("PlayXProviders", "justin.tv", JustinTV)
list.Set("PlayXProvidersList", "justin.tv", {"justin.tv"})