
// The first helicopter that spawns will create this table
if( !("ResupplyHelicopter" in g_RoundState ) )
{
	g_RoundState.ResupplyHelicopter <- {}
	IncludeScript( "base_helicopter", g_RoundState.ResupplyHelicopter )
}

//-------------------------------------------------------
function Precache()
{
	helicopter <- { relayName = EntityGroup[0].GetName(), available = 1 }
	
	g_RoundState.ResupplyHelicopter.HelicopterList.append( helicopter )

	// randomize the list
	g_RoundState.ResupplyHelicopter.RandomizeHelicopterList()
}