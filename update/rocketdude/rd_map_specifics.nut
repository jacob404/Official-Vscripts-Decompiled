//****************************************************************************************
//																						//
//									rd_map_specifics.nut								//
//																						//
//****************************************************************************************




// Some maps require minor adjustments to improve gameplay. 
// ----------------------------------------------------------------------------------------------------------------------------

::mapSpecifics <- function(){
	local mapName = Director.GetMapName().tolower()
	switch(mapName){
		
		case "c1m1_hotel"		:	rd_specifics_c1m1();	break;
		case "c8m4_interior"	:	rd_specifics_c8m4();	break;
		case "c8m5_rooftop"		:	rd_specifics_c8m5();	break;
		case "c14m1_junkyard"	:	rd_specifics_c14m1();	break;
		case "c14m2_lighthouse"	:	rd_specifics_c14m2();	break;
		default					:							break;
	}
}




// Since we dont have any fall damage at all we should not stop players from just dropping down the hotel
// ----------------------------------------------------------------------------------------------------------------------------

::rd_specifics_c1m1 <- function(){
	local deathTriggers =
	[
		Vector(3200.000,5312.000,1648.000),
		Vector(2944.000,5888.000,1648.000),
		Vector(2936.000,6932.000,1648.000),
		Vector(1516.800,8000.000,1520.000),
		Vector(632.000,6944.000,1648.000),
		Vector(1600.000,4608.000,1648.000),
		Vector(0.000,5632.000,1648.000)
	]
	foreach(triggerPos in deathTriggers){
		local ent = null;
		if(ent = Entities.FindByClassnameNearest( "trigger_hurt", triggerPos, 4 )){
			ent.Kill()
		}
	}
}




// Remove and rooftop_opening_clip
// ----------------------------------------------------------------------------------------------------------------------------

::rd_specifics_c8m5 <- function(){
	local ent = null;
	if(ent = Entities.FindByClassnameNearest( "func_brush", Vector(7248.000000, 9168.000000, 7144.000000), 4)){
		ent.Kill()
	}
}




// Change damage type of trigger_hurt ( water area in front of the end saferoom )
// ----------------------------------------------------------------------------------------------------------------------------

::rd_specifics_c14m1 <- function(){
	local trigger = null;
	if(trigger = Entities.FindByClassnameNearest( "trigger_hurt_ghost", Vector(-4580,9352,-732), 4)){
		TriggerSetDamageType(trigger, damageTypes.GENERIC)
	}
}




// Kill trigger which re-enables the ledgehang
// Change damage type of trigger_hurt ( water of rescue vehicle zone )
// ----------------------------------------------------------------------------------------------------------------------------

::rd_specifics_c14m2 <- function(){
	local ent = null;
	
	if(ent = Entities.FindByClassnameNearest( "trigger_multiple", Vector(-4352,3928,1096), 4)){
		ent.Kill()
	}
	if(ent = Entities.FindByClassnameNearest( "trigger_hurt", Vector(-4608,7168,-256), 4)){
		TriggerSetDamageType(ent, damageTypes.GENERIC)
	}
	if(ent = Entities.FindByClassnameNearest("func_brush", Vector(275.000000, 930.000000, 1360.000000), 4)){
		ent.Kill()
	}
}




// Re-execute the elevator fix once
// ----------------------------------------------------------------------------------------------------------------------------

::c8m4FixReloaded <- false
::rd_specifics_c8m4 <- function(){
	if(!c8m4FixReloaded){
		EntFire( "worldspawn", "RunScriptFile", "c8m4_elevatorfix" )
	}
}




// Utils to manipulate entities
// ----------------------------------------------------------------------------------------------------------------------------

::TriggerSetDamageType <- function(ent, type){
	if(ent.GetClassname() == "trigger_hurt" || ent.GetClassname() == "trigger_hurt_ghost"){
		NetProps.SetPropInt(ent, "m_bitsDamageInflict", type)
	}
}

::damageTypes <-
{
	GENERIC			= 0
	CRUSH			= 1
	BULLET			= 2
	SLASH			= 4
	BURN			= 8
	VEHICLE			= 16
	FALL			= 32
	BLAST			= 64
	CLUB			= 128
	SHOCK			= 256
	SONIC			= 512
	ENERGYBEAM		= 1024
	DROWN			= 16384
	PARALYSE		= 32768
	NERVEGAS		= 65536
	POISON			= 131072
	RADIATION		= 262144
	DROWNRECOVER	= 524288
	ACID			= 1048576
	SLOWBURN		= 2097152
	REMOVENORAGDOLL	= 4194304
}







