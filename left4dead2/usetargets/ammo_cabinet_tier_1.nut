//=========================================================
// For use on a Tier 1 weapon cabinet "point_script_use_target"
//=========================================================

IncludeScript("usetargets/base_buildable_target")


BuildableType	<- "ammo_cabinet_tier_1"
ResourceCost	<- 0

// button options
BuildTime		<- 2.0
BuildText		<- "TIER 1 Weapons"

if( ResourceCost )
{
	BuildSubText	<- "Cost: " + ResourceCost
}
else
{
	BuildSubText	<- "Cost: FREE"
}