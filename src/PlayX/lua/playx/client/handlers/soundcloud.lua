list.Set("PlayXHandlers", "SoundCloud", function(width, height, start, volume, adjVol, uri, handlerArgs, callback)
    if(start > 2) then
		start = start + 4 -- Lets account for buffer time...
    end
	volume = adjVol
    local result = playxlib.GenerateIFrame(width, height, "http://gcinema.net/ingame/soundcloud.html?url="..playxlib.URLEscape(uri).."&t="..tostring(start*1000).."&vol="..tostring(volume))
	result.GetVolumeChangeJS = function(volume)
		return [[
			var widget = SC.Widget(document.getElementById('player'));//
			widget.volume = ]]..tostring(volume/100) ..[[;
			widget.setVolume(]]..tostring(volume/100)..[[)]]
	end
	callback(result)
end)