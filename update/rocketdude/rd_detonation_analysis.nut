//****************************************************************************************
//																						//
//								rd_detonation_analysis.nut								//
//																						//
//****************************************************************************************




// Distance between player eyepos and wall < distance between player eyepos to floor/ceiling...
// Thats why we want to have a higher value when the hit surface was a wall.
// ----------------------------------------------------------------------------------------------------------------------------

function getSurfaceValue(detonationPos,player){
	
	local traceTableX1 = { start = detonationPos+Vector(2,0,0), end = detonationPos+Vector(-2,0,0), ignore = player, mask = TRACE_MASK_PLAYER_SOLID }
	local traceTableX2 = { start = detonationPos+Vector(-2,0,0), end = detonationPos+Vector(2,0,0), ignore = player, mask = TRACE_MASK_PLAYER_SOLID }

	local traceTableY1 = { start = detonationPos+Vector(0,2,0), end = detonationPos+Vector(0,-2,0), ignore = player, mask = TRACE_MASK_PLAYER_SOLID }
	local traceTableY2 = { start = detonationPos+Vector(0,-2,0), end = detonationPos+Vector(0,2,0), ignore = player, mask = TRACE_MASK_PLAYER_SOLID }

	local traceTableZ1 = { start = detonationPos+Vector(0,0,2), end = detonationPos+Vector(0,0,-2), ignore = player, mask = TRACE_MASK_PLAYER_SOLID }
	local traceTableZ2 = { start = detonationPos+Vector(0,0,-2), end = detonationPos+Vector(0,0,2), ignore = player, mask = TRACE_MASK_PLAYER_SOLID }

	TraceLine(traceTableX1)
	TraceLine(traceTableX2)
	TraceLine(traceTableY1)
	TraceLine(traceTableY2)
	TraceLine(traceTableZ1)
	TraceLine(traceTableZ2)

	// WALL
	if("hit" in traceTableX1 && traceTableX1.hit == true ||  "hit" in traceTableX2 && traceTableX2.hit == true ){
		return "WALL"
	}
	// WALL
	else if("hit" in traceTableY1 && traceTableY1.hit == true ||  "hit" in traceTableY2 && traceTableY2.hit == true ){
		return "WALL"
	}
	// CEILING/FLOOR
	else if("hit" in traceTableZ1 && traceTableZ1.hit == true ||  "hit" in traceTableZ2 && traceTableZ2.hit == true ){
		return "CLOOR"
	}else{
		return "WALL" // Just in case...
	}
}

