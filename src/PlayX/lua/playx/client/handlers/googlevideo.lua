list.Set("PlayXHandlers", "Google", function(width, height, start, volume, adjVol, uri, handlerArgs, callback)
	local chosen_qual = CreateClientConVar ("theater_kissanimeres", "720"):GetInt()
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
		style="width: ]]..width..[[px; height: ]]..height..[[px" >
		<div style="background: red none repeat scroll 0% 0%; color: rgb(255, 255, 255); font: 45pt Calibri; width: 95%; position: relative; top: 30vh; margin: 0px auto; padding: 30px; text-align: center;">
			<div style="padding-bottom:10px">Adobe Flash Player <strong style="text-decoration: underline">for other browsers</strong> is not installed.<br></div><br />
			<div style="padding-bottom:10px"><b style="color:black;">></b>Go to <b style="color:red;background-color:white">http://flash.gcinema.net</b><br></div>
			<div style="padding-bottom:10px"><b style="color:black;">></b>Select your Operating System, then <b style="color:red;background-color:white">FP for Firefox - NPAPI</b><br></div>
			<div style="padding-bottom:10px"><b style="color:black;">></b><b style="color:red;background-color:white">Install</b>, then <b style="color:red;background-color:white">restart Garry's Mod</b><br></div>
			<div style="padding-bottom:10px"><b style="color:black;">></b><b style="color:red;background-color:white">Join back this server</b><br></div>
		</div>
		</embed>
		]],

		css = [[
		*{margin:0;}
		]],

		js = [[
			function switchQuality(ply,q){
				var refList = {1080: 'hd1080', 720: 'hd720', 480: 'large', 360: 'medium', 240: 'small'};
				SetQualTo = refList[q]
				ply.setPlaybackQuality(SetQualTo);
				console.log("Setting video quality to "+SetQualTo+"; Video quality actually set to"+ply.GetPlaybackQuality());
			}
			function onYouTubePlayerReady(playerId) {
			console.log("Player ready!")
			  ytplayer = document.getElementById("embedVideo");
			  ytplayer.seekTo(]]..start..[[, true);
			  ytplayer.setVolume(]]..volume..[[);
			  switchQuality(ytplayer,]]..chosen_qual..[[)
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