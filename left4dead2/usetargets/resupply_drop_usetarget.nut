//=========================================================
// This script should be attached to a L4D2 Holdout Resupply helicopter buildable button
//=========================================================


IncludeScript("usetargets/base_buildable_target")
IncludeScript("usetargets/base_helicopter_button")
IncludeScript( "entity_script_utilities" )

BuildableType	<- "helicopter_resupply_drop"
ResourceCost	<- 12

// button options
BuildTime		<- 2.0
BuildText		<- "Radio helicopter for supply drop"
BuildSubText	<- "Cost: " + ResourceCost


// fired by completion of button press
function SummonRandomResupplyChopper()
{
	if( !( "ResupplyHelicopter" in g_RoundState ) )
	{
		printl(" ** Error: There is no Resupply drop chopper in the map!")
		return
	}
	
	// baseclass call to claim helicopter
	HelicopterBegin()

	g_RoundState.ResupplyHelicopter.SummonHelicopter()

	ActivateCustomObject()
}