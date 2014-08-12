//-----------------------------------------------------
//
// This script encourages the director to generate the
// mega-mobs from positions in front of the survivors.
//
//-----------------------------------------------------

DirectorOptions <-
{
	//-----------------------------------------------------
	// This is the variable that you have to set in order
	// to influence the direction of mob spawns.
	//-----------------------------------------------------
	PreferredMobDirection = SPAWN_IN_FRONT_OF_SURVIVORS

	// Turn always wanderer on
	AlwaysAllowWanderers = true

	// Let dudes come out of the fog
	ZombieSpawnInFog = true

	// Set the number of infected that cannot be absorbed
	NumReservedWanderers = 10

	// More generous range for spawning infected makes it more
	// likely that we'll actually get our mob from the front
	ZombieSpawnRange = 2700
}

