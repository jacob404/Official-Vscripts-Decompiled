///////////////////////////////////////////////////////////////////////////////
//
// sm_stages.nut
// 
// Helper code for table based "stage definitions" - load, merge, etc
//
///////////////////////////////////////////////////////////////////////////////

// debug setup/helpers
stageDebug <- false

function stageDebugPrintl( s )
{
	if (stageDebug)
		printl(s)
}

stageDebugPrintl( " Including stage helper script.")

//-------------------------------------
// this is the template for what a stageTable looks like
stageData_Template <-
{
	name         = "stage_data_template"
	params   = {}
	callback = null        // function to call when stage starts
	trigger  = null        // trigger to entfire when stage starts
}

SpecialNames <- [ "Boomer", "Charger", "Hunter", "Jockey", "Spitter", "Smoker" ]

// This is the actual function to move the parameters from the table into the master DirectorOptions
function ParseStageParams( params )
{
	// check any special fields first
	if ( "DefaultLimit" in params )
	{
		foreach ( val in SpecialNames )
		{
			local limitstring = val + "Limit"
			SessionOptions[limitstring] = params.DefaultLimit
		}
	}
	
	// then the generic mapping
	foreach (idx, val in params )
	{
		if (idx != "DefaultLimit")
		{
			if (idx in SessionOptions)
			{
				stageDebugPrintl("Changing " + idx + " from " + SessionOptions[idx] + " to " + val );
				SessionOptions[idx] = val
			}
			else 
			{
				stageDebugPrintl("Adding index " + idx + " in SessionOptions table to set")
				SessionOptions[idx] <- val
			}
		}
	}
}

// Evaluate the current Stage table to make sure it makes some sense...
// i.e. check for
//   Errors
//      Total<Type> > 0 but <Type>Limit = 0 or MaxSpecials = 0
//      TotalSpecials > 0 but MaxSpecials = 0
//   Warnings   
//      MaxSpecials < <Type>Limit
function StageInfo_SanityCheckParams( params )
{
	local maxSpecials = -1
	if ("MaxSpecials" in params)
		maxSpecials = params.MaxSpecials

	foreach ( val in SpecialNames )
	{
		local totalStr = "Total" + val + "s"
		local limitStr = val + "Limit"
		
		local totalVal = (totalStr in params) ? params[totalStr] : -1
		local limitVal = (limitStr in params) ? params[limitStr] : -1

		if (totalVal > 0)  // we have a total set
		{
			if (limitVal == 0 || maxSpecials == 0)
				printl("Stage Table Error: " + totalStr + " is " + totalVal + " but " + limitStr + " is " + limitVal + " and MaxSpecials is " + maxSpecials )
		}

		if (maxSpecials < limitVal)
			printl("Stage Table Warning: " + limitStr + " is " + limitVal + " but MaxSpecials is " + maxSpecials)
	}

	if ("TotalSpecials" in params)
	{
		local totalSpec = params.TotalSpecials
		if (totalSpec > 0 && maxSpecials == 0)
			printl("Stage Table Error: You have TotalSpecials set to " + totalSpec + " but MaxSpecials is 0...")
	}
}

//=========================================================
// Pass in a StageTable (and optional table of default fallbacks) - this merges them, then actually sets them
scripthelp_StageInfo_Execute <- "Execute a stage table, i.e. move parameters to DirectorOptions, do callbacks and so on"
function StageInfo_Execute( stageInfo, stageDefaults = null )
{
	// @can call the typo checker here if you want - but for now we arent going to

	// merge down the parameters 
	if ("params" in stageInfo)
	{
		ParseStageParams( stageInfo.params )

		if (stageDefaults != null && "params" in stageDefaults)  // @TODO: comment still true
		{   // still wrong for specials per - need to figure that out... do all specials before? after? 
			// even worse, if stage has specialsper than shouldnt allow any of the sub-fields from defaults to override
			foreach (idx, val in stageDefaults.params )
			{
				if (!(idx in stageInfo.params) && (idx in SessionOptions))
				{
					if (!(idx in SpecialNames) || !("DefaultLimit" in stageInfo.params))
					{
						stageDebugPrintl(" default changing " + idx + " from " + SessionOptions[idx] + " to " + val );
						SessionOptions[idx] = val
					}
				}
			}
		}
	}
	else
	{
		if ("params" in stageDefaults)
			ParseStageParams( stageDefaults )
	}

	StageInfo_SanityCheckParams( SessionOptions )

	if (stageDebug)
	{
		if ("name" in stageInfo)
			printl("Running stage " + stageInfo.name + " with SessionOptions")
		foreach (idx, val in SessionOptions )	
			printl("  DO." + idx + " = " + val);

		if ( "callback" in stageInfo )
			printl(" and now gonna call callback " + stageInfo.callback )
			
		if ( "trigger" in stageInfo )
			printl(" and now gonna entfire trigger " + stageInfo.trigger )
	}

	if ("callback" in stageInfo)
		stageInfo.callback.call(this, stageInfo)

	if ("trigger" in stageInfo && stageInfo.trigger != null)
	{
		if (typeof(stageInfo.trigger) != "string")
			printl("WARNING!! you are passing " + stageInfo.trigger + " to trigger, but it isnt a String!!!")
		else
			EntFire(stageInfo.trigger, "Trigger")
	}

	if ( "type" in stageInfo )
	{
		SessionOptions.ScriptedStageType = stageInfo.type
	}
	else if (stageDefaults != null && ("type" in stageDefaults) )
	{
		SessionOptions.ScriptedStageType = stageDefaults.type
	}
	
	if ("value" in stageInfo)
	{
		SessionOptions.ScriptedStageValue = stageInfo.value
	}
	else if (stageDefaults != null && ("value" in stageDefaults) )
	{
		SessionOptions.ScriptedStageValue = stageDefaults.value
	}

	// so you can just return the result of Execute if you want
	return SessionOptions.ScriptedStageType
}

///////////////////////////////////////////////////////////////////////////////
// Special Stage Helper
//
// this is basically an "example" of a more sophisticated stage manager
//   allowing some chances/randomization and so on
// Wouldn't really suggest using this (though it does work)
//   
// If you want to do a more sophisticated stage model, prob better to just write one
///////////////////////////////////////////////////////////////////////////////

//=========================================================
// adds stages_used and used_count to stage_info as it goes, but copies new stage_list table info
scripthelp_CheckForSpecialStage <- "Helper for picking a random special stage based on stage_info table"
function CheckForSpecialStage( level, stage_list, stage_info )
{
	if (!("chance" in stage_info))
		return
	local per_level = 0
	if ("earliest" in stage_info)
		if (level < stage_info.earliest)
			return
	if ("per_level" in stage_info)
		per_level = stage_info.per_level
	local effective_chance = stage_info.chance + per_level * level
	if ("max_allowed" in stage_info)
	{
		local used_count = 0
		if ("used_count" in stage_info)
			used_count = stage_info.used_count
		if (used_count >= stage_info.max_allowed)
			return null
	}
//	printl("Forcing special stage ps had " + RandomFloat(0,100.0) + " for " + effective_chance)
	if (RandomFloat(0,100.0) < effective_chance)     
	{
		local use_idx = -1
		if (! ("stages_used" in stage_info))
			stage_info.stages_used <- []

		if (stage_info.stages_used.len() == stage_list.len())
		{
			printl("We have used every special stage... recycling")
			stage_info.stages_used <- []
		}
		local usable_idxs = []
		for (local stage_idx = 0; stage_idx < stage_list.len(); stage_idx ++)
		{
			if ( ! ( stage_idx in stage_info.stages_used) )
			{
				if ("levelrange" in stage_list[stage_idx])
				{
					if ( stage_list[stage_idx].levelrange[0] != -1)
						if ( stage_list[stage_idx].levelrange[0] > level)
							continue;
					if ( stage_list[stage_idx].levelrange[1] != -1)
						if ( stage_list[stage_idx].levelrange[1] < level)
							continue;
				}
				usable_idxs.append(stage_idx)
			}
		}         
		if (usable_idxs.len() == 0)
			return null

		local new_idx = usable_idxs[RandomInt(0,usable_idxs.len()-1)]
		local new_stage = stage_list[new_idx]

		// scale it here - how do we scale non-params? should we really write a fallback? ugh
		if ("scaletable" in new_stage)
		{
			foreach (scale_info in new_stage.scaletable)
			{
				if (scale_info.var in new_stage.params)
				{
					if ( level < 1 )
						level = 1
					new_stage.params[scale_info.var] *= (scale_info.scale*(level-1))
					printl("Scaling " + scale_info.var + " to " + new_stage.params[scale_info.var])
				}
				else
					printl("ScriptedMode: Warning! you cant scale " + scale_info.var + " if it isnt in your params!")
			}
		}

		if (!("used_count" in stage_info))
			stage_info.used_count <- 0
		stage_info.used_count++
		stage_info.stages_used.append(new_idx)

		printl("Stages: Picked " + new_idx + " which is " + new_stage.name)

		return new_stage
	}
	return null
}



