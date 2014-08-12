//-----------------------------------------------------
//
//
//-----------------------------------------------------
Msg("Initiating c7m3_port script\n");

DirectorOptions <-
{
	TankLimit = 0
	WitchLimit = 0
	ProhibitBosses = true
}



function GeneratorButtonPressed()
{
    Msg("**c7m3_port GeneratorButtonPressed **\n")    
	EntFire( "@director", "EndScript" )
	EntFire( "generator_start_model", "Enable" )
    EntFire( "generator_start_model", "ForceFinaleStart" )
	EntFire( "generator_start_model", "Disable" )
}
