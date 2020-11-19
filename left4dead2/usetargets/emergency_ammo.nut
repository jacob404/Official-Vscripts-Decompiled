//=========================================================
// For use on an ammo cabinet "point_script_use_target"
//=========================================================

IncludeScript("usetargets/base_buildable_target")

BuildableType	<- "emergency_ammo"
ResourceCost	<- 1

// button options
BuildTime		<- 1.0
BuildText		<- "Buy Emergency Ammo"
BuildSubText	<- "Cost: " + ResourceCost