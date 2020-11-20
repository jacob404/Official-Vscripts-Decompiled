//=========================================================
// For use on med cabinet "point_script_use_target"
//=========================================================

IncludeScript("usetargets/base_buildable_target")

BuildableType	<- "health_cabinet"
ResourceCost	<- 4

// button options
BuildTime		<- 3
BuildText		<- "Buy Pills and Adrenaline"

if( ResourceCost )
{
	BuildSubText	<- "Cost: " + ResourceCost
}
else
{
	BuildSubText	<- "Cost: FREE"
}