properties.Add( "playxsub", {
	
	MenuLabel = "#Toggle subscribe",
	Order = 999,
	MenuIcon = "icon16/film.png",
	
	Filter = function( self, ent, ply )
		
		return ent and ent:IsValid() and ent:GetClass():find("playx",1,true)
		
	end,
	
	Action = function( self, ent )
		
		self:MsgStart()
		net.WriteEntity( ent )
		self:MsgEnd()
		
	end,
	
	Receive = function( self, length, pl )
		
		local ent = net.ReadEntity()
		if ( !self:Filter( ent, pl ) ) then return end
		
		if ent:IsSubscribed( pl ) then
			ent:Unsubscribe( pl )
		else
			ent:Subscribe( pl )
		end
		
	end
})
