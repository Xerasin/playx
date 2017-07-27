local lastResult = nil

local function UnHTMLEncode(s)
    -- Warning: Improper
    s = s:gsub("&lt;", "<")
    s = s:gsub("&gt;", ">")
    s = s:gsub("&quot;", "\"")
    s = s:gsub("&#34;", "'")
    s = s:gsub("&amp;", "&")
    return s
end

local function URLEncode(s)
    s = tostring(s)
    local new = ""

    for i = 1, #s do
        local c = s:sub(i, i)
        local b = c:byte()
        if (b >= 65 and b <= 90) or (b >= 97 and b <= 122) or
            (b >= 48 and b <= 57) or
            c == "_" or c == "." or c == "~" then
            new = new .. c
        else
            new = new .. string.format("%%%X", b)
        end
    end

    return new
end

local function URLEncodeTable(vars)
    local str = ""

    for k, v in pairs(vars) do
        str = str .. URLEncode(k) .. "=" .. URLEncode(v) .. "&"
    end

    return str:sub(1, -2)
end

local function FindMatch(str, patterns)
    for _, pattern in pairs(patterns) do
        local m = {str:match(pattern)}
        if m[1] then return m end
    end

    return nil
end

local function SearchYouTube(q, successF, failureF)
    local vars = URLEncodeTable{
        ["q"] = q,
        ["orderby"] = "relevance",
        ["maxResults"] = "1",
        ["part"] = "snippet",
		["type"] = "video",
        ["key"] = "AIzaSyAOXYJd-KlRB1thyjdifdsD9PCW_GrwsfU"
    }

    local url = "https://www.googleapis.com/youtube/v3/search?" .. vars

    http.Fetch(url, function(json)
        local queryTable = util.JSONToTable(json)
        if queryTable and queryTable.items and queryTable.items[1] and queryTable.items[1].id then
            return successF( queryTable.items[1].id.videoId,queryTable.items[1].snippet.title )
        end
        failureF( "No results found on YouTube query." )
    end)
end

local function Play(ply, provider, uri, lowFramerate)
    local instance = PlayX.GetInstance(ply)

    if not PlayX.IsPermitted(ply, instance) then
        ply:ChatPrint("NOTE: You are not permitted to control the player")
        return
    end

	if(PlayXQueue~=nil) then
		if(PlayXQueue.IsCinema ~= nil and instance and instance:IsValid() and PlayXQueue.IsCinema(instance)) then
			PlayXQueue.QueueVideo(instance, ply, uri)
			return
		end
	end
    if not instance then
        ply:ChatPrint("NOTE: No PlayX player is spawned!")
    else
		provider = PlayX.ResolveProvider(provider,uri,false)
		if(provider == "KissAnime" or provider == "KissCartoon") then
			list.Get("PlayXProviders")[provider].QueryMetadata(uri,function(tab)
				local result, err = instance:OpenMedia(provider,tab["URL2"],0,lowFramerate, true, ply)
				if not result then
					ply:ChatPrint(err)
				end
			end)
		elseif(provider~="SoundCloud") then
			local result, err = instance:OpenMedia(provider, uri, 0, lowFramerate, true, ply)
			if not result then
				ply:ChatPrint(err)
			end
		else
			list.Get("PlayXProviders")["SoundCloud"].QueryMetadata(uri,function(tab)
				local result, err = instance:OpenMedia(provider,tab["URL"],0,lowFramerate, true, ply)
				if not result then
					ply:ChatPrint(err)
				end
			end)
		end
    end
end

local function MediaPlayerPlay(ply, ent, url)
    local player = MediaPlayer.GetByObject(ent)
    if player then
        local media = MediaPlayer.GetMediaForUrl( url, true )
        media:NetReadRequest()

        player:RequestMedia( media, ply )
    end
end

local function GrabID(uri)
    local m = FindMatch(uri, {
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

local mediaplayer_ents = {"mediaplayer_tv", "theater_screen"}

hook.Add("PlayerSay", "PlayXMediaQueryPlayerSay", function(ply, text, all, death)

    text = text:TrimRight()

    local m = FindMatch(text, {
        "^[!%.](yt) (.+)",
        "^[!%.](ytplay) (.+)",
        "^[!%.](ytplay)",
        "^[!%.](ytlisten) (.+)",
        "^[!%.](ytlisten)",
        "^[!%.](ytlast)",
    })

    if m then
        if m[1] == "yt" or (m[1] == "ytplay" and m[2]) or (m[1] == "ytlisten" and m[2]) then
			m[2] = GrabID(m[2]) or m[2]
            local function successF(videoID, title)
                lastResult = videoID
                if m[1] ~= "yt" then -- Play
                    local mp
                    for _, ent in next, ents.GetAll() do
                        if table.HasValue(mediaplayer_ents, ent:GetClass()) and table.HasValue(MediaPlayer.GetByObject(ent)._Listeners, ply) then
                            mp = ent
                            break
                        end
                    end
                    if mp then
                        MediaPlayerPlay(ply, mp, "http://www.youtube.com/watch?v="..videoID)
                    else
    					local instance = PlayX.GetInstance(ply)
    					if(PlayXQueue~=nil) then
    						if(PlayXQueue.IsCinema ~= nil and instance and instance:IsValid() and PlayXQueue.IsCinema(instance)) then
    							PlayXQueue.QueueVideo(instance,ply,"http://www.youtube.com/watch?v="..videoID)

    							if DarkRP then
    								for k, v in pairs(ents.FindInSphere(instance:GetPos(), 768)) do
    									if v:IsPlayer() then
    										DarkRP.talkToPerson(v, Color(255, 0, 0), "[YouTube]", Color(200, 255, 0), string.format("%s ( http://www.youtube.com/watch?v=%s )", title, videoID), ply)
    									end
    								end
    							end

    							return
    						end
    					end
                        Play(ply, "YouTube", videoID, m[1] == "ytlisten")
                    end
                end

                if not DarkRP then
					for _, v in pairs(player.GetAll()) do
						v:ChatPrint(string.format("[YouTube] %s ( http://www.youtube.com/watch?v=%s )",
												  title, videoID))
					end
				end


            end

            local function failureF(msg)
                ply:ChatPrint(string.format("[YouTube] No results for %s, sorry about that :\\", msg))
            end

            SearchYouTube(m[2], successF, failureF)
        elseif m[1] == "ytplay" or m[1] == "ytlisten" or m[1] == "ytlast" then -- Play last
            if lastResult then
                local mp
                for _, ent in next, ents.GetAll() do
                    if table.HasValue(mediaplayer_ents, ent:GetClass()) and table.HasValue(MediaPlayer.GetByObject(ent)._Listeners, ply) then
                        mp = ent
                        break
                    end
                end
                if mp then
                    MediaPlayerPlay(ply, mp, "http://www.youtube.com/watch?v="..lastResult)
                else
    				local instance = PlayX.GetInstance(ply)
    				if(PlayXQueue~=nil) then
    					if(PlayXQueue.IsCinema ~= nil and instance and instance:IsValid() and PlayXQueue.IsCinema(instance)) then
    						PlayXQueue.QueueVideo(instance,ply,lastResult)
    						return
    					end
    				end
                    Play(ply, "YouTube", lastResult, m[1] == "ytlisten")
                end
            else
                ply:ChatPrint("ERROR: No last result exists!")
            end
        end

        return nil
    end

    local m = FindMatch(text, {
        "^[!%.]play (.+) (.+)",
        "^[!%.]link (.+) (.+)",
        "^[!%.]playx (.+) (.+)",
    })

    if m then
        Play(ply, m[1], m[2], false)

        return nil
    end

    local m = FindMatch(text, {
        "^[!%.]play (.+)",
        "^[!%.]link (.+)",
        "^[!%.]playx (.+)",
    })

    if m then
        Play(ply, "", m[1], false)

        return nil
    end

	local m = FindMatch(text, {
        "^[!%.]kiss (.+)",
        "^[!%.]kissanime (.+)",
        "^[!%.]kisscartoon (.+)",
    })
	if m then
        Play(ply, "", m[1], false)

        return nil
    end

    local m = FindMatch(text, {
        "http[s]?://youtube%.com/watch%?.*v=([A-Za-z0-9_%-]+)",
        "http[s]?://[A-Za-z0-9%.%-]*%.youtube%.com/watch%?.*v=([A-Za-z0-9_%-]+)",
        "http[s]?://[A-Za-z0-9%.%-]*%.youtube%.com/v/([A-Za-z0-9_%-]+)",
        "http[s]?://youtube%-nocookie%.com/watch%?.*v=([A-Za-z0-9_%-]+)",
        "http[s]?://[A-Za-z0-9%.%-]*%.youtube%-nocookie%.com/watch%?.*v=([A-Za-z0-9_%-]+)",
    })

    if m then
        lastResult = m[1]

        local function successF(videoID, title)
            lastResult = videoID

            for _, v in pairs(player.GetAll()) do
                v:ChatPrint(string.format("YouTube video %s: \"%s\"",
                                          videoID, title))
            end
        end

        SearchYouTube(m[1], successF, function() end)

        return nil
    end

    local m = FindMatch(text, {
        "^[!%.]webpage (.+)",
        "^[!%.]http (.+)",
        "^[!%.]web (.+)",
    })

    if m then
        Play(ply, "StaticWeb", m[1], false)

        return nil
    end


    return nil
end)