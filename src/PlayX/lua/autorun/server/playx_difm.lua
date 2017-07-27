local function Play(ply, provider, uri, lowFramerate)
    local instance = PlayX.GetInstance(ply)

    if not PlayX.IsPermitted(ply, instance) then
        ply:ChatPrint("NOTE: You are not permitted to control the player")
        return
    end

	if(PlayXQueue~=nil) then
		if(PlayXQueue.IsCinema ~= nil and instance and instance:IsValid() and PlayXQueue.IsCinema(instance)) then
			--PlayXQueue.QueueVideo(instance, ply, uri)
			ply:ChatPrint("NOTE: You are not permitted to control the player")
			return
		end
	end
    if not instance then
        ply:ChatPrint("NOTE: No PlayX player is spawned!")
    else
		provider = PlayX.ResolveProvider(provider,uri,false)
		if(provider~="SoundCloud") then
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

--Play(me,"MP3","http://pub6.di.fm:80/di_electrohouse",false)




local cacheds={}
local function CommencePlay(pl,line,chan)
	PrintMessage(3,"["..(chan.title or chan.name or "??").." | "..tostring(chan.lastPlaying).."] ".."http://somafm.com/"..tostring(chan.id))
	if not pl:IsValid() then return end
	
	local mp3url = chan.dat
	Play(pl,"MP3",mp3url,false)
end
local function ParsePLS(dat)
	local t={}
	for str in dat:gmatch'File%d+=([^\r^\n]+)' do
		if str:find"http://" then
			table.insert(t,str:Trim())
		end
	end
	assert(#t>0)
	return table.Random(t)
end
local function UseThisPlaylist(pl,line,radiochan)
	if cacheds[radiochan] then
		return CommencePlay(pl,line,radiochan)
	else
		
		local function GotPlaylist(dat,len,hdr,code)
			cached = nil
			if code~=200 then
				print("DI FM paylist Fail",code)
				return
			end
			radiochan.dat = ParsePLS(dat)
			cacheds[radiochan] = true
			CommencePlay(pl,line,radiochan)
		end
		local url
		for k,playlist in next,radiochan.playlists do
			if playlist.format=="mp3" then
				url = playlist.url
			end
		end
		cached = false
		http.Fetch(url,GotPlaylist,function(err)
			GotPlaylist(nil,nil,nil,err)
		end)
	end
end

local cached
local function StartParsingChannels(pl,line)
	for k,chan in next,cached do
		local name = chan.id or ""
		if name:lower()==line:lower() then
			UseThisPlaylist(pl,line,chan)
			return
		end
	end
	for k,chan in next,cached do
		local name = chan.title
		if name:lower():find(line:lower(),1,true) then
			UseThisPlaylist(pl,line,chan)
			return
		end
	end
	for k,chan in next,cached do
		local name = chan.description
		if name:lower():find(line:lower(),1,true) then
			UseThisPlaylist(pl,line,chan)
			return
		end
	end
end
timer.Simple(0,function()
	aowl.AddCommand({"di","soma"},function(pl,line)
		if cached then
			if cached==true then return end
			return StartParsingChannels(pl,line)
		elseif cached==nil then
			
			local function GotPlaylist(dat,len,hdr,code)
				cached = nil
				if code~=200 then
					print("DI FM Fail",code)
					return
				end
				dat = json.decode(dat)
				cached = dat and dat.channels or true
				if not cached or cached==true then return end
				StartParsingChannels(pl,line)
			end
			cached = false
			http.Fetch("http://somafm.com/channels.json",GotPlaylist,function(err)
				GotPlaylist(nil,nil,nil,err)
			end)
		end
	end)
end)