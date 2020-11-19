//=========================================================
// This script should be attached to a L4D2 Holdout gascan helicopter buildable button
//=========================================================


IncludeScript("usetargets/base_buildable_target")
IncludeScript("usetargets/base_helicopter_button")

BuildableType	<- "helicopter_gascan_drop"
ResourceCost	<- 5
incrementalCost <- 5

// button options
BuildTime		<- 2.0
BuildText		<- "Radio helicopter for gascan drop"
BuildSubText	<- "Cost: " + ResourceCost


// fired by completion of button press
function SummonRandomGascanChopper()
{	
	if( !( "GascanHelicopter" in g_RoundState ) )
	{
		printl(" ** Error: There is no Gascan drop chopper in the map!")
		return
	}
	
	// baseclass call to claim helicopter
	HelicopterBegin()

	g_RoundState.GascanHelicopter.SummonHelicopter()
}
