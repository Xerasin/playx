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

local Shoutcast = {}

function Shoutcast.Detect(uri)
    local m = playxlib.FindMatch(uri, {
        "^http[s]?://[^:/]+/;stream%.nsv$",
        "^http[s]?://[^:/]+:[0-9]+/?$",
    })

    if m then
        return m[1]
    end
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
    local m = playxlib.FindMatch(uri:gsub("%?.*$", ""), {
        "^http[s]?://.+%.mp3$",
        "^http[s]?://.+%.MP3$",
    })

    if m then
        return m[1]
    end
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

    if m and not m[1]:find("media.gcinema.net") then
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
        "^http[s]?://.+%.webm$",
        "^http[s]?://.+%.WEBM$",
    })

    if m then
        return m[1]
    end
end

function WebM.GetPlayer(uri, useJW)
    if uri:lower():find("^http[s]?://") then
        return {
            ["Handler"] = "NotYoutubeButHTML5", ------REVERT BACK TO WebM IF IT FAILS!!! ALSO, COMMENTED OUT video/mp4 ON JS-LANDER; CHANGE THAT BACK!
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


local IFrame = {}

function IFrame.Detect(uri)
  return false
end

function IFrame.GetPlayer(uri, useJW)
    return {
        ["Handler"] = "IFrame",
        ["URI"] = uri,
        ["ResumeSupported"] = true,
        ["LowFramerate"] = true,
        ["QueryMetadata"] = function(callback, failCallback)
            IFrame.QueryMetadata(uri, callback, failCallback)
        end,
    }
end

function IFrame.QueryMetadata(uri, callback, failCallback)
    callback({
        ["URL"] = uri,
    })
end

list.Set("PlayXProviders", "IFrame", IFrame)
list.Set("PlayXProvidersList", "IFrame", {"IFrame"})
