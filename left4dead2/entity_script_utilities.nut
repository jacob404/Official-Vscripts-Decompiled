//-------------------------------------------------------
// Entity scripts may include this file to access these helpers
//-------------------------------------------------------
if ( "GetUniqueTargetnameTable" in g_MapScript )
{
	UniqueTargetnames <- g_MapScript.GetUniqueTargetnameTable()
}

if ( "GetReplacementKeys" in g_MapScript )
{
	ReplacementKeys <- g_MapScript.GetReplacementKeys()
}

//-------------------------------------------------------
// Return this group's unique version of a targetname
//-------------------------------------------------------
function LookupInstancedName( targetname )
{
	if ( targetname in UniqueTargetnames )
	{
		return UniqueTargetnames[ targetname ]
	}

	printl( "WARNING: No unique name found for " + targetname )
	return targetname
}

//-------------------------------------------------------
// Return the value for a particular replacement key
//-------------------------------------------------------
function LookupReplacementKey( keyname )
{
	if ( keyname in ReplacementKeys )
	{
		return ReplacementKeys[ keyname ]
	}

//	printl( "WARNING: No replacement key found for " + keyname )
	return keyname
}