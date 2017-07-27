local function bassHandler(width, height, start, volume, adjVol, uri, handlerArgs, callback)
	local result = playxlib.GenerateIFrame(width, height, "http://playx.xeras.in/host.html")

	sound.PlayURL ( uri, "noblock noplay", function( station )
		if not IsValid( station ) then return end

		-- No need to return JS, can still use it to change volume
		result.GetVolumeChangeJS = function(volume)
			if IsValid(station) then
				station:SetVolume(volume/100)
			end
		end

		-- Temporary ID for the Bass handle
		local r = math.random()

		local function play(ent)
			if not (IsValid(ent) and (ent.Media.URI .. r) == (uri .. r)) then return end
			hook.Remove("PlayXPlayed", uri .. r)

			-- Use entity index from now on
			local ei = ent:EntIndex()

			station:SetVolume(math.Clamp(GetConVar("playx_volume"):GetFloat() / 100, 0, 1))

			-- Stopsound detection
			local function ssdetect()
				if station:GetState() == GMOD_CHANNEL_STOPPED then
					station:Play()
				end
			end

			-- Sync Bass to PlayX
			if start == 0 or station:GetLength() < 0 then
				station:Play()
				hook.Add("Think", uri .. ei, ssdetect)
			else
				station:SetTime(start)
				if station:GetTime() < (start-1) then
					local pt = CurTime()
					local function sync()
						local nt = CurTime()
						station:SetTime(start+nt-pt)
						if station:GetLength() < start+nt-pt-1 then
							hook.Add("Think", uri .. ei, ssdetect)
							return
						end
						if station:GetTime() < start+nt-pt-1 then return end
						station:Play()
						hook.Add("Think", uri .. ei, ssdetect)
					end
					hook.Add("Think", uri .. ei, sync)
				else
					station:Play()
					hook.Add("Think", uri .. ei, ssdetect)
				end
			end

			-- Make sure we are stopping the right Bass handle
			local function stop(ent)
				ent = type(ent) == "Entity" and (IsValid(ent) and ent:EntIndex()) or ent
				if not (ei == ent) then return end
				station:Stop()
				hook.Remove("PlayXStopped",uri .. ei)
				hook.Remove("PlayXMediaEnded",uri .. ei)
				hook.Remove("Think", uri .. ei)
			end

			hook.Add("PlayXStopped",uri .. ei,stop)
			hook.Add("PlayXMediaEnded",uri .. ei,stop)
		end

		-- The callback will call the PlayXPlayed hook
		hook.Add("PlayXPlayed", uri .. r, play)
		callback(result)
	end)
end

list.Set("PlayXHandlers", "bassurl", bassHandler)