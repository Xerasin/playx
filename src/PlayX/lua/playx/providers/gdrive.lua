local Google = {}

function Google.Detect(uri)
	string.gsub(uri,"&authuser=0","")
    local m = playxlib.FindMatch(uri, {
        "http[s]://drive.google.com/open%?.*id=([A-Za-z0-9_%-]+)",
        "http[s]://docs.google.com/file/d/([A-Za-z0-9_%-]+)",
        "http[s]://drive.google.com/file/d/([A-Za-z0-9_%-]+)"
    })
    if m then
        return m[1]
    end
end
function Google.GetPlayer(uri, useJW)
		return {
			["Handler"] = "Google",
			["URI"] = uri,
			["ResumeSupported"] = true,
			["LowFramerate"] = false,
			["MetadataFunc"] = function(callback, failCallback)
				Google.QueryMetadata(uri, callback, failCallback)
			end,
		}
end
function Google.QueryMetadata(uri, callback, failCallback)
    local url = Format("https://www.googleapis.com/drive/v2/files/%s?key=AIzaSyDMtfNruJbxNAM0yFGKGudaq7e2jUSgbLs", uri)
	local GD_notfound
	local GD_novideo
	--local url = "https://www.googleapis.com/drive/v2/files/"..uri.."?key=AIzaSyDMtfNruJbxNAM0yFGKGudaq7e2jUSgbLs"
    http.Fetch(url, function(result, size)
        if result == "Not Found" then
			GD_notfound = true
        end
        local videoResults = util.JSONToTable(result)
        if videoResults["error"] and (videoResults["error"]["code"] == 404) then
			GD_notfound = true
        end
        if not videoResults["mimeType"] or not videoResults["mimeType"]:find([[video/]]) then
			GD_novideo = true
        end
		
		if videoResults["videoMediaMetadata"] and videoResults["videoMediaMetadata"]["durationMillis"] then
			duration = videoResults["videoMediaMetadata"]["durationMillis"]/1000
		end
		
        local url = "https://drive.google.com/open?id="..uri
        local title = videoResults["title"]
        local thumbnail = videoResults["thumbnailLink"]
        callback({
        	["URL"] = url,
        	["Title"] = title or url,
        	["Length"] = duration,
        	["Thumbnail"] = thumbnail,
			["GD_notfound"] = GD_notfound,
			["GD_novideo"] = GD_novideo,
        })
    end)
end


list.Set("PlayXProviders", "Google", Google)
list.Set("PlayXProvidersList", "Google", {"Google"})