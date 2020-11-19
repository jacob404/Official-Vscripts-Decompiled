///////////////////////////////////////////////////////////////////////////////
// HOLDOUT Scripted Mode
//
// For the Houseboat map 
///////////////////////////////////////////////////////////////////////////////

IncludeScript("sm_resources", g_MapScript)

//---------------------------------------------------------
// The Map Specific Spawn, State, Options, and Sanitize data
//---------------------------------------------------------
MapSpawns <-
[
	[ "AmmoCrate"],
	[ "WallBarricade"],
	[ "WindowBarricade"],
	[ "BuildableMinigun"],
	[ "DefibCabinet"],
	[ "FootlockerThrowables"],
	[ "HealthCabinet"],
	[ "ResupplyHelicopter"],
	[ "PlaceableResource"],
	[ "MedCabinet"],
	[ "Tier1WeaponCabinet"],
	[ "Tier2WeaponCabinet"],
	[ "TankManhole"],
	[ "CooldownExtensionButton"],
	[ "WrongwayBarrier" ],
	[ "RescueHelicopter"],
	[ "Hintboard" ],
	[ "Combiner" ],
]	

// configure our HUD and a few config elements
MapState <-
{
	InitialResources = 0
	HUDWaveInfo = true
	HUDRescueTimer = false
	HUDTickerText = "Objective: Hold out for 10 waves and then get to the chopper!  Use the radio to start."
	StartActive = true
	
	ForcedEscapeStage = 28

	CooldownEndWarningChance = 100 // crank up the chance of playing the end of wave warning
}

MapOptions <-
{
	SpawnSetRule = SPAWN_POSITIONAL
	SpawnSetRadius = 2000
	SpawnSetPosition = Vector( 3752, -4148, -89 )
}

//---------------------------------------------------------
// entities to sanitize on map spawn
//
// 'Sanitizing' is deleting entities from a map that are 
// not wanted or needed by this scripted mode. This frees 
// up memory and CPU, as well as removing map logic that
// could interfere with our Scripted Mode.
//---------------------------------------------------------
SanitizeTable <-
[
	// fire these outputs on map spawn
	{ classname		= "prop_minigun_l4d1", input = "kill" },
	{ classname		= "func_breakable", input = "break" },
	{ classname		= "prop_door_rotating", input = "kill" },
	{ classname		= "weapon_*", input = "kill" },
	{ classname		= "trigger_finale", input = "kill" },
	{ model			= "models/props_junk/gascan001a.mdl" input = "kill" }, // gascans
	{ targetname	= "radio_button", input = "kill" }, // old radio
	{ targetname	= "radio_model", input = "kill" }, // old radio
	{ targetname	= "trigger_start_radio", input = "kill" },
	{ targetname	= "trigger_boat", input = "kill" },
	{ targetname	= "relay_radio_triggerbutton2", input = "kill" },
	{ targetname	= "dock*", input = "kill" },
	{ targetname	= "orator_boat_radio", input = "kill" },
	{ targetname	= "target_boat_radio_speaker", input = "kill" },
	{ targetname	= "radio_game_event*", input = "kill" },
	{ classname		= "prop_physics", position = Vector( 4068, -3940, -21), input = "kill" } // railing
	{ classname		= "prop_physics", position = Vector( 4015.410,-4623.720,-151.531 ), input = "sethealth", param = "99999999" } // jack up the health on picnic table (for combiner)
	{ classname		= "prop_physics", position = Vector( 4015.410,-4623.720,-151.531 ), input = "disablemotion" } // disable motion on picnic table (for combiner)

	// escape boat ents
	{ targetname	= "outro", input = "kill" },
	{ targetname	= "relay_start_boat", input = "kill" },
	{ targetname	= "relay_stop_boat", input = "kill" },
	{ targetname	= "relay_leave_boat", input = "kill" },
	{ targetname	= "relay_init_boat", input = "kill" },
	{ targetname	= "relay_outro_start", input = "kill" },
	{ targetname	= "goal_infected", input = "kill" },
	{ targetname	= "fade_outro_*", input = "kill" },
	{ targetname	= "gameinstructor_disable", input = "kill" },
	{ targetname	= "camera_outro", input = "kill" },
	{ targetname	= "ghostanim_outro", input = "kill" },
	{ targetname	= "survivors", input = "kill" },
	{ targetname	= "brush_boat_deck", input = "kill" },
	{ targetname	= "track_boat_lighting", input = "kill" },
	{ targetname	= "template_boat", input = "kill" },
	{ targetname	= "filter_infected", input = "kill" },
	{ classname		= "prop_physics", position= Vector( 3702, -4041, -88 ), input = "kill" },

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
]

//---------------------------------------------------------
// Here are the strings that will be doled out as hints when players use the corkboard
//---------------------------------------------------------
HintBoardStringTable <-
[
	["Wait for specials to get close before killing them so their loot will drop nearby"],
	["Barricade the manhole if you are not ready to fight the tank"],
	["Melee weapons break down barricades more quickly than bullets"],
	["The explosive locker can only be opened once. Use the items inside wisely!"],
	["There have been reports of filthy necromancers defiling picnic tables in the area..."],
]

//---------------------------------------------------------
// We'll pass this table to CreateTrainingHints when the map starts for the first time
//---------------------------------------------------------
InstructorHintTable <-
[
	{ targetname = "hintboard_script_hint", mdl = "models/props/cs_office/offcorkboarda.mdl", targetEntName = "hintboard", hintText = "Map Hints!" }
	{ targetname = "tier_1_script_hint", mdl = "models/props_unique/guncabinet_door.mdl", targetEntName = "gun_cabinet_door", hintText = "Tier 1 Guns" }
	{ targetname = "tier_2_script_hint", mdl = "models/props_unique/guncabinet01_ldoor.mdl", targetEntName = "gun_cabinet_doors", hintText = "Tier 2 Guns" }
	{ targetname = "first_aid_script_hint", mdl = "models/props_buildables/small_cabinet_firstaid.mdl", targetEntName = "health_cabinet", hintText = "First Aid Kits" }
	{ targetname = "throwables_hint", mdl = "models/props_waterfront/footlocker01.mdl", targetEntName = "footlocker", hintText = "Explosives" }
]

//=========================================================
//=========================================================
function BeginSupplyDrop( stageData )
{
	Ticker_SetBlink( true )
	Ticker_NewStr( "Here comes a helicopter supply drop! Look for orange smoke to find the impact site.", 30 )
	g_RoundState.ResupplyHelicopter.SummonHelicopter()
}

//=========================================================
//=========================================================
function FirstWaveCB( stageData )
{
	Ticker_SetBlink( true )
	Ticker_NewStr( "Here they come! Survive 10 waves!", 10 )
}

//=========================================================
//=========================================================
function EscapeWaveCB( stageData ) 
{
	g_RoundState.g_RescueManager.EnableRescue()

	//call the rescue chopper!
	g_RoundState.g_RescueManager.SummonRescueChopperCheck()	
}

///////////////////////////////////////////////////////////////////////////////
//
// Stage Definitions for this map
//
///////////////////////////////////////////////////////////////////////////////

// delay time constants to make stage definition easier
DelayTime <- 30	
DelayTimeShort <- 25
DelayTimeMedium <- 30
DelayTimeLong <- 35

stageDefaults <-
{ name = "default", type = STAGE_PANIC, value = 1,
	params = { PanicWavePauseMax = 1, BileMobSize = 20, TankLimit = 1, SpawnDirectionCount = 0, SpawnDirectionMask = 0, AddToSpawnTimer = 6 }, 
	callback = null, trigger = null, NextDelay = DelayTime } 

stage1 <-
{ name = "wave 1", params = { PanicWavePauseMax = 5, DefaultLimit = 1, MaxSpecials = 2, SpitterLimit = 0, ChargerLimit = 0, BoomerLimit = 0, CommonLimit = 30, SpawnDirectionMask = SPAWNDIR_NE}, NextDelay = DelayTimeShort, callback = FirstWaveCB }

stage2 <-
{ name = "wave 2", params = { DefaultLimit = 1, MaxSpecials = 3, HunterLimit = 2, BoomerLimit = 0, SpitterLimit = 0, CommonLimit = 30, SpawnDirectionMask = SPAWNDIR_NW }, NextDelay = DelayTimeMedium }

stage3 <-
{ name = "wave 3", params = { DefaultLimit = 1, MaxSpecials = 4, JockeyLimit = 2, BoomerLimit = 0, SmokerLimit = 2, CommonLimit = 50, SpawnDirectionMask = SPAWNDIR_SW }, NextDelay = DelayTimeMedium }

stage4 <-
{ name = "wave 4", params = { DefaultLimit = 1, MaxSpecials = 6, HunterLimit = 2, SmokerLimit = 2, CommonLimit = 50, SpawnDirectionMask = SPAWNDIR_NE }, NextDelay = DelayTimeMedium } 

stage5 <-
{ name = "wave 5", params = { DefaultLimit = 1, MaxSpecials = 4, SpitterLimit = 0, BoomerLimit = 0, CommonLimit = 20, SpawnDirectionMask = SPAWNDIR_SW }, NextDelay = DelayTimeLong }

stage6 <-
{ name = "wave 6", params = { DefaultLimit = 2, MaxSpecials = 6, SmokerLimit = 3, CommonLimit = 50, SpawnDirectionMask = SPAWNDIR_NW }, NextDelay = DelayTimeMedium }

stage7 <-
{ name = "wave 7", params = { DefaultLimit = 1, MaxSpecials = 8, BoomerLimit = 2, SpitterLimit = 6, CommonLimit = 50, SpawnDirectionMask = SPAWNDIR_NE }, callback = BeginSupplyDrop, NextDelay = DelayTimeShort }

stage8 <-
{ name = "wave 8", params = { DefaultLimit = 2, MaxSpecials = 10, HunterLimit = 4, JockeyLimit = 4, SmokerLimit = 5, CommonLimit = 50, SpawnDirectionMask = SPAWNDIR_NE|SPAWNDIR_SW }, NextDelay = DelayTimeMedium }

stage9 <-
{ name = "wave 9", params = { DefaultLimit = 4, MaxSpecials = 10, CommonLimit = 50, SpawnDirectionMask = SPAWNDIR_NE|SPAWNDIR_NW|SPAWNDIR_SW }, NextDelay = DelayTimeMedium }

stage10 <-
{ name = "wave 10", params = { DefaultLimit = 4, MaxSpecials = 10, CommonLimit = 50, SpawnDirectionMask = SPAWNDIR_NE|SPAWNDIR_NW|SPAWNDIR_SE }, callback = EscapeWaveCB, NextDelay = DelayTimeShort }


stageEscape <-
{ name = "escapeWave", type = STAGE_ESCAPE, value = 3,
	params = { DefaultLimit = 4, MaxSpecials = 6, CommonLimit = 50 },
	callback = EscapeWaveCB }

//=========================================================
//function StartDelayStage( stageData )
//=========================================================
function DelayCB( stageData )
{
	// check to see if tanks should spawn
	g_RoundState.TankManager.ManholeTankSpawnCheck()
}
	
stageDelay <-
{ name = "delay",
	params = { DefaultLimit = 0, MaxSpecials = 0, BileMobSize = 0 }
	callback = DelayCB, type = STAGE_DELAY, value = 60 }   // the 60 will get rewritten per stage from NextDelayVal

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
// Called by the start box code when any survivor leaves the
// start box. If a survivor leaves the start box, we take
// that to mean that they're ready, so we start the action
//=========================================================
function SurvivorLeftStartBox()
{
	// turn off the training hints in 30 seconds
	EndTrainingHints( 30 )
	Director.ForceNextStage()
}

//=========================================================
//=========================================================
function DoMapSetup()
{
	Ticker_SetTimeout( 0 ) // keeps start ticker text on screen

	CreateTrainingHints( InstructorHintTable )

	// spawn fireaxe 
	local axeOrigin = Vector( 5200, -3054, -38 )
	local axeAngles = Vector( 20,45,20 )
	SpawnMeleeWeapon( "fireaxe", axeOrigin, axeAngles )
	
	g_RoundState.TankManager.ManholeTankSetup( 2 )
}

//=========================================================
// Activate and Shutdown code
//=========================================================
function Precache()
{
	Startbox_Precache()
}

function OnActivate()
{
	//teleport players to the start point
	if (!TeleportPlayersToStartPoints( "playerstart*" ) )
		printl(" ** TeleportPlayersToStartPoints: Spawn point count or player count incorrect! Verify that there are 4 of each.")

	if ( !SpawnStartBox( "startbox_origin", true, 1200, 1100 ) )
	{
		printl("Warning: No startbox_origin in map.\n  Place a startbox_origin entity in order to spawn a game start region.\n")
		// should auto-start now... do we need to forcenextstage?
	}	

	g_ResourceManager.AddResources( SessionState.InitialResources )
}

function OnShutdown()
{
	ClearStartBox()
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
	Ticker_NewStr("Here comes the Rescue Chopper!")
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
function PickupObject( object )
{
	// resource drops
	if ( object.GetName().find( "ingredient" ) )
	{
		return true
	}
	
	return false
}

//=========================================================
//=========================================================
function GetMapDelayStage()
{
	switch( SessionState.ScriptedStageWave )
	{
		case 1:
			Ticker_NewStr( "Now would be a good time to heal, barricade, explore and spend supplies", 20 )
			break
		
		case 9:
			Ticker_SetBlink( true )
			Ticker_NewStr( "The rescue chopper will pick you up on the docks very soon!", 20)
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

//=========================================================
//=========================================================
function DoMapEventCheck()
{
	//time to release a tank?
	g_RoundState.TankManager.ManholeTankReleaseCheck()
}
