//****************************************************************************************
//																						//
//										rd_director.nut									//
//																						//
//****************************************************************************************

MutationOptions <-
{	
	// General
	cm_NoSurvivorBots	= 1
	
	// Special Infected
	MaxSpecials			= 6

	// convert items
	weaponsToConvert =
	{
		weapon_first_aid_kit =	"weapon_pain_pills_spawn"
	}

	function ConvertWeaponSpawn(classname){
		if (classname in weaponsToConvert){
			return weaponsToConvert[classname];
		}
		return 0;
	}	
	

	weaponsToPreserve =
	{
		weapon_pain_pills		= 0
		weapon_adrenaline		= 0
		weapon_melee			= 0
		weapon_first_aid_kit	= 0
		weapon_gascan			= 0
		weapon_pistol_magnum	= 0
	}

	function AllowWeaponSpawn(classname){
		if(!IsValveMap()){
			if(classname in weaponsToPreserve){
				return true;
			}
		}
		
		if (classname in weaponsToPreserve){
			return true;
		}
		return false;
	}
	
	function AllowFallenSurvivorItem(item){
		return false
	}



	DefaultItems = [
		"weapon_grenade_launcher",
		RandomInt(0, 1) ? getAvailableMelee("Sharp") : "weapon_pistol_magnum"
	]

	function GetDefaultItem( idx ){
		if ( idx < DefaultItems.len() ){
			return DefaultItems[idx];
		}
		return 0;
	}
}




// The right man in the wrong place can make all the difference in the world
// ----------------------------------------------------------------------------------------------------------------------------

::allowPropPickup <- function(){
	
	local player = null;
	local playerInv = {};
	
	while(player = Entities.FindByClassname(player, "player")){
		if(player.GetZombieType() == 9 && !IsPlayerABot(player)){
			if(player.GetPlayerName() == "Dr. Gordon Freeman"){
				 GetInvTable(player, playerInv)
				if("slot1" in playerInv){
					if(NetProps.GetPropString(playerInv.slot1, "m_strMapSetScriptName") == "crowbar"){
						return true;
					}
				}
			}
		}
	}
	return false;
}


function g_ModeScript::CanPickupObject(object){
	if(allowPropPickup()){
		return true
	}
	return false;
}


