local KissCartoon = {}

function KissCartoon.Detect(uri)
    local m = playxlib.FindMatch(uri, {
        "http[s]?://kisscartoon.me/Cartoon/",
    })
    if m then
        return uri
    end
end

function KissCartoon.GetPlayer(uri, useJW)
		return {
			["Handler"] = "kissanime",
			["URI"] = uri,
			["ResumeSupported"] = true,
			["LowFramerate"] = false,
			["MetadataFunc"] = function(callback, failCallback)
				KissCartoon.QueryMetadata(uri, callback, failCallback)
			end,
		}
end
function KissCartoon.QueryMetadata(uri, callback, failCallback)
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

list.Set("PlayXProviders", "KissCartoon", KissCartoon)
list.Set("PlayXProvidersList", "KissCartoon", {"KissCartoon"})