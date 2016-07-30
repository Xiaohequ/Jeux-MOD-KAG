// default startup functions for autostart scripts

void RunServer()
{
    if (getNet().CreateServer())
    {
		print("Loading Game Rules scripts");
        LoadRules(  "Rules/" + sv_gamemode + "/gamemode.cfg" );
		
		print("Loading Game map cycle");
        LoadMapCycle( "Rules/" + sv_gamemode + "/mapcycle.cfg" );

		print("Loading map");
        LoadNextMap();
    }
}

void ConnectLocalhost()
{
    getNet().Connect( "localhost", sv_port );
}

void RunLocalhost()
{
    RunServer();
    ConnectLocalhost();
}

void LoadDefaultMenuMusic()
{
	if(s_menumusic)
	{
		CMixer@ mixer = getMixer();	 
		if (mixer !is null) 
		{
			mixer.ResetMixer();
			mixer.AddTrack( "Sounds/Music/world_intro.ogg", 0 );
			mixer.PlayRandom( 0 );
		}
	}
}
