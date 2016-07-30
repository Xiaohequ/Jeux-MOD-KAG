
//Zombies gamemode rule script
#define SERVER_ONLY

#include "ZS_Structs.as";
#include "RulesCore.as";

shared class ZombiesCore : RulesCore
{
    s32 warmUpTime;
    s32 gameDuration;
    s32 spawnTime;

	s32 gamestart;
	
    ZombiesSpawns@ Zombies_spawns;

    ZombiesCore() {}

    ZombiesCore(CRules@ _rules, RespawnSystem@ _respawns )
    {
        super(_rules, _respawns );
		_rules.set_bool("managed teams",true);
    }
	
    
	
    void Setup(CRules@ _rules = null, RespawnSystem@ _respawns = null)
    {
        RulesCore::Setup(_rules, _respawns);
        @Zombies_spawns = cast<ZombiesSpawns@>(_respawns);
        server_CreateBlob( "Entities/Meta/WARMusic.cfg" );
		gamestart = getGameTime();
		rules.SetCurrentState(WARMUP);
    }
	
	u16 num_day = 0;
	u16 MAX_ZOMBIES = 100;
	u8 day_cycle = 0;
	u16 zombie_quantity = 0;
	u16 CAN_SPAWN_ZOMBIES = 0;
	u16 num_zombies = 0;
	u16 spawnRate = 8;
	bool can_update_num_day = false; 
	bool bossSpawned = false;
	bool everyone_dead = false;
	CMap@ map;
	bool NEED_INIT = true;
	Vec2f[] zombieSpawns;
	bool testing = false;
	CBlob@[] zombiePortals;
 
    void Update()
    {
		if (rules.isGameOver()) return; 
	
 		if(rules.isWarmup() && NEED_INIT){
			init();
			NEED_INIT = false;
		}
		
        Zombies_spawns.force = false;
		
		if(rules.isWarmup()){
			// if(timeElapsed > getTicksASecond()*10){
 			if(canStartGame()){
				printf("Match start !!!!!!!!!!!!!");
				rules.SetCurrentState(GAME);
			}else{
				Zombies_spawns.force = true;
			} 
		}
		
		if (!testing && rules.isMatchRunning() && map !is null && (map.getDayTime()>0.8 || map.getDayTime()<0.1))  // 0.0 midnight; 0.5 - midday; 1.0 midnight
		{
			if(can_update_num_day){
				num_day++;
				num_zombies = 0;
				rules.SetGlobalMessage( "Day "+ num_day);
				CAN_SPAWN_ZOMBIES = GetCanSpawnZombieQuantity(num_day);
				bossSpawned = false;
				can_update_num_day = false;
			}
			
			if(getGameTime() % spawnRate == 0 ){
				SpawnZombiesNight(zombieSpawns[0]);
				SpawnZombiesNight(zombieSpawns[1]);
				
				//SpawnBossEveryDay(10);
			}	
		}else{
			can_update_num_day = true;
		}
		
		UpdateZombiePortals();
		
        RulesCore::Update(); //update respawns
        CheckTeamWon(num_day);
    }
	
	void init(){
		rules.SetGlobalMessage( "Day "+ num_day);
		
 		if(rules.exists("max_zombies"))
			MAX_ZOMBIES = rules.get_s32("max_zombies");
	
		day_cycle = getRules().daycycle_speed * 60 * getTicksASecond();
		
		@map = getMap();
		
		if(map is null)
			warn("map init failed !!!!");
		
		//left zombie spawner
		Vec2f col;
		map.rayCastSolid( Vec2f(1.0f, 0.0f), Vec2f(0.0f, map.tilemapheight*8), col );
		col.y-=16.0;
		zombieSpawns.push_back(col);
		
		//right zombie spawner
		map.rayCastSolid( Vec2f((map.tilemapwidth-1)*8 - 1, 0.0f), Vec2f(map.tilemapwidth*8, map.tilemapheight*8), col );
		col.y-=16.0;
		zombieSpawns.push_back(col);
		
		//get zombie portals
		getBlobsByName("ZombiePortal", @zombiePortals);
	}

	void SpawnZombiesNight(Vec2f location){
		if(num_zombies < CAN_SPAWN_ZOMBIES){
			if(SpawnZombies(location) !is null)
				num_zombies++ ;
		}
	}
	
    CBlob@ SpawnZombies(Vec2f location){
		if(zombie_quantity <= MAX_ZOMBIES){
			
			if(num_day < 5){		
				return SpawnStageZombies("zombie", "skeleton", "skeleton", location);
			}			
			else if(num_day < 10){	
				return SpawnStageZombies("zombieKnight", "zombie", "skeleton", location);
			}
 			else{
				if(XORRandom(10)<=5){
					return SpawnStageZombies("wraith", "zombieKnight", "zombie", location);
				}else{
					return SpawnStageZombies("greg", "zombieKnight", "skeleton", location);
				}
			}
		}
		return null;
	}
	
	void SpawnBossEveryDay(u8 day){
		if(num_day%day == 0 && !bossSpawned){
			bossSpawned = true;
			SpawnBoss(zombieSpawns[0]);
			SpawnBoss(zombieSpawns[1]);
		}
	}
	
	void SpawnBoss(Vec2f location){
		server_CreateBlob( "zombieBoss", -1, location);
	}
	
 	CBlob@ SpawnStageZombies(const string rare, const string middleRare, const string normal, Vec2f spawnPoint){
 		string chooseZombie = getZombieToSpawn(rare, middleRare, normal);
		return server_CreateBlob(chooseZombie, -1, spawnPoint); 
	}
	
 	// name1 = rare zombie, name2 = middle rare zombie, name3 = normal zombie
	string getZombieToSpawn(const string rare, const string middleRare, const string normal){
		int proba = XORRandom(10);
		
		if(proba == 1){
			return rare;
		}
		else if(proba <= 3){
			return middleRare;
		}else{
			return normal;
		}
		
		return normal;
	}
	
	void UpdateZombieQuantity(u16 amount){
		zombie_quantity = zombie_quantity + amount;
	}
	
	u16 GetCanSpawnZombieQuantity(u16 numday){
		if(numday<5){
			return numday * (numday+1);
		}else if(numday<10){
			return numday * 5;
		}else if(numday<20){
			return numday * 5 + 10;
		}
		return CAN_SPAWN_ZOMBIES + 10;
	}

	void UpdateZombiePortals(){
		if(zombiePortals.length > 0 /* && getGameTime() % 16 == 0 */){
			for(uint i =0; i<zombiePortals.length; i++){
				CBlob@ zombieportal = zombiePortals[i];
				
				if(zombieportal !is null && zombieportal.get_bool("portalbreach")){
					int spawnRate = 16 + (184*zombieportal.getHealth() / 42.0);
					if(getGameTime() % spawnRate == 0){
						SpawnZombies(zombieportal.getPosition());
					}
				}
			}
		}
	}
	
	void updateHUD()
	{
	
	}

    //team stuff
    void AddTeam(CTeam@ team)
    {
        ZSTeamInfo t(teams.length, team.getName());
        teams.push_back(t);
    }
	
	//working with players
    void SetupPlayers()
    {
        players.clear();

        for (u8 player_step = 0; player_step < getPlayersCount(); ++player_step)
        {
			ResetScoreboard(getPlayer(player_step));
            AddPlayer(getPlayer(player_step));
        }
    }
	
	void ResetScoreboard(CPlayer@ player)
	{
		if(player is null) return;
		
		player.setScore(0);
		player.setKills(0);
		player.setDeaths(0);
	}
	
	//on join new player to server
    void AddPlayer(CPlayer@ player, u8 team = 0, string default_config = "builder")
    {
        ZSPlayerInfo p(player.getUsername(), player.getTeamNum(), default_config);
        players.push_back(p);
        ChangeTeamPlayerCount(p.team, 1);
		getRules().Sync("gold_structures",true);
    }
	
  	void AddPlayerSpawn(CPlayer@ player)
    {
		// printf("add "+ player.getUsername() + " to Spawn");
        PlayerInfo@ p = getInfoFromName(player.getUsername());  
        if (p is null)	//check new player
        {
            AddPlayer(player);
        }
		else
		{
			if (p.lastSpawnRequest != 0 && p.lastSpawnRequest + 5 > getGameTime()) // safety - we dont want too much requests			
			{
			//	printf("too many spawn requests " + p.lastSpawnRequest + " " + getGameTime());
				return;
			}

			// kill old player
			RemovePlayerBlob( player );
		}

        if (player.lastBlobName.length() > 0 && p !is null)
        {
            p.blob_name = filterBlobNameToSpawn(player.lastBlobName, player);
        }

        if (respawns !is null)
        {
            // respawns.RemovePlayerFromSpawn(player);
            respawns.AddPlayerToSpawn(player);
			if (p !is null) {
				p.lastSpawnRequest = getGameTime();
			}
        }
    } 
	
	void onSetPlayer( CBlob@ blob, CPlayer@ player )
	{
		ZSPlayerInfo@ info = cast<ZSPlayerInfo@>(getInfoFromPlayer(player));
		if(info !is null)
			info.isAlive = true;
	}
	
	void onPlayerDie(CPlayer@ victim, CPlayer@ killer, u8 customData)
	{
		ZSPlayerInfo@ info = cast<ZSPlayerInfo@>(getInfoFromPlayer(victim));
		if(info !is null)
			info.isAlive = false;
		
		//check everyOne is dead
		if(rules.isMatchRunning()){
			everyone_dead = isEveryOneDead();
		}
	}
	
	bool isEveryOneDead(){
		if(players.length>0){
			for (u8 num_player = 0; num_player < players.length; num_player++){
				ZSPlayerInfo@ info = cast<ZSPlayerInfo@>(players[num_player]);
				if(info.isAlive){
					return false;
				}
			}
			return true;
		}
		return false;
	}
	
	bool canStartGame()
	{
		if(!rules.isWarmup()) return false;
		
		uint count = 0;
		if(getPlayersCount()>0){
			for (uint player_step = 0; player_step < getPlayersCount(); ++player_step)
			{
				if(getPlayer(player_step) !is null && getPlayer(player_step).getBlob() !is null) count++;
			}
			if(count > 0 && count == getPlayersCount()) return true;
		}
		return false;
	}

    //checks
    void CheckTeamWon( u8 num_day )
    {
        if (!rules.isMatchRunning()) { return; }
		if (everyone_dead){
            rules.SetGlobalMessage( "You survived for "+ num_day + " days");
			rules.SetTeamWon( -1 );
			rules.SetCurrentState(GAME_OVER);
		}
    }
};

void onBlobDie( CRules@ this, CBlob@ blob )
{			
	if (blob.getName()=="hall")
	{
		printf("hall destroyed");
		this.set_bool("hall destroyed", true);
	}else if(blob.hasTag("zombie")){
 		ZombiesCore@ core;
		this.get("core", @core);
		if(core !is null){
			// printf("add kill zombie");
			core.UpdateZombieQuantity(-1);
		}
	}
}
 
void onBlobCreated( CRules@ this, CBlob@ blob )
{
	if(blob.hasTag("zombie")){
		ZombiesCore@ core;
		this.get("core", @core);
		if(core !is null){
			// printf("add num zombie");
			core.UpdateZombieQuantity(1);
		}
	}
}