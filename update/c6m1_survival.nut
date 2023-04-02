Msg("Initiating c6m1_survival Script\n");

DirectorOptions <-
{
	ZombieSpawnInFog = true
	ZombieSpawnRange = 3000
	ZombieDiscardRange = 5500
	DisallowThreatType = ZOMBIE_WITCH
	
	function AllowFallenSurvivorItem( classname )
	{
		if ( classname == "weapon_first_aid_kit" )
			return false;
		
		return true;
	}
}