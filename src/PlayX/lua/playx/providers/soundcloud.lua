include("playxlib.lua")
local SoundCloud = {}

function SoundCloud.Detect(uri, useJW)
    local m = playxlib.FindMatch(uri:gsub("%?.*$", ""), {
        "^http[s]?://soundcloud.com/(.+)/(.+)$",
		"^http[s]?://www.soundcloud.com/(.+)/(.+)$",
		"^http[s]?://api.soundcloud.com/tracks/(%d)+",
    })
	if(m) then
		if m[1] and m[2] then
			return "http://soundcloud.com/"..m[1].."/"..m[2]
		elseif(m[1]) then
			return "http://api.soundcloud.com/tracks/"..m[1]
		end
	end
end

function SoundCloud.GetPlayer(uri, useJW)
	local url = uri
	return {
		["Handler"] = "SoundCloud",
		["URI"] = url,
		["ResumeSupported"] = true,
		["LowFramerate"] = false,
		["QueryMetadata"] = function(callback, failCallback)
			SoundCloud.QueryMetadata(uri, callback, failCallback)
		end,
		["HandlerArgs"] = {
			["VolumeMul"] = 0.1,
		},
	}
end
SoundCloud.Cache = {}
function SoundCloud.QueryMetadata(uri, callback, failCallback)
    local url = "http://api.soundcloud.com/resolve.json?url="..uri.."&client_id=cb09cb2fe6132065fc82671cb433b4f5"
	local function Do(dec)
		if(dec["title"] ~= nil) then
			local title = dec["title"]
			local desc = dec["description"]
			local viewerCount = dec["playback_count"]
			//local tags = playxlib.ParseTags(dec["tag_list"])
			callback({
				["Duration"] = math.floor(tonumber(dec["duration"])/1000),
				["URL"] = dec["uri"],
				["URL2"] = uri,
				["Title"] = title,
				["Description"] = desc,
				["Tags"] = tags,
				["ViewerCount"] = viewerCount,
			})
		end
	end
    if SoundCloud.Cache[url] then
    	Do(SoundCloud.Cache[url])
    	return
    end
    http.Fetch(url,function(content,size)
		if(content == NULL) then
			if(failCallback) then failCallback("Failed to get Metadata") end
		end
		local dec = util.JSONToTable(content) or {}
		if(dec["title"] ~= nil) then
			SoundCloud.Cache[url] = dec
			Do(dec)
		end
	end)
end

list.Set("PlayXProviders", "SoundCloud", SoundCloud)
list.Set("PlayXProvidersList", "SoundCloud", {"SoundCloud"})