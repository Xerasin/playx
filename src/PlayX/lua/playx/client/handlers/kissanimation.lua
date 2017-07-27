list.Set("PlayXHandlers", "kissanime", function(width, height, start, volume, adjVol, uri, handlerArgs, callback)
	local videoURL = uri

	local result = playxlib.HandlerResult{
		body = [[
		<embed id="embedVideo" height="]]..height..[["
		src="http://www.youtube.com/get_player?enablejsapi=1&modestbranding=1"
		type="application/x-shockwave-flash"
		width="]]..width..[["
		allowfullscreen="true"
		allowscriptaccess="always"
		bgcolor="#fff" scale="noScale"
		wmode="opaque"
		flashvars="]]..videoURL..[["
		style="width: ]]..width..[[px; height: ]]..height..[[px" />
		]],

		css = [[
		*{margin:0;}
		]],

		js = [[
			function onYouTubePlayerReady(playerId) {
				ytplayer = document.getElementById("embedVideo");
				ytplayer.seekTo(]]..start..[[, true);
				ytplayer.setVolume(]]..volume..[[);
			}
		]]

	}

	result.GetVolumeChangeJS = function(volume)
		return [[
			ytplayer = document.getElementById("embedVideo");
			ytplayer.setVolume(]]..volume..[[);]]
	end

	callback(result)
end)