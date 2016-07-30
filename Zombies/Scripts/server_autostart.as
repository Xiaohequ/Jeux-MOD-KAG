// dedicated serverinitialize script
// use server variables in server_autoconfig.cfg
// sv_gamemode - sets game mode eg. /sv_gamemode "TDM"
// sv_mapcycle - sets map cycle eg. /sv_mapcycle "mapcycle.cfg";
// leave blank to use default map cycle in gamemode Rules folder

void Configure()
{
    v_driver = 0;  // disable video
    s_soundon = 0; // disable audio
}

void InitializeGame()
{
	print("Load "+ sv_gamemode +" Game Script");
	RegisterFileExtensionScript("Scripts/MapLoaders/GenerateZombieMapFromKAGGen.as","kaggen.cfg");
	// RegisterFileExtensionScript("Scripts/MapLoaders/BasePNGLoader.as","png");
	// RegisterFileExtensionScript( "Scripts/MapLoaders/GenerateFromKAGGen.as", "kaggen.cfg" );
	if (getNet().CreateServer())
	{
		print("Initializing Game Script");
		print("Loading Game Rules scripts");
		LoadRules(  "Rules/" + sv_gamemode + "/gamemode.cfg" );
		print("Loading Game map cycle");
		LoadMapCycle( "Rules/" + sv_gamemode + "/mapcycle.cfg" );
		print("Loading map");
		LoadNextMap();
	}
}
