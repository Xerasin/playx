local Shoutcast = {}

function Shoutcast.Detect(uri)
end

function Shoutcast.GetPlayer(uri, useJW)
    local m = playxlib.FindMatch(uri, {
        "^http[s]?://.+$",
    })

    if m then
        if not uri:lower():find("^;stream%.nsv") then
            if uri:find("/$") then
                uri = uri .. ";stream%.nsv"
            else
                uri = uri .. "/;stream%.nsv"
            end
        end

        return {
            ["Handler"] = "JWAudio",
            ["URI"] = uri,
            ["ResumeSupported"] = true,
            ["LowFramerate"] = true,
            ["QueryMetadata"] = function(callback, failCallback)
                Shoutcast.QueryMetadata(uri, callback, failCallback)
            end,
        }
    end
end

function Shoutcast.QueryMetadata(uri, callback, failCallback)
    callback({
        ["URL"] = uri,
    })
end

list.Set("PlayXProviders", "Shoutcast", Shoutcast)
list.Set("PlayXProvidersList", "Shoutcast", {"Shoutcast"})

local MP3 = {}

function MP3.Detect(uri)
end

function MP3.GetPlayer(uri, useJW)
    if uri:lower():find("^http[s]?://") then
        return {
            ["Handler"] = "JWAudio",
            ["URI"] = uri,
            ["ResumeSupported"] = true,
            ["LowFramerate"] = true,
            ["QueryMetadata"] = function(callback, failCallback)
                MP3.QueryMetadata(uri, callback, failCallback)
            end,
        }
    end
end

function MP3.QueryMetadata(uri, callback, failCallback)
    callback({
        ["URL"] = uri,
    })
end

list.Set("PlayXProviders", "MP3", MP3)
list.Set("PlayXProvidersList", "MP3", {"MP3"})

local FlashVideo = {}

function FlashVideo.Detect(uri)
    local m = playxlib.FindMatch(uri:gsub("%?.*$", ""), {
        "^http[s]?://.+%.flv$",
        "^http[s]?://.+%.FLV$",
        "^http[s]?://.+%.mp4$",
        "^http[s]?://.+%.MP4$",
        "^http[s]?://.+%.aac$",
        "^http[s]?://.+%.AAC$",
    })

    if m then
        return m[1]
    end
end

function FlashVideo.GetPlayer(uri, useJW)
    if uri:lower():find("^http[s]?://") then
        return {
            ["Handler"] = "JWVideo",
            ["URI"] = uri,
            ["ResumeSupported"] = false,
            ["LowFramerate"] = false,
            ["QueryMetadata"] = function(callback, failCallback)
                FlashVideo.QueryMetadata(uri, callback, failCallback)
            end,
        }
    end
end

function FlashVideo.QueryMetadata(uri, callback, failCallback)
    callback({
        ["URL"] = uri,
    })
end

list.Set("PlayXProviders", "FlashVideo", FlashVideo)
list.Set("PlayXProvidersList", "FlashVideo", {"FLV/MP4/AAC"})

local Image = {}

function Image.Detect(uri)
    local m = playxlib.FindMatch(uri:gsub("%?.*$", ""), {
        "^http[s]?://.+%.jpe?g$",
        "^http[s]?://.+%.JPE?G$",
        "^http[s]?://.+%.png$",
        "^http[s]?://.+%.PNG$",
        "^http[s]?://.+%.gif$",
        "^http[s]?://.+%.GIF$",
    })

    if m then
        return m[1]
    end
end

function Image.GetPlayer(uri, useJW)
    if uri:lower():find("^http[s]?://") then
        return {
            ["Handler"] = "Image",
            ["URI"] = uri,
            ["ResumeSupported"] = true,
            ["LowFramerate"] = false,
            ["QueryMetadata"] = function(callback, failCallback)
                Image.QueryMetadata(uri, callback, failCallback)
            end,
        }
    end
end

function Image.QueryMetadata(uri, callback, failCallback)
    callback({
        ["URL"] = uri,
    })
end

list.Set("PlayXProviders", "Image", Image)
list.Set("PlayXProvidersList", "Image", {"Image"})
list.Set("PlayXProviders", "AnimatedImage", Image) -- Legacy


local WebM = {}

function WebM.Detect(uri)
    local m = playxlib.FindMatch(uri:gsub("%?.*$", ""), {
        "^http[s]?://.+%.[wW][eE][bB][mM]$",
    })

    if m then
        return m[1]
    end
end

function WebM.GetPlayer(uri, useJW)
    if uri:lower():find("^http[s]?://") then
        return {
            ["Handler"] = "WebM",
            ["URI"] = uri,
            ["ResumeSupported"] = true,
            ["LowFramerate"] = false,
            ["QueryMetadata"] = function(callback, failCallback)
                WebM.QueryMetadata(uri, callback, failCallback)
            end,
        }
    end
end

function WebM.QueryMetadata(uri, callback, failCallback)
    callback({
        ["URL"] = uri,
    })
end

list.Set("PlayXProviders", "WebM", WebM)
list.Set("PlayXProvidersList", "WebM", {"WebM"})


local WebAudio = {}

function WebAudio.Detect(uri)
    local m = playxlib.FindMatch(uri:gsub("%?.*$", ""), {
		--"^http[s]?://.+%.[aA][aA][Cc]$",
		--"^http[s]?://.+%.[oO][pP][uU][sS]$",
		"^http[s]?://.+%.[wW][eE][bB][aA]$",
		"^http[s]?://.+%.[wW][aA][vV]$",
		--"^http[s]?://.+%.[mM][pP]3$",
		--"^http[s]?://.+%.[fF][lL][aA][cC]$",
    })

    if m then
        return m[1]
    end
end

function WebAudio.GetPlayer(uri, useJW)
    if uri:lower():find("^http[s]?://") then
        return {
            ["Handler"] = "WebAudio",
            ["URI"] = uri,
            ["ResumeSupported"] = true,
            ["LowFramerate"] = false,
            ["QueryMetadata"] = function(callback, failCallback)
                WebAudio.QueryMetadata(uri, callback, failCallback)
            end,
        }
    end
end

function WebAudio.QueryMetadata(uri, callback, failCallback)
    callback({
        ["URL"] = uri,
    })
end

list.Set("PlayXProviders", "WebAudio", WebAudio)
list.Set("PlayXProvidersList", "WebAudio", {"WebAudio"})