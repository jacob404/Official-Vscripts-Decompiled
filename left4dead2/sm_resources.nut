// resource manager
//  We load this at MapScript scope, so we can put our GameEvent of infected dropping resource into it
//  We also put a g_ResourceManager at Root Scope, that delegates to it
// 
// @TODO: Parameterize the OnGameEvent callback, or make it replaceable? so per-game-per-map tweaks can happen
//  


//---------------------------------------------------------
// this table can be accessed at root scope with g_ResourceManager
//---------------------------------------------------------
Resources <-
{
	CurrentCount = 0
	debug = false

	DropChance = 1.0

	function resDbgPrint( string )
	{
		if( debug )
			printl( "ResMan:* " + string )
	}

	// ----------------------------------------------------------------------------
	function Purchase( cost )
	{
		resDbgPrint("PURCHASE RUNNING!....")
		
		if( CanAfford( cost ) )
		{
			resDbgPrint("Buying, Price is: " + cost + " CurrentCount: " + CurrentCount)
			RemoveResources( cost )		
			resDbgPrint("new avail resources: " + CurrentCount ) 
			return true
		}

		resDbgPrint("***Not Enough resources!****")
		resDbgPrint("Current CurrentCount: " + CurrentCount ) 
		return false

	}

	// ----------------------------------------------------------------------------
	function CanAfford( cost )
	{
		resDbgPrint("Price is: " + cost)
		
		if( cost <= CurrentCount)
		{
			
			resDbgPrint("Price is: " + cost + " CurrentCount: " + CurrentCount + " You can afford this!")
			return true
		}
		if( cost > CurrentCount)
		{
			resDbgPrint("NOPE, can't buy. Current CurrentCount: " + CurrentCount ) 
			return false
		}
	}

	// ----------------------------------------------------------------------------
	function AddResources( val )
	{
		resDbgPrint("adding resources")
		CurrentCount += val
		resDbgPrint("added " + val + " new total is: " + CurrentCount)
		
		UpdateHud()
	}

	// ----------------------------------------------------------------------------
	function RemoveResources( val ) 
	{
		resDbgPrint("removing resources")
		CurrentCount -= val
		if( CurrentCount < 0 )
		{
			resDbgPrint("Warning: Resource count is less than zero - this shouldn't happen. Clamping to 0.")
			CurrentCount = 0
		}
		
		resDbgPrint("subtracted " + val + " new total is: " + CurrentCount)
		
		UpdateHud()
	}

	// ----------------------------------------------------------------------------
	// updates the root table value that the HUD UI examines every frame
	// ----------------------------------------------------------------------------
	function UpdateHud()
	{
		local params = { newcount = CurrentCount };
		FireScriptEvent( "on_resources_changed", params );
	}

}

//---------------------------------------------------------
// Lets make this more easily accessed from throughout the code
// the g_ is just a convention thing for globals, it doesnt actually do anything
//---------------------------------------------------------
::g_ResourceManager <- Resources

//=========================================================
// GameEvents get called at MapScope, so we sadly cant put this inside the table above
//=========================================================
function OnGameEvent_zombie_death( params )
{	
	if ( params.infected_id == ZOMBIE_NORMAL )
		return;

	smDbgPrint("TYPE KILLED: " + params.infected_id )

	local chance = g_ResourceManager.DropChance
	if ( RandomFloat(0,1) > chance )
	{
		smDbgPrint( "Sorry, failed at your " + chance * 100 * "% chance" )
		return
	}
	
	local victim = EntIndexToHScript( params.victim );
	smDbgPrint( "Spawning item at: " + victim.GetOrigin() + " - " + Vector(0,0,0) )
	
	//get entity group from the map
	local coinEntityGroup = g_MapScript.GetEntityGroup( "PlaceableResource" )
	//spawn the coin 16 units above the victim
	SpawnSingleAt( coinEntityGroup, victim.GetOrigin() + Vector(0,0,16) , QAngle( 0,0,0) )	
}

