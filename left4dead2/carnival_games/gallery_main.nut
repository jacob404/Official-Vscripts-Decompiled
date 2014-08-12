// length of round in seconds
RoundLength <- 45.0
RoundLengthLeft <- RoundLength

// the player's score
CurrentScore <- 0

// the score to beat to get the prize!
HighScore <- 750

RedScoreValue <- 10
BlueScoreValue <- 10
GreenScoreValue <- 100
PeanutScoreValue <- -100


// Get a valid target
function GetTargetToSpawn()
{
	if( RandomInt(0,12) == 0 )
	{
		if( TargetAvailableArray[7] )
		{
			EntFire( CounterArray[14].GetName(), "playsound", "0", 0.5 ) // play lil' peanut spawn sound
			return 8 // return lil' peanut's
		}
	}
	else if( RandomInt(0,6) == 0 )
	{
		if( TargetAvailableArray[6] )
		{
			EntFire( CounterArray[11].GetName(), "playsound", "0", 0.5 ) // play moustachio spawn sound
			return 7 // return moustachio's index
		}
	}
	
	local targetcount = 0
	for( local i = 0; i < 6; i++ )
	{
		if( TargetAvailableArray[i] )
		{
			targetcount++
		}
	}
	
	local randompick = RandomInt(0, targetcount-1)
	
	
	
	for( local i = 0; i < 6; i++ )
	{
		if( TargetAvailableArray[i] )
		{
			if( randompick == 0 )
			{
				return i+1
			}
			else
			{
				randompick--
			}
		}
	}
	
	return 1 // this shouldn't ever be hit
}


//--------------------------------------------------------------------------------------------
// Spawners
//--------------------------------------------------------------------------------------------
function SpawnTargetInLane( lane )
{
	local side = RandomInt( 0, 1 )
	local spawnPosition = ( side * 6 ) + lane 
	local targetnum = GetTargetToSpawn()
	//printl("========================------------------------------------------GetTargetToSpawn() returned: " + targetnum )
	TargetAvailableArray[targetnum - 1] = false

	//printl(" ===============================++++++++++++++++++++++ Spawning" + targetnum + " at position: " + spawnPosition + " at speed: " +  TargetTravelSpeed[CurrentGameStage])
	EntFire( MoveLinearArray[targetnum].GetName(), "TeleportToTarget", PositionArray[spawnPosition].GetName(), 0.0 )
	// set speed
	EntFire( MoveLinearArray[targetnum].GetName(), "SetSpeed", TargetTravelSpeed[CurrentGameStage], 0.0 )
	
	EntFire( MoveLinearArray[targetnum].GetName(), "ResetPosition", side? "1" : "0", 0 )
	EntFire( MoveLinearArray[targetnum].GetName(), "SetPosition", side? "0" : "1", 0.5 )
	EntFire( TargetArray[targetnum].GetName(), "Enable", 0, 0.01 )
	
	// reset hit state
	TargetHitStateArray[targetnum] = false
}


//--------------------------------------------------------------------------------------------
// Timers
//--------------------------------------------------------------------------------------------

TimerEnabled <- false
StartTime <- Time()
LastThink <-Time()
Started <- false


StageTwoStartTime <- 8    // time to start stage two (in seconds)
StageThreeStartTime <- 20 // time to start stage three (in seconds)


// last timer positions
LastPosTimer_1 <- 0
LastPosTimer_2 <- 0


// target timers
TimerStageOneNextThink <- 0
TimerStageTwoNextThink <- 0
TimerStageThreeNextThink <- 0

// game stage
CurrentGameStage <- 0



// lane spawn time array
LaneSpawnTimeArray <- [0,0,0,0,0,0]


// time it takes for the target to cross the screen
MinTargetTravelTime <-  [0,6,5,4]
PadTime 			<-	[6,1,2,1]
TargetTravelSpeed <- [125,125,150,188]

// target timer functions
function ResetLaneSpawnTime( lane )
{
	LaneSpawnTimeArray[lane] = RandomFloat( MinTargetTravelTime[CurrentGameStage], MinTargetTravelTime[CurrentGameStage]+PadTime[CurrentGameStage] ) + Time()
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
			EntFire( CounterArray[i].GetName(), "SetPosition", fabs( ( (setval * 0.1) - 1.0 ) ) ) // subtracting from 1 to reverse
		}
		
		// only fire the output if the position has changed from the previous position
		if( i == 2 && ( LastPosTimer_2 != ( setval * 0.1 ) ) )
		{
			EntFire( CounterArray[i].GetName(), "SetPosition", fabs( ( (setval * 0.1) - 1.0 ) ) ) // subtracting from 1 to reverse
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

// run once
initialized <- false

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
	
	if( !initialized )
	{
		// close the bonus indicator
		EntFire( CounterArray[7].GetName(), "open", 0 )
		initialized = true
	}
}


//
// Stage Control
//
function StageControl()
{
	
    if( StageThreeStartTime + StartTime <= Time() )
	{
		CurrentGameStage = 3
	}
		
	else if( StageTwoStartTime + StartTime <= Time() )
	{
		CurrentGameStage = 2
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
			LastThink = StartTime
		}
		
		if ( Started == true  )
		{
			// this controls the timer
			local time = ( RoundLength - (Time() - StartTime) ) * 10
			if ( time <= 0 )
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
	
	for( local i=1; i<7; i++ )
	{
		// Target popup
		if( LaneSpawnTimeArray[i-1] <=  Time() )
		{
		//	printl("=======================++++++++++++++++ Lane " + i + " Spawning")
			SpawnTargetInLane(i)
			ResetLaneSpawnTime( i-1 )
		}	
	}
}



//
// StartGame -- this function starts the gallery game
//
function StartGame()
{	
	// initialize the 
	InitializeGame()
	
	// starts the clock
	StartTimer( RoundLength )

}

function InitializeGame()
{
	CurrentGameStage = 0
	// reset the score
	ResetScore()
	
	
	// initialize target hit states
	for( local i=0; i<8; i++ )
	{
		TargetHitStateArray[i] = false
	}

	// reset lane spawn time
	for( local i=0; i<6; i++ )
	{
		ResetLaneSpawnTime(i)
	}
	
	CurrentGameStage = 1

}

//
// StartTimer
//
function StartTimer( seconds )
{
	TimerEnabled = true
	StartTime <- Time()
	SetTimer( seconds * 10 )
	
	
	
	//printl("============starting the timer_0 timer forward")
	EntFire( CounterArray[0].GetName(), "Startforward", 0 )
}

//
// StopTimer -- function is called when the game ends
//
function StopTimer()
{
	//printl( "================================================Timer Stopped" )
	TimerEnabled = false
	SetTimer(0)
	Started = false
	
	EntFire( CounterArray[0].GetName(), "SnapToStartPos", 0 )
	
	StopGame()
	
}


///////////////////////////////////////////////////////////////////////////////
// StopGame
///////////////////////////////////////////////////////////////////////////////
function StopGame()
{
	EntFire( self.GetName(), "fireuser1" )
	//printl( "===================THE ROUND HAS ENDED !!!" );

	// check highscore
	if( CurrentScore >= HighScore )
	{
		EntFire( self.GetName(), "fireuser2" )
	}
}



//--------------------------------------------------------------------------------------------
// Counters
//--------------------------------------------------------------------------------------------
function SetCounter( score )
{
				
	local divider = 10
	local setval = 0
	local tempTime = score;
	for ( local i = 0; i<=3; i++ )
	{
		setval = ( tempTime % divider ) + 0.01
		tempTime = tempTime / divider
				
		EntFire( CounterArray[i+3].GetName(), "SetPositionImmediately", fabs( ( (setval * 0.1) - 1.0 ) ) ) // subtracting from 1 to reverse
	}
}

function ScorePoints( value )
{
	// play the score sound
	EntFire( EntityGroup[4].GetName(), "Playsound", 0 ) 
	
	// adjust the score
	CurrentScore += value
	
	// clamp to zero
	if( CurrentScore < 0 )
	{
		CurrentScore = 0
	}
	
	// set the counter to match the new score
	SetCounter( CurrentScore )	
}

function ResetScore()
{
	CurrentScore = 0
	SetCounter( CurrentScore )
}



TargetAvailableArray <- [1,1,1,1,1,1,1,1]

// called when targets go to their closet
function RegisterTargetDocked( targetnum )
{
	//printl("=========================================----------------- RegisterTaretDocked() setting target :" + targetnum + " to true " )
	TargetAvailableArray[ targetnum - 1 ] = true
}

// false hit state indicates the target is not hit
TargetHitStateArray <- [ 0,0,0,0,0,0,0,0,0 ] 


function LookupTargetValue( TargetNumber )
{

	switch( TargetNumber )
	{
		case 1: case 2: case 3:
			return RedScoreValue
			
		
		case 4: case 5: case 6:
			return BlueScoreValue
			
		
		case 7:
			return GreenScoreValue
			
		
		case 8:
			return PeanutScoreValue
			
		
		default:
			return 0
	}
	
}


function PlayRegularScoreSound()
{
	EntFire( CounterArray[12].GetName(), "playsound", "0", 0 ) // play point score sound
}


LastGroupHit <- 0


function CheckCombo( TargetNumber )
{
	local grouphit = 0

	switch( TargetNumber )
	{
		case 1: case 2: case 3: // red targets
			{
				PlayRegularScoreSound()
				grouphit = 1
				break
			}
					
		case 4: case 5: case 6: // blue targets
			{
				PlayRegularScoreSound()
				grouphit = 2
				break
			}
		case 7:		// moustachio
			EntFire( CounterArray[13].GetName(), "playsound", "0", 0 ) // play moustachio point sound
			EntFire( CounterArray[9].GetName(), "playsound", "0", 0.3 ) // play moustachio hit sound
			return
			
		default:		// lil'peanut is default
			EntFire( CounterArray[15].GetName(), "playsound", "0", 0.3 ) // play lilpeanut hit sound
			EntFire( RotatorArray[10].GetName(), "playsound", "0", 0.0 ) // play lilpeanut buzzer point sound
			grouphit = 0
			return
	}
	
	if( grouphit == LastGroupHit )
	{
		AwardBonus()
		LastGroupHit = 0
	}
	else
	{
		LastGroupHit = grouphit
	}
}

function AwardBonus()
{
	local color = "255 255 255";
	if ( LastGroupHit == 1 )
	{
		color = "255 0 0";
	}
	else
	{
		color = "0 0 255";	
	}
		
		
	EntFire( CounterArray[8].GetName(), "color", color ); // combo_x is entitygroup 8
		
	EntFire( CounterArray[7].GetName(), "close", 0 )
	
	EntFire( RotatorArray[9].GetName(), "playsound", "0", 0 ) // play bonus point award sound
	
	
	// add the bonus
	CurrentScore += 20
}

// ===========================================
// scoring for targets
// ===========================================
function RegisterTargetHit( TargetNumber ) 
{
	// only score points if the timer has time on the clock
	// targets visible after the timer expires are not recorded as valid hits
	if( Started )
	{
		//printl("================================----------------------checking target: " + TargetNumber )
		if( !TargetHitStateArray[TargetNumber] )
		{
			CheckCombo( TargetNumber )
			//printl("================================----------------------registering hit!" )
			EntFire( RotatorArray[TargetNumber].GetName(), "PressIn", 0, 0 )
			//printl("=======================================POINTS: " + LookupTargetValue( TargetNumber )  )
			ScorePoints( LookupTargetValue( TargetNumber ) )
			TargetHitStateArray[TargetNumber] = true
		}
	}

}