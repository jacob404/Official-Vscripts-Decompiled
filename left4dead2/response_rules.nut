// see response_testbed.nut for the definitions of the types used below 


// Each Rule consists of the following fields in a table
// * name		: an arbitrary rule name, for your convenience in debugging.
// * criteria	: an array of criteria that must be met for the rule to be considered a match. 
//		Criteria may be static string/numeric comparisons, or functions. 
// * responses	: an array of individual Response objects, emulating their counterparts in RR1.

// --- CRITERIA
// the 'criteria' section of a rule is a simple list. Criteria fall into two broad groups:
// * STATIC criteria compare a fact (as a number) to a range on a number line, or strings to each other.
//	  So, 'foo > 4', 'foo > 0 and foo < 10', 'foo = 6', ' foo = "bar" ' are all static criteria. These are very fast to match.
// * FUNCTION criteria are arbitrary Squirrel functions returning TRUE or FALSE. They may do any work you like, but
//   incur a 3 microsecond overhead to call, in addition to the work the function itself does. 
// A rule must match all of its static criteria before the function criteria are even tested, so the more narrowly
// constrained your rule, the less of an impact the functions will have.
// Static criteria follow the form:
//   [ name, a, b ] compares the value of key 'name' to see if it is >= a and <= b. 
//   a and b may be null, in which case they represent negative and positive infinity. 
//   See below for examples.
// A function criterion takes one parameter: 'query' and should return a boolean 
// so you could define one ahead of time like
// function FooCriterion(query) {  return query.foo > g_rr.whatever.foo }
// Here's example of different kinds of criteria
// { name = "FakeRule"
//	 criteria = [
//		[ "concept", "PlayerMove" ],	// does the "concept" fact equal "PlayerMove" ?
//		[ "IsCoughing" , 0 ],			// does the "IsCoughing" fact equal zero?
//		[ "NumAllies", 1, null ],		// is "numallies" between 1 and infinity -- ie, is "NumAllies" >= 1 ?
//		[ "Ammo", 2, 8 ],				// is the "ammo" fact >=2 and <= 8?
//		FooCriterion,					// does the function FooCriterion return true when called?
//		@(query) query.blarg % 3 == 0	// anonymous function declared inline -- is fact "blarg" divisible by 3?
//	]

// --- RESPONSES 

// Emulates a single Response object from RR1, which is eg an individual 'speak' or 'sentence' etc
// A response consists of a table with these fields:
// target	: a string like "foo.vcd", 
// func		: which is a script function to call before performing Target (optional)	
//			  this function may be specified by name, or as an anonymous @ function.
// and a Params object which is a table consisting of the optional parameters below. 
//	( Omitting an entry in Params assumes a reasonable default. )
// Optional parameters:
//   nodelay = an additional delay of 0 after speaking
//   defaultdelay = an additional delay of 2.8 to 3.2 seconds after speaking
//   delay interval = an additional delay based on a random sample from the interval after speaking
//   speakonce = don't use this response more than one time (default off)
//	 noscene = For an NPC, play the sound immediately using EmitSound, don't play it through the scene system. Good for playing sounds on dying or dead NPCs.
//   odds = if this response is selected, if odds < 100, then there is a chance that nothing will be said (default 100)
//	 respeakdelay = don't use this response again for at least this long (default 0)
//   soundlevel = use this soundlevel for the speak/sentence (default SNDLVL_TALKING)
//   weight = if there are multiple responses, this is a selection weighting so that certain responses are favored over others in the group (default 1)
//   displayfirst/displaylast : this should be the first/last item selected (ignores weight)
//   then = a Then() object processed as in RR1
//	 onFinish = eventually, a script function to call when the scene finishes (currently not implemented)

// see the "DemonstrateScriptFollowup" concept below for details


// all of this is experimental code not relevant to the running game. 


function rr_CharacterSpeak( speaker, query )
{
      local q = ::rr_QueryBestResponse( speaker, query_params ) // looks up the result, returns null if none found
      if(q) 
            ::rr_CommitAIResponse( speaker, q ) // this actually makes the character speak
}

function DemoScriptFollowupFunction( speaker, query )
{
	print( "DemoScriptFollowupFunction called with speaker = " + speaker + " query = " + query + "\n" )
	// if you wanted to submit this query to the speaker and do a response-lookup with it
	// you could do that like:
	// local response = rr_QueryBestResponse( speaker, query ) // <- send a query to this entity and look for the best matching response.
	// if ( response )							 // <- if a response was found,
	//	rr_CommitAIResponse( speaker, response ) // <- have this entity speak it.
}

// if you want to share a criterion between many rules, you can declare it as its own variable like this:
CriterionIsNotCoughing <- [ "Coughing", 0 ]
CriterionIsc6m3_port  <- [ "map", "c6m3_port" ]  //use for the moveon example below to scope the rule change
CriterionIsAwardProtector  <- [ "awardname","Protector" ]
 
// and then include it into the criteria lists as per the examples below. The "g_rr." part
// is a bit of temporary cruft that will go away once we resolve some questions about scope resolution
// in map .nut files.

// here's a demo of a function that reads a context out of a character, and sets it again. (you can also read context out of the query.)
function DemoWritingContextToCharacter( speaker, query )
{
	// look up a 'bananas' context in the query, add one to it, and write it to the character. write 1 if query has no bananas.
	if ( "bananas" in query ) 
	{
		speaker.SetContext( "bananas", (query["bananas"] + 1).tostring(), 0 )
	}
	else
	{
		speaker.SetContext( "bananas", "1", 0 )
	}
}
// just prints a table to the console
// for scoping reasons too dumb to go into, to access this you'll need
// to actually type 'g_rr.PrintTable'. 

function PrintTable( t )
{
	foreach(k,v in t)
	{
		printl( k + " : " + v )
	}
}

//this is an example set of functions that checks to see if a player just received an award protecting a player.  if they did - don't have the protected player play any friendly fire lines.
function SetAwardSpeech	(speaker, query)
{
	local  ProtectedDude = rr_GetResponseTargets()[ query.subject ]
	ProtectedDude.SetContext( "AwardSpeech", query.who, 10 )
}


function SubjectAward ( query )
{
		if ( "AwardSpeech" in query )
	{ 
		if ( query["AwardSpeech"] == query["subject"] )
		{
			return true
		}
		else
		{
			return false
		}
	}
	else
	{
			return false	
	}
}


g_decisionrules <- [
{
	name = "PlayerMoveOnCoach",
	criteria = [
		[ "concept", "PlayerMoveOn" ], // conceptPlayerMoveOn
		g_rr.CriterionIsNotCoughing,
		[ "Who", "Coach" ],	// isCoach
		g_rr.CriterionIsc6m3_port
	],
	responses = [
		{ scenename = "scenes/Coach/MoveOn01.vcd",
		}
	],
	group_params = RGroupParams({ permitrepeats = true, sequential = false, norepeat = false })
},
{
	name = "PlayerMoveOnGambler",
	criteria = [
		[ "concept", "PlayerMoveOn" ], // conceptPlayerMoveOn
		g_rr.CriterionIsNotCoughing,
		[ "Who", "Gambler" ],	// isgambler
		g_rr.CriterionIsc6m3_port
	],
	responses = [
		{ scenename = "scenes/Gambler/MoveOn01.vcd",
			followup = RThen( "self",  "DemonstrateScriptFollowup", {additionalcontext="whatever"}, 1.23 ) // dispatches a "DemonstrateScriptFollowup" concept back to self
			func = DemoWritingContextToCharacter
		}
		//,{ scenename = "scenes/Gambler/MoveOn02.vcd", // another vcd response
		//}
	],
	group_params = RGroupParams({ permitrepeats = true, sequential = false, norepeat = false })
},
{	// this rule demonstrates how a followup can be an arbitrary script fucntion
	name = "TestBogusGambler",
	criteria = [
		[ "concept", "DemonstrateScriptFollowup" ],
		[ "Who", "Gambler" ],
		g_rr.CriterionIsc6m3_port
	],
	responses = [
		{ func = g_rr.DemoScriptFollowupFunction 	}
	],
	group_params = RGroupParams({ permitrepeats = true, sequential = false, norepeat = false })
},
{
	name = "PlayerMoveOnMechanic",
	criteria = [
		[ "concept", "PlayerMoveOn" ], // conceptPlayerMoveOn
		g_rr.CriterionIsNotCoughing,
		[ "Who", "Mechanic" ],	// isMechanic
		g_rr.CriterionIsc6m3_port
	],
	responses = [
		{ scenename = "scenes/Mechanic/MoveOn01.vcd"
		}
	],
	group_params = RGroupParams({ permitrepeats = true, sequential = false, norepeat = false })
},
{
	name = "PlayerMoveOnProducer",
	criteria = [
		[ "concept", "PlayerMoveOn" ], // conceptPlayerMoveOn
		g_rr.CriterionIsNotCoughing,
		[ "Who", "Producer" ],	// isgambler
		g_rr.CriterionIsc6m3_port
	],
	responses = [
		{ scenename = "scenes/Producer/MoveOn01.vcd"
		}
	],
	group_params = RGroupParams({ permitrepeats = true, sequential = false, norepeat = false })
},
{
	name = "PlayerAwardProtect",
	criteria = [
		[ "concept", "Award" ], // conceptAward
		g_rr.CriterionIsAwardProtector
	],
	responses = [
		{ 
			func = SetAwardSpeech	
		}
	],
	group_params = RGroupParams({ permitrepeats = true, sequential = false, norepeat = false })
},
{
	name = "ProtectedFriendlyFire",
	criteria = [
		[ "concept", "PlayerFriendlyFire" ], 
		[ SubjectAward ]
	],
	responses = [
		{ 
			func = DemoScriptFollowupFunction			
		}
	],
	group_params = RGroupParams({ permitrepeats = true, sequential = false, norepeat = false })
}
]


//rr_ProcessRules( g_decisionrules )



