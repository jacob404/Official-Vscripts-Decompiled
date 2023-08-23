//-----------------------------------------------------
Msg("Activating Mutation 1\n");


DirectorOptions <-
{
	ActiveChallenge = 1

	cm_NoSurvivorBots = 1
	cm_CommonLimit = 0
	cm_DominatorLimit = 1
	cm_MaxSpecials = 2
	cm_SpecialRespawnInterval = 60
	cm_AutoReviveFromSpecialIncap = 1
	cm_AllowPillConversion = 0

	BoomerLimit = 0
	MobMaxPending = 0
	SurvivorMaxIncapacitatedCount = 1
	SpecialInitialSpawnDelayMin = 5
	SpecialInitialSpawnDelayMax = 30
	TankHitDamageModifierCoop = 0.5
	
	// convert items that aren't useful
	weaponsToConvert =
	{
		weapon_pipe_bomb =	"weapon_molotov_spawn"
		weapon_vomitjar =	"weapon_molotov_spawn"
		weapon_defibrillator =	"weapon_first_aid_kit_spawn"

		weapon_smg =		"weapon_rifle_spawn"
		weapon_pumpshotgun =	"weapon_autoshotgun_spawn"
		weapon_smg_silenced =	"weapon_rifle_desert_spawn"
		weapon_shotgun_chrome =	"weapon_shotgun_spas_spawn"
	}

	function ConvertWeaponSpawn( classname )
	{
		if ( classname in weaponsToConvert )
		{
			return weaponsToConvert[classname];
		}
		return 0;
	}	
}

removed_common_spawns <- false;
function Update()
{
	if( !removed_common_spawns )
    {
		EntFire( "intro_zombie_spawn", "kill" );
		EntFire( "zspawn_lobby_fall_1", "kill" );
		EntFire( "zspawn_lobby_fall_2", "kill" );
		EntFire( "zspawn_lobby_fall_3", "kill" );
		EntFire( "zspawn_lobby_fall_4", "kill" );
		EntFire( "zspawn_lobby_fall_5", "kill" );
		EntFire( "zspawn_fall_1", "kill" );
		EntFire( "zspawn_fall_2", "kill" );
		EntFire( "zombie_outro", "kill" );
		EntFire( "escape_zombie", "kill" );
		EntFire( "zspawn_zombie_safe", "kill" );
		EntFire( "zspawn_zombie_safe2", "kill" );
		EntFire( "spawn_zombie_van", "kill" );
		EntFire( "spawn_zombie_alarm", "kill" );
		EntFire( "spawn_zombie_alarm2", "kill" );
		EntFire( "zombie_spawn1", "kill" );
		EntFire( "spawn_zombie_run", "kill" );
		EntFire( "spawn_zombie_end", "kill" );
		EntFire( "infected_spawner", "kill" );
		EntFire( "infected_spawner2", "kill" );
		EntFire( "spawn_zombie_location1", "kill" );
		EntFire( "spawn_zombie_location2", "kill" );
		EntFire( "spawn_zombie_location3", "kill" );
		EntFire( "spawn_zombie_location4", "kill" );
		EntFire( "spawn_zombie_location5", "kill" );
		EntFire( "spawn_zombie_location6", "kill" );
		removed_common_spawns = true;
    }
	if( Director.GetCommonInfectedCount() >= 1 )
	{
		z <- null;
		while( ( z = Entities.FindByClassname( z, "infected" ) ) != null )
		{
			DoEntFire( "!self", "kill", "", 0, null, z );
		}
	}
}

