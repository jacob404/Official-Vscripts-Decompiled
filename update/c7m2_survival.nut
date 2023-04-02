Msg("Initiating c7m2_survival Script\n");

BargeCommonLimit <- 25	// use a lower common limit to combat infected related perf issues

if ( Director.IsPlayingOnConsole() )
{
	BargeCommonLimit <- 20
}

DirectorOptions <-
{
	CommonLimit = BargeCommonLimit
	
	// This prevents infected that spawn at a larger radius from despawning.
	ZombieDiscardRange = 12000
}