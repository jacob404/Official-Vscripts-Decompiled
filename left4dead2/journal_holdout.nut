
function SetupCustom( HUDTable )
{
	// initial write, so we can = from now on, and get an initial value...
	SessionState.Resources <- 0

	// now tweak the hud for our data
	delete HUDTable.Fields.wave
	HUDTable.Fields.resources <- { slot = HUD_RIGHT_TOP, name = "res count", staticstring = "Supplies: ", datafunc = @() SessionState.Resources }

	// should check this if our data has it only... hmmm...
	if ("DataStream" in this && DataStream.len() > 0 && "custom" in DataStream[0])
	{
		if ("rescue" in DataStream[0].custom)
		{
			SessionState.RescueTimer <- 0.01
			HUDTable.Fields.rescue <- { slot = HUD_FAR_LEFT, name = "rescue", staticstring = "R: ", datafunc = @() SessionState.RescueTimer, flags = HUD_FLAG_AS_TIME }
		}
	}
}

// store last count and blink it if it changes?
function ParseCustom( customTable, preorpost )
{
	if (preorpost)
	{
		if ("cans" in customTable)
			foreach (idx,val in customTable.cans)
				DebugDrawBox(Vector(val[0],val[1],val[2]),Vector(10,5,10),Vector(-10,-5,-10),200,40,40,200,SessionState.TimeDraw)
	}
	else
	{
		if ("resources" in customTable)
			SessionState.Resources = customTable.resources
		if ("rescue" in customTable)
			SessionState.RescueTimer = customTable.rescue.tofloat()  // for now
	}
}