
//Zombies gamemode logic script
//Modded by Eanmig edited by GB
#define SERVER_ONLY

#include "ZS_Rules.as";
#include "ZS_SpawnSys.as";


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
	
    this.set("core", @core);
    this.set("start_gametime", getGameTime() + core.warmUpTime);
    this.set_u32("game_end_time", getGameTime() + core.gameDuration); //for TimeToEnd.as
	
	//do some thing after init
	// AddBot("bot");
}

//simple config function - edit the variables below to change the basics

void Config(ZombiesCore@ this, const string path)
{
    string configstr = path + "config.cfg";
	
	ConfigFile cfg = ConfigFile( configstr );
	
	//how long to wait for everyone to spawn in?
    s32 warmUpTimeSeconds = cfg.read_s32("warmup_time",30);
    this.warmUpTime = (getTicksASecond() * warmUpTimeSeconds);
	
	bool auto = cfg.read_bool("auto_duration", true);
	this.auto_duration = auto;
	
	//how long for the game to play out?
	s32 gameDurationSeconds = cfg.read_s32("game_time",-1);
	printf("init duration " + gameDurationSeconds);
	if(auto){
		this.EACH_PLAYER_SUPPL_TIME = gameDurationSeconds;
		this.gameDuration = this.EACH_PLAYER_SUPPL_TIME  * getTicksASecond();
	}else{
		if (gameDurationSeconds <= 0)
		{
			this.gameDuration = 0;
			getRules().set_bool("no timer", true);
		}
		else
		{
			this.gameDuration = (getTicksASecond() * gameDurationSeconds);
		}
	}
	
	this.spawnTime = (getTicksASecond() * cfg.read_s32("spawn_time", 10));
}

void onNewPlayerJoin( CRules@ this, CPlayer@ player )
{
	RulesCore@ core;
    this.get("core", @core);

	if (core is null) return;
	
	if (player.getTeamNum() != this.getSpectatorTeamNum())
	{
		if(!this.isMatchRunning())
			player.server_setTeamNum(0);
		else
			player.server_setTeamNum(1);
	}
}

// void onPlayerLeave( CRules@ this, CPlayer@ player )
// {
// }
