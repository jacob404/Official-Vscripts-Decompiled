Msg("----------------------FINALE SCRIPT------------------\n")

StageDelay <- 0
PreEscapeDelay <- 0
if ( Director.GetGameModeBase() == "coop" || Director.GetGameModeBase() == "realism" )
{
	StageDelay <- 5
	PreEscapeDelay <- 5
}
else if ( Director.GetGameModeBase() == "versus" )
{
	StageDelay <- 10
	PreEscapeDelay <- 15
}

//-----------------------------------------------------
PANIC <- 0
TANK <- 1
DELAY <- 2
ONSLAUGHT <- 3
//-----------------------------------------------------

DirectorOptions <-
{
 	A_CustomFinale_StageCount = 14
	
	A_CustomFinale1			= ONSLAUGHT
	A_CustomFinaleValue1	= "c14m1_gauntlet"
	A_CustomFinale2 		= DELAY
	A_CustomFinaleValue2 	= StageDelay
	A_CustomFinale3 		= TANK
	A_CustomFinaleValue3 	= 1	
	A_CustomFinale4 		= DELAY
	A_CustomFinaleValue4 	= StageDelay
	A_CustomFinale5 		= PANIC
	A_CustomFinaleValue5 	= 2
	A_CustomFinale6 		= DELAY
	A_CustomFinaleValue6 	= StageDelay
	A_CustomFinale7			= ONSLAUGHT
	A_CustomFinaleValue7 	= "c14m1_gauntlet"
	A_CustomFinale8 		= DELAY
	A_CustomFinaleValue8 	= StageDelay
	A_CustomFinale9			= TANK
	A_CustomFinaleValue9	= 1
	A_CustomFinale10 		= DELAY
	A_CustomFinaleValue10 	= StageDelay
	A_CustomFinale11 		= PANIC
	A_CustomFinaleValue11 	= 2	
	A_CustomFinale12 		= DELAY
	A_CustomFinaleValue12 	= StageDelay
	A_CustomFinale13 		= TANK
	A_CustomFinaleValue13 	= 2
	A_CustomFinaleMusic13	= "Event.TankMidpoint_Metal"
	A_CustomFinale14 		= DELAY
	A_CustomFinaleValue14 	= PreEscapeDelay
	//-----------------------------------------------------

	ProhibitBosses = true
} 

//-----------------------------------------------------

// number of cans needed to escape.
NumCansNeeded <- 8

// fewer cans in single player since bots don't help much
/*if ( Director.IsSinglePlayerGame() )
{
	NumCansNeeded <- 6
}*/
//-----------------------------------------------------
//      INIT
//-----------------------------------------------------

GasCansTouched          <- 0
GasCansPoured           <- 0

//NavMesh.UnblockRescueVehicleNav()

//-----------------------------------------------------

function GasCanTouched()
{
    GasCansTouched++
    Msg(" Touched: " + GasCansTouched + "\n")   
	
    EvalGasCansPouredOrTouched()    
}
    
function GasCanPoured()
{
    GasCansPoured++
    Msg(" Poured: " + GasCansPoured + "\n")

    if ( GasCansPoured == NumCansNeeded )
    {
        Msg(" needed: " + NumCansNeeded + "\n") 
        EntFire( "relay_generator_ready", "Trigger" )
    }

    EvalGasCansPouredOrTouched()
}

function EvalGasCansPouredOrTouched()
{
    TouchedOrPoured <- GasCansPoured + GasCansTouched
    Msg(" Poured or touched: " + TouchedOrPoured + "\n")
}
//-----------------------------------------------------

function OnBeginCustomFinaleStage( num, type )
{
	printl( "Beginning custom finale stage " + num + " of type " + type );
	
	if ( num == 7 )
	{
		EntFire( "relay_lighthouse_off", "Trigger" );
	}
}
