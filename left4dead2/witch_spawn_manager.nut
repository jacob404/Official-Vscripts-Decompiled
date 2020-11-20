//=========================================================
// This script should be attached to a L4D2 witch tombstone instance
//=========================================================

// set up spawn list, create one if it does not exist.
if( !( "WitchManager" in g_RoundState ) )
{
	g_RoundState.WitchManager <-
	{
		WitchSpawnpointList = []
		
		WitchTargetIndex = 0
		WitchTargetList = ["!ellis", "!nick", "!rochelle", "!coach"]
		
		WitchesActivating = false
		WitchSpawnWave = 0

		WitchSpawnCheck = function()
		{
			if( WitchSpawnWave == SessionState.ScriptedStageWave )
			{
				ActivateTombstones()
				WitchesActivating = true

				g_MapScript.Ticker_NewStr("Watch for Witches")
			}
		}

		GetWitchSpawnWave  = function()
		{
			return WitchSpawnWave
		}

		WitchSetup = function()
		{
			WitchSpawnWave = RandomInt( 3, 9)
		}

		IsActivating = function()
		{
			return WitchesActivating
		}

		GetWitchSpawnpointCount = function()
		{
			return WitchSpawnpointList.len()
		}
	
		// return the name of a player for a newly spawned witch to attack
		GetWitchVictim = function()
		{
			local victimName = WitchTargetList[WitchTargetIndex]
			WitchTargetIndex++
		
			if( WitchTargetIndex > 3 )
			{
				WitchTargetIndex = 0
			}
		
			return victimName
		}

		// activate all the tombstones (start glowing, emerge from the ground)
		ActivateTombstones = function()
		{
			for( local i=0; i<WitchSpawnpointList.len(); i++ )
			{
				EntFire( WitchSpawnpointList[i].tombstoneStartGlowingRelay, "trigger" )
			}
		}
	
		// release the witches and send them after players
		ReleaseTombstoneWitches = function()
		{
			WitchesActivating = false

			for( local i=0; i<4; i++ )
			{
				local min = 0
				local max = 3.5
				local rndDelay = min+((max-min+1)*rand()/RAND_MAX)
			
				EntFire( WitchSpawnpointList[i].tombstoneSpawnWitchRelay, "trigger", 0, rndDelay )
			
				local victimName = GetWitchVictim()
				EntFire( WitchSpawnpointList[i].tombstoneWitchSpawnerName, "StartleZombie", victimName, (rndDelay + 0.2) )
			}
		}
	}
}

function Precache()
{
	Witchspawnpoint <- 
	{ 
		tombstoneStartGlowingRelay = EntityGroup[0].GetName()
		tombstoneSpawnWitchRelay = EntityGroup[1].GetName()
		tombstoneWitchSpawnerName = EntityGroup[2].GetName()
		tombstoneDestructorRelay = EntityGroup[3].GetName()
	}
	
	g_RoundState.WitchManager.WitchSpawnpointList.append( Witchspawnpoint )
}