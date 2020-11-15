// vim: set ts=4
// CompLite Mutation Modules
// Copyright (C) 2012 ProdigySim
// All rights reserved.
// =============================================================================

if("Modules" in this) return;
Modules <- {};
IncludeScript("gamestate_model", this);
IncludeScript("utils", this);


class Modules.MsgGSL extends GameState.GameStateListener
{
	function OnRoundStart(roundNumber) { Msg("MsgGSL: OnRoundStart("+roundNumber+")\n"); }
	function OnSafeAreaOpened() { Msg("MsgGSL: OnSafeAreaOpened()\n"); }
	function OnTankEntersPlay() { Msg("MsgGSL: OnTankEntersPlay()\n"); }
	function OnTankLeavesPlay() { Msg("MsgGSL: OnTankLeavesPlay()\n"); }
	function OnSpawnPCZ(id) { Msg("MsgGSL: OnSpawnPCZ("+id+")\n"); }
	function OnSpawnedPCZ(id) { Msg("MsgGSL: OnSpawnedPCZ("+id+")\n"); }
	function OnGetDefaultItem(idx)
	{
		if(idx == 0) 
		{
			Msg("MsgGSL: OnGetDefaultItem(0) #"+m_defaultItemCnt+"\n");
			m_defaultItemCnt++;
		}
	}
	// Too much spam for these
	/*
	function OnAllowWeaponSpawn(classname) {}
	function OnConvertWeaponSpawn(classname) {}
	*/
	m_defaultItemCnt = 0;
};

class Modules.SpitterControl extends GameState.GameStateListener
{
	constructor(director, director_opts, entlist)
	{
		m_pDirector = director;
		m_pSpitterLimit = KeyReset(director_opts, "SpitterLimit");
		m_pEntities = entlist;
		// Initialize to default order...
		SpawnLastUsed = [1, 2, 3, 5, 6];
	}
	function OnTankEntersPlay()
	{
		m_pSpitterLimit.set(0);
	}
	function OnTankLeavesPlay()
	{
		m_pSpitterLimit.unset();
	}
	// Check if there is an instance of this SI on the map
	function IsGivenSIClassSpawned(id)
	{
		foreach(mdl in SIModels[id])
		{
			if(m_pEntities.FindByModel(null, mdl) != null)
			{
				return true;
			}
		}
		return false;
	}
	function OnSpawnPCZ(id)
	{
		// If a spitter is going to be spawned during tank,
		if(id == SIClass.Spitter && m_pDirector.IsTankInPlay())
		{
			foreach(si in SpawnLastUsed)
			{
				// Note: Player keeps SI model until they receive a new spawn
				// (while dead, they have the model of their last SI class)
				if(!IsGivenSIClassSpawned(si)) return si;
			}
			// default to hunter if we really can't pick another class...
			return SIClass.Hunter;
		}
		// Msg("Spawning SI Class "+newClass+".\n");
		return id;
	}
	function OnSpawnedPCZ(id)
	{
		// Mark that this SI to be spawned is most recently spawned now.
		if(id != SIClass.Spitter && id <= SIClass.Charger && id >= SIClass.Smoker)
		{
			// Low index = least recent
			// High index = most recent
			// Remove the other instance of this class in our array
			ArrayRemoveByValue(SpawnLastUsed, id);
			SpawnLastUsed.push(id);
		}
	}
	// List of last spawned time for each SI class
	SpawnLastUsed = null;
	// reference to director options
	m_pSpitterLimit = null;
	m_pDirector = null;
	m_pEntities = null;
	static KeyReset = Utils.KeyReset;
	static SIClass = Utils.SIClass;
	static SIModels = Utils.SIModels;
	static ArrayRemoveByValue = Utils.ArrayRemoveByValue;
};


class Modules.MobControl extends GameState.GameStateListener
{
	constructor(mobresetti)
	{
		//m_dopts = director_opts;
		m_resetti = mobresetti;
	}
	function OnSafeAreaOpened() 
	{
		m_resetti.ZeroMobReset();
	}
	// These functions created major problems....
	/*
	function OnTankEntersPlay()
	{
		m_oldMinTime = m_dopts.MobSpawnMinTime;
		m_oldMaxTime = m_dopts.MobSpawnMaxTime;

		m_dopts.MobSpawnMinTime = 99999;
		m_dopts.MobSpawnMaxTime = 99999;

		m_resetti.ZeroMobReset();
	}
	function OnTankLeavesPlay()
	{
		m_dopts.MobSpawnMinTime = m_oldMinTime;
		m_dopts.MobSpawnMaxTime = m_oldMaxTime;

		m_resetti.ZeroMobReset();
	} 
	m_oldMinTime = 0;
	m_oldMaxTime = 0; 
	m_dopts = null; */
	m_resetti = null;
};

class Modules.BasicItemSystems extends GameState.GameStateListener
{
	constructor(removalTable, convertTable, defaultItemList)
	{
		m_removalTable = removalTable;
		m_convertTable = convertTable;
		m_defaultItemList = defaultItemList;
	}
	function OnAllowWeaponSpawn(classname)
	{
		if ( classname in m_removalTable )
		{
			if(m_removalTable[classname] > 0)
			{
				//Msg("Found a "+classname+" to keep, "+m_removalTable[classname]+" remain.\n");
				m_removalTable[classname]--
			}
			else if (m_removalTable[classname] < -1)
			{
				//Msg("Killing just one "+classname+"\n");
				m_removalTable[classname]++
				return false;
			}
			else if (m_removalTable[classname] == 0)
			{
				//Msg("Removed "+classname+"\n")
				return false;
			}
		}
		return true;
	}
	function OnConvertWeaponSpawn(classname)
	{
		if ( classname in m_convertTable )
		{
			//Msg("Converting"+classname+" to "+convertTable[classname]+"\n")
			return m_convertTable[classname];
		}
		return 0;
	}
	function OnGetDefaultItem(idx)
	{
		if ( idx < m_defaultItemList.len())
		{
			return m_defaultItemList[idx];
		}
		return 0;
	}
	m_removalTable = null;
	m_convertTable = null;
	m_defaultItemList = null;
};

class Modules.EntKVEnforcer extends GameState.GameStateListener
{
	constructor(EntList, classes, models, key, value)
	{
		m_pEntities = EntList;
		m_classes = classes;
		m_models = models;
		m_key = key;
		switch(typeof value)
		{
			case "bool":
				m_value = value.tointeger();
				m_setFunc = "__KeyValueFromInt";
				break;
			case "float":
				m_value = value.tointeger();
				m_setFunc = "__KeyValueFromInt";
				break;
			case "integer":
				m_value = value;
				m_setFunc = "__KeyValueFromInt";
				break;
			case "string":
				m_value = value;
				m_setFunc = "__KeyValueFromString";
				break;
			case "instance":
				if(value.getclass() == ::Vector)
				{
					m_value = value;
					m_setFunc = "__KeyValueFromVector";
					break;
				}
			default:
				m_value = null;
				m_setFunc = null;
				// Unsupported type!!!
				throw "Unsupported type "+(typeof value)+" used with EntKVEnforcer!";
		}
	}
	function OnRoundStart(roundNumber)
	{
		local ent = null;

		while((ent = m_pEntities.Next(ent)) != null)
		{
			if(ent.GetClassname() in m_classes)
			{
				ent[m_setFuncName].call(ent, m_key, m_value);
			}
		}

		foreach(mdl in m_models)
		{
			ent = null;
			while((ent = m_pEntities.FindByModel(mdl)) != null)
			{
				ent[m_setFuncName].call(ent, m_key, m_value);
			}
		}
	}
	m_pEntities = null;
	m_classes = null;
	m_models = null;
	m_key = null;
	m_value = null;
	m_setFunc = null;
};

class Modules.ItemControl extends GameState.GameStateListener
{
	constructor(entlist, removalTable, modelRemovalTable, saferoomRemoveList, mapinfo)
	{
		m_entlist = entlist;
		m_removalTable = removalTable;
		m_modelRemovalTable = modelRemovalTable;
		m_saferoomRemoveList = ArrayToTable(saferoomRemoveList);
		m_pMapInfo = mapinfo;
	}
	function OnFirstRound()
	{
		local ent = m_entlist.First();
		local classname = "";
		local tItemEnts = {};
		local saferoomEnts = [];

		// Create an empty array for each item in our list.
		foreach(key,val in m_removalTable)
		{
			tItemEnts[key] <- [];
		}

		while(ent != null)
		{
			classname = ent.GetClassname()
			if(classname in m_saferoomRemoveList && m_pMapInfo.IsEntityNearAnySaferoom(ent, 1600.0))
			{
				// Make a list of items which are in saferooms that need to be removed
				// and don't track these entities for other removal.
				saferoomEnts.push(ent.weakref());
			}
			else if(classname in m_removalTable)
			{
				tItemEnts[classname].push(ent.weakref());
			}
			ent=m_entlist.Next(ent);
		}

		local tModelEnts = {};

		foreach(mdl,limit in m_modelRemovalTable)
		{
			local thisMdlEnts = tModelEnts[mdl] <- [];
			ent = null;
			while((ent = m_entlist.FindByModel(ent, mdl)) != null)
			{
				// Only use this entity if it's not one of the saferoom entities we're going to remove.
				thisMdlEnts.push(ent.weakref());
			}
		}

		// Remove all targeted saferoom items before doing roundstart removals
		foreach(entity in saferoomEnts) KillEntity(entity);
		local KilledEntList = saferoomEnts;

		m_firstRoundEnts = {}
		foreach(classname,instances in tItemEnts)
		{
			local cnt = m_removalTable[classname].tointeger();
			local saved_ents = m_firstRoundEnts[classname] <- [];
			// We need to choose certain items to save
			while( instances.len() > 0 && saved_ents.len() < cnt )
			{
				local saveIdx = RandomInt(0,instances.len()-1);
				// Track this entity's info for future rounds.
				saved_ents.push(ItemInfo(instances[saveIdx]));
				// Remove this entity from the kill list
				instances.remove(saveIdx);
			}
			Msg("Killing "+instances.len()+" "+classname+", leaving "+saved_ents.len()+" on the map.\n");
			foreach(inst in instances)
			{
				KillEntity(inst);
				KilledEntList.push(inst.weakref());
			}
		}

		m_firstRoundModelEnts = {}
		foreach(model,instances in tModelEnts)
		{
			// Don't use killed ents!
			foreach(deadEnt in KilledEntList) ArrayRemoveByValue(instances, deadEnt);
			local limit = m_modelRemovalTable[model].tointeger();
			local saved_ents = m_firstRoundModelEnts[model] <- [];
			while( instances.len() > 0 && saved_ents.len() < limit )
			{
				local saveIdx = RandomInt(0,instances.len()-1);
				// Track this entity's info for future rounds.
				saved_ents.push(ItemInfo(instances[saveIdx]));
				// Remove this entity from the kill list
				instances.remove(saveIdx);
			}
			Msg("Killing "+instances.len()+" "+model+", leaving "+saved_ents.len()+" on the map.\n");
			foreach(inst in instances)
			{
				KillEntity(inst);
			}
		}
	}
	function OnLaterRounds()
	{
		local ent = m_entlist.First();
		local classname = "";
		local tItemEnts = {};

		foreach(key,val in m_removalTable)
		{
			tItemEnts[key] <- [];
		}
		while(ent != null)
		{
			classname = ent.GetClassname()
			if(classname in m_removalTable)
			{
				tItemEnts[classname].push(ent.weakref());
			}
			ent=m_entlist.Next(ent);
		}

		local tModelEnts = {};
		foreach(mdl,limit in m_modelRemovalTable)
		{
			local thisMdlEnts = tModelEnts[mdl] <- [];
			ent = null;
			while((ent = m_entlist.FindByModel(ent, mdl)) != null)
			{
				// Only use this entity if it's not one of the saferoom entities we're going to remove.
				thisMdlEnts.push(ent.weakref());
			}
		}

		foreach(classname,entList in tItemEnts)
		{
			local firstItems = m_firstRoundEnts[classname];
			// count to keep alive
			local cnt = firstItems.len();
			if(cnt > entList.len())
			{
				Msg("Warning! Not enough "+classname+" spawned this round to match R1! ("+entList.len()+" < "+cnt+")\n");
				cnt = entList.len();
			}

			for(local i = cnt; i < entList.len(); i++)
			{
				KillEntity(entList[i]);
			}

			for(local i = 0; i < cnt; i++)
			{
				local vec = VectorClone(firstItems[i].m_vecOrigin);

				// Hack. To avoid crashing the server by placing entities on top of each other here, 
				// we'll just offset the placement of each entity by 1 unit. 
				// Alternative solutions: 
				// 1. Check all tracked entity positions for conflicts and resolve through <insert algorithm here>
				// 2. Move all entities to offset by 1 unit, wait 1 frame, move entities to original (un-offset) position (same frame also crashes)
				// 3. Convert this code to kill/create entities instead of kill/shuffle entities (not possible atm)
				vec.z += 1.0;
				entList[i].SetOrigin(vec.ToVector());
				//entList[i].SetForwardVector(firstItems[i].m_vecForward.ToVector());
			}
			Msg("Restored "+cnt+" "+classname+", out of "+entList.len()+" on the map.\n");
		}

		foreach(model,entList in tModelEnts)
		{
			local firstItems = m_firstRoundModelEnts[model];
			// count to keep alive
			local cnt = firstItems.len();
			if(cnt > entList.len())
			{
				Msg("Warning! Not enough "+model+" spawned this round to match R1! ("+entList.len()+" < "+cnt+")\n");
				cnt = entList.len();
			}

			for(local i = cnt; i < entList.len(); i++)
			{
				KillEntity(entList[i]);
			}

			for(local i = 0; i < cnt; i++)
			{
				entList[i].SetOrigin(firstItems[i].m_vecOrigin.ToVector());
				//entList[i].SetForwardVector(firstItems[i].m_vecForward.ToVector());
			}
			Msg("Restored "+cnt+" "+model+", out of "+entList.len()+" on the map.\n");
		}
	}
	function OnRoundStart(roundNumber)
	{
		Msg("ItemControl OnRoundStart()\n");
		// This will run multiple times per round in certain cases...
		// Notably, on natural map switch (transition) e.g. chapter 1 ends, start chapter 2.
		// Just make sure you don't screw up anything...
		if(roundNumber == 1)
		{
			OnFirstRound();
		}
		else
		{
			OnLaterRounds();
		}


	}
	// pointer to global Entity List
	m_entlist = null;
	// point to global mapinfo
	m_pMapInfo = null;
	// Table of entity classname, limit value pairs
	m_removalTable = null;
	m_modelRemovalTable = null;
	m_saferoomRemoveList = null;

	m_firstRoundEnts = null;
	m_firstRoundModelEnts = null;
	static ArrayToTable = Utils.ArrayToTable;
	static ArrayRemoveByValue = Utils.ArrayRemoveByValue;
	static ItemInfo = Utils.ItemInfo;
	static KillEntity = Utils.KillEntity;
	static VectorClone = Utils.VectorClone;
};

class Modules.MeleeWeaponControl extends GameState.GameStateListener {
	constructor(entlist, melee_limit)
	{
		m_pEntities = entlist;
		m_maxSpawns = melee_limit;
	}
	function EntListToItemInfoList(entlist)
	{
		local infolist = [];
		foreach (ent in entlist)
		{
			infolist.push(ItemInfo(ent));
		}
		return infolist;
	}
	function OnFirstRound()
	{
		m_firstRoundMelees = {};
		local meleeEnts = {}
		local totalCount = 0;

		// Enumerate all melee weapon spawns by model
		foreach(mdl in MeleeModels)
		{
			// prep table for later
			m_firstRoundMelees[mdl] <- []

			local spawnlist = []
			local ent = null;
			while((ent = m_pEntities.FindByModel(ent, mdl)) != null)
			{
				spawnlist.push(ent.weakref());
				totalCount++;
			}
			meleeEnts[mdl] <- spawnlist;
		}

		if(totalCount < m_maxSpawns)
		{
			// There are less than m_maxSpawns melee weapons on the map,
			// so we record them all and we're done.
			foreach(mdl,spawnlist in meleeEnts)
			{
				m_firstRoundMelees[mdl] = EntListToItemInfoList(spawnlist);
			}
			Msg("Only "+totalCount+" melee weapons on the map to track.\n");
		}
		else
		{
			local savedCnt = 0;

			// Save m_maxSpawns of them
			while(savedCnt < m_maxSpawns)
			{
				local saveIdx = RandomInt(0,totalCount-1);

				// Iterate through the list until we've hit saveIdx melees.
				foreach(mdl, spawnlist in meleeEnts)
				{
					if(saveIdx < spawnlist.len())
					{
						// Save this item's spawn info.
						m_firstRoundMelees[mdl].push(ItemInfo(spawnlist[saveIdx]));
						spawnlist.remove(saveIdx);
						savedCnt++;
						totalCount--;
						break;
					}
					saveIdx -= spawnlist.len();
				}
			}

			// remove the remaining weapon spawns from the map.
			foreach(mdl, spawnlist in meleeEnts)
			{
				foreach(melee_ent in spawnlist)
				{
					KillEntity(melee_ent);
				}
			}
			Msg("Killing "+totalCount+" melee weapons and saving "+savedCnt+" out of "+(totalCount+savedCnt)+" on the map.\n");
		}

	}
	function OnOtherRounds()
	{
		local meleeEnts = {}
		local totalCount = 0;

		// Enumerate all melee weapon spawns by model
		foreach(mdl in MeleeModels)
		{
			local spawnlist = []
			local ent = null;
			while((ent = m_pEntities.FindByModel(ent, mdl)) != null)
			{
				spawnlist.push(ent.weakref());
				totalCount++;
			}
			meleeEnts[mdl] <- spawnlist;
		}

		foreach(mdl,infolist in m_firstRoundMelees)
		{
			local restoreCnt = infolist.len();

			// Make sure this model isn't unset in this round's ent table
			if(!(mdl in meleeEnts))
			{
				Msg("Warning! No "+ mdl +" exist on R2 for restoring!\n");
				continue;
			}

			local thisMdlEnts = meleeEnts[mdl];

			// Check that this round's ent list is long enough to spawn last round's melees
			if(thisMdlEnts.len() < restoreCnt)
			{
				restoreCnt = thisMdlEnts.len();
				Msg("Warning! Not as many of melee weapon ("+ mdl +") available on R2! ("+restoreCnt+" < "+infolist.len()+"\n");
			}

			Msg("Restoring "+restoreCnt+" "+mdl+" out of "+thisMdlEnts.len()+"\n");

			// Move restoreCnt melees of this model to their spots from R1.
			for(local i = 0; i < restoreCnt; i++)
			{
				local ent = thisMdlEnts[0];
				thisMdlEnts.remove(0);
				ent.SetOrigin(infolist[i].m_vecOrigin.ToVector());
				//ent.SetForwardVector(infolist[i].m_vecForward.ToVector());
			}
		}

		// Delete the remaining melees from this round.
		foreach(mdl,spawnlist in meleeEnts)
		{
			foreach(ent in spawnlist)
			{
				KillEntity(ent);
			}
		}
	}
	function OnRoundStart(roundNumber)
	{
		if(roundNumber == 1)
		{
			OnFirstRound();
		}
		else
		{
			OnOtherRounds();
		}
	}
	m_pEntities = null;
	m_maxSpawns = null;

	m_firstRoundMelees = null;

	static MeleeModels = Utils.MeleeModels;
	static ItemInfo = Utils.ItemInfo;
	static KillEntity = Utils.KillEntity;
};

class Modules.HRControl extends GameState.GameStateListener //, extends TimerCallback (no MI support)
{
	constructor(entlist, globals, director)
	{
		m_pEntities = entlist;
		m_pGlobals = globals;
		m_pDirector = director;
	}
	function QueueCheck(time)
	{
		if(!m_bChecking)
		{
			m_pGlobals.Timer.AddTimer(time, this);
			m_bChecking = true;
		}
	}
	function OnRoundStart(roundNumber)
	{
		QueueCheck(1.0);
	}
	function OnTimerElapsed()
	{
		m_bChecking=false;
		if(!m_pDirector.HasAnySurvivorLeftSafeArea()) QueueCheck(5.0);

		local ent = null;
		local hrList = [];
		while((ent = m_pEntities.FindByClassname(ent, "weapon_hunting_rifle")) != null)
		{
			hrList.push(ent.weakref());
		}

		if(!m_pGlobals.MapInfo.isIntro)
		{
			if(hrList.len() <= 1) return;
			hrList.remove(RandomInt(0,hrList.len()-1));
		}

		// Delete the rest
		foreach(hr in hrList)
		{
			KillEntity(hr);
		}
	}
	m_pEntities = null;
	m_pTimer = null;
	m_pGlobals = null;
	m_pDirector = null;
	m_bChecking = false;
	static KillEntity = Utils.KillEntity;
};

class Modules.GasCanControl extends GameState.GameStateListener {
	constructor(entList, mapinfo)
	{
		m_pEntities = entList;
		m_pMapInfo = mapinfo;
	}
	function OnRoundStart(roundNumber)
	{
		// Don't demolish gascans if the map has a scavenge event!
		// Unless it's c1m2 because it uses cola yo.
		if(m_pMapInfo.hasScavengeEvent && m_pMapInfo.mapname != "c1m2_streets") return;

		local ent = null;
		local list = [];
		while((ent = m_pEntities.FindByModel(ent, "models/props_junk/gascan001a.mdl")) != null)
		{
			list.push(ent.weakref());
		}
		Msg("Killing "+list.len()+" gas cans from the map.\n");
		foreach(can in list)
		{
			KillEntity(can);
		}
	}
	m_pEntities = null;
	m_pMapInfo = null;
	static KillEntity = Utils.KillEntity;
}