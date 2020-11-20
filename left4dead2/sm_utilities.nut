///////////////////////////////////////////////////////////////////////////////
//
// A collection of utilities and helpers for new script mutations
//
///////////////////////////////////////////////////////////////////////////////

//printl("Loading sm_utilities.nut")

//=========================================================
// Teleport players to spawn points
//=========================================================
scripthelp_TeleportPlayersToStartPoints <- "Teleport players to start entities named by the argument - must have 4 spawnpoints"
function TeleportPlayersToStartPoints( spawnpointName )
{
	// Teleport players to spawn points
	local FindPlayerEntity = null
	local FindSpawnPointEntity = null
	local playercount = 0
	local spawnpointcount = 0
		
	while ( FindPlayerEntity = Entities.FindByClassname( FindPlayerEntity, "player" ) )
	{			
		if ( !FindPlayerEntity.IsSurvivor() )
			continue
				
		++playercount
		if( FindSpawnPointEntity = Entities.FindByName( FindSpawnPointEntity, spawnpointName ) )
		{
			spawnpointcount++				
			FindPlayerEntity.SetOrigin( FindSpawnPointEntity.GetOrigin() )
		}
	}
		
	if( spawnpointcount != 4 )
		return false

	return true
}

//---------------------------------------------------------
// Entity group spawn flags used by MapSpawn table
//---------------------------------------------------------
::SPAWN_FLAGS <-
{
	SPAWN	= (1<<0),	// default. spawn on map spawn.
	NOSPAWN	= (1<<1),	// include the entity group but do not spawn the entity
	TARGETSPAWN = (1<<2), // spawn to a set number of targets
}

///////////////////////////////////////////////////////////////////////////////
// StartBox tables and functions
//
// The startbox is a procedurally generated box on the ground around a point
// which makes it easy to create a new start area for a map, and know when players first leave it
// if you dont want to have your mutation start at usual safe house but also dont want to have to write code
//
// The code allows some amount of general control of a startbox, what model, what size, etc
// And stores a few globals so it can easily remove itself on demand, knows its center object, etc
///////////////////////////////////////////////////////////////////////////////

g_RoundState.smStartboxList <- []			// all the startbox spawned barricade objects
g_RoundState.smStartboxCenter <- null		// the center object
g_RoundState.smStartboxRemoveAll <- true	// are we supposed to delete everything after (false for ground)

//=========================================================
// callbacks for managing the post-spawn startbox data - for later cleanup
//=========================================================
function StoreStartboxCB( startboxObj, rarity )
{
	g_RoundState.smStartboxList.append( startboxObj )
}

function StoreStartboxCenterCB( startboxcenterObj, rarity )
{
	g_RoundState.smStartboxCenter = startboxcenterObj
}

//-------------------------------------
// These are the spawn tables for the center point and the two types of outer shell model used in startboxes
//-------------------------------------
StartboxSpeedbump_Info <-
{
	classname = "prop_dynamic"
	model = "models/props_placeable/speedBump.mdl"
	angles = Vector(0,0,0)
	origin = Vector(0,0,0)
}

StartboxFloating_Info <-
{
	classname = "prop_dynamic"
	model = "models/props_placeable/striped_barricade.mdl"
	angles = Vector(0,0,0)
	solid = "0"
	origin = Vector(0,0,0)
}

StartboxCenter_Info <-
{
	classname = "info_item_position"
	angles = Vector(0,0,0)
	vscripts = "startbox"
	thinkfunction = "Think"
	movetype = "0"
	spawnflags = "8"
}

function Startbox_Precache( )
{
	PrecacheEntityFromTable( StartboxFloating_Info )
	PrecacheEntityFromTable( StartboxSpeedbump_Info )
}

//=========================================================
// this spawns a start box around the named object, of width and height, using barriermodel
//=========================================================
scripthelp_SpawnStartBox <- "Auto-create a startbox that will give you a callback when the first player exits it"
function SpawnStartBox( centerobjname, useFloating = true, width = 384, depth = 384, barriermodel = null, min_gap = 12 )
{
	local center_ent = Entities.FindByName( null, centerobjname )
	if (center_ent == null || width <= 0 || depth <= 0)
		return false

	local visualToSpawn = useFloating ? StartboxFloating_Info : StartboxSpeedbump_Info
	g_RoundState.smStartboxRemoveAll = useFloating

	local box_origin = center_ent.GetOrigin()
	local sbCenter = CreateSingleSimpleEntityFromTable( StartboxCenter_Info, center_ent )
	g_RoundState.smStartboxCenter = sbCenter
	local centerScr = g_RoundState.smStartboxCenter.GetScriptScope()
	centerScr.SetSBSize( width, depth )
	
	// compute the bounding area 
	local forw = center_ent.GetForwardVector()
	local targ_angles = center_ent.GetAngles()
	visualToSpawn.angles <- Vector( targ_angles.x, targ_angles.y, targ_angles.z )

	// need to do something smarter with Z!!!

//	printl( "Start box forward looks like " + forw + " and " + Items_StartboxVisuals.SpawnInfo.angles )
	local barr_width = 60 // can we get this from the model somehow

	local num_wide = width / barr_width
	if (num_wide < 1)
		num_wide = 1   // deal with width smaller than barrier
	local gap_wide = (width - (num_wide * barr_width)) / num_wide
	while ( num_wide > 1 && gap_wide < min_gap )
	{
		num_wide--
		gap_wide = (width - (num_wide * barr_width)) / num_wide
	}

	local num_deep = depth / barr_width
	if (num_deep < 1)
		num_deep = 1   // deal with width smaller than barrier
	local gap_deep = (depth - (num_deep * barr_width)) / num_deep
	while ( num_deep > 1 && gap_deep < min_gap )
	{
		num_deep--
		gap_deep = (depth - (num_deep * barr_width)) / num_deep
	}

	// need to do Z smarter!!!
	local front_mid = forw.Scale(depth/2.0)
	local bk = forw.Scale(-depth)
	local side_step = Vector ( -forw.y, forw.x, 0)
	local per_barr = barr_width + gap_wide 
	local st = front_mid - (side_step * (per_barr * (num_wide - 1) / 2.0) )
	st.z = front_mid.z

	visualToSpawn.angles.y += 90;
	for ( local i_w = 0; i_w < num_wide; i_w++ )
	{
		visualToSpawn.origin = box_origin + st + side_step * (per_barr * i_w)
		g_RoundState.smStartboxList.append( CreateSingleSimpleEntityFromTable( visualToSpawn ) )
		visualToSpawn.origin = box_origin + st + bk + side_step * (per_barr * i_w)
		g_RoundState.smStartboxList.append( CreateSingleSimpleEntityFromTable( visualToSpawn ) )
	}

	// for the sides, just do the x,y -> -y,x trick, since we know forw is a unit vector
	local side_mid = Vector( width/2.0 * forw.y, -width/2.0 * forw.x, width/2.0 * forw.z )
	bk = Vector ( -width * forw.y, width * forw.x, -width * forw.z )
	side_step = Vector ( forw.x, forw.y, 0)
	per_barr = barr_width + gap_deep 
	st = side_mid - ( side_step * (per_barr * (num_deep - 1) / 2.0 ) )
	st.z = side_mid.z

	// then the left and right sides, i.e. the depth ones
	visualToSpawn.angles.y += 90;
	for ( local i_d = 0; i_d < num_deep; i_d++ )
	{
		visualToSpawn.origin = box_origin + st + side_step * (per_barr * i_d)
		g_RoundState.smStartboxList.append( CreateSingleSimpleEntityFromTable( visualToSpawn ) )
		visualToSpawn.origin = box_origin + st + bk + side_step * (per_barr * i_d)
		g_RoundState.smStartboxList.append( CreateSingleSimpleEntityFromTable( visualToSpawn ) )
	}

//	printl("Built startbox size " + width + "x" + depth + "\n chose " + num_wide + " across and " + num_deep + " deep\n which gave gaps of " + gap_wide + " and " + gap_deep)

	return true
}

function ClearStartBox( )
{
	if ( g_RoundState.smStartboxRemoveAll )
	{
		foreach ( ent in g_RoundState.smStartboxList )
		{
			EntFire( ent.GetName(), "Kill" )
		}
		g_RoundState.smStartboxList <- null
	}
	if ( g_RoundState.smStartboxCenter != null )
	{
		EntFire( g_RoundState.smStartboxCenter.GetName(), "Kill" )
		g_RoundState.smStartboxCenter = null
	}
	g_RoundState.smStartboxRemoveAll = false
}


///////////////////////////////////////////////////////////////////////////////
//
// Radio helper stuff
//
///////////////////////////////////////////////////////////////////////////////
function RadioSpawnCB( entity, rarity)
{
	entity.ValidateScriptScope()
	//get the radio's script scope
	local radioScope = entity.GetScriptScope()

	radioScope.Used <- function()
	{
		// Notify the map script that the starting line has been touched
		if ("StartRadioUsed" in g_MapScript)
			g_MapScript.StartRadioUsed()   // if you need to do additional work
		else
			Director.ForceNextStage()   // default is just "go to next stage"
		
		EntFire( entity, "Lock" )
		EmitSoundOn( "npc.soldier_RadioButton210", entity )
	}

//	entity.ConnectOutput( "OnOpen", "Used" )   // lets put the function in before connecting it, for safety
}


///////////////////////////////////////////////////////////////////////////////
// Debug helpers
//
//  Things that are really for during development - you really should never call any of this 
//  in final/real/workshop submitted code
///////////////////////////////////////////////////////////////////////////////

// if you want a table printed to console formatted like a table (dont we already have this somewhere?)
scripthelp_DeepPrintTable <- "Print out a table (and subtables) to the console"
function DeepPrintTable( debugTable, prefix = "" )
{
	if (prefix == "")
	{
		printl("{")
		prefix = "   "
	}
	foreach (idx, val in debugTable)
	{
		if ( typeof(val) == "table" )
		{
			printl( prefix + idx + " = \n" + prefix + "{")
			DeepPrintTable( val, prefix + "   " )
			printl(prefix + "}")
		}
		else if ( typeof(val) == "string" )
			printl(prefix + idx + "\t= \"" + val + "\"")
		else
			printl(prefix + idx + "\t= " + val)
	}
	if (prefix == "   ")
		printl("}")
}



///////////////////////////////////////////////////////////////////////////////
// Misc helpers
//  Table management, run functions on lists, merge and add defaults to tables, etc
///////////////////////////////////////////////////////////////////////////////

// @TODO: is there not a squirrel default way to do this?
scripthelp_DuplicateTable <- "This returns a deep copy of the passed in table"
function DuplicateTable( srcTable )
{
	local result = clone srcTable;
	foreach( key, val in srcTable )
	{
		if ( typeof( val ) == "table" )
		{
			result[ key ] = DuplicateTable( val )
		}
	}
	return result;
}

// List helpers, table checks/defaults - run a member or function on entities in a list
function RunMemberOnList( member_name, list_name )
{
	foreach (idx, val in list_name)
		if ( member_name in val )
			val[member_name]()
}

function RunFunctionOnList( func_name, list_name)
{
	foreach (idx, val in list_name)
		func_name( val )
}

// if you want to place a callback into the Map level script scope if it isnt there
// i.e. you can do "CheckOrSetMapCallback("CheckForFish", @(who) "HasFish" in who)"
//   and then it will check if there is a CheckForFish callback at map scope
//   if so, this call does nothing, and leaves it alone, if there isnt one, this is "injected" to mapscope
//   so that in later code, you know it is there and can just call it, rather than checking every time
scripthelp_CheckOrSetMapCallback <- "Pass a callback and default @ for it, if it doesnt exist in current table, place it there"
function CheckOrSetMapCallback( cb_name, cb_default )
{
	if ( !(cb_name in g_MapScript) )
	{
		g_MapScript[cb_name] <- cb_default
	}
}

//=========================================================
// Copy source table into the dest table.
// Duplicate keys will be overwritten by the source table's value.
// If the destination table doesn't exist, it will be created.
// This first one is for Tables, the next one is for arrays
//=========================================================
function AddDefaultsToTable( srcname, srcscope, destname, destscope )
{
	if ( (destname in destscope) && typeof(destscope[destname]) != "table" )
	{
		printl( "Warning: Hey... you can't AddDefaultToTable of a non-table " + destname )
		return
	}
	
	if ( (srcname in srcscope) && typeof(srcscope[srcname]) != "table" )
	{
		printl( "Warning: Hey... you can't AddDefaultToTable of a non-table " + srcname )
		return
	}
	
	if ( !(destname in destscope) )
	{
		destscope[destname] <- {}
	}
	
	if ( srcname in srcscope )
	{
		local srctable = srcscope[srcname]
		local desttable = destscope[destname]
		
		smDbgLoud( " Table Copying " + srctable + " into " + desttable )
		foreach ( key, val in srctable )
		{
			smDbgLoud( " Copying " + val + " into " + key )
			desttable[key] <- val
		}
	}
}

function AddDefaultsToArray( srcname, srcscope, destname, destscope )
{
	if ( (destname in destscope) && typeof(destscope[destname]) != "array" )
	{
		printl( "Warning: Hey... you can't AddDefaultToArray of a non-array " + destname )
		return
	}
	
	if ( (srcname in srcscope) && typeof(srcscope[srcname]) != "array" )
	{
		printl( "Warning: Hey... you can't AddDefaultToArray of a non-array " + srcname )
		return
	}
	
	if ( !(destname in destscope) )
	{
		destscope[destname] <- []
	}
		
	if ( srcname in srcscope )
	{
		local srcarray = srcscope[srcname]
		local destarray = destscope[destname]
		
		smDbgLoud( " Array Copying " + srcarray + " into " + destarray )
		foreach ( idx, val in srcarray )
		{
			smDbgLoud( " Checking on " + val + " [e0 is " + val[0] + "]" )
			if ( !destarray.find( val ) )
			{
				destarray.append( val )
				smDbgLoud( "  decided to Copy " + val )
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
//
// Scoring system - High-score/table type stuff
//    The dream here is that these map/mode specific scoreboards could persist in the cloud or something
//    But we dont really have any good way to do that without it exploding into infinite waste right now
//    so for now, they persist on the server machine hard drive - so yea, not so very cloud
//
//    Still, keeping it as an example, basically
///////////////////////////////////////////////////////////////////////////////

g_MutationScores <- []
g_DefaultScores <- []

// if no scores, add some defaults
function Scoring_SetDefaultScores( score_table )
{
	if (g_MutationScores == null || g_MutationScores.len() == 0)
		g_MutationScores = score_table
	g_DefaultScores = score_table
}

function Scoring_MakeFileName( mapname, modename )
{
	return  "Scores_" + mapname + "_" + modename + ".txt"
}

function Scoring_LoadTable( mapname, modename )
{
	local saved_data = FileToString( Scoring_MakeFileName( mapname, modename ) )
	if (saved_data != null)
	{
//		printl("Think we loaded the file - and got ")
//		printl(saved_data)
		local score_closure = compilestring( "return " + saved_data )
		g_MutationScores = score_closure()
		if (g_MutationScores.len() > 0 && ("time" in g_MutationScores[0]))
		{
			printl("Old score file! ignoring!")
			g_MutationScores = g_DefaultScores
		}
	}
	else
		g_MutationScores = g_DefaultScores
}

function Scoring_SaveTable( mapname, modename )
{
	local save_string = "[ "
	if (g_MutationScores && g_MutationScores.len() > 0)
	{
		foreach (idx, val in g_MutationScores)
		{
			save_string = save_string + "\n { name = \"" + val.name + "\" , score = " + val.score + " }, "
		}
		save_string = save_string + "\n]"
		StringToFile( Scoring_MakeFileName( mapname, modename ), save_string )
	}
	else
		printl("No ScoreTable to Save")
}

function Scoring_AddScore( new_name, new_score, lower_is_better = true )
{
	local score_pos = -1
	local do_insert = false

	foreach (idx, val in g_MutationScores)
	{
		if ( ( lower_is_better && new_score <= val.score) || ( (!lower_is_better) && new_score > val.score ))
		{
			do_insert = true
			score_pos = idx
			break
		}
	}
	if (do_insert)
	{
		g_MutationScores.insert(score_pos, {name=new_name, score=new_score})
		while (g_MutationScores.len() > 10)
		{
			g_MutationScores.remove(10)
		}
	}
	else if ( g_MutationScores == null || g_MutationScores.len() < 10 )   // if we have <10 scores, add to end, else we already have 10
	{
		g_MutationScores.append({name=new_name, score=new_score})
		score_pos = g_MutationScores.len() - 1
	}

	return score_pos
}

function Scoring_MakeName( )
{
	local score_names = ""
	local player_count = 0
	local FindPlayerEntity = null

	while ( FindPlayerEntity = Entities.FindByClassname( FindPlayerEntity, "player" ) )
	{
		if (FindPlayerEntity.IsSurvivor())
		{
			if (player_count > 0)
				score_names = score_names + ", "
			score_names = score_names + FindPlayerEntity.GetPlayerName()
			player_count += 1
		}
	}
	return score_names
}

pos_strs <- [ "1st", "2nd", "3rd" ]
function GetPosStr( pos )
{
	if (pos < 0)
		return "out of the scoring"
	else if (pos < 3)
		return pos_strs[pos]
	else 
		return (pos+1) + "th"
}

// need a score_time to display function
scripthelp_TimeToDisplayString <- "Convert a # of seconds to a displayable time string form m:ss"
function TimeToDisplayString( disp_time )
{
	local minutes = ( disp_time / 60 ).tointeger()
	local seconds_10s = ( ( disp_time % 60) / 10 ).tointeger()
	local seconds_1s = ( disp_time % 10 ).tointeger()
	return minutes + ":" + seconds_10s + seconds_1s
}

// should this always just use Ticker?
function Scoring_AddScoreAndBuildStrings( name, score, show_as_time = true, lower_is_better = true )
{
	local pos = Scoring_AddScore( name, score, lower_is_better )
	local score_strings = {}
	if (show_as_time)
		score_strings.yourtime <- "Your Time was " + TimeToDisplayString(score) + "\n"
	else
		score_strings.yourscore <- "Your Score was " + score + "\n"
	if (pos != -1)
		score_strings.finish <- "and you finished " + GetPosStr(pos) + "\n"
	// now the top 4
	local scores_to_show = g_MutationScores.len() < 4 ? g_MutationScores.len() : 4
	score_strings.topscores <- []
	for (local a = 0; a < scores_to_show; a += 1 )
	{
		local score_display = show_as_time ? TimeToDisplayString(g_MutationScores[a].score) : g_MutationScores[a].score
		score_strings.topscores.append( score_display + "    " + g_MutationScores[a].name + "\n" )
	}
	return score_strings
}

///////////////////////////////////////////////////////////////////////////////
//
// Rescue Timer
//  @TODO: should be a class. Or maybe a larger table with these as subtables? probably
//
///////////////////////////////////////////////////////////////////////////////

//---------------------------------------------------------
// Rescue timer helpers so UI can interact, etc - by 
// convention Rescue Timer uses Timer3 (@todo re# from 0)
//---------------------------------------------------------
RescueTimerTimerID <- 3
RescueTimerBlinkIfOff <- true
RescueTimerFinished <- false
RescueTimerActive <- false
RescueHUDSlot <- null
RescueHUDTitle <- null

function RescueTimer_Init( hudTable, titleslot, mainslot, blinkifoff = true )
{
	hudTable.Fields.rescuetitle <- { slot = titleslot, name = "rescuetitle", dataval = "Find Fuel!", flags = 0 }  // since we are going to tweak flags
	hudTable.Fields.rescuetimer <- { slot = mainslot, name = "rescuetime", special = HUD_SPECIAL_TIMER3, flags = HUD_FLAG_BLINK | HUD_FLAG_NOBG }

	RescueHUDTitle = hudTable.Fields.rescuetitle
	RescueHUDSlot = hudTable.Fields.rescuetimer
	RescueTimerBlinkIfOff = blinkifoff
}

//=========================================================
//=========================================================
function RescueTimer_Set( initial_time )
{
	HUDManageTimers( RescueTimerTimerID, TIMER_STOP, 0 )
	HUDManageTimers( RescueTimerTimerID, TIMER_SET, initial_time )   // hmmm, we need "set countdown and stop all at once"
	if ( RescueTimerBlinkIfOff )
		RescueHUDSlot.flags = RescueHUDSlot.flags | HUD_FLAG_BLINK;
	RescueTimerFinished = false
	RescueTimerActive = false
}

//=========================================================
// if 0, it just uses whatever you last set it to
//=========================================================
function RescueTimer_Start( initial_time = 0 )  
{
	if (RescueTimerFinished)
		return
	HUDManageTimers( RescueTimerTimerID, TIMER_COUNTDOWN, initial_time )
	if ( RescueTimerBlinkIfOff )
		RescueHUDSlot.flags = RescueHUDSlot.flags & ~HUD_FLAG_BLINK;
	RescueTimerActive = true

	RescueHUDTitle.flags = RescueHUDTitle.flags & ~HUD_FLAG_BLINK
	RescueHUDTitle.dataval = "Rescue in:"
}

//=========================================================
//=========================================================
function RescueTimer_Stop( )
{
	if (RescueTimerFinished)
		return
	HUDManageTimers( RescueTimerTimerID, TIMER_STOP, 0 )
	if ( RescueTimerBlinkIfOff )
		RescueHUDSlot.flags = RescueHUDSlot.flags | HUD_FLAG_BLINK
	if ( HUDReadTimer( RescueTimerTimerID ) <= 0)
	{
		RescueTimerFinished = true
		RescueHUDTitle.dataval = "Summoned"
	}
	else
	{
		RescueHUDTitle.flags = RescueHUDTitle.flags | HUD_FLAG_BLINK
		RescueHUDTitle.dataval = "Find Fuel!"
	}
	RescueTimerActive = false
}		

//=========================================================
//=========================================================
function RescueTimer_Get()
{
	if (RescueTimerFinished)
		return 0
	return HUDReadTimer( RescueTimerTimerID )
}

//=========================================================
// should redo this to know whether it is actually moving 
// or not at the moment - hmmmm
//=========================================================
function RescueTimer_Tick()
{
	if ( !RescueTimerFinished && RescueTimerActive)
		if ( HUDReadTimer( RescueTimerTimerID ) <= 0)
			RescueTimer_Stop()
}

///////////////////////////////////////////////////////////////////////////////
// Message Ticker helpers
// 
// Creates a simple set of calls to manage a Ticker text line for convenience
// Provides set string, set timeout, hide, blink, etc
// And hooks a slowpoll so it can manage all the timing related stuff
// NOTE: you certainly can ignore all this and just do your own whatever w/slot HUD_TICKER
//
// @todo: same as timer - should be a master table
//
///////////////////////////////////////////////////////////////////////////////

// Ticker config variables and a few easy set/modify calls
TickerShowing <- false
TickerLastTime <- 0
TickerTimeout <- 10
TickerHUDSlot <- null
TickerBlinkTime <- 5

// this really wants to self-register an "Update" iff it has a timeout... hmmm
function Ticker_SetTimeout( val )
{
	TickerTimeout = val
}

function Ticker_SetBlinkTime( val )
{
	TickerBlinkTime = val
}

function Ticker_SetBlink( BlinkOn )
{
	if (TickerHUDSlot == null)
	{
		printl("You need a HUD and to Ticker_AddToHud a Ticker before you use it!")
		return false
	}
	if( BlinkOn )
	{
		TickerHUDSlot.flags = TickerHUDSlot.flags | HUD_FLAG_BLINK
	}
	else
	{
		TickerHUDSlot.flags = TickerHUDSlot.flags & ~HUD_FLAG_BLINK
	}
}

function Ticker_Hide( )
{
	if (TickerShowing)
	{
		TickerShowing = false
		TickerLastTime = 0
		TickerHUDSlot.flags = TickerHUDSlot.flags | HUD_FLAG_NOTVISIBLE
	}
}

//=========================================================
// actually put our ticker config into a hudTable, and hook slow poll/init vars
//=========================================================
scripthelp_Ticker_AddToHud <- "adds ticker data to a passed in HUDTable"
function Ticker_AddToHud( hudTable, strInit, blink = false )
{
	if ( ! ("Fields" in hudTable ) )  // if you are setting up a Ticker Only HUD
		hudTable.Fields <- {}
	hudTable.Fields.ticker <- { slot = HUD_TICKER, name = "ticker", dataval = strInit, flags = 0 }
	TickerHUDSlot = hudTable.Fields.ticker   // reference the real table
	TickerShowing = true
	TickerLastTime = Time()
	if (blink)
		TickerHUDSlot.flags = TickerHUDSlot.flags | HUD_FLAG_BLINK
	ScriptedMode_AddSlowPoll( Ticker_SlowPoll )
}

// little helper if you want to just have a Ticker as a HUD, but really, just do this locally
function CreateTickerOnlyHUD( startStr = "" )
{
	TickerHUD <- {}
	Ticker_AddToHud( TickerHUD, startStr )
	HUDSetLayout( TickerHUD )
	HUDPlace( HUD_TICKER, 0.25, 0.04, 0.5, 0.08 )
}

//=========================================================
// this is slowpoll function the ticker uses to manage the timers
//=========================================================
function Ticker_SlowPoll( )
{
	if (TickerShowing && TickerTimeout > 0)  // i.e. on screen and has a fadeout time
		if (Time() - TickerLastTime > TickerTimeout)
			Ticker_Hide()
	if ( TickerShowing && (TickerHUDSlot.flags & HUD_FLAG_BLINK) && ( Time() - TickerLastTime > TickerBlinkTime ) )
		TickerHUDSlot.flags = TickerHUDSlot.flags & ~HUD_FLAG_BLINK
}

//=========================================================
// This puts a new string into the Ticker, and can optionally also set a new timeout value
//=========================================================
scripthelp_Ticker_NewStr <- "sets the current Ticker string, w/an optional timeout value"
function Ticker_NewStr( newStr, newTimeout = -1 )
{
	if (TickerHUDSlot == null)
	{
		printl("You need a HUD and to Ticker_AddToHud a Ticker before you use it!")
		return false
	}
	if (newTimeout != -1)
		Ticker_SetTimeout( newTimeout )
	TickerHUDSlot.dataval = newStr
	if (!TickerShowing)
	{
		TickerShowing = true
		TickerHUDSlot.flags = TickerHUDSlot.flags & ~HUD_FLAG_NOTVISIBLE
	}
	TickerLastTime = Time()
	return true
}

///////////////////////////////////////////////////////////////////////////////
//
// "clearout" manager - for waiting for a wave to end
// 
// There is of course STAGE_CLEAROUT, if you want to just let the C++ side manage waiting for the mobs to be cleared
// But if you want a more specific set of clearout behaviors (different timings, rules on mob types, whatever)
// You can use this script based Clearout "wave" manager (or extend it, or write your own)
//
// It takes a "ClearoutTable" which parameterizes the clearout you want
// and then is called once at the start of the panic wave (to track mob counts) [i.e. ClearoutNotifyPanicStart] 
// and then when the panic wave itself ends (i.e. the director thinks it is done spawning stuff)
// rather than going into a STAGE_CLEAROUT, you go into an infinite STAGE_DELAY [and call ClearoutStart]
// except you also a running a SlowPoll of Clearout_Tick (ClearoutStart automatically sets this up and makes it happen)
// and that _Tick checks the counts/monitors mobs checking against the Table's goals
// when the requirements are met, the slowpoll is removed and ForceNextStage is called to move on
//
///////////////////////////////////////////////////////////////////////////////

//---------------------------------------------------------
// a default clearout config - if you dont supply one this is used
defaultClearout <-
{
	commons = 2
	specials = 1
	tanks = 0
	witches = 0
	plateautime = 5
	plateaucommons = 6
	plateauspecials = 1
}

//---------------------------------------------------------
// globals to store the current clearout config table
// the flag is for whether you want verbose console feedback during clearout
::g_ClearoutLoud <- false
::g_ClearoutTable <- null

//=========================================================
// we use the clearout table to see whether the wave is really done 
//    (i.e. have we spawned everything and they are dead)
//=========================================================
function Clearout_Tick( )
{   
	if (g_ClearoutTable == null)
	{
		printl("Hey - how did we get Ticked with no clearout table?!?")
		ScriptedMode_RemoveSlowPoll(Clearout_Tick)
		// remove the slowpoll
		return
	}

	local bDoMoveOn = false
	local bTimerDone = false
	local infStats = {}
	GetInfectedStats( infStats )

	if (g_ClearoutLoud)
	{
		local pt = "plateautarget" in g_ClearoutTable ? g_ClearoutTable.plateautarget : -1
		local wt_str = " also witches " + infStats.Witches + "/" + g_ClearoutTable.witches + " tanks " + infStats.Tanks + "/" + g_ClearoutTable.tanks 
		printl("CTick: @ " + Time() + " goal " + pt + " c " + infStats.Commons + "/" + g_ClearoutTable.lastcommons + " s " + infStats.Specials + "/" + g_ClearoutTable.lastspecials + wt_str )
	}

	local bStaticCounts = (infStats.Commons == g_ClearoutTable.lastcommons && infStats.Specials == g_ClearoutTable.lastspecials)

	if ("plateautarget" in g_ClearoutTable)
	{   
		if (!bStaticCounts)
			g_ClearoutTable.plateautarget = Time() + g_ClearoutTable.plateautime
		else if (Time() > g_ClearoutTable.plateautarget)
			bTimerDone = true
		g_ClearoutTable.lastspecials = infStats.Specials
		g_ClearoutTable.lastcommons  = infStats.Commons
	}

	if (bStaticCounts)
	{
		if ( Time() > g_ClearoutTable.ubertimeout)
		{
			bDoMoveOn = true
			printl("Warning: UberTimeout Giving up!")
		}
		else
			g_ClearoutTable.ubertimeout  = Time() + 60			
	}

	// if it is way way long w/no changes - just go to next phase no matter what is happening
	if (!bDoMoveOn && ("specialtarget" in g_ClearoutTable && infStats.SpecialsSpawned < g_ClearoutTable.specialtarget) )
		return  // this is the "havent spawned enough yet" case
	// do this after the plateau testing - really need to combine so stuck specials dont end the wave - hmmmm

	if (bTimerDone)
	{
		if ( infStats.Commons <= g_ClearoutTable.plateaucommons && infStats.Specials <= g_ClearoutTable.plateauspecials )
		{
			if (infStats.Tanks <= g_ClearoutTable.tanks && infStats.Witches <= g_ClearoutTable.witches)
				bDoMoveOn = true
			if (g_ClearoutLoud)
				printl("TimerDone - MoveOn now " + bDoMoveOn )
		}
		if (!bDoMoveOn && ("stopspecials" in g_ClearoutTable && SessionOptions.MaxSpecials != 0) ) // as soon as we plateau, go to maxspecials zero
		{
			SessionOptions.MaxSpecials = 0              // note: if we have a specialtarget, this wont happen till we hit it
			if (g_ClearoutLoud)
				printl("Setting MaxSpecials and Assault")
		}
	}

	if (!bDoMoveOn)
	{
		if (infStats.Specials <= g_ClearoutTable.specials && infStats.Commons <= g_ClearoutTable.commons &&
			infStats.Tanks <= g_ClearoutTable.tanks && infStats.Witches <= g_ClearoutTable.witches)
			bDoMoveOn = true
		if (g_ClearoutLoud)
			printl("Moveon " + bDoMoveOn + " from infStats w/t of " + infStats.Witches + "/" + infStats.Tanks + " and c/s " + infStats.Commons + "/" + infStats.Specials )
	}

	if (bDoMoveOn)
	{   // force next stage
		g_ClearoutTable.rawdelete("specialtarget")
		g_ClearoutTable = null
		ScriptedMode_RemoveSlowPoll( Clearout_Tick ) 
		if (g_ClearoutLoud)
			printl("Clearout Moving on (ps. trying to RemoveSlowPoll...)")    // make it a return false instead?
		Director.ForceNextStage()   // NOTE: this is a synchronous call - be warned!
	}
}

//=========================================================
// This is to store off the current info about counts, so that clearout can analyze that
//=========================================================
function ClearoutNotifyPanicStart( clearoutTable )
{
	local infStats = {}
	GetInfectedStats( infStats )
	if ("specialcount" in g_ClearoutTable)   // gonna need to figure out when we've spawned enough
		g_ClearoutTable.specialtarget <- infStats.SpecialsSpawned + g_ClearoutTable.specialcount  
}

//=========================================================
// this is how you start the script based clearout
//=========================================================
function ClearoutStart( clearoutTable )
{
	local bNeedPoll = (g_ClearoutTable == null)
	if (clearoutTable)
		g_ClearoutTable = clearoutTable
	else
		g_ClearoutTable = defaultClearout
	local infStats = {}
	GetInfectedStats( infStats )
	if ( ("specialcount" in g_ClearoutTable) && (!("specialtarget" in g_ClearoutTable)) )   // gonna need to figure out when we've spawned enough
		g_ClearoutTable.specialtarget <- infStats.SpecialsSpawned + g_ClearoutTable.specialcount  
	if ("plateautime" in g_ClearoutTable)
		g_ClearoutTable.plateautarget <- Time() + g_ClearoutTable.plateautime
	g_ClearoutTable.ubertimeout  <- Time() + 60
	g_ClearoutTable.lastcommons  <- infStats.Commons
	g_ClearoutTable.lastspecials <- infStats.Specials
	if (!("plateaucommons" in g_ClearoutTable))
		g_ClearoutTable.plateaucommons <- 10
	if (!("plateauspecials" in g_ClearoutTable))
		g_ClearoutTable.plateauspecials <- 1
	if (bNeedPoll)                           	// now make sure to add the Tick
		ScriptedMode_AddSlowPoll( Clearout_Tick )
	SessionOptions.SpecialInfectedAssault = 1   // new specials will attack - though shouldnt be any
	StartAssault()                              // tell existing ones to attack, too
	if ( (!("specialcount" in g_ClearoutTable)) && (!("specialcontinue" in g_ClearoutTable)) )
		SessionOptions.MaxSpecials = 0          // if you dont have a "# of specials" wave, stop new specials too
	printl("Starting script based Clearout with C:" + infStats.Commons + " and s:" + infStats.Specials )
}

//=========================================================
// Go through and remove map entities based on the sanitize table
//=========================================================
function SanitizeMap( sanitizeTable )
{
	foreach( key, value in sanitizeTable )
	{
		local delay = 0
		local param = 0
		local targetname = ""
		local searchname = ""
		local searchfunc = null
		local input = value.input
			
		// set delay and param if they are used
		if ( "delay" in value )	delay = value.delay
		if ( "param" in value ) param = value.param
			
		// special handling for the kill command - call directly to avoid EntFire delay
		local kill = ( input.find( "kill" ) != null )

		if ( "model" in value )
		{
			// if the table has a model key then operate on all entities in the map that use the model
			targetname = "!activator"
			searchname = value.model
			searchfunc = Entities.FindByModel
		}
		else if ( "targetname" in value )
		{
			targetname = value.targetname
			searchname = targetname
			searchfunc = Entities.FindByName
		}
		else if ( "classname" in value )
		{
			if ( "position" in value )
			{
				// Special case to find a single entity
				local entity = FindClassnameByPosition( value.classname, value.position )

				SanitizeEntity( entity, "!activator", value.input, param, delay, kill )
			}
			else
			{
				targetname = value.classname
				searchname = targetname
				searchfunc = Entities.FindByClassname
			}
		}

		if ( searchfunc )
		{
			local entity = null
			entity = searchfunc.call( Entities, entity, searchname )
				
			while( entity )
			{
				// if we're sanitizing by region only sanitize if we're in the region
				if( "region" in value ) 
				{
					if( EntityInsideRegion( entity, value.region ) )
					{
						SanitizeEntity( entity, targetname, input, param, delay, kill )
					}
				}
				else
				{
					SanitizeEntity( entity, targetname, input, param, delay, kill )
				}

				entity = searchfunc.call( Entities, entity, searchname )
			}
		}	
	}
}

//=========================================================
// Checks to see if an entity is inside a region
//
// A region is defined by two entities that share the same name.
// They mark the corners of the region.
//
// entity: The handle to the entity to find
// regionName: The name of the entities that define the region
//=========================================================
function EntityInsideRegion( entity, regionName )
{
	if( !entity )
	{
		return false
	}
	
	// find regionName pairs
	local count = 0
	local regionCorners = []

	local foundEnt = Entities.FindByName( null, regionName )

	// collect the corner entities of the region
	while( foundEnt )
	{
		count++
		regionCorners.append( foundEnt )

		foundEnt = Entities.FindByName( foundEnt, regionName )
	}

	if( count != 2 )
	{
		printl(" ** EntityInsideRegion() error: Found " + count + " entitie(s) with the region name: " + regionName + "!  Expected to find only upper and lower corner ents - Aborting.")
		return false
	}

	local vec0 = regionCorners[0].GetOrigin()
	local vec1 = regionCorners[1].GetOrigin()

	local entityOrigin = entity.GetOrigin()
	
	if( NumBetween( vec0.x, vec1.x, entityOrigin.x ) && NumBetween( vec0.y, vec1.y, entityOrigin.y ) && NumBetween( vec0.z, vec1.z, entityOrigin.z ) )
	{
		return true
	}
	else
	{
		return false
	}
}

//=========================================================
// is num between a,b where a and b do not have to be ordered
//=========================================================
function NumBetween( a, b, num )
{
	return ( b > a ? num > a && num < b : num > b && num < a )
}

//=========================================================
// actually do the sanitize based on the parsed table data
//=========================================================
function SanitizeEntity( entity, name, input, param, delay, kill )
{
	if ( !entity )
	{
		return
	}
	
	if( entity.GetClassname() == "info_item_position" )
	{
		// do not sanitize item position entities!
		return
	}
		
	if ( kill )
	{
		entity.Kill()
	}
	else
	{
		EntFire( name, input, param, delay, entity )
	}
}

//=========================================================
// Find an entity near a position and of a particular class and fire an input into it. 
// classname is the name of the class to find.  e.g., "info_target" 
// position is a comma delimited string for the entity position. e.g., "100, 200, 300" 
//=========================================================
function FindClassnameByPosition( classname, position )
{
	local SEARCH_DIST = 2 // radius to use for search

	local cur_ent = Entities.FindByClassnameNearest( classname, position, SEARCH_DIST )
	if ( !cur_ent )
	{
		printl(" *** Sanitize Error: Couldn't find a " + classname + " at " + position )
	}
	
	return cur_ent		
}

//=========================================================
// Take a comma delimited string in the format "x, y, z"  and return a vector
//=========================================================
function StringToVector( str, delimiter )
{
	local vec = Vector( 0, 0, 0 )

	local result = split( str, delimiter )

	vec.x = result[0].tointeger()
	vec.y = result[1].tointeger()
	vec.z = result[2].tointeger()

	return vec
}

///////////////////////////////////////////////////////////////////////////////
// dynamic spawn helpers
//   for Melee Weapons, Particle Systems, and then some more complex stuff for hints
///////////////////////////////////////////////////////////////////////////////

function SpawnMeleeWeapon( weaponname, pos, ang )
{
	local weaponMeleeSpawnInfo =
	{
		classname		= "weapon_melee_spawn"
		origin			= pos
		angles			= ang
		spawnflags		= "2"
		count			= "1"
		melee_weapon	= weaponname
		solid			= "6"
	}
	return CreateSingleSimpleEntityFromTable( weaponMeleeSpawnInfo )
}

function CreateParticleSystemAt( srcEnt, vOffset, particleName, startActive = true, overrideTable = null)
{
	local particleSpawnInfo =
	{
		classname = "info_particle_system"
		effect_name = particleName
		targetname = "our_particles"
		render_in_front = "0"
		start_active = startActive ? "1" : "0"
		origin = vOffset
	}
	if (overrideTable)
		InjectTable( overrideTable, particleSpawnInfo )
	return CreateSingleSimpleEntityFromTable( particleSpawnInfo, srcEnt )
}

//=========================================================
// create hint at versus create hint on? - on hintEnt, 
// with Str, with overrides from Table
//=========================================================
function CreateHintOn( hintTargetName, hintPos, hintStr, hintTable, callback = null )
{
	local hintShell = 
	{
		function GetSpawnList()      { return [ EntityGroup.SpawnTables.hint ] }
		function GetEntityGroup()    { return EntityGroup }
		EntityGroup =
		{
			SpawnTables =
			{
				hint =
				{
					initialSpawn = true
					SpawnInfo =
					{
						classname = "env_instructor_hint"
						hint_allow_nodraw_target = "1"
						hint_alphaoption = "0"
						hint_auto_start = "1"
						hint_binding = "+use"
						hint_caption = "Default Dynamic Hint!"
						hint_color = "255 255 255"
						hint_forcecaption = "0"                 // diff
						hint_icon_offscreen = "icon_tip"
						hint_icon_offset = "0"
						hint_icon_onscreen = "use_binding"
						hint_instance_type = "2"                // show multiple
						hint_nooffscreen = "0"                  // 0/1
						hint_pulseoption = "0"
						hint_range = "130"                      // 130/300
						hint_shakeoption = "0"
						hint_static = "0"                       // 0/1 - 1 is show on hud, show in world
						hint_target = "prop_resource"
						hint_timeout = "0"
						targetname = "hint"
						origin = Vector( 0, 0, 28.2918 )
						connections =
						{
						 	OnUser4 =
						 	{
						 		cmd1 = "!selfEndHint0-1"
						 		cmd2 = "!selfKill0.01-1"
						 	}
						}
					}
				}
			}
		}
	}

	if (hintTable)
		foreach (idx, val in hintTable)    // merge 
			hintShell.EntityGroup.SpawnTables.hint.SpawnInfo[idx] <- val 
	if (hintStr)
		hintShell.EntityGroup.SpawnTables.hint.SpawnInfo.hint_caption = hintStr
	if (hintTargetName)
	{
		hintShell.EntityGroup.SpawnTables.hint.SpawnInfo.hint_target = hintTargetName
	}

	if (hintPos == null && hintTargetName != null)
	{
		local hintEnt = Entities.FindByName(null, hintTargetName)
		if (hintEnt)
			hintPos = hintEnt.GetOrigin()
		else
			printl("Cant find an entity for spawning hint")
	}
	
	local hintGroup = hintShell.GetEntityGroup()
	if( callback )
	{
		if( "PostPlaceListCB" in this )
		{
			printl(" CreateHintOn: Error!  Trying to create a PostPlaceListCB when one already exists!  Stomping existing CB.")
			// @todo: go ahead and chain this? ugh...
		}
		hintGroup.PostPlaceListCB <- callback
	}
	SpawnSingleAt( hintGroup, hintPos, QAngle(0,0,0) )
}

//=========================================================
// inject the override data into the baseTable - i.e. add any new ones, overwrite dupes
//=========================================================
function InjectTable( overrideTable, baseTable )
{
	foreach (idx, val in overrideTable)
	{
		if ( typeof(val) == "table" )
		{
			if (! (idx in baseTable) )
			{
				baseTable[idx] <- {}    // make sure there is a table here to inject into in the base
			}
			InjectTable( val, baseTable[idx] ) 
		}
		else
		{
			if (val == null)
				baseTable.rawdelete(idx)   // specify null to remove a key!
			else
				baseTable[idx] <- overrideTable[idx]
		}
	}
}

// all the training hint entity names generated from the InstructorHintTable
g_RoundState.TrainingHintList <- []	

//=========================================================
// Callback that runs after CreateHintOn creates a hint entity.
// The hint is then shown and stored in a list for subsequent
// use (such as ending, killing hints when they're not needed)
//=========================================================
function TrainingHintCB( entNameList )
{
	foreach (idx, val in entNameList)
	{
		if ( val != null )
		{			
			EntFire( val, "ShowHint", 0, 1 )
	
			g_RoundState.TrainingHintList.append( val )
		}
	}
}

//=========================================================
// Callback that runs when the target entity for a hint gets created.
//=========================================================
function TrainingHintTargetCB( entNameList )
{
	if( entNameList.len() != 1 )
	{
		printl(" TrainingHintTargetCB: Error!  List contains more than one object, expected one.")
	}
	
	SessionState.TrainingHintTargetNextName <- entNameList[0]
}

//=========================================================
// This helper kills off all the hints in the training hint list
// so you can give a pile of hints to spawn, then when you want (on time, or on some event) go clear them out
//=========================================================
function EndTrainingHints( delay )
{
	foreach( idx, value in g_RoundState.TrainingHintList )
	{
		EntFire( value, "kill", 0, delay )
	}
}

//=========================================================
// Will find all entities in the supplied table and create instructor hints at their respective positions. 
//
// If you want finer control over the hint parameters, consider using CreateInstructorHint() to meticulously
// define each individual hint
// 
// Expects a table formatted like this:
//
// { hintEntityName = "<name for this hint entity>", targetEntityName = "<name of target entity>", hintText = "<Actual hint display text>", hintOnScreenIcon = "<name of hint icon>" }
//
// NOTE: This function will spawn a hint entity for each entry in the table that you pass in. 
// Each such entity will receive the hintEntityName that you supply in the passed table. 
// You may not care what name this is, but take care that it doesn't collide with something else important.
//
// NOTE: This function will attach a hint to ALL entities found matching targetEntityName. 
// So use unique names for each target entity unless you want this behavior.
//=========================================================
function CreateSimpleInstructorHints( hintTable )
{
	local HintDefaultSpawnInfo =
	{
		hint_auto_start = "1"
		hint_range = "0"
		hint_suppress_rest = "1"
		hint_nooffscreen = "1"
		hint_forcecaption = "1"
		hint_icon_onscreen = "icon_shield"
	}

	foreach( key, value in hintTable )
	{
		local ent = null
		HintDefaultSpawnInfo.targetname <- value.hintEntityName
		do
		{
			ent = Entities.FindByName( ent, value.targetEntityName )

			if( ent )
			{
				local hintTargetName = value.hintEntityName + "_target"
				CreateHintTarget( hintTargetName, ent.GetOrigin(), null, TrainingHintTargetCB )
				CreateHintOn( SessionState.TrainingHintTargetNextName, ent.GetOrigin(), value.hintText, HintDefaultSpawnInfo, TrainingHintCB )

				// delete the training hint next name key
				SessionState.rawdelete( "TrainingHintTargetNextName" )				
			}
		} while( ent )
	}
}

//=========================================================
// Creates a hint on a target entity that uses a model.
//
// Expects a table with this format:
// 
// { targetname = "<name to give created hint>", mdl = "<name of model used by hint target>", targetEntName = "<name (or substring) of entity that uses the mdl>", hintText = "<text to display>" }
// 
// NOTE: The MDL and targetEntName are both necessary in order to narrow down the entity for hint attachment.  You do not need to provide the exact name of the target entity, just a substring contained
// by the name.
//=========================================================
function CreateTrainingHints( hintTable )
{
	local HintSpawnInfo =
	{
		hint_auto_start = "1"
		hint_range = "0"
		hint_suppress_rest = "1"
		hint_nooffscreen = "1"
		hint_forcecaption = "1"
		hint_icon_onscreen = "icon_shield"
	}

	foreach( key, value in hintTable )
	{
		local ent = null
		HintSpawnInfo.targetname <- value.targetname
		do
		{
			ent = Entities.FindByModel( ent, value.mdl )

			if( ent )
			{
				if( ent.GetName().find( value.targetEntName  ) != null && ent.GetClassname() != "info_item_position" ) // ignore item position entities
				{
					local hintTargetName = value.targetname + "_target"
					CreateHintTarget( hintTargetName, ent.GetOrigin(), null, TrainingHintTargetCB )
					CreateHintOn( SessionState.TrainingHintTargetNextName, ent.GetOrigin(), value.hintText, HintSpawnInfo, TrainingHintCB )

					// delete the training hint next name key
					SessionState.rawdelete( "TrainingHintTargetNextName" )				
				}
			}
		} while( ent )
	}
}

//=========================================================
// Creates a info_target_instructor_hint entity
//=========================================================
function CreateHintTarget( hintTargetName, hintPos, hintTargetTable, callback )
{
	local hintTargetShell = 
	{
		function GetSpawnList()      { return [ EntityGroup.SpawnTables.hintTarget ] }
		function GetEntityGroup()    { return EntityGroup }
		EntityGroup =
		{
			SpawnTables =
			{
				hintTarget =
				{
					initialSpawn = true
					SpawnInfo =
					{
						classname = "info_target_instructor_hint"
						targetname = "_target"
						origin = Vector( 0,0,0 )
					}
				}
			}		
		}
	}

	if (hintTargetTable)
	{
		foreach (idx, val in hintTargetTable)
		{
			hintTargetShell.EntityGroup.SpawnTables.hint.SpawnInfo[idx] <- val
		}
	}

	if (hintTargetName)
		hintTargetShell.EntityGroup.SpawnTables.hintTarget.SpawnInfo.targetname = hintTargetName
	
	local hintGroup = hintTargetShell.GetEntityGroup()
	hintGroup.PostPlaceListCB <- callback
	SpawnSingleAt( hintGroup, hintPos, QAngle(0,0,0) )
}

//=========================================================
// Creates a "simple" singleton entity from KeyValues - by wrapping an EntityGroup shell around it
//=========================================================
// this is the callback that simply stores off the entity for returning to the caller
::_SingleSimpleEntityTempStore <- null
function _SingleSimpleEntityCB( entity, rarity )
{
	::_SingleSimpleEntityTempStore = entity
}

// builds an EntityGroup shell around the spawnTable data
function BuildShell( spawnTable )
{
	local simpleShell = 
	{
		groupname = "sm_utilities::SimpleShell"
		function GetSpawnList()      { return [ EntityGroup.SpawnTables.simple ] }
		function GetEntityGroup()    { return EntityGroup }
		EntityGroup =
		{
			SpawnTables = 
			{
				simple =
				{
					initialSpawn = true
					SpawnInfo =
					{
						origin = Vector(0,0,0)
					}
				}
			}
		}
	}
	if (!("targetName" in spawnTable))
		spawnTable.targetname = "simple"
	local overrides = { simple = { SpawnInfo = spawnTable } }
	InjectTable( overrides, simpleShell.GetEntityGroup().SpawnTables )
	return simpleShell
}

// wrap the table in a shell, then create an entity for the table, and then return the entity
function CreateSingleSimpleEntityFromTable( spawnTable, entityAt = null )
{
	// how do we precache these!!!
	local singleSimpleShell = 
	{
		function GetSpawnList()      { return [ EntityGroup.SpawnTables.singlesimple ] }
		function GetEntityGroup()    { return EntityGroup }
		EntityGroup =
		{
			SpawnTables =
			{
				singlesimple =
				{
					PostPlaceCB = _SingleSimpleEntityCB
					initialSpawn = true
					SpawnInfo =
					{
						origin = Vector(0,0,0)   // do we need/want this key? if you remove it, change the = to <- below
						angles = QAngle(0,0,0)
					}
				}
			}
		}
	}

	if (!("targetname" in spawnTable))
		spawnTable.targetname <- "singlesimple"
	local overrides = { singlesimple = { SpawnInfo = spawnTable } }

	InjectTable( overrides, singleSimpleShell.GetEntityGroup().SpawnTables )
	if (entityAt != null)
	{
		singleSimpleShell.EntityGroup.SpawnTables.singlesimple.SpawnInfo.origin = entityAt.GetOrigin()
		singleSimpleShell.EntityGroup.SpawnTables.singlesimple.SpawnInfo.angles = entityAt.GetAngles()
	}
	SpawnSingle( singleSimpleShell.GetEntityGroup() )

	local tmp = ::_SingleSimpleEntityTempStore
	::_SingleSimpleEntityTempStore <- null
	return tmp
}
