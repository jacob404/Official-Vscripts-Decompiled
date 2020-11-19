//=========================================================
// For use on a life preserver "point_script_use_target"
//=========================================================
IncludeScript("usetargets/base_buildable_target")

BuildableType	<- "lifepreserver"
ResourceCost	<- 2

// button options
BuildTime		<- 1.0
BuildText		<- "Rescue your teammate"
BuildSubText	<- "Cost: " + ResourceCost

UseStateDependencies.available <- true

// create life preserver manager if it does not exist.
if( !( "LifePreserverManager" in g_RoundState ) )
{
	g_RoundState.LifePreserverManager <-
	{
		LifePreserverList = []
		PlayersAwaitingPreserverList = []

		CurrentLifePreserverIndex = 0
		
		// number of zombies that can be hauled in from the water
		SpawnedWaterZombieCount = 1

		//-------------------------------------------------------
		UpdatePreservers = function()
		{
			foreach( k, val in LifePreserverList )
			{
				// search for a body.  if one is not found then they've already been defibrillated so recycle the life preserver
				if( val.inUse && val.HasRescuedPlayer )
				{
					local playerBodyEnt = Entities.FindByClassnameWithin( null, "survivor_death_model", val.useTarget.self.GetOrigin(), 32 )
					local foundBody = false

					while( playerBodyEnt )
					{
						if( playerBodyEnt == val.playerEnt )
						{
							foundBody = true
						}

						playerBodyEnt = Entities.FindByClassnameWithin( playerBodyEnt, "survivor_death_model", val.useTarget.self.GetOrigin(), 32 )
					}

					// if we didn't find the correct body reset the life preserver
					if( !foundBody )
					{
						val.inUse = false
						val.HasRescuedPlayer = false

						val.useTarget.SetAvailable()
					}
				}
			}
		}

		//-------------------------------------------------------
		WaterDeathPoll = function()
		{
			UpdatePreservers()

			local cur_ent = Entities.FindByClassname( null, "survivor_death_model" )

			// bail early if we don't find a dead player
			if( !cur_ent )
			{
				return
			}
			
			while( cur_ent )
			{
				if( g_MapScript.EntityInsideRegion( cur_ent, "water_incap_region" ) )
				{	
					// only enable a preserver if the player hasn't done so yet
					if( PlayerNeedsPreserver( cur_ent ) )
					{
						EnablePreserverForDrownedPlayer( cur_ent )							
					}
				}


				cur_ent = Entities.FindByClassname( cur_ent, "survivor_death_model" )
			}
		}

		//-------------------------------------------------------
		PlayerNeedsPreserver = function( deadPlayerEnt )
		{
			foreach( k, val in PlayersAwaitingPreserverList )
			{
				if( deadPlayerEnt == val )
				{
					return false
				}
			}

			return true
		}

		//-------------------------------------------------------
		EnablePreserverForDrownedPlayer = function( deadPlayerEnt )
		{
			PlayersAwaitingPreserverList.append( deadPlayerEnt )

			local lifePreserver = GetAvailablePreserver()

			lifePreserver.useTarget.TurnOn()
		}

		//-------------------------------------------------------
		GetAvailablePreserver = function()
		{
			foreach( k, val in LifePreserverList )
			{
				if( !val.inUse )
				{
					val.inUse = true
					return val
				}
			}

			printl(" Life Preserver Error: Non are available.  This shouldn't happen...")
		}

		//-------------------------------------------------------
		GetPlayerToRescue = function()
		{
			return PlayersAwaitingPreserverList.pop()
		}
	}
}

//-------------------------------------------------------
//-------------------------------------------------------
function OnPostSpawn()
{
	LifePreserver <-
	{
		useTarget = this.weakref()
		inUse = false
		playerEnt = null
		HasRescuedPlayer = false
	}

	g_RoundState.LifePreserverManager.LifePreserverList.append( LifePreserver )

	// shuffle the list if all four preservers have spawned
	local lifePreserverCount = g_RoundState.LifePreserverManager.LifePreserverList.len()

	if( lifePreserverCount == 4 )
	{
		for( local i = 0; i < lifePreserverCount - 1; i++)
		{
			local j = i + rand() / (RAND_MAX / (lifePreserverCount - i) + 1)
			local t = g_RoundState.LifePreserverManager.LifePreserverList[j]
			g_RoundState.LifePreserverManager.LifePreserverList[j] = g_RoundState.LifePreserverManager.LifePreserverList[i]
			g_RoundState.LifePreserverManager.LifePreserverList[i] = t
		}
	}

	TurnOff()
}

//-------------------------------------------------------
function IsAvailable()
{
	return UseStateDependencies.available
}

//-------------------------------------------------------
function SetAvailable()
{
	UseStateDependencies.available = true
	UpdateButtonState()
}

//-------------------------------------------------------
function SetUnAvailable()
{
	UseStateDependencies.available = false
	
	// unavailable buttons are also not visible (off)
	TurnOff()
}

//-------------------------------------------------------
function RescuePlayerFromWater()
{
	local player = g_RoundState.LifePreserverManager.GetPlayerToRescue()
	
	LifePreserver.playerEnt = player
	LifePreserver.HasRescuedPlayer = true

	local useModelEnt = Entities.FindByName( null, self.GetUseModelName() )

	if( !useModelEnt )
	{
		printl(" *** ERROR: usable does not have use model, can't rescue player from water. aborting!")
		return
	}

	player.SetOrigin( useModelEnt.GetOrigin() )
}

//-------------------------------------------------------
function PreserverPulledFromWater()
{
	local chance = RandomInt( 0, 4 )
	if( chance == 0 && g_RoundState.LifePreserverManager.SpawnedWaterZombieCount )
	{
		g_RoundState.LifePreserverManager.SpawnedWaterZombieCount--

		// spawn a special and re-enable preserver
		EntFire( self.GetName(), "fireuser3" )
		
		LifePreserver.inUse = true
		
		LifePreserver.useTarget.TurnOn()

		SetAvailable()
	}
	else
	{
		RescuePlayerFromWater()
	}
}
