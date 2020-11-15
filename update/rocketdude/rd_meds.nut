//****************************************************************************************
//																						//
//										rd_meds.nut										//
//																						//
//****************************************************************************************



// All trigger and mushroom data gets stored in here
// ----------------------------------------------------------------------------------------------------------------------------

::medkit_data	<- {}
::medkit_data2	<- {}




// Returns handle of the created prop_dynamic with a 'mushroom model'
// ----------------------------------------------------------------------------------------------------------------------------

::RD_healtkit_model <- function(pos, shroomdata){
	local model = SpawnEntityFromTable("prop_dynamic_override",
	{
		// General
		targetname = "RD_HP_MODEL", origin = pos, angles = "0 0 0", body = 0, DefaultAnim = "idle", DisableBoneFollowers = 1,
		// Shadows and fade
		disablereceiveshadows = 1, disableshadows = 1, disableX360 = 0, ExplodeDamage = 0, ExplodeRadius = 0, fademaxdist = 0, fademindist = -1, fadescale = 0,
		// Glows
		glowbackfacemult = 1.0, glowcolor = shroomdata.glowColor, glowrange = 256, glowrangemin = 0, glowstate = 3, health = 0,
		// Model & Animation
		LagCompensate = 0, MaxAnimTime = 10, maxcpulevel = 0, maxgpulevel = 0, MinAnimTime = 5,
		mincpulevel = 0, mingpulevel = 0, model = "models/props_collectables/mushrooms_glowing.mdl", PerformanceMode = 0, pressuredelay = 0,
		RandomAnimation = 0, renderamt = 255, rendercolor = shroomdata.modelColor, renderfx = 0, rendermode = 0, SetBodyGroup = 0, skin = 0,
		solid = 0, spawnflags = 0, updatechildren = 0
	})
	model.SetModelScale(shroomdata.modelScaleMax, 0)
	return model
}




// Creates a survivor only filter for the mushrooms
// ----------------------------------------------------------------------------------------------------------------------------

SpawnEntityFromTable("filter_activator_team", { targetname = "RD_FILTER_SURVIVOR", origin = Vector(0,0,0), Negated = 0, filterteam = 2 } )
::worldspawn <- Entities.FindByClassname(null, "worldspawn")
::worldspawn.ValidateScriptScope()




// Returns handle of trigger to execute the healing function
// ----------------------------------------------------------------------------------------------------------------------------

::RD_healthkit_trigger <- function(pos, shroomdata){
	local triggerMin = shroomdata.triggerSize[0]
	local triggerMax = shroomdata.triggerSize[1]
	local zOffset = triggerMax.z
	local HP_Value = shroomdata.hp
	
	local triggerName = "RD_HP_TRIGGER"
	//
	local triggerTable =
	{
		targetname    = triggerName
		StartDisabled = 0
		spawnflags    = 1
		allowincap    = 1
		entireteam    = 0
		filtername    = "RD_FILTER_SURVIVOR"
		origin        = pos + Vector(0,0,zOffset)
	}

	local trigger = SpawnEntityFromTable( "trigger_multiple", triggerTable)
	//
	setTriggerSize(trigger,triggerMin,triggerMax)
	NetProps.SetPropInt(trigger, "m_Collision.m_nSolidType", 2)
	//
	EntFire( triggerName, "AddOutput", "OnStartTouch worldspawn:RunScriptCode:survivorMedKitTouch(activator):0:-1" )
	EntFire( triggerName, "AddOutput", "OnTouching worldspawn:RunScriptCode:survivorMedKitTouch(activator):0:-1" )
	//
	if(scriptDebug){
		DebugDrawBox( triggerTable.origin, Vector(32,32,32), Vector(-32,-32,-32), 255, 255, 255, 0, 16)
	}
	return trigger
}




// Sets the trigger size in relation to the mushroom size
// ----------------------------------------------------------------------------------------------------------------------------

function setTriggerSize(trigger, vectorMins, vectorMaxs){
	if(trigger.IsValid()){
		if(typeof(vectorMins) == "Vector"){
			if(typeof(vectorMaxs) == "Vector"){
				NetProps.SetPropVector(trigger, "m_Collision.m_vecMins", vectorMins)
				NetProps.SetPropVector(trigger, "m_Collision.m_vecMaxs", vectorMaxs)
			}else{
				error("setTriggerSize error: vectorMaxs ment to be datatype vector")
			}
		}else{
			error("setTriggerSize error: vectorMins ment to be datatype vector")
		}
	}
}




// Creates a set of trigger and prop_dynamic_override ( healing mushroom )
// ----------------------------------------------------------------------------------------------------------------------------

::createRD_Medkit <- function(pos, shroomdata){
	local HP_Val = shroomdata.hp
	
	local trigger = RD_healthkit_trigger(pos, shroomdata);
	local model = RD_healtkit_model(pos, shroomdata);

	medkit_data[trigger]	<- { model = model, usetime = Time() , usable = true , hp = HP_Val }
	medkit_data2[model]		<- { trigger = trigger, usetime = Time() , usable = true , hp = HP_Val, modelScaleMin = shroomdata.modelScaleMin, modelScaleMax = shroomdata.modelScaleMax }
}




// Mushrooms properties
// ----------------------------------------------------------------------------------------------------------------------------
::shroomProperties <-
{
	large 	= 	{ hp = 75, modelColor = "255 185 0", glowColor = "255 185 0", modelScaleMax = 7.0, modelScaleMin = 1.0, triggerSize = [ Vector(-32,-32,-32), Vector(32,32,32) ] },
	medium 	=	{ hp = 50, modelColor = "220 0 255", glowColor = "220 0 255", modelScaleMax = 5.0, modelScaleMin = 1.0, triggerSize = [ Vector(-16,-16,-16), Vector(16,16,16) ] },
	small	=	{ hp = 25, modelColor = "0 105 255", glowColor = "0 105 255", modelScaleMax = 3.0, modelScaleMin = 1.0, triggerSize = [ Vector(-16,-16,-16), Vector(16,16,16) ] }
	tiny	=	{ hp = 10, modelColor = "255 255 255", glowColor = "255 255 255", modelScaleMax = 2.0, modelScaleMin = 1.0, triggerSize = [ Vector(-16,-16,-16), Vector(16,16,16) ] }
}

foreach(dataset in shroomProperties){
	dataset.glowColor = getColorWithIntensity(dataset.modelColor, 77)
}




// After a mushroom heals a player it should be invisible for 10 seconds
// ----------------------------------------------------------------------------------------------------------------------------

::setMedVisibility <- function(x, ent){
	
	if(x == 0){
		NetProps.SetPropInt(ent, "m_Glow.m_iGlowType", 0)
		NetProps.SetPropInt(ent, "m_fEffects", NetProps.GetPropInt(ent, "m_fEffects") | (1 << 5))
		mushroomSizer(ent,medkit_data2[ent].modelScaleMin, 0)
	}else{
		NetProps.SetPropInt(ent, "m_fEffects", 0)
		NetProps.SetPropInt(ent, "m_Glow.m_iGlowType", 3)
		mushroomSizer(ent,medkit_data2[ent].modelScaleMax, 0.1)
		EmitAmbientSoundOn("level/popup.wav", 1, 100, 100, ent)
	}
}




// Let's the mushroom "grow"
// ----------------------------------------------------------------------------------------------------------------------------

::mushroomSizer <- function(ent, scale, time){
	ent.SetModelScale(scale, time)
}




// Allow bunny hop for the player
// ----------------------------------------------------------------------------------------------------------------------------

::playerBecomesBunny <- function(player){
	if(!(player in bunnyPlayers)){
		if(player.IsValid()){
			bunnyPlayers[player] <- true
			ClientPrint(null, 5, "\x03" + player.GetPlayerName() + "\x01" + " is a bunny now")
		}
	}
}




// Survivor touches a mushroom trigger
// ----------------------------------------------------------------------------------------------------------------------------

::survivorMedKitTouch <- function(player){
	
	// Has to be set when this fuction gets called via OnTouching because the activator is the trigger itself
	
	if(player.GetClassname() == "trigger_multiple"){
		player = Entities.FindByClassnameNearest("player", player.GetOrigin(), 256)
	}
	
	local playerPos = player.GetOrigin()
	local medkit_trigger = Entities.FindByNameNearest("RD_HP_TRIGGER", playerPos, 256)
	local HP_Val = medkit_data[medkit_trigger].hp
	
	local medkit_model = Entities.FindByNameNearest("RD_HP_MODEL", playerPos, 256)
	
	if(player.GetHealth() < 200 && !IsPlayerABot(player) || player.IsIncapacitated() && !IsPlayerABot(player)){

		if(Time() >= medkit_data[medkit_trigger].usetime + 10 )
		{
			if(!missionFailed){
				healPlayer(player, HP_Val)
				medkit_data[medkit_trigger].usetime = Time()
				medkit_data[medkit_trigger].usable = false
				setMedVisibility(0, medkit_model)
				playerBecomesBunny(player)
			}
		}
	}
}




// Healing function for mushroom trigger ( healing, visual effect, audio indicator )
// ----------------------------------------------------------------------------------------------------------------------------

::healPlayer <- function(player, val){
	
	local sndPitch = 100;
	switch(GetCharacterDisplayName(player)){
		case "Rochelle"	:	sndPitch = 115; break;
		case "Zoey"		: 	sndPitch = 135; break;
		default			: 	sndPitch = 100; break;
	}
	
	EmitAmbientSoundOn("player/items/pain_pills/pills_use_1.wav", 1, 100, sndPitch, player)
	StopAmbientSoundOn("player/heartbeatloop.wav", player) 
	player.UseAdrenaline(7)
	ScreenFade(player, 40, 0, 0, 190, 1, 1,1 )
	local newHP = player.GetHealth() + val
	
	if(player.IsIncapacitated())
	{
		player.ReviveFromIncap()
		player.SetReviveCount(0)
		player.SetHealthBuffer(0)
		player.SetHealth(val)
	}
	else
	{
		if(newHP >= 200)
		{
			//NetProps.SetPropInt(player,"m_isGoingToDie",0)
			//NetProps.SetPropInt(player,"m_isIncapacitated",0)
			player.ReviveFromIncap()
			player.SetReviveCount(0)
			player.SetHealthBuffer(0)
			player.SetHealth(200)
		}
		else
		{
			//NetProps.SetPropInt(player,"m_isGoingToDie",0)
			//NetProps.SetPropInt(player,"m_isIncapacitated",0)
			player.ReviveFromIncap()
			player.SetReviveCount(0)
			player.SetHealthBuffer(0)
			player.SetHealth(newHP)
		}
	}
}




// Called "OnGameplayStart" it will spawn mushrooms for the current map 
// ----------------------------------------------------------------------------------------------------------------------------

spawnMushrooms <- function(){
	if(Director.GetMapName().tolower() in mushroomPositions){
		foreach(dataset in mushroomPositions[Director.GetMapName()]){
			createRD_Medkit(dataset[0], shroomProperties[dataset[1]])
		}
	}
}



