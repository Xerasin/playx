local Flash = {}

function Flash.Detect(uri)
    return nil
end

function Flash.GetPlayer(uri, useJW)
    if uri:lower():find("^http://") then
        return {
            ["Handler"] = "Flash",
            ["URI"] = uri,
            ["ResumeSupported"] = false,
            ["LowFramerate"] = false,
            ["QueryMetadata"] = function(callback, failCallback)
                Flash.QueryMetadata(uri, callback, failCallback)
            end,
        }
    end
end

function Flash.QueryMetadata(uri, callback, failCallback)
    callback({
        ["URL"] = uri,
    })
end

list.Set("PlayXProviders", "Flash", Flash)
list.Set("PlayXProvidersList", "Flash", {"Flash"})

local FlashMovie = {}

function FlashMovie.Detect(uri)
    local m = playxlib.FindMatch(uri:gsub("%?.*$", ""), {
        "^http://.+%.swf$",
        "^http://.+%.SWF$",
    })

    if m then
        return m[1]
    end
end

function FlashMovie.GetPlayer(uri, useJW)
    if uri:lower():find("^http://") then
        return {
            ["Handler"] = "Flash",
            ["URI"] = uri,
            ["ResumeSupported"] = false,
            ["LowFramerate"] = false,
            ["QueryMetadata"] = function(callback, failCallback)
                FlashMovie.QueryMetadata(uri, callback, failCallback)
            end,
            ["HandlerArgs"] = {
                ["ForcePlay"] = true,
            },
        }
    end
end

function FlashMovie.QueryMetadata(uri, callback, failCallback)
    callback({
        ["URL"] = uri,
    })
end

list.Set("PlayXProviders", "FlashMovie", FlashMovie)
--list.Set("PlayXProvidersList", "FlashMovie", {"Flash movie [force play buttons]"})