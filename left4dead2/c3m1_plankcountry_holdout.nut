///////////////////////////////////////////////////////////////////////////////
// On round start, we execute any script file of the name <mapname>_<gamemode>.nut
// This file is executed in the MAP_SCRIPT layer
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// We hand define (for now! would be cool if more flexible eventually) first 10 waves
//  then we have an outline of waves after that, where we randomize some values and just run it
//  with a small add based on wave #, so it slowly goes up
// Then there are a few special events for now (tank barn, witch wave)
//  which we "hand manage" in the callbacks
///////////////////////////////////////////////////////////////////////////////


//---------------------------------------------------------
// this should prob be in holdout, not here - and put 
// resources in mapstate?
//---------------------------------------------------------
IncludeScript("sm_resources", g_MapScript)

//---------------------------------------------------------
// Gascan manager handles spawning of holdout gascans
//---------------------------------------------------------
IncludeScript("holdout_gascan_manager", g_MapScript)

//---------------------------------------------------------
// Balloon resupply manager - handles spawning of resupply 
// balloon event
//---------------------------------------------------------
IncludeScript("resupply_balloon_spawn_manager", g_MapScript )

//---------------------------------------------------------
// Include all entity group interfaces needed for this mode
// Entities in the MapSpawns table will be included and spawned on map start by default unless otherwise specified.
// MapSpawn table contains at minimum the group name. E.g., [ "WallBarricade" ]
// and at most four parameters: group name, spawn location, file to include, and spawn flags. E.g., [ "WallBarricade", "wall_barricade_spawn", "wall_barricade_group", SPAWN_FLAGS.SPAWN ]
// If you provide only the group name the spawn location and file to include will be generated, and the default 'spawn' flag will be used
// E.g., [ "WallBarricade" ]
// If you provide two parameters it assumes they are the group name and spawn flag, and will auto generate the spawn location and file to include
// E.g., [ "WallBarricade", SPAWN_FLAGS.NOSPAWN ]
// If you provide three parameters it assumes group name, spawn location, and file to include.  It will use the default 'spawn' flag
// E.g., [ "WallBarricade", "my_barricade_spawn", "my_barricade_group" ]
//---------------------------------------------------------
MapSpawns <- 
[
	[ "Empty64"],
	[ "Empty256"],
	[ "WallBarricade"],
	[ "WindowBarricade"],
	[ "DefibCabinet"],
	[ "AmmoCabinet"],
	[ "AmmoCrate"],
	[ "FootlockerThrowables"],
	[ "HealthCabinet"],
	[ "BuildableMinigun"],
	[ "CooldownExtensionButton"],
	[ "FirewallTrap"],
	[ "FirewallPipe"],
	[ "FireworkLauncher"],
	[ "GascanHelicopter"],
	[ "GascanHelicopterButton"],
	[ "Landmine"],
	[ "ResupplyHelicopter"],
	[ "ResupplyHelicopterButton"],
	[ "ResupplyBalloon", SPAWN_FLAGS.NOSPAWN],
	[ "MineTable"],
	[ "Searchlight"],
	[ "BuildableLadder" ],
	[ "MedCabinet"],
	[ "ResourceLocker"],
	[ "PlaceableResource"],
	[ "Tier1WeaponCabinet"],
	[ "Tier2WeaponCabinet"],
	[ "TankManhole"],
	[ "RescueHelicopter"],
	[ "WitchTombstone", "witch_tombstone_spawn", "witch_tombstone_group", SPAWN_FLAGS.TARGETSPAWN, 4],
	[ "WrongwayBarrier"],
	[ "LifePreserver"],
	[ "Hintboard" ],
	[ "C3m1PlankcountryMisc" ],
]


//---------------------------------------------------------
//---------------------------------------------------------
MapState <-
{
	RescueTime = 600         // how long to run rescue timer for
	InitialResources = 0
	NextDelayTime = 60   // really should always be set, but lets have a default
	HUDWaveInfo = false
	HUDRescueTimer = true
	HUDTickerTimeout = 0
	HUDTickerText = "Collect respawning gascans and keep spotlights fueled to be rescued"
	StartActive = true
	InstructorHints = true
}

//---------------------------------------------------------
//---------------------------------------------------------
MapOptions <-
{
	// Set the infected to spawn on BATTLEFIELD areas
	SpawnSetRule = SPAWN_BATTLEFIELD
	ShouldIgnoreClearStateForSpawn = true
	PreferredMobDirection = SPAWN_LARGE_VOLUME
	PreferredSpecialDirection = SPAWN_LARGE_VOLUME
	ShouldConstrainLargeVolumeSpawn = false
}                   

//---------------------------------------------------------
// entities to sanitize on map spawn
//
// 'Sanitizing' is deleting entities from a map that are 
// not wanted or needed by this scripted mode. This
// frees up memory and CPU.
//---------------------------------------------------------
SanitizeTable <-
[
	// fire these outputs on map spawn
	{ targetname	= "relay_intro_start", input = "kill" }, // stops the intro choreo scene from triggering
	{ targetname	= "survival_spawnpoints", input = "kill" },
	{ targetname	= "ferry_*", input = "kill" },
	{ targetname	= "rope_ferry_*", input = "kill" },
	{ targetname	= "rope_winch_*", input = "kill" },
	{ classname		= "move_rope", position = Vector( -5424, 5987, 38 ), input = "kill" } // unnamed ferry rope
	{ targetname	= "WorldC3M1Ferry*", input = "kill" },
	{ classname		= "func_breakable", input = "break" },
	{ classname		= "prop_door_rotating", input = "kill" },
	{ classname		= "weapon_*", input = "kill" },
	{ model 		= "models/props_junk/gascan001a.mdl", input = "kill" }, // gascans
	{ model 		= "models/props_urban/boat002.mdl", input = "kill" }, // dock boat
	{ model 		= "models/props/cs_office/shelves_metal.mdl", input = "kill" }, // dock shelves
	{ model 		= "models/props_urban/shopping_cart001.mdl", input = "kill" }, // shopping carts
	{ model 		= "models/props_vehicles/cara_69sedan.mdl", input = "kill" }, // car
	{ classname		= "trigger_once", position = Vector( -8095.920, 8124.910, 128 ), input = "kill" } // trigger_once

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
	{ classname		= "func_*", input = "kill", region = "sanitize_region_front" },
	
	// sanitize by region "sanitize_region_back"
	{ classname		= "env_phys*", input = "kill", region = "sanitize_region_back" },
	{ classname		= "env_*", input = "kill", region = "sanitize_region_back" },
	{ classname		= "keyframe_rope", input = "kill", region = "sanitize_region_back" },
	{ classname		= "move_rope", input = "kill", region = "sanitize_region_back" },
	{ classname		= "beam_spotlight", input = "kill", region = "sanitize_region_back" },
	{ classname		= "prop_*", input = "kill", region = "sanitize_region_back" },
	{ classname		= "point_*", input = "kill", region = "sanitize_region_back" },
	{ classname		= "info_*", input = "kill", region = "sanitize_region_back" },
	{ classname		= "func_*", input = "kill", region = "sanitize_region_back" },
	{ classname		= "logic_*", input = "kill", region = "sanitize_region_back" },
	{ classname		= "ambient_generic", input = "kill", region = "sanitize_region_back" },
]

//---------------------------------------------------------
// Here is a table containing the strings that will be 
// doled out as hints when players use the corkboard
//---------------------------------------------------------
HintBoardStringTable <-
[
	["Wait for specials to get close before killing them so their loot will drop nearby"],
	["Barricade the manhole if you are not ready to fight the tank"],
	["Adrenaline helps you build everything faster"],
	["If someone falls in the water you will have an opportunity to rescue them"],
	["There are two free healthkits in the garage!"],
	["Use lots of land mines to soften up the tanks and witches"],
	["If you need more time to prepare for a wave buy extra time"],
]

//---------------------------------------------------------
// We'll pass this table to CreateTrainingHints when the map 
// starts for the first time
//---------------------------------------------------------
InstructorHintTable <-
[
	{ targetname = "tier_1_script_hint", mdl = "models/props_unique/guncabinet_door.mdl", targetEntName = "gun_cabinet_door", hintText = "Tier 1 Guns" }
	{ targetname = "tier_2_script_hint", mdl = "models/props_unique/guncabinet01_ldoor.mdl", targetEntName = "gun_cabinet_doors", hintText = "Tier 2 Guns" }
	{ targetname = "first_aid_script_hint", mdl = "models/props_buildables/small_cabinet_firstaid.mdl", targetEntName = "health_cabinet", hintText = "First Aid Kits" }
	{ targetname = "hintboard_script_hint", mdl = "models/props/cs_office/offcorkboarda.mdl", targetEntName = "hintboard", hintText = "Map Hints!" }
]

//---------------------------------------------------------
// Scripted Mode calls all slow polls every two seconds
//---------------------------------------------------------
function MapSlowPoll()
{	
	// time to summon the escape chopper?
	g_RoundState.g_RescueManager.SummonRescueChopperCheck()

	// spawn cans if it is time
	g_RoundState.g_GascanManager.GascanUpdate()

	// search for water victims
	g_RoundState.LifePreserverManager.WaterDeathPoll()
}

//---------------------------------------------------------
// Called when the first stage starts
//---------------------------------------------------------
function GameStartCB( stageData )
{
	// hide the starting ticker
	Ticker_SetBlink( true )
	Ticker_NewStr( "Here they come!", 5 )
}

///////////////////////////////////////////////////////////////////////////////
//
// Stage definitions
//
///////////////////////////////////////////////////////////////////////////////

//---------------------------------------------------------
// These are the fixed delay values for Holdout mode in 
// this specific map
//---------------------------------------------------------
DelayTimeShort <- 40
DelayTimeMedium <- 65
DelayTimeLong <- 100

//---------------------------------------------------------
// These values are set every wave.  Subsequent wave stages are applied afterward.
// Handy so you don't have to remember to reset modified values after each wave
//---------------------------------------------------------
stageDefaults <-
{ 
	name = "default", 
	type = STAGE_PANIC, 
	value = 1,
	params = { TankLimit = 1, BileMobSize = 20, SpawnDirectionCount = 0, SpawnDirectionMask = 0, AddToSpawnTimer = 6 }, 
	callback = null, 
	trigger = null
} 

///////////////////////////////////////////////////////////////////////////////
//
// Configuration data for each of the 'waves'
//
///////////////////////////////////////////////////////////////////////////////

stage1 <-
{ name = "wave 1", params = { PanicWavePauseMax = 1,  DefaultLimit = 1, BoomerLimit = 0, ChargerLimit = 0, MaxSpecials = 4, CommonLimit = 100, SpawnDirectionMask = SPAWNDIR_N | SPAWNDIR_SE }, NextDelay = DelayTimeShort, callback = GameStartCB }

stage2 <-
{ name = "wave 2", params = { PanicWavePauseMax = 1,  DefaultLimit = 1, BoomerLimit = 0, HunterLimit = 2, SpitterLimit = 1, MaxSpecials = 4, CommonLimit = 100, SpawnDirectionMask = SPAWNDIR_E }, NextDelay = DelayTimeShort }

stage3 <-
{ name = "wave 3", params = { DefaultLimit = 1,  BoomerLimit = 0, JockeyLimit = 2, SmokerLimit = 2, MaxSpecials = 4, CommonLimit = 100, SpawnDirectionMask = SPAWNDIR_SE | SPAWNDIR_S }, NextDelay = DelayTimeMedium }

stage4 <-
{ name = "wave 4", params = { DefaultLimit = 1,  HunterLimit = 2, SmokerLimit = 2, SpitterLimit = 2, MaxSpecials = 6, CommonLimit = 100, SpawnDirectionMask = SPAWNDIR_NE }, NextDelay = DelayTimeShort } 

stage5 <-
{ name = "wave 5", params = { DefaultLimit = 1, BoomerLimit = 0, SpitterLimit = 0, MaxSpecials = 4, CommonLimit = 100, SpawnDirectionMask = SPAWNDIR_SW }, NextDelay = DelayTimeMedium } 

stage6 <-
{ name = "wave 6", params = { DefaultLimit = 2,  SmokerLimit = 3, MaxSpecials = 6, CommonLimit = 100, SpawnDirectionMask = SPAWNDIR_NW | SPAWNDIR_SE }, NextDelay = DelayTimeMedium } 

stage7 <-
{ name = "wave 7", params = { DefaultLimit = 1,  BoomerLimit = 2, SpitterLimit = 6, MaxSpecials = 8, CommonLimit = 100, SpawnDirectionMask = SPAWNDIR_NE }, NextDelay = DelayTimeShort } 

stage8 <-
{ name = "wave 8", params = { DefaultLimit = 2,  HunterLimit = 4, JockeyLimit = 4, SmokerLimit = 5, MaxSpecials = 10, CommonLimit = 100, SpawnDirectionMask = SPAWNDIR_NE | SPAWNDIR_SW }, NextDelay = DelayTimeMedium } 

stage9 <-
{ name = "wave 9", params = { DefaultLimit = 4,  MaxSpecials = 10, CommonLimit = 100, SpawnDirectionMask = SPAWNDIR_NE | SPAWNDIR_SW | SPAWNDIR_NW }, NextDelay = DelayTimeMedium } 

stage10 <-
{ name = "wave 10", params = { DefaultLimit = 4,  MaxSpecials = 12, CommonLimit = 100, SpawnDirectionMask = SPAWNDIR_NE | SPAWNDIR_SW | SPAWNDIR_NW }, NextDelay = DelayTimeMedium } 

//---------------------------------------------------------
// this is a stage table we'll just mess with in code a bit rather than keep writing them out
//---------------------------------------------------------
stage10plus <-
{ 
	name = "wave 10+", 
	params = {	BoomerLimit = 4, ChargerLimit = 4, HunterLimit = 4, JockeyLimit = 4, SpitterLimit = 4, SmokerLimit = 4, MaxSpecials = 14, CommonLimit = 100, SpawnDirectionCount = 2 }, 
	NextDelay = DelayTimeShort 
}

//=========================================================
// so the idea is for stages after 10, rather than keep 
// defining ones, we just call the random thing
//=========================================================
function RandomizeStage10Plus ( raw_stage_num )
{
	stage10plus.params.MaxSpecials = RandomInt(12,19) + (raw_stage_num / 4)
	// now, per type limits
	foreach (val in SpecialNames)
	{
		local limit = RandomInt(2,5) + (raw_stage_num / 10)
		stage10plus.params[val + "Limit"] = limit
	}
	// if we wanted to do Masks here, we could have a table and just RandomInt an index into that table instead
	//    i.e. local dir_table = [ SPAWNDIR_N, SPAWNDIR_NE | SPAWNDIR_SW, SPAWNDIR_W ]
	//         stage10plus.params.SpawnDirectionMask = dir_table[RandomInt(0,2)]
	// or write code to always pick 2 "next door" directions in the Mask, instead of just using count - prob better
	//    i.e. local first_dir = 1 << RandomInt(0,7)
	//         stage10plus.params.SpawnDirectionMask = first_dir + (first_dir<<1)  // yea, wrap broken, maybe use table, bleh
	if ( RandomInt(0,10) > 8 )
		stage10plus.params.SpawnDirectionCount = 1
	else if ( RandomInt(0, 10) > 8)
		stage10plus.params.SpawnDirectionCount = 3
	else
		stage10plus.params.SpawnDirectionCount = 2
	// ps. id think we'd want to play w/CommonLimit too - not sure where 100 everywhere? incorrect?
	return stage10plus
}

//=========================================================
// also, could write sample one based on Node instead easily
//=========================================================
function GetAttackStage()
{   
	// local use_stage = CheckForSpecialStage( SessionState.ScriptedStageWave, stages_special, stages_special_info )
	// if (use_stage != null)
	// 	return use_stage

	if ( SessionState.ScriptedStageWave > 10 )
	{
		return RandomizeStage10Plus ( SessionState.RawStageNum )
	}
	else
	{
		local stage_name = "stage" + SessionState.ScriptedStageWave
		return this[stage_name]
	}
}

//=========================================================
//=========================================================
function EscapeWaveCB( stageData )
{
	g_RoundState.g_RescueManager.EnableRescue()
}

//---------------------------------------------------------
// Director configuration data for when survivors are trying
// to escape to the rescue vehicle
//---------------------------------------------------------
stageEscape <-
{ 
	name = "escape wave", 
	params = { TankLimit = 1, DefaultLimit = 4, JockeyLimit = 5, MaxSpecials = 17, CommonLimit = 100, SpawnDirectionMask = SPAWNDIR_W | SPAWNDIR_E | SPAWNDIR_N },
	callback = EscapeWaveCB, 
	type = STAGE_ESCAPE 
}

//=========================================================
//=========================================================
function witchWaveCB( stageData )
{
	smDbgPrint( "Witch Wave CB" )
	// this is necessary for making witches attack as soon as they spawn
	EntFire( "@command", "command", "witch_rage_ramp_duration 1", 0 )
	
	g_RoundState.WitchManager.ReleaseTombstoneWitches()	
}

//---------------------------------------------------------
// if cool, maybe we'd have a "set a value" - i.e. along 
// w/callback and trigger have "setvar" or something?
//---------------------------------------------------------
stageWitchWave <-
{ 
	name = "witchwave", 
	params = { DefaultLimit = 0, MaxSpecials = 0, CommonLimit = 0 }, 
	callback = witchWaveCB
}

//=========================================================
//function StartDelayStage( stageData )
//=========================================================
function DelayCB( stageData )
{
	smDbgPrint( "In Delay Callback " + stageData.value )

	// check to see if tanks should spawn
	g_RoundState.TankManager.ManholeTankSpawnCheck()

	// Time to spawn witches?
	g_RoundState.WitchManager.WitchSpawnCheck()

	// release the supply balloon?
	g_RoundState.ResupplyBalloonManager.ResupplyBalloonSpawnCheck()
}

//---------------------------------------------------------
//---------------------------------------------------------
stageDelay <-
{ 
	name = "delay",
	params = { DefaultLimit = 0, MaxSpecials = 0, BileMobSize = 20 },
	callback = DelayCB, type = STAGE_DELAY, value = 60 
	// the 60 will get rewritten per stage from NextDelayVal
}


//=========================================================
//=========================================================
function AllowTakeDamage( damageTable )
{	
	// mitigate mine damage on players
	if( damageTable.Attacker.GetName().find( "mine_1_exp") && damageTable.Victim.GetClassname() == "player" )
	{
		if( damageTable.Victim.IsSurvivor() )
		{
			ScriptedDamageInfo.DamageDone = 5
		}
		return true
	}

	// If a melee weapon hits a breakable door (barricades are doors)
	// then increase the damage so it breaks more quickly
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


///////////////////////////////////////////////////////////////////////////////
//
// The main loop callbacks for this map
//
///////////////////////////////////////////////////////////////////////////////

//=========================================================
//=========================================================
function DoMapSetup()
{
	CreateTrainingHints( InstructorHintTable )

	// spawn fireaxe 
	local axeOrigin = Vector( -6069.945, 7596.355, 100.080 )
	local axeAngles = Vector( 20,45,20 )

	SpawnMeleeWeapon( "fireaxe", axeOrigin, axeAngles )
		
	// add 2 manhole tanks to the game
	g_RoundState.TankManager.ManholeTankSetup( 2 )

	// add the witch event to the game
	g_RoundState.WitchManager.WitchSetup()
}

//=========================================================
// Called by the start box code when any survivor leaves the start box. 
// If a survivor leaves the start box, we take that to mean that they're ready, so we start the action
//=========================================================
function SurvivorLeftStartBox()
{
	EndTrainingHints( 15 )
	Director.ForceNextStage()
}

//=========================================================
//=========================================================
function Precache()
{
	Startbox_Precache()
}

function OnActivate()
{
	// and start the gascan action
	g_RoundState.g_GascanManager.StartGascanSpawns()

	//teleport players to the start point
	if (!TeleportPlayersToStartPoints( "gamemode_playerstart" ) )
		printl(" ** TeleportPlayersToStartPoints: Spawn point count or player count incorrect! Verify that there are 4 of each.")
	
	if ( !SpawnStartBox( "startbox_origin", true, 1064, 736 ) )
	{
		printl("Warning: No startbox_origin in map.\n  Place a startbox_origin entity in order to spawn a game start region.\n")
		// should auto-start now...
	}	
	
	// do this after the items have spawned so the items will get the calls to update their glow state
	g_ResourceManager.AddResources( SessionState.InitialResources )

	ScriptedMode_AddSlowPoll( MapSlowPoll )
	
	RescueTimer_Set( SessionState.RescueTime )

	// display script debug overlay
	DisplayScriptDebugOverlays()
}

function DoMapShutdown()
{
	ClearStartBox()
	ScriptedMode_RemoveSlowPoll( MapSlowPoll )
}

//=========================================================
//=========================================================
function DisplayScriptDebugOverlays()
{
	ScriptDebugClearWatches()
	
	// current wave
	ScriptDebugAddWatch( @() "Current Wave: " + SessionState.ScriptedStageWave )

	// witch data
	ScriptDebugAddWatch( @() "Witch spawning on Wave: " + g_RoundState.WitchManager.GetWitchSpawnWave() )

	// tank data
	for( local i=0; i<g_RoundState.TankManager.ManholeTankList.len(); i++ )
	{
		local x = i
		ScriptDebugAddWatch( @() "Manhole tank spawning on wave: " + g_RoundState.TankManager.ManholeTankList[x].SpawnWave )
	}
}

//=========================================================
//=========================================================
function DoMapEventCheck( )
{
	// time to release a tank?
	g_RoundState.TankManager.ManholeTankReleaseCheck()

	// release the supply balloon?
	g_RoundState.ResupplyBalloonManager.ResupplyBalloonSpawnCheck()
}

//=========================================================
//=========================================================
function GetMapEscapeStage( )  
{
	Ticker_SetBlink( true )
	Ticker_NewStr("Here comes the rescue chopper")
	return stageEscape
}

//=========================================================
//=========================================================
function IsMapSpecificStage( )
{
	if ( g_RoundState.WitchManager.IsActivating() )
		return true
	return false
}

//=========================================================
//=========================================================
function GetMapSpecificStage()
{
	if (  g_RoundState.WitchManager.IsActivating() )
		return stageWitchWave
	printl( "HEY! who called GetMapSpecificStage given that witchchurch isnt activating...???" )
	return null
}

//=========================================================
// this could just be a "stageClearout" - but wanted to test 
// the "just set some DO variables yourself and return null" path
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
	if ( "NextDelayTime" in SessionState )
		stageDelay.value = SessionState.NextDelayTime	   
	else
		stageDelay.value = DelayTimeMedium
	return stageDelay
}
