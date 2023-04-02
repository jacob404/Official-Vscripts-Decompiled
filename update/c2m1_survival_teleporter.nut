Msg("Initiating c2m1_survival_teleporter Script\n");

local c2m1_teleporter = Entities.FindByName( null, "survival_teleporter" );
if ( c2m1_teleporter )
{
	c2m1_teleporter.ValidateScriptScope();
	local teleporterScope = c2m1_teleporter.GetScriptScope();
	teleporterScope.InputTeleport <- function()
	{
		if ( activator )
		{
			local carryAttacker = NetProps.GetPropEntity( activator, "m_carryAttacker" );
			local pummelAttacker = NetProps.GetPropEntity( activator, "m_pummelAttacker" );
			
			if ( carryAttacker || pummelAttacker )
				return false;
		}
		return true;
	}
}