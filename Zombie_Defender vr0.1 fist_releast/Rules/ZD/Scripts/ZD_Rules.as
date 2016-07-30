
//Zombies gamemode rule script
#define SERVER_ONLY

#include "ZS_Structs.as";
#include "RulesCore.as";

shared class ZombiesCore : RulesCore
{
    s32 warmUpTime;
    s32 gameDuration;
    s32 spawnTime;

    ZombiesSpawns@ Zombies_spawns;

    ZombiesCore() {}

    ZombiesCore(CRules@ _rules, RespawnSystem@ _respawns )
    {
        super(_rules, _respawns );
		_rules.set_bool("managed teams",true);
    }
	
    int gamestart;
	
    void Setup(CRules@ _rules = null, RespawnSystem@ _respawns = null)
    {
        RulesCore::Setup(_rules, _respawns);
        @Zombies_spawns = cast<ZombiesSpawns@>(_respawns);
        server_CreateBlob( "Entities/Meta/WARMusic.cfg" );
		gamestart = getGameTime();
		// rules.set_u8("num_wave", 0);
		SyncWaveTimer();
		rules.SetGlobalMessage( "Wave 0");
    }
 
	string base_name() { return "hall"; }
 
	int WAVE_TIME = 90; // sec
	int MAX_ZOMBIES = 100;
	int MAX_WAVE_ZOMBIES = 30;
	int WAVE_SUP_ZOMBIE = 10;
	int wave_timer = WAVE_TIME;
	int wave_start_at = 0;
	int num_wave = 0;
	int num_zombies = 0;
	int killed_zombies = 0;

	bool bossSpawned = false;
 
    void Update()
    {
		CheckTeamWon(num_wave);
		 
        if (rules.isGameOver() || num_wave > 20) return; 
		
        Zombies_spawns.force = false;
		
		if(rules.isWarmup()){
 			if(canStartGame()){
				if(rules.exists("max_zombies"))
					MAX_ZOMBIES = rules.get_s32("max_zombies");
				printf("Match start !!!!!!!!!!!!!");
				rules.SetCurrentState(GAME);
			}else{
				Zombies_spawns.force = true;
			} 
		}
		
  		if(rules.isMatchRunning()){
			if(wave_timer <= 0){
				if(getGameTime()%16==0){
					SpawnZombies(num_wave);
				}
				if(wave_start_at - getGameTime() <= 0 && (num_zombies - killed_zombies)==0){
					wave_timer = WAVE_TIME;
					SyncWaveTimer();
					num_wave++;
					if(num_wave<=20)
						rules.SetGlobalMessage("Wave " + num_wave);
					num_zombies = 0;
					killed_zombies = 0;
				}
			}else if(getGameTime()%getTicksASecond() == 0){
				wave_start_at = getGameTime() + 20 * getTicksASecond();
				wave_timer--;
				SyncWaveTimer();
			}
		} 
		
        RulesCore::Update(); //update respawns
    }

    void SpawnZombies(int num_wave){
 		u8 sup_zombie = (num_wave % 5) * WAVE_SUP_ZOMBIE;
		
		if(num_wave > 20 || num_zombies >= (MAX_WAVE_ZOMBIES + sup_zombie)) return;
		
		// if(getGameTime() % 16 == 0)
			// printf("zombie spawning !!!!!!!! \n num zombie: "+ num_zombies +" \n killed zombie: "+ killed_zombies);
			
		CMap@ map = getMap();
		
		if (map is null) return;
		
		if(num_zombies <= MAX_ZOMBIES){
			
			Vec2f[] zombiePlaces;
		
			//left zombie spawner
			Vec2f col;
			map.rayCastSolid( Vec2f(1.0f, 0.0f), Vec2f(0.0f, map.tilemapheight*8), col );
			col.y-=16.0;
			zombiePlaces.push_back(col);
			
			//right zombie spawner
			map.rayCastSolid( Vec2f((map.tilemapwidth-1)*8, 0.0f), Vec2f(map.tilemapwidth*8, map.tilemapheight*8), col );
			col.y-=16.0;
			zombiePlaces.push_back(col);
			
			Vec2f zombieSpawn = zombiePlaces[XORRandom(zombiePlaces.length)];
 
			if(num_wave < 5){			//stage 1: skeleton
				if(num_zombies < MAX_WAVE_ZOMBIES){
					SpawnStageZombies("greg", "zombie", "skeleton", zombieSpawn);
				}else if(num_zombies < MAX_WAVE_ZOMBIES + sup_zombie){
					SpawnStageZombies("zombie", "zombie", "skeleton", zombieSpawn);
				}
			}
 			else if(num_wave < 10){	//stage 2: zombie
				if(num_zombies < MAX_WAVE_ZOMBIES){
					SpawnStageZombies("zombieKnight", "skeleton", "zombie", zombieSpawn);
				}else if(num_zombies < MAX_WAVE_ZOMBIES + sup_zombie){
					SpawnStageZombies("zombieKnight", "greg", "zombie", zombieSpawn);
				}
			}
			else if(num_wave < 15){	//stage 3: zombieKnight
				if(num_zombies < MAX_WAVE_ZOMBIES){
					SpawnStageZombies("wraith", "zombie", "zombieKnight", zombieSpawn);
				}else if(num_zombies < MAX_WAVE_ZOMBIES + sup_zombie){
					SpawnStageZombies("wraith", "zombieKnight", "skeleton", zombieSpawn);
				}
			}
			else if(num_wave < 20){		//stage 4: weith
				if(num_zombies < MAX_WAVE_ZOMBIES){
					SpawnStageZombies("wraith", "wraith", "zombieKnight", zombieSpawn);
				}else if(num_zombies < MAX_WAVE_ZOMBIES + sup_zombie){
					SpawnStageZombies("wraith", "zombie", "zombieKnight", zombieSpawn);
				}
			}
			else if(num_wave == 20){	//stage final: zombieBoss 
				if(num_zombies < MAX_WAVE_ZOMBIES){
					SpawnStageZombies("zombieKnight", "wraith", "zombie", zombieSpawn);
				}
 				if(!bossSpawned){
					bossSpawned = true;
					server_CreateBlob( "zombieBoss", -1, zombiePlaces[0]);
					server_CreateBlob( "zombieBoss", -1, zombiePlaces[1]);
				}
			}
		}

	}
	
 	void SpawnStageZombies(const string rare, const string middleRare, const string normal, Vec2f spawnPoint){
 		string chooseZombie = getZombieToSpawn(rare, middleRare, normal);
		server_CreateBlob(chooseZombie, -1, spawnPoint); 
	}
	
 	// name1 = rare zombie, name2 = middle rare zombie, name3 = normal zombie
	string getZombieToSpawn(const string rare, const string middleRare, const string normal){
		int proba = XORRandom(10);
		
		if(proba == 1){
			return rare;
		}
		else if(proba < 2){
			return middleRare;
		}else{
			return normal;
		}
		
		return normal;
	}
	
	void addZombieKill(){
		killed_zombies++;
	}
	
	void addNumZombie(){
		num_zombies++;
	}
	
	void SyncWaveTimer(){
		getRules().set_u16("wave_timer", wave_timer);
		getRules().Sync("wave_timer", true);
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

        for (int player_step = 0; player_step < getPlayersCount(); ++player_step)
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
        ZSPlayerInfo p(player.getUsername(), player.getTeamNum(), (XORRandom(512) >= 256 ? "knight" : "archer"));
        players.push_back(p);
        ChangeTeamPlayerCount(p.team, 1);
		// ChangeTeamPlayerCount(p.team, 1);
		getRules().Sync("gold_structures",true);
		// printf("!!!!!!!!!" +player.getUsername()+" added to team: "+ p.team +", Total player: "+  getPlayersCount());
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

	}
	
	void onPlayerDie(CPlayer@ victim, CPlayer@ killer, u8 customData)
	{

	}
	
	 void SetupBases()
    {
		// destroy all previous spawns if present
        CBlob@[] oldBases;
        getBlobsByName( base_name(), @oldBases );

        for (uint i=0; i < oldBases.length; i++) {
            oldBases[i].server_Die();
        }
		
		CMap@ map = getMap();
		if (map !is null)
        {
			Vec2f respawnPos;
			respawnPos = Vec2f(map.tilemapwidth*map.tilesize / 2, (map.getLandYAtX(map.tilemapwidth/ 2) * map.tilesize )- 3*map.tilesize);
            SetupBase( server_CreateBlob( base_name(), 0, respawnPos ) );
		} 
		
		getRules().set_bool("hall destroyed", false);
		rules.SetCurrentState(WARMUP);
	}
	
	void SetupBase( CBlob@ base )
    {
        if (base is null) {
            return;
        }
        //nothing to do
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
void CheckTeamWon(int num_wave)
    {
        if (!rules.isMatchRunning()) { return; }
		// int wave_num = rules.get_u8("num_wave");
		if (getRules().get_bool("hall destroyed"))  //defenders lose
		{
            rules.SetGlobalMessage( "You survived for "+ num_wave + " waves");		
			rules.SetTeamWon( -1 ); 
			rules.SetCurrentState(GAME_OVER);
		}else if(num_wave > 20){ //defenders win
			rules.SetGlobalMessage( "You have the victory!!!");	
			rules.SetTeamWon( 0 ); 
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
			core.addZombieKill();
		}
		// this.set_s32("killed_zombies", this.get_s32("killed_zombies")+1);
	}
}
 
void onBlobCreated( CRules@ this, CBlob@ blob )
{
	if(blob.hasTag("zombie")){
		ZombiesCore@ core;
		this.get("core", @core);
		if(core !is null){
			// printf("add num zombie");
			core.addNumZombie();
		}
		// this.set_s32("num_zombies", this.get_s32("num_zombies")+1);
	}
}