// vim: set ts=4
// L4D2 GameState Model for Mutation VScripts
// Copyright (C) 2012 ProdigySim
// All rights reserved.
// =============================================================================

// double include protection
if("GameState" in this) return;
GameState <- {
	ROUNDSTART_DELAY_INTERVAL = 2
};
IncludeScript("utils", this);

class GameState.GameStateModel
{
	constructor(controller, director)
	{
		m_controller = controller;
		m_pDirector = director;
	}

	function DoFrameUpdate()
	{
		if(m_bLastUpdateTankInPlay)
		{
			if(!m_pDirector.IsTankInPlay())
			{
				m_bLastUpdateTankInPlay = false;
				m_controller.TriggerTankLeavesPlay();
			}
		}
		else if(m_pDirector.IsTankInPlay())
		{
			m_bLastUpdateTankInPlay = true;
			m_controller.TriggerTankEntersPlay();
		}
		if(!m_bLastUpdateSafeAreaOpened && m_pDirector.HasAnySurvivorLeftSafeArea())
		{
			m_bLastUpdateSafeAreaOpened = true;
			m_controller.TriggerSafeAreaOpen();
		}
		if(!m_bRoundStarted && m_bHeardAWS && m_bHeardCWS && m_bHeardGDI 
			&& m_iRoundStartTime < Time()-m_roundstart_delay)
		{
			m_bRoundStarted = true;
			m_controller.TriggerRoundStart(GetCurrentRound());
		}
	}
	function OnAllowWeaponSpawn( classname )
	{
		m_bHeardAWS = true;
		m_iRoundStartTime = Time();
		return m_controller.TriggerAllowWeaponSpawn(classname);
	}
	function OnConvertWeaponSpawn( classname )
	{
		m_bHeardCWS = true;
		m_iRoundStartTime = Time();
		return m_controller.TriggerConvertWeaponSpawn(classname);
	}
	function OnGetDefaultItem( idx )
	{
		m_bHeardGDI = true;
		m_iRoundStartTime = Time();
		return m_controller.TriggerGetDefaultItem(idx);
	}
	function OnConvertZombieClass(id)
	{
		return m_controller.TriggerPCZSpawn(id);
	}

	function Reset()
	{
		m_bRoundStarted = false;
		m_bHeardAWS = false;
		m_bHeardCWS = false;
		m_bHeardGDI = false;
		m_iRoundStartTime = 0;
		m_bLastUpdateSafeAreaOpened = false;
	}

	// Check for various round-start even. ts before triggering OnRoundStart()
	m_bRoundStarted = false;
	m_bHeardAWS = false;
	m_bHeardCWS = false;
	m_bHeardGDI = false;
	m_iRoundStartTime = 0;

	m_bLastUpdateTankInPlay = false;
	m_bLastUpdateSafeAreaOpened = false;
	
	m_controller = null;
	m_pDirector = null;
	m_roundstart_delay = GameState.ROUNDSTART_DELAY_INTERVAL;
	static GetCurrentRound = Utils.GetCurrentRound;
};

class GameState.GameStateListener
{
	// Called on round start. These may be multiples of these triggered, unfortunately.
	function OnRoundStart(roundNumber) {}
	// Called when a player leaves saferoom or the saferoom timer counts down
	function OnSafeAreaOpened() {}
	// Called when tank spawns
	function OnTankEntersPlay() {}
	// Called when tank dies/leaves play
	function OnTankLeavesPlay() {}
	// Called when a player-controlled zombie is going to be spawned via ConvertZombieClass
	// This event will be chained--called on all Listeners with the modified id passed into successive calls.
	// id: SIClass id of the PCZ to be spawned
	// return another SIClass value to convert the PCZ spawn.
	function OnSpawnPCZ(id) {}
	// Called when a player-controlled zombie is going to be spawned via ConvertZombieClass
	// After conversions from OnSpawnPCZ have taken place
	// id: actual SIClass id to be spawned
	function OnSpawnedPCZ(id) {}
	// Called when DirectorOptions.GetDefaultItem() is called.
	// This event chain will notify all listeners, but only one return value will be used.
	// TODO: further abstraction to just have lists returned...
	// Should be at the beginning of the round normally.
	function OnGetDefaultItem(idx) {}
	// Called when DirectorOptions.AllowWeaponSpawn() is called. 
	// Should be at the beginning of the round normally, after conversions take place.
	// This event will stop being called on Listeners when one listener returns false.
	// classname: string classname of weapon to allow/disallow
	// return true to allow, false to disallow.
	function OnAllowWeaponSpawn(classname) {}
	// Called when DirectorOptions.ConvertWeaponSpawn is called
	// This event will be chained--called on all Listeners with the modified classname passed into successive calls.
	// classname: Classname of the weapon that would spawned
	// retun the classname that it should be converted to, or 0 for no conversion.
	function OnConvertWeaponSpawn(classname) {}
};

class GameState.GameStateController
{
	function AddListener(listener)
	{
		m_listeners.push(listener)
	}

	function TriggerRoundStart(roundNumber)
	{
		foreach(listener in m_listeners)
			listener.OnRoundStart(roundNumber);
	}
	function TriggerSafeAreaOpen()
	{
		foreach(listener in m_listeners)
			listener.OnSafeAreaOpened();
	}
	function TriggerTankEntersPlay()
	{
		foreach(listener in m_listeners)
			listener.OnTankEntersPlay();
	}
	function TriggerTankLeavesPlay()
	{
		foreach(listener in m_listeners)
			listener.OnTankLeavesPlay();
	}
	function TriggerPCZSpawn(id)
	{
		local retval = id;
		foreach(listener in m_listeners)
		{
			// Allow each listener to try to convert.
			// Not pretty in the long run but I'm okay with it.
			local ret = listener.OnSpawnPCZ(retval);
			if(ret != null) retval = ret;
		}

		// Simply notify everyone of the final value
		foreach(listener in m_listeners)
			listener.OnSpawnedPCZ(retval)
		return retval;
	}
	function TriggerAllowWeaponSpawn(classname)
	{
		foreach(listener in m_listeners)
		{
			// Cancel call chain once one listener returns false (says not to spawn it).
			if(listener.OnAllowWeaponSpawn(classname) == false) return false;
			// Interesting ! semantics
			//             null  false
			// !ret        true  true
			// ret==false  false true
			// ret==null   true  false
		}
		return true;
	}
	function TriggerConvertWeaponSpawn(classname)
	{
		local retcls = 0;
		foreach(listener in m_listeners)
		{
			local ret = listener.OnConvertWeaponSpawn(classname);
			if(ret != null && ret != 0) retcls = ret;
		}
		return retcls;
	}
	function TriggerGetDefaultItem(idx)
	{
		local retval = 0;
		foreach(listener in m_listeners)
		{
			local ret = listener.OnGetDefaultItem(idx);
			if(retval == 0 && ret != null) retval = ret;
		}
		return retval;
	}

	m_listeners = []
};
