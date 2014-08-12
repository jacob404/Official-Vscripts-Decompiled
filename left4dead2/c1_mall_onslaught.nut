Msg("Initiating Onslaught\n");

DirectorOptions <-
{
	// This turns off tanks and witches.
	ProhibitBosses = true

	MobSpawnMinTime = 1
	MobSpawnMaxTime = 4
	MobMinSize = 15
	MobMaxSize = 20
	MobMaxPending = 30
	SustainPeakMinTime = 10
	SustainPeakMaxTime = 15
	IntensityRelaxThreshold = 0.99
	RelaxMinInterval = 3
	RelaxMaxInterval = 5
	RelaxMaxFlowTravel = 200
	BoomerLimit = 0
	SmokerLimit = 3
	HunterLimit = 1
	ChargerLimit = 2
	SpecialRespawnInterval = 5.0
	PreferredMobDirection = SPAWN_IN_FRONT_OF_SURVIVORS
	//ZombieSpawnRange = 1500
}

Director.PlayMegaMobWarningSounds()
Director.ResetMobTimer()

