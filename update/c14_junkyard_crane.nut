Msg("Beginning crane panic event.\n")

DirectorOptions <-
{
	ProhibitBosses = true
	CommonLimit = 16

	MobSpawnMinTime = 3
	MobSpawnMaxTime = 3
	MobMinSize = 15
	MobMaxSize = 20
	MobMaxPending = 25
	SustainPeakMinTime = 10
	SustainPeakMaxTime = 15
	IntensityRelaxThreshold = 0.99
	RelaxMinInterval = 3
	RelaxMaxInterval = 5
	RelaxMaxFlowTravel = 200
	BoomerLimit = 0
	SmokerLimit = 1
	HunterLimit = 1
	ChargerLimit = 1
	SpecialRespawnInterval = 5.0
	PreferredMobDirection = SPAWN_IN_FRONT_OF_SURVIVORS
}

if ( Director.GetGameModeBase() == "versus" )
{
    DirectorOptions.MobSpawnMinTime = 5;
    DirectorOptions.MobSpawnMaxTime = 5;
}