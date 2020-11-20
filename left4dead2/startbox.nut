// this is attached to the startbox core center entity, and thinks to determine if the survivors are in or out
// it is then deleted by the manager code

sbWidth <- 0   // used internally to manage the "if inside" math - passed in at creation time
sbDepth <- 0

// @todo: unimplemented - variables to allow more configurable/flexible startbox behavior/triggering
//   we'll autodefault them, but you can go get the startbox object and tweak them as script data if you want
sbAllInFirst <- true
sbTriggerOnLeave <- true
sbNumberNeeded <- 1   

function SetSBSize( width, depth )
{
	sbWidth = width
	sbDepth = depth
}

function VecDistSq( v1, v2 )
{
	return ( v2.x - v1.x ) * (v2.x - v1.x) + ( v2.y - v1.y ) * (v2.y - v1.y) + ( v2.z - v1.z ) * (v2.z - v1.z)
}

function InStartBox( startent, testent, width = 384, depth = 384 )
{
	local forv = startent.GetForwardVector()

	local offset = testent.GetOrigin() - startent.GetOrigin()
	local for_dot = offset.Dot ( forv )
	if (for_dot < 0)
		for_dot = -for_dot
	local sidv = Vector( forv.y, -forv.x, 0 )
	local sid_dot = offset.Dot( sidv )
	if (sid_dot < 0)
		sid_dot = -sid_dot

	return ( for_dot < depth/2.0 && sid_dot < width/2.0 )
}

allIn <- false
alreadyLeft <- false

print_cnt <- 0

function Think( )
{
	local FindEntity = null
	local num_out = 0

	if (!alreadyLeft)
	{
		while( ( FindEntity = Entities.FindByClassname( FindEntity, "player" ) ) != null )
		{  
			if ( !FindEntity.IsSurvivor() )
				continue

			// loop all the players, make sure in start box
			if (!InStartBox( self, FindEntity, sbWidth, sbDepth ))
			{
				if (allIn && !alreadyLeft)
				{
					// printl("Left the start box!")
					alreadyLeft = true
					g_MapScript.ClearStartBox()
					
					// Notify the map script that a survivor has left the start box.
					if (!g_MapScript.ScriptMode_SystemCall("SurvivorLeftStartBox"))
						Director.ForceNextStage()
				}
				num_out++
			}
		}
		if (!allIn && num_out == 0)
		{   // this should be on an optional param (i.e. "ForceInBeforeLeaving" or something)
			allIn = true
			printl("All in the start box!")
		}
	}
//	if (++print_cnt % 8 == 0)
//		printl("SB out " + num_out + " in " + allIn + " left " + alreadyLeft )
}