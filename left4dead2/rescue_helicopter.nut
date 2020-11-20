//=========================================================
// This script is used by the Rescue Helicopter, an entity
// group that spawns a helicopter that allows the survivors
// to escape (and win a map).
// This script creates the helicopter entities and functions and
// store them in a table that is accessible from g_RoundState.
//=========================================================

g_RoundState.g_RescueManager <-
{ 
	startRelayName = EntityGroup[0].GetName()

	startFlyAwayRelay = EntityGroup[3].GetName() // entity that triggers the chopper to depart
	cleanupFlyAwayRelay = EntityGroup[4].GetName() // removes the ladder and other unneeded ents

	HelicopterAvailable = true
	ShouldSummon = false

	EnableRescue = function()
	{
		ShouldSummon = true
	}

	//-------------------------------------------------------
	// Summons the rescue chopper if possible.
	// Often times when the rescue occurs there is another 
	// helicopter flying around in the map, so this function
	// can be called on a tick to spawn the rescue chopper
	// as soon as possible (e.g., when the other chopper
	// flies away)
	//-------------------------------------------------------
	SummonRescueChopperCheck = function()
	{
		if( ShouldSummon == true && HelicopterAvailable )
		{
			ForceSummonRescueChopper()
		}
	}

	//-------------------------------------------------------
	// Spawns the rescue chopper without checking to see if it
	// is available
	//-------------------------------------------------------
	ForceSummonRescueChopper = function()
	{
		// claim the helicopter
		HelicopterAvailable = false
		FireScriptEvent( "on_helicopter_begin", null )

		EntFire( startRelayName, "trigger", 0, 0 )

		ShouldSummon = false
	}

	// Rescue completed!
	RescueSurvivors = function()
	{
		EntFire( startFlyAwayRelay, "trigger" )
		EntFire( cleanupFlyAwayRelay, "trigger", 0. 0.3 )
		g_MapScript.ScriptMode_SystemCall( "RescuedByCopter" )
	}
}

function OnScriptEvent_on_helicopter_begin( params )
{	
	g_RoundState.g_RescueManager.HelicopterAvailable = false
}

function OnScriptEvent_on_helicopter_end( params )
{
	g_RoundState.g_RescueManager.HelicopterAvailable = true
}

//-------------------------------------------------------
// Called by OnTrigger in rescue chopper with a reset delay
// of one second.
// If all the human survivors are in the chopper the rescue
// will begin.
// This allows humans to trigger the rescue without needing
// to wait for the bots (who will not try to reach the chopper)
//-------------------------------------------------------
function SurvivorInChopper()
{
	local playerEnt = null
	local playerArray = []

	local totalSurvivorCount = 0

	// Count all human survivors in the game
	while ( playerEnt = Entities.FindByClassname( playerEnt, "player" ) )
	{
		if (playerEnt.IsSurvivor() && !IsPlayerABot( playerEnt )  )
		{
			totalSurvivorCount++
		}
	}

	// Count human survivors in the rescue chopper.  Trigger the rescue if they're all nearby.
	while ( playerEnt = Entities.FindByClassnameWithin( playerEnt, "player", self.GetOrigin(), 250 ) )
	{
		if (playerEnt.IsSurvivor() && !IsPlayerABot( playerEnt ) )
		{
			playerArray.append( playerEnt)
		}
	}

	// if the number of human players in the chopper equals the number in the game, you win
	if( playerArray.len() >= totalSurvivorCount )
	{
		g_RoundState.g_RescueManager.RescueSurvivors()
	}
}