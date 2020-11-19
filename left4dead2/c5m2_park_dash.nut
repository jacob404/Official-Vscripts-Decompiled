// Map specific setup for c5m2_park dash mode
// sets some default scores, and spawns some custom items for the map

function MapGameplayStart()
{
	Scoring_SetDefaultScores( [ { name = "Chell", score = 165 }, { name = "Coach", score = 192 }, { name = "Gordon", score = 265 } ] )
	SpawnItems()
}

//=========================================================
// Spawn a bunch of items into the map at specific xyz positions
//=========================================================
function SpawnItems()
{
	local itemTable =
	[
		{ classname = "weapon_upgradepack_explosive_spawn", spawnflags = 2, origin = Vector(-6678,-2317, -250), angles = Vector(0, 40, 0) },
		{ classname = "weapon_upgradepack_incendiary_spawn", spawnflags = 2, origin = Vector(-3765, -2390, -375), angles = Vector(0, 0, 0) },
		{ classname = "weapon_pipe_bomb", spawnflags = 0, origin = Vector(-7453, -1042, -245), angles = Vector(45, 45, 0) },
		{ classname = "weapon_pipe_bomb", spawnflags = 0, origin = Vector(-7045, -3608, -150), angles = Vector(45, 45, 0) },
		{ classname = "weapon_adrenaline", spawnflags = 0, origin = Vector(-7453, -700, -250), angles = Vector(45, 45, 0) },
		{ classname = "weapon_adrenaline", spawnflags = 0, origin = Vector(-7272, -3637, -157), angles = Vector(45, 45, 0) },
		{ classname = "weapon_adrenaline", spawnflags = 0, origin = Vector(-7272, -3600, -157), angles = Vector(45, 45, 0) },
		{ classname = "weapon_adrenaline", spawnflags = 0, origin = Vector(-7272, -3667, -157), angles = Vector(45, 45, 0) },
		{ classname = "weapon_gascan", spawnflags = 0, origin = Vector(-7172, -1015, -218), angles = Vector(45, 45, 0) },
		{ classname = "weapon_gascan", spawnflags = 0, origin = Vector(-6569, -3803, -251), angles = Vector(45, 45, 0) },
	]

	foreach( idx, val in itemTable )
		CreateSingleSimpleEntityFromTable( val )
}
