//****************************************************************************************
//																						//
//										rd_utils.nut									//
//																						//
//****************************************************************************************


getroottable()["TRACE_MASK_ALL"] <- -1
getroottable()["TRACE_MASK_SHOT"] <- 1174421507
getroottable()["TRACE_MASK_VISION"] <- 33579073
getroottable()["TRACE_MASK_NPC_SOLID"] <- 33701899
getroottable()["TRACE_MASK_PLAYER_SOLID"] <- 33636363
getroottable()["TRACE_MASK_VISIBLE_AND_NPCS"] <- 33579137


getroottable()["WHITE"]		<- "\x01"
getroottable()["BLUE"]		<- "\x03"
getroottable()["ORANGE"]	<- "\x04"
getroottable()["GREEN"]		<- "\x05"




// Creates the think timer which calls "Think()" every tick
// ----------------------------------------------------------------------------------------------------------------------------

function createThinkTimer(){
	local timer = null;
	while (timer = Entities.FindByName(null, "thinkTimer")){
		timer.Kill()
	}
	timer = SpawnEntityFromTable("logic_timer", { targetname = "thinkTimer", RefireTime = 0.01 })
	timer.ValidateScriptScope()
	timer.GetScriptScope()["scope"] <- this

	timer.GetScriptScope()["func"] <- function (){
		scope.Think()
	}
	timer.ConnectOutput("OnTimer", "func")
	EntFire("!self", "Enable", null, 0, timer)
}




// Remove all deathcams e.g on c8m5_rooftop
// ----------------------------------------------------------------------------------------------------------------------------

function removeDeathFallCameras(){
	local deathCam = null;
	while (deathCam = Entities.FindByClassname(deathCam, "point_deathfall_camera")){
		deathCam.Kill()
	}
}




// All needed cvars
// ----------------------------------------------------------------------------------------------------------------------------

function setNeededCvars(){
	//Survivor settings
	Convars.SetValue("survivor_allow_crawling", 1)
	Convars.SetValue("sv_infinite_ammo", 1)
	Convars.SetValue("first_aid_kit_max_heal", 200)
	Convars.SetValue("survivor_respawn_with_guns", 2)
	Convars.SetValue("first_aid_heal_percent", 0.8)
	Convars.SetValue("z_grab_ledges_solo", 1)
	Convars.SetValue("z_tank_incapacitated_decay_rate", 5)
	//Grenadelauncher settings
	Convars.SetValue("grenadelauncher_velocity", 1100)
	Convars.SetValue("grenadelauncher_startpos_right", 0)
	Convars.SetValue("grenadelauncher_startpos_forward", 16)
	Convars.SetValue("grenadelauncher_vel_variance", 0)
	Convars.SetValue("grenadelauncher_vel_up", 0)
	//Force settings
	Convars.SetValue("phys_explosion_force", 4096)
	Convars.SetValue("melee_force_scalar", 16)
	Convars.SetValue("melee_force_scalar_combat_character", 512)
	Convars.SetValue("phys_pushscale", 512)
	//Infected settings
	Convars.SetValue("z_force_attack_from_sound_range", 512)
	Convars.SetValue("z_brawl_chance", 1)
	//Medicals
	Convars.SetValue("pain_pills_health_threshold", 199)
	Convars.SetValue("pain_pills_health_value", 100)
	//Items
	Convars.SetValue("sv_infected_riot_control_tonfa_probability", 0)
	Convars.SetValue("sv_infected_ceda_vomitjar_probability", 0)
	//Votes
	Convars.SetValue("sv_vote_creation_timer", 8)
	Convars.SetValue("sv_vote_plr_map_limit", 128)
	//
	Convars.SetValue("z_spawn_flow_limit", 99999)
	Convars.SetValue("director_afk_timeout", 99999)
	Convars.SetValue("mp_allowspectators", 0)
}




// Create a func_timescale entity for the "bullet time"
// ----------------------------------------------------------------------------------------------------------------------------

timeScaler <- null
function createBulletTimerEntity(){
	while (timeScaler = Entities.FindByName(null, "timeScaler")){
		timeScaler.Kill()
	}
	timeScaler = SpawnEntityFromTable("func_timescale",
		{
			targetname = "timeScaler"
			acceleration = 0.05
			angles = "0 0 0"
			origin = Vector(0, 0, 0)
			blendDataMultiplier = 3.0
			minBlendRate = 0.1
			desiredTimescale = 0.25
		}
	)
}




// We roll a dice with probability of X to decide if event Y will occur 
// ----------------------------------------------------------------------------------------------------------------------------

function rollDice(probability){
	local roll = RandomInt(1, 100)
	
	if(probability == 100){
		return true
	}else if(roll <= probability){
		return true
	}
	return false
}




// Returns the closest survivor in any radius
// ----------------------------------------------------------------------------------------------------------------------------

function getClosestSurvivorTo(ent){
	local survivor = null;
	local previousDistance = 0.0
	local closest = null;
	local currentDistance = null
	
	foreach(survivor in GetSurvivors()){
		if(survivor != ent){
			if(previousDistance == 0.0){
				previousDistance = (ent.GetOrigin() - survivor.GetOrigin()).Length()
				closest = survivor;
			}else{
				currentDistance = (ent.GetOrigin() - survivor.GetOrigin()).Length()
				if(currentDistance < previousDistance){
					previousDistance = currentDistance
					closest = survivor;
				}
			}
		}
	}
	return closest;
}




// Returns true if the survivor is near to a info_survivor_rescue ( used for teleport players who join mid-game )
// ----------------------------------------------------------------------------------------------------------------------------

function isNearRescueCloset(ent){
	local rescueEnt = Entities.FindByClassnameWithin(null, "info_survivor_rescue", ent.GetOrigin(), 128)
	if(rescueEnt == null){
		return false
	}
	return true
}




// Returns array of all players (bots included)
// ----------------------------------------------------------------------------------------------------------------------------

function GetSurvivors(){
	local player = null;
	local players = []
	while (player = Entities.FindByClassname(player, "player")){
		if (player.GetZombieType() == 9){
			players.append(player)
		}
	}
	return players
}


// Returns array of all players (bots excluded)
// ----------------------------------------------------------------------------------------------------------------------------

function GetHumanSurvivors(){
	local player = null;
	local players = []
	while (player = Entities.FindByClassname(player, "player")){
		if (player.GetZombieType() == 9 && !IsPlayerABot(player)){
			players.append(player)
		}
	}
	return players
}




// Precache survivor models so game wont crash due to the "cm_NoSurvivorBots = 1" bug...Valve please fix
// ----------------------------------------------------------------------------------------------------------------------------

function precacheAllSurvivorModels(){
	local survivorModelNames =
		[
			// L4D2
			"survivor_coach.mdl", "survivor_gambler.mdl", "survivor_manager.mdl", "survivor_mechanic.mdl",
			// L4D1
			"survivor_namvet.mdl", "survivor_biker.mdl", "survivor_producer.mdl", "survivor_teenangst.mdl"
		]

	foreach(model in survivorModelNames){
		if (!IsModelPrecached("models/survivors/" + model)){
			PrecacheModel("models/survivors/" + model)
		}
	}
}




// Check if the current map is a valve map
// ----------------------------------------------------------------------------------------------------------------------------

::IsValveMap <- function(){
	local currentMap = Director.GetMapName().tolower()
	local valveMaps =
		[
			// DEAD CENTER
			"c1m1_hotel",
			"c1m2_streets",
			"c1m3_mall",
			"c1m4_atrium",
			// DARK CARNIVAL
			"c2m1_highway",
			"c2m2_fairgrounds",
			"c2m3_coaster",
			"c2m4_barns",
			"c2m5_concert",
			// SWAMP FEVER
			"c3m1_plankcountry",
			"c3m2_swamp",
			"c3m3_shantytown",
			"c3m4_plantation",
			// HARD RAIN
			"c4m1_milltown_a",
			"c4m2_sugarmill_a",
			"c4m3_sugarmill_b",
			"c4m4_milltown_b",
			"c4m5_milltown_escape",
			// THE PARISH
			"c5m1_waterfront",
			"c5m1_waterfront_sndscape",
			"c5m2_park",
			"c5m3_cemetery",
			"c5m4_quarter",
			"c5m5_bridge",
			// THE PASSING
			"c6m1_riverbank",
			"c6m2_bedlam",
			"c6m3_port",
			// THE SACRIFICE
			"c7m1_docks",
			"c7m2_barge",
			"c7m3_port",
			// NO MERCY
			"c8m1_apartment",
			"c8m2_subway",
			"c8m3_sewers",
			"c8m4_interior",
			"c8m5_rooftop",
			// CRASH COURSE
			"c9m1_alleys",
			"c9m2_lots",
			// DEATH TOLL
			"c10m1_caves",
			"c10m2_drainage",
			"c10m3_ranchhouse",
			"c10m4_mainstreet",
			"c10m5_houseboat",
			// DEAD AIR
			"c11m1_greenhouse",
			"c11m2_offices",
			"c11m3_garage",
			"c11m4_terminal",
			"c11m5_runway",
			// BLOOD HARVEST
			"c12m1_hilltop",
			"c12m2_traintunnel",
			"c12m3_bridge",
			"c12m4_barn",
			"c12m5_cornfield",
			// COLD STREAM
			"c13m1_alpinecreek",
			"c13m2_southpinestream",
			"c13m3_memorialbridge",
			"c13m4_cutthroatcreek",
			// THE LAST STAND
			"c14m1_junkyard",
			"c14m2_lighthouse"
		]
	if (valveMaps.find(currentMap) == null){
		return false
	}
	return true
}


// Mushroom positions of maps ( c1 -14 )
// ----------------------------------------------------------------------------------------------------------------------------

::mushroomPositions <-
{
	c1m1_hotel =
	[
		[Vector(2480.381, 6217.598, 2656.031), "tiny"],
		[Vector(2311.68,7656.3,2464.03), "small"],
		[Vector(1924.48,5762.97,1336.03), "medium"],
		[Vector(540.982, 4832.06, 1320.03), "large"],
		
	],
	c1m2_streets =
	[
		[Vector(-1253.71,777.393,811.381), "tiny"],
		[Vector(-5343.9,-2082.83,456.031), "tiny"],
		[Vector(-8619.01,-2111.07,963.138), "tiny"],
		[Vector(-7171.31,-4490.4,1224.7), "tiny"],
		[Vector(1059.617, 4854.105, 704.031), "small"],
		[Vector(1598.726, 4225.023, 521.433), "small"],
		[Vector(-2223.24, 982.305, 41.8048), "small"],
		[Vector(-4588.864, 1475.420, 440.031), "medium"],
		[Vector(-6132.59, -1135.09, 472.031), "medium"],
		[Vector(-8635.88, -4498.73, 440.031), "large"]
	],
	c1m3_mall =
	[
		[Vector(3600.03,-2384.03,825.031), "tiny"],
		[Vector(4008.45,-290.606,0.03125), "tiny"],
		[Vector(2266.34,-1561.81,536.031), "tiny"],
		[Vector(-198.189,-5201.84,415.031), "tiny"],
		[Vector(-1891.39,-4127.36,574.433), "tiny"],
		[Vector(6997.87, -1362.59, 152.031), "small"],
		[Vector(3896.59, -2873.28, 318.958), "small"],
		[Vector(2754.07, -1866.65, 280.031), "small"],
		[Vector(2414.66, -2412.11, 536.031), "medium"],
		[Vector(1584.63, -5446.67, 364.031), "medium"],
		[Vector(-1239.21, -4472.65, 318.958), "large"],
	],
	c1m4_atrium =
	[
		[Vector(-2572.11,-5303.06,553.52), "tiny"],
		[Vector(-6031.35,-3306.58,792.031), "tiny"],
		[Vector(-3340.16, -4001.26, 744.781), "small"],
		[Vector(-5103.33, -3918.44, 408.031), "small"],
		[Vector(-4451.52, -3207.95, 106.031), "medium"],
		[Vector(-3209.12, -3865.85, 107.617), "large"],
		[Vector(-5343.23, -4186.55, 1080.03), "large"]
	],
	c2m1_highway =
	[
		[Vector(3462.18,8450.17,-843.079), "tiny"],
		[Vector(-1168.83,2091.84,-1738.7), "tiny"],
		[Vector(6915.73, 7505.84, -675.791), "small"],
		[Vector(3015.77, 6931.89, -899.608), "small"],
		[Vector(2273.79, 4287.25, -936.719), "medium"],
		[Vector(2914.95, 4895.79, -507.969), "medium"],
		[Vector(1163.45, 2193.78, -1213.73), "large"],
		[Vector(-1334.14, -2035.05, -510.97), "large"]
	],
	c2m2_fairgrounds =
	[
		[Vector(1576.99,1513.79,8.03125), "tiny"],
		[Vector(-3329.16,-4239.81,352.595), "tiny"],
		[Vector(2710.8, 516.643, 200.031), "small"],
		[Vector(3962.74, -431.439, 50.0823), "small"],
		[Vector(-2126.08, 318.905, 128.031), "medium"],
		[Vector(-874.256, -1539.82, 128.031), "medium"],
		[Vector(-1493.91, -4415.5, -1.77925), "large"]
	],
	c2m3_coaster =
	[
		[Vector(2797.84,1638.93,-35.5456), "tiny"],
		[Vector(-3968.39,1550.79,413.031), "tiny"],
		[Vector(2048.36, 3296.04, 196.031), "small"],
		[Vector(-66.8414, 3611.93, 208.031), "small"],
		[Vector(-2754.75, 1143.2, 620.031), "medium"],
		[Vector(-3743.81, 3732.83, 544.031), "large"]
	],
	c2m4_barns =
	[
		[Vector(3138.24,3629.02,-3.96875), "tiny"],
		[Vector(-999.771,1962.43,-33.8993), "tiny"],
		[Vector(2166.15, 1419.64, 18.4938), "small"],
		[Vector(-226.231, 886.084, 387.031), "small"],
		[Vector(-1918.83, 95.4541, 32.0313), "medium"],
		[Vector(-3042.29, 1694.38, -255.969), "large"]
	],
	c2m5_concert =
	[
		[Vector(-2091.92,2406.35,-255.969), "tiny"],
		[Vector(-2637.91, 3340.46, 312.678), "small"],
		[Vector(-448.975, 2760.9, -255.969), "tiny"],
		[Vector(-1979.98, 2505.26, 191.031), "medium"],
		[Vector(-2679.04, 2500.67, 191.031), "large"]
	],
	c3m1_plankcountry =
	[
		[Vector(-10586.4,10170.8,571.008), "tiny"],
		[Vector(-8121.03, 7213.5, 266.604), "tiny"],
		[Vector(-5392.27, 5891.52, 256.034), "small"],
		[Vector(-6212.27, 7861.63, 48.0313), "small"],
		[Vector(-3386.78, 6069.38, 698.369), "medium"],
		[Vector(-2186.78, 8556.16, 208.552), "large"],
		[Vector(-1022.87, 4946.13, 332.031), "large"]
	],
	c3m2_swamp =
	[
		[Vector(1936.43,1250.89,19.2292), "tiny"],
		[Vector(7614.55,3192.79,122.329), "tiny"],
		[Vector(-8114.13, 5131.93, 295.391), "small"],
		[Vector(-1895.61, 3104.54, 226.169), "small"],
		[Vector(41.1561, 3076.97, 11.5583), "medium"],
		[Vector(4779.86, 1102.69, 41.265), "medium"],
		[Vector(8702.53, 512.321, 569.088), "large"]
	],
	c3m3_shantytown =
	[
		[Vector(-4605.58,-236.376,181.425), "tiny"],
		[Vector(1532.24,-4869.25,24.0313), "tiny"],
		[Vector(-5293.03, 1199.51, 871.913), "small"],
		[Vector(-2651.48, -931.619, 74.849), "medium"],
		[Vector(-5504.8, -3256.66, 308.68), "medium"],
		[Vector(3013.28, -4477.09, 86.1035), "large"]
	],
	c3m4_plantation =
	[
		[Vector(2743.47,-3207.78,65.3052), "tiny"],
		[Vector(3040.81,2016.1,133.507), "tiny"],
		[Vector(-3650.61, -1527.09, 542.849), "small"],
		[Vector(-1426.21, -3443.73, 187.907), "medium"],
		[Vector(1665.04, 536.081, 640.031), "medium"],
		[Vector(1867.68, -138.64, 600.031), "large"]
	],
	c4m1_milltown_a =
	[
		[Vector(-1547.58,6908.92,200.773), "tiny"],
		[Vector(4152.82,1222.7,184.031), "tiny"],
		[Vector(-5801.77, 7494.31, 1009.75), "small"],
		[Vector(-609.475, 6187.33, 296.031), "small"],
		[Vector(1482.28, 4149.37, 435.32), "medium"],
		[Vector(3617.5, 2161.08, 368.155), "medium"],
		[Vector(3338.04, 179.84, 586.974), "large"]
	],
	c4m2_sugarmill_a =
	[
		[Vector(4315.07,-4528.41,97.6315), "tiny"],
		[Vector(-10.6827,-12670.2,113.272), "tiny"],
		[Vector(3212.06, -3036.58, 1164.28), "small"],
		[Vector(2725.17, -4272.82, 329.469), "small"],
		[Vector(2581.79, -6098.72, 100.829), "medium"],
		[Vector(-345.992, -8559.92, 624.281), "small"],
		[Vector(-1507.19, -13161, 1141.23), "large"]
	],
	c4m3_sugarmill_b =
	[
		[Vector(2587.19,-6096.47,100.157), "tiny"],
		[Vector(4114.54,-3217.8,406.265), "tiny"],
		[Vector(-925.624, -13530.8, 432.031), "small"],
		[Vector(-1106.24, -8463.68, 624.031), "small"],
		[Vector(936.826, -6244.9, 638.807), "medium"],
		[Vector(430.224, -4582.72, 310.428), "medium"],
		[Vector(1741.85, -3929.74, 737.02), "large"]
	],
	c4m4_milltown_b =
	[
		[Vector(3331.17,-847.188,586.974), "tiny"],
		[Vector(387.227,3489.37,336.38), "tiny"],
		[Vector(4327.79, 1780.41, 363.761), "small"],
		[Vector(673.109, 4776.85, 131.802), "medium"],
		[Vector(-1486.32, 7441.23, 366.277), "large"]
	],
	c4m5_milltown_escape =
	[
		[Vector(-5315.37,8567.07,584.038), "tiny"],
		[Vector(-7088.42,7698.42,113.924), "small"],
		[Vector(-5815.44, 6623.25, 126.972), "medium"],
		[Vector(-5801.8, 7496.52, 1009.75), "large"]
	],
	c5m1_waterfront =
	[
		[Vector(-561.684, -137.842, -55.9688), "tiny"],
		[Vector(-1904.66,-1864.33,-71.9454), "small"],
		[Vector(-3068.68, -2336.01, -157.992), "medium"]
	],
	c5m2_park =
	[
		[Vector(-5054.91, -2216.52, -127.982), "tiny"],
		[Vector(-7166.92, -3491.44, 44.5587), "small"],
		[Vector(-8789.87, -5193.33, 89.7595), "medium"],
		[Vector(-8113.72, -5774.25, 485.766), "medium"],
		[Vector(-6815.91, -8437.09, 250.906), "large"]
	],
	c5m3_cemetery =
	[
		[Vector(6127.99, 7700.52, 208.031), "tiny"],
		[Vector(4432.79, 3202.69, 154.031), "small"],
		[Vector(6189.01, 1337.86, -159.969), "medium"],
		[Vector(8768.77, -6591.84, 756.031), "medium"],
		[Vector(7417.2, -8926.28, 264.031), "large"]
	],
	c5m4_quarter =
	[
		[Vector(-3650.66, 3888.94, 384.031), "tiny"],
		[Vector(29.7625,-1607.78,287.837), "small"],
		[Vector(-1193.22, 1488.05, 452.401), "medium"],
		[Vector(-813.288, -2031.78, 422.465), "large"]
	],
	c5m5_bridge =
	[
		[Vector(-12334.9, 6552.2, 453.565), "tiny"],
		[Vector(-6151.38, 6420.53, 765.699), "small"],
		[Vector(2290.68, 6425.58, 790.031), "medium"],
		[Vector(14201, 6326.86, 790.031), "large"]
	],
	c6m1_riverbank =
	[
		[Vector(669.412, 3116.3, 640.031), "tiny"],
		[Vector(4461.7, 2397.54, 224.031), "small"],
		[Vector(-4004.19, 554.621, 864.031), "medium"],
		[Vector(-4223.99, 1571.49, 727.091), "large"]
	],
	c6m2_bedlam =
	[
		[Vector(2148.07, -1201.23, 288.031), "tiny"],
		[Vector(1213.93, 1966.51, 336.031), "small"],
		[Vector(998.689, 2701.23, 96.0313), "medium"],
		[Vector(1589.86, 4615.77, 32.0313), "medium"],
		[Vector(2868.05, 5702.03, -1063.97), "large"],
		[Vector(5883.71, 4207.33, -890.867), "large"]
	],
	c6m3_port =
	[
		[Vector(345.633, -358.962, 184.031), "small"]
	],
	c7m1_docks =
	[
		[Vector(12001.8, -787.905, -35.1111), "tiny"],
		[Vector(5208.64, 552.395, 382.031), "small"],
		[Vector(4679.74, 764.071, 303.384), "small"],
		[Vector(2516.95,-188.518,138.451), "medium"],
		[Vector(3404.88, 1676.66, 336.031), "large"]
	],
	c7m2_barge =
	[
		[Vector(5435.93,755.192,256.282), "small"],
		[Vector(10062.7, 2095.96, 305.796), "tiny"],
		[Vector(8590.49, 155.998, 577.666), "small"],
		[Vector(5435.93,755.192,256.282), "small"],
		[Vector(-593.486, 2559.1, 756.694), "medium"],
		[Vector(-2894.79, 725.009, 576.031), "large"]
	],
	c7m3_port =
	[
		[Vector(-938.757,931.624,352.031), "tiny"],
		[Vector(736.739, 2264.6, 640.031), "small"],
		[Vector(1560.46, 168.305, 345.56), "large"]
	],
	c8m1_apartment =
	[
		[Vector(334.88, 767.923, 957.29), "small"],
		[Vector(2624.62, 2212.92, 945.241), "medium"],
		[Vector(1976.26, 3944.68, 608.031), "large"],
		[Vector(3493.26,4004.85,1436.03), "tiny"]
	],
	c8m2_subway =
	[
		[Vector(2204.75, 3968.89, -335.969), "tiny"],
		[Vector(6775.15, 2899.15, -178.67), "small"],
		[Vector(7567.9, 3417.3, 424.031), "small"],
		[Vector(8328.45, 4596.1, 1216.03), "medium"],
		[Vector(8805.87, 5685.34, 768.031), "large"]
	],
	c8m3_sewers =
	[
		[Vector(11203.7, 5091.59, 712.031), "tiny"],
		[Vector(12712.9, 6696.47, 800.031), "tiny"],
		[Vector(11852.1, 7923.79, 276.031), "small"],
		[Vector(13711, 10120.7, -358.28), "small"],
		[Vector(13068.6, 10985.1, -191.969), "medium"],
		[Vector(13070.8, 11448, -277.217), "medium"],
		[Vector(13788.6, 11101.2, 746.031), "large"],
		[Vector(13198.7, 13927.2, 5624.03), "large"]
	],
	c8m4_interior =
	[
		[Vector(12314.1, 13388.4, 152.031), "small"],
		[Vector(13439.6, 15006.3, 624.031), "medium"],
		[Vector(14045.5, 14862.1, 5920.03), "large"]
	],
	c8m5_rooftop =
	[
		[Vector(7048.08, 9024.08, 6096.03), "tiny"],
		[Vector(6960.91,9464.52,5644.03), "small"],
		[Vector(7022.35,7746.25,16.0313), "medium"],
		[Vector(7714.38, 9340.58, 5952.03), "large"]
	],
	c9m1_alleys =
	[
		[Vector(-7876.03,-10448,192.031), "tiny"],
		[Vector(-8671.74, -9921.56, 384.031), "small"],
		[Vector(-2692.39, -9362.13, 362.682), "medium"],
		[Vector(-1326.74, -3292.39, 445.932), "large"]
	],
	c9m2_lots =
	[
		[Vector(3568.14, -492.286, 35.807), "small"],
		[Vector(1761.86, 218.214, 45.0175), "medium"],
		[Vector(7843.74, 6713.64, 376.036), "large"]
	],
	c10m1_caves =
	[
		[Vector(-11659.9, -13385.5, 554.054), "tiny"],
		[Vector(-12349.5, -9805.34, 496.031), "small"],
		[Vector(-12974.9, -5860.65, 176.031), "medium"],
		[Vector(-10690.6, -4991.48, 688.028), "large"]
	],
	c10m2_drainage =
	[
		[Vector(-10213.5, -8154.52, -162.483), "tiny"],
		[Vector(-9872.4, -6733.67, -307.969), "small"],
		[Vector(-7846.5, -6987.36, -457.214), "medium"],
		[Vector(-8826.14, -7633.1, 953.457), "large"]
	],
	c10m3_ranchhouse =
	[
		[Vector(-8059.92, -5811.83, 400.031), "tiny"],
		[Vector(-10367.7, -6505.36, 584.665), "small"],
		[Vector(-9092.79, -3946.72, 356.642), "medium"],
		[Vector(-5081.95, -1693.59, 626.119), "large"]
	],
	c10m4_mainstreet =
	[
		[Vector(-3068.25, -57.6381, 1039.03), "tiny"],
		[Vector(2756.35, -2412.78, 336.031), "small"],
		[Vector(1617.19, -4384.35, 96.0313), "medium"],
		[Vector(-673.274, -4583.52, 176.031), "medium"],
		[Vector(-1399.49, -4674.15, 192.031), "large"]
	],
	c10m5_houseboat =
	[
		[Vector(3770.44,252.689,-179.969), "tiny"],
		[Vector(3854.66, 4218.71, 320.031), "small"],
		[Vector(4264.85, -4686.83, 231.018), "medium"],
		[Vector(2195.19, -4720.26, -35.1493), "large"]
	],
	c11m1_greenhouse =
	[
		[Vector(2910.57,2108.9,416.535), "small"],
		[Vector(4351.72, -300.349, 1116.8), "medium"],
		[Vector(3394.22, -871.949, 1029.47), "large"]
	]
	c11m2_offices =
	[
		[Vector(6272.13,1022.59,16.0313), "small"],
		[Vector(5447.53, 3558.41, 303.983), "medium"],
		[Vector(6623.48, 4828.47, 600.482), "large"]
	],
	c11m3_garage =
	[
		[Vector(-4952.03, -2623.2, 352.031), "tiny"],
		[Vector(-7206, -2165.78, 536.031), "tiny"],
		[Vector(-6805.34, -1273.95, 550.072), "small"],
		[Vector(-5239.47, 124.543, 1301.27), "medium"],
		[Vector(-2881.81, 3153.91, 160.031), "large"]
	],
	c11m4_terminal =
	[
		[Vector(541.737, 3785.52, 536.031), "tiny"],
		[Vector(-142.605, 5253.46, 512.031), "tiny"],
		[Vector(471.801, 2959.14, 348.031), "small"],
		[Vector(2130.92, 1586.85, 448.031), "medium"],
		[Vector(2780.61, 6941.86, 313.031), "large"]
	],
	c11m5_runway =
	[
		[Vector(-5795.82, 9010.43, 176.974), "large"]
	],
	c12m1_hilltop =
	[
		[Vector(-9851.16, -14544.8, 1161.37), "tiny"],
		[Vector(-10980.1, -10901.5, 938.975), "small"],
		[Vector(-8990.35, -8981.87, 1062.03), "medium"],
		[Vector(-7808.35, -9486.53, 992.031), "large"]
	],
	c12m2_traintunnel =
	[
		[Vector(-8740.09, -7214.79, 200.031), "tiny"],
		[Vector(-8547.49, -8900.32, 304.031), "small"],
		[Vector(-7563.7, -8612.52, 826.025), "medium"],
		[Vector(-4185.79, -8717.72, 232.031), "large"]
	],
	c12m3_bridge =
	[
		[Vector(-952.414, -10439.4, 72.0312), "tiny"],
		[Vector(-1137.81, -10944.3, 160.031), "tiny"],
		[Vector(-652.769, -10765, 696.938), "small"],
		[Vector(3342.01, -14299.5, 169.088), "small"],
		[Vector(4914.05, -13113.9, 1141.33), "medium"],
		[Vector(5932.44, -13851.9, 272.05), "large"]
	],
	c12m4_barn =
	[
		[Vector(7488.13, -10687, 897.565), "tiny"],
		[Vector(9334.13, -9355.23, 932.537), "tiny"],
		[Vector(10879.7, -9053.31, 356.031), "small"],
		[Vector(10616.6, -7429.15, 274.641), "small"],
		[Vector(9688.78, -4243.98, 722.381), "medium"],
		[Vector(10453.7, -1712.4, 268.031), "large"]

	],
	c12m5_cornfield =
	[
		[Vector(10059.6, 821.12, 462.47), "tiny"],
		[Vector(9272.22, 3547.45, 961.057), "tiny"],
		[Vector(8446.37, 422.173, 590.031), "small"],
		[Vector(7138.16, 270.204, 596.031), "small"],
		[Vector(6823.95, 1191.26, 794.031), "medium"],
		[Vector(7186.65, 2650.19, 1034.12), "medium"],
		[Vector(7536.12, 2649.97, 1034.12), "large"],
		[Vector(5877.17, 2103.69, 818.275), "large"]
	],
	c13m1_alpinecreek =
	[
		[Vector(-3727.92, 664.31, 560.254), "tiny"],
		[Vector(-2876.72, 2797.21, 1273), "tiny"],
		[Vector(-2332, 3247.16, 976.031), "small"],
		[Vector(869.342, 2451.07, 805.031), "medium"],
		[Vector(1274.75, 20.8816, 1872.35), "large"],
		[Vector(880.042, -464, 476.011), "large"]
	],
	c13m2_southpinestream =
	[
		[Vector(7961.18, 6390.28, 585.92), "tiny"],
		[Vector(8107.63, 4172.91, 649.555), "tiny"],
		[Vector(6728, 2925.41, 1216.03), "small"],
		[Vector(5677.56, 2211.83, 1090.001), "small"],
		[Vector(4905.09, 2577.37, 1120.03), "medium"],
		[Vector(-356.712, 4977.07, 272.031), "medium"],
		[Vector(-348.279, 6151.25, 302.031), "large"],
		[Vector(79.0006, 8900.59, -276.969), "large"]
	],
	c13m3_memorialbridge =
	[
		[Vector(-2167.36, -4083.3, 896.031), "tiny"],
		[Vector(-3844.47, -4095.34, 896.031), "tiny"],
		[Vector(-2169.22, -4042.35, 1758.03), "small"],
		[Vector(-2169.54, -4092.02, 2201.03), "small"],
		[Vector(3687.47, -4074.24, 2201.03), "medium"],
		[Vector(3686.79, -4095.17, 896.031), "large"]
	],
	c13m4_cutthroatcreek =
	[
		[Vector(-3593.93, -8513.88, 723.031), "tiny"],
		[Vector(-3622.38, -5926.86, 623.746), "tiny"],
		[Vector(-3916.44, -3227.55, 360.898), "small"],
		[Vector(-664.339, -49.0258, -36.4243), "small"],
		[Vector(-653.084, 1568.25, 18.0313), "medium"],
		[Vector(-391.136, 3752.91, 88.0313), "large"],
		[Vector(-1272.03, 5613.55, 26.7287), "large"]
	],
	c14m1_junkyard =
	[
		[Vector(-4227.94, -8819.65, 103), "tiny"], 
		[Vector(-1343.4,-2300.03,593.922), "small"],
		[Vector(-2676.9,2190.812,-50.752), "small"],
		[Vector(-5723.82,5214.3,446.163), "medium"],
		[Vector(-2407,7408.93,168.031), "large"]
	],
	c14m2_lighthouse = 
	[
		[Vector(1319.83,344.463,830.588), "tiny"],
		[Vector(479.378,946.381,696.031), "small"],
		[Vector(-981.672,2524.87,701.112), "medium"],
		[Vector(-4725.000, 5825.000, -92.968), "large"]
	]
}


// Returns the slot the weapon belongs to
// ----------------------------------------------------------------------------------------------------------------------------

function getItemSlot(item){
	local className = item.GetClassname()
	
	local slot0 =
	[
		"weapon_grenade_launcher","weapon_rifle_m60",
		"weapon_rifle","weapon_rifle_desert","weapon_rifle_ak47",
		"weapon_rifle_sg552","weapon_smg_mp5",
		"weapon_shotgun_chrome","weapon_pumpshotgun",
		"weapon_shotgun_spas","weapon_autoshotgun",
		"weapon_smg","weapon_smg_silenced",
		"weapon_hunting_rifle","weapon_sniper_military",
		"weapon_sniper_scout","weapon_sniper_awp"
	]
	local slot1 = 
	[
		"weapon_melee","weapon_chainsaw",
		"weapon_pistol","weapon_pistol_magnum"
	]
	local slot2 =
	[
		"weapon_molotov","weapon_pipe_bomb","weapon_vomitjar"
	]
	local slot3 =
	[
		"weapon_first_aid_kit","weapon_defibrillator",
		"weapon_upgradepack_explosive","weapon_upgradepack_incendiary"
	]
	local slot4 =
	[
		"weapon_adrenaline","weapon_pain_pills"
	]
	local slot5 = 
	[
		"weapon_oxygentank","weapon_propanetank","weapon_gascan",
		"weapon_gnome","weapon_cola_bottles","weapon_fireworkcrate"
	]

	if(slot0.find(className) != null){
		return "slot0"
	}else if(slot1.find(className) != null){
		return "slot1"
	}else if(slot2.find(className) != null){
		return "slot2"
	}else if(slot3.find(className) != null){
		return "slot3"
	}else if(slot4.find(className) != null){
		return "slot4"
	}else if(slot5.find(className) != null){
		return "slot5"
	}else{
		return null;
	}
}




::playerOnGroundData <- {}
function playerOnGroundCounter(){
	foreach(player in GetHumanSurvivors()){
		if(PlayerIsOnGround(player)){
			if(player in playerOnGroundData){
				if(playerOnGroundData[player].finish == false){
					if(playerOnGroundData[player].ticks < 30){
						playerOnGroundData[player].ticks += 1
					}else{
						playerOnGroundData[player].ticks = 0
						playerOnGroundData[player].seconds += 1
					}
				}
			}else{
				playerOnGroundData[player] <- { startTime = Time(), ticks = 0, seconds = 0, finish = false }
			}
		}
	}
}




function PlayerIsOnGround(player){
	if(NetProps.GetPropInt(player, "m_fFlags") & 1){
		return true
	}
	return false
}




// Print a chat message in color x 
// ----------------------------------------------------------------------------------------------------------------------------

function toChat(color, message, sound){
	local player = Entities.FindByClassname(null,"player")
	switch(color)
	{
		case "white"	: color = "\x01" ; break
		case "blue"		: color = "\x03" ; break
		case "orange"	: color = "\x04" ; break
		case "green"	: color = "\x05" ; break
	}
	switch(sound)
	{
		case "reward"	: sound = "ui/littlereward.wav" ; break;
		case "error"	: sound = "ui/beep_error01.wav" ; break;
		case "click"	: sound = "ui/menu_click01.wav" ; break;
	}
	ClientPrint(null, 5, color + message)
	if(sound != null){
		EmitAmbientSoundOn( sound, 1, 100, 100, player)
	}
}




// When enabled it will change the model of "tank_rock" to a log
// ----------------------------------------------------------------------------------------------------------------------------

function setTankRockModel(){
	local rock = null;
	if(L4D1SurvivorSet){
		while(rock = Entities.FindByClassname(rock, "tank_rock")){
			if(rock.IsValid()){
				rock.ValidateScriptScope()
				if(!("usesLog" in rock.GetScriptScope())){
					rock.SetModel("models/props_foliage/tree_trunk.mdl")
					rock.GetScriptScope()["usesLog"] <- true
				}
			}
		}
	}
}




// When last change mode is active we need to enable the glow on all new rocks
// ----------------------------------------------------------------------------------------------------------------------------

function lastChanceRockListener(){
	local rock = null;
	if(last_chance_active){
		while(rock = Entities.FindByClassname(rock, "tank_rock")){
			if(rock.IsValid()){
				rock.ValidateScriptScope()
				if(!("glowing" in rock.GetScriptScope())){
					NetProps.SetPropInt(rock, "m_Glow.m_iGlowType", 3)
					rock.GetScriptScope()["glowing"] <- true
				}
			}
		}
	}
}




// Which set of survivors are we using?
// ----------------------------------------------------------------------------------------------------------------------------

function IsL4D1SurvivorSet(){
	
	local L4D2Survivors = ["Louis", "Francis", "Bill", "Zoey"]
	
	foreach(survivor in GetSurvivors()){
		foreach(name in L4D2Survivors){
			if(GetCharacterDisplayName(survivor) == name){
				return true
			}
		}
	}
	return false
}




// Returns the given color with changed intesity as string 
// ----------------------------------------------------------------------------------------------------------------------------

function getColorWithIntensity(color, intensity){	
	//
	local values = split(color, " ")
	
	local rNew = values[0].tofloat()
	local gNew = values[1].tofloat()
	local bNew = values[2].tofloat()
	//
	rNew	= (rNew / 100 * intensity).tointeger()
	gNew	= (gNew / 100 * intensity).tointeger()
	bNew	= (bNew / 100 * intensity).tointeger()
	//
	return "" + rNew + " " + gNew + " " + bNew;
}

