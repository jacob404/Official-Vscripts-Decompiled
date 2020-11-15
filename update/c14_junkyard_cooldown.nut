Msg("Initiating Crescendo Cooldown\n");

DirectorOptions <-
{
	ProhibitBosses = true
	AlwaysAllowWanderers = true
	MobSpawnMinTime = 60
	MobSpawnMaxTime = 90
	MobMinSize = 10
	MobMaxSize = 15
	MobMaxPending = 10
	SustainPeakMinTime = 10
	SustainPeakMaxTime = 15
	IntensityRelaxThreshold = 0.9
	RelaxMinInterval = 20
	RelaxMaxInterval = 35
	RelaxMaxFlowTravel = 500	
	BoomerLimit = 1
	SpitterLimit = 1
	SmokerLimit = 2
	HunterLimit = 2
	ChargerLimit = 1
	SpecialRespawnInterval = 20.0
	ZombieSpawnRange = 2000
	NumReservedWanderers = 15
}

Director.ResetMobTimer()