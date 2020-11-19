
// The first helicopter that spawns will create this table
if( !("GascanHelicopter" in g_RoundState ) )
{
	g_RoundState.GascanHelicopter <- {}
	IncludeScript( "base_helicopter", g_RoundState.GascanHelicopter )
}

//-------------------------------------------------------
function Precache()
{
	helicopter <- { relayName = EntityGroup[0].GetName(), available = 1 }
	
	g_RoundState.GascanHelicopter.HelicopterList.append( helicopter )

	// randomize the list
	g_RoundState.GascanHelicopter.RandomizeHelicopterList()
}