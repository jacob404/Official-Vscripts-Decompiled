Msg("Beginning Lighthouse Scavenge.\n")

DirectorOptions <-
{
	CommonLimit = 15
	MobSpawnMinTime = 8
	MobSpawnMaxTime = 12
	MobSpawnSize = 7
	MobMaxPending = 12
	IntensityRelaxThreshold = 0.99
	RelaxMinInterval = 1
	RelaxMaxInterval = 1
	RelaxMaxFlowTravel = 1
	SpecialRespawnInterval = 30
	LockTempo = true
	PreferredMobDirection = SPAWN_ANYWHERE
	PanicForever = true
}

if ( Director.IsSinglePlayerGame() )
{
	DirectorOptions.CommonLimit = 10;
	DirectorOptions.MobSpawnSize = 5;
	DirectorOptions.MobMaxPending = 8;
}

if ( Director.GetGameModeBase() == "versus" )
	DirectorOptions.MobSpawnSize = 4;

Director.ResetMobTimer();