//****************************************************************************************
//																						//
//									rd_last_chance.nut									//
//																						//
//****************************************************************************************




// Basic functions to check if survivors are dead / capped
// ----------------------------------------------------------------------------------------------------------------------------

function allSurvivorsIncap(){
	foreach(survivor in GetSurvivors()){
		//if(!survivor.IsIncapacitated() && !survivor.IsHangingFromLedge() && !survivor.IsDead() && !survivor.IsDying() && !playerIsCapped(survivor)){  // 20200913
		if(!survivor.IsIncapacitated() && !survivor.IsDead() && !survivor.IsDying()){
			return false
		}
	}
	return true
}

function allSurvivorsDead(){
	foreach(survivor in GetSurvivors()){
		if(!survivor.IsDead() && !survivor.IsHangingFromLedge()){
			return false
		}
	}
	return true
}

function playerIsCapped(player){
	local infected = null;
	local keys = ["m_pummelVictim","m_carryVictim","m_pounceVictim","m_jockeyVictim","m_tongueVictim"]
	while(infected = Entities.FindByClassname(infected, "player")){
		if(infected.GetZombieType() != 9){
			foreach(key in keys){
				if(NetProps.GetPropEntity(infected, key) == player){
					return true
				}
			}
		}
	}
	return false
}




// When all survivors are incapacitated, give them 10 seconds to kill any special infected or boss infected ( BL-Style )
// ----------------------------------------------------------------------------------------------------------------------------

::last_chance_active	<- false
lastChanceCheckStamp	<- Time()
remainingReviveTime		<- 10
::missionFailed			<- false
::lastChanceUsed		<- false



// Called on player_death and player_incapacitated it will call enableLastChanceVision()
// when all survivors are incap but not all are dead
// ----------------------------------------------------------------------------------------------------------------------------

function lastChanceSwitch(params){
	if(!allSurvivorsDead()){
		if("userid" in params && GetPlayerFromUserID(params.userid).GetZombieType() == 9){
			if(allSurvivorsIncap() && !last_chance_active){
				enableLastChanceVision();
				lastChanceUsed = true
				last_chance_active = true
				remainingReviveTime = 10
				Convars.SetValue("director_no_death_check", 1)
				lastChanceCheckStamp = Time()
			}
		}
	}
}




// Called every tick, it will outout a countdown to timeout the survivors
// ----------------------------------------------------------------------------------------------------------------------------

function lastChanceCountDown(){
	if(last_chance_active){
		if(Time() >= lastChanceCheckStamp + 1 ){
			lastChanceCheckStamp = Time()
			if(allSurvivorsIncap()){
				if(remainingReviveTime == 0){
					last_chance_active = false
					Convars.SetValue("director_no_death_check", 0)
					ClientPrint(null, 5, BLUE + "Sorry, you don't have any time left to repopulate the world.")
					missionFailed = true
				}else{
					ClientPrint(null, 5, BLUE + remainingReviveTime)
				}
				remainingReviveTime --
			}else{
				last_chance_active = false
				Convars.SetValue("director_no_death_check", 0)
			}
		}
	}
}




// Will switch survivors vision to "black and white" and enables outline glows for special and boss infected
// ----------------------------------------------------------------------------------------------------------------------------

function enableLastChanceVision(){
	whiteScreen();
	local player = null
	local witch = null
	local rock = null
	
	while(player = Entities.FindByClassname(player,"player")){
		if(player.GetZombieType != 9 && !player.IsDead() && !player.IsDying()){
			NetProps.SetPropInt(player, "m_Glow.m_iGlowType", 3)
			setInfectedGlowColor(player)
		}
		if(player.GetZombieType() == 9){
			player.SetReviveCount(2)
		}
	}
	while(witch = Entities.FindByClassname(witch, "witch")){
		if(witch.IsValid()){
			NetProps.SetPropInt(witch, "m_Glow.m_iGlowType", 3)
			setInfectedGlowColor(witch)
		}
	}
	while(rock = Entities.FindByClassname(rock, "tank_rock")){
		if(rock.IsValid()){
			NetProps.SetPropInt(rock, "m_Glow.m_iGlowType", 3)
			setInfectedGlowColor(rock)
		}
	}
}




// After a survivor gets a kill on any special or boss infected this should get called also
// ----------------------------------------------------------------------------------------------------------------------------

function stopLastChanceMode(){
	local player = null;
	local witch = null;
	local rock = null;
	while(player = Entities.FindByClassname(player, "player")){
		NetProps.SetPropInt(player, "m_Glow.m_iGlowType", 0)
		if(player.GetZombieType() == 9){
			player.SetReviveCount(1)
		}
	}
	while(witch = Entities.FindByClassname(witch, "witch")){
		NetProps.SetPropInt(witch, "m_Glow.m_iGlowType", 0)
	}
	while(rock = Entities.FindByClassname(rock, "tank_rock")){
		if(rock.IsValid()){
			NetProps.SetPropInt(rock, "m_Glow.m_iGlowType", 0)
		}
	}
}




// Called on mission_fail it will disable all infected glows of "last chance"
// ----------------------------------------------------------------------------------------------------------------------------

function disableInfectedGlows(){
	local player = null;
	local witch = null;
	while(player = Entities.FindByClassname(player, "player")){
		NetProps.SetPropInt(player, "m_Glow.m_iGlowType", 0)
	}
	while(witch = Entities.FindByClassname(witch, "witch")){
		NetProps.SetPropInt(witch, "m_Glow.m_iGlowType", 0)
	}
}




// Fade effect for entering the last chance vision
// ----------------------------------------------------------------------------------------------------------------------------

function whiteScreen(){
	foreach(player in GetSurvivors()){
		ScreenFade(player, 200, 200, 200, 255, 1, 0.5, 1)
	}
}




// Change infected glows in "last_chance_mode" depending on difficulty
// ----------------------------------------------------------------------------------------------------------------------------

function setInfectedGlowColor(inf){
	local vector = null;
	switch(Convars.GetStr("z_difficulty").tolower()){
		case "easy"			: vector = Vector(255,45,180);	break;
		case "normal"		: vector = Vector(0,255,0);		break;
		case "hard"			: vector = Vector(200,0,0);		break;
		case "impossible"	: vector = Vector(120,120,120);	break;
		default				: vector = Vector(165,0,255);	break;
	}
	local color = vector.x
	color += 256 * vector.y
	color += 65536 * vector.z
	NetProps.SetPropInt(inf, "m_Glow.m_glowColorOverride", color)
}




// Returns vector color as int
// ----------------------------------------------------------------------------------------------------------------------------

function GetColorInt(vector){
	local color = vector.x
	color += 256 * vector.y
	color += 65536 * vector.z
	return color
}





