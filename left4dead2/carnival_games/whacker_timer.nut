
TimerEnabled <- false
StartTime <- Time()
Started <- false


// length of round in seconds
RoundLength <- 30.0
RoundLengthLeft <- RoundLength

StageTwoStartTime <- 8    // time to start stage two (in seconds)
StageThreeStartTime <- 20 // time to start stage three (in seconds)



// last timer positions
LastPosTimer_1 <- 0
LastPosTimer_2 <- 0


// target timers
TimerStageOneNextThink <- 0
TimerStageTwoNextThink <- 0
TimerStageThreeNextThink <- 0

// timer start state
TimerOneEnabled <- true
TimerTwoEnabled <- false
TimerThreeEnabled <- false



// timer functions
function EnableTimerStageOne()
{
	TimerOneEnabled <- true
}

function EnableTimerStageTwo()
{
	TimerTwoEnabled <- true
}

function EnableTimerStageThree()
{
	TimerThreeEnabled <- true
}

// set timer functions
function SetTimerStageOneNextThink()
{
	TimerStageOneNextThink = RandomFloat( 1.5, 3.0 ) + Time()
}

function SetTimerStageTwoNextThink()
{
	TimerStageTwoNextThink = RandomFloat( 3.0, 6.0 ) + Time()
}

function SetTimerStageThreeNextThink()
{
	TimerStageThreeNextThink = RandomFloat( 1.0, 3.0 ) + Time()
}

//=========================================================
// SetTimer
//=========================================================
function SetTimer( timeLeft )
{
	RoundLengthLeft = timeLeft
			
	local divider = 10
	local setval = 0
	local tempTime = RoundLengthLeft

	
	for ( local i = 0; i<3; i++ )
	{
		setval = ( tempTime % divider ) + 0.01
		tempTime = tempTime / divider
		
		
		// only fire the output if the position has changed from the previous position
		if( i == 1 && ( LastPosTimer_1 != ( setval * 0.1 ) ) )
		{
			EntFire( EntityGroup[i].GetName(), "SetPosition", (setval * 0.1) )
		}
		
		// only fire the output if the position has changed from the previous position
		if( i == 2 && ( LastPosTimer_2 != ( setval * 0.1 ) ) )
		{
			EntFire( EntityGroup[i].GetName(), "SetPosition", (setval * 0.1) )
		}
		
		// store last positions
		if( i == 1 )
		{
			LastPosTimer_1 = (setval * 0.1)
		}
		if( i == 2 )
		{
			LastPosTimer_2 = (setval * 0.1)
		}
	}
		
}
///////////////////////////////////////////////////////////////////////////////
// Think
///////////////////////////////////////////////////////////////////////////////
function Think()
{
	if( TimerEnabled )
	{
		StageControl()
		TimerControl()
		TargetControl()
	}
	else if ( ContinueMode )
	{
		//printl("=============================Entering continue mode")
		ContinueModeControl()
	}
		
}


//
// Stage Control
//
function StageControl()
{
	// is it time to enable the second stage?
	if( !TimerTwoEnabled )
	{
		if( StageTwoStartTime + StartTime <= Time() )
		{
			EnableTimerStageTwo()
		}
	}
	
	// is it time to enable the third stage?
	if( !TimerThreeEnabled )
	{
		if( StageThreeStartTime + StartTime <= Time() )
		{
			EnableTimerStageThree()
		}
	}

}


// continue timer flag
ContinueMode <- false
ContinueTimeLength <- 10.0
ContinueStartTime <- 0.0

function SetContinueMode( state )
{
	ContinueMode = state
}

function BeginContinueMode()
{
	SetContinueMode( true ) // enable continue mode
	ContinueStartTime <- Time() // set continue mode start time
	
	// start the first dial spinnin'
	EntFire( EntityGroup[0].GetName(), "Startforward", 0 )
}

function EndContinueMode()
{
	//printl("=====================ENDING continue mode.")
	ContinueStartTime = ContinueTimeLength // make the timer think time is up
}

//
// Continue mode control
//
function ContinueModeControl()
{
	local ContinueTime = ( ContinueTimeLength - (Time() - ContinueStartTime ) ) * 10

	//printl("=======================Continue time is : " + ContinueTime )
	if ( ContinueTime <= 0 )
	{
		//printl("============================================ Continue Time UP!" )
		StopTimer()
		EntFire( EntityGroup[0].GetName(), "SnapToStartPos", 0 )
		
		SetContinueMode( false )
		return
	}
	else
	{
		//printl("============================================ Timer Thinking....: " + ContinueTime )
		SetTimer( ContinueTime.tointeger() )
	}
	
}

//
// Timer Control
//
function TimerControl()
{
		if ( Started == false ) 
		{
			// printl( "==============================================Started" )
			Started = true
			StartTime = Time()
		}
		
		if ( Started == true  )
		{
			// this controls the timer
			local time = ( RoundLength - (Time() - StartTime) ) * 10
			if ( time <= 0 && !ContinueMode )
			{
				EntFire( self.GetName(), "fireuser1" )
				// printl( "================================================Timer expired" )
				StopTimer()
				return		
			}

			SetTimer( time.tointeger() )

		}
}

//
// Target Control
//
function TargetControl()
{

	if( TimerOneEnabled )
	{
		if( TimerStageOneNextThink <=  Time() )
		{
			PopupRandomTarget()
			SetTimerStageOneNextThink()
		}
	
	}
	
	if( TimerTwoEnabled )
	{
		if( TimerStageTwoNextThink <=  Time() )
		{
			PopupRandomTarget()
			SetTimerStageTwoNextThink()
		}
	}
	
	if( TimerThreeEnabled )
	{
		if( TimerStageThreeNextThink <=  Time() )
		{
			PopupRandomTarget()
			SetTimerStageThreeNextThink()
		}
	}
	
}

//
// PopupRandomTarget fires EntityGroup references that match func_door entities
//
function PopupRandomTarget()
{
	local target = RandomInt( 3, 7 ) // 3 - 7 correlates to the entity group reference in the logic script
	
	switch(target)
	{
		case 3:
		EntFire( EntityGroup[target].GetName(), "toggle", "0.0" )
		break
		
		case 4:
		EntFire( EntityGroup[target].GetName(), "toggle", "0.0" )
		break
		
		case 5:
		EntFire( EntityGroup[target].GetName(), "toggle", "0.0" )
		break
		
		case 6:
		EntFire( EntityGroup[target].GetName(), "toggle", "0.0" )
		break
		
		case 7:
		EntFire( EntityGroup[target].GetName(), "toggle", "0.0" )
		break
		
		default:
			return
	}
}


//
// StartGame
//
function StartGame()
{
	StartTimer( RoundLength )
}

//
// StartTimer
//
function StartTimer( seconds )
{
	TimerEnabled = true
	StartTime <- Time()
	SetTimer( seconds * 10 )
	
	InitializeTargetTimerState()
	
	EntFire( EntityGroup[0].GetName(), "Startforward", 0 )
}

//
// StopTimer
//
function StopTimer()
{
	TimerEnabled = false
	SetTimer(0)
	Started = false
	
	EntFire( EntityGroup[0].GetName(), "SnapToStartPos", 0 )
	//printl( "================================================Timer Stopped" )
}

//
// InitializeTargetTimerState
//
function InitializeTargetTimerState()
{
	SetTimerStageOneNextThink()
	SetTimerStageTwoNextThink()
	SetTimerStageThreeNextThink()
	
	// reset timer states
	TimerOneEnabled <- true
	TimerTwoEnabled <- false
	TimerThreeEnabled <- false
	
	// reset continue states
	ContinueMode = false
	ContinueTimeLength = 10.0
	ContinueStartTime = 0.0
}