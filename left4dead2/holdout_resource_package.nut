//=========================================================
// This script should be attached to a L4D2 Holdout barricade instance's button
//=========================================================

ResourceAmount	<- 1
spawnTime 		<- 0
expireTime		<- 20 // seconds
resourcesAwarded <- false

glowBlinkDuration		<- 6				// number of seconds to blink before expiring
glowBlinkRate			<- 0.25				// how often to blink
glowBlinkNextThink		<- 0
glowBlinkColor  		<- "255 0 0"
glowDefaultColor		<- "255 255 255"
glowBlinkToggleState	<- false

skin_green <- 1
skin_red <- 2


self.ConnectOutput( "OnPlayerTouch", "AwardResources" )
self.ConnectOutput( "OnPlayerPickup", "AwardResources" )


//---------------------------------------------------------
// called when resource package trigger is touched by player
//---------------------------------------------------------
function AwardResources()
{
	if ( !activator.IsSurvivor() )
		return

	if( !resourcesAwarded )
	{
		g_ResourceManager.AddResources( ResourceAmount )
		EntFire( self.GetName(), "FireUser1", 0, 0 )
		EntFire( self.GetName(), "kill", 0, 0.1 )
		EmitSoundOn( "WAM.PointScored", self )
	}
		
	resourcesAwarded = true
}

function Precache()
{
	spawnTime = Time()
}

//---------------------------------------------------------
function Think()
{		
	if( spawnTime + expireTime < Time() )
	{
		EntFire( self.GetName(), "kill", 0, 0 )
	}
	else if( (spawnTime + expireTime - glowBlinkDuration) < Time() )
	{
		// only blink at 
		if( glowBlinkNextThink < Time() )
		{
			ToggleBlink()
			glowBlinkNextThink = Time() + glowBlinkRate
		}
	}
}

function ToggleBlink()
{
	if( glowBlinkToggleState )
	{
		EntFire( self.GetName(), "skin", skin_green, 0 )
	}
	else
	{
		EntFire( self.GetName(), "skin", skin_red, 0 )
	}
	
	glowBlinkToggleState = !glowBlinkToggleState
}