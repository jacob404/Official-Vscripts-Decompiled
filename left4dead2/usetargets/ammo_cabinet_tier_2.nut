//=========================================================
// For use on a Tier 2 weapon cabinet "point_script_use_target"
//=========================================================


IncludeScript("usetargets/base_buildable_target")

BuildableType	<- "ammo_cabinet_tier_2"
ResourceCost	<- 4

// button options
BuildTime		<- 1.0
BuildText		<- "TIER 2 Weapons"
BuildSubText	<- "Cost: " + ResourceCost