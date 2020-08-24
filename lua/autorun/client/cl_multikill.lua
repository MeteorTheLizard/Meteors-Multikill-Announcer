--Made by MrRangerLP

if CLIENT then
	net.Receive("MMM_Multkill_Announcer",function()
		local iAnnouncer = net.ReadUInt(32)
		if not isnumber(iAnnouncer) then return end
		local iNumber = net.ReadUInt(32)
		if not isnumber(iNumber) then return end

		surface.PlaySound("meteorsmultikill/" .. tostring(iAnnouncer) .. "/announcer" .. tostring(iNumber) .. ".ogg")
	end)
end