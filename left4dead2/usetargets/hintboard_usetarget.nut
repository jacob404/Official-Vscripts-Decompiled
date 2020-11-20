//=========================================================
// For use on a hint board "point_script_use_target"
// Requires a table of strings in the map script
//=========================================================

IncludeScript("usetargets/base_buildable_target")


BuildableType	<- "Map Hints"
ResourceCost	<- 0

// button options
BuildTime		<- 1.8
BuildText		<- "Read a hint about this map!"
BuildSubText	<- ""

HintLifetime	<- 5 // how long to display hint before killing it
CurrentHintIdx	<- 0


self.ConnectOutput( "OnUser1", "OnButtonPress" )

function OnPostSpawn()
{
	if( !("HintBoardStringTable" in g_MapScript ) )
	{
		printl( "** Hintboard ERROR!  Cannot find HintBoardStringTable in map script! Aborting, killing Hintboard.")
		EntFire( "!self", "fireuser4" )
		return
	}
	
	// shuffle the hint order so it is different each time you play
	RandomizeHintboardStrings()	
}

function RandomizeHintboardStrings()
{
	local table = g_MapScript.HintBoardStringTable // for convenience

	local n = table.len()
	
	for( local i = 0; i < n - 1; i++)
	{
		local j = i + rand() / (RAND_MAX / (n - i) + 1)
		local t = table[j]
		table[j] = table[i]
		table[i] = t
	}
}

// Callback that runs after hint entity gets created
function HintboardHintCB( entNameList )
{
	foreach (idx, val in entNameList)
	{
		if ( val != null )
		{			
			EntFire( val, "ShowHint" )
			EntFire( val, "kill", 0, 5 )
		}
	}
}

function OnButtonPress()
{
	local HintSpawnInfo =
	{
		hint_allow_nodraw_target = "1"
		hint_icon_onscreen = "icon_alert"
		hint_instance_type = "2"
		hint_nooffscreen = "1"
		hint_static = "1"
		hint_timeout = "5"
		targetname = "hintboard_hint"
	}

	g_MapScript.CreateHintOn( self.GetName(), self.GetOrigin(), GetHintString(), HintSpawnInfo, HintboardHintCB )
}

function GetHintString()
{
	local hintTable = g_MapScript.HintBoardStringTable // for convenience

	if( CurrentHintIdx >= hintTable.len() )
	{
		CurrentHintIdx = 0
	}

	// hint to return
	local string = hintTable[CurrentHintIdx][0]
	
	CurrentHintIdx++

	return string
}