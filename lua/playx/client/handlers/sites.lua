
list.Set("PlayXHandlers", "Hulu", function(width, height, start, volume, adjVol, uri, handlerArgs, callback)
    return callback(playxlib.HandlerResult{
        url = uri,
        center = true,
        css = [[
* { overflow: hidden !important; }
]],
        js = [[
var m = document.body.innerHTML.match(/\/embed\/([^"]+)"/);
if (m) {
    document.body.style.overflow = 'hidden';
    var id = m[1];
    document.body.innerHTML = '<div id="player-container"></div>'
    var swfObject = new SWFObject("/embed/" + id, "player", "]] .. width .. [[", "]] .. height .. [[", "10.0.22");
    swfObject.useExpressInstall("/expressinstall.swf");
    swfObject.setAttribute("style", "position:fixed;top:0;left:0;width:1024px;height:512px;z-index:99999;");
    swfObject.addParam("allowScriptAccess", "always");
    swfObject.addParam("allowFullscreen", "true");
    swfObject.addVariable("popout", "true");
    swfObject.addVariable("plugins", "1");
    swfObject.addVariable("modes", 4);
    swfObject.addVariable("initMode", 4);
    swfObject.addVariable("sortBy", "");
    swfObject.addVariable("continuous_play_on", "false");
    swfObject.addVariable("st", ]] .. start .. [[);
    swfObject.addVariable("stage_width", "]] .. width .. [[");
    swfObject.addVariable("stage_height", "]] .. height .. [[");
    swfObject.write("player-container");
} else {
    document.body.innerHTML = 'Failure to detect ID.'
}
]]})
end)

--[=[list.Set("PlayXHandlers", "justin.tv", function(width, height, start, volume, adjVol, uri, handlerArgs, callback)
    volume = adjVol -- This handler supports instant volume changing

    local volumeFunc = function(volume)
        return [[
try {
  player.change_volume(]] .. volume .. [[);
} catch (e) {}
]]
    end

    callback(playxlib.HandlerResult{
        center = true,
        body = [[<div id="player-container"></div>]],
        js = [[
var player;
var actionInterval;
var script = document.createElement('script');
script.type = 'text/javascript';
script.src = 'http://www-cdn.justin.tv/javascripts/jtv_api.js';
script.onload = function () {
  document.body.style.textAlign = 'center';
  player = jtv_api.new_player("player-container", {channel: "]] .. playxlib.JSEscape(uri) .. [[", custom: true})
  actionInterval = setInterval(function() {
    if (player.play_live) {
      clearInterval(actionInterval);
      player.play_live("]] .. playxlib.JSEscape(uri) .. [[");
      player.change_volume(]] .. volume .. [[);
      var style = window.getComputedStyle(player, null);
      var width = parseInt(style.getPropertyValue("width").replace(/px/, ""));
      var height = parseInt(style.getPropertyValue("height").replace(/px/, ""));
      var useHeight = ]] .. height .. [[;
      var useWidth = ]] .. height .. [[ * width / height;
      player.style.width = useWidth + 'px';
      player.style.height = useHeight + 'px';
      player.resize_player(useWidth, useHeight);
    }
  }, 100);
}
document.body.appendChild(script);
]],
        volumeFunc = volumeFunc})
end)]=]

list.Set("PlayXHandlers", "justin.tv", function(width, height, start, volume, adjVol, uri, handlerArgs, callback)
    volume = adjVol -- This handler supports instant volume changing

    local volumeFunc = function(volume)
        return [[
try {
  live_embed_player_flash.volume =]] .. (volume / 2).. [[;
} catch (e) { console.log(e.message) }
]]
    end -- Danking fix
    callback(playxlib.HandlerResult{
        center = true,
        body = [[
<object type="application/x-shockwave-flash"
        height="]]..height..[["
        width="]]..width..[["
        id="live_embed_player_flash"
        data="http://www.justin.tv/widgets/live_embed_player.swf?channel=]]..uri..[["
        bgcolor="#000000">
  <param  name="allowFullScreen"
          value="true" />
  <param  name="allowScriptAccess"
          value="always" />
  <param  name="allowNetworking"
          value="all" />
  <param  name="movie"
          value="http://www.justin.tv/widgets/live_embed_player.swf" />
  <param  name="flashvars"
          value="hostname=www.justin.tv&channel=]]..uri..[[&auto_play=true&start_volume=]] .. (volume / 2) .. [[" />
</object>]],
        volumeFunc = volumeFunc})
end)
list.Set("PlayXHandlers", "twitch.tv", function(width, height, start, volume, adjVol, uri, handlerArgs, callback)
    volume = adjVol -- This handler supports instant volume changing

    local volumeFunc = function(volume)
        return [[
try {
  live_embed_player_flash.volume =]] .. (volume / 2).. [[;
} catch (e) { console.log(e.message) }
]]
    end -- Danking fix
    callback(playxlib.HandlerResult{
        center = true,
        body = [[
<object type="application/x-shockwave-flash"
        height="]]..height..[["
        width="]]..width..[["
        id="live_embed_player_flash"
        data="http://www.twitch.tv/widgets/live_embed_player.swf?channel=]]..uri..[["
        bgcolor="#000000">
  <param  name="allowFullScreen"
          value="true" />
  <param  name="allowScriptAccess"
          value="always" />
  <param  name="allowNetworking"
          value="all" />
  <param  name="movie"
          value="http://www.twitch.tv/widgets/live_embed_player.swf" />
  <param  name="flashvars"
          value="hostname=www.twitch.tv&channel=]]..uri..[[&auto_play=true&start_volume=]] .. (volume / 2) .. [[" />
</object>]],
        volumeFunc = volumeFunc})
end)


list.Set("PlayXHandlers", "YouTubePopup", function(width, height, start, volume, adjVol, uri, handlerArgs, callback)

    local volumeFunc = function(volume)
        return [[try {
  document.getElementById('video-player-flash').setVolume(]] .. volume .. [[);
} catch (e) {}
try {
  document.getElementsByClassName("video-stream")[0].volume = ((]] .. volume .. [[)/100);
} catch (e) {}
]]
    end
    callback(playxlib.HandlerResult{
        url = "http://www.youtube.com/watch_popup?v=" .. playxlib.JSEscape(uri)
    ..'&autoplay=1&autohide=1&disablekb=1&enablejsapi=1&version=3&start='..(start or 0),
        center = false,
        volumeFunc = volumeFunc,
        js = [[
var knownState = "Loading...";
var player;

function sendPlayerData(data) {
    var str = "";
    for (var key in data) {
        str += encodeURIComponent(key) + "=" + encodeURIComponent(data[key]) + "&"
    }
}

function onError(err) {
  var msg;

  if (err == 2) {
    msg = "Error: Invalid media ID";
  } else if (err == 100) {
    msg = "Error: Media removed or now private";
  } else if (err == 101 || err = 150) {
    msg = "Error: Embedding not allowed";
    msg = "Buffering...";
  } else {
    msg = "Unknown error: " + err;
  }

  knownState = msg;

  sendPlayerData({ State: msg });
}

function onPlayerStateChange(state) {
  var msg;

  if (state == -1) {
    msg = "Loading...";
  } else if (state == 0) {
    msg = "Playback complete.";
  } else if (state == 1) {
    msg = "Playing...";
  } else if (state == 2) {
    msg = "Paused.";
  } else if (state == 3) {
    msg = "Buffering...";
  } else {
    msg = "Unknown state: " + state;
  }

  knownState = msg;

  sendPlayerData({ State: msg, Position: player.getCurrentTime(), Duration: player.getDuration() });
}

function updateState() {
  sendPlayerData({ Title: "test", State: knownState, Position: player.getCurrentTime(), Duration: player.getDuration() });
}

yt.embed.onPlayerReady = function() {
  player = document.getElementById('video-player-flash');
  player.addEventListener('onStateChange', 'onPlayerStateChange');
  player.addEventListener('onError', 'onError');
  player.setVolume(]] .. volume .. [[);
  setInterval(updateState, 250)
}
]]})
end)

list.Set("PlayXHandlers", "WebM", function(width, height, start, volume, adjVol, uri, handlerArgs, callback)
    local result = playxlib.HandlerResult{
        body = [[
        <video id="video" width="]] .. width ..
        [[" height="]] .. height ..
        [[" onPlay="currentTime=]] .. start ..
        [[,volume=]] .. string.format("%.2f",volume/100) ..
        [[" autoplay loop>

        <source src="]] .. uri .. [[" type="video/webm">
        </video>
        ]],
        css = [[
        *{margin:0;}
        ]],
    }

    result.GetVolumeChangeJS = function(volume)
        return [[video.volume=]]..string.format("%.2f",volume/100)
    end

    return callback(result)
end)

list.Set("PlayXHandlers", "dailymotion", function(width, height, start, volume, adjVol, uri, handlerArgs, callback)
	local videoURL = string.match(uri, "^http://www.dailymotion.com/video/([^%?]+)") or ""
	local result = playxlib.HandlerResult{
		body = [[<div id="player"></div>]],
		css = [[
		*{margin:0;}
		]],
		js = [[
				(function() {
					var e = document.createElement('script'); e.async = true;
					e.src = 'http://api.dmcdn.net/all.js';
					document.body.appendChild(e);
				}());

				// This function init the player once the SDK is loaded
				var interval = setInterval(function()
				{
					if(player.skipAd)
					{
						player.skipAd();
					}
					if(player._trigger)
					{
						console.log("A");
					}
				},100);
				window.dmAsyncInit = function()
				{
					// PARAMS is a javascript object containing parameters to pass to the player if any (eg: {autoplay: 1})
					var player = DM.player("player", {video: "]]..videoURL..[[", width: "]]..width..[[", height: "]]..height..[[", params: {autoplay:1}});

					// 4. We can attach some events on the player (using standard DOM events)
					player.addEventListener("apiready", function(e)
					{
						e.target.seek(]]..start..[[);
						e.target.volume(]]..volume..[[);
					});
					player.addEventListener("play", function(e)
					{
						e.target.seek(]]..start..[[);
						e.target.volume(]]..volume..[[);
						clearInterval(interval);
					});
				}
			
		]]
	}

	result.GetVolumeChangeJS = function(volume)
		return [[
				player = document.getElementById("player");
				player.volume(]]..volume..[[);]]
	end

   return callback(result)
end)
local function httpGet3(url, func)
	local t = vgui.Create("DHTML")
	t:AddFunction("gmod","return", function(a, b, c)
		t:Remove()
		timer.Simple(0, function()
			func((a or "") .. " " .. (b or "") .. " " .. (c or ""))
		end)
	end)
	t:AddFunction("gmod","loaded", function(a, b, c)
		LocalPlayer():ChatPrint("Loading... You may hear the player in the background!")
		timer.Simple(12, function()
			t:RunJavascript([[
				gmod.return(document.getElementsByTagName('html')[0].innerHTML)
				document.innerHTML = "";
			]])
		end)
	end)
	t:QueueJavascript([[gmod.loaded()]])
	t:SetPos(ScrW() + 1, ScrH() + 1)
	t:OpenURL(url)
	
	timer.Simple(38, function()
		t:Remove()
	end)
end
local alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/='
local lookup = nil
local function fromUTF8(s)
	if not lookup then
		lookup = {}
		for I=1,#alphabet do
			lookup[string.byte(alphabet[I])] = I - 1
		end
	end
	local buffer = {}
	local enc = {}
	local I = 1
	while(I <= #s) do
		
		enc[1] = lookup[string.byte(s[I])]
		I = I + 1
		enc[2] = lookup[string.byte(s[I])]
		table.insert(buffer, bit.bor(bit.lshift(enc[1], 2), bit.rshift(enc[2], 4)))
		I = I + 1
		enc[3] = lookup[string.byte(s[I])]
		if enc[3] == 64 then break end
		table.insert(buffer, bit.bor(bit.lshift(bit.band(enc[2], 15), 4), bit.rshift(enc[3], 2)))
		I = I + 1
		enc[4] = lookup[string.byte(s[I])]
		if enc[4] == 64	 then break end
		table.insert(buffer, bit.bor(bit.lshift(bit.band(enc[3], 3), 6), enc[4]))
			
		I = I + 1
	end
	
	return buffer
end

local function wrap(str)
	local output = ""
	local buf = fromUTF8(str)
	--PrintTable(buf)
	local I = 1
	while(I < #buf) do
		if buf[I] < 128 then
			output = output .. string.char(buf[I])
			I = I + 1
		elseif buf[I] > 191 and buf[I] < 224 then
			
			I = I + 2
		elseif true then
			I = I + 3
		end
		
	end
	return output
end
