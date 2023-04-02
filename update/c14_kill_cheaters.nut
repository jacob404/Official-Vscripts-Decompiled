function KillCheater()
{
	if ( (!activator) || (!activator.IsPlayer()) || (NetProps.GetPropInt( activator, "movetype" ) == 8) )
		return;
	
	if ( activator.IsSurvivor() )
	{
		local maxIncap = Convars.GetFloat( "survivor_max_incapacitated_count" );
		if ( "SurvivorMaxIncapacitatedCount" in DirectorScript.GetDirectorOptions() )
			maxIncap = DirectorScript.GetDirectorOptions().SurvivorMaxIncapacitatedCount;
		
		activator.SetReviveCount( maxIncap );
		activator.SetHealthBuffer( 0 );
	}
	
	activator.TakeDamage( activator.GetHealth(), 32, Entities.FindByClassname( null, "worldspawn" ) );
}