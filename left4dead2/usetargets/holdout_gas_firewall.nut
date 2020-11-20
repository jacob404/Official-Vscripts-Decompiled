//=========================================================
// For use on a firewall trap "point_script_use_target"
//=========================================================
IncludeScript( "entity_script_utilities" )

// debug
DBG <- 0

function debugPrint( string )
{
	if( DBG )
	{
		printl( string )
	}
}

// defines
FUEL_MAX			<- 4
FUEL_PER_CAN 		<- 2
FUEL_BURN_RATE 		<- 1
TRAP_BURN_TIME		<- 6 // time in seconds.  must update map fire entities if changed (keys and entity IO)
PIPE_SEARCH_RADIUS	<- 160 // how far to search from one pipe to find a nearby connected pipe

// data
init <- false
currentFuel <- 0
trapArmed <- false
trapArmTime 			<- 0	// the time the trap gets armed
trapActivatedTime		<- 0	// the time the trap gets activated
trapExpiredTime			<- 0	// the time the trap finishes burning
trapPipeArray			<- []	// trap pipes attached to this fire trap

trapTargetEntityName <- LookupInstancedName( "flametrap_target_arm" )
trapNozzleName <- LookupInstancedName( "flametrap_nozzle" )
gaugeNeedleName <- LookupInstancedName( "flametrap_fuel_gauge_needle" )
trapFireName <- LookupInstancedName( "flametrap_fire" )
trapStartPipeName <- LookupInstancedName( "flametrap_pipe_point" )

// ----------------------------------------------------------------------------
function Precache()
{
	self.ConnectOutput( "OnUseFinished", "AddFuel" )
}

function VecDistSqr( v1, v2 )
{
	return ( v2.x - v1.x ) * (v2.x - v1.x) + ( v2.y - v1.y ) * (v2.y - v1.y) + ( v2.z - v1.z ) * (v2.z - v1.z)
}

// ----------------------------------------------------------------------------
function CollectFlametrapPipes()
{
	local currentPipeEnt = null
	local unsortedTrapPipeArray	= []

	currentPipeEnt = Entities.FindByClassname( currentPipeEnt, "info_target" )

	// collect all the flame pipes in the map into a list
	while( currentPipeEnt )
	{
		// only store the flametrap pipes
		if( currentPipeEnt.GetName().find( "flametrap_pipe_point" ) )
		{
			unsortedTrapPipeArray.append( currentPipeEnt )
		}

		//DebugDrawCircle(currentPipeEnt.GetOrigin(), (Vector(0,255,0)*0.5), 100, PIPE_SEARCH_RADIUS, true, 30)

		currentPipeEnt = Entities.FindByClassname( currentPipeEnt, "info_target" )
	}

	// find the pipes that are connected to this flame trap
	currentPipeEnt = null
	currentPipeEnt = Entities.FindByName( currentPipeEnt, trapStartPipeName )

	// add the start point to the pipe array
	trapPipeArray.append( currentPipeEnt )

	//DebugDrawCircle(trapPipeArray[0].GetOrigin(), Vector(255,255,0), 255, 16, true, 30)
	
	// find all the targets that connect to the start point
	foreach( x, val in trapPipeArray )
	{	
		foreach( y, val in unsortedTrapPipeArray )
		{
			if( y < unsortedTrapPipeArray.len() )
			{				
				if( VecDistSqr( trapPipeArray[x].GetOrigin(), unsortedTrapPipeArray[y].GetOrigin() ) <= (PIPE_SEARCH_RADIUS*PIPE_SEARCH_RADIUS ) )
				{
					//DebugDrawCircle(unsortedTrapPipeArray[y].GetOrigin(), Vector(255,0,0), 255, 16, true, 30)	
					trapPipeArray.append( unsortedTrapPipeArray[y] )
					unsortedTrapPipeArray.remove( y )
				}
			}
		}
	}
}


// ----------------------------------------------------------------------------
function IgniteTrapPipes()
{
	for( local i=0; i<trapPipeArray.len(); i++ )
	{
		
		// FireUser1 on the info_target enables and starts fires associated with the pipe
		EntFire( trapPipeArray[i].GetName(), "FireUser1" )
	}
}

// ----------------------------------------------------------------------------
function AddFuel()
{
	if( currentFuel < FUEL_MAX )
	{
		currentFuel += FUEL_PER_CAN
		debugPrint("Fuel added! New fuel: " + currentFuel )
	}
	
	// clamp fuel
	if( currentFuel > FUEL_MAX)
	{
		currentFuel = FUEL_MAX
	}
	
	// if fuel tank is full prevent refueling
	if( currentFuel == FUEL_MAX )
	{
		LockFuelTank()
	}
	
	UpdateFuelGauge()
}

// ----------------------------------------------------------------------------
function BurnFuel()
{
	currentFuel -= FUEL_BURN_RATE
	
	// clamp fuel
	if( currentFuel <= 0 )
	{
		currentFuel = 0
	}
	
	if( currentFuel < FUEL_MAX )
	{
		UnlockFuelTank()
	}
	
	UpdateFuelGauge()
	
	debugPrint("Burning fuel! Fuel now at: " + currentFuel )
}

// ----------------------------------------------------------------------------
function UpdateFuelGauge()
{
	local pos = 0
	
	debugPrint("== UpdateGauge - Fuel : " + currentFuel )
	
	if( currentFuel > 0 )
	{
		pos = (currentFuel / 4.0 )
	}
	else
	{
		pos = 0.01
	}
	
	debugPrint("== Fuel Needle Pos: " + pos )
	
	EntFire( gaugeNeedleName, "setposition", pos, 0 )
}

// ----------------------------------------------------------------------------
function LockFuelTank()
{
	printl(" == Locking fuel tank")
	EntFire( self.GetName(), "deactivate", 0, 0 )
	EntFire( trapNozzleName, "stopglowing", 0, 0 )
}

// ----------------------------------------------------------------------------
function UnlockFuelTank()
{
	debugPrint(" == Unlocking fuel tank")
	EntFire( self.GetName(), "activate", 0, 0 )
	EntFire( trapNozzleName, "startglowing", 0, 0 )
}

// ----------------------------------------------------------------------------
function FireTrapThink()
{
	// search for connected trap pipes on first think
	if( !init )
	{
		init = true
		CollectFlametrapPipes()
	}

	debugPrint("Think - Fuel: " + currentFuel )
	
	if( ReadyToArm() )
	{
		debugPrint("		I have fuel!  Arming trap. Fuel:" + currentFuel )
		
		 ArmTrap()
	}
	else if( !HasFuel() )
	{
		debugPrint("I do not have fuel: " + currentFuel )
	}
	
}

function ReadyToArm()
{
	if( HasFuel() && !IsTrapArmed() && (Time() > trapExpiredTime) )
	{
		debugPrint("Ready to arm trap!")
		return true
	}
	
	return false
}

// ----------------------------------------------------------------------------
function HasFuel()
{
	return ( currentFuel > 0 ) ? 1:0
}

// ----------------------------------------------------------------------------
function ArmTrap()
{
	// don't double-arm trap
	if( IsTrapArmed() )
	{
		debugPrint(" --- avoiding double arm --- this shouldn't happen.")
		return
	}
	debugPrint("Arming trap!")
	
	trapArmed = true
	
	EntFire( trapTargetEntityName, "open", 0, 0 )
}

// ----------------------------------------------------------------------------
function DisarmTrap()
{
	trapArmed = false
} 

// ----------------------------------------------------------------------------
function IsTrapArmed()
{
	return trapArmed
}

// ----------------------------------------------------------------------------
function StartFireTrap()
{
	if( !IsTrapArmed() )
	{
		debugPrint("StartFireTrap() -- trap already started. Ignoring.")
		return
	}
	
	BurnFuel()
	DisarmTrap()
	
	IgniteTrapPipes()
	
	// close the trap arm
	EntFire( trapTargetEntityName, "close", 0, 0 )
	
	
	trapExpiredTime = Time() + TRAP_BURN_TIME + 1.0 // pad time by 1 second, giving fires time to burn out
	
	debugPrint("Fire started!  Time: " + Time() + " Expire time: " + trapExpiredTime )
}
