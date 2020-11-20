//-------------------------------------------------------
// Autogenerated from 'placeable_resource.vmf'
//-------------------------------------------------------
PlaceableResource <-
{
	//-------------------------------------------------------
	// Required Interface functions
	//-------------------------------------------------------
	function GetSpawnList()
	{
		local spawnEnts =
		[
			EntityGroup.SpawnTables.hint,
		]
		return spawnEnts
	}

	//-------------------------------------------------------
	function GetEntityGroup()
	{
		return EntityGroup
	}

	//-------------------------------------------------------
	// Table of entities that make up this group
	//-------------------------------------------------------
	EntityGroup =
	{
		SpawnTables =
		{
			hint = 
			{
				SpawnInfo =
				{
					classname = "env_instructor_hint"
					hint_allow_nodraw_target = "1"
					hint_alphaoption = "0"
					hint_auto_start = "1"
					hint_binding = "+use"
					hint_caption = "Default Dynamic Hint!"
					hint_color = "255 255 255"
					hint_forcecaption = "1"                 // diff
					hint_icon_offscreen = "icon_tip"
					hint_icon_offset = "0"
					hint_icon_onscreen = "use_binding"
					hint_instance_type = "2"                // show multiple
					hint_nooffscreen = "0"                  // 0/1
					hint_pulseoption = "0"
					hint_range = "130"                      // 130/300
					hint_shakeoption = "0"
					hint_static = "0"                       // 0/1 - 1 is show on hud, show in world
					hint_target = "prop_resource"
					hint_timeout = "0"
					targetname = "hint"
					origin = Vector( 0, 0, 28.2918 )
					connections =
					{
						OnUser4 =
						{
							cmd1 = "!selfEndHint0-1"
							cmd2 = "!selfKill0.01-1"
						}
					}
				}
			}
		}
	} // EntityGroup
} // PlaceableResource

RegisterEntityGroup( "HintShell", HintShell )
