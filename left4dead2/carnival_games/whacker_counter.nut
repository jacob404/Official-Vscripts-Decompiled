CurrentScore <- 0

// score to blow up machine
HighScore <- 42

// target hit state.  used to prevent target from scoring more than one hit per target popup
TargetOneHit <- false
TargetTwoHit <- false
TargetThreeHit <- false
TargetFourHit <- false
TargetFiveHit <- false



function SetCounter( score )
{
				
	local divider = 10
	local setval = 0
	local tempTime = score;
	for ( local i = 0; i<2; i++ )
	{
		setval = ( tempTime % divider ) + 0.01
		tempTime = tempTime / divider
				
		EntFire( EntityGroup[i].GetName(), "SetPosition", (setval * 0.1) )
	}
}


function ScoreHit()
{
	// play the score sound
	EntFire( EntityGroup[4].GetName(), "Playsound", 0 ) 
	
	
	// increment the score
	CurrentScore++
	
	// set the counter to match the new score
	SetCounter( CurrentScore )
	
	//throw out a ticket
	EntFire( EntityGroup[6].GetName(), "Start", "0", 0 )
	EntFire( EntityGroup[6].GetName(), "Stop", "0", 0.1 )
	
	CheckScore()
}

function ResetScore()
{
	TargetOneHit = false
	TargetTwoHit = false
	TargetThreeHit = false
	TargetFourHit = false
	TargetFiveHit = false

	CurrentScore = 0
	SetCounter( CurrentScore )
}

function CheckScore()
{
	if( CurrentScore >= HighScore )
	{
		EntFire( EntityGroup[5].GetName(), "trigger", 0 )
	}
}

// ===========================================
// scoring for target 1
// ===========================================
function ScoreHitTargetOne()
{
	if( !TargetOneHit )
	{
		ScoreHit()
		TargetOneHit = true
	}
}

function ClearHitTargetOne()
{
	TargetOneHit = false
}

// ===========================================
// scoring for target 2
// ===========================================
function ScoreHitTargetTwo()
{
	if( !TargetTwoHit )
	{
		ScoreHit()
		TargetTwoHit = true
	}
}

function ClearHitTargetTwo()
{
	TargetTwoHit = false
}

// ===========================================
// scoring for target 3
// ===========================================
function ScoreHitTargetThree()
{
	if( !TargetThreeHit )
	{
		ScoreHit()
		TargetThreeHit = true
	}
}

function ClearHitTargetThree()
{
	TargetThreeHit = false
}

// ===========================================
// scoring for target 4
// ===========================================
function ScoreHitTargetFour()
{
	if( !TargetFourHit )
	{
		ScoreHit()
		TargetFourHit = true
	}
}

function ClearHitTargetFour()
{
	TargetFourHit = false
}

// ===========================================
// scoring for target 5
// ===========================================
function ScoreHitTargetFive()
{
	if( !TargetFiveHit )
	{
		ScoreHit()
		TargetFiveHit = true
	}
}

function ClearHitTargetFive()
{
	TargetFiveHit = false
}
