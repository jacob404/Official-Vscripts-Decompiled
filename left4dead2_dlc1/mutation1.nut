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
		weapon_pipe_bomb = 	"weapon_molotov_spawn"
		weapon_vomitjar = 	"weapon_molotov_spawn"
		weapon_defibrillator =	"weapon_first_aid_kit_spawn"

		weapon_smg = 		"weapon_rifle_spawn"
		weapon_pumpshotgun = 	"weapon_autoshotgun_spawn"
		weapon_smg_silenced =	"weapon_rifle_desert_spawn"
		weapon_shotgun_chrome = "weapon_shotgun_spas_spawn"
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

