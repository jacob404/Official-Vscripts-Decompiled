IncludeScript( "entity_script_utilities" )

// debug
searchlightDBG <- false

function debugPrint( string )
{
	if( searchlightDBG )
		printl( string )
}

// generator text spew functions
// until we get a HUD display for time we just spew it to the console
// spew turns on for first time when gas is poured into the generator
generatorSpewEnabled <- false

function generatorPrint( string )
{
	if( generatorSpewEnabled )
		printl( string )
}

function EnableGeneratorSpew()
{
	generatorSpewEnabled = true
}

function DisableGeneratorSpew()
{
	generatorSpewEnabled = false
}

// defines

// name of spinning spotlight entity
ROTATOR <- LookupInstancedName( "generator_1_spotlight_rotator" )

// table of spotlight entity names
SPOTLIGHT_TABLE <- 
[ 
	LookupInstancedName( "generator_1_spotlight_1" ),
	LookupInstancedName( "generator_1_spotlight_2" ),
	LookupInstancedName( "generator_1_spotlight_3" ),
	LookupInstancedName( "generator_1_spotlight_4" ),
]

MAX_FUEL 				<- 6
FUEL_PER_CAN			<- 0.20
FUEL_VARIATION          <- 0.02  // we'll actually add/sub -this->+this 2x to get the real fuel amount
FUEL_BURN_RATE			<- 0.001 // burn rate per think
LOW_FUEL_VALUE			<- 0.26

// data
currentFuel				<- 0
lastFuelLevelDisplayed 	<- 0
numSpotlightsOn			<- 0
generatorOn				<- false
fuelLow					<- false

// last generator think time
lastThink 				<- 0.1

// ----------------------------------------------------------------------------
// Spotlight Generator Think
// ----------------------------------------------------------------------------
function GeneratorThink()
{
	local dt = Time() - lastThink
	lastThink = Time()
	
	// increment run time if we have fuel
	if( currentFuel > 0 )
	{
		if( lastFuelLevelDisplayed == 0 )
			TurnGeneratorOn()
		
		// notify the rotator that we're running low on fuel
		if( ( currentFuel < LOW_FUEL_VALUE ) && !fuelLow )
		{
			EntFire( ROTATOR, "FireUser3", 0, 0 )
			fuelLow = true
		}
		else if( ( currentFuel > LOW_FUEL_VALUE ) && fuelLow )
		{
			EntFire( ROTATOR, "FireUser4", 0, 0 )
			fuelLow = false
		}
		
		currentFuel -= FUEL_BURN_RATE
		
		// clamp
		if( currentFuel <= 0 )
		{
			TurnGeneratorOff()
			currentFuel = 0
		}
		
		SynchronizeSpotlights()
	}
}

// ----------------------------------------------------------------------------
function SynchronizeSpotlights()
{
	// if the tank is overfueled don't update the lights
	if( currentFuel > ( FUEL_PER_CAN * 4 ) ) // 4 = number of spotlights
		return
	
	local lastLightOn = ( lastFuelLevelDisplayed / FUEL_PER_CAN )
	local currentLightsOn = ( currentFuel / FUEL_PER_CAN )
	
	lastLightOn = ceil( lastLightOn )
	currentLightsOn = ceil( currentLightsOn )

	debugPrint(" ========================= synch lastLightOn: " + lastLightOn + " currentLightsOn: " + currentLightsOn )
	
	// clamp lights on to max number of lights
	if( currentLightsOn > SPOTLIGHT_TABLE.len() )
	{
		currentLightsOn = SPOTLIGHT_TABLE.len()
	}
	
	if( currentLightsOn > lastLightOn )
	{
		for( local i=lastLightOn; i<currentLightsOn; i++ )
		{
			EnableSpotlight( i )
		}
	}
	else if( currentLightsOn < lastLightOn )
	{
		// subtract one from adjust the count for index based array
		for( local i=lastLightOn-1; i >= currentLightsOn; i-- )
		{
			DisableSpotlight( i )
		}
	}
	lastFuelLevelDisplayed = currentFuel
}

// ----------------------------------------------------------------------------
function EnableSpotlight( light )
{
	// clamp
	if( light >= SPOTLIGHT_TABLE.len() )
	{
		light = SPOTLIGHT_TABLE.len() - 1
	}
	
	if( light < 0 )
	{
		light = 0
	}
	
	debugPrint("+++ Enabling spotlight: " + light )
	EntFire( SPOTLIGHT_TABLE[light], "LightOn", 0, 0 )
}

// ----------------------------------------------------------------------------
function DisableSpotlight( light )
{
	// clamp
	if( light >= SPOTLIGHT_TABLE.len() )
	{
		light = SPOTLIGHT_TABLE.len() - 1
	}
	
	if( light < 0 )
	{
		light = 0
	}
	
	debugPrint("+++ Disabling spotlight: " + light )
	EntFire( SPOTLIGHT_TABLE[light], "LightOff", 0, 0 )
}

// ----------------------------------------------------------------------------
function TurnGeneratorOn()
{
	debugPrint("+++ Turning on Generator!")

	// start the generator spotlights spinning
	EntFire( ROTATOR, "start", 0, 0 )
	generatorOn = true
	EntFire( ROTATOR, "FireUser1", 0, 0 )

	g_MapScript.FireEvent( "OnGeneratorStart" )
}

// ----------------------------------------------------------------------------
function TurnGeneratorOff()
{	
	// shut down the generator
	debugPrint("---- stopping generator.")
	EntFire( ROTATOR, "stop", 0, 0 )
	EntFire( ROTATOR, "FireUser2", 0, 0 )
	
	generatorOn = false
	numSpotlightsOn = false
	fuelLow = false // there is zero fuel 

	g_ModeScript.FireEvent( "OnGeneratorStop" )
}

function RandRangeF(low,hi)
{
	return low + ((hi-low)*rand()/(RAND_MAX-1))
}

// ----------------------------------------------------------------------------
function AddFuel()
{
	local newFuel = currentFuel + FUEL_PER_CAN + RandRangeF(-FUEL_VARIATION,FUEL_VARIATION) + RandRangeF(-FUEL_VARIATION,FUEL_VARIATION)

	debugPrint("-- adding fuel. current fuel: " + currentFuel + " new fuel: " + newFuel )
	currentFuel = newFuel
	
	// clamp
	if( currentFuel > MAX_FUEL )
		currentFuel = MAX_FUEL	
}
