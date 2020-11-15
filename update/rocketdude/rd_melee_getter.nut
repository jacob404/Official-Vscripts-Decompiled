//****************************************************************************************
//																						//
//									rd_melee_getter.nut									//
//																						//
//****************************************************************************************

sharpMeleeData <-
[
	{ model = "models/v_models/weapons/v_knife_t.mdl", itemName = "knife", alias = "knife" },
	{ model = "models/weapons/melee/v_crowbar.mdl", itemName = "crowbar", alias = "crowbar" },
	{ model = "models/weapons/melee/v_fireaxe.mdl", itemName = "fireaxe", alias = "fireaxe" },
	{ model = "models/weapons/melee/v_katana.mdl", itemName = "katana", alias = "katana" },
	{ model = "models/weapons/melee/v_machete.mdl", itemName = "machete", alias = "machete" },
	{ model = "models/weapons/melee/v_pitchfork.mdl", itemName = "pitchfork", alias = "pitchfork" }
]

bluntMeleeData <-
[
	{ model = "models/weapons/melee/v_riotshield.mdl", itemName = "riotshield" , alias = "riotshield" },
	{ model = "models/weapons/melee/v_shovel.mdl", itemName = "shovel", alias = "shovel" },
	{ model = "models/weapons/melee/v_bat.mdl", itemName = "baseball_bat", alias = "bat" },
	{ model = "models/weapons/melee/v_cricket_bat.mdl", itemName = "cricket_bat", alias = "cricket" },
	{ model = "models/weapons/melee/v_golfclub.mdl", itemName = "golfclub", alias = "golfclub" },
	{ model = "models/weapons/melee/v_tonfa.mdl", itemName = "tonfa", alias = "tonfa" },
	{ model = "models/weapons/melee/v_electric_guitar.mdl", itemName = "electric_guitar", alias = "guitar" },
	{ model = "models/weapons/melee/v_frying_pan.mdl", itemName = "frying_pan", alias = "pan" }
]




// Before giving the melee check if it's available for the current map
// ----------------------------------------------------------------------------------------------------------------------------

function GiveMelee(player, melee){

	if(meleeAliases == null){
		meleeAliases = getAvailableMeleeAliases()
	}

	local sharps = GetAvailableSharpMelees()
	local blunts = GetAvailableBluntMelees()

	if(sharps.find(melee) != null || blunts.find(melee) != null){
		player.GiveItem(melee)
	}else{
		ClientPrint(null,5, "The " + melee + " is not available on current map.")
		ClientPrint(null,5, "Take one of those: " + meleeAliases)
	}
}

meleeAliases <- null;
function getAvailableMeleeAliases(){
	local aliases = "";
	foreach(dataSet in sharpMeleeData){
		if(IsModelPrecached(dataSet.model)){
			aliases += dataSet.alias + ", "
		}
	}
		foreach(dataSet in bluntMeleeData){
		if(IsModelPrecached(dataSet.model)){
			aliases+=dataSet.alias + ", "
		}
	}
	return aliases;
}

function GetAvailableSharpMelees(){
	local sharps = []
	foreach(dataSet in sharpMeleeData){
		if(IsModelPrecached(dataSet.model)){
			sharps.append(dataSet.itemName)
		}
	}
	return sharps;
}

function GetAvailableBluntMelees(){
	local blunts = []
	foreach(dataSet in bluntMeleeData){
		if(IsModelPrecached(dataSet.model)){
			blunts.append(dataSet.itemName)
		}
	}
	return blunts;
}




// Will give the player a random sharp/blunt weapon depending which melee is available on the current map
// ----------------------------------------------------------------------------------------------------------------------------

function getAvailableMelee(attribute){
	local sharps = GetAvailableSharpMelees()
	local blunts = GetAvailableBluntMelees()
	local melee = null;
	if(sharps.len() != 0 && blunts.len() != 0){
		if(attribute == "Sharp"){
		melee = sharps[RandomInt(0, sharps.len() - 1)]
		}
		else{
			melee = blunts[RandomInt(0, blunts.len() - 1)]
		}
		return melee;
	}else{
		return "bat"
	}
}

