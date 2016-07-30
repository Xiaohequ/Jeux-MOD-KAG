
//Zombies gamemode logic script
//Modded by Eanmig edited by GB
#define SERVER_ONLY

#include "ZD_Rules.as";
#include "ZD_SpawnSys.as";
#include "ZS_Technology.as";


void onRestart( CRules@ this )
{
    printf("Re/Starting reading rules script: " + getFilenameWithoutPath(getCurrentScriptName()) );
	//get config file path
	string path = getFilePath(getCurrentScriptName());
	path = path.substr(0,path.findLast("Scripts"));
	// init
    ZombiesSpawns spawns();
    ZombiesCore core(this, spawns);
    Config(core, path);
	core.SetupBases();
	SetupZombieTech();
    this.set("core", @core);
    this.set("start_gametime", getGameTime() + core.warmUpTime);
    this.set_u32("game_end_time", getGameTime() + core.gameDuration); //for TimeToEnd.as
	
	//do some thing after init
	// AddBot("bot");
}

 void SetupZombieTech(){
    SetupScrolls(getRules());
	Vec2f[] zombiePlaces;
	getMap().getMarkers("zombie portal", zombiePlaces );
	if (zombiePlaces.length>0)
	{
		for (int i=0; i<zombiePlaces.length; i++)
		{
			spawnPortal(zombiePlaces[i]);
		}
	}
	Vec2f[] techPlaces;
	getMap().getMarkers("random tech", techPlaces );
	if (techPlaces.length>0)
	{
		for (int i=0; i<techPlaces.length; i++)
		{
			spawnRandomTech(techPlaces[i]);
		}
	}

	Vec2f[] scrollPlaces;
	getMap().getMarkers("random scroll", scrollPlaces );
	if (scrollPlaces.length>0)
	{
		for (int i=0; i<scrollPlaces.length; i++)
		{
			spawnRandomScroll(scrollPlaces[i]);
		}
	}

}

//simple config function - edit the variables below to change the basics

void Config(ZombiesCore@ this, const string path)
{
    string configstr = path + "config.cfg";
	
	ConfigFile cfg = ConfigFile( configstr );
	
	//how long for the game to play out?
    s32 gameDurationMinutes = cfg.read_s32("game_time",-1);
    if (gameDurationMinutes <= 0)
    {
		this.gameDuration = 0;
		getRules().set_bool("no timer", true);
	}
    else
    {
		this.gameDuration = (getTicksASecond() * 60 * gameDurationMinutes);
	}
	
    bool destroy_dirt = cfg.read_bool("destroy_dirt",true);
	getRules().set_bool("destroy_dirt", destroy_dirt);
	bool gold_structures = cfg.read_bool("gold_structures",false);
	bool scrolls_spawn = cfg.read_bool("scrolls_spawn",false);
	bool techstuff_spawn = cfg.read_bool("techstuff_spawn",false);
	warn("GS SERVER: "+ gold_structures);
	getRules().set_bool("gold_structures", gold_structures);
	
	s32 max_zombies = cfg.read_s32("max_zombies",80);
	if (max_zombies<20) max_zombies=20;
	getRules().set_s32("max_zombies", max_zombies);
	getRules().set_bool("scrolls_spawn", scrolls_spawn);
	getRules().set_bool("techstuff_spawn", techstuff_spawn);
    //spawn after death time 
    this.spawnTime = (getTicksASecond() * cfg.read_s32("spawn_time", 30));

}

//pass stuff to the core from each of the hooks

void spawnPortal(Vec2f pos)
{
	server_CreateBlob("ZombiePortal",-1,pos+Vec2f(0,-24.0));
}


void spawnRandomTech(Vec2f pos)
{
	bool techstuff_spawn = getRules().get_bool("techstuff_spawn");
	if (techstuff_spawn)
	{
		int r = XORRandom(2);
		// if (r == 0)
			// server_CreateBlob("RocketLauncher",-1,pos+Vec2f(0,-16.0));
		// else
		if (r == 1)
			server_CreateBlob("megasaw",-1,pos+Vec2f(0,-16.0));
	}
}

void spawnRandomScroll(Vec2f pos)
{
	bool scrolls_spawn = getRules().get_bool("scrolls_spawn");
	if (scrolls_spawn)
	{
		int r = XORRandom(3);
		if (r == 0)
			server_MakePredefinedScroll( pos+Vec2f(0,-16.0), "carnage" );
		else
		if (r == 1)
			server_MakePredefinedScroll( pos+Vec2f(0,-16.0), "midas" );				
		else
		if (r == 2)
			server_MakePredefinedScroll( pos+Vec2f(0,-16.0), "tame" );				
	}
}


void onNewPlayerJoin( CRules@ this, CPlayer@ player )
{
	RulesCore@ core;
    this.get("core", @core);

	if (core is null) return;
	
	if (player.getTeamNum() != this.getSpectatorTeamNum())
	{
		player.server_setTeamNum(0);
	}
}

void onPlayerLeave( CRules@ this, CPlayer@ player )
{
}
