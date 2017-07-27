local StaticWeb = {}

function StaticWeb.Detect(uri)
    local m = playxlib.FindMatch(uri, {
        "^http://.*%.htm",
        "^http://.*%.php",
        "^http://.*%.html",
        "^http://.*%.txt",
        "^http://.*%.log",
        "^http://.*%.js",
    })

    if m then
        return m[1]
    end
end

function StaticWeb.GetPlayer(uri, useJW)
    if uri:find("^http://") then
        return {
            ["Handler"] = "IFrame",
            ["URI"] = uri,
            ["ResumeSupported"] = true,
            ["LowFramerate"] = false,
            ["QueryMetadata"] = function(callback, failCallback)
                StaticWeb.QueryMetadata(uri, callback, failCallback)
            end,
        }
    end
end

function StaticWeb.QueryMetadata(uri, callback, failCallback)
    callback({
        ["URL"] = uri,
    })
end

list.Set("PlayXProviders", "StaticWeb", StaticWeb)
list.Set("PlayXProvidersList", "StaticWeb", {"Webpage"})

