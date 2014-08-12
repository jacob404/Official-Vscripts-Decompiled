Msg("Initiating Follow Van\n");

DirectorOptions <-
{
	// This turns off tanks and witches.
	ProhibitBosses = true
	
	//LockTempo = true
	MobSpawnMinTime = 1
	MobSpawnMaxTime = 1
	MobMinSize = 10
	MobMaxSize = 10
	MobMaxPending = 10
	SustainPeakMinTime = 5
	SustainPeakMaxTime = 10
	IntensityRelaxThreshold = 0.99
	RelaxMinInterval = 5
	RelaxMaxInterval = 15
	RelaxMaxFlowTravel = 0
	SpecialRespawnInterval = 5.0
	PreferredMobDirection = SPAWN_ANYWHERE
	ZombieSpawnRange = 1000
}

Director.ResetMobTimer()
