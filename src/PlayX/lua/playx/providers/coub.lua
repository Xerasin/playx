local Coub = {}

function Coub.Detect(uri)
    local m = playxlib.FindMatch(uri,{
        "^http://coub.com/view/([a-zA-Z0-9_]+)$",
    })
	
    if m then
        return m[1]
    end
end

function Coub.GetPlayer(uri, useJW)
    if uri:lower():find("^[a-zA-Z0-9_]+$") then
        return {
            ["Handler"] = "IFrame",
            ["URI"] = "http://coub.com/embed/" .. uri .. "?autostart=true",
            ["ResumeSupported"] = true,
            ["LowFramerate"] = false,
            ["QueryMetadata"] = function(callback, failCallback)
                Coub.QueryMetadata(uri, callback, failCallback)
            end,
        }
    end
end

function Coub.QueryMetadata(uri, callback, failCallback)
    callback({
        ["URL"] = "http://coub.com/embed/" .. uri .. "?autostart=true",
    })
end

list.Set("PlayXProviders", "coub.com", Coub)
list.Set("PlayXProvidersList", "coub.com", {"coub.com"})