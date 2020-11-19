//=========================================================

cashValue <- 5
cashAwarded <- false

spawnTime 		<- 0
expireTime		<- 40 // seconds

myID <- 0  // replaced on load
active <- false
waypointInitialized <- false

touches <- 0
touchers <- []

// how many "touches" the pole should have when it spawns
initialTouchCount <- 0


self.ConnectOutput( "OnPlayerTouch", "HitWaypoint" )

//---------------------------------------------------------
// called when resource package trigger is touched by player
//---------------------------------------------------------
function HitWaypoint()
{
	print( "Hit a waypoint\n" )
}

function OnPostSpawn()
{
	// the "bug" here is that we dont have the rarity data anymore...
//	cashValue = g_RoundState.CashSpawnValueHack++
}

// this works, but sadly isnt called in time - i.e. we are already in Spawn, sadly - though at top
// but we already have gotten the assert about model not being in the precache
function Precache()
{
	spawnTime = Time()
}

// Called when a waypoint is "touched"
// Waypoints are always activated in order
function ActivateWaypoint( shouldTriggerActivationEffects )
{
	++touches

	// clamp
	if( touches > 4 )
		touches = 4

	EntFire( EntityGroup[touches].GetName(), "color", "0 255 0" )
	EntFire( EntityGroup[touches].GetName(), "setglowoverride", "0 255 0" )
	
	// activates the touch fx on the object (e.g., fireworks launch)
	if( shouldTriggerActivationEffects)
		EntFire( EntityGroup[touches].GetName(), "fireuser1")
}

//---------------------------------------------------------
function Think()
{	
	local FindEntity = null;
	if ( !active )
		return

	// The waypoint has become active.
	// On the first "active" Think enable the touch indicators and make them glow
	// and "touch" indicators initialTouchCount times.
	if( !waypointInitialized )
	{
		// start touch indicators glowing
		EntFire( EntityGroup[1].GetName(), "enable" )
		EntFire( EntityGroup[1].GetName(), "startglowing" )

		EntFire( EntityGroup[2].GetName(), "enable" )
		EntFire( EntityGroup[2].GetName(), "startglowing" )
	
		EntFire( EntityGroup[3].GetName(), "enable" )
		EntFire( EntityGroup[3].GetName(), "startglowing" )
	
		EntFire( EntityGroup[4].GetName(), "enable" )
		EntFire( EntityGroup[4].GetName(), "startglowing" )

		// "touch" indicators initialTouchCount times
		for( local i=0; i < initialTouchCount; i++ )
		{
			ActivateWaypoint( false )
		}

		waypointInitialized = true
	}

	while( ( FindEntity = Entities.FindByClassnameWithin( FindEntity, "player", self.GetOrigin(), 100 ) ) != null )
	{
		// ignore specials
		if( !FindEntity.IsSurvivor() )
			continue

		local handle = FindEntity.GetEntityHandle()
		if ( touchers.find( handle ) == null )
		{
			touchers.append( handle )	
			ActivateWaypoint( true )
		}

		//printl( "*** Found a toucher: " + handle + "    (p.s. my id is " + myID + " )" )
	}

	if ( touches == 4 )
	{
		g_ModeScript.DashWaypointDone( myID )

		// kill the poles!
		EntFire( EntityGroup[1].GetName(), "kill" )
		EntFire( EntityGroup[2].GetName(), "kill" )
		EntFire( EntityGroup[3].GetName(), "kill" )
		EntFire( EntityGroup[4].GetName(), "kill" )

		// printl("Called DWD for " + myID + "ps. now im " + active)
	}
}