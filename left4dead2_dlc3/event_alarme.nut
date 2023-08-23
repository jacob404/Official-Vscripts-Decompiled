Msg("Initiating Onslaught\n");

DirectorOptions <-
{
// This turns off tanks and witches.
ProhibitBosses = true

//LockTempo = true
MobSpawnMinTime = 3
MobSpawnMaxTime = 6
MobMinSize = 11
MobMaxSize = 17
MobMaxPending = 30
SustainPeakMinTime = 4
SustainPeakMaxTime = 10
IntensityRelaxThreshold = 0.99
RelaxMinInterval = 1
RelaxMaxInterval = 5
RelaxMaxFlowTravel = 50
SpecialRespawnInterval = 1.0
PreferredMobDirection = SPAWN_IN_FRONT_OF_SURVIVORS
ZombieSpawnRange = 2000
}

Director.ResetMobTimer()