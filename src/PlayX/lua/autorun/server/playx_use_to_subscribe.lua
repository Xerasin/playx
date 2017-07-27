local function TogglePlayX(ent,pl)
    local ret
    if ent:IsSubscribed(pl) then
		ret=ent:Unsubscribe(pl)
    else
		ret=ent:Subscribe(pl)
    end
	pl:ChatPrint( ent:IsSubscribed(pl) and "Subscribed" or "Unsubscribed" )
end

concommand.Add('playx_kill',function(pl)
	for k,ent in pairs(PlayX.GetInstances()) do
		if ent:IsSubscribed(pl) then
			ent:Unsubscribe(pl)
		end
	end
end)

hook.Add("PlayXUse","multiplayx",function( ent, ply, ply2)
	local pl=IsValid(ply) and ply or IsValid(ply2) and ply2
	if not pl then return end
	TogglePlayX( ent , pl )
end)

hook.Add("PlayXRepeaterUse","multiplayx",function(ent,ply,ply2)
	local pl=IsValid(ply) and ply or IsValid(ply2) and ply2
	if not pl then return end
	TogglePlayX(ent,ply)
end)

hook.Add("PlayXShouldAutoSubscribe", "multiplayx", function(ply, instance)
	return false  -- no more autosubscribing
end)

-- otherwise playx selects the closest
hook.Add("PlayXSelectInstance","multiplayx",function(pl)
	local pos=pl:GetPos()
	local ent=pl:GetEyeTrace().Entity
	ent=IsValid(ent) and table.HasValue(PlayX.GetInstances(),ent) and ent
	if ent then return ent end
end)

