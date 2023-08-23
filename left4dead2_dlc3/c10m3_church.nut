Msg("Initiating Church Panic Event\n");

EntFire( "@director", "PanicEvent", 0 )
EntFire( "relay_enable_chuch_zombie_loop", "trigger", "", 90 )

DirectorOptions <-
{
}
