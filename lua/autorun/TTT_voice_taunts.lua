--voice_tauns by Edge

CreateConVar("voice_taunts_length", "15", {FCVAR_NOTIFY, FCVAR_ARCHIVE}) --in seconds unused atm
CreateConVar("voice_taunts_cost", "1", {FCVAR_NOTIFY, FCVAR_ARCHIVE})

CreateConVar("voice_taunts_volume", "60", {FCVAR_NOTIFY, FCVAR_ARCHIVE}) --in dB
CreateConVar("voice_taunts_volume_spectator", "30", {FCVAR_NOTIFY, FCVAR_ARCHIVE})

local taunts = {}

for k,v in pairs(file.Find("sound/TTT_voice_taunts/*", "THIRDPARTY")) do

	local short_name = string.StripExtension(v)
	
	--if short_name != ".gitkeep" then
	
		taunts[short_name] = v

		if SERVER then
			resource.AddFile("sound/TTT_voice_taunts/" .. v)
		end
	--end
end


local function listTaunts()
	local tbl = table.GetKeys(taunts)
	table.sort(tbl)
	for k,v in pairs(tbl) do
		print(v)
	end
end


local function AutoComplete( cmd, stringargs )
	
	stringargs = string.Trim(stringargs) -- Remove any spaces before or after.
	stringargs = string.lower(stringargs)
	
	local tbl = {}
	
	for k,v in pairs(taunts) do
		local taunt = k
		if string.find( string.lower( taunt ), stringargs, nil, true ) then
			taunt = "voice_taunt " .. taunt -- We also need to put the cmd before for it to work properly.
			
			table.insert(tbl, taunt)
		end
	end
	
	return tbl
end

concommand.Add("voice_taunt_list", listTaunts, nil, "Shows all currently loaded voice taunts")

if SERVER then
	local function taunt(ply, cmd, args, soundName)

		local cost = GetConVar("voice_taunts_cost"):GetInt()

		if taunts[soundName] == nil then
			print("invalid taunt, choose from:")
			listTaunts()
			return
		end
	
		if ply:Frags() < cost then return end
	
		local volume = GetConVar("voice_taunts_volume"):GetInt()
	
		if !ply:Alive() or ply:Team() == TEAM_SPEC then

			volume = GetConVar("voice_taunts_volume_spectator"):GetInt()
		
		end
	
		sound.Add( {
			name = soundName,
			channel = CHAN_VOICE,
			level = volume,
			sound = "TTT_voice_taunts/" .. taunts[soundName]
		})

		ply:EmitSound(soundName)
		ply:AddFrags(-cost)
		
		local identifier = ply:GetName() .. "StopVoiceTaunt"
		
		hook.Add( "PlayerDeath", identifier, function(victim, inflictor, attacker)
		
			if victim != ply then return end
			hook.Remove("PlayerDeath", identifier)
			ply:StopSound(soundName)
			
		end )	
	end
	
	local function randomTaunt(ply, cmd, args, strArgs)

		stringargs = string.Trim(strArgs) -- Remove any spaces before or after.
		stringargs = string.lower(stringargs)
		
		local tbl = {}
		
		for k,v in pairs(taunts) do
			local taunt = k
			if string.find( string.lower( taunt ), stringargs, nil, true ) then
				table.insert(tbl, taunt)
			end
		end
		
		taunt(ply, cmd, args, table.Random(tbl))
	end
	
	concommand.Add("voice_taunt", taunt, AutoComplete, "Plays a taunt sound specified after the command, use voice_taunt_list to see all loaded taunts")
	concommand.Add("voice_taunt_random", randomTaunt, nil, "Plays a random taunt starting with the chosen substring")
end

    