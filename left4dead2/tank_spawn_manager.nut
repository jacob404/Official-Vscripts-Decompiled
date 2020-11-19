//=========================================================
// This script should be attached to a L4D2 tank spawn instance
// (e.g., tank manhole, tank barn)
//=========================================================


// this value gets set by the gamemode when the manhole tank state table gets created.
ManholeTankListIndex <- 0

// set up tank spawn list, create one if it does not exist.
if( !( "TankManager" in g_RoundState ) )
{
	g_RoundState.TankManager <- 
	{
		TankSpawnpointList = []
				
		// list that contains manhole tank state
		ManholeTankList = []
	
		//-------------------------------------------------------
		GetTankSpawnpointCount = function()
		{
			return TankSpawnpointList.len()
		}

		//-------------------------------------------------------
		RandomizeTankSpawnpointList = function()
		{
			local n = GetTankSpawnpointCount()
	
			for( local i = 0; i < n - 1; i++)
			{
				local j = i + rand() / (RAND_MAX / (n - i) + 1)
				local t = TankSpawnpointList[j]
				TankSpawnpointList[j] = TankSpawnpointList[i]
				TankSpawnpointList[i] = t
			}
		}

		//-------------------------------------------------------
		ManholeTankSpawnCheck = function()
		{
			// iterate tank list, check if tanks should spawn
			for( local i=0; i<ManholeTankList.len(); i++ )
			{
				local currentTank = ManholeTankList[i]

				if ( currentTank.IsValid )
				{	// time to spawn a barn tank?
					if ( currentTank.SpawnWave == SessionState.ScriptedStageWave && !currentTank.Spawned )
					{
						currentTank.Spawned = true

						// note - a witch can "overwrite" this warning - not sure if/how to fix
						g_MapScript.Ticker_NewStr("Something seems to be awakening...")
					}
		
					// break tank barn boards every time cooldown starts
					if (currentTank.Spawned && currentTank.Barricaded)
					{
						EntFire( currentTank.BreakBoardsRelayName, "trigger", 0, 0 )
			
						currentTank.Barricaded = false
					}
		
					// if the tank has spawned, start up his sounds
					if( currentTank.Spawned )
					{
						EntFire( currentTank.StartRattleRelayName, "trigger", 0, 0 )

						// notify the button that the tank has spawned so it can evaluate the correct +use state
						currentTank.UseTargetScriptScope.TankThreatening()
					}
				}
			}
		}

		//-------------------------------------------------------
		ManholeTankSetup = function( tankCount )
		{
			// generate the tank state tables and wave spawn order
			if( "TankSpawnpointList" in g_RoundState.TankManager )
			{
				if( tankCount > g_RoundState.TankManager.GetTankSpawnpointCount() )
				{
					printl(" *** ERROR:  You're trying to spawn more tanks than there are spawn points!")
				}

				for( local i=0; i<tankCount; i++ )
				{
					// create a table of state & data for the tank
					local ManholeTank =
					{
						IsValid = true
						Barricaded = false
						Spawned = false
						SpawnWave = 0 // this value gets calculated 
						ReleaseTankRelayName = g_RoundState.TankManager.TankSpawnpointList[i].releaseTankRelayName
						BreakBoardsRelayName = g_RoundState.TankManager.TankSpawnpointList[i].breakBoardsRelayName
						StartRattleRelayName = g_RoundState.TankManager.TankSpawnpointList[i].startRattleRelayName
						StopRattleRelayName = g_RoundState.TankManager.TankSpawnpointList[i].stopRattleRelayName
						UseTargetScriptScope = g_RoundState.TankManager.TankSpawnpointList[i].buttonScope
					}

					// spawn the first tank before the 5th wave
					if( i == 0 )
					{
						ManholeTank.SpawnWave = RandomInt(2, 5)
					}
					else
					{	// don't spawn subsequent tanks on the same wave as the first
						ManholeTank.SpawnWave = ManholeTankList[0].SpawnWave + RandomInt(2, 4)
					}

					// associate this table with the button that barridades the manhole
					// so the button knows which state to modify when it is used
					g_RoundState.TankManager.TankSpawnpointList[i].manholeScriptScope.SetManholeTankListIndex( i )

					ManholeTankList.append( ManholeTank )

					//printl(" *** Tank " + i + " spawning on wave: " + ManholeTank.SpawnWave )
				}
			}
			else
			{
				printl(" *** ERROR *** No tank spawn points (e.g., manhole entity groups) in the map!")
			}	
		}

		//-------------------------------------------------------
		ManholeTankReleaseCheck = function()
		{
			// only operate on the tank list if there are items in it
			if( ManholeTankList.len() > 0 )
			{
				// iterate the list of tanks to see if any are due to be released
				for( local i=0; i<ManholeTankList.len(); i++ )
				{
					local currentTank = ManholeTankList[i]

					if ( currentTank.IsValid && currentTank.Spawned && !currentTank.Barricaded)
					{
						EntFire( currentTank.ReleaseTankRelayName, "trigger", 0, 0 )
		
						currentTank.IsValid = false
					}
				}
			}
		}
	}
}

function Precache()
{
	if( !( "TankSpawnpointList" in g_RoundState.TankManager ) )
	{
		printl(" ** Error: There is no TankSpawnpointList in the map! Aborting setup of tank spawnpoints.")
		return
	}
	
	tankspawnpoint <- 
	{ 
		startRattleRelayName = EntityGroup[0].GetName()
		stopRattleRelayName = EntityGroup[1].GetName()
		releaseTankRelayName = EntityGroup[2].GetName()
		breakBoardsRelayName = EntityGroup[3].GetName()
		manholeScriptScope = this.weakref()
		buttonScope = Entities.FindByName( null, EntityGroup[4].GetName() ).GetScriptScope()
	}
	
	g_RoundState.TankManager.TankSpawnpointList.append( tankspawnpoint )
	

	// randomize the list order
	g_RoundState.TankManager.RandomizeTankSpawnpointList()
}

// called by setup to notify this object of where it ended up in the list after it was shuffled
function SetManholeTankListIndex( index )
{
	ManholeTankListIndex = index
}

// called by successful press of barricade button
function SetTankBarnBarricaded()
{
	local TankSpawned = false

	g_RoundState.TankManager.ManholeTankList[ManholeTankListIndex].Barricaded = true
	TankSpawned = g_RoundState.TankManager.ManholeTankList[ManholeTankListIndex].Spawned
	

	if( TankSpawned )
	{
		EntFire( g_RoundState.TankManager.ManholeTankList[ManholeTankListIndex].StopRattleRelayName, "trigger", 0, 0 )

		g_RoundState.TankManager.ManholeTankList[ManholeTankListIndex].UseTargetScriptScope.TankBarricaded()
	}
}
