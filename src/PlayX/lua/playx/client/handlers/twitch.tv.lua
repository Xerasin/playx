list.Set("PlayXHandlers", "twitch.tv", function(width, height, start, volume, adjVol, uri, handlerArgs, callback)
        local url = "http://gcinema.xerasin.com/twitch.php?channel="..uri.."&t="..tostring(math.floor(start)).."&vol="..tostring(volume) .. "&paused=" .. (paused and 1 or 0)
        local result = playxlib.GenerateIFrame(width, height, url)
        result.GetVolumeChangeJS = function(volume)
                return [[
                        player.setVolume(]]..tostring(volume)..[[);]]
        end
        result.PlayPause = function(paused)
                return paused and [[
                        player.pause();
                ]] or [[
                        player.play();
                ]]
        end
        callback(result)
end)