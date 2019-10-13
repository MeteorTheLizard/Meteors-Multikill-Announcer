--Made by MrRangerLP

if SERVER then
	resource.AddWorkshop("1659142161")

	local AoA = 15
	for a = 1,AoA,1 do
		for k = 0,9,1 do
			resource.AddFile("sound/meteorsmultikill/"..tostring(a).."/announcer"..tostring(k)..".ogg")
		end
	end

	mmkAnnouncer = CreateConVar("mmk_announcer",1,FCVAR_ARCHIVE,"Announcer System")
	mmkAnnouncerTime = CreateConVar("mmk_timeforkills",5,FCVAR_ARCHIVE,"Time inbetween kills before it resets")
	local WhichAnnouncer = 1; local TimeForKills = 5
	
	local MeteorsCallbackCreate = function(StrName,Func)
		cvars.RemoveChangeCallback(StrName,StrName .. "_callback")
		cvars.AddChangeCallback(StrName,function(var,old,new)
			Func()
		end,StrName .. "_callback")
	end
	
	MeteorsCallbackCreate("mmk_announcer",function() WhichAnnouncer = GetConVar("mmk_announcer"):GetInt() end)
	MeteorsCallbackCreate("mmk_timeforkills",function() TimeForKills = GetConVar("mmk_timeforkills"):GetInt() end)

	hook.Add("Tick","MMMAnnouncerInit",function()
		if GAMEMODE then
			WhichAnnouncer = GetConVar("mmk_announcer"):GetInt()
			TimeForKills = GetConVar("mmk_timeforkills"):GetInt()
			hook.Remove("Tick","MMMAnnouncerInit")
		end
	end)

	local TextOnScreen = {
		{"Has a DOUBLE KILL!","Has a TRIPLE KILL!","Has a ULTRA KILL!","Has a MONSTER KILL!","IS UNSTOPPABLE!!","IS GODLIKE!",".. HOLY S**T!"},
		{"Has a MULTI KILL!","Is on a KILLING SPREE!","Has a ULTRA KILL!","Has a MONSTER KILL!","IS UNSTOPPABLE!!","IS GODLIKE!",".. HOLY S**T!"},
		{"Has a DOUBLE KILL!","Has a TRIPLE KILL!","Has a QUADRUPLE KILL!","Has a QUINTUPLE KILL!","Has a SEXTUPLE KILL!","IS LEGENDARY!!"},
		{"Has a DOUBLE KILL!","Has a TRIPLE KILL!","Has a QUADRA KILL!","Has a PENTA KILL!","IS UNSTOPPABLE!!","IS IMMORTAL!!","IS GODLIKE!!!"},
		{"Has a DOUBLE KILL!","Has a TRIPLE KILL!","Has a QUADRA KILL!","AND THE GODS PROCLAIMED.. PENTA KILL!","IS UNSTOPPABLE!!","IS IMMORTAL!!","IS GODLIKE!!!"},
		{"Has a DOUBLE KILL!","Has a TRIPLE KILL!","Has a QUADRA KILL!","Has a PENTA KILL!","CANNOT BE STOPPED!","CAN CLEARLY DO BETTER!!","BURNS THEM ALL TO THE GROUND!!!"},
		{"Has a DOUBLE KILL!","Has a MULTI KILL!","Has a ULTRA KILL!","IS UNBELIEVEABLE!","LET THEM ALL COME!!","YOU WANT A PIECE OF ME?!!","Has WAY TO MUCH FUN!!!"},
		{"Has a DOUBLE KILL!","Has a MULTI KILL!","Has a ULTRA KILL!","IS UNBREAKABLE!","IS UNBELIEVEABLE","YOU WANT A PIECE OF ME?!!","Come and GET SOME!!"},
		{"Has a DOUBLE KILL!","Has a MULTI KILL!","Has a ULTRA KILL!","IS UNBREAKABLE!","IS UNBELIEVEABLE","YOU WANT A PIECE OF ME?!!","Come and GET SOME!!"},
		{"Has a DOUBLE KILL!","Has a MULTI KILL!","Has a ULTRA KILL!","Has a MONSTER KILL!","IS UNSTOPPABLE!!","IS GODLIKE!",".. IS UNHOLY!!"},
		{"Has a DOUBLE KILL!","Has a MULTI KILL!","Has a ULTRA KILL!","Has a MONSTER KILL!","IS UNSTOPPABLE!!","IS GODLIKE!",".. HOLY S**T!"},
		{"Has a DOUBLE KILL!","Has a TRIPLE KILL!","Has an OVERKILL!","IS KILLTACULAR!","IS A KILLTROCITY","IS KILLAMANJARO!!","IS A KILLTASTROPHE!!!","BROUGHT RAGNAROK UPON US","IS A KILLIONARE!!!"},
		{"Has a DOUBLE KILL!","Has a MULTI KILL!","Has a ULTRA KILL!","Has a MONSTER KILL!","IS UNSTOPPABLE!!","IS GODLIKE!",".. IS A WINNER BY NATURE!!"},
		{"Has a DOUBLE KILL!","Has a TRIPLE KILL!","Has a QUADRA KILL!","Has a PENTA KILL!!","Has a LEGENDARY KILL!!"},
		{"Has a DOUBLE KILL!","Has a MORE THAN 2 BUT LESS THAN 4 KILL!","Has a ULTRA KILL!","Has a MONSTER KILL!","IS UNSTOPPABLE!!","IS GODLIKE!","GABEN REFUSES TO READ","GABE PLS","HAS DISCOVERED YOUR SCAM"}
	}

	local SendToPlayers = function(Number)
		for k,v in pairs(player.GetAll()) do v:SendLua("surface.PlaySound(\"meteorsmultikill/"..tostring(WhichAnnouncer).."/announcer"..Number..".ogg\")") end
	end
	
	timer.Create("rzmMultikillAnnouncerTimer",1,0,function()
		for k,v in pairs(player.GetAll()) do
			if v.TimerNextKill and v.TimerNextKill > 0 then
				v.TimerNextKill = (v.TimerNextKill - 1)
			end
		end
	end)
	
	local TableAnnouncerN = {1,2,7,8,9,10,11,12,13}
	hook.Add("PlayerDeath","rzmMultikillAnnouncer",function(Target,Inflictor,Attacker)
		if not Target:IsPlayer() then return end
		if not Attacker:IsPlayer() then return end
		if Target == Attacker then Attacker.MultiKillPlyer = 0; Attacker.TimerNextKill = 0; return end
		
		timer.Simple(0.1,function()
			if not Attacker.MultiKillPlyer then Attacker.MultiKillPlyer = 0 end
			if Attacker.MultiKillPlyer > 0 and Attacker.TimerNextKill == 0 then Attacker.MultiKillPlyer = 0 end
			
			Attacker.TimerNextKill = TimeForKills
			Attacker.MultiKillPlyer = (Attacker.MultiKillPlyer + 1)

			if Target:LastHitGroup() == 1 then
				if Attacker.MultiKillPlyer == 1 and table.HasValue(TableAnnouncerN,WhichAnnouncer) then
					Attacker:PrintMessage(HUD_PRINTCENTER,"HEADSHOT!")
					Attacker:SendLua("surface.PlaySound(\"meteorsmultikill/"..tostring(WhichAnnouncer).."/announcer0.ogg\")")
				end
			end
			
			timer.Destroy("rzmAnnounceKills")
			timer.Create("rzmAnnounceKills",0.1,1,function()
				if (Attacker.MultiKillPlyer >= 10 and WhichAnnouncer == 12) or (Attacker.MultiKillPlyer >= 10 and WhichAnnouncer == 15)then
					PrintMessage(HUD_PRINTCENTER,Attacker:GetName().." "..TextOnScreen[WhichAnnouncer][9]); SendToPlayers("9")
				elseif (Attacker.MultiKillPlyer >= 9 and WhichAnnouncer == 12) or (Attacker.MultiKillPlyer >= 9 and WhichAnnouncer == 15) then
					PrintMessage(HUD_PRINTCENTER,Attacker:GetName().." "..TextOnScreen[WhichAnnouncer][8]); SendToPlayers("8")
				elseif Attacker.MultiKillPlyer >= 8 and WhichAnnouncer ~= 3 and WhichAnnouncer ~= 14 then
					PrintMessage(HUD_PRINTCENTER,Attacker:GetName().." "..TextOnScreen[WhichAnnouncer][7]); SendToPlayers("7")
				elseif Attacker.MultiKillPlyer >= 7 and WhichAnnouncer ~= 14 then
					PrintMessage(HUD_PRINTCENTER,Attacker:GetName().." "..TextOnScreen[WhichAnnouncer][6]); SendToPlayers("6")
				elseif Attacker.MultiKillPlyer >= 6 then
					PrintMessage(HUD_PRINTCENTER,Attacker:GetName().." "..TextOnScreen[WhichAnnouncer][5]); SendToPlayers("5")
				elseif Attacker.MultiKillPlyer >= 5 then
					PrintMessage(HUD_PRINTCENTER,Attacker:GetName().." "..TextOnScreen[WhichAnnouncer][4]); SendToPlayers("4")
				elseif Attacker.MultiKillPlyer >= 4 then
					PrintMessage(HUD_PRINTCENTER,Attacker:GetName().." "..TextOnScreen[WhichAnnouncer][3]); SendToPlayers("3")
				elseif Attacker.MultiKillPlyer >= 3 then
					PrintMessage(HUD_PRINTCENTER,Attacker:GetName().." "..TextOnScreen[WhichAnnouncer][2]); SendToPlayers("2")
				elseif Attacker.MultiKillPlyer >= 2 then
					PrintMessage(HUD_PRINTCENTER,Attacker:GetName().." "..TextOnScreen[WhichAnnouncer][1]); SendToPlayers("1")
				end
			end)
		end)
	end)
end