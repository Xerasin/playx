list.Set("PlayXHandlers", "DEBUG_googlecontent", function(width, height, start, volume, adjVol, uri, handlerArgs, callback)
	
	local function URLDecode(s)
		s = string.gsub(s, "+", " ")
		s = string.gsub(s, "%%(%x%x)", function (h)
				return string.char(tonumber(h, 16))
			end)
		return s
	end
	local resolutionReference = 
		{	
			[37] = '1920x1080',
			[22] = '1280x720', 
			[18] = '640x360' 
		}
	local matchTable = {}
	local resRef
	local singleRes
	singleRes = string.Split(uri,'=')
	local replaceBy
		if singleRes[2] == 'm37' then resRef = 37 replaceBy = 1080 end
		if singleRes[2] == 'm22' then resRef = 22 replaceBy = 720 end
		if singleRes[2] == 'm18' then resRef = 18 replaceBy = 360 end
	singleRes = "fmt_list="..resRef.."/"..resolutionReference[resRef].."&fmt_stream_map="..playxlib.URLEscape(singleRes[1]).."&host_language=en&el=embedded&video_id=non&fs=1&hl=en&autoplay=1&ps=picasaweb&playerapiid=uniquePlayerId&t=1&auth_timeout=86400000000"
	
	uri = playxlib.HTMLEscape(singleRes)
	local videoURL = uri

	local result = playxlib.HandlerResult{
		body = [[
		<embed id="embedVideo" height="]]..height..[[" 
		src="http://www.youtube.com/get_player?enablejsapi=1&modestbranding=1"type="application/x-shockwave-flash" 
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
			console.log("Player ready!")
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