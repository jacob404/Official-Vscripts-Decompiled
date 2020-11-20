// Testbed for decision-engine (response rules) hookup.

IncludeScript("rulescript_base", this)


// The different kinds of available response
// must exactly match ResponseType_t in code.
enum ResponseKind 
{
	none,		// invalid type
	speak,		// it's an entry in sounds.txt
	sentence,	// it's a sentence name from sentences.txt
	scene,		// it's a .vcd file
	response,	// it's a reference to another response group by name
	print		// print the text in developer 2 (for placeholder responses)
	script		// a script function
}


// Emulates a single Response object from RR1, which is eg an individual 'speak' or 'sentence' etc
// A response consists of a Kind (see ResponseKind above), 
// a Target which is a string like "foo.vcd", 
// a Func (option), which is a script function to call before performing Target
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
class ResponseSingle {
	// constructor
	constructor( _kind, _target, _rule,  _func = null, _params = {}  )
	{
		kind = _kind
		target = _target
		rule = _rule
		params = _params
		func = _func 
		
		// assert valid types
		assert( typeof( kind ) == "integer" )
		assert( typeof( params ) == "table" )
	}
	function Describe() 
	{
		print("Response:\n")
		print("\tkind " + kind)
		print("\n\ttarget " + target + "\n" )
		foreach ( k,v in params )
			print("\t" + k + " : " + v + "\n")
	}
	// properties 
	kind = null; // one of the ResponseKind enumerations
	target = null; // will be a string or a function
	func = null;
	params = null; // will be a table
	rule = null; // reference back to the rule to which I belong
	
	cpp_visitor = null; // a field for the C++ code to store whatever opaque info it needs in this object.
}


// Emulates a defined response group from RR1, which consists of several optional
// you pass in a table of configuration variables affecting how entries in the responses array are selected:
// [permitrepeats]   ; optional parameter, by default we visit all responses in group before repeating any
// [sequential]	  ; optional parameter, by default we randomly choose responses, but with this we walk through the list starting at the first and going to the last
// [norepeat]		  ; Once we've run through all of the entries, disable the response group
// [matchonce]	; once this rule matches (at all), disable it.
// so you would call this like
//	RGroupParams( {sequential=true, norepeat=true} )
class RGroupParams {
	// constructor
	constructor( parms = {} )
	{	
		if ( "permitrepeats" in parms && parms.permitrepeats )
			permitrepeats = true
		if ( "sequential" in parms && parms.sequential )
			sequential = true
		if ( "norepeat" in parms && parms.norepeat )
			norepeat = true
		if ( "matchonce" in parms && parms.matchonce )
			matchonce = true
	}
	// properties 
	permitrepeats = false; 
	sequential = false;  
	norepeat = false;  
	matchonce = false;
}	


// A followup event like the old response Then.
// All followups need to expose a function and a 'delay' parameter.
// The callable gets the following parameters:
//	( speaker [ehandle] , query [as table] )
// Build like so:
//  RThen(	"coach",  // target
//			"TLK_FOLLOWUP_WHATEVER", // concept
//			{ foo = 1, bar = "flarb" }, // contexts to add to the followup  (may be null instead)
//			1.5 // delay
//			)
class RThen {
	constructor( _target, _concept, _contexts, _delay )
	{
		// type checking
		assert( typeof(_target) == "string" )
		target = _target
		assert( typeof(_concept) == "string" )
		delay = _delay.tofloat()
		
		// in rr2 "concept" is just another fact in the query
		if ( _contexts == null ) 
		{
			_contexts = {}
		}
		else if ( typeof(_contexts) != "table" )
		{
			throw("RThen() error: _contexts parameter isn't a table or null")
		}
		addcontexts = clone _contexts
		
		addcontexts.concept <- _concept
		func = execute.bindenv(this)
	}
	
	function execute( speaker, query ) 
	{
		// debug prints...
		if ( Convars.GetFloat( "rr_debugresponses" ) > 0 )
		{
			print( "RThen followup called:\n\ttarget: " )
			printl(target)
		
			if ( Convars.GetFloat( "rr_debugresponses" ) >= 2 )
			{
				print( "\taddcontexts: {")
				foreach (k,v in addcontexts)
				{ 
					print("\n\t")
					print(k)
					print(" : ")
					print(v)
				}
				print( "\n}\n\tspeaker: ")
				print( speaker )
			}
			print( "\t(end followup)\n")
		}
		
		// merge addcontexts into query
		foreach (k,v in addcontexts)
		{
			query[k] <- v
		}
		
		if ( target == "all" )
		{
			local expressers = ::rr_GetResponseTargets()
			// attempt disapatch to all listeners
			foreach (name, recipient in expressers)
			{
				local q = rr_QueryBestResponse( recipient, query )
				if ( q )
				{
					rr_CommitAIResponse( recipient, q )
				}
			}
		}
		else if ( target == "any" )
		{
			local expressers = ::rr_GetResponseTargets()
			// test the query against each listener and only play the best match
			local results = []
			foreach (name, recipient in expressers)
			{
				local q = rr_QueryBestResponse( recipient, query )
				if ( q )
				{
					results.push( [recipient, q] )
				}
			}
			if ( results.len() > 0 )
			{
				// find the highest-scoring entry and play that
				local idx = 1
				local best = 0
				while ( idx < results.len() ) 
				{
					if ( results[i][1].score > results[best][1].score )
					{
						best = idx
					}
				}
				rr_CommitAIResponse( results[best][0], results[best][1] )
			}
		}
		else if ( target == "self" )
		{
			local q = rr_QueryBestResponse( speaker, query )
			if ( q )
				rr_CommitAIResponse( speaker, q )
		}
		else
		{	
			local expressers = ::rr_GetResponseTargets()
			if ( target in expressers )
			{
				local q = rr_QueryBestResponse( expressers[target], query )
				if ( q )
				{
					rr_CommitAIResponse( expressers[target], q )
				}
			}
			else
			{
				printl("RRscript warning: couldn't find target " + target )
			}
		}
		
	}

	// properties
	target = null; // this will be one of "any", "all", "coach", etc. I think in the future this wants to be a function?
	addcontexts = null; // a table of {k1:v1, k2:v2} additional facts that will be added to the following query. concept is always present here, from the constructor.
	delay = null; // delay as passed to the code followup class 	
	func = null; // what gets called when the followup triggers
}

// Given a single array representing a criterion,
// return a proper criterion object following these rules
// [a, b, c] becomes a static criterion for key a >= b && <= c
//           use Null for b or c to mean infinity, so that
//           [a, Null, c] means just a <= c (and a >= -infinity )
// [a, b]    if a is a function, becomes a functor criterion where b is called on fact a
//           otherwise becomes [a, b, b] meaning "a is equal to b"
// [a]       if a is a function, becomes a functor criterion like (Null, a)  (eg the function is always called and gets a null fact)
//           otherwise becomes [a, Null, Null], meaning "true if A exists in the query"
// functor criteria must always be functions taking (val, query) where val is the value of a fact (may be Null) and 'query' is a table
function rr_ProcessCriterion( crit )
{
	if ( typeof(crit) == "function" )
	{
		return CriterionFunc( null ) 
	}
	else if ( typeof(crit) == "array" )
	{
		switch( crit.len() )
		{
			case 1:
				if (typeof(crit[0])=="function")
				{
					return CriterionFunc( null, crit[0] )
				}
				else
				{
					assert( typeof(crit[0]) == "string" )
					return Criterion( crit[0], null, null )
				}
				break	
			case 2:
				assert( typeof(crit[0]) == "string" )
				if (typeof(crit[1])=="function")
				{
					return CriterionFunc( crit[0], crit[1] )
				}
				else
				{
					return Criterion( crit[0], crit[1], crit[1] )
				}
				break	
			case 3:
				assert( typeof(crit[0]) == "string" )
				return Criterion( crit[0], crit[1], crit[2] )
				break
			default:
				throw ( "Invalid criterion: " + crit )
		}
	}
	else 
	{
		throw( "Invalid type for criterion: " + typeof(crit) )
	}
}


// Given a single array representing the responses,
// do the ugly work to normalize them into ResponseSingle objects.
// right now the decision of type is made by whether there is a func param or a scenename param.
function rr_ProcessResponse( resp )
{
	local func = null
	local scene = null
	if ( "func" in resp ) 
	{
		func = resp.func
		
		// we still need to store the 'resp' table as a strong reference in the ResponseSingle object
		// so that it doesn't get garbage-collected. .bindenv only stores weak references to objects
		// so you can't count on it to actually hang onto the closure table.
	} 
	if ( "scenename" in resp )
	{
		scene = resp.scenename
	}
	
	local kind = ResponseKind.none
	if ( scene )
	{
		kind = ResponseKind.scene
	}
	else if ( func ) 
	{	
		kind = ResponseKind.script
	}
	else
	{
		print("Unable to parse response: \n")
		resp.Describe()
		return null
	}
	
	return ResponseSingle( kind, scene, null, func, resp )
}

function rr_ProcessRules( rulesarray )
{
	local debug_rules_arr = []
	foreach( rule in rulesarray )
	{
		// need to bind the rr_ProcessCriterion function in a closure containing this environment,
		// otherwise for whatever reason it won't be able to find the Criterion and CriterionFunctor 
		// classes in its scope.
		local coderule = RRule( rule.name, 
			rule.criteria.map( rr_ProcessCriterion.bindenv( this ) ), 
			rule.responses.map( rr_ProcessResponse.bindenv( this ) ),
			rule.group_params  )
		// fix up 'rule' in each response
		foreach ( r in coderule.responses ) 
		{
			r.rule = coderule
		}

		if( !rr_AddDecisionRule( coderule ) )
		{
			throw "Failed to add rule to decision database: " + rule
		}
		// print("-- ADDED RULE--\n")
		// coderule.Describe()
		debug_rules_arr.push(coderule)
	}	
}

// Each individual rule has:
// a name 
// criteria
// responses
//	if the response has a 'func' parameter, it is interpreted to be a script function that gets called with the following two parameters:
//	* query - the entire fact array passed to the matching system
//	* speaker - the 'speaker' param as an entity
//  in addition, it gets a bound environment so that every key in the response table gets seen as a local variable in the function.
// an optional 'group_params'  which emulates the norepeat/sequential/permitrepeats behavior from rr1.
//	it is an RGroupParams object, see above.
// if a response is a function, it gets called with parameters (speaker, query)

// fake rule table to test my parsing 
// g_ignoredecisionrules <- [
// {
// 	name = "CoachSeeSmoker",
// 	criteria = [
// 		[ "concept", "onSeeEnemy" ], // arrays of two entries are considered to be fact = value
// 		[ "speaker", "coach" ],
// 		[ "numAllies", 1, 4 ],	// arrays of three entries are considered to be fact >= x && fact <= y
// 		[ "enemyType", "smoker" ],
// 		[ @(query) (query.GameTime) < 30 ] // arrays of one entry are expected to be functions
// 	],
// 	responses = [
// 		{ scenename = "coach_see_smoker_1.vcd", // if a 'scenename' key is present, this is expected to be a 'scene' response
// 		  soundlevel = 80,
// 		  onFinish = @(query, speaker) speaker.smokersSeen += 1 // expected to be a function
// 		} , {
// 		  func = ZombieFreakout // if a 'func' key is present, this is expected to be a 'do function' response 
// 		} , {
// 		  func = @(query,speaker) speaker.PointAt( query.enemy ) // anonymous functions are ok too
// 		} , {
// 		  scenename = "coach_see_smoker_2.vcd",
// 		  sndlevel = 90,
// 		  onFinish = @(speaker, query) speaker.smokersSeen += 1
// 		}
// 	],
// 	group_params = RGroupParams({ permitrepeats = false, sequential = true, norepeat = false })
// },
// { // another rule to test that I don't inadvertently write state shared between rules
// 	name = "Dummy", 
// 	criteria = [
// 		[ "concept", "dummy" ], // arrays of two entries are considered to be fact = value
// 		[ "speaker", "zombie" ]
// 	],
// 	responses = [
// 		{ scenename = "zombie.vcd", // if a 'scenename' key is present, this is expected to be a 'scene' response
// 		  sndlevel = 80,
// 		  onFinish = @(speaker, query) speaker.smokersSeen += 1 // expected to be a function
// 		} 
// 	],
// 	group_params = RGroupParams( ) // default 
// }
// ]


IncludeScript("response_rules")