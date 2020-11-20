//=========================================================
//=========================================================

GunStatsTable <- null

TARGET_INVALID <- -1
TARGET_SURVIVOR <- 9

MAX_TRACK_PLAYERS <- 10 // note - to change this we would need to update the server index to generate our graphs. There are only 10 graph servers so you can't go past the index 9.

// we need a barebones HUD for our ticker that shows up at the begining of the game
function SetupModeHUD( )
{
	ModeHUD <-
	{
		Fields =
		{
		}
	}
	Ticker_AddToHud( ModeHUD, "" )

	// load the ModeHUD table
	HUDSetLayout( ModeHUD )
}

/////////////////////////////////////////////////
// Mod Command interface
/////////////////////////////////////////////////

GB_HELP_TEXT <-
[
	"About GunBrain - Damage stats are stored on the server for each player. The motd points to an htm file that contains graphs of the stats.",
	"Type these commands into the chat window to perform the following actions.",
	"---",
	"gb_block <playername> - Remove stats for this player and prevent them from recording stats in the future. (useful for Bots)",
	"gb_allow <playername> - Allow a stats blocked player to record stats again.",
	"gb_update - Update the files on disk with the most recent version of the stats (this automatically happens at level end).",
	"gb_dump - Dump all the stats to the console.",
	"gb_reset - Start fresh collecting stats.",
	"gb_backup - creates gunbrainstats.bak with the current data",
	"gb_restore - loads data from gunbrainstats.bak",
	"gb_bot_block - Block all bots from recording stats",
]

function InterceptChat( str, srcEnt )
{
	if ( str.find("gb_help") != null )
	{
		foreach( idx, Line in GB_HELP_TEXT )
		{
			Say( null, Line, true )
		}
	}
	else if( srcEnt != null )
	{
		if ( str.find("gb_block ") )
		{
			local commandStart = str.find("gb_block ")
			local name = str.slice( commandStart + 9 )
			name = name.slice(0,-1)
			CommandAddBlockPlayer( name.toupper() )
			SessionState.GBStatsDirty = true
		}
		else if ( str.find("gb_allow ") )
		{
			local commandStart = str.find("gb_allow ")
			local name = str.slice( commandStart + 9 )
			name = name.slice(0,-1)
			CommandRemoveBlockPlayer( name.toupper() )
		}
		else if ( str.find("gb_update") )
		{
			SessionState.GBStatsDirty = true
		}
		else if ( str.find("gb_dump") )
		{
			CommandDumpData()
		}
		else if ( str.find("gb_reset") )
		{
			CommandResetData()
			SessionState.GBStatsDirty = true
		}
		else if ( str.find("gb_backup") )
		{
			CommandBackupData()
		}
		else if ( str.find("gb_restore") )
		{
			CommandRestoreData()
			SessionState.GBStatsDirty = true
		}
		else if ( str.find("gb_bot_block") )
		{
			CommandAddBlockPlayer( "ELLIS" )
			CommandAddBlockPlayer( "COACH" )
			CommandAddBlockPlayer( "NICK" )
			CommandAddBlockPlayer( "ROCHELLE" )
			CommandAddBlockPlayer( "FRANCIS" )
			CommandAddBlockPlayer( "LOUIS" )
			CommandAddBlockPlayer( "ZOEY" )
			CommandAddBlockPlayer( "BILL" )
		}		
	}
}

function IsPlayerBlocked( playerName )
{
	foreach( index, name in GunStatsTable.Blocked )
	{
		if( name == playerName )
		{
			return true
		}
	}
	return false
}

function CommandAddBlockPlayer( playerName )
{
	Say( null, "Blocking stats for " + playerName, true )

	if ( GunStatsTable.Blocked.len() >= 64 )
		return

	if ( IsPlayerBlocked( playerName ) )
	{
		return
	}
	
	
	GunStatsTable.Blocked.push( playerName )

	foreach( index, Player in GunStatsTable.Players )
	{
		if( playerName == Player.name )
		{
			Say( null, "Removing stats for " + playerName, true )
			GunStatsTable.Players.remove(index)
			return
		}
	}
}

function CommandRemoveBlockPlayer( playerName )
{
	Say( null, "Removing block for " + playerName, true )
	foreach( index, name in GunStatsTable.Blocked )
	{
		if( name == playerName )
		{
			GunStatsTable.Blocked.remove(index)
			return
		}
	}
}

function CommandUpdateData()
{
	CommitDamageData()
}

function CommandDumpData()
{
	printl( TableToString( GunStatsTable ) )
}

function CommandResetData()
{
	GunStatsTable.clear()
	VerifyStatsTableStorage()
	printl( TableToString( GunStatsTable ) )
}

function CommandBackupData()
{
	Say( null, "Backing up data", true )
	StringToFile( "GunBrainData.bak" , TableToString( GunStatsTable ) )
}

function CommandRestoreData()
{
	GunStatsTable.clear()

	local saved_data = FileToString( "GunBrainData.bak" )
	if (saved_data != null)
	{
		local compileDataFunc = compilestring( "local temp_table = " + saved_data + " return temp_table" )
		GunStatsTable = compileDataFunc()
	}
	else
	{
		GunStatsTable <- {}
	}

	VerifyStatsTableStorage()
}

/////////////////////////////////////////////////
// Startup
/////////////////////////////////////////////////

function OnGameplayStart()
{
	printl("Running GunBrain the enhanced gun stats mod")
}

function OnActivate()
{
	printl( " ** On Activate" )	

	SessionState.GBStatsDirty <- false
	ScriptedMode_AddUpdate( StatsUpdate )
	SessionState.GBStatsTick <- 0

	Ticker_SetBlink( true )
	Ticker_NewStr( "Welcome to GunBrain! Chat <gb_help> or open the MotD for available commands", 15 )
	
	PrepareStats()

	CommitDamageData()
}

function PrepareStats()
{
	local saved_data = FileToString( "GunBrainData" )
	if (saved_data != null)
	{
		local compileDataFunc = compilestring( "local temp_table = " + saved_data + " return temp_table" )
		GunStatsTable = compileDataFunc()
	}
	else
	{
		GunStatsTable <- {}
	}

	VerifyStatsTableStorage()

	foreach( index, Player in GunStatsTable.Players )
	{
		printl( "    " + index + " = " + Player.name );
	}
}

/////////////////////////////////////////////////
// Data Management
/////////////////////////////////////////////////

function StatsUpdate()
{
	SessionState.GBStatsTick++

	if( SessionState.GBStatsDirty || SessionState.GBStatsTick == 30 )
	{
		g_ModeScript.CommandUpdateData()

		SessionState.GBStatsDirty = false
		SessionState.GBStatsTick = 0

		Say( null, "Updating Stats", true )
	}
}

function VerifyStatsTableStorage()
{
	if ( !( "Players" in GunStatsTable ) )
	{
		printl("Adding new players list")
		GunStatsTable.Players <- []
	}
	if ( !( "Blocked" in GunStatsTable ) )
	{
		GunStatsTable.Blocked <- []
	}
}

function CommitDamageData()
{
	StringToFile( "GunBrainData" , TableToString( GunStatsTable ) )

	local damageImgString = "<p>"
	
	foreach( idx, Line in GB_HELP_TEXT )
	{
		damageImgString = damageImgString + Line + "<br>"
	}

	damageImgString = damageImgString + "</p>"
	
	damageImgString = damageImgString + CreateOutgoingDamageChartString() + CreateIncomingDamageChartString()
	foreach( index, Player in GunStatsTable.Players )
	{
		damageImgString = damageImgString + CreatePlayerAccuracyChartString( index )
	}
	foreach( index, Player in GunStatsTable.Players )
	{
		damageImgString = damageImgString + CreatePlayerDamageChartString( index )
	}
	StringToFile( "gunbrainstats.htm" , damageImgString )
	SendToServerConsole( "motdfile ems\\gunbrainstats.htm" )
	ReloadMOTD() 
}

function OnShutdown()
{
	CommitDamageData()
}

/////////////////////////////////////////////////
// Damage Event handling
/////////////////////////////////////////////////

function AllowTakeDamage( damageTable )
{	
	// check to see if this wasn't a weapon
	if( !( "GetClassname" in damageTable.Weapon ) )
	{
		// don't store shove damage
	}
	else
	{
		if( damageTable.Attacker.GetClassname() == "player" && damageTable.Attacker.IsSurvivor() )
		{
			local target_type = TARGET_INVALID

			if ( damageTable.Victim.GetClassname() == "infected" )
			{
				target_type = ZOMBIE_NORMAL
			}
			else if ( damageTable.Victim.GetClassname() == "player" )
			{
				if( damageTable.Victim.IsSurvivor() )
				{
					target_type = TARGET_SURVIVOR
				}
				else
				{
					target_type = damageTable.Victim.GetZombieType()
				}
			}
			else if ( damageTable.Victim.GetClassname() == "witch" )
			{
				target_type = ZOMBIE_WITCH
			}
			
			// remove WEAPON_ from the name
			local weapName = damageTable.Weapon.GetClassname()
			weapName = weapName.slice( 7 )

			AddHit( damageTable.Attacker.GetPlayerName().toupper(), weapName.toupper(), damageTable.Victim.GetHealth() > 0 ? damageTable.Victim.GetHealth() : 0, damageTable.DamageDone, damageTable.DamageType & DMG_HEADSHOT, target_type )
		}
		else
		{
			printl("bad target")
		}
	}
	return true
}

function OnGameEvent_weapon_fire( params )
{
	if ( "count" in params )
	{
		local attacker = GetPlayerFromUserID( params.userid )
		local weapon = params.weapon
		local shots = params.count

		AddShots( attacker.GetPlayerName().toupper(), weapon.toupper(), shots )
	}
}

function OnGameEvent_player_hurt( params )
{
	local victim = GetPlayerFromUserID( params.userid )
	if ( !victim.IsSurvivor() )
	{
		return
	}

	if( IsPlayerBlocked( victim.GetPlayerName().toupper() ) )
		return

	if( "attackerentid" in params )
	{
		local attacker = EntIndexToHScript( params.attackerentid )

		local target_type = TARGET_INVALID

		if( params.attackerentid == 0 && params.attacker == 0 )
		{
			// looks like an invalid attacker
		}
		else if ( attacker.GetClassname() == "infected" )
		{
			target_type = ZOMBIE_NORMAL
		}
		else if ( attacker.GetClassname() == "player" )
		{
			if( attacker.IsSurvivor() )
			{
				target_type = TARGET_SURVIVOR
			}
			else
			{
				target_type = attacker.GetZombieType()
			}
		}
		else if ( attacker.GetClassname() == "witch" )
		{
			target_type = ZOMBIE_WITCH
		}

		local player = FindOrAddPlayerData( victim.GetPlayerName().toupper() )
		if ( player != null )
		{
			AddIncomingDamage( player, params.health, params.dmg_health, target_type )
		}
	}
}

/////////////////////////////////////////////////
// Stat recording.
/////////////////////////////////////////////////

function AddHit( playerName, weaponName, victimHealth, damage, headShot, target_type )
{
	if( IsPlayerBlocked( playerName ) )
		return
	
//	printl( "playerName " + playerName + " weaponName " + weaponName + " victimHealth " + victimHealth + " damage " + damage + " headShot " + headShot )

	local Weapon = FindOrAddWeaponData( playerName, weaponName )

	if ( Weapon != null )
	{
		if( target_type != TARGET_INVALID )
		{
			AddWeaponHit( Weapon, victimHealth, damage, headShot, target_type )
		}

		local player = FindOrAddPlayerData( playerName )
		if ( player != null ) 
		{
			AddTypeDamage( player, victimHealth, damage, target_type )
		}
	}
}

function AddShots( playerName, weaponName, shots )
{
	if( IsPlayerBlocked( playerName ) )
		return

//	printl( "playerName " + playerName + " weaponName " + weaponName + " shots " + shots )

	local Weapon = FindOrAddWeaponData( playerName, weaponName )
	if ( Weapon  != null )
	{
		Weapon.shots += shots
	}
}

function CreateNewPlayerTable( playerName )
{
	local player = { name=playerName, WeaponData = [], TypeDamage = [], DamageTaken = [] }
	player.TypeDamage.resize(10,0)
	player.DamageTaken.resize(10,0)
	return player
}

function CreateNewWeaponTable( weaponName )
{
	local weapon = { name=weaponName, shots = 0, hits = 0, effectiveDamage = 0, overKill = 0, deadDamage = 0, headShots = 0, FFHits = 0 }
	return weapon
}

function FindOrAddPlayerData( playerName )
{
	local playerIdx = -1

	foreach( indexP, Player in GunStatsTable.Players )
	{
		if( playerName == Player.name )
		{
			playerIdx = indexP
			break
		}
	}	

	if ( playerIdx == -1 )
	{
		if ( GunStatsTable.Players.len() >= MAX_TRACK_PLAYERS )
		{
			return null
		}
		else
		{
			local player = CreateNewPlayerTable( playerName )
			playerIdx = GunStatsTable.Players.len()
			GunStatsTable.Players.push( player )
		}
	}

	return GunStatsTable.Players[playerIdx]
}

function FindOrAddWeaponData( playerName, weaponName )
{
	local foundPlayer = null
	local bFoundWeapon = false

	local weapIdx = -1
	local playerIdx = -1

	foreach( indexP, Player in GunStatsTable.Players )
	{
		if( playerName == Player.name )
		{
			playerIdx = indexP
			foreach( indexW, Weapon in Player.WeaponData )
			{	
				if( weaponName == Weapon.name )
				{
					return Weapon
				}
			}
			break
		}
	}	

	if ( playerIdx == -1 )
	{
		if ( GunStatsTable.Players.len() >= MAX_TRACK_PLAYERS )
		{
			return null
		}
		else
		{
			local player = CreateNewPlayerTable( playerName )
			playerIdx = GunStatsTable.Players.len()
			GunStatsTable.Players.push( player )
		}
	}

	local weapon = CreateNewWeaponTable( weaponName )
	GunStatsTable.Players[playerIdx].WeaponData.push( weapon )
	return weapon
}

function AddIncomingDamage( player, victimHealth, damage, target_type )
{
	if ( target_type == TARGET_INVALID )
		return

	local effectiveDamage = damage
	if ( damage > victimHealth )
	{
		effectiveDamage = victimHealth
	}

	player.DamageTaken[target_type] += effectiveDamage
}

function AddTypeDamage( player, victimHealth, damage, target_type )
{
	if ( target_type == TARGET_INVALID )
		return

	local effectiveDamage = damage
	if ( damage > victimHealth )
	{
		effectiveDamage = victimHealth
	}

	player.TypeDamage[target_type] += effectiveDamage
}

function AddWeaponHit( weaponData, victimHealth, damage, headShot, target_type )
{
	if ( target_type == TARGET_SURVIVOR )
	{
		weaponData.FFHits++
		return
	}

	if ( weaponData.name == "MELEE" || weaponData.name == "CHAINSAW" )
	{
		weaponData.shots++
	}

//	printl( "victimHealth " + victimHealth + " damage " + damage + " headShot " + headShot + " target_type " + target_type )

	if ( damage < 0 )
		damage = 0
	
	local effectiveDamage = damage
	local overKillDamage = 0
	local deadDamage = 0

	if ( victimHealth <= 0 )
	{
		effectiveDamage = 0
		overKillDamage = 0
		deadDamage = damage
	}
	if ( damage > victimHealth )
	{
		effectiveDamage = victimHealth
		overKillDamage = damage - victimHealth
	}

	weaponData.hits++
	weaponData.effectiveDamage += effectiveDamage
	weaponData.overKill += overKillDamage
	weaponData.deadDamage += deadDamage

	if ( headShot > 0 )
	{
		weaponData.headShots++
	}

//	printl( "hits " + weaponData.hits + "  effectiveDamage " + weaponData.effectiveDamage + "  overKill " + weaponData.overKill + "  headShots " + weaponData.headShots + "  shots " + weaponData.shots )
}


/////////////////////////////////////////////////
// Chart URL building
/////////////////////////////////////////////////

function ComputeChartHeight( desiredHeight )
{
	local height = desiredHeight

	if( height < 220 )
	{
		height = 220
	}
	if( height > 500 )
	{
		height = 500
	}
	return height
}
function CreateOutgoingDamageChartString()
{
	local chart_url = "<img src="
	chart_url = chart_url + "\""
	chart_url = chart_url + "http://"
	chart_url = chart_url + 8
	chart_url = chart_url + ".chart.apis.google.com/chart"

	local target_names = ["Common","Smoker","Boomer","Hunter","Spitter","Jockey","Charger","Witch","Tank","Survivor"]

	{
		local line = "?chxl=1:"
		foreach( index, player in GunStatsTable.Players )
		{
			// player names are backwards so go in revers order
			line = line + "|" + GunStatsTable.Players[ (GunStatsTable.Players.len() - 1) - index ].name
		}
		chart_url = chart_url + line
	}
	
	chart_url = chart_url + "&chxr=0,0,100"
	chart_url = chart_url + "&chxt=x,y"
	chart_url = chart_url + "&chbh=a"
	chart_url = chart_url + "&chs=600x" + ComputeChartHeight( floor(( 30*( 1 + GunStatsTable.Players.len() ) ) ) )
	chart_url = chart_url + "&cht=bhs"
	chart_url = chart_url + "&chco=D1C304,43D948,B6D943,0E8F17,6CA0E0,04C7D1,0E04D1,D104B2,8A04D1,DE2E12"
	chart_url = chart_url + "&chds=0,1000,0,1000,0,1000,0,1000,0,1000,0,1000,0,1000,0,1000,0,1000,0,1000"

	local maxDamage = 100
	foreach( indexP, player in GunStatsTable.Players )
	{
		local playerDamageTotal = 0 
		foreach( index_target, damage in player.TypeDamage )
		{
			playerDamageTotal += damage
		}
		if( playerDamageTotal > maxDamage )
		{
			maxDamage = playerDamageTotal
		}
	}

	local damageScalar = 1000.0/maxDamage

	{		
		local line = "&chd=t"
		foreach( index_target, target in target_names )
		{
			if( index_target == 0 ) {	line = line + ":" } else { line = line + "|" }

			foreach( indexP, player in GunStatsTable.Players )
			{
				if( indexP == 0 ) {	line = line + "" } else { line = line + "," }

				local num = damageScalar*player.TypeDamage[index_target]
				line = line + "" + floor( num )
			}
		}
		chart_url = chart_url + line
	}

	{
		local line = "&chdl="
		foreach( index, name in target_names )
		{
			if( index != 0 ) { line = line + "|" }
			line = line + name
		}
		chart_url = chart_url + line
	}
	chart_url = chart_url + "&chtt=" + "Outgoing Player damage by Target"
	chart_url = chart_url + "\"" + "\\><br><br><br><br>"

	return chart_url
}

function CreateIncomingDamageChartString()
{
	local chart_url = "<img src="
	chart_url = chart_url + "\""
	chart_url = chart_url + "http://"
	chart_url = chart_url + 9
	chart_url = chart_url + ".chart.apis.google.com/chart"

	local target_names = ["Common","Smoker","Boomer","Hunter","Spitter","Jockey","Charger","Witch","Tank","Survivor"]

	{
		local line = "?chxl=1:"
		foreach( index, player in GunStatsTable.Players )
		{
			// player names are backwards so go in revers order
			line = line + "|" + GunStatsTable.Players[ (GunStatsTable.Players.len() - 1) - index ].name
		}
		chart_url = chart_url + line
	}

	chart_url = chart_url + "&chxr=0,0,100"
	chart_url = chart_url + "&chxt=x,y"
	chart_url = chart_url + "&chbh=a"
	chart_url = chart_url + "&chs=600x" + ComputeChartHeight( floor(( 30*( 1 + GunStatsTable.Players.len() ) ) ) )
	chart_url = chart_url + "&cht=bhs"
	chart_url = chart_url + "&chco=D1C304,43D948,B6D943,0E8F17,6CA0E0,04C7D1,0E04D1,D104B2,8A04D1,DE2E12"
	chart_url = chart_url + "&chds=0,1000,0,1000,0,1000,0,1000,0,1000,0,1000,0,1000,0,1000,0,1000,0,1000"

	local maxDamage = 100
	foreach( indexP, player in GunStatsTable.Players )
	{
		local playerDamageTotal = 0 
		foreach( index_target, damage in player.DamageTaken )
		{
			playerDamageTotal += damage
		}
		if( playerDamageTotal > maxDamage )
		{
			maxDamage = playerDamageTotal
		}
	}

	local damageScalar = 1000.0/maxDamage

	{		
		local line = "&chd=t"
		foreach( index_target, target in target_names )
		{
			if( index_target == 0 ) {	line = line + ":" } else { line = line + "|" }

			foreach( indexP, player in GunStatsTable.Players )
			{
				if( indexP == 0 ) {	line = line + "" } else { line = line + "," }

				local num = damageScalar*player.DamageTaken[index_target]
				line = line + "" + floor( num )
			}
		}
		chart_url = chart_url + line
	}

	{
		local line = "&chdl="
		foreach( index, name in target_names )
		{
			if( index != 0 ) { line = line + "|" }
			line = line + name
		}
		chart_url = chart_url + line
	}
	chart_url = chart_url + "&chtt=" + "Incoming Player damage by Source"
	chart_url = chart_url + "\"" + "\\><br><br><br><br>"

	return chart_url
}

function CreatePlayerAccuracyChartString( player_index )
{
	local chart_url = "<img src="
	chart_url = chart_url + "\""
	chart_url = chart_url + "http://"
	chart_url = chart_url + player_index
	chart_url = chart_url + ".chart.apis.google.com/chart"

	local Player = GunStatsTable.Players[player_index]
	{
		local line = "?chxl=1:"
		foreach( indexW, Weapon in Player.WeaponData )
		{
			// weapon names are listed backwards so store them such
			line = line + "|" + Player.WeaponData[ (Player.WeaponData.len() - 1) - indexW ].name
		}
		chart_url = chart_url + line
	}

	chart_url = chart_url + "&chxr=0,0,100"
	chart_url = chart_url + "&chxt=x,y"
	chart_url = chart_url + "&chbh=a"
	chart_url = chart_url + "&chs=600x" + ComputeChartHeight( floor(( 36*( 1.6 + GunStatsTable.Players[player_index].WeaponData.len() ) )) )
	chart_url = chart_url + "&cht=bhs"
	chart_url = chart_url + "&chco=3D7930,A2C180,DCBA80,DC5030"
	chart_url = chart_url + "&chds=0,1000,0,1000,0,1000,0,1000"

	{		
		local line = "&chd=t"
		foreach( indexW, Weapon in Player.WeaponData )
		{
			if( indexW == 0 ) {	line = line + ":" } else { line = line + "," }

			local num = ( Weapon.headShots / (0.001*(Weapon.shots + 1) ) )
			line = line + "" + floor( num )
		}
		line = line + "|"
		foreach( indexW, Weapon in Player.WeaponData )
		{
			if( indexW != 0 ) { line = line + "," }

			local num = ( (Weapon.hits - Weapon.headShots) / (0.001*(Weapon.shots + 0.01) ) )
			line = line + "" + floor( num )
		}
		line = line + "|"
		foreach( indexW, Weapon in Player.WeaponData )
		{
			if( indexW != 0 ) { line = line + "," }

			local num = ( ( Weapon.shots - ( Weapon.hits + Weapon.FFHits ) ) / (0.001*(Weapon.shots + 0.01) ) )
			line = line + "" + floor( num )
		}
		line = line + "|"
		foreach( indexW, Weapon in Player.WeaponData )
		{
			if( indexW != 0 ) { line = line + "," }

			local num = ( Weapon.FFHits / (0.001*(Weapon.shots + 0.01) ) )
			line = line + "" + floor( num )
		}
		chart_url = chart_url + line
	}

	chart_url = chart_url + "&chdl=Headshot|Non-Headshot Hit|Miss|Friendly Fire"
	chart_url = chart_url + "&chtt=" + Player.name + " Shot Hit Type"
	chart_url = chart_url + "\"" + "\\><br><br><br><br>"

	return chart_url
}

function CreatePlayerDamageChartString( player_index )
{
	local chart_url = "<img src="
	chart_url = chart_url + "\""
	chart_url = chart_url + "http://"
	chart_url = chart_url + player_index
	chart_url = chart_url + ".chart.apis.google.com/chart"

	local Player = GunStatsTable.Players[player_index]
	{
		local line = "?chxl=1:"
		foreach( indexW, Weapon in Player.WeaponData )
		{
			// weapon names are listed backwards so store them such
			line = line + "|" + Player.WeaponData[ (Player.WeaponData.len() - 1) - indexW ].name
		}
		chart_url = chart_url + line
	}
	
	chart_url = chart_url + "&chxr=0,0,75"
	chart_url = chart_url + "&chxt=x,y"
	chart_url = chart_url + "&chbh=a"
	chart_url = chart_url + "&chs=600x" + ComputeChartHeight( floor(( 36*( 1.6 + GunStatsTable.Players[player_index].WeaponData.len() ) )) )
	chart_url = chart_url + "&cht=bhs"
	chart_url = chart_url + "&chco=1B84E0,43C5CC,A4B3B0"
	chart_url = chart_url + "&chds=0,75,0,75,0,75"

	{		
		local line = "&chd=t"
		foreach( indexW, Weapon in Player.WeaponData )
		{
			if( indexW == 0 )
			{
				line = line + ":"
			}
			else
			{
				line = line + ","
			}
			line = line + ( Weapon.effectiveDamage / (Weapon.shots + 1) )
		}
		line = line + "|"
		foreach( indexW, Weapon in Player.WeaponData )
		{
			if( indexW != 0 )
			{
				line = line + ","
			}
			line = line + ( Weapon.overKill / (Weapon.shots + 1) )
		}
		line = line + "|"
		foreach( indexW, Weapon in Player.WeaponData )
		{
			if( indexW != 0 )
			{
				line = line + ","
			}
			line = line + ( Weapon.deadDamage / (Weapon.shots + 1) )
		}
		chart_url = chart_url + line
	}

	chart_url = chart_url + "&chdl=Effective+Damage|Overkill+Damage|Dead Target+Damage"
	chart_url = chart_url + "&chtt=" + Player.name + " Damage+Breakdown(per pellet)"
	chart_url = chart_url + "\"" + "\\><br><br><br><br>"

	return chart_url
}


/////////////////////////////////////////////////
// Table manipulation
/////////////////////////////////////////////////

// These two helper functions can call themselves and each other so if want either you would need both.
function TableToString( table )  
{
	local table_string = "{\n"
		
	foreach (idx, key in table)
	{
		if ( typeof(key) == "table" )
		{
			table_string = table_string + idx + "=\n" + TableToString( key ) + ",\n"
		}
		else if ( typeof(key) == "array" )
		{
			table_string = table_string + idx + "=\n" + ArrayToString( key ) + ",\n"
		}
		else if ( typeof(key) == "string" )
		{
			table_string = table_string + idx + "=\"" + key + "\",\n"
		}
		else
		{
			table_string = table_string + idx + "=" + key + ",\n"
		}
	}
	return table_string	+ "}"
}

function ArrayToString( array )
{
	local array_string = "[\n"
		
	foreach (idx, key in array)
	{
		if ( typeof(key) == "table" )
		{
			array_string = array_string + TableToString( key ) + ",\n"
		}
		else if ( typeof(key) == "array" )
		{
			array_string = array_string + ArrayToString( key ) + ",\n"
		}
		else if ( typeof(key) == "string" )
		{
			array_string = array_string + "\"" + key + "\",\n"
		}
		else
		{
			array_string = array_string + key + ",\n"
		}
	}
	return array_string	+ "]"
}