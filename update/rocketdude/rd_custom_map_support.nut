//****************************************************************************************
//																						//
//								rd_custom_map_support.nut								//
//																						//
//****************************************************************************************




// Spawn mushrooms from map entities 
// ----------------------------------------------------------------------------------------------------------------------------

getMapSidedMushrooms <- function(){
	local mushroomTarget = null;
	local mushrooms = {}
	local sizes = ["tiny","small","medium","large"]
	
	foreach(size in sizes){
		while(mushroomTarget = Entities.FindByName(mushroomTarget, "rd_mushroom_" + size)){
			mushrooms[mushroomTarget] <- [  mushroomTarget.GetOrigin(), size]
		}
	}
	return mushrooms
}

spawnMapSidedMushrooms <- function(){
	
	foreach(target, dataset in getMapSidedMushrooms()){
		createRD_Medkit(dataset[0], shroomProperties[dataset[1]])
	}
}




// Timers and stats
// ----------------------------------------------------------------------------------------------------------------------------

::resetPlayerStats <- function(){
	if(activator.IsValid()){
		if(activator in playerOnGroundData){
			playerOnGroundData[activator] <- { startTime = Time(), ticks = 0, seconds = 0, finish = false }
			ClientPrint(null, 5, BLUE + "GO GO GO")
			EmitAmbientSoundOn("ui/littlereward.wav", 0.5, 100, 110, activator)
		}
	}
}

::mapFinished <- function(){
	
	if(playerOnGroundData[activator].finish == true){
		return
	}
	
	printFinalGroundTime(activator)
	playerOnGroundData[activator].finish = true;
	EmitAmbientSoundOn("ui/menu_invalid.wav", 0.5, 100, 110, activator)
	
	local playerSpawn = Entities.FindByName(null, "rd_player_start")
	if(playerSpawn != null){
		activator.SetOrigin(playerSpawn.GetOrigin())
	}else{
		ClientPrint(null, 5, "ERROR: ENTITY 'rd_player_start' NOT FOUND")
	}
}

