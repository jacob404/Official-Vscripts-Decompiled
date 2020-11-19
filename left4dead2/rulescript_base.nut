// Testbed for decision-engine (response rules) hookup.

function rrDebugPrint( string )
{
	printl( "RR_TESTBED: " + string )
}

function rrPrintTable( tabl, prefix = "\t" )
{
	foreach ( k,v in tabl )
		print(prefix + k + " : " + v + "\n")
}


// Define an individual "static" criterion, varying between a bottom and top integral value
class Criterion {
	//constructor
	constructor( k, b, t )
	{
		key = k
		bottom = b
		top = t
	}
	
	//member function
	function Describe()
	{
		printl( "Criterion " + key + " " + bottom + ".." + top )
	}
	
	//property
	key = null;
	bottom = null;
	top = null;
}

// Define a functor criterion, where the comparator is a function returning a bool
class CriterionFunc {
	//constructor
	constructor( k, f )
	{
		key = k
		func = f
	}
	
	//member function
	function Describe()
	{
		printl( "Criterion functor " + key + " -> " + func )
	}
	
	//property
	key = null;
	func = null;
}

// Multiple lines
// response <responsegroupname>
// {
//		[permitrepeats]   ; optional parameter, by default we visit all responses in group before repeating any
//		[sequential]	  ; optional parameter, by default we randomly choose responses, but with this we walk through the list starting at the first and going to the last
//		[norepeat]		  ; Once we've run through all of the entries, disable the response group
//		responsetype1 parameters1 [nodelay | defaultdelay | delay interval ] [speakonce] [odds nnn] [respeakdelay interval] [soundelvel "SNDLVL_xxx"] [displayfirst] [ displaylast ] weight nnn
//		responsetype2 parameters2 [nodelay | defaultdelay | delay interval ] [speakonce] [odds nnn] [respeakdelay interval] [soundelvel "SNDLVL_xxx"] [displayfirst] [ displaylast ] weight nnn
//		etc.
// }


// Represents an individual rule as sent from script to C++
// TODO: handle ApplyContextToWorld
class RRule {
	constructor( name, crits, _responses, _group_params )
	{
		rulename = name
		criteria = crits
		responses = _responses
		group_params = _group_params
		
		// type-check
		assert( responses.len() > 0 )
		
		// make a shallow copy of selection_state to avoid overwriting shared state
		// (otherwise changes made in one instance will affect all others)
		selection_state = clone selection_state
		
		
		// make an array of one 'false' per response (eg no response has played yet)
		selection_state.playedresponses <- responses.map( @(x) false )
	}
	
	function Describe( verbose = true )
	{
		printl( rulename + "\n" + criteria.len() + " crits, " + responses.len() + " responses" )
		if ( verbose )
		{
			foreach (crit in criteria) 
			{
				crit.Describe()
			}
			foreach (resp in responses)
			{
				resp.Describe()
			}
			printl("selection_state:")
			foreach ( k,v in selection_state )
				print("\t" + k + " : " + v + "\n")
			print("\n")
		}
	}
		
	// for some reason can't resolve this from file scope?
	function ChooseRandomFromArray( arr ) 
	{
		local l = arr.len()
		if ( l > 0 )
		{
			return arr[RandomInt( 0, l - 1 ) ]
		}
		else
			return null
	}
	
	// When a rule matches, call this to pick a response. 
	// TODO: test
	function SelectResponse() 
	{
		if ( Convars.GetFloat("rr_debugresponses") > 0 )
		{
			print("Matched rule: " )
			Describe( false )
		}
		if ( group_params.permitrepeats ) 
		{
			// just randomly pick a response 
			local R = ChooseRandomFromArray( responses )
			
			if ( Convars.GetFloat("rr_debugresponses") > 0 )
			{
				print("Matched " )
				R.Describe()
			}
				
			return R
		}
		// else...
		// get a list of response *indexes* that haven't played yet
		local unplayed_resps = []
		foreach (idx,val in selection_state.playedresponses) 
		{
			if ( !val ) // if not been played... 
			{ 
				unplayed_resps.push( idx )
			}
		}
		
		if ( unplayed_resps.len() == 0 ) // out of unplayed responses, what do we do?
		{
			if (group_params.norepeat) 
			{
				Disable()
				return // do nothing
			}
			else //reset
			{
				selection_state.playedresponses = responses.map( @(x) false )
			}
		}
		
		// okay, now pick a response
		if ( group_params.sequential )
		{
			local retval = selection_state.nextseq
			selection_state.nextseq = (selection_state.nextseq + 1) % responses.len() // advance sequential counter
			assert( selection_state.playedresponses[retval] == false )
			// mark this response as played
			selection_state.playedresponses[retval] = true 
			local R = responses[retval]
			
			if ( Convars.GetFloat("rr_debugresponses") > 0 )
			{
				print("Matched " )
				R.Describe()
			}
			return R
		}
		else
		{
			// choose randomly from available unplayed responses
			local retval = ChooseRandomFromArray( unplayed_resps )
			selection_state.playedresponses[retval] = true
			local R = responses[retval]
			
			if ( Convars.GetFloat("rr_debugresponses") > 0 )
			{
				print("Matched " )
				R.Describe()
			}
			return R
		}
	}
	
	// tell the response engine to disable me
	function Disable()
	{
		printl( "TODO: rule " + rulename + " wants to disable itself." )
	}
	
	// properties
	rulename = null;
	criteria = [];
	responses = [];
	group_params = null;
	
	// handles the 'response group' state which is 
	// used to pick the next response in sequence, etc
	selection_state = { 
		nextseq = 0 , // next response to play if 'sequential' is true
		playedresponses = [], // an array containing one bool per response -- indicating whether it's played or not, to handle 'permitrepeats'
	}
}
