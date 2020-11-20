//========= Copyright © Valve Corporation, All rights reserved. ============//
//
// All the logic for an individual shootzone
//
//==========================================================================//

isEnabled <- false
isActive <- false
timeToDeactivate <- 0
id <- -1
origin <- EntityGroup[2].GetOrigin()
flowDistance <- 0.0
flowPercent <- 0.0
flowPercent1 <- 0.0

function Precache()
{
	self.PrecacheScriptSound( "Lilpeanut.GALLERY_HIT" )
	self.PrecacheScriptSound( "Lilpeanut.GALLERY_SPAWN" )
	self.PrecacheScriptSound( "c2m4.BadMan1" )
}

function OnEnterShootzone()
{
	if ( isEnabled )
	{
		//Activate the shootzone if needed
		if ( !isActive )
		{
			ActivateShootzone()
		}

		//Tell the mode to recompute players in shootzones
		//g_ModeScript.RecomputePlayersInShootzones()
	}
}


function OnExitShootzone()
{
	//Tell the mode to recompute players in shootzones
	//g_ModeScript.RecomputePlayersInShootzones()
}


function EnableShootzone()
{
	isEnabled = true

	//Enable the trigger and start glowing
	EntFire( EntityGroup[0].GetName(), "Enable" )
	EntFire( EntityGroup[1].GetName(), "setglowoverride", "128 255 0" )
	EntFire( EntityGroup[1].GetName(), "StartGlowing" )
}


function ActivateShootzone()
{
	isActive = true
	timeToDeactivate = Time() + 5

	//EmitSoundOn( "c2m4.BadMan1", self )

	EntFire( EntityGroup[1].GetName(), "setglowoverride", "255 128 64" )
}


function TimeoutShootzone()
{
	EntFire( EntityGroup[1].GetName(), "StopGlowing" )

	isActive = false;
	isEnabled = false;

	//EmitSoundOn( "Lilpeanut.GALLERY_HIT", self )

	g_ModeScript.ShootzoneTimedOut( id )

	//Tell the mode to recompute players in shootzones
	//g_ModeScript.RecomputePlayersInShootzones()
}


function Think()
{
	if ( !isActive )
	{
		return;
	}

	//Deactivate 
	if ( Time() > timeToDeactivate )
	{
		TimeoutShootzone()	
	}
}
