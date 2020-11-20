//=========================================================
// Base Buildable Use Target
// Used in the Holdout mod on usable objects that consume resources
// to create objects in the map.
//=========================================================
DBG <- 0

function debugPrint( string )
{
	if ( DBG )
		printl( string )
}

// Overrides 
// This file is intended to be IncludeScripted at the top of other files
// in order to factor out common functionality. The following
// variables should be overwritten in the host file.
BuildTime <- 0
BuildableType <- "Base Buildable"
ResourceCost <- 0
BuildText <- "Base Buildable Text"	
BuildSubText <- "Base Buildable Subtext"

// cumulative data
BuildCumulative <- false
BuildCumulativeProgress <- 0
incrementalCost <- 0

// stop on hurt
BuildStopOnHurt <- false

// Distance to start glowing
GLOW_RANGE <- 100


// This table holds button dependencies for determining enable/disable state.
// Descended classes can add state cases that they need to evaluate 
// e.g., button not usable if helicopter is in flight
UseStateDependencies <- { canAfford = false, buttonOn = true  }

//
// Game engine hooks
//

// Called by the game engine when the entity first spawns, immediately after this script is run.
function Precache()
{
	UpdateCostString()

	self.SetProgressBarText( BuildText );
	self.SetProgressBarSubText( BuildSubText );
	self.SetProgressBarFinishTime( BuildTime );
	self.SetProgressBarCurrentProgress( 0.0 );

	SetGlowRange( GLOW_RANGE )
	
	// Initialize to disabled
	Enabled = true;
	DisableUse()
}

function SetGlowRange( glowrange )
{
	
	// set the default glow distance
	EntFire( self.GetUseModelName(), "SetGlowRange", glowrange )
	//printl("<><><><><>GLOW IS " + glowrange)
	
}

function SetCumulativeProgress( progress )
{
	BuildCumulativeProgress = progress
	if ( BuildCumulative )
	{
		self.SetProgressBarCurrentProgress( BuildCumulativeProgress )
	}
}

// Called when the player begins to use this button
function OnUseStart()
{	
	if ( Enabled == false )
		return false

	debugPrint( self.GetName() + " starting use. BuildTime: " + BuildTime )
	
	local canAfford = g_ResourceManager.CanAfford( ResourceCost )
	
	if( canAfford && BuildCumulative)
	{
		SetCumulativeProgress( BuildCumulativeProgress );
	}
	
	return 	canAfford
}

// Called when the player stops using this button
// Passes the time this button has been used (time between StartUse and now).
function OnUseStop( timeUsed )
{
	debugPrint( self.GetName() + " stopped being used. Time used: " + timeUsed )
	
	// store the time used as cumulative progress so cumulative buttons know where to resume
	SetCumulativeProgress( timeUsed )
}

// Called when the player has used this button for at least 'BuildTime' seconds.
function OnUseFinished()
{
	debugPrint("Attempting to purchase: " + self.GetName() + " of type " + BuildableType )

	local purchaseSucceeded = g_ResourceManager.Purchase( ResourceCost )
	
	if( purchaseSucceeded )
	{
		// FireUser1 is the button entity IO that gets fired on successful use
		EntFire( self.GetName(), "FireUser1", 0, 0 )
		UpdatePrice()
	}
	else
	{
		debugPrint("Purchase failed (insufficient funds?) " + self.GetName() + " of type " + BuildableType )
	}
	
	// reset cumulative time
	SetCumulativeProgress( 0 )

	// call descended class BuildCompleted if it exists
	if( "BuildCompleted" in this )
	{
		BuildCompleted()
	}
} 

//
// Game Event hooks
// The game engine will call 

// "this" is the script table
function OnScriptEvent_on_resources_changed( params )
{
	UseStateDependencies.canAfford = g_ResourceManager.CanAfford( ResourceCost )
	
	UpdateButtonState()
}

function UpdateButtonState()
{
	if( !ShouldEnable() )
	{
		debugPrint( "Disable-Using this resource : " + self.GetName() )
		if ("DisableUse" in this)
			DisableUse()
		else
			debugPrint( "Can't find Disable for " + self.GetName())
	}
	else
	{
		debugPrint( "Enable-Using this resource: " + self.GetName() )
		if ("EnableUse" in this)
			EnableUse()
		else
			debugPrint( "Can't find Enable for " + self.GetName())
	}
}

// check the dependencies of the button to see if it can be enabled
function ShouldEnable()
{
	debugPrint("-----------------------------------------")
	debugPrint( "Entity: " + self.GetName() )
	foreach( dependency, value in UseStateDependencies )
	{
		debugPrint( " == Dependency: " + dependency + "\n == Value: " + value )
		
		if( !value  )
		{
			debugPrint(" == should not enable")
			return false
		}
	}
	
	debugPrint(" ** should enable!")
	return true
}

//
// Local Vars and functions 
//


function TurnOff()
{
	// bail if the button is already off
	if( !UseStateDependencies.buttonOn )
		return

	UseStateDependencies.buttonOn = false
	
	// disable glow
	EntFire( self.GetUseModelName(), "stopglowing", 0 )

	// disable rendering of the use model
	EntFire( self.GetUseModelName(), "disable", 0, 0.1 )


	DisableBuildPanel()

	StopButtonUse()

	UpdateButtonState()
}

function TurnOn()
{
	// bail if the button is already on
	if( UseStateDependencies.buttonOn )
		return

	UseStateDependencies.buttonOn = true
	
	// enable rendering of the use model
	EntFire( self.GetUseModelName(), "enable", 0 )
	
	// enable glow
	EntFire( self.GetUseModelName(), "startglowing", 0, 0.1 )


	EnableBuildPanel()

	UpdateButtonState()
}

Enabled <- false;

function EnableUse()
{
	if ( Enabled )
		return

	debugPrint( "Doing EnableUse for " + self.GetName() )
	Enabled = true
	
	EntFire( self.GetUseModelName(), "SetGlowOverride", "0 255 0" )
	EntFire( self.GetUseModelName(), "Skin", "0", 0 )
}

function DisableUse()
{
	if ( !Enabled )
		return

	debugPrint( "Doing DisableUse for " + self.GetName() )
	Enabled = false
	self.StopUse()
	
	EntFire( self.GetUseModelName(), "SetGlowOverride", "255 0 0" )
	EntFire( self.GetUseModelName(), "Skin", "2", 0 )
}

function UpdatePrice()
{
	ResourceCost += incrementalCost
	debugPrint(" == Updating price on " + self.GetName() + ". Price is now: " + ResourceCost )
	
	UpdateCostString()
}

function UpdateCostString()
{
	if( ResourceCost )
	{
		BuildSubText	<- "Cost: " + ResourceCost
	}

	self.SetProgressBarSubText( BuildSubText )
}


function DisableBuildPanel()
{
	self.CanShowBuildPanel( false )
}

function EnableBuildPanel()
{
	// only enable the build panel if the button is ON
	if( !UseStateDependencies.buttonOn)
		return

	self.CanShowBuildPanel( true )
}


// Interrupt +use of button
function StopButtonUse()
{
	self.StopUse()
}

// If this button is flagged to use a custom relay it will search nearby for one and activate it
function ActivateCustomObject()
{
	// exit early if we are not flagged to use a custom relay
	if( LookupReplacementKey( "$custom_relay" ) != "1" )
		return

	// radius to search
	local SEARCH_DIST = 8

	// Search nearby for a relay to trigger
	local cur_ent = Entities.FindByClassnameWithin( null, "logic_relay", self.GetOrigin(), SEARCH_DIST )
	
	// fire all the relays nearby with the name "custom_relay"
	while( cur_ent )
	{
		if( cur_ent.GetName().find( "custom_relay" ) )
		{
			EntFire( cur_ent.GetName(), "trigger" )
		}

		cur_ent = Entities.FindByClassnameWithin( cur_ent, "logic_relay", self.GetOrigin(), SEARCH_DIST )
	}	
}



// obsolete
/*
function OnGameEvent_player_hurt( params )
{
	// bail early if we don't stop building on taking damage
	if( !BuildStopOnHurt || !PlayerUsingMe )
		return

	local PlayerHurt = PlayerInstanceFromIndex( params.userid )
	if ( this.PlayerUsingMe == PlayerHurt )
	{
		StopUse()
	}
		
	if( BuildCumulative )
	{
		// This currently doesn't work as intended
		// reduce some progress off of the buildable
//		printl(" ** Progress reduction!  Progress is: " + BuildCumulativeProgress )
//		BuildCumulativeProgress *= 0.9 // shave off 10%
//		printl(" ** Progress reduction!  Progress reduced to : " + BuildCumulativeProgress )
	}

}
*/