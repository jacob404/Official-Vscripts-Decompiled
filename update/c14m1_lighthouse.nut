Msg(" lighthouse map script "+"\n")

// number of cans needed to escape.
NumCansNeeded <- 8


DirectorOptions <-
{
	CommonLimit = 30
}

//NavMesh.UnblockRescueVehicleNav()

EntFire( "progress_display", "SetTotalItems", NumCansNeeded )

function GasCanTouched(){}
function GasCanPoured(){}