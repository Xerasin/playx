local bassurl = {}

function bassurl.Detect(uri)
	local m = playxlib.FindMatch(uri:gsub("%?.*$", ""), {
		"^http[s]?://.+%.[mM][pP]3$",
		"^http[s]?://.+%.[oO][gG][gG]$",
        "^http[s]?://[^:/]+/;stream%.nsv$",
        "^http[s]?://[^:/]+/;$",
        "^http[s]?://[^:/]+:[0-9]+/?$",
		"^http[s]?://.+%:%d.+"
	})

	if m then
		return m[1]
	end
end

function bassurl.GetPlayer(uri, useJW)
	return {
		["Handler"] = "bassurl",
		["URI"] = uri,
		["ResumeSupported"] = true,
		["LowFramerate"] = false,
		["QueryMetadata"] = function(callback, failCallback)
			bassurl.QueryMetadata(uri, callback, failCallback)
		end,
	}
end

function bassurl.QueryMetadata(uri, callback, failCallback)
	callback({
		["URL"] = uri,
		["Title"] = uri,
	})
end

list.Set("PlayXProviders", "bassurl", bassurl)
list.Set("PlayXProvidersList", "bassurl", {"bassurl"})