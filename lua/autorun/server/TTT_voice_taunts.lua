--voice_tauns by Edge

MAXIMUM_TAUNT_LENGTH = 15 --in seconds unused atm

local taunts = {}

for k,v in pairs(file.Find("sound/voice_taunts/*", "THIRDPARTY")) do
	if SERVER then
		resource.AddFile("sound/voice_taunts/" .. v)
	end
	
	local short_name = string.StripExtension(v)
	
	taunts[short_name] = v
end


local function listTaunts()
	for k,v in pairs(taunts) do
		print(k)
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

local function taunt(ply, cmd, args, soundName)

	if taunts[soundName] == nil then
		print("invalid taunt, choose from:")
		listTaunts()
		return
	end
	
	if !ply:Alive() or ply:Team() == TEAM_SPEC then
	
		sound.Add( {
			name = soundName,
			channel = CHAN_VOICE,
			level = 25,
			sound = "voice_taunts/" .. taunts[soundName]
		} )
	else
		sound.Add( {
			name = soundName,
			channel = CHAN_VOICE,
			level = 60,
			sound = "voice_taunts/" .. taunts[soundName]
		} )
	end
	
	ply:EmitSound(soundName)
	
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
concommand.Add("voice_taunt_list", listTaunts, nil, "Shows all currently loaded voice taunts")
concommand.Add("voice_taunt_random", randomTaunt, nil, "Plays a random taunt starting with the chosen substring")
    