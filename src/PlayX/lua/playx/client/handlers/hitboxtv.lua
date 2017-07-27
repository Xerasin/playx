list.Set("PlayXHandlers", "hitbox.tv", function(width, height, start, volume, adjVol, uri, handlerArgs, callback)
    volume = adjVol
    local result = playxlib.GenerateIFrame(width, height, uri)
    
    result.GetVolumeChangeJS = function(volume)
        return [[
            var api = flowplayer();
            api.setVolume(]] .. tostring(volume) .. [[);
        ]]
    end

    callback(result)
end)