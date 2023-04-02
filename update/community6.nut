// vim: set ts=4
// CompLite.nut (Confogl Mutation)
// Copyright (C) 2012 ProdigySim
// All rights reserved.
// =============================================================================

IncludeScript("globals", this);

CompLite = InitializeCompLite();

// Don't need to do anything else if we're not first load
if(CompLite.Globals.GetCurrentRound() > 0)
{
	Msg("CompLite Starting Round "+CompLite.Globals.GetCurrentRound()+" on ");
	local mi = CompLite.Globals.MapInfo;
	if(mi.isIntro) Msg("an intro map.\n");
	else Msg("a non-intro map.\n");

	Msg("Found "+mi.saferoomPoints.len()+" saferoom points.\n");
	Msg("Map has a scavenge event? " + mi.hasScavengeEvent + "\n");
	Msg("MapName: "+mi.mapname+"\n");

	return;
}

Msg("Activating Mutation CompLite v3.6\n");

DirectorOptions.ActiveChallenge <- 1
DirectorOptions.cm_ProhibitBosses <- 0
DirectorOptions.cm_AllowPillConversion <- 0

// Name shortening references
local g_Timer = CompLite.Globals.Timer;
local g_FrameTimer = CompLite.Globals.FrameTimer;
local g_MapInfo = CompLite.Globals.MapInfo;
local g_GSC = CompLite.Globals.GSC;
local g_GSM = CompLite.Globals.GSM;
local g_MobResetti = CompLite.Globals.MobResetti;
local Modules = CompLite.Modules;

// Uncomment to add a debug event listener
//g_GSC.AddListener(Modules.MsgGSL());

g_GSC.AddListener(Modules.SpitterControl(Director, DirectorOptions, Entities));
g_GSC.AddListener(Modules.MobControl(g_MobResetti));


// Give out hunting rifles on non-intro maps.
// But limit them to 1 of each.
g_GSC.AddListener(Modules.HRControl(Entities, CompLite.Globals, Director));


g_GSC.AddListener(
	Modules.BasicItemSystems(
		// AllowWeaponSpawn Limits
		// 0: Always remove
		// >0: Keep the first n instances, delete others
		// <-1: Delete the first n instances, keep others.
		{
			weapon_defibrillator = 0
			weapon_grenade_launcher = 0
			weapon_upgradepack_incendiary = 0
			weapon_upgradepack_explosive = 0
			weapon_chainsaw = 0
			//weapon_molotov = 1
			//weapon_pipe_bomb = 2
			//weapon_vomitjar = 1
			weapon_propanetank = 0
			weapon_oxygentank = 0
			weapon_rifle_m60 = 0
			//weapon_first_aid_kit = -5
			upgrade_item = 0
		},
		// Conversion Rules
		{
		weapon_autoshotgun	  = "weapon_pumpshotgun_spawn"
		weapon_shotgun_spas	 = "weapon_shotgun_chrome_spawn"
		weapon_rifle			= "weapon_smg_spawn"
		weapon_rifle_desert	 = "weapon_smg_spawn"
		weapon_rifle_sg552	  = "weapon_smg_mp5_spawn"
		weapon_rifle_ak47	   = "weapon_smg_silenced_spawn"
		weapon_hunting_rifle	= "weapon_smg_silenced_spawn"
		weapon_sniper_military  = "weapon_shotgun_chrome_spawn"
		weapon_sniper_awp	   = "weapon_shotgun_chrome_spawn"
		weapon_sniper_scout	 = "weapon_pumpshotgun_spawn"
		weapon_first_aid_kit	= "weapon_pain_pills_spawn"
		weapon_molotov = "weapon_molotov_spawn"
		weapon_pipe_bomb = "weapon_pipe_bomb_spawn"
		weapon_vomitjar = "weapon_vomitjar_spawn"
		},
		// Default item list
		[
			"weapon_pain_pills",
			"weapon_pistol",
			"weapon_hunting_rifle"
		]
	)
);

// Enforce various item spawns to be single pickup.
g_GSC.AddListener(
	Modules.EntKVEnforcer(Entities,
		// classnames
		[
			"weapon_adrenaline_spawn",
			"weapon_pain_pills_spawn",
			"weapon_melee_spawn",
			"weapon_molotov_spawn",
			"weapon_vomitjar_spawn",
			"weapon_pipebomb_spawn"
		],
		// models
		[],
		// key to enforce
		"count",
		// value to set it to
		1
	)
);

// Entity tracking/removal/limiting
g_GSC.AddListener(
	Modules.ItemControl(Entities, 
	// Limit to value by classname
		{
			weapon_adrenaline_spawn = 1
			weapon_pain_pills_spawn = 4
			witch = 1
			func_playerinfected_clip = 0
			weapon_molotov_spawn = 1
			weapon_pipe_bomb_spawn = 1
			weapon_vomitjar_spawn = 1
		},
	// Limit to value by model name
		{
			["models/props_junk/propanecanister001a.mdl"] = 0,
			["models/props_equipment/oxygentank01.mdl"] = 0,
			["models/props_junk/explosive_box001.mdl"] = 1
		},
	// Remove these items from all saferooms
		[
			"weapon_adrenaline_spawn",
			"weapon_pain_pills_spawn",
			//"weapon_melee_spawn",
			"weapon_molotov_spawn",
			"weapon_pipe_bomb_spawn",
			"weapon_vomitjar_spawn"
		],
		g_MapInfo
	)
);

// Limit melee weapons to 4
g_GSC.AddListener(Modules.MeleeWeaponControl(Entities, 4));

// Remove all gascans on non-scavenge maps
g_GSC.AddListener(Modules.GasCanControl(Entities, g_MapInfo));


Msg("GSC/M/L Script run.\n");
