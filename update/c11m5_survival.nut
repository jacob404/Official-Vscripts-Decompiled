Msg("Initiating c11m5_survival Script\n");

DirectorOptions <-
{
	ZombieSpawnRange = 4000
	PreferredMobDirection = SPAWN_LARGE_VOLUME
	PreferredSpecialDirection = SPAWN_LARGE_VOLUME
	
	// This prevents infected that spawn at a larger radius from despawning.
	ZombieDiscardRange = 12000
}