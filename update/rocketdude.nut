//****************************************************************************************
//																						//
//									rocketDude.nut (mainfile)							//
//																						//
//****************************************************************************************

::rocketdude_version <- 1.3

::scriptDebug <- Convars.GetFloat("developer")

Msg("Activating RocketDude By ReneTM \n");

if ( !IsModelPrecached( "models/props_collectables/mushrooms_glowing.mdl" ) )
	PrecacheModel( "models/props_collectables/mushrooms_glowing.mdl" )

	
IncludeScript("rocketdude/rd_utils");
IncludeScript("rocketdude/rd_melee_getter");
IncludeScript("rocketdude/rd_director");
IncludeScript("rocketdude/rd_damage_controll");
IncludeScript("rocketdude/rd_detonation_analysis");
IncludeScript("rocketdude/rd_meds");
IncludeScript("rocketdude/rd_events");
IncludeScript("rocketdude/rd_last_chance");
IncludeScript("rocketdude/rd_decals");
IncludeScript("rocketdude/rd_map_specifics");
IncludeScript("rocketdude/rd_custom_map_support");




precacheAllSurvivorModels();

local grenadeData			= {}

local grenadeProperties		= {}

local useNonGravityRockets	= true
local physicsBlast			= true
local boost_ignore_incapped	= true
local allowBhop				= true
local preventLandingCrack	= true

L4D1SurvivorSet <- false




// Creates a bullet time when the previous one is atleast 32 seconds ago.
// When this condition is met bullet time will occur with a probability of 10% 
// ----------------------------------------------------------------------------------------------------------------------------

local lastBulletTime = Time()
local lastDiceTime = Time()

::GLOBALS <-
{
	allowBulletTime = true
}

function bulletTime(){

	if(GLOBALS.allowBulletTime){
		if(Time() > lastBulletTime + 32){
			if(Time() >= lastDiceTime + 2){
				if(rollDice(5)){
					lastBulletTime = Time()
					DoEntFire( "!self", "Start", "", 0, timeScaler, timeScaler )
					DoEntFire( "!self", "Stop", "", 1, timeScaler, timeScaler )
				}
				lastDiceTime = Time()
			}
		}
	}
}

function saveGlobals(){
	SaveTable("GLOBAL_SAVINGS", GLOBALS)
}

function restoreGlobals(){
	RestoreTable("GLOBAL_SAVINGS", GLOBALS)
}




// When an instance of a grenade launcher projectile stops existing "doRocketJump" gets called
// ----------------------------------------------------------------------------------------------------------------------------

function grenadeExplodeEvent( impact ){
	if(getSurvivorsInRange( impact ).len() > 0){
		foreach( player in getSurvivorsInRange( impact ) ){
			doRocketJump(impact, player)
		}	
	}
}




// Returns players within the blast radius
// ----------------------------------------------------------------------------------------------------------------------------

function getSurvivorsInRange(pos){
	local player = null;
	local players = []
	while(player = Entities.FindByClassnameWithin(player, "player", pos, 160)){
		if(!player.IsDead()){
			if(boost_ignore_incapped){
				if(!player.IsIncapacitated()){
					players.append(player)
				}
			}else{
				players.append(player)
			}
		}
	}
	return players
}




// Compares current position of a projectile with the previous one. Force it to explode when it got stuck on prop_dynamic
// ----------------------------------------------------------------------------------------------------------------------------

function grenadeIsStuck(pos1, pos2){
	if((pos1 - pos2).Length() < 1){
		return true
	}
	return false
}

function dynamicPropCheck(grenade){
	if(grenade in grenadeData){
		if(grenadeIsStuck(grenadeData[grenade], grenade.GetOrigin())){
			if(grenade.IsValid()){
				NetProps.SetPropInt(grenade, "m_takedamage", 1)
				grenade.TakeDamage(1337, 2, null)
			}
		}
	}
}




// Get's fired 'OnGameplayStart' (usually after every single loadingscreen)
// ----------------------------------------------------------------------------------------------------------------------------

function OnGameplayStart(){
	
	/* CREATE MUSHROOMS */
	if(IsValveMap())
	spawnMushrooms();

	/* SPAWN MAP SIDED MUSHROOMS */
	spawnMapSidedMushrooms();
	
	/* SET PLAYERS MAX HEALTH AND CURRENT HEALTH TO 200 */
	setPlayersHealth();
	
	/* GENERAL SETTINGS */
	setNeededCvars();
	killFixEntities();
	EntFire("worldspawn", "RunScriptCode", "killFixEntities()", 8)
	EntFire("worldspawn", "RunScriptCode", "killFixEntities()", 32)

	/* CREATE BULLET TIME */
	createBulletTimerEntity();

	/* KILL ALL DEATH CAMS */
	removeDeathFallCameras();
	
	/* CREATE THINK TIMER */
	createThinkTimer();

	/* DECIDES WHICH ROCK 2 USE */
	L4D1SurvivorSet = IsL4D1SurvivorSet()
	
	/* RESTORE SETTINGS LIKE BULLET TIME 1/0 */
	restoreGlobals()
}

::killFixEntities <- function(){
	EntFire( "anv_mapfixes*", "Kill" );
	EntFire( "env_player_blocker", "Kill" );
	EntFire( "rene_relay", "Trigger" );
	mapSpecifics();
}




// Called for every player within the detonation radius, it will launch the player in the calculated direction
// ----------------------------------------------------------------------------------------------------------------------------

function doRocketJump(detonationPos, player){

	local hitSurface = getSurfaceValue(detonationPos, player)
	local ignoreDistance = 160
	local playerEyes = player.EyePosition()
	local finalVector = null;
	
	local detonationDistance = (detonationPos - playerEyes).Length()
	local playerIsMidAir = NetProps.GetPropInt(player, "m_hGroundEntity") & 1
	local midAirFactor = 0
	local boostdirection = (detonationPos - playerEyes) * - 1
	local currentVelocityVector = player.GetVelocity()
	local eyeToSurface = ((detonationPos - playerEyes).Length())
	local distanceFactor = (160 - eyeToSurface) / 10
	
	// WALL OR FLOOR ?
	if(hitSurface == "WALL"){
		distanceFactor *= 1.5
	}else{
		distanceFactor *= 1.4
	}
	
	if(detonationDistance <= ignoreDistance){
		if(playerIsMidAir){
			midAirFactor = 1
			finalVector = (currentVelocityVector + boostdirection * midAirFactor * distanceFactor) 
		}else{
			midAirFactor = 0.5
			finalVector = (currentVelocityVector + boostdirection * midAirFactor * distanceFactor)
		}
		player.SetVelocity(finalVector)
	}
}



// This listener will fire "grenadeExplodeEvent" passing the last valid position
// of the grenade which is not existent anymore. Additionally it checks for stucked grenades
// Disallowed the rocket boost for bots.
// ----------------------------------------------------------------------------------------------------------------------------

function grenadeExplodeListener(){
	local grenade = null;
	while(grenade = Entities.FindByClassname(grenade, "grenade_launcher_projectile")){
		dynamicPropCheck(grenade)
		if(!IsPlayerABot(NetProps.GetPropEntity(grenade, "m_hThrower"))){
			grenadeData[grenade] <- grenade.GetOrigin()
		}
	}
	
	foreach(grenade,origin in grenadeData){
		if(!grenade.IsValid()){
			grenadeExplodeEvent(origin)
			grenadeData.rawdelete(grenade)
		}
	}
}




// If enabled, this will straighten the rockets so we end up with non gravity rockets like in TF2
// ----------------------------------------------------------------------------------------------------------------------------

function grenadeManipulator(){
	local grenade = null
	if(useNonGravityRockets){
		while(grenade = Entities.FindByClassname(grenade, "grenade_launcher_projectile")){
			if(!(grenade in grenadeProperties)){
				grenadeProperties[grenade] <- grenade.GetVelocity()
			}else{
				grenade.SetVelocity(grenadeProperties[grenade])
			}
		}
	}
}




// Disable player´s ledge hang, set his max health to 200 and disable fall damage crack
// ----------------------------------------------------------------------------------------------------------------------------

local PlayerSettingsCheckTime = Time()
function PlayerSettings(){
	if(Time() > PlayerSettingsCheckTime + 4){
		foreach(player in GetSurvivors()){
			DoEntFire("!self", "DisableLedgeHang", "", 1, player, player)
			if(preventLandingCrack){
				DoEntFire("!self", "ignorefalldamagewithoutreset", "10", 1, player, player)
			}
			if(NetProps.GetPropInt(player, "m_iMaxHealth") != 200){
				NetProps.SetPropInt(player, "m_iMaxHealth", 200)
			}
			PlayerSettingsCheckTime = Time()
		}
	}
}


function setPlayersHealth(){
	foreach(player in GetSurvivors()){
		NetProps.SetPropInt(player, "m_iMaxHealth", 200)
		NetProps.SetPropInt(player, "m_iHealth", 200)
	}
}




// Typing sv_cheats 1 on local server would result in every cheat flagged variable reset
// ----------------------------------------------------------------------------------------------------------------------------

local ServerSettingsCheckTime = Time()
function ServerSettings(){
	if(Time() > ServerSettingsCheckTime + 10){
		setNeededCvars()
		removeThrowables()
		ServerSettingsCheckTime = Time()
	}
}




// Remove any throwables from the map
// ----------------------------------------------------------------------------------------------------------------------------

function removeThrowables(){
	foreach(player in GetHumanSurvivors()){
		local invTable = {}
		GetInvTable(player, invTable)
		if("slot2" in invTable){
			invTable["slot2"].Kill();
		}
	}
	local throwables = ["weapon_molotov","weapon_vomitjar","weapon_pipe_bomb"]
	foreach(item in throwables){
		local ent = null;
		while(ent = Entities.FindByClassname(ent, item)){
			ent.Kill()
		}
	}
}




// Mushrooms will get reactivated every 10 seconds.
// ----------------------------------------------------------------------------------------------------------------------------

function updateMushroomTrigger(){
	foreach(trigger, table in medkit_data){
		if( Time() >= table.usetime + 10){
			if(table.usable == false){
				table.usetime = Time() - 10
				setMedVisibility(1, table.model)
				table.usable = true
				DoEntFire("!self", "TouchTest", "", 0, trigger, trigger)
			}
		}
	}
}




// Hold space for auto-bhop ( if enabled and player used atleast one mushroom )
// ----------------------------------------------------------------------------------------------------------------------------

::bunnyPlayers <- {}

function autobhop(){
	if(allowBhop){
		foreach(player in GetHumanSurvivors())
		{
			if(player in bunnyPlayers)
			{
				if(!(NetProps.GetPropInt(player, "m_fFlags") & 1) && NetProps.GetPropInt(player, "movetype") == 2)
				{
					if(player.GetButtonMask() & 2)
					{
						player.OverrideFriction(0.033, 0)
					}
					NetProps.SetPropInt(player, "m_afButtonDisabled", NetProps.GetPropInt(player, "m_afButtonDisabled") | 2)
				} 
				else
				{
					NetProps.SetPropInt(player, "m_afButtonDisabled", NetProps.GetPropInt(player, "m_afButtonDisabled") & ~2)
				}
			}
		}
	}
}




// Giant grenade_launcher_projectiles with custom skin and fire attached ? There you go
// ----------------------------------------------------------------------------------------------------------------------------

local grenadeColor = GetColorInt(Vector(64,64,64))
local grenadeGlowColor = GetColorInt(Vector(255,16,16))

if(!IsModelPrecached("models/w_models/weapons/w_rd_grenade_scale_x4_burn.mdl")){
	PrecacheModel("models/w_models/weapons/w_rd_grenade_scale_x4_burn.mdl")
}

if(!IsModelPrecached("models/w_models/weapons/w_rd_grenade_scale_x4.mdl")){
	PrecacheModel("models/w_models/weapons/w_rd_grenade_scale_x4.mdl")
}

function grenadeCustomizer(){
	local nade = null;
	while(nade = Entities.FindByClassname(nade, "grenade_launcher_projectile")){
		nade.ValidateScriptScope()
		local scope = nade.GetScriptScope()
		
		// Change projectile model and color
		if(!("modelChanged" in scope)){
			if(NetProps.GetPropEntity(nade, "m_hThrower") in bunnyPlayers){
				nade.SetModel("models/w_models/weapons/w_rd_grenade_scale_x4_burn.mdl")
			}else{
				nade.SetModel("models/w_models/weapons/w_rd_grenade_scale_x4.mdl")
			}
			NetProps.SetPropInt(nade, "m_clrRender", grenadeColor)
			scope["modelChanged"] <- true
		}
		
		if(!("creationTimestamp" in scope)){
			scope["creationTimestamp"] <- Time()
		}
		
		// Enable glows for projectile when the m_hThrower used a mushroom already
		if(Time() > scope["creationTimestamp"] + 0.12){
			if(!("glowEnabled" in scope)){
				if(NetProps.GetPropEntity(nade, "m_hThrower") in bunnyPlayers){
					NetProps.SetPropInt(nade, "m_Glow.m_glowColorOverride", grenadeGlowColor)
					NetProps.SetPropInt(nade, "m_Glow.m_nGlowRangeMin", 32)
					NetProps.SetPropInt(nade, "m_Glow.m_nGlowRange", 8192)
					NetProps.SetPropInt(nade, "m_Glow.m_iGlowType", 3)
					NetProps.SetPropInt(nade, "m_Glow.m_bFlashing", 1)
					scope["glowEnabled"] <- true
				}
			}
		}
	}	
}




// Get's fired every tick from a timer
// ----------------------------------------------------------------------------------------------------------------------------

function Think(){
	grenadeExplodeListener()
	grenadeManipulator()
	PlayerSettings()
	ServerSettings()
	updateMushroomTrigger()
	autobhop()
	playerOnGroundCounter()
	survivorSaferoomCheck()
	lastChanceCountDown()
	grenadeCustomizer()
	setTankRockModel()
	lastChanceRockListener()
}



