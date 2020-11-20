//=========================================================
// For use on tank manhole "point_script_use_target"
//=========================================================

IncludeScript("usetargets/base_buildable_target")

BuildableType	<- "tank_barricade"
ResourceCost	<- 1
incrementalCost <- 1 // amount the price increases per use

//override of base class. 
GLOW_RANGE = 5000

// button options
BuildTime		<- 1
BuildText		<- "Barricade the Tank"

// when the tank spawns it needs a barricade or it will get released.  If false, barricade will not be buildable
UseStateDependencies.TankNeedsBarricade <- false

// turn off the build panel on spawn
DisableBuildPanel()

// tank has spawned and threatening to escape
function TankThreatening()
{
	UseStateDependencies.TankNeedsBarricade = true

	UpdateButtonState()
}

// tank has been barricaded
function TankBarricaded()
{
	UseStateDependencies.TankNeedsBarricade = false

	UpdateButtonState()
} 