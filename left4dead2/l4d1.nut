//============ Copyright (c) Valve Corporation, All rights reserved. ==========
//
//
//=============================================================================

Msg("Activating Mutation L4D1\n");


DirectorOptions <-
{
	ActiveChallenge = 1

	SpitterLimit = 0
	JockeyLimit = 0
	ChargerLimit = 0

	weaponsToConvert =
	{
		weapon_shotgun_spas				= "weapon_autoshotgun_spawn"
		weapon_defibrillator			= "weapon_first_aid_kit_spawn"
		weapon_ammo_pack				= "weapon_first_aid_kit_spawn"
		weapon_sniper_awp				= "weapon_hunting_rifle_spawn"
		weapon_sniper_military			= "weapon_hunting_rifle_spawn"
		weapon_sniper_scout				= "weapon_hunting_rifle_spawn"
		weapon_vomitjar					= "weapon_molotov_spawn"
		weapon_adrenaline				= "weapon_pain_pills_spawn"
		weapon_pistol_magnum			= "weapon_pistol_spawn"
		weapon_shotgun_chrome			= "weapon_pumpshotgun_spawn"
		weapon_rifle_ak47				= "weapon_rifle_spawn"
		weapon_rifle_desert				= "weapon_rifle_spawn"
		weapon_rifle_m60				= "weapon_rifle_spawn"
		weapon_rifle_sg552				= "weapon_rifle_spawn"
		weapon_smg_mp5					= "weapon_smg_spawn"
		weapon_smg_silenced				= "weapon_smg_spawn"
	}

	function ConvertWeaponSpawn( classname )
	{
		if ( classname in weaponsToConvert )
		{
			return weaponsToConvert[classname];
		}
		return 0;
	}	

	weaponsToRemove =
	{
		weapon_grenade_launcher = 0
		weapon_chainsaw = 0
		weapon_melee = 0
		weapon_upgradepack_explosive = 0
		weapon_upgradepack_incendiary = 0
		upgrade_item = 0
	}

	function AllowWeaponSpawn( classname )
	{
		if ( classname in weaponsToRemove )
		{
			return false;
		}
		return true;
	}	

}
