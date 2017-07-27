list.Set("PlayXHandlers", "NotYoutubeButHTML5", function(width, height, start, volume, adjVol, uri, handlerArgs, callback)
	local handler = "http://gcinema.net/video-js/lander.php"
	volume = adjVol
	local uri = playxlib.URLEscape(uri)
	
    local result = playxlib.GenerateIFrame(width, height,string.format(handler.."?url=%s&t=%d&vol=%d", uri, start, volume))
	result.GetVolumeChangeJS = function(volume)
		return [[
			VsetVolume(]]..(volume/100)..[[);]]
	end --VsetVolume set on lander, beware
	callback(result)
end)
