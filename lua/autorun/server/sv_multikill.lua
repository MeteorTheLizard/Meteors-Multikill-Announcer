--Made by MrRangerLP

if SERVER then
	resource.AddWorkshop("1659142161") -- Force subscribe so that people download the sounds through workshop (much faster!)

	for a = 1,15 do -- Add files to download list (For people that cannot download through workshop)
		for k = 0,9 do
			resource.AddFile("sound/meteorsmultikill/" .. tostring(a) .. "/announcer" .. tostring(k) .. ".ogg")
		end
	end

	-- Create convars and their on-changed logic
	CreateConVar("mmk_announcer",1,FCVAR_ARCHIVE,"Change which announcer to use 1 - 15")
	CreateConVar("mmk_timeforkills",5,FCVAR_ARCHIVE,"Time in-between kills before the counter resets")
	CreateConVar("mmk_enablefornpcs",0,FCVAR_ARCHIVE,"Enable or Disable kill counting for NPC kills")

	local MeteorsCallbackCreate = function(StrName,Func)
		cvars.RemoveChangeCallback(StrName,StrName .. "_callback")
		cvars.AddChangeCallback(StrName,function()
			Func()
		end, StrName .. "_callback")
	end

	-- Initialize variables
	local WhichAnnouncer = 1
	local TimeForKills = 5
	local EnableForNPCs = false

	util.AddNetworkString("MMM_Multkill_Announcer")
	local SendToPlayers = function(Number)
		net.Start("MMM_Multkill_Announcer")
			net.WriteUInt(WhichAnnouncer,32)
			net.WriteUInt(Number,32)
		net.Broadcast()
	end

	local TextOnScreen = {
		{"has a DOUBLE KILL!","has a TRIPLE KILL!","has a ULTRA KILL!","has a MONSTER KILL!","IS UNSTOPPABLE!!","IS GODLIKE!",".. HOLY S**T!"},
		{"has a MULTI KILL!","Is on a KILLING SPREE!","has a ULTRA KILL!","has a MONSTER KILL!","IS UNSTOPPABLE!!","IS GODLIKE!",".. HOLY S**T!"},
		{"has a DOUBLE KILL!","has a TRIPLE KILL!","has a QUADRUPLE KILL!","has a QUINTUPLE KILL!","has a SEXTUPLE KILL!","IS LEGENDARY!!"},
		{"has a DOUBLE KILL!","has a TRIPLE KILL!","has a QUADRA KILL!","has a PENTA KILL!","IS UNSTOPPABLE!!","IS IMMORTAL!!","IS GODLIKE!!!"},
		{"has a DOUBLE KILL!","has a TRIPLE KILL!","has a QUADRA KILL!","AND THE GODS PROCLAIMED.. PENTA KILL!","IS UNSTOPPABLE!!","IS IMMORTAL!!","IS GODLIKE!!!"},
		{"has a DOUBLE KILL!","has a TRIPLE KILL!","has a QUADRA KILL!","has a PENTA KILL!","CANNOT BE STOPPED!","CAN CLEARLY DO BETTER!!","BURNS THEM ALL TO THE GROUND!!!"},
		{"has a DOUBLE KILL!","has a MULTI KILL!","has a ULTRA KILL!","IS UNBELIEVEABLE!","LET THEM ALL COME!!","YOU WANT A PIECE OF ME?!!","has WAY TO MUCH FUN!!!"},
		{"has a DOUBLE KILL!","has a MULTI KILL!","has a ULTRA KILL!","IS UNBREAKABLE!","IS UNBELIEVEABLE","YOU WANT A PIECE OF ME?!!","Come and GET SOME!!"},
		{"has a DOUBLE KILL!","has a MULTI KILL!","has a ULTRA KILL!","IS UNBREAKABLE!","IS UNBELIEVEABLE","YOU WANT A PIECE OF ME?!!","Come and GET SOME!!"},
		{"has a DOUBLE KILL!","has a MULTI KILL!","has a ULTRA KILL!","has a MONSTER KILL!","IS UNSTOPPABLE!!","IS GODLIKE!",".. IS UNHOLY!!"},
		{"has a DOUBLE KILL!","has a MULTI KILL!","has a ULTRA KILL!","has a MONSTER KILL!","IS UNSTOPPABLE!!","IS GODLIKE!",".. HOLY S**T!"},
		{"has a DOUBLE KILL!","has a TRIPLE KILL!","has an OVERKILL!","IS KILLTACULAR!","IS A KILLTROCITY","IS KILLAMANJARO!!","IS A KILLTASTROPHE!!!","BROUGHT RAGNAROK UPON US","IS A KILLIONARE!!!"},
		{"has a DOUBLE KILL!","has a MULTI KILL!","has a ULTRA KILL!","has a MONSTER KILL!","IS UNSTOPPABLE!!","IS GODLIKE!",".. IS A WINNER BY NATURE!!"},
		{"has a DOUBLE KILL!","has a TRIPLE KILL!","has a QUADRA KILL!","has a PENTA KILL!!","has a LEGENDARY KILL!!"},
		{"has a DOUBLE KILL!","has a MORE THAN 2 BUT LESS THAN 4 KILL!","has a ULTRA KILL!","has a MONSTER KILL!","IS UNSTOPPABLE!!","IS GODLIKE!","GABEN REFUSES TO READ","GABE PLS","HAS DISCOVERED YOUR SCAM"}
	}

	local TableAnnouncerN = { -- Determine which announcers have a headshot announcement
		[1] = true,
		[2] = true,
		[7] = true,
		[8] = true,
		[9] = true,
		[10] = true,
		[11] = true,
		[12] = true,
		[13] = true
	}

	local f_ALogic = function(Target,Inflictor,Attacker)
		timer.Simple(0,function() -- One tick delay
			if not IsValid(Attacker) then return end

			if IsValid(Inflictor) and Inflictor:IsPlayer() then
				Attacker = Inflictor
			end

			if not Attacker.MultiKillPlyer then
				Attacker.MultiKillPlyer = 0
			end

			if Attacker.MultiKillPlyer > 0 and Attacker.TimerNextKill == 0 then
				Attacker.MultiKillPlyer = 0
			end

			Attacker.TimerNextKill = TimeForKills
			Attacker.MultiKillPlyer = (Attacker.MultiKillPlyer + 1)

			if Target:IsPlayer() and Target:LastHitGroup() == 1 and Attacker.MultiKillPlyer == 1 and TableAnnouncerN[WhichAnnouncer] then -- Announce headshot
				Attacker:PrintMessage(HUD_PRINTCENTER,"HEADSHOT!")

				net.Start("MMM_Multkill_Announcer")
					net.WriteUInt(WhichAnnouncer,32)
					net.WriteUInt(0,32)
				net.Send(Attacker)
			end

			timer.Remove("MMM_Multkill_Announcer")
			timer.Create("MMM_Multkill_Announcer",0.1,1,function() -- This is delayed so it does not stack when multiple kills happened at once
				if not IsValid(Attacker) then return end
				local AttackerName = (Attacker:IsPlayer() and Attacker:Nick()) or Attacker:GetName()

				if Attacker.MultiKillPlyer >= 10 and WhichAnnouncer == 12 or Attacker.MultiKillPlyer >= 10 and WhichAnnouncer == 15 then
					PrintMessage(HUD_PRINTCENTER,AttackerName.." "..TextOnScreen[WhichAnnouncer][9])
					SendToPlayers("9")

				elseif Attacker.MultiKillPlyer >= 9 and WhichAnnouncer == 12 or Attacker.MultiKillPlyer >= 9 and WhichAnnouncer == 15 then
					PrintMessage(HUD_PRINTCENTER,AttackerName.." "..TextOnScreen[WhichAnnouncer][8])
					SendToPlayers("8")

				elseif Attacker.MultiKillPlyer >= 8 and WhichAnnouncer ~= 3 and WhichAnnouncer ~= 14 then
					PrintMessage(HUD_PRINTCENTER,AttackerName.." "..TextOnScreen[WhichAnnouncer][7])
					SendToPlayers("7")

				elseif Attacker.MultiKillPlyer >= 7 and WhichAnnouncer ~= 14 then
					PrintMessage(HUD_PRINTCENTER,AttackerName.." "..TextOnScreen[WhichAnnouncer][6])
					SendToPlayers("6")

				elseif Attacker.MultiKillPlyer >= 6 then
					PrintMessage(HUD_PRINTCENTER,AttackerName.." "..TextOnScreen[WhichAnnouncer][5])
					SendToPlayers("5")

				elseif Attacker.MultiKillPlyer >= 5 then
					PrintMessage(HUD_PRINTCENTER,AttackerName.." "..TextOnScreen[WhichAnnouncer][4])
					SendToPlayers("4")

				elseif Attacker.MultiKillPlyer >= 4 then
					PrintMessage(HUD_PRINTCENTER,AttackerName.." "..TextOnScreen[WhichAnnouncer][3])
					SendToPlayers("3")

				elseif Attacker.MultiKillPlyer >= 3 then
					PrintMessage(HUD_PRINTCENTER,AttackerName.." "..TextOnScreen[WhichAnnouncer][2])
					SendToPlayers("2")

				elseif Attacker.MultiKillPlyer >= 2 then
					PrintMessage(HUD_PRINTCENTER,AttackerName.." "..TextOnScreen[WhichAnnouncer][1])
					SendToPlayers("1")
				end
			end)
		end)
	end

	local NPC_Func = function(Ent,damageInfo)
		if Ent:IsNPC() then
			local Damage = damageInfo:GetDamage()

			if Damage >= Ent:Health() then
				local Attacker = damageInfo:GetAttacker()
				local Inflictor = IsValid(damageInfo:GetInflictor()) and damageInfo:GetInflictor() or Attacker

				if not IsValid(Attacker) or not Attacker:IsPlayer() then return end -- Props should not get kill counts!

				f_ALogic(Ent,Attacker,Inflictor)
			end
		end
	end

	-- We wait until the gamemode finished loading to make extra sure the convars were created
	hook.Add("PostGamemodeLoaded","MMM_MultikillAnnouncer_Init",function()
		hook.Remove("PostGamemodeLoaded","MMM_MultikillAnnouncer_Init")
		WhichAnnouncer = GetConVar("mmk_announcer"):GetInt()
		TimeForKills = GetConVar("mmk_timeforkills"):GetInt()

		local Int = GetConVar("mmk_enablefornpcs"):GetInt()
		EnableForNPCs = (Int == 1 and true or Int == 0 and false)

		if EnableForNPCs then
			hook.Add("EntityTakeDamage","MMM_Multikill_Announcer",NPC_Func)
		end
	end)

	MeteorsCallbackCreate("mmk_announcer",function()
		WhichAnnouncer = GetConVar("mmk_announcer"):GetInt()
	end)

	MeteorsCallbackCreate("mmk_timeforkills",function()
		TimeForKills = GetConVar("mmk_timeforkills"):GetInt()
	end)

	MeteorsCallbackCreate("mmk_enablefornpcs",function()
		local Int = GetConVar("mmk_enablefornpcs"):GetInt()
		if not isnumber(Int) then return end

		EnableForNPCs = (Int == 1 and true or Int == 0 and false)

		if EnableForNPCs then
			hook.Add("EntityTakeDamage","MMM_Multikill_Announcer",NPC_Func)
		else
			hook.Remove("EntityTakeDamage","MMM_Multikill_Announcer")
		end
	end)

	timer.Create("MMM_Multkill_Announcer_ResetLogic",1,0,function()
		for _,v in ipairs(player.GetAll()) do
			if v.TimerNextKill and v.TimerNextKill > 0 then
				v.TimerNextKill = (v.TimerNextKill - 1)
			end
		end
	end)

	hook.Add("PlayerDeath","MMM_Multikill_Announcer",function(Target,Inflictor,Attacker)
		if not Target:IsPlayer() or not Attacker:IsPlayer() then return end
		if Target == Attacker then -- Reset streak on death
			Attacker.MultiKillPlyer = 0
			Attacker.TimerNextKill = 0
			return
		end

		f_ALogic(Target,Inflictor,Attacker)
	end)
end