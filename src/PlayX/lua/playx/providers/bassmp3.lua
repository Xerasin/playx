local bassmp3 = {}

function bassmp3.Detect(uri)
	local m = playxlib.FindMatch(uri:gsub("%?.*$", ""), {
		"^http[s]?://.+%.[mM][pP]3$",
		"^http[s]?://.+%:8000.+",
	})

	if m then
		return m[1]
	end
end

function bassmp3.GetPlayer(uri, useJW)
	return {
		["Handler"] = "bassmp3",
		["URI"] = uri,
		["ResumeSupported"] = true,
		["LowFramerate"] = false,
		["QueryMetadata"] = function(callback, failCallback)
			bassmp3.QueryMetadata(uri, callback, failCallback)
		end,
	}
end

function bassmp3.QueryMetadata(uri, callback, failCallback)
	callback({
		["URL"] = uri,
		["Title"] = uri,
	})
end

list.Set("PlayXProviders", "bassmp3", bassmp3)
list.Set("PlayXProvidersList", "bassmp3", {"bassmp3"})