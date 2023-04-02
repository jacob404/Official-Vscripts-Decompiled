

Msg("----------------------SCAVENGE SCRIPT------------------\n")
//-----------------------------------------------------

DirectorOptions <-
{
	PreferredMobDirection = SPAWN_LARGE_VOLUME
	PreferredSpecialDirection = SPAWN_LARGE_VOLUME
       
	ShouldConstrainLargeVolumeSpawn = false
    
	MobSpawnMinTime = 20 
	MobSpawnMaxTime = 40

	MobMinSize = 10
	MobMaxSize = 20
    
	CommonLimit = 30
    
	ZombieSpawnRange = 3000
} 

NavMesh.UnblockRescueVehicleNav()
//Director.ResetMobTimer()
