
local apiKey = "AIzaSyAOXYJd-KlRB1thyjdifdsD9PCW_GrwsfU"

local YouTube = {}

function YouTube.Detect(uri)
    local m = playxlib.FindMatch(uri, {
        "^http[s]?://youtube%.com/watch%?.*v=([A-Za-z0-9_%-]+)",
		"^http[s]?://youtu%.be/([A-Za-z0-9_%-]+)",
        "^http[s]?://[A-Za-z0-9%.%-]*%.youtube%.com/watch%?.*v=([A-Za-z0-9_%-]+)",
        "^http[s]?://[A-Za-z0-9%.%-]*%.youtube%.com/v/([A-Za-z0-9_%-]+)",
        "^http[s]?://youtube%-nocookie%.com/watch%?.*v=([A-Za-z0-9_%-]+)",
        "^http[s]?://[A-Za-z0-9%.%-]*%.youtube%-nocookie%.com/watch%?.*v=([A-Za-z0-9_%-]+)",

    })

    if m then
        return m[1]
    end
end

function YouTube.GetPlayer(uri, useJW)
    if uri:find("^[A-Za-z0-9_%-]+$") then
        if useJW then
            return {
                ["Handler"] = "moan",
                ["URI"] = "http://www.youtube.com/watch?v=" ..uri,
                ["ResumeSupported"] = true,
                ["LowFramerate"] = false,
                ["MetadataFunc"] = function(callback, failCallback)
                    YouTube.QueryMetadata(uri, callback, failCallback)
                end,
            }
        else
            local vars = {
                ["autoplay"] = "1",
                ["start"] = "__start__",
                ["rel"] = "0",
                ["hd"] = "0",
                ["showsearch"] = "0",
                ["showinfo"] = "0",
                ["enablejsapi"] = "1",
            }

            local url = Format("http://www.youtube.com/v/%s&%s", uri, playxlib.URLEscapeTable(vars))

            return {
                ["Handler"] = "FlashAPI",
                ["URI"] = url,
                ["ResumeSupported"] = true,
                ["LowFramerate"] = false,
                ["MetadataFunc"] = function(callback, failCallback)
                    YouTube.QueryMetadata(uri, callback, failCallback)
                end,
                ["HandlerArgs"] = {
                    ["JSInitFunc"] = "onYouTubePlayerReady",
                    ["JSVolumeFunc"] = "setVolume",
                    ["StartMul"] = 1,
                },
            }
        end
    end
end

function YouTube.QueryMetadata(uri, callback, failCallback)
    local vars = playxlib.URLEscapeTable({
        ["alt"] = "atom",
        ["key"] = apiKey,
        ["client"] = game.SinglePlayer() and "SP" or ("MP:" .. GetConVar("hostname"):GetString()),
    })
	local url = "https://www.googleapis.com/youtube/v3/videos?part=snippet%2CcontentDetails&id=".. uri .."&maxResults=1&fields=items(ageGating%2CcontentDetails(duration)%2Csnippet(title%2Cthumbnails%2CchannelTitle%2CchannelId%2Cdescription%2CpublishedAt))&key=" .. apiKey
	-- I know I dozed the Format thing, but the encoded url has %C parts that mess with the formatter.
	-- Ah welp, it's sanitized before

    http.Fetch(url, function(result, size)
        --[[if size == 0 then
            failCallback("Video not found!")
            return
        end]]
		local videoJSON = util.JSONToTable(result)
		if not videoJSON["items"] or not videoJSON["items"][1] or not videoJSON["items"][1]["snippet"] then
			failCallback("Video not found!")
            return
		end
		local title = videoJSON["items"][1]["snippet"]["title"]
		local desc = videoJSON["items"][1]["snippet"]["description"]

		local submitter = videoJSON["items"][1]["snippet"]["channelTitle"]
		local submitterUrl = "https://youtube.com/user/" .. videoJSON["items"][1]["snippet"]["channelId"]
		local publishedDate = nil
		if videoJSON["items"][1]["snippet"]["publishedAt"] then
			local y, mo, d, h, m, s = string.match(videoJSON["items"][1]["snippet"]["publishedAt"], "([0-9]+)-([0-9]+)-([0-9]+)T([0-9]+):([0-9]+):([0-9]+)%.000Z")
			if y and mo and d and h and m and s then
				publishedDate = playxlib.UTCTime({year=tonumber(y), month=tonumber(mo),
											   day=tonumber(d), hour=tonumber(h),
											   min=tonumber(m), sec=tonumber(s)})
			end
		end
		local hours = string.match(videoJSON["items"][1]["contentDetails"]["duration"],"([0-9]+)H")
		local mins = string.match(videoJSON["items"][1]["contentDetails"]["duration"],"([0-9]+)M")
		local secs = string.match(videoJSON["items"][1]["contentDetails"]["duration"],"([0-9]+)S")

		local length = 0
		if secs then
			length = length + tonumber(secs)
		end
		if mins then
			length = length + tonumber(mins)*60
		end
		if hours then
			length = length + tonumber(hours)*3600
		end
		local thumbnail = videoJSON["items"][1]["snippet"]["thumbnails"]["high"] or videoJSON["items"][1]["snippet"]["thumbnails"]["medium"] or videoJSON["items"][1]["snippet"]["thumbnails"]["default"]

		if length then
			callback({
				["URL"] = "http://www.youtube.com/watch?v=" .. uri,
				["Title"] = title,
				["Description"] = desc or "",
				["Length"] = length,
				["DatePublished"] = publishedDate,
				["Submitter"] = submitter,
				["SubmitterURL"] = submitterURL or nil,
				["Thumbnail"] = thumbnail["url"],
				--["AllowedIn"] = allows,
				["RatedEmbeddedDisabled"] = ratedEmbeddedDisabled,
			})
		else
			callback({
				["URL"] = "http://www.youtube.com/watch?v=" .. uri,
			})
		end
    end)
end

list.Set("PlayXProviders", "YouTube", YouTube)
list.Set("PlayXProvidersList", "YouTube", {"YouTube"})