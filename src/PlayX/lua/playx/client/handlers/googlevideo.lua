list.Set("PlayXHandlers", "Google", function(width, height, start, volume, adjVol, uri, handlerArgs, callback)
	local result = playxlib.HandlerResult{
		body = [[
		<embed id="embedVideo" height="]]..height..[["
		src="https://video.google.com/get_player?enablejsapi=1&modestbranding=1&autoplay=1&start=]]..start..[[&ps=docs&partnerid=30&docid=]]..uri..[[&BASE_URL=https://docs.google.com/"
		type="application/x-shockwave-flash"
		width="]]..width..[["
		allowfullscreen="true"
		allowscriptaccess="always"
		bgcolor="#fff" scale="noScale"
		wmode="opaque"
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

	return callback(result)
end)