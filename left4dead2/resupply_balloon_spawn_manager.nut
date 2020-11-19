//=========================================================
//=========================================================
// set up spawn list, create one if it does not exist.
if( !( "ResupplyBalloonManager" in g_RoundState ) )
{
	g_RoundState.ResupplyBalloonManager <-
	{
		hasSpawned = false

		minWave = 2
		maxWave = 9 // balloon guaranteed to spawn by this wave

		ResupplyBalloonSpawnCheck = function()
		{
			// bail if we already spawned
			if ( hasSpawned == true )
				return

			local chance = RandomInt(0, 5)

			if( ( chance == 0 && SessionState.ScriptedStageWave > minWave ) || SessionState.ScriptedStageWave == maxWave )
			{
				// spawn the balloon
				local balloonGroup = g_MapScript.GetEntityGroup( "ResupplyBalloon" )
				balloonGroup.SpawnPointName <- "resupply_balloon_spawn"
				g_MapScript.SpawnMultiple( balloonGroup, { count = 1 } )
				hasSpawned = true
			}	
		}
	}
}