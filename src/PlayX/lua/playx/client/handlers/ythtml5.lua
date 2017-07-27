local function GrabID(uri)
	local m = playxlib.FindMatch(uri, {
		"^http[s]?://youtube%.com/watch%?.*v=([A-Za-z0-9_%-]+)",
		"^http[s]?://youtu%.be/([A-Za-z0-9_%-]+)",
		"^http[s]?://[A-Za-z0-9%.%-]*%.youtube%.com/watch%?.*v=([A-Za-z0-9_%-]+)",
		"^http[s]?://[A-Za-z0-9%.%-]*%.youtube%.com/v/([A-Za-z0-9_%-]+)",
		"^http[s]?://youtube%-nocookie%.com/watch%?.*v=([A-Za-z0-9_%-]+)",
		"^http[s]?://[A-Za-z0-9%.%-]*%.youtube%-nocookie%.com/watch%?.*v=([A-Za-z0-9_%-]+)",
	})

	if m then
		return m[1]
	end
end

local function URLDecode(s)
	s = string.gsub(s, "+", " ")
	s = string.gsub(s, "%%(%x%x)", function (h)
			return string.char(tonumber(h, 16))
		end)
	return s
end

local function GGLDecode(s)
	return URLDecode(URLDecode(s)):gsub("\\u0026","&"):gsub("\\/","/")
end

local function CleanParams(s)
	local tt = {s=true}
	s = s:gsub("[^=^&^?]+=[^&]+", function(s)
		local r = s:match("[^=]+")
		if tt[r] then
			return ""
		end
		tt[r] = true
		return s
	end)
	return s
end

function playxlib.YTGetVideo(link, onsuccess, onfail)
	local id = GrabID(link)

	local function finalize(m,s)
		local res = ("%s&signature=%s"):format(CleanParams(m), s)
		return onsuccess and onsuccess(res)
	end

	local function decodeSignature(decdef, dechdf, decnam, m, sig)
		local p = vgui.Create("DHTML")
		local fun = ("%s%sgmod.getsig(%s('%s'));")
				:format( dechdf, decdef, decnam, sig )
		p:AddFunction("gmod","getsig", function(s)
			timer.Simple(0.01, function()
				p:Remove()
				finalize(m,s)
			end)
		end)
		p:QueueJavascript( fun )
	end

	local function getJSDecoder(m,sig,s)
		local decnam = s:match("%.sig||([%w%$]+)%(")
		if not decnam then
			return onfail and onfail("Couldn't find decipher function, try again?")
		end
		local decdef = s:match("function "..decnam.."%([^\\)]+%){[^}]+};")
		local dechnm = decdef:match(";([%w%$]+)%.")
		if not dechnm then
			return onfail and onfail("Couldn't find decipher helper object, try again?")
		end
		local dechdf = s:match(("var %s={.-};"):format(dechnm))
		return decodeSignature(decdef, dechdf, decnam, m, sig)
	end

	local function prepare(s)
		local script = s:match('"url_encoded_fmt_stream_map":"([^"]+)"') or ""
		local html5p = ("https://s.ytimg.com/yts/jsbin/%s/html5player.js?gt=%f")
						:format(s:match("(html5player%-([%w_%-]+))\\") or "", CurTime() )

		local m, sig
		for chunk in script:gmatch("([^,]+)") do
			if chunk:find("itag=43") then
				m = GGLDecode(chunk:match("url=([^\\]+)"))
				sig = chunk:match("s=([A-F0-9]+%.[A-F0-9]+)")
			end
		end

		if not m then
			return onfail and onfail("No suitable formats found")
		end

		http.Fetch(html5p, function(s) return getJSDecoder(m,sig,s) end)
	end

	local function tryDict(s)
		if s:match("use_cipher_signature=True") or s:match("status=fail") then
			http.Fetch(("http://youtube.com/watch?v=%s&gt=%f"):format(id, CurTime()), prepare)
			return
		end

		s = s:match("url_encoded_fmt_stream_map=([^&]+)")
		if not s then
			http.Fetch(("http://youtube.com/watch?v=%s&gt=%f"):format(id, CurTime()), prepare)
			return
		end

		local g = URLDecode(s)
		local m
		for uri in g:gmatch("url=([^,]+)") do
			if uri:match("itag%%3D43") then
				m = URLDecode(uri:match("[^&]+"))
			end
		end

		if not m then
			return onfail and onfail("No suitable formats found")
		end
		m = CleanParams(m)
		return onsuccess(m)
	end

	http.Fetch(("http://www.youtube.com/get_video_info?&video_id=%s&gt=%f"):format(id, CurTime()), tryDict)
end
local useHTML = CreateClientConVar( "playx_ytwebm", 1, true, false )

list.Set("PlayXHandlers", "moan", function(width, height, start, volume, adjVol, uri, handlerArgs, callback, thumbnail, paused)

	--if not useHTML:GetBool() then
		PlayX.Debug("playx_ytwebm is false, using JW.")
		local url = "http://gcinema.xerasin.com/playvideo.php?vid="..GrabID(uri).."&t="..tostring(math.floor(start)).."&vol="..tostring(volume)
		print(url)
		local result = playxlib.GenerateIFrame(width, height, url)
		result.GetVolumeChangeJS = function(volume)
			return [[
				player.setVolume(]]..tostring(volume)..[[);]]
		end
		callback(result)
	--end

	--[=[playxlib.YTGetVideo(uri, function(webm)
		local id = GrabID(uri)
		local poster = ""

		if id then
			poster = ('poster = "http://i3.ytimg.com/vi/%s/hqdefault.jpg"'):format(id)
		end

		local result = playxlib.HandlerResult{
			body = ([[
				<video id="video" width="%fpx" height="%fpx" %s onPlay="currentTime=%f;volume=%f;" autoplay>
					<source src="%s" type="video/webm">
				</video>
			]]):format(width, height, poster, start, volume/100, webm),

			css = "*{margin:0;padding:0;}"
		}

		-- Has to be outside for this to work
		result.GetVolumeChangeJS = function(volume)
			return ("video.volume=%.2f;"):format(volume/100)
		end

		return callback(result)
	end, function(s)
		PlayX.Debug(s)
		PlayX.Debug("No WebM found, falling back to JW.")
		local url = "http://gcinema.xerasin.com/playvideo.php?vid="..GrabID(uri).."&t="..tostring(math.floor(start)).."&vol="..tostring(volume)
		print(url)
		local result = playxlib.GenerateIFrame(width, height, url)
		result.GetVolumeChangeJS = function(volume)
			return [[
				player.setVolume(]]..tostring(volume)..[[);]]
		end
		callback(result)
	end)]=]
end)
