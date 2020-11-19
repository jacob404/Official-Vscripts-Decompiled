//=========================================================
// For use on a defib cabinet "point_script_use_target"
//=========================================================

IncludeScript("usetargets/base_buildable_target")
BuildableType	<- "defib_cabinet"
ResourceCost	<- 2

// button options
BuildTime		<- 5
BuildText		<- "Buy Defibrillators"
BuildSubText	<- "Cost: " + ResourceCost

if( ResourceCost )
{
	BuildSubText	<- "Cost: " + ResourceCost
}
else
{
	BuildSubText	<- "Cost: FREE"
}