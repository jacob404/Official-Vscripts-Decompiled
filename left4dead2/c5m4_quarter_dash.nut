// Table that allows users to specify the order waypoints are to be spawned.
//
// Also allows setting of the startingTouchCount so a waypoint can be spawned
// as if it has already been touched by a player.  For example, startingTouchCount =3
// would spawn a waypoint as if it has been touched 3 times and only requres one
// more touch before clearing.
//
// This table is optional and if it isn't provided then Dash will look for short_waypoint_* and waypoint_* entities
// and spawn them in suffix-sorted order
CustomWaypointList <-
[
	{ targetName = "short_waypoint_001", startingTouchCount = 3 },
	{ targetName = "short_waypoint_002", startingTouchCount = 3 },
	{ targetName = "short_waypoint_003", startingTouchCount = 3 },
	{ targetName = "short_waypoint_004", startingTouchCount = 3 },
	{ targetName = "short_waypoint_005", startingTouchCount = 3 },
	{ targetName = "waypoint_006",		 startingTouchCount = 0 },
	{ targetName = "short_waypoint_007", startingTouchCount = 3 },
	{ targetName = "short_waypoint_008", startingTouchCount = 3 },
	{ targetName = "waypoint_009",		 startingTouchCount = 0 },
	{ targetName = "short_waypoint_010", startingTouchCount = 3 },
	{ targetName = "short_waypoint_011", startingTouchCount = 3 },
	{ targetName = "short_waypoint_012", startingTouchCount = 3 },
	{ targetName = "waypoint_013",		 startingTouchCount = 0 },
	{ targetName = "short_waypoint_014", startingTouchCount = 3 },
	{ targetName = "float_waypoint",	 startingTouchCount = 0 }, // waypoint at the "Float" mini-finale
	{ targetName = "short_waypoint_016", startingTouchCount = 3 },
	{ targetName = "short_waypoint_017", startingTouchCount = 3 },
	{ targetName = "short_waypoint_018", startingTouchCount = 3 },
	{ targetName = "short_waypoint_019", startingTouchCount = 3 },
	{ targetName = "waypoint_020",		 startingTouchCount = 0 },
	{ targetName = "short_waypoint_021", startingTouchCount = 3 },
	{ targetName = "short_waypoint_022", startingTouchCount = 3 },
	{ targetName = "short_waypoint_023", startingTouchCount = 3 },
	{ targetName = "waypoint_024",		 startingTouchCount = 0 },
	{ targetName = "waypoint_025",		 startingTouchCount = 0 },
	{ targetName = "waypoint_026",		 startingTouchCount = 0 },
	{ targetName = "short_waypoint_027", startingTouchCount = 3 },
	{ targetName = "waypoint_028",		 startingTouchCount = 0 },
]


function MapGameplayStart()
{
	// prevent the checkpoint door from changing the level when survivors reach the checkpoint
	EntFire( "checkpoint_entrance", "setrotationdistance", 180, 0 )
	EntFire( "checkpoint_entrance", "close" )
	EntFire( "checkpoint_entrance", "open", 0, 1 )
	EntFire( "checkpoint_entrance", "disable", 0, 2 )
}