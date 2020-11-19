//=========================================================
// For use on an ammo crate "point_script_use_target"
//=========================================================

IncludeScript("usetargets/base_buildable_target")

BuildableType	<- "ammo_crate"
ResourceCost	<- 5

// button options
BuildTime		<- 2
BuildText		<- "Open Ammo Crate"
BuildSubText	<- "Cost: " + ResourceCost
