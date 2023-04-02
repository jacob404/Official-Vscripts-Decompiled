

Msg("----------------------SCAVENGE SCRIPT------------------\n")
//-----------------------------------------------------

DirectorOptions <-
{
	PreferredMobDirection = SPAWN_LARGE_VOLUME
	PreferredSpecialDirection = SPAWN_LARGE_VOLUME
       
	ShouldConstrainLargeVolumeSpawn = false
    
	MobSpawnMinTime = 45 
	MobSpawnMaxTime = 90
    
	CommonLimit = 15
    
	ZombieSpawnRange = 3000
} 

NavMesh.UnblockRescueVehicleNav()
//Director.ResetMobTimer()
