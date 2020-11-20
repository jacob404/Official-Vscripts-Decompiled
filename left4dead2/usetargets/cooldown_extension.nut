//=========================================================
// For use on the cooldown "point_script_use_target"
// Extends the length of a cooldown in a holdout game
//=========================================================

IncludeScript("usetargets/base_buildable_target")

BuildableType	<- "cooldown_extension"
ResourceCost	<- 2
incrementalCost <- 1

// button options
BuildTime		<- 2.0
BuildText		<- "Radio for more time"
BuildSubText	<- "Cost: " + ResourceCost 

local CooldownExtendSeconds = 60.0

// add cooldown state to dependency table
UseStateDependencies.InCooldownStage <- false


function OnScriptEvent_on_cooldown_begin( params )
{
	// if we just started the map do not enable the button despite being in a "cooldown"
	if( SessionState.RawStageNum == 0 )
	{
		UseStateDependencies.InCooldownStage = false
	}
	else
	{
		UseStateDependencies.InCooldownStage = true
	}
	
	// baseclass
	UpdateButtonState()
}

function OnScriptEvent_on_cooldown_end( params )
{
	UseStateDependencies.InCooldownStage = false
	
	// baseclass
	UpdateButtonState()
}


function ExtendCooldownTime()
{
	local ftime = Director.GetHoldoutCooldownEndTime();
	Director.SetHoldoutCooldownEndTime( ftime + CooldownExtendSeconds );
}


function SetExtraTime(i)
{
	CooldownExtendSeconds = i	
}
