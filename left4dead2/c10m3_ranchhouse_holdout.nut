///////////////////////////////////////////////////////////////////////////////
//
// Holdout mode stuff specific to the Ranch House map
//
///////////////////////////////////////////////////////////////////////////////

IncludeScript("sm_resources", g_MapScript)

//-------------------------------------
// Include all entity group interfaces needed for this mode. Entities in the
// MapSpawns table will be included and spawned on map start by default unless
// otherwise specified. MapSpawn table contains at minimum the group name. 
// E.g., [ "WallBarricade" ]
//
// and at most four parameters: group name, spawn location, file to include, and spawn flags. 
// E.g., [ "WallBarricade", "wall_barricade_spawn", "wall_barricade_group", SPAWN_FLAGS.SPAWN ]
//
// If you provide only the group name the spawn location and file to include will
// be generated, and the default 'spawn' flag will be used
// E.g., [ "WallBarricade" ]
//
// If you provide two parameters it assumes they are the group name and spawn flag, 
// and will auto generate the spawn location and file to include
// E.g., [ "WallBarricade", SPAWN_FLAGS.NOSPAWN ]
//
// If you provide three parameters it assumes group name, spawn location, and file to include.  
// It will use the default 'spawn' flag
// E.g., [ "WallBarricade", "my_barricade_spawn", "my_barricade_group" ]
//-------------------------------------
MapSpawns <-
[
	["WindowBarricade"],	
	["Blocknav64"],
	["DefibCabinet"],
	["FootlockerThrowables"],
	["HealthCabinet"],
	["ResupplyHelicopter"],
	["MedCabinet"],
	["PlaceableResource"],
	["Tier1WeaponCabinet"],
	["Tier2WeaponCabinet"],
	["Ladder"],
	["LadderButton"],
	["Radio"], 
	["RescueHelicopter" ],
	["WrongwayBarrier" ],
	["Hintboard" ],
]

//-------------------------------------
// Map specific game state info - will get merged with MutationState into the SessionState table
// In the code below, you should just use SessionState 
//-------------------------------------
MapState <-
{
	InitialResources = 0
	HUDWaveInfo = true
	HUDTickerText = "Objective: Hold out for 6 waves and then get to the chopper!  Use the radio to start."
	StartActive = true 
	
	ForcedEscapeStage = 19

	CooldownEndWarningChance = 100 // crank up the chance of playing the end of wave warning
}	

//-------------------------------------
// The map specific overrides to the Options table - merges down to SessionState
//-------------------------------------
MapOptions <-
{

	SpawnSetRule = SPAWN_POSITIONAL
	SpawnSetRadius = 2000
	SpawnSetPosition = Vector( -6979, -1886, 70 )
}

//-------------------------------------
// entities to sanitize on map spawn
//
// 'Sanitizing' is deleting entities from a map that are not wanted or 
// needed by this scripted mode. This frees up memory and CPU.
// And is sometimes needed to remove events from a map that you dont want in your mode
//-------------------------------------
SanitizeTable <-
[
	// fire these outputs on map load
	{ classname		= "prop_door_rotating", input = "kill" },
	{ classname		= "func_breakable", input = "break" },
	{ classname		= "weapon_*", input = "kill" },
	{ classname		= "trigger_finale", input = "kill" },
	{ targetname	= "car_sedan*", input = "kill" },
	{ classname		= "func_physbox", input = "kill" }, // kitchen boards on sawhorses
	{ model			= "models/props_interiors/sawhorse.mdl", input = "kill" }

	// sanitize by region "sanitize_region_front"
	{ classname		= "logic*", input = "kill", region = "sanitize_region_front" },
	{ classname		= "point*", input = "kill", region = "sanitize_region_front" },
	{ classname		= "prop*", input = "kill", region = "sanitize_region_front" },
	{ classname		= "ambient_generic", input = "kill", region = "sanitize_region_front" },
	{ classname		= "keyframe_rope", input = "kill", region = "sanitize_region_front" },
	{ classname		= "move_rope", input = "kill", region = "sanitize_region_front" },
	{ classname		= "env_soundscape", input = "kill", region = "sanitize_region_front" },
	{ classname		= "env_fade", input = "kill", region = "sanitize_region_front" },
	{ classname		= "info_*", input = "kill", region = "sanitize_region_front" },
	{ classname		= "trigger*", input = "kill", region = "sanitize_region_front" },
	{ classname		= "env_sprite", input = "kill", region = "sanitize_region_front" },
	{ classname		= "beam*", input = "kill", region = "sanitize_region_front" },
	{ classname		= "env_fire", input = "kill", region = "sanitize_region_front" },
	{ classname		= "func_areaportalwindow", input = "kill", region = "sanitize_region_front" },
	{ classname		= "func_brush", input = "kill", region = "sanitize_region_front" },
	{ classname		= "func_illusionary", input = "kill", region = "sanitize_region_front" },
	{ targetname	= "filter_tank", input = "kill", region = "sanitize_region_front" },
	{ targetname	= "survivor", input = "kill", region = "sanitize_region_front" },


	// sanitize by region "sanitize_region_back"
	{ classname		= "logic*", input = "kill", region = "sanitize_region_back" },
	{ classname		= "point*", input = "kill", region = "sanitize_region_back" },
	{ classname		= "prop*", input = "kill", region = "sanitize_region_back" },
	{ classname		= "ambient_generic", input = "kill", region = "sanitize_region_back" },
	{ classname		= "keyframe_rope", input = "kill", region = "sanitize_region_back" },
	{ classname		= "move_rope", input = "kill", region = "sanitize_region_back" },
	{ classname		= "env_soundscape", input = "kill", region = "sanitize_region_back" },
	{ classname		= "env_fade", input = "kill", region = "sanitize_region_back" },
	{ classname		= "info_*", input = "kill", region = "sanitize_region_back" },
	{ classname		= "trigger*", input = "kill", region = "sanitize_region_back" },
	{ classname		= "env_sprite", input = "kill", region = "sanitize_region_back" },
	{ classname		= "beam*", input = "kill", region = "sanitize_region_back" },
]

//---------------------------------------------------------
// Here are the strings that will be doled out as hints 
// when players use the corkboard
//---------------------------------------------------------
HintBoardStringTable <-
[
	["Build the ladder to the roof during a cooldown so it will be ready for the escape wave"],
	["Adrenaline helps you build everything faster"],
	["Bullets will damage barricades so aim carefully through the gun slits"],
	["Wait for specials to get close before killing them so their loot will drop nearby"]
]

//---------------------------------------------------------
// We'll pass this table to CreateTrainingHints when the map
// starts for the first time
//---------------------------------------------------------
InstructorHintTable <-
[
	{ targetname = "hintboard_script_hint", mdl = "models/props/cs_office/offcorkboarda.mdl", targetEntName = "hintboard", hintText = "Map Hints!" }
]

//---------------------------------------------------------
// Default delay values, these are used as constants 
// within this file
//---------------------------------------------------------
DelayTime <- 30
DelayTimeShort <- 20
DelayTimeMedium <- 25
DelayTimeLong <- 30

//=========================================================
//=========================================================
function BeginSupplyDrop( stageData )
{
	Ticker_SetBlink( true )
	Ticker_NewStr( "Here comes a helicopter supply drop! Look for orange smoke to find the impact site.", 45 )
	g_RoundState.ResupplyHelicopter.SummonHelicopter()
}

//=========================================================
//=========================================================
function EscapeWaveCB( stageData ) 
{
	g_RoundState.g_RescueManager.EnableRescue()

	// go ahead and summon the chopper directly since we know it can't conflict with other choppers in the map
	g_RoundState.g_RescueManager.SummonRescueChopperCheck()
}

//=========================================================
//=========================================================
function FirstWaveCB( stageData )
{
	Ticker_SetBlink( true )
	Ticker_NewStr( "Here they come! Survive 6 waves!", 10 )
}

//---------------------------------------------------------
//stage definitions
//---------------------------------------------------------
stageDefaults <-
{ 
	name = "default", 
	type = STAGE_PANIC, 
	value = 1,
	params = 
	{ 
		PanicWavePauseMax = 1, 
		BileMobSize = 20, 
		SpawnDirectionMask = SPAWNDIR_N, 
		AddToSpawnTimer = 6 
	}, 
	callback = null, 
	trigger = null, 
	NextDelay = DelayTime
}

stage1 <-
{ name = "wave 1", params = { PanicWavePauseMax = 5, DefaultLimit = 1, MaxSpecials = 2, CommonLimit = 30,  SpawnDirectionMask = SPAWNDIR_S }, NextDelay = DelayTimeLong, callback = FirstWaveCB }

stage2 <-
{ name = "wave 2", params = { DefaultLimit = 2, MaxSpecials = 3, ChargerLimit = 1, CommonLimit = 30, SpawnDirectionMask = SPAWNDIR_N },  NextDelay = DelayTimeLong }

stage3 <-
{ name = "wave 3", params = { DefaultLimit = 3, MaxSpecials = 3, ChargerLimit = 1, CommonLimit = 50, SpawnDirectionMask = SPAWNDIR_S  }, NextDelay = DelayTimeLong }

stage4 <-
{ name = "wave 4", params = { DefaultLimit = 3, MaxSpecials = 4, CommonLimit = 50, SpawnDirectionMask = SPAWNDIR_SW | SPAWNDIR_SE }, NextDelay = DelayTimeShort, }

stage5 <-
{ name = "wave 5", params = { DefaultLimit = 2, MaxSpecials = 4, CommonLimit = 20, SpawnDirectionMask = SPAWNDIR_SE }, NextDelay = DelayTimeLong }

stage6 <-
{ name = "wave 6", params = { DefaultLimit = 3, MaxSpecials = 5, CommonLimit = 50, SpawnDirectionMask = SPAWNDIR_NE  }, NextDelay = DelayTimeMedium }

//---------------------------------------------------------
//---------------------------------------------------------
stageEscape <-
{
	name = "escapeWave",
	type = STAGE_ESCAPE,
	value = 3,
	params = { DefaultLimit = 4, MaxSpecials = 6, CommonLimit = 50 },
	callback = EscapeWaveCB
	//didn't set type again like its set in the old ranchhouse script. make sure its set up correctly
}

//---------------------------------------------------------
//---------------------------------------------------------
stageDelay <- 
{
	name = "delay",
	type = STAGE_DELAY,
	value = 60
	params = { DefaultLimit = 0, MaxSpecials = 0, BileMobSize = 0 }
}

//=========================================================
// Called by Scripted Mode for each entity group that is properly registered. 
// This call comes in BEFORE the entities of that group are actually spawned. 
// Mainly this is an opportunity to fiddle with fields in the entity spawn table 
//  before the entity is actually created.
//
// In this case, we're hooking a callback function to the 'Radio' group before it spanws.
//=========================================================
function OnEntityGroupRegistered( name, group )
{	
	if ( name == "Radio" ) 
	{
		group.GetEntityGroup().SpawnTables[ "radio" ].PostPlaceCB <- RadioSpawnCB
	}
}

//=========================================================
// Called by the Holdout mode script when the radio is used by any survivor.
//=========================================================
function StartRadioUsed()
{
	EndTrainingHints( 15 )
	Director.ForceNextStage()
}

//=========================================================
// This function is called by the Holdout mode when a game starts up
//=========================================================
function DoMapSetup()
{
	Ticker_SetTimeout( 0 )  // stops the start ticker from timing out so it stays up until the game starts

	CreateTrainingHints( InstructorHintTable )
	
	// do this after the items have spawned so the items will get the calls to update their glow state
	g_ResourceManager.AddResources( SessionState.InitialResources )

	//teleport players to the start point
	if (!TeleportPlayersToStartPoints( "playerstart*" ) )
		printl(" ** TeleportPlayersToStartPoints: Spawn point count or player count incorrect! Verify that there are 4 of each.")
}

//=========================================================
// If a melee weapon hits a breakable door (barricades are 
// doors) then increase the damage so it breaks more quickly
//=========================================================
function AllowTakeDamage( damageTable )
{
	if ( damageTable.Victim.GetClassname() == "prop_door_rotating" )
	{
		if ( damageTable.Weapon != null )
		{
			if ( damageTable.Weapon.GetClassname() == "weapon_melee" )
			{
				ScriptedDamageInfo.DamageDone = 100.0
				return true
			}
		}
	}
	
	return true
}

//=========================================================
//=========================================================
function GetAttackStage()
{
	local stage_name = "stage" + SessionState.ScriptedStageWave
	return this[stage_name]
}

//=========================================================
//=========================================================
function GetMapEscapeStage()
{
	Ticker_SetBlink( true )
	Ticker_NewStr("Here comes the Rescue Chopper!  Get to the roof!", 30 )
	return stageEscape
}

//=========================================================
//=========================================================
function GetMapClearoutStage()
{
	DirectorOptions.ScriptedStageType = STAGE_CLEAROUT
	DirectorOptions.ScriptedStageValue = 5
	return null
}

//=========================================================
//=========================================================
function GetMapDelayStage()
{
	switch( SessionState.ScriptedStageWave )
	{
	    case 1:
			Ticker_NewStr( "Cooldown! Now would be a good time to heal, barricade and spend supplies.", 45 )
			break

		case 2:
			Ticker_SetTimeout( 45 )
			Ticker_NewStr( "Cooldown! Heal, barricade and get ready for the next attack!", 45 )
			break

		case 3:
			BeginSupplyDrop( 0 )
			break

		case 4:
			Ticker_NewStr( "This is a short cooldown!  Prepare for the next attack!", 20)
			break
		
		case 6:
			Ticker_SetBlink( true )
			Ticker_NewStr( "The rescue chopper will pick you up on the roof next wave!  Can you reach the roof?", 30 )
			break

		default:
			break
	}

	if( "NextDelayTime" in SessionState ) 
		stageDelay.value = SessionState.NextDelayTime
	else
		stageDelay.value = DelayTimeMedium
	return stageDelay
}