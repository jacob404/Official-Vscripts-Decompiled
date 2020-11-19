///////////////////////////////////////////////////////////////////////////////
//
// An object that detects physics objects nearby and uses them to create other
// objects based on recipes
//
///////////////////////////////////////////////////////////////////////////////

// Array of ingredients that are "loaded" into the combiner
NearbyIngredients	<- []

INGREDIENTS_NEEDED <- 3		// how many ingredients are needed nearby to complete a recipe

// Think
THINK_RATE		<- 1		// how often to think
nextThink		<- 0		// the last time think occurred

// the number of ingredients to spawn
RED_INGREDIENT_SPAWN_QUANTITY <- 7
BLUE_INGREDIENT_SPAWN_QUANTITY <- 7

// point to spawn completed recipes
recipeSpawnPos <- null

// relay to fire to trigger recipe completion particle fx
recipeCreationFxRelay <- null

//=========================================================
// Think 
//=========================================================
function Think()
{
	// Spawn the ingredients on the very first think
	if( nextThink == 0 )
		SpawnIngredients()

	// bail if not time to think
	if( nextThink > Time() )
		return
	
	// set next think time
	nextThink = Time() + THINK_RATE

	ProcessNearbyIngredients()
}

//=========================================================
// OnPostSpawn
//=========================================================
function OnPostSpawn()
{
	self.PrecacheScriptSound( "Menu.Select" )
	self.PrecacheScriptSound( "ambient.electrical_zap_5" )
	
	// store the point where we'll spawn completed recipes
	recipeSpawnPos = EntityGroup[1].GetOrigin()

	// store the name of the relay that handles recipe completion particles
	recipeCreationFxRelay = EntityGroup[2].GetName()

	// spawn ingredients in the world
//	SpawnIngredients()
}

//=========================================================
// Searches for nearby ingredients and toggles their glow state
// and adds/removes them to the ingredient list.
// If there are enough ingredients to complete a recipe
// the objects are destroyed and the recipe object is created.
//=========================================================
function ProcessNearbyIngredients()
{
	// make a copy of the list before rebuilding it
	local oldIngredientList = clone NearbyIngredients
	
	
	// Clear all contents from ingredient list
	NearbyIngredients.clear()

	// Radius to search around combiner for eligible ingredients
	local SEARCH_RADIUS = 14

	// Search nearby for eligible ingredients
	local cur_ent = Entities.FindByClassnameWithin( null, "prop_physics_multiplayer", recipeSpawnPos, SEARCH_RADIUS )
	
	// Add all eligible ingredients to nearby ingredient list
	while( cur_ent )
	{
		if( cur_ent.GetName().find( "ingredient" ) )
		{
			EntFire( cur_ent.GetName(), "StartGlowing" )
			NearbyIngredients.append( cur_ent )
		}

		cur_ent = Entities.FindByClassnameWithin( cur_ent, "prop_physics_multiplayer", recipeSpawnPos, SEARCH_RADIUS )
	}

	// compare the new list to the old one so we can stop old objects from glowing
	foreach( k, old in oldIngredientList )
	{
		local found = false

		foreach( idx, new in NearbyIngredients )
		{
			if( old == new )
			{
				found = true
			}
		}
		
		// if we didn't find the old entity in the new list then turn off the glow
		if( !found)
			EntFire( old.GetName(), "StopGlowing" )
	}

	// Complete a recipe if conditions are met
	if( RecipeRequirementsMet() )
		CompleteRecipe()
}

//=========================================================
// Checks conditions to see if it is possible to complete a recipe
//=========================================================
function RecipeRequirementsMet()
{
	if( NearbyIngredients.len() >= INGREDIENTS_NEEDED )
		return true
}

function test()
{
		CreateRecipe( g_MapScript.PlaceableResource )
}

//=========================================================
// Counts the ingredients and spawns the corresponding recipe object
//=========================================================
function CompleteRecipe()
{
	local redCount = 0
	local blueCount = 0
	
	foreach( k, v in NearbyIngredients )
	{
		if( v.GetName().find( "blue") )
			blueCount++
		else
			redCount++
	}


	if( redCount == 0 && blueCount == 3 )
	{
		// pass in the placeable resource as the recipe
		CreateRecipe( g_MapScript.PlaceableResource )	
	}
	else if( redCount == 1 && blueCount == 2 )
	{
		CreateRecipe( recipe_adrenaline )
	}
	else if( redCount == 2 && blueCount == 1 )
	{
		CreateRecipe( recipe_explosive_ammo )
	}
	else if( redCount == 3 && blueCount == 0 )
	{
		CreateRecipe( recipe_firstaid )
	}

	// kill all the ingredient
	foreach( k, v in NearbyIngredients )
	{
		EntFire( v.GetName(), "kill")
	}

	// clear the list
	NearbyIngredients.clear()
}

recipe_adrenaline <-
{
	function GetSpawnList()      { return [ EntityGroup.SpawnTables.item_adrenaline ] }
	function GetEntityGroup()    { return EntityGroup }
	EntityGroup =
	{
		SpawnTables =
		{
			item_adrenaline = 
			{
				initialSpawn = true
				SpawnInfo =
				{
					classname = "weapon_adrenaline_spawn"
					angles = Vector( 0, 0, 90 )
					solid = "6"
					spawnflags = "3"
					targetname = "item_adrenaline"
					origin = Vector( 0, 0, 0 )
				}
			}
		} // SpawnTables
	} // EntityGroup
}

recipe_firstaid <-
{
	function GetSpawnList()      { return [ EntityGroup.SpawnTables.item_firstaid ] }
	function GetEntityGroup()    { return EntityGroup }
	EntityGroup =
	{
		SpawnTables =
		{
			item_firstaid = 
			{
				initialSpawn = true
				SpawnInfo =
				{
					classname = "weapon_first_aid_kit_spawn"
					angles = Vector( 0, 0, 90 )
					solid = "6"
					spawnflags = "3"
					targetname = "item_firstaid"
					origin = Vector( 0, 0, 0 )
				}
			}
		} // SpawnTables
	} // EntityGroup
}

recipe_explosive_ammo <-
{
	function GetSpawnList()      { return [ EntityGroup.SpawnTables.item_explosive_ammo ] }
	function GetEntityGroup()    { return EntityGroup }
	EntityGroup =
	{
		SpawnTables =
		{
			item_explosive_ammo = 
			{
				initialSpawn = true
				SpawnInfo =
				{
					classname = "weapon_upgradepack_explosive_spawn"
					angles = Vector( 0, 0, 90 )
					solid = "6"
					spawnflags = "3"
					targetname = "item_explosive_ammo"
					origin = Vector( 0, 0, 0 )
				}
			}
		} // SpawnTables
	} // EntityGroup
}


function CreateRecipe( recipeTable )
{
	// trigger spawn fx
	EntFire( recipeCreationFxRelay, "trigger" )

	// play sounds
	EmitSoundOn( "ambient.electrical_zap_5", self )
	EmitSoundOn( "Menu.Select", self )


	local recipeGroup = recipeTable.GetEntityGroup()
	g_MapScript.SpawnSingleAt( recipeGroup, recipeSpawnPos + Vector(0,0,6) , QAngle( 0,0,0) )
}

function SpawnIngredients()
{
	local redIngredient = 
	{
		function GetSpawnList()      { return [ EntityGroup.SpawnTables.red_ingredient ] }
		function GetEntityGroup()    { return EntityGroup }
		EntityGroup =
		{
			SpawnTables =
			{
				red_ingredient = 
				{
					initialSpawn = true
					SpawnInfo =
					{
						classname = "prop_physics_multiplayer"
						angles = Vector( 0, 180, 0 )
						BreakableType = "0"
						damagetoenablemotion = "0"
						Damagetype = "0"
						fademindist = "-1"
						fadescale = "1"
						forcetoenablemotion = "0"
						glowcolor = "255 0 0"
						inertiaScale = "1.0"
						massScale = "0"
						minhealthdmg = "0"
						model = "models/props_collectables/mushrooms.mdl"
						nodamageforces = "0"
						physdamagescale = "0.1"
						physicsmode = "0"
						renderamt = "255"
						rendercolor = "255 255 255"
						shadowcastdist = "0"
						skin = "0"
						spawnflags = "41216"
						targetname = "red_ingredient"
						origin = Vector( -0, 0, 0 )
					}
				}
			} // SpawnTables
		} // EntityGroup
	}

	
	local blueIngredient = 
	{
		function GetSpawnList()      { return [ EntityGroup.SpawnTables.blue_ingredient ] }
		function GetEntityGroup()    { return EntityGroup }
		EntityGroup =
		{
			SpawnTables =
			{
				blue_ingredient = 
				{
					initialSpawn = true
					SpawnInfo =
					{
						classname = "prop_physics_multiplayer"
						angles = Vector( 0, 180, 0 )
						BreakableType = "0"
						damagetoenablemotion = "0"
						Damagetype = "0"
						fademindist = "-1"
						fadescale = "1"
						forcetoenablemotion = "0"
						glowcolor = "0 0 255"
						inertiaScale = "1.0"
						massScale = "0"
						minhealthdmg = "0"
						model = "models/props_collectables/flower.mdl"
						nodamageforces = "0"
						physdamagescale = "0.1"
						physicsmode = "0"
						renderamt = "255"
						rendercolor = "255 255 255"
						shadowcastdist = "0"
						skin = "0"
						spawnflags = "41216"
						targetname = "blue_ingredient"
						origin = Vector( -0, 0, 0 )
					}
				}
			} // SpawnTables
		} // EntityGroup
	}
	

	// complain if the spawn points do not exist 
	if( ! ( Entities.FindByName( null, "red_ingredient_*") ) )
		printl("*** ERROR!! Combiner cannot find red_ingredient_* info_item_position entities!")

	if( ! ( Entities.FindByName( null, "blue_ingredient_*") ) )
		printl("*** ERROR!! Combiner cannot find blue_ingredient_* info_item_position entities!")

	// spawn red ingredients
	local redGroup = redIngredient.GetEntityGroup()
	redGroup.SpawnPointName <- "red_ingredient_*"
	redGroup.Target <- RED_INGREDIENT_SPAWN_QUANTITY
	g_MapScript.SpawnMultiple( redGroup, { count = RED_INGREDIENT_SPAWN_QUANTITY } )
	
	// spawn blue ingredients
	local blueGroup = blueIngredient.GetEntityGroup()
	blueGroup.SpawnPointName <- "blue_ingredient_*"
	blueGroup.Target <- BLUE_INGREDIENT_SPAWN_QUANTITY
	g_MapScript.SpawnMultiple( blueGroup, { count = BLUE_INGREDIENT_SPAWN_QUANTITY } )	
}