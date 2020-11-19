//=========================================================
// This script should be included by barricades
//=========================================================

IncludeScript( "entity_script_utilities" )

ResourceCost	<- 0
BuildSubText	<- "Cost: " + ResourceCost
BuildText		<- "Build Barricade"

BuildCumulative = true
BuildStopOnHurt = true

// tracks barricade being blocked by infected
UseStateDependencies.Unblocked <- true

// tracks barricade being in a state of disrepair
UseStateDependencies.Broken <- true


if( ResourceCost )
{
	BuildSubText	<- "Cost: " + ResourceCost
}
else
{
	BuildSubText	<- "Cost: FREE"
}


function OnPostSpawn()
{		
	if( LookupReplacementKey( "$barricade_start_on" ) == "1" )
	{
		EntFire( "!self", "FireUser1" )
		// barricade is fully built so disable the build panel
		BuildCompleted()
	}

	if( LookupReplacementKey( "$button_start_off" ) == "1" )
	{
		TurnOff()
	}
}

function WindowBlocked()
{
	UseStateDependencies.Unblocked = false
	UpdateButtonState()
}

function WindowUnblocked()
{
	UseStateDependencies.Unblocked = true
	UpdateButtonState()
}

// called when the barricade takes enough damage that it can be rebuilt
function NeedsRepairs()
{
	if( UseStateDependencies.Broken )
		return

	UseStateDependencies.Broken = true
	UpdateButtonState()
	EnableBuildPanel()
	EntFire( self.GetUseModelName(), "startglowing", 0, 0 )
}

// called when the barricade is successfully built
function BuildCompleted()
{
	if( !UseStateDependencies.Broken )
		return

	UseStateDependencies.Broken = false
	UpdateButtonState()
	DisableBuildPanel()
	EntFire( self.GetUseModelName(), "stopglowing", 0, 0 )
}