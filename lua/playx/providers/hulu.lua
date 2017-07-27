local Hulu = {}

function Hulu.Detect(uri)
    local m = playxlib.FindMatch(uri, {
        "^http://www.hulu.com/watch/[0-9]+/.+$",
    })

    if m then
        return uri
    end
end

function Hulu.GetPlayer(uri, useJW)
    local m = playxlib.FindMatch(uri, {
        "^http://www.hulu.com/watch/[0-9]+/.+$",
    })

    if m then
        return {
            ["Handler"] = "Hulu",
            ["URI"] = uri,
            ["ResumeSupported"] = true,
            ["LowFramerate"] = false,
            ["QueryMetadata"] = function(callback, failCallback)
                Hulu.QueryMetadata(uri, callback, failCallback)
            end,
        }
    end
end

function Hulu.QueryMetadata(uri, callback, failCallback)
    callback({
        ["URL"] = uri,
    })
end

list.Set("PlayXProviders", "Hulu", Hulu)
list.Set("PlayXProvidersList", "Hulu", {"Hulu"})