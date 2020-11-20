//=========================================================
// This is the new cash resource - soon to be a more generated inject for new powerup system

// if you use the LookupInstanceName thing - you need this...
//IncludeScript("entity_script_utilities.nut")

cashValue <- 8
cashAwarded <- false

spawnTime 		<- 0
expireTime		<- 0 // seconds

glowBlinkDuration		<- 6				// number of seconds to blink before expiring
glowBlinkRate			<- 0.25				// how often to blink
glowBlinkNextThink		<- 0
glowBlinkColor  		<- "255 0 0"
glowDefaultColor		<- "255 255 255"
glowBlinkToggleState	<- false

self.ConnectOutput( "OnPlayerPickup", "AwardCash" )
// the trigger itself also has a direct call to AwardCash

//---------------------------------------------------------
// called when resource package trigger is touched by player
//---------------------------------------------------------
function AwardCash()
{
	if( !cashAwarded )
	{
		EmitSoundOn( "WAM.PointScored", self )
		// printl("CASH! $" + cashValue )
		g_ModeScript.GiveCash( cashValue )
		g_ModeScript.CreateParticleSystemAt( self, Vector(0,0,6), "st_elmos_fire_cp0", true )
		Destruct()
	}
	else
		printl("Did we really get called twice for " + self.GetName() )
	cashAwarded = true
}

function Destruct()
{
	self.Kill();
// if you didnt have stuff correctly parented, you could do this for sub-entities you need
//	  local trigger_name = LookupInstancedName( "trigger_award_resource" )
//	  EntFire( trigger_name, "kill", 0, 0.1 )
}

//---------------------------------------------------------
// if you want a powerup that times out

// function Precache()
// {
// 	if (expireTime > 0)
//  		spawnTime = Time()
// }

// function Think()
// {		
// 	if (expireTime == 0)   // really - want no think for these... how to manage. Can we choose to have a Think dynamically
// 		return             // or name this something else than inject it for others... that is probably best choice...
// 	if( spawnTime + expireTime < Time() )
// 	{
//  		g_ModeScript.CreateParticleSystemAt( self, Vector(0,0,12), "bridge_isparkA", true )
//  		Destruct()
//  	}
// 	else if( (spawnTime + expireTime - glowBlinkDuration) < Time() )
//  	{
//  		if( glowBlinkNextThink < Time() )
//  		{
//  			ToggleBlink()
//  			glowBlinkNextThink = Time() + glowBlinkRate
//  		}
//  	}
// }

// function ToggleBlink()
// {
// 	local glow_color = glowBlinkToggleState ? glowDefaultColor : glowBlinkColor;
// 	EntFire( self.GetName(), "color", glow_color, 0 )
// 	glowBlinkToggleState = !glowBlinkToggleState
// }