//=========================================================
// Base helicopter button - included by L4D2 buildable scripts
// that need to know the status of the helicopter for evaluating
// enable, disable states
//=========================================================

// add helicopter state to dependency table
UseStateDependencies.HelicopterAvailable <- true

function OnScriptEvent_on_helicopter_begin( params )
{
	UseStateDependencies.HelicopterAvailable = false
	
	// baseclass
	UpdateButtonState()
}

function OnScriptEvent_on_helicopter_end( params )
{
	UseStateDependencies.HelicopterAvailable = true
	
	// baseclass
	UpdateButtonState()
}

function OnScriptEvent_on_cooldown_begin( params )
{	
	// baseclass
	UpdateButtonState()
}

function OnScriptEvent_on_cooldown_end( params )
{	
	// baseclass
	UpdateButtonState()
}

function HelicopterBegin()
{
	FireScriptEvent( "on_helicopter_begin", null ) // false = no longer available
}