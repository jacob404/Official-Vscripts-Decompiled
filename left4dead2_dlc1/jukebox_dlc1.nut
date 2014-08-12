
// flip this on to enable debugging spew
DBG <- ::JUKEBOX_DEBUG <- true

// this value controls how often the "rare" song will play on the jukebox
RareSongChance <- 20


function SwitchRecords()
{
	StopAllMusic()
	
	// play needle scratch sound
	EntFire( EntityGroup[14].GetName(), "playsound", 0 )
	
	// switch disks
	EntFire( EntityGroup[7].GetName(), "setanimation", "replace", 0 )
	EntFire( EntityGroup[7].GetName(), "setdefaultanimation", "diskspin", 0.1 )
}

function PlaySong()
{	
	local random_chance = RandomInt( 0, RareSongChance )
	if( random_chance == 0 )
	{
		// play the rare song
		StopAllMusic()
		if(DBG) printl("==================== playing rare music ")
		
		// play record starting sound
		//EntFire( EntityGroup[13].GetName(), "playsound", 0 )
	
		RareSongList.PlayRandomSong()
	}
	else
	{
		// play a normal song
		StopAllMusic()
		if(DBG) printl("==================== playing normal music ")
		
		// play record starting sound
		EntFire(  EntityGroup[13].GetName(), "playsound", 0 )
		
		NormalSongList.PlayRandomSong()
	}
}


function StopAllMusic()
{
	if(DBG) printl("==================== stopping music ")
	// blindly stop regular music
	EntFire( EntityGroup[1].GetName(), "stopsound", 0 )
	EntFire( EntityGroup[2].GetName(), "stopsound", 0 )
	EntFire( EntityGroup[3].GetName(), "stopsound", 0 )
	EntFire( EntityGroup[4].GetName(), "stopsound", 0 )
	EntFire( EntityGroup[5].GetName(), "stopsound", 0 )
	
	//stop rare music
	EntFire( EntityGroup[10].GetName(), "stopsound", 0 )
	EntFire( EntityGroup[11].GetName(), "stopsound", 0 )
}


class SongList {

	constructor( _songs, _menu_model, _skin_start, _horde_timer, _fire_on_play_ballad )
	{
		songs = _songs
		skin_start = _skin_start
		menu_model = _menu_model
		horde_timer = _horde_timer
		fire_on_play_ballad = _fire_on_play_ballad
		
		playstate = array( songs.len(), 1 )
		UnplayedSongCount = playstate.len()
		
		if(DBG) printl("================== SONG ZERO " + songs[0] )
	}
	
	songs = null
	skin_start = null
	playstate = null
	menu_model = null
	horde_timer = null
	UnplayedSongCount = null
	LastSongPlayed = -1
	fire_on_play_ballad = null

	DBG = ::JUKEBOX_DEBUG
	

	
	function ResetPlayState()
	{
		if(DBG) printl("============ All songs have been played.  Resetting the song count.")
		// set all the songs to be unplayed
		playstate = array( playstate.len(), 1 )
		UnplayedSongCount = playstate.len()
	}
	
	function PlayRandomSong()
	{	
		if(DBG) printl("============= The unplayed song count is: " + UnplayedSongCount )
		
		if( UnplayedSongCount == 0 )
		{
			ResetPlayState()
		}
		
		
		// pick a random song, and if the song is the same as the last song that played, pick another one
		// this prevents the same song from being played twice between songlist shuffles
		local randompick = 0
		do
		{
			randompick = RandomInt(0, UnplayedSongCount-1)
			if( randompick == LastSongPlayed )
			if(DBG) printl("========== random pick is " + randompick + " and last song played is " + LastSongPlayed + " unplayed count is " + UnplayedSongCount + " - rerolling" )
		}
		while ( randompick == LastSongPlayed && UnplayedSongCount != 1 )
		
		
		foreach(i, song in songs )
		{
			if( playstate[i] )
			{
				if( randompick == 0 )
				{
					// mark song as having been played
					playstate[i] = 0
					
					// store last song played
					LastSongPlayed = i
					if(DBG) printl("===============--- storing last song played :" + LastSongPlayed )
					
					if(DBG) printl("============= Choosing song : " + i + " with skin " + (skin_start+i) )
					EntFire( songs[i].GetName(), "playsound", "0", 0 )
					EntFire( menu_model.GetName(), "skin", skin_start+i, 0 )
					UnplayedSongCount -= 1
					
					if( i == 3 )
					{
						// play the song?  check to see if there is anyone within 800 units
						local FindEntity = null
						FindEntity = Entities.FindByClassnameWithin( FindEntity, "player", horde_timer.GetOrigin(), 600 )
						if(DBG) printl("=========FindEntity = " + FindEntity )
						
						// all we want to do is eat your brains
						EntFire( horde_timer.GetName(), "enable", 0 )
					}
					else
					{
						EntFire( horde_timer.GetName(), "disable", 0 )
					}
					
					// we fire a game event when the ballad is played
					if ( fire_on_play_ballad && i == 4 )
					{
						if(DBG) printl("============= song is 4, firing to " + fire_on_play_ballad.GetName() )					
						EntFire( fire_on_play_ballad.GetName(), "FireEvent", 0 )
					}
					
					return
				}
				else
				{
					randompick--
				}
			}
		}
		
	}
}


// create the song lists
NormalSongList <- SongList( EntityGroup.slice(1, 5+1 ), EntityGroup[8], 2, EntityGroup[6], EntityGroup[15] ) // 5 songs, skins start at 2
RareSongList <- SongList( EntityGroup.slice(10, 11+1 ), EntityGroup[8], 6, EntityGroup[6], null ) // 2 song, skin starts at 6

