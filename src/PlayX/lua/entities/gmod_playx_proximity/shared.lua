ENT.Type = "anim"
ENT.Base = "gmod_playx"

ENT.PrintName = "PlayX Proximity Player"
ENT.Author = "Someone"
ENT.Contact = ""
ENT.Purpose = "Internet media player with proximity"
ENT.Instructions = "Spawn one, and then use the spawn menu."
ENT.Category = "PlayX"
ENT.WireDebugName = "PlayX Proximity Player"

ENT.Spawnable = true
ENT.AdminSpawnable = true

local Tag="gmod_playx_proximity"

list.Add("PlayXScreenClasses", Tag)

local playx_volume_distance = CLIENT and CreateClientConVar("playx_volume_distance","1",true,false)
local playx_proximity_enable = CLIENT and CreateClientConVar("playx_proximity_enable","1",true,false)

if SERVER then
	util.AddNetworkString(Tag)
	net.Receive(Tag,function(len,pl)
		local ent=net.ReadEntity()
		if not IsValid(ent) then return end
		if ent.Base ~= "gmod_playx" then return end
		
		local what=net.ReadUInt(8)
		if what==1 then
			ent:Subscribe(pl,true)
		elseif what==0 then
			ent:Unsubscribe(pl,true)
		end
	end)
else

	function ENT:SendSub(num)
		net.Start(Tag)
			net.WriteEntity(self)
			--net.WriteDouble(num)
			net.WriteUInt(num,8)
		net.SendToServer()
	end
		
		
	function ENT:Subscribe()
		if self._unsub_timeout then
			Msg"[PlayX] " print("Cancelling unsubscribe on",self)
			hook.Run("PlayXTimedUnsubscribe",self,false)
			self._unsub_timeout = false
		end
		if self._subbed then return end

		self._subbed = true
		self:SendSub(1)
	end
	
	function ENT:_Unsubscribe()
		
		if not self._subbed then return end

		self._subbed = false
		self:SendSub(0)
		
	end
	
	function ENT:Unsubscribe()
		if not self._subbed then return end
		
		local now = RealTime()
		
		local timeout = self._unsub_timeout
		if not timeout then
			timeout = now + 10
			Msg"[PlayX] " print("Unsubscribing from",self)
			hook.Run("PlayXTimedUnsubscribe",self,true)
			self._unsub_timeout = timeout
		end
		
		if timeout < now then
			self._unsub_timeout = false
			hook.Run("PlayXTimedUnsubscribe",self,nil)
			self:_Unsubscribe()
		end
		
	end
			
	--TODO: cvar
	local cutoff,maxd,mind=1500,1024,128
	function ENT:Think()
		self.BaseClass.Think(self)
		local ep=LocalPlayer():GetPos()
		local dist=self:GetPos():Distance(ep)
		local playx_proximity_enable = playx_proximity_enable:GetInt()
		local owner = self.CPPIGetOwner and self:CPPIGetOwner()
		if playx_proximity_enable>0 and dist<cutoff then
			local cansub = playx_proximity_enable~=2 or (owner and owner:IsValid() and owner:IsPlayer() and owner:GetFriendStatus()=="friend")
			if cansub then
				self:Subscribe()
			end
			
			local vol= playx_volume_distance:GetBool() and ((maxd-dist+mind)/maxd) or 1
			vol=vol>1 and 1 or vol<0 and 0 or vol
			if self.__lastvol ~=vol then
				self.__lastvol = vol
				self:SetVolume(vol * (PlayX.GetVolume and PlayX.GetVolume() or 100))
			end
		else
			self:Unsubscribe()
		end
	end
end

cleanup.Register("gmod_playx_proximity")