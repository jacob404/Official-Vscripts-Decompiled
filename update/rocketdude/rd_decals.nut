//****************************************************************************************
//																						//
//										rd_decals.nut									//
//																						//
//****************************************************************************************




// Will place decals depending on map
// ----------------------------------------------------------------------------------------------------------------------------

::placeRocketDudeDecals <- function(){
	local mapName = Director.GetMapName()
	local texture = "decals/rocketdude/rd_logo_glow"
	
	if(mapName in RocketDudeDecals){
		foreach(pos in RocketDudeDecals[mapName]){
			if(mapName == "c14m1_junkyard" || mapName == "c14m2_lighthouse"){
				texture = "decals/rocketdude/rd_logo_glow_big"
			}
			applyDecalAt(pos, texture)
		}
	}
}




// Applies a decal with texture X on position Y
// ----------------------------------------------------------------------------------------------------------------------------

::applyDecalAt <- function (pos, tex){
	local decal = SpawnEntityFromTable( "infodecal", { targetname = "rd_decal", texture = tex, LowPriority = 0, origin = pos } )
	DoEntFire( "!self", "Activate", "", 0.0, decal, decal )
}




// Decal data for maps c1 - c14
// ----------------------------------------------------------------------------------------------------------------------------

::RocketDudeDecals <-
{
	c1m1_hotel			= [ Vector(2064.64,6783.97,2882) ]
	c1m2_streets		= [ Vector(-1174.98,728.091,912.947) ]
	c1m3_mall			= [ Vector(1776.31,-2015.99,642.575) ]
	c1m4_atrium			= [ Vector(-3927.97,-3403.11,856.501) ]

	c2m1_highway		= [ Vector(1338.82,-1736.51,-1087.55) ]
	c2m2_fairgrounds	= [ Vector(-495.969,-1238.1,187.207) ]
	c2m3_coaster		= [ Vector(303.034,3328.03,349.983) ]
	c2m4_barns 			= [ Vector(3717.22,576.031,-127.915) ]
	c2m5_concert 		= [ Vector(-4368.03,2687,236.19) ]

	c3m1_plankcountry 	= [ Vector(-3712,4349.86,-74.6688) ]
	c3m2_swamp 			= [ Vector(-3923.97,4650.4,85.4511) ]
	c3m3_shantytown 	= [ Vector(-5602.41,-1635.03,258.268) ]
	c3m4_plantation 	= [ Vector(1853.52,76.6953,600.031) ]

	c4m1_milltown_a 	= [ Vector(1643.17,4338.16,433.805) ]
	c4m2_sugarmill_a 	= [ Vector(2966.24,-3271.43,1200.15) ]
	c4m3_sugarmill_b 	= [ Vector(1424.04,-6088.03,416.549) ]
	c4m4_milltown_b 	= [ Vector(1437.01,6364.88,334.595) ]
	c4m5_milltown_escape = [ Vector(-5874.37,8072.03,377.766) ]

	c5m1_waterfront		= [ Vector(-2144.03,-2508.57,-334.026) ]
	c5m2_park			= [ Vector(-10102.6,-5538.72,48.0313) ]
	c5m3_cemetery		= [ Vector(3511.2,3503.97,258.566) ]
	c5m4_quarter		= [ Vector(-2060.97,3392.03,132.305) ]
	c5m5_bridge			= [ Vector(14288.3,6326.82,790.031) ]

	c6m1_riverbank		= [ Vector(1301.35,1616.03,578.07) ]
	c6m2_bedlam			= [ Vector(3964.55,4096.03,-549.714) ]
	c6m3_port			= [ Vector(-1258.88,-307.692,480.031) ]

	c7m1_docks			= [ Vector(2835.56,901.987,448.031) ]
	c7m2_barge 			= [ Vector(-10349.8,415.969,341.246) ]
	c7m3_port 			= [ Vector(-2223.97,-537.898,-32.6826) ]

	c8m1_apartment 		= [ Vector(1710.64,4568.03,264.95) ]
	c8m2_subway 		= [ Vector(9519.12,3772.03,71.1739) ]
	c8m3_sewers 		= [ Vector(15280,15322.9,72.8583) ]
	c8m4_interior 		= [ Vector(13064,14173,632.224) ]
	c8m5_rooftop		= [ Vector(7291.74,8976.03,470.528) ]

	c9m1_alleys			= [ Vector(1466.98,-1663.97,-161.193) ]
	c9m2_lots			= [ Vector(4135.19,1263.97,252.13) ]

	c10m1_caves			= [ Vector(-12608,-9505.11,27.5156) ]
	c10m2_drainage		= [ Vector(-9007.97,-9040.36,-377.031) ]
	c10m3_ranchhouse	= [ Vector(-9690.9,-7808.03,545.451) ]
	c10m4_mainstreet	= [ Vector(-1181.2,-4732.03,253.471) ]
	c10m5_houseboat		= [ Vector(2239.22,4086.55,72.0313) ]

	c11m1_greenhouse	= [ Vector(3248.03,961.976,69.2323) ]
	c11m2_offices		= [ Vector(5168.03,137.882,69.3103) ]
	c11m3_garage		= [ Vector(-2448.03,1375.55,217.825) ]
	c11m4_terminal		= [ Vector(1992.03,3128.09,513.913) ]
	c11m5_runway		= [ Vector(-7215.97,14444.1,623.558) ]

	c12m1_hilltop		= [ Vector(-7670.79,-7375.85,1478.86) ] 
	c12m2_traintunnel	= [ Vector(-7996.38,-7685.76,1329.54) ] 
	c12m3_bridge		= [ Vector(1828.55,-12166.7,484.031) ]
	c12m4_barn			= [ Vector(9825.65,-6235.72,861.689) ] 
	c12m5_cornfield		= [ Vector(4736,1515.6,362.583) ]

	c13m1_alpinecreek	= [ Vector(-3956.75,3989.21,461.736) ]
	c13m2_southpinestream = [ Vector(1329.92,993.69,170.069) ]
	c13m3_memorialbridge = [ Vector(6804.03,-4099.88,1720.87) ] 
	c13m4_cutthroatcreek = [ Vector(-731.623,1533.44,-48.6967) ] 

	c14m1_junkyard 		= [ Vector(-3616.64,-9215.38,165.2) ]
	c14m2_lighthouse	= [ Vector(340.733,-240.909,394.865) ] 


}
