//=========================================================
// For use on a resource locker "point_script_use_target"
//=========================================================

IncludeScript("usetargets/base_buildable_target")

BuildableType	<- "resource_locker"
ResourceCost	<- 0

// data
ResourceAmount	<- 5 // amount to award after opening

// button options
BuildTime		<- 60
BuildText		<- "Crate (contains " + ResourceAmount + " supplies)"

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

//-------------------------------------
function AwardLockerResource()
{
	g_ResourceManager.AddResources( 1 )
	ResourceAmount--
	if( ResourceAmount == 0 )
	{
		EntFire( self.GetName(), "kill", 0, 0 )
	}
}
