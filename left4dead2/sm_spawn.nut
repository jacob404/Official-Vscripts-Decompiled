///////////////////////////////////////////////////////////////////////////////
//
// sm_spawn.nut - Entity group spawning
// Spawn Helpers systems for new Scripted Mutation stuff
//
///////////////////////////////////////////////////////////////////////////////

// debug helper if you want to see all the spawned objects with glows for debugging
g_DebugAllSpawnsGlow <- false

///////////////////////////////////////////////////////////////////////////////
// First up, the core actual Spawning System and support
///////////////////////////////////////////////////////////////////////////////

// global data store for spawn temporaries used during the spawn process
InstancedEntityGroup <- {}
UniqueTargetnames <- {}
ReplacementParms <- {}
UniqueTag <- ""

//=========================================================
// Helpers to return duplicates of the of global tables - really want to be macros...
//=========================================================
function GetUniqueTargetnameTable()
{
	return DuplicateTable( UniqueTargetnames )
}

function GetReplacementKeys()
{
	return DuplicateTable( ReplacementParms )
}

//=========================================================
// make strings, replace them in place, and so on
//=========================================================
function ReplaceString( string, pfnMakeUnique )
{
	if ( pfnMakeUnique( string ) )
	{
		if ( string in UniqueTargetnames )
		{
			string = UniqueTargetnames[ string ]
		}
		else if ( string.find( "*" ) != null )
		{
			// wildcard search
			string = UniqueTag + string
		}
	}
	return string
}

function ReplaceConnectionString( string, pfnMakeUnique )
{
	local failsafe = 0
	local searchstart = 0
	local searchend = string.find( "\x1B", searchstart )
	while ( searchend != null && failsafe < 20 )
	{
		local pre = string.slice( 0, searchstart )
		local search = string.slice( searchstart, searchend )
		local post = string.slice( searchend )

		if ( pfnMakeUnique( search ) )
		{
			if ( search in UniqueTargetnames )
			{
				search = UniqueTargetnames[ search ]
			}
			else if ( search.find( "*" ) != null )
			{
				// assume this is a wildcard search
				search = UniqueTag + search
			}
		} 

		string = pre + search + post
		searchstart = ( pre + search ).len() + 1
		searchend = string.find( "\x1B", searchstart )
		++failsafe
	}
	return string
}

//=========================================================
// generate spawn tables 
//=========================================================
function CacheSpawnTables( entityGroup )
{
	InstancedEntityGroup.clear()
	UniqueTargetnames.clear()

	if ( !("SpawnTables" in entityGroup) )
	{
		printl("No spawntables for this entity group " + entityGroup)
		return
	}

	InstancedEntityGroup = DuplicateTable( entityGroup )

	// Initialize the targetname lookup table
	local spawnTables = entityGroup.SpawnTables
	foreach ( entityTable in spawnTables )
	{
		if ( "targetname" in entityTable.SpawnInfo )
		{
			local targetName = entityTable.SpawnInfo.targetname
			UniqueTargetnames[ targetName ] <- targetName
		}
	}
}


//=========================================================
// just get unique names on each VM restart by incrementing the global
//=========================================================
g_UniqueID <- 0
function GetUniqueString()
{
	return "_" + ++g_UniqueID + "_"
}

//=========================================================
// Uniquify every targetname in the UniqueTargetnames table
//=========================================================
function GenerateUniqueTargetnames()
{
	UniqueTag = GetUniqueString()
	foreach ( targetname, unique in UniqueTargetnames )
	{
		if ( targetname.find( "@" ) == null )
		{
			UniqueTargetnames[ targetname ] <- UniqueTag + targetname
		}
		else
		{
			UniqueTargetnames[ targetname ] <- targetname			
		}
		smDbgLoud( "Converted " + targetname + " to " + UniqueTargetnames[ targetname ] )
	}
}

//=========================================================
// Build a mapping from targetname to spawn tables for every entity that shares that targetname
//=========================================================
function MapTargetnameToSpawnTables( entityGroup )
{
	local entSpawnInfo = {}
	foreach ( tableName, entityTable in entityGroup.SpawnTables )
	{
		// Multiple entities may have the same targetname, so use targetname as the key
		// for a sub-table which will contain the spawn tables for those entities (table
		// names are guarenteed to be unique within an entity group)
		if ( "targetname" in entityTable.SpawnInfo )
		{
			local targetName = entityTable.SpawnInfo.targetname;
			smDbgLoud( "Mapping SpawnInfo for entityTable " + tableName + " to targetname " + targetName )

			if ( !( entityTable.SpawnInfo.targetname in entSpawnInfo ) )
			{
				// Establish the new sub-table for this targetname
				entSpawnInfo[ targetName ] <- {}
			}

			// Add the entity spawn table to the targetname table
			entSpawnInfo[ targetName ][ tableName ] <- entityTable.SpawnInfo
		}
	}
	return entSpawnInfo
}

//=========================================================
// Fill out templates with spawn data for their target entities
//=========================================================
function ProcessTemplates( entityGroup )
{
	local spawnTableLookup = MapTargetnameToSpawnTables( entityGroup )

	local entityGroupSet = 
	{ 
		OriginalGroup = { SpawnTables = DuplicateTable( entityGroup.SpawnTables ) }
		UniqueGroup = { SpawnTables = entityGroup.SpawnTables }
	}

	// For each template in the group, look up the referenced entities and cache off their spawn tables
	foreach ( tablename, entity in entityGroup.SpawnTables )
	{
		if ( entity.SpawnInfo.classname == "point_script_template" )
		{
			smDbgLoud( "Processing Template " + entity.SpawnInfo.targetname )
			local template = Entities.FindByName( null, entity.SpawnInfo.targetname )
			while ( template )
			{
				// entity group spawn table targetnames get decorated with each spawn, so make sure the template caches
				// its table from the "OriginalGroup" which is a copy that's guaranteed to never change
				local templateSpawnInfo = entityGroupSet.OriginalGroup.SpawnTables[ tablename ].SpawnInfo
				template.SetGroupSpawnTables( templateSpawnInfo, entityGroupSet )

				foreach ( spawnKey, targetName in entity.SpawnInfo )
				{
					if ( spawnKey.find( "Template" ) != null )
					{
						if ( targetName in spawnTableLookup )
						{
							smDbgLoud( "\t" + spawnKey + ": " + targetName )
							foreach( spawnTable in spawnTableLookup[ targetName ] )
							{
								smDbgLoud( "\t\tAdding " + spawnTable.classname + " (" + spawnTable.targetname + ")" )
								template.AddTemplate( spawnTable.classname, spawnTable )
							}
						}
						else
						{
							printl( "WARNING: Missing entity \"" + targetName + "\" referenced by point_template " + entity.SpawnInfo.targetname + "." ) 
						}
					}
				}
				template = Entities.FindByName( template, entity.SpawnInfo.targetname )
			}
		}
	}
}

//-------------------------------------
// Keys of the format "<name>xx" 
// such as "Template01"
//-------------------------------------
local substringKeys =
{
	// left4dead2.fgd
	logic_choreographed_scene = "target"
	logic_scene_list_manager =	"scene"
	info_changelevel = "landmark"

	// base.fgd
	point_script_template = "Template"
	env_soundscape = "position"
	info_particle_system = "cpoint"
	logic_branch_listener = "Branch"
	logic_collision_pair = "attach"
	logic_script = "Group"
}

//-------------------------------------
// Entity-specific keys
//-------------------------------------
local entitySpecificKeys = 
{
	// left4dead2.fgd
	env_airstrike_outdoors = "modelgroup",
	point_viewcontrol_multiplayer =	"target_entity",
	point_prop_use_target = "nozzle",			 
	env_rock_launcher = "RockTargetName",
	point_script_use_target = "model",

	// base.fgd
	ambient_generic = "SourceEntityName",	 
	env_beam = [ "LightningStart",	"LightningEnd" ],
	env_explosion = "ignoredEntity",	 
	env_physexplosion = "targetentityname",	 
	env_physimpact = "directionentityname", 
	env_laser = "LaserTarget",	
	env_soundscape_proxy = "MainSoundscapeName",	 
	point_entity_finder = "referencename",	
	info_decal = "ApplyEntity", 
	prop_door_rotating = "slavename",
	point_viewcontrol = "moveto",
	env_microphone = "SpeakerName",
	logic_lineto = "source",
	env_entity_maker = "EntityTemplate",
	point_anglesensor = "lookatname",
	path_track = "altpath",
	logic_measure_movement = [ "MeasureTarget", "MeasureReference", "TargetReference" ]
	env_instructor_hint	= "hint_target",
}

//-------------------------------------
// Common spawn keys
//-------------------------------------
local commonKeys =
[
	// base.fgd
	"parentname",		// @BaseClass Parentname
	"damagefilter",		// @BaseClass DamageFilter
	"target",			// path_track, func_tracktrain, etc.
	"lightingorigin",	// @BaseClass gibshooterbase
	"NextKey",			// @BaseClass KeyFrame
	"glow",				// func_button, func_button_timed, momentary_rot_button
	"attach1",			// @BaseClass TwoObjectPhysics, etc.
	"attach2",			// @BaseClass TwoObjectPhysics, etc.
	"constraintsystem",	// @BaseClass TwoObjectPhysics
	"filtername",		// triggers
]

//=========================================================
// Actually instance in specific keys onto the spawned entity
//=========================================================
function InstanceEntitySpawnKeys( entityGroup, entitySpawnInfo, tableName, replaceParms, groupOrigin, groupAngles, pfnMakeUnique )
{
	local sourceSpawnInfo = entitySpawnInfo
	local targetSpawnInfo = entityGroup.SpawnTables[ tableName ].SpawnInfo

	if ( "targetname" in sourceSpawnInfo )
	{
		targetSpawnInfo.targetname = ReplaceString( sourceSpawnInfo.targetname, @(s) true )
		smDbgLoud( sourceSpawnInfo.targetname + "(" + targetSpawnInfo.targetname + "):" )
	}

	if ( groupAngles == null)
		groupAngles = QAngle(0,0,0)
	if ( groupOrigin == null)
		groupOrigin = Vector(0,0,0)

	if ( "origin" in sourceSpawnInfo )
	{
		targetSpawnInfo.origin = RotatePosition( Vector( 0, 0, 0 ), groupAngles, sourceSpawnInfo.origin ) + groupOrigin
	}
	else
	{
		targetSpawnInfo.origin <- groupOrigin
	}

	if ( "angles" in sourceSpawnInfo )
	{
		local entAngles = QAngle( sourceSpawnInfo.angles.x, sourceSpawnInfo.angles.y, sourceSpawnInfo.angles.z )
		local newAngles = RotateOrientation( groupAngles, entAngles )
		targetSpawnInfo.angles = Vector( newAngles.x, newAngles.y, newAngles.z )
	}
	else
	{
		local vecAngles = Vector( groupAngles.x, groupAngles.y, groupAngles.z )
		targetSpawnInfo.angles <- vecAngles
	}

	if ( "pushdir" in sourceSpawnInfo )
	{
		local pushAngles = QAngle( sourceSpawnInfo.pushdir.x, sourceSpawnInfo.pushdir.y, sourceSpawnInfo.pushdir.z )
		local newAngles = RotateOrientation( groupAngles, pushAngles )
		targetSpawnInfo.pushdir = Vector( newAngles.x, newAngles.y, newAngles.z )
	}
	
	if ( "springaxis" in sourceSpawnInfo )
	{
		targetSpawnInfo.springaxis = RotatePosition( Vector( 0, 0, 0 ), groupAngles, sourceSpawnInfo.springaxis ) + groupOrigin
	}

	if ( "axis" in sourceSpawnInfo )
	{
		if ( typeof( sourceSpawnInfo.axis ) == "Vector" )
		{
			targetSpawnInfo.axis = RotatePosition( Vector( 0, 0, 0 ), groupAngles, sourceSpawnInfo.axis ) + groupOrigin
		}
	}

	// I/O connections contain the name of the target entity
	if ( "connections" in sourceSpawnInfo )
	{
		smDbgLoud( "\tconnections:" )
		foreach ( outputName, output in sourceSpawnInfo.connections )
		{
			foreach ( key, cmd in output )
			{
				local oldvalue = targetSpawnInfo.connections[ outputName ][ key ]
				targetSpawnInfo.connections[ outputName ][ key ] = ReplaceConnectionString( cmd, pfnMakeUnique )
				smDbgLoud( "\t\tReplaced " + key + " (" + oldvalue + ") with (" + targetSpawnInfo.connections[ outputName ][ key ] + ")" )
			}
		}
	}

	// Handle replace parameters
	if ( replaceParms && replaceParms.len() > 0 )
	{
		foreach ( key, value in sourceSpawnInfo )
		{
			if ( typeof( value ) == "string" && value.find( "$" ) == 0 )
			{
				if ( value in replaceParms )
				{
					smDbgLoud( "\tReplaced " + value + " with " + replaceParms[ value ] )
					targetSpawnInfo[ key ] = replaceParms[ value ]
				}
			}
		}
	}

	// Find every spawn key in the entity that references a targetname
	local keysToReplace = []

	// Find keys of the format "<name>xx" such as "Template01"
	local classname = sourceSpawnInfo.classname
	if ( classname in substringKeys )
	{
		local substring = substringKeys[ classname ]
		local substringLen = substring.len()
		foreach ( key, value in sourceSpawnInfo )
		{
			local idx = key.find( substring )
			if ( idx == 0 && (key.len() - substringLen <= 2) )
			{
				keysToReplace.push( key )
			}
		}		
	}

	// Find keys that are unique to a particular entity
	if ( classname in entitySpecificKeys )
	{
		local value = entitySpecificKeys[ classname ]
		if ( typeof( value ) == "array" )
		{
			foreach ( entry in value )
			{
				if ( entry in sourceSpawnInfo )
				{
					keysToReplace.push( entry )
				}
			}
		}
		else if ( value in sourceSpawnInfo )
		{
			keysToReplace.push( value )
		} 
	}

	// Replace common keys that are shared by multiple entities
	foreach( key in commonKeys )
	{
		if ( key in sourceSpawnInfo )
		{
			keysToReplace.push( key )
		}			
	}

	foreach ( key in keysToReplace )
	{
		local oldvalue = targetSpawnInfo[ key ]
		targetSpawnInfo[ key ] = ReplaceString( sourceSpawnInfo[ key ], pfnMakeUnique )
		smDbgLoud( "\tReplaced " + key + " (" + oldvalue + ") with (" + targetSpawnInfo[ key ] + ")" )
	}			

	if (g_DebugAllSpawnsGlow)
		targetSpawnInfo["glowstate"] <- "3"
}

//=========================================================
// check for any replace params in the entity group, and apply them
//=========================================================
function GetReplaceParms( positionEnt, entityGroup )
{
	// Find replace parms in the position entity and perform replacements in the spawn entities
	local replaceParms = {}
	if ( positionEnt && "GetReplaceParm" in positionEnt )
	{
		local idx = 0
		local parm = null
		while ( parm = positionEnt.GetReplaceParm( idx++ ) )
		{
			local space = parm.find( " " )
			if ( space == null )
			{
				continue
			}

			local key = parm.slice( 0, space )
			local value = parm.slice( space+1 )
			replaceParms[ key ] <- value
		}
	}

	if ( "ReplaceParmDefaults" in entityGroup )
	{
		foreach ( parm, value in entityGroup.ReplaceParmDefaults )
		{
			if ( !( parm in replaceParms ) )
			{
				replaceParms[ parm ] <- value
			}
		}
	}
	return replaceParms;
}

//=========================================================
// go ahead and create the entity group instance
//=========================================================
function InstanceEntityGroup( entityGroup, positionEnt, groupOrigin, groupAngles )
{
	GenerateUniqueTargetnames()

	smDbgLoud( "" )
	smDbgLoud( "Instance Entity Group" )

	ReplacementParms = GetReplaceParms( positionEnt, entityGroup );

	// now replace targetnames in the group spawn tables with the unique targetnames
	local spawnTables = entityGroup.SpawnTables
	foreach( tableName, entityTable in spawnTables )
	{
		InstanceEntitySpawnKeys( InstancedEntityGroup, entityTable.SpawnInfo, tableName, ReplacementParms, groupOrigin, groupAngles, @(s) true )
	}
	
	return InstancedEntityGroup
}

//=========================================================
// Generate unique spawn keys for each entity in this template
//=========================================================
function InstanceTemplateGroup( templateSpawnInfo, entityGroupSet, allowNameFixup )
{
	if ( allowNameFixup )
	{
		GenerateUniqueTargetnames()
	}

	local spawnTableLookup = MapTargetnameToSpawnTables( entityGroupSet.OriginalGroup )

	// record the targetnames of entities that need to be instanced
	local templateTargetnames = {}
	local spawnTables = entityGroupSet.OriginalGroup.SpawnTables

	smDbgLoud( "Instancing entities for template " + templateSpawnInfo.targetname )

	foreach ( key, value in templateSpawnInfo )
	{
		if ( key.find( "Template" ) != null )
		{
			smDbgLoud( "Found " + key + " : " + value )
			templateTargetnames[ value ] <- 1
		}		
	}	

	foreach( targetname, val in templateTargetnames )
	{
		if ( targetname in spawnTableLookup )
		{
			foreach( tableName, spawnTable in spawnTableLookup[ targetname ] )
			{
				smDbgLoud( "Processing template target entity table " + tableName + " (" + targetname + ")" )
				InstanceEntitySpawnKeys( entityGroupSet.UniqueGroup, spawnTable, tableName, null, Vector( 0, 0, 0 ), QAngle( 0, 0, 0 ), @(str) str in templateTargetnames )
			}
		}
	}
}

//=========================================================
// Called from c++ when a point_script_template 
// spawns its entities
//=========================================================
function InstanceTemplateSpawnTables( templateSpawnInfo, entityGroupSet, allowNameFixup )
{
	CacheSpawnTables( entityGroupSet.OriginalGroup )
	InstanceTemplateGroup( templateSpawnInfo, entityGroupSet, allowNameFixup )
}

///////////////////////////////////////////////////////////////////////////////
// Now, the actual spawn system/management of objects/etc
///////////////////////////////////////////////////////////////////////////////

// this is the table of all registered/global/ready to go entity groups - key'd by name
EntityGroups <- {}

//=========================================================
// Precache all models
//=========================================================
function EntityGroupPrecache( entityGroup )
{
	if ("GetPrecacheList" in entityGroup)
	{
		local precacheTable = entityGroup.GetPrecacheList()
		foreach ( entity in precacheTable )
			PrecacheEntityFromTable( entity.SpawnInfo )	
	}
}

//=========================================================
// when precache happens, want to go through and precache all the entitygroups
//=========================================================
function ScriptedPrecache()
{
	smDbgPrint( "ScriptedPrecache()" )
	foreach ( idx, group in EntityGroups )
	{
		smDbgPrint( "Precaching " + idx )
		EntityGroupPrecache( group )
	}
}

//=========================================================
// "Register" the entity group - so that it can be found by name later/it ready to spawn
// also calls the OnEntityGroupRegistered if they exist in Mode or Map script...
//=========================================================
function RegisterEntityGroup( name, groupInterface )
{
	EntityGroups[ name ] <- groupInterface
	smDbgPrint( "Registering entity group " + name )

	// Mark the entities that need to get spawned
	local spawnEnts = groupInterface.GetSpawnList()
	foreach ( ent in spawnEnts )
	{
		ent.initialSpawn <- true
	}

	local entityGroup = groupInterface.GetEntityGroup()
	if ( "OnEntityGroupRegistered" in g_ModeScript )
		g_ModeScript.OnEntityGroupRegistered( name, groupInterface )
	if ( "OnEntityGroupRegistered" in g_MapScript )
		g_MapScript.OnEntityGroupRegistered( name, groupInterface )
}

//=========================================================
// go get an entity group from the global registry
//=========================================================
function GetEntityGroup( name )
{
	if ( name in EntityGroups )
	{
		return EntityGroups[ name ].GetEntityGroup()
	}
	printl( "ERROR: EntityGroup " + name + " doesn't exist. Did you forget to include the group script?" )
	return null
}

//=========================================================
// if there is a target entity name (for info_item_targets for this entity group) go find them
// so we have a list of all the position entities where we might want to spawn that entity group
// There is one for "by name" and one for "by class"
//=========================================================
function MakeSpawnLocNameList( entityGroup )
{
	local max_group = 0
	local ent_item = Entities.FindByName( null, entityGroup.SpawnPointName )
	if (!("InfoItemList" in entityGroup))
		entityGroup.InfoItemList <- []
	while ( ent_item )
	{
		entityGroup.InfoItemList.append( ent_item )
		if (ent_item.GetGroup() > max_group)
			max_group = ent_item.GetGroup()
		ent_item = Entities.FindByName( ent_item, entityGroup.SpawnPointName )
	}
	entityGroup.InfoListBuilt <- true
	entityGroup.ItemMaxGroup <- max_group
	smDbgPrint("Built infolist with " + entityGroup.InfoItemList.len() + "entries from " + entityGroup.SpawnPointName + " maxgroup " + max_group)
}

function MakeSpawnLocClassList( itemTable )
{
	local max_group = 0
	local ent_item = Entities.FindByClassname( null, itemTable.InfoItemClass )
	if (!("InfoItemList" in itemTable))
		itemTable.InfoItemList <- []
	while ( ent_item )
	{
		itemTable.InfoItemList.append( ent_item )
		if (ent_item.GetGroup() > max_group)
			max_group = ent_item.GetGroup()
		ent_item = Entities.FindByClassname( ent_item, itemTable.InfoItemClass )
	}
	itemTable.InfoListBuilt <- true
	itemTable.ItemMaxGroup <- max_group
	smDbgPrint("Built infolist with " + itemTable.InfoItemList.len() + "entries from class " + itemTable.InfoItemClass + " maxgroup " + max_group)
}

function BuildInfoItemList( entityGroup, force_rebuild = false )
{
	if (force_rebuild)
		if ("InfoItemList" in entityGroup)
			entityGroup.InfoItemList.clear()

	if ( (! ( "InfoItemList" in entityGroup ) ) || force_rebuild)
	{
		if ( "SpawnPointName" in entityGroup )
			MakeSpawnLocNameList( entityGroup )
		else if ( "InfoItemClass" in entityGroup )
			MakeSpawnLocClassList( entityGroup )
		else 
		{
			entityGroup["InfoItemClass"] <- "info_item_position"
			MakeSpawnLocClassList( entityGroup )			
		}
	}
}

//=========================================================
// go ahead and spawn the entity group
//=========================================================
function SpawnEntityGroup( group, positionEnt, origin, angles )
{		
	smDbgPrint( "\nSpawning entity group at " )
	if ( "SpawnPointName" in group )
	{
		smDbgPrint( group.SpawnPointName + "\n" )
	}
	smDbgPrint( "Origin: " + origin + ", Angles: " + angles )

	local groupInst = InstanceEntityGroup( group, positionEnt, origin, angles )

	local tableidx = 0
	local groupSpawnTables = {}
	local bSuccess = true
	foreach ( spawnEnt in groupInst.SpawnTables )
	{
		if ( "initialSpawn" in spawnEnt && spawnEnt.initialSpawn == true )
		{
			local spawnInfo = spawnEnt.SpawnInfo
			groupSpawnTables[ tableidx++ ] <- { [ spawnInfo.classname ] = spawnInfo }
			//printl("Added a thing to spawn...")
		}
	}

	bSuccess = SpawnEntityGroupFromTable( groupSpawnTables )
	if (!bSuccess)
		printl("ERROR: Failed to spawn entity group" )

	local spawnedNameList = []
	// Post-spawn processing
	foreach ( spawnEnt in groupInst.SpawnTables )
	{
		if ( "initialSpawn" in spawnEnt && spawnEnt.initialSpawn == true )
		{
			if ("targetname" in spawnEnt.SpawnInfo)
			{
				spawnedNameList.append( spawnEnt.SpawnInfo.targetname  )
			}
			
			// Call any post-spawn callbacks
			if ( "PostPlaceCB" in spawnEnt )
			{
				local spawnedEntity = Entities.FindByName( null, spawnEnt.SpawnInfo.targetname )
				if (spawnedEntity != null)
					spawnEnt.PostPlaceCB( spawnedEntity, 0 )
				else
					printl("WARNING: failed to find entity for callback for target " + spawnEnt.SpawnInfo.targetname )
			}

			// For entities with a script, push a copy of the spawn table into their script scope
			if ( "vscripts" in spawnEnt.SpawnInfo )
			{
				local spawnedEntity = Entities.FindByName( null, spawnEnt.SpawnInfo.targetname )
				if ( spawnedEntity )
				{
					if ( spawnedEntity.GetScriptScope() )
					{
						spawnedEntity.GetScriptScope().SpawnKeys <- DuplicateTable( spawnEnt.SpawnInfo )	
					}	
				}		
			}
		}
	}

	ProcessTemplates( groupInst )

	if ( bSuccess )
	{
		if ( "PostPlaceListCB" in groupInst )
		{
			groupInst.PostPlaceListCB( spawnedNameList )
		}
	}

	return bSuccess
}

///////////////////////////////////////////////////////////////////////////////
// EntSpawn helpers - these basically parse the MapSpawn table, include from it, and so on
///////////////////////////////////////////////////////////////////////////////
function EntSpawn_DoIncludes( spawnTable )
{
	foreach (idx, val in spawnTable)
	{
		local fileName = ""
		local valCount = 0

		// count the number of parameters in the slot
		foreach( idx in val)
			valCount++

		// if only one parameter then assume it is the group name, build the filename
		// e.g., MineTable
		if( valCount == 1 )
		{
			fileName = EntSpawn_GetFixedUpGroupName( val[0] ) + "_group"
		}
		// If two parameters are passed in assume it is the group name and a custom flag
		// e.g., MineTable, FLAG_SPAWN
		else if( valCount == 2 )
		{
			fileName = EntSpawn_GetFixedUpGroupName( val[0] ) + "_group"
		}
		// If three or more parameters are supplied then use the 3rd as the group name
		// e.g., MineTable, mine_table_spawn, mine_table_group
		else if( valCount >= 3 )
		{
			fileName = val[2]
		}

		// printl(" **** Including with filename: " + fileName )

		IncludeScript( "entitygroups/" + fileName, g_MapScript )
	}
}

//=========================================================
//=========================================================
function EntSpawn_DefaultHelper( groupName, locationName )
{
	local entityGroup = GetEntityGroup( groupName )
	entityGroup.SpawnPointName <- locationName
	SpawnMultiple( entityGroup, { sort = @(a,b) a.GetName() <=> b.GetName() } )
}

//=========================================================
//=========================================================
function EntSpawn_SpawnToTargetHelper( groupName, locationName, quantity )
{
	local entityGroup = GetEntityGroup( groupName )
	entityGroup.SpawnPointName <- locationName
	SpawnMultiple( entityGroup, { count = quantity } )
}

//=========================================================
// Takes a group name and inserts an underscore before every capital
//   letter (except the first) and then makes the string lower case 
// e.g., 'MineTable' would be converted into 'mine_table'
//=========================================================
function EntSpawn_GetFixedUpGroupName( originalName )
{
	local groupFixedup = ""
	
	// expression for upper case
	local ex = regexp( @"\u" )

	// Regex search result
	local result = {}

	// create the fixed up name (no upper case characters, underscores)
	while( result )
	{
		// initialize start of search on 2nd letter
		result.begin <- 0
		result.end <- 1
	
	
		result = ex.search( originalName, result.end )
		
		// if we found a capital letter, chop up the string and add an underscore
		if( result )
		{
			groupFixedup += originalName.slice( 0, result.begin ) + "_"
			originalName = originalName.slice( result.begin )
		}
		else
		{
			// no more capital letters so finish up
			groupFixedup += originalName		
			groupFixedup = groupFixedup.tolower()
		}
	}

	return groupFixedup
}

//=========================================================
//=========================================================
function EntSpawn_DoTheSpawns( spawnTable )
{
	foreach (idx, val in spawnTable)
	{
		local valCount = 0

		// count the number of parameters in the slot
		foreach( idx in val)
			valCount++

		local group = 0
		local location = ""
		local flags = SPAWN_FLAGS.SPAWN
		local quantity = 0

		// If one parameter is supplied then assume it is the group name - build the location from it and use default flag.
		// e.g., MineTable
		if( valCount == 1 )
		{
			group		= val[0]
			location	= EntSpawn_GetFixedUpGroupName( val[0] ) + "_spawn"
			flags		= SPAWN_FLAGS.SPAWN
		}
		// If two parameters are passed in assume it is the group name and a custom flag
		// e.g., MineTable, SPAWN_FLAGS.SPAWN
		else if( valCount == 2 )
		{
			group		= val[0]
			location	= EntSpawn_GetFixedUpGroupName( val[0] ) + "_spawn"
			flags		= val[1]
		}
		// If three parameters are supplied then no flag was specified. use the default.
		// e.g., MineTable, mine_table_spawn, mine_table_group
		else if( valCount == 3 )
		{
			group		= val[0]
			location	= val[1]
			flags		= SPAWN_FLAGS.SPAWN
		}
		else if( valCount == 4 )
		{
			// Assume all four parameters were passed in and use them as specified.
			group		= val[0]
			location	= val[1]
			flags		= val[3]
		}
		else if( valCount == 5 )
		{
			// 5th parameter is a quantity to spawn.
			group		= val[0]
			location	= val[1]
			flags		= val[3]
			quantity	= val[4]
		}

		// Check the spawn flag to determine what EntSpawn function to call
		if( flags == SPAWN_FLAGS.SPAWN )
		{
			EntSpawn_DefaultHelper( group, location )
		}
		else if( flags == SPAWN_FLAGS.TARGETSPAWN )
		{
			// spawn a specific number
			EntSpawn_SpawnToTargetHelper( group, location, quantity )
		}
		else if( flags == SPAWN_FLAGS.NOSPAWN )
		{
			// do nothing
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// You can Spawn from lists (SpawnMultiple), and pass in a config table with filters, sorts, and list overrides
// Or you can "SpawnSingle" - for putting a single entity group at a specific place or object
//
// a configTable can have
//   filter - is passed the list of possible spawns, can decide which to do or not do
//   sort   - if you place one, it is called on the final spawn list
//   list   - if you want to just pass a spawn list yourself directly
//   count  - if you want N things spawned, but dont care which
//   
///////////////////////////////////////////////////////////////////////////////

// this helper is here so that if you want to get the list to do some thinking (# of groups, length, etc) you can
// note that it is returning the actual list - so dont modify unless you know what you are doing!
// usually you'd want to GetList, then make your own sublist/new list to pass into SpawnMultiple in the config table
function SpawnGetList( entityGroup )
{
	CacheSpawnTables( entityGroup )
	BuildInfoItemList( entityGroup )
	return entityGroup.InfoItemList
}

// configTable parameters = filter = null, sort = null, list = null - see above for some detail
// Multiple is kinda a misnomer - it really is "spawn from list" or "position markers" or something
function SpawnMultiple( entityGroup, configTable )
{
	CacheSpawnTables( entityGroup )
	// build the potential list
	local spawnList = []
	if ( configTable && "list" in configTable )
	{
		spawnList = configTable.list 
	}
	else
	{
		BuildInfoItemList( entityGroup )
		spawnList = entityGroup.InfoItemList
	}
	if ( configTable && "filter" in configTable )
	{
		spawnList = spawnList.filter( @(idx,val) configTable.filter(val) )   // is this legal?
	}
	if ( configTable && "sort" in configTable )
		spawnList.sort ( configTable.sort )
	if ( configTable && "count" in configTable )
	{
		if (configTable.count >= spawnList.len())
		{
			printl("You are requesting more spawns than there are spawn positions!")
		}
		else
		{
			local nList = []
			local used = {}
			local tries = 0
			while ( tries++ < configTable.count * 4 && nList.len() < configTable.count )
			{
				local use_idx = RandomInt( 0, spawnList.len()-1 )
				if ( ! (use_idx in used ) )
				{
					nList.append( spawnList[use_idx] )
					used[use_idx] <- true
				}
			}
			spawnList = nList
		}
	}
	if (spawnList.len())
	{
		CacheSpawnTables( entityGroup )  // since we arent calling SpawnSingle, cache ones then just spawn directly
		foreach (idx, val in spawnList)  // or should this just call SpawnSingleOn?
		{
			// @todo: this seems clearer - except it does a Cache each time, which often times out and may not be safe
//			SpawnSingleOn( entityGroup, val )   // so for now, just do the direct call
			SpawnEntityGroup( entityGroup, val, val.GetOrigin(), val.GetAngles() )
		}
	}
}

// could these return the post-place-list-CB list or entity array?
function SpawnSingle( entityGroup, entityAt = null, pos = null, ang = null )
{
	CacheSpawnTables( entityGroup )
	SpawnEntityGroup( entityGroup, entityAt, pos, ang )
}

function SpawnSingleAt( entityGroup, pos, ang )
{
	SpawnSingle( entityGroup, null, pos, ang )
}

function SpawnSingleOn( entityGroup, entityAt )
{
	SpawnSingle( entityGroup, entityAt, entityAt.GetOrigin(), entityAt.GetAngles() )
}