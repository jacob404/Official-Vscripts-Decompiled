//=========================================================
// For use on a health cabinet "point_script_use_target"
//=========================================================

IncludeScript("usetargets/base_buildable_target")

BuildableType	<- "health_cabinet"
ResourceCost	<- 0

// button options
BuildTime		<- 10
BuildText		<- "Buy First Aid Kits"

if( ResourceCost )
{
	BuildSubText	<- "Cost: " + ResourceCost
}
else
{
	BuildSubText	<- "Cost: FREE"
}