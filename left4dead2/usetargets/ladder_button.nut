// ----------------------------------------------------------------------------
// This button is used to build a ladder object.  It requires a ladder entity group
// (created from ladder.vmf) be placed within LADDER_SEARCH_DIST units.
// ----------------------------------------------------------------------------

IncludeScript("usetargets/base_buildable_target")

BuildableType	<- "ladder_128"
ResourceCost	<- 0

// button options
BuildTime		<- 20
BuildText		<- "Build Ladder"
BuildSubText	<- "Cost: " + ResourceCost

BuildCumulative = true
BuildStopOnHurt = true

if( ResourceCost )
{
	BuildSubText	<- "Cost: " + ResourceCost
}
else
{
	BuildSubText	<- "Cost: FREE"
}
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


// data
LADDER_SEARCH_DIST		<- 128
LADDER_SEARCH_STRING	<- "ladder_128_target"
targetLadderEnt			<- null


// ----------------------------------------------------------------------------
function OnPostSpawn()
{
	// connect this button with a nearby ladder object
	ConnectToLadder()
}


// ----------------------------------------------------------------------------
function ConnectToLadder()
{
	local curEnt = Entities.FindByClassnameWithin( null, "info_target", self.GetOrigin(), LADDER_SEARCH_DIST )
	
	if( curEnt )
	{
		while( curEnt )
		{
			// Does our search string match the targetname of the found entity?
			if( curEnt.GetName().find( LADDER_SEARCH_STRING ) )
			{
				targetLadderEnt = curEnt
				curEnt = null
			}
			else
			{
				curEnt = Entities.FindByClassnameWithin( curEnt, "info_target", self.GetOrigin(), LADDER_SEARCH_DIST )
			}
		}

	}
	else
	{
		printl(" *** ERROR: Ladder button: " + self.GetName() + " could not find a nearby latter to connect to!  Did you forget to add a ladder or is it too far away from the button?")
	}
}


// ----------------------------------------------------------------------------
function BuildLadder()
{
	if( targetLadderEnt )
	{
		EntFire( targetLadderEnt.GetName(), "FireUser1" )
	}
	else
	{
		printl(" *** ERROR: Ladder button: " + self.GetName() + " was +used but does not have a target ladder to build! ")
	}
}