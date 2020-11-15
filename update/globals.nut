

// Call this once on script start to initialize CompLite's libraries and hook them up to ChallengeScript events.
// parentTable: The parent table where the CompLite library namespace should be created. This 
//		should be a table which will not be wiped on roundstart. getroottable() is a good idea, defaults to getroottable();
// customNameSpace: The custom name to use for the CompLite Libraries' namespace. Should be passed as a string. Defaults to "CompLite"
// ChallengeScript: Pass a reference to the ChallengeScript table. Defaults to ::DirectorScript.MapScript.ChallengeScript
function InitializeCompLite(parentTable = getroottable() , customNameSpace = "CompLite", ChallengeScript = ::DirectorScript.MapScript.ChallengeScript )
{
	if(customNameSpace in parentTable)
	{
		local CompLite = parentTable[customNameSpace];
		CompLite.Globals.IncrementRoundNumber();
		CompLite.Globals.GSM.Reset();

		if(CompLite.Globals.GetCurrentRound() == 1)
		{
			CompLite.Globals.MapInfo.IdentifyMap(Entities);
		}

		ChallengeScript.DirectorOptions <- CompLite.ChallengeScript.DirectorOptions;
		ChallengeScript.Update <- CompLite.ChallengeScript.Update;
		return CompLite;
	}
	
	local CompLite = parentTable[customNameSpace] <- {};
	
	IncludeScript("gamestate_model", CompLite);
	IncludeScript("globaltimers", CompLite);
	IncludeScript("utils", CompLite);
	IncludeScript("modules", CompLite);
	
	CompLite.ChallengeScript <- {
		CompLite = CompLite
		DirectorOptions = {
			CompLite = CompLite
			function AllowWeaponSpawn( classname ) 
			{ 
				return CompLite.Globals.GSM.OnAllowWeaponSpawn(classname);
			}
			function ConvertWeaponSpawn( classname ) 
			{ 
				return CompLite.Globals.GSM.OnConvertWeaponSpawn(classname);
			}
			function GetDefaultItem( idx ) 
			{
				return CompLite.Globals.GSM.OnGetDefaultItem(idx);
			}
			function ConvertZombieClass( id ) 
			{ 
				return CompLite.Globals.GSM.OnConvertZombieClass(id);
			}
		}

		function Update()
		{
			CompLite.Globals.Timer.Update();
			CompLite.Globals.FrameTimer.Update();
			CompLite.Globals.GSM.DoFrameUpdate();
		}
	}

	CompLite.Globals <- CompLiteGlobals(CompLite, Director, CompLite.ChallengeScript.DirectorOptions);

	ChallengeScript.DirectorOptions <- CompLite.ChallengeScript.DirectorOptions;
	ChallengeScript.Update <- CompLite.ChallengeScript.Update;

	CompLite.Globals.MapInfo.IdentifyMap(Entities);

	return CompLite;
}

class CompLiteGlobals {
	constructor(NameSpace, director, dopts)
	{
		Timer = NameSpace.Timers.GlobalSecondsTimer();
		FrameTimer = NameSpace.Timers.GlobalFrameTimer();
		MapInfo = NameSpace.Utils.MapInfo();
		GSC = NameSpace.GameState.GameStateController();
		GSM = NameSpace.GameState.GameStateModel(GSC, director);
		MobResetti = NameSpace.Utils.ZeroMobReset(director, dopts, FrameTimer);
	}

	function IncrementRoundNumber() { m_iRoundNumber++; }
	function GetCurrentRound() { return m_iRoundNumber; }
	//public
	Timer = null;
	FrameTimer = null;
	MapInfo = null;
	GSM = null;
	GSC = null;
	MobResetti = null;
	
	// private
	m_iRoundNumber = 0;
}
