// vim: set ts=4
// Utilities for L4D2 Vscript Mutations
// Copyright (C) 2012 ProdigySim
// All rights reserved.
// =============================================================================


if("Utils" in this) return;
Utils <- {
	SIClass = {
		Smoker = 1
		Boomer = 2
		Hunter = 3
		Spitter = 4
		Jockey = 5
		Charger = 6
		Witch = 7
		Tank = 8
	}
	SIModels = [
		"", // null entry
		["models/infected/smoker.mdl"],
		["models/infected/boomer.mdl", "models/infected/boomette.mdl"],
		["models/infected/hunter.mdl"],
		["models/infected/spitter.mdl"],
		["models/infected/jockey.mdl"],
		["models/infected/charger.mdl"],
		["models/infected/witch.mdl", "models/infected/witch_bride.mdl"],
		["models/infected/hulk.mdl", "models/infected/hulk_dlc3.mdl"]
	]
	SurvivorModels = {
		coach = "models/survivors/survivor_coach.mdl"
		ellis = "models/survivors/survivor_mechanic.mdl"
		nick = "models/survivors/survivor_gambler.mdl"
		rochelle = "models/survivors/survivor_producer.mdl"
		louis = "models/survivors/survivor_manager.mdl"
		bill = "models/survivors/survivor_namvet.mdl"
		francis = "models/survivors/survivor_biker.mdl"
		zoey = "models/survivors/survivor_teenangst.mdl"
	}
	MeleeModels = [
		"models/weapons/melee/w_bat.mdl",
		"models/weapons/melee/w_chainsaw.mdl"
		"models/weapons/melee/w_cricket_bat.mdl",
		"models/weapons/melee/w_crowbar.mdl",
		"models/weapons/melee/w_didgeridoo.mdl",
		"models/weapons/melee/w_electric_guitar.mdl",
		"models/weapons/melee/w_fireaxe.mdl",
		"models/weapons/melee/w_frying_pan.mdl",
		"models/weapons/melee/w_golfclub.mdl",
		"models/weapons/melee/w_katana.mdl",
		"models/weapons/melee/w_machete.mdl",
		"models/weapons/melee/w_riotshield.mdl",
		"models/weapons/melee/w_tonfa.mdl"
	]
};
IncludeScript("globaltimers", this);

/* KeyReset
	Create a KeyReset to track the state of a key before you change its value, and
	reset it to the original value/state when you want to revert it.
	Can detect whether a key existed or not and will delete the key afterwards if it doesn't exists.
	
	e.g.
	myKeyReset = KeyReset(DirectorOptions, "JockeyLimit")
	
	then on some event...
	myKeyReset.set(0); // Set DirectorOptions.JockeyLimit to 0, storing the previous value/state
	
	and later...
	myKeyReset.unset(); // Reset DirectorOptions.JockeyLimit to whatever value it was before, or delete
	

 */

// Class that will detect the existence and old value of a key and store
// it for "identical" resetting at a later time.
// Assumes that while between Set() and Unset() calls no other entity will modify the
// value of this key.
class Utils.KeyReset
{
	constructor(owner, key)
	{
		m_owner = owner;
		m_key = key;
	}
	function set(val)
	{
		if(!m_bSet)
		{
			m_bExists = m_owner.rawin(m_key);
			if(m_bExists)
			{
				m_oldVal = m_owner.rawget(m_key);
			}
			m_bSet = true;
		}
		m_owner.rawset(m_key,val);
	}
	function unset()
	{
		if(!m_bSet) return;
		
		if(m_bExists)
		{
			m_owner.rawset(m_key,m_oldVal);
		}
		else
		{
			m_owner.rawdelete(m_key);
		}
		m_bSet = false;
	}
	m_owner = null;
	m_key = null;
	m_oldVal = null;
	m_bExists = false;
	m_bSet = false;
};


/* ZeroMobReset
	Class which handles resetting the mob timer without spawning CI.
	
	e.g.
	g_MobTimerCntl = ZeroMobReset(Director, DirectorOptions, g_FrameTimer);
	
	then later on some event
	g_MobTimerCntl.ZeroMobReset();
	

 */
// Can reset the mob spawn timer at any point without
// triggering an CI to spawn. Should not demolish any other state settings.
class Utils.ZeroMobReset extends Timers.TimerCallback
{
	// Initialize with Director, DirectorOptions, and a GlobalFrameTimer
	constructor(director, dopts, timer)
	{
		m_director = director;
		m_timer = timer;
		m_mobsizesetting = KeyReset(dopts, "MobSpawnSize");
	}
	/* ZeroMobReset()
	Resets the director's mob timer.
	Will trigger incoming horde music, but will not spawn any commons.
	 */
	function ZeroMobReset()
	{
		if(m_bResetInProgress) return;
		
		// set DirectorOptions.MobSpawnSize to 0 so the triggered
		// horde won't spawn CI
		m_mobsizesetting.set(0);
		m_director.ResetMobTimer();
		m_timer.AddTimer(1, this)
		m_bResetInProgress = true;
	}
	// Internal use only,
	// resets the mob size setting after the mob timer has been set
	function OnTimerElapsed()
	{
		m_mobsizesetting.unset();
		m_bResetInProgress = false;
	}
	m_bResetInProgress = false;
	m_director = null;
	m_timer = null;
	m_mobsizesetting = null;
	static KeyReset = Utils.KeyReset;
};

class Utils.Sphere {
	constructor(center, radius)
	{
		m_vecOrigin = center;
		m_flRadius = radius;
	}
	function GetOrigin()
	{
		return m_vecOrigin();
	}
	function GetRadius()
	{
		return m_flRadius;
	}
	// point: vector
	function ContainsPoint(point)
	{
		return (m_vecOrigin - point).Length() <= m_flRadius;
	}
	function ContainsEntity(entity)
	{
		return ContainsPoint(entity.GetOrigin());
	}
	m_vecOrigin = null;
	m_flRadius = null;
};

class Utils.MapInfo {
	function IdentifyMap(EntList)
	{
		isIntro = EntList.FindByName(null, "fade_intro") != null
			|| EntList.FindByName(null, "lcs_intro") != null;

		// also will become true in scavenge gamemode!
		hasScavengeEvent = EntList.FindByClassname(null, "point_prop_use_target") != null;

		saferoomPoints = [];

		if(isIntro)
		{
			local ent = EntList.FindByName(null, "survivorPos_intro_01");
			if(ent != null) saferoomPoints.push(ent.GetOrigin());
		}

		local ent = null;
		while((ent = EntList.FindByClassname(ent, "prop_door_rotating_checkpoint")) != null)
		{
			saferoomPoints.push(ent.GetOrigin());
		}

		if(IsMapC1M2(EntList)) mapname = "c1m2_streets";
		else mapname = "unknown";
	}
	function IsPointNearAnySaferoom(point, distance=2000.0)
	{
		// We actually check if any saferoom is near the point...
		local sphere = Sphere(point, distance);
		foreach(pt in saferoomPoints)
		{
			if(sphere.ContainsPoint(pt)) return true;
		}
		return false;
	}
	function IsEntityNearAnySaferoom(entity, distance=2000.0)
	{
		return IsPointNearAnySaferoom(entity.GetOrigin(), distance);
	}
	function IsMapC1M2(EntList)
	{
		// Identified by a entity with a given model at a given point
		local ent = EntList.FindByModel(null, "models/destruction_tanker/c1m2_cables_far.mdl");
		if(ent != null 
			&& (ent.GetOrigin() - Vector(-6856.0,-896.0,384.664)).Length() < 1.0) return true;
		return false;
	}
	isIntro = false
	isFinale = false
	hasScavengeEvent = false;
	saferoomPoints = null;
	mapname = null
	chapter = 0
	Sphere = Utils.Sphere;
};

class Utils.VectorClone {
	constructor(vec)
	{
		x=vec.x;
		y=vec.y;
		z=vec.z;
	}
	function ToVector()
	{
		return Vector(x,y,z);
	}
	x=0.0
	y=0.0
	z=0.0
};

class Utils.ItemInfo {
	constructor(ent)
	{
		m_vecOrigin = VectorClone(ent.GetOrigin());
		//m_vecForward = ent.GetForwardVector();
	}
	m_vecOrigin = null;
	//m_vecForward = null;
	static VectorClone = Utils.VectorClone;
};

Utils.KillEntity <- function (ent)
{
	DoEntFire("!self", "kill", "", 0, null, ent);
}

Utils.ArrayToTable <- function (arr)
{
	local tab = {};
	foreach(str in arr) tab[str] <- 0;
	return tab;
}

Utils.ArrayRemoveByValue <- function (arr, value)
{
	foreach(id,val in arr)
	{
		if(val == value)
		{
			arr.remove(id);
			break;
		}
	}
}

// return index on found
// return -1 on not found
Utils.ArraySearchByValue <- function (arr, value)
{
	foreach(id,val in arr)
	{
		if(val == value)
		{
			return id;
			break;
		}
	}
	return -1;
}

Utils.IsEntityInMoveHeirarchy <- function (moveChildEnt, moveParentCandidate)
{
	local curEnt = moveChildEnt;
	while(curEnt != null)
	{
		curEnt = curEnt.GetMoveParent();
		if(curEnt == moveParentCandidate) return true;
	}
	return false;
}

// TODO move/refactor...
Utils.GetCurrentRound <- function () 
{ 
	return ::CompLite.Globals.GetCurrentRound();
}