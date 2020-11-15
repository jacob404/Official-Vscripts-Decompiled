Msg("Initiating C4 Director Storm settings\n");

DirectorOptions <-
{
	// This turns off tanks and witches.
	//ProhibitBosses = true

	ZombieSpawnInFog = 1
	ZombieSpawnRange = 3000
	MobRechargeRate = 0.001
	
	FallenSurvivorPotentialQuantity = 6
	FallenSurvivorSpawnChance       = 0.75
	
	GasCansOnBacks = true
}


if ( Director.GetGameModeBase() == "versus" )
{
    DirectorOptions.ProhibitBosses <- true;
}
