

g_RoundState.g_GascanManager <-
{
	canSpawnInterval = 20 // minimum time in seconds between can spawns

	// the hand-built entity group for the gascans we will spawn
	GasCanGroup =
	{
		function GetSpawnList()   { return [ EntityGroup.SpawnTables.gascan ] }
		function GetEntityGroup() { return EntityGroup }
		EntityGroup =
		{
			SpawnPointName = "gascanspawn_*"
			SpawnTables = 
			{
				gascan =
				{
					initialSpawn = true
					SpawnInfo =
					{
						classname = "prop_physics"
						model = "models/props_junk/gascan001a.mdl"
//						thinkfunction = "Think"
						glowstate = "3"
						glowcolor = "255 255 255"
					}
				}
			}
		}
	}

	DoUpdates = false
	lastUpdateTime = 0
	lastSawCans = 0
	lastGroupUsed = -1
	MaxGroup = -1

	// if we want, could actually track used group and force all to be hit once before going on, etc
	// GroupsUsed = {}
	// just put a key in when a group is used, dont use it again, check to see if GroupsUsed.Len() == MaxGroups, reset

	// ----------------------------------------------------------------------------
	function SetGascanSpawnInterval( interval )
	{
		canSpawnInterval = interval
	}

	// ----------------------------------------------------------------------------
	function StartGascanSpawns()
	{
		// spawn the cans in group 0
		g_MapScript.SpawnMultiple( GasCanGroup.GetEntityGroup(), { filter =  @(v) v.GetGroup() == 0 } ) 

		// get the actual list so we can compute # of groups
		local all_can_locations = g_MapScript.SpawnGetList( GasCanGroup.GetEntityGroup() )
		foreach (idx, val in all_can_locations)
		{
			if (val.GetGroup() > MaxGroup)
				MaxGroup = val.GetGroup()
		}

		lastGroupUsed = 0
		DoUpdates = true
		lastUpdateTime = Time() 
	}

	function GascanUpdate()
	{
		// check for gascans but not often since it uses slow "search for model" approach
		if ( DoUpdates && ( Time()- lastUpdateTime > 5.0 ) )
		{
			local cur_ent = Entities.FindByModel( null, GasCanGroup.GetEntityGroup().SpawnTables.gascan.SpawnInfo.model )
		
			// could actually count them, but for now just check for zero
			if (cur_ent == null )
			{
				// there are no cans in the world but do not spawn cans until the canSpawnInterval time between spawns has been exceeded
				if( Time() > lastSawCans + canSpawnInterval)
				{   // now need to pick a group #
					local nextGroup = 0
					local tries = 0
					do {
						nextGroup = RandomInt( 1, MaxGroup - 1 )
					} while ( nextGroup == lastGroupUsed && ++tries < 5 )   // if we fail 5 times, something prob wrong
						g_MapScript.SpawnMultiple( GasCanGroup.GetEntityGroup(), { filter = @(v) v.GetGroup() == nextGroup } )
					lastSawCans = Time()
					lastGroupUsed = nextGroup
				}
			}
			else
			{
				lastSawCans = Time()
			}

			lastUpdateTime = Time()
		}
	}
}