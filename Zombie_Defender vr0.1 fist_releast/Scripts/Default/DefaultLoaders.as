
void LoadDefaultMapLoaders()
{
	printf("############ GAMEMODE " + sv_gamemode +" ###########");
	if (sv_gamemode == "TTH" || sv_gamemode == "WAR" ||
		sv_gamemode == "tth" || sv_gamemode == "war") 
	{
		RegisterFileExtensionScript( "Scripts/MapLoaders/LoadWarPNG.as", "png" );
	}
    else if (sv_gamemode == "Challenge" || sv_gamemode == "challenge") 
    {
		RegisterFileExtensionScript( "Scripts/MapLoaders/LoadChallengePNG.as", "png" );
	}
	else if (sv_gamemode == "TDM" || sv_gamemode == "tdm") 
	{
		RegisterFileExtensionScript( "Scripts/MapLoaders/LoadTDMPNG.as", "png" );
	}
	else if(sv_gamemode == "ZD" || sv_gamemode == "zd" ||sv_gamemode == "ZS" || sv_gamemode == "zs")
	{
		printf("register file extension cfg");
		RegisterFileExtensionScript( "Scripts/MapLoaders/GenerateFromKAGGen.as", "cfg" );
		return;
	}
	else
	{
		RegisterFileExtensionScript( "Scripts/MapLoaders/LoadPNGMap.as", "png" );
	}
		
	RegisterFileExtensionScript( "Scripts/MapLoaders/GenerateFromKAGGen.as", "kaggen.cfg" );
}
