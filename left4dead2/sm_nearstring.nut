// Helper functions for string comparison
//
// Note: Currently unused, used to be used in the stage parameter setting 

//=========================================================
// returns lowest of 3 values
function min3( v1, v2, v3 )
{
	local mv = v1
	if (v2 < mv)
		mv = v2
	if (v3 < mv)
		mv = v3
	return mv
}

//=========================================================
// returns a "distance" value - using the Damerau Levenshtein Distance model (wikipedia, etc)
function near_strings( str1, str2 )
{
	// really we should reimplement this in C++ and just call in
	//   but hey, we only do this at start of map, so probably not too bad
	local d = array(str1.len()+1)
	local i,j
	for (i=0; i<str1.len()+1; i++)
	{
		d[i]=array(str2.len()+1)
		d[i][0]=i
	}
	for (j=1;j<str2.len()+1;j++)
		d[0][j]=j

	for (i=1; i<str1.len(); i++)
	{
		for (j=1; j<str2.len(); j++)
		{
			local cost = 1
			if ( str1[i-1] == str2[j-1] )
				cost = 0
			d[i][j] = min3( d[i-1][j] + 1, d[i][j-1] + 1, d[i-1][j-1] + cost )     // delete, insert, sub
			if (i>1 && j>1 && str1[i-1]==str2[j-2] && str1[i-2]==str2[j-1])        // transpose
				d[i][j] = min3( d[i][j], d[i-2][j-2] + cost, 1000 )  // cheat since i know max here is length of string+2 ish
		}
	}

	local ret = d[str1.len()-1][str2.len()-1]

	return ret
}

//=========================================================
// 
function _stageValidateTable( table, valid_strings )
{
	local tab_unseen = []
	local temp_unseen = []
	foreach (idx, val in template)
	{
		if (idx.slice(0,4)!="opt_")
			if (!(idx in table))
			{
				temp_unseen.append(idx)
			}
	}
	foreach (idx, val in table)
	{
		if (!(idx in template))
		{
			local best_idx = -1
			local best_near = 100
			foreach (potential_idx, toss_val in template)
			{
				local near_val = near_strings(potential_idx, idx)
				if (near_val < best_near)
				{
					best_idx = potential_idx
					best_near = near_val
				}
			}
			if (best_near <= 2) // within 2 transpositions
				printl("WARNING: You have " + idx + " in table, but " + best_idx + " is in template - typo?")
			// warn anyway for now
			tab_unseen.append(idx)
		}
	}

	// look for close strings someday!
	if (tab_unseen.len() + temp_unseen.len() > 0)
	{
		printl("Potential errors in table " + table.debug_name)
		foreach (val in tab_unseen)
			printl("  " + val + " is in the table but not part of the template")
		foreach (val in temp_unseen)
			printl("  " + val + " is in the template but was not found in the table")
	}
	if (temp_unseen.len())
		table.missing_fields <- true

	return tab_unseen.len() + temp_unseen.len()
}

//=========================================================
//=========================================================
function stageTypoCheck( stage_tables )
{
	local warnings = 0
	foreach (val in stage_tables)
	{
		stageDebugPrintl("Typo check on " + val.debug_name )
		warnings += _stageValidateTable ( val, StageInfo_TableTemplate )
	}
	stageDebugPrintl("Stage data checked and " + warnings + " potential issue(s)")
}

