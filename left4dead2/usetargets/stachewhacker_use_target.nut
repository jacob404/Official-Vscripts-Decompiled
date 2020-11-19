//=========================================================
// For use on the carnival game Stachwhacker "point_script_use_target"
//=========================================================

IncludeScript("usetargets/base_buildable_target")

BuildableType	<- "wam_game"
ResourceCost	<- 1

//override of base class. 
GLOW_RANGE = 5000

// button options
BuildTime		<- 0.5
BuildText		<- "Insert Coin"

// Tracks if the game is available for play
UseStateDependencies.GameAvailable <- true

self.ConnectOutput( "OnUser1", "OnButtonPress" )

// button was successfully pressed
function OnButtonPress()
{
	GameInProgress()
}

// The game is being played
function GameInProgress()
{
	UseStateDependencies.GameAvailable = false
	
	DisableBuildPanel()

	UpdateButtonState()
}

// The game is not being played
function GameOver()
{
	UseStateDependencies.GameAvailable = true

	EnableBuildPanel()

	UpdateButtonState()
}