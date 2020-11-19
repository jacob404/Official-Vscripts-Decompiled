IncludeScript( "entity_script_utilities" )

// data
ResourceAmount	<- 1 // amount to award

spawnTime 			<- 0
expireTime			<- 20 // seconds
staticResource		<- false

glowBlinkDuration		<- 6				// number of seconds to blink before expiring
glowBlinkRate			<- 0.25				// how often to blink
glowBlinkNextThink		<- 0
glowBlinkColor  		<- "255 0 0"
glowDefaultColor		<- "255 255 255"
glowBlinkToggleState	<- false


self.ConnectOutput( "OnPlayerPickup", "OnPickup" )

function OnPickup()
{
	EntFire( self.GetName(), "fireuser1" )
}

function AwardResource()
{
	EmitSoundOn( "WAM.PointScored", self )
	
	g_ResourceManager.AddResources( 1 )
	
	Destruct()
}

function Precache()
{
	spawnTime = Time()
}

function Destruct()
{
	EntFire( self.GetName(), "FireUser2", 0, 0 )
	EntFire( self.GetName(), "kill", 0, 0.1 )
}

function OnPostSpawn()
{		
	if( LookupReplacementKey( "$static" ) == "1" )
	{
		staticResource = true	
	}
	
	local showHints = false

	// show training hints?
	if( "ShowTrainingHints" in SessionState )
	{
		if( SessionState.ShowTrainingHints )
			showHints = true
	}

	if( !showHints || staticResource )
	{
		// kill the hint
		EntFire( self.GetName(), "FireUser4" )
	}
}

//---------------------------------------------------------
function Think()
{		
	if( !staticResource )
	{
		ExpireCheck()
	}
}

function ExpireCheck()
{
	if( spawnTime + expireTime < Time() )
	{
		EmitSoundOn( "Plastic_Barrel.Break", self )
		Destruct()
	}
	else if( (spawnTime + expireTime - glowBlinkDuration) < Time() )
	{
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
		EntFire( self.GetName(), "color", glowDefaultColor, 0 )
	}
	else
	{
		EntFire( self.GetName(), "color", glowBlinkColor, 0 )
	}
	
	EmitSoundOn( "Strongman.puck_tick", self )
	
	glowBlinkToggleState = !glowBlinkToggleState
}