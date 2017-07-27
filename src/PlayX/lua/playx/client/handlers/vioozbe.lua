list.Set("PlayXHandlers", "vioozbe", function(width, height, start, volume, adjVol, uri, handlerArgs, callback)
	local js = [[
		var e = document.getElementById("container_wrapper")
		var t = e && e.children[0];
        if (t) {
            document.body.style.setProperty("overflow", "hidden");
            t.style.setProperty("z-index", "99999");
            t.style.setProperty("position", "fixed");
            t.style.setProperty("top", "0");
            t.style.setProperty("left", "0");
            t.width = "100%";
            t.height = "105%";
            this.player = t;
            var interval;
			interval = setInterval(function() {
				try
				{
					var t = this.player.jwGetState();
					if (t === "PLAYING")
	                {
	                	clearInterval(interval)
	                	return;
	                }
	                if (t !== "BUFFERING") {
	                    this.player.jwSeek(]]..start..[[)
	                }
	                if (t === "IDLE") {
	                	this.player.jwSetVolume(]]..volume..[[)
	                    this.player.jwPlay()
	                }
	                if (t === "PLAYING")
	                {
	                	clearInterval(interval)
	                }
	      		}
	      		catch(e)
	      		{
	      		}
                
			}, 100)	
        }
	]]
	local result = playxlib.HandlerResult(nil, js, nil, nil, false, uri)
	result.GetVolumeChangeJS = function(volume)
		return [[
			try {
				var e = document.getElementById("container_wrapper"),
				t = e && e.children[0];
				if (t) {
					t.jwSetVolume(]]..volume..[[);
				}
			} catch(e) {}
		]]
	end
	callback(result)
end)

list.Set("PlayXHandlers", "viooz", function(width, height, start, volume, adjVol, uri, handlerArgs, callback)
	local js = [[
		var e = document.getElementById("flashstream")
		var t = e && e.children[4];
        if (t) {
            document.body.style.setProperty("overflow", "hidden");
            t.style.setProperty("z-index", "99999");
            t.style.setProperty("position", "fixed");
            t.style.setProperty("top", "0");
            t.style.setProperty("left", "0");
            t.width = "100%";
            t.height = "105%";
            this.player = t;
            var interval;
			interval = setInterval(function() {
				try
				{
					var t = this.player.jwGetState();
					if (t === "PLAYING")
	                {
	                	clearInterval(interval)
	                	return;
	                }
	                if (t !== "BUFFERING") {
	                    this.player.jwSeek(]]..start..[[)
	                }
	                if (t === "IDLE") {
	                	this.player.jwSetVolume(]]..volume..[[)
	                    this.player.jwPlay()
	                }
	                if (t === "PLAYING")
	                {
	                	clearInterval(interval)
	                }
	      		}
	      		catch(e)
	      		{
	      		}
                
			}, 100)	
        }
	]]
	local result = playxlib.HandlerResult(nil, js, nil, nil, false, uri)
	result.GetVolumeChangeJS = function(volume)
		return [[
			try {
				var e = document.getElementById("flashstream"),
				t = e && e.children[4];
				if (t) {
					t.jwSetVolume(]]..volume..[[);
				}
			} catch(e) {}
		]]
	end
	callback(result)
end)