//-----------------------------------------------------
//
//
//-----------------------------------------------------
Msg("Initiating c10m5_houseboat_finale script\n");

//-----------------------------------------------------
ERROR		<- -1
PANIC 		<- 0
TANK 		<- 1
DELAY 		<- 2
SCRIPTED 	<- 3
//-----------------------------------------------------

StageDelay <- 0
if ( Director.GetGameMode() == "coop" )
{
	StageDelay <- 5
}
else if ( Director.GetGameMode() == "versus" )
{
	StageDelay <- 10
}

PreEscapeDelay <- 0
if ( Director.GetGameMode() == "coop" )
{
	PreEscapeDelay <- 5
}
else if ( Director.GetGameMode() == "versus" )
{
	PreEscapeDelay <- 15
}

DirectorOptions <-
{	
	 
	A_CustomFinale_StageCount = 8
	 
	A_CustomFinale1 		= PANIC
	A_CustomFinaleValue1 	= 2	
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
	A_CustomFinale7 		= TANK
	A_CustomFinaleValue7 	= 1
	A_CustomFinale8 		= DELAY
	A_CustomFinaleValue8 	= PreEscapeDelay
	 
	 
	TankLimit = 1
	WitchLimit = 0
	CommonLimit = 20	
	HordeEscapeCommonLimit = 15	
	EscapeSpawnTanks = false
	//SpecialRespawnInterval = 80

}


function EnableEscapeTanks()
{
	printl( "Chase Tanks Enabled!" );
	
	MapScript.DirectorOptions.EscapeSpawnTanks <- true
}