local KissAnime = {}

function KissAnime.Detect(uri)
    local m = playxlib.FindMatch(uri, {
        "http[s]?://kissanime.com/Anime/",
    })
    if m then
        return uri
    end
end

function KissAnime.GetPlayer(uri, useJW)
		return {
			["Handler"] = "kissanime",
			["URI"] = uri,
			["ResumeSupported"] = true,
			["LowFramerate"] = false,
			["MetadataFunc"] = function(callback, failCallback)
				KissAnime.QueryMetadata(uri, callback, failCallback)
			end,
		}
end

function KissAnime.QueryMetadata(uri, callback, failCallback)
	--local Fetch
	--function Fetch()
	--	local function asd(duration)
	--		http.Fetch(uri, function(result)
	--			local title = string.match(result,[[<meta itemprop="name" content="([^"]*)"[ ]?/>]])
	--			local thumbnail = string.match(result, [[<meta itemprop="thumbnailUrl" content="(.-)"/>]])
	--			callback({
	--				["URL"] = uri,
	--				["Title"] = title or "I apparently can't get this anymore :(",
	--				["Length"] = duration,
	--				["Thumbnail"] = thumbnail or "",
	--			})
	--		end)
			
	--	end
	--	local duration = (3600 * 60)
	--	http.Fetch("http://gcinema.net/providers/KissAnime-Cartoon/video_time_fetch.php?uri=" .. uri, function(s)
	--		if tonumber(s) != nil then
	--			s = tonumber(s)
	--			end
	--		duration = s or (3600 * 60)
	--		asd(duration)
	--	end, function() asd(3600 * 60) end)
	--end
    --Fetch()
	local Fetch
	function Fetch()
			http.Fetch("http://gcinema.net/providers/KissAnime-Cartoon/video_time_fetch.php?type=meta&uri="..uri, function(result)
				local server_result = util.JSONToTable(result)
				if tonumber(server_result.videoLENGTH) != nil then
					server_result.videoLENGTH = tonumber(server_result.videoLENGTH)
				end
				callback({
					["URL"] = uri,
					["URL2"] = server_result.videoURL,
					["Title"] = server_result.videoTITLE or "I apparently can't get this anymore :(",
					["Length"] = server_result.videoLENGTH or (3600 * 60),
					["Thumbnail"] = server_result.videoTHUMB or "",
				})
			end)
	end
    Fetch()
end


list.Set("PlayXProviders", "KissAnime", KissAnime)
list.Set("PlayXProvidersList", "KissAnime", {"KissAnime"})