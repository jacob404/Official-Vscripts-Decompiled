HelicopterList <- []
HelicopterIndex <- 0

//-------------------------------------------------------
function GetChopperIndex()
{
	local index = HelicopterIndex // get from table

	// reshuffle if we exhausted the list
	if( index == GetHelicopterCount()-1 )
	{
		HelicopterIndex = 0
			
		RandomizeHelicopterList()
	}
	else
	{
		HelicopterIndex++
	}

	return index
}
	
//-------------------------------------------------------
function GetHelicopterCount()
{
	return HelicopterList.len()
}

//-------------------------------------------------------
function RandomizeHelicopterList()
{
	local n = GetHelicopterCount()
	
	for( local i = 0; i < n - 1; i++)
	{
		local j = i + rand() / (RAND_MAX / (n - i) + 1)
		local t = HelicopterList[j]
		HelicopterList[j] = HelicopterList[i]
		HelicopterList[i] = t
	}
}

//-------------------------------------------------------
function SummonHelicopter()
{
	local chopperIndex = GetChopperIndex()
	EntFire( HelicopterList[chopperIndex].relayName, "trigger", 0 )
}

//-------------------------------------------------------
function HelicopterEnd()
{	
	FireScriptEvent( "on_helicopter_end", null ) // true = available 
}