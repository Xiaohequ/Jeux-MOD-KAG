
//Zombies gamemode rule script
#define SERVER_ONLY

#include "ZS_Structs.as";
#include "RulesCore.as";

const u8 SURVIVOR_TEAM =0;
const u8 INFECTED_TEAM =1;

shared class ZombiesCore : RulesCore
{
    s32 warmUpTime;
	bool auto_duration = false;
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
		rules.set_s8("team_wins_on_end", SURVIVOR_TEAM);
		rules.SetCurrentState(WARMUP);
    }
	
	bool spawnInfected = true;
	bool afterGameOver = false;
	bool fist_support_item_spawned = false;
	bool second_support_item_spawned = false;
	s32 EACH_PLAYER_SUPPL_TIME = 20;
 
    void Update()
    {
		if (rules.isGameOver()) {
			if(rules.getTeamWon() == SURVIVOR_TEAM && !afterGameOver){
				afterGameOver = true;
				UpdatePlayersScore(SURVIVOR_TEAM, 100); //bonus of score
			}
			return;
		} 
	
        Zombies_spawns.force = false;
		
		s32 ticksToStart = gamestart + warmUpTime - getGameTime();
		
        if (ticksToStart <= 0 && (rules.isWarmup())) //game start
        {
			rules.Sync("game_end_time", true);
			ChangePlayersClass("archer");
            rules.SetCurrentState(GAME);
        }
        else if (ticksToStart > 0 && rules.isWarmup())
        {
            rules.SetGlobalMessage( "Game start in "+((ticksToStart/30)+1) );
            Zombies_spawns.force = true;

			// rules.set_u32("game_end_time", gamestart + warmUpTime + gameDuration);
        }

		if (rules.isIntermission() || rules.isWarmup() && (!canStartGame()))
        {
            gamestart = getGameTime();

			// rules.set_u32("game_end_time", gamestart + warmUpTime + gameDuration);
			
            rules.SetGlobalMessage( "Not enough players for the game to start.\nPlease wait for someone to join..." );
            Zombies_spawns.force = true;
        }
		else if (rules.isMatchRunning())
		{
			rules.SetGlobalMessage( "" );
		}
		
		// if(getGameTime()%15 == 0){
			// printf("game time: " + getGameTime());
			// printf("game end time " + rules.get_u32("game_end_time"));
		// }
		
		if(rules.isMatchRunning()){
			if(!haveAnyoneInTeam(INFECTED_TEAM))
				SpawnInfected();
			if(!second_support_item_spawned && getGameTime() > (rules.get_u32("game_end_time"))*0.7f){
				second_support_item_spawned = true;
				if(teams[SURVIVOR_TEAM].players_count >= teams[INFECTED_TEAM].players_count){
					printf("giving support 2 !!!!!!!!!!!!!!");
					GiveSupportItemToTeam(INFECTED_TEAM,2);
				}
			}else if(!fist_support_item_spawned && getGameTime() > (rules.get_u32("game_end_time"))*0.4f){
				fist_support_item_spawned = true;
				if(teams[SURVIVOR_TEAM].players_count >= teams[INFECTED_TEAM].players_count){
					printf("giving support 1 !!!!!!!!!!!!!!");
					GiveSupportItemToTeam(INFECTED_TEAM,1);
				}
			}
		}else if(rules.isWarmup()){
			if(getGameTime()%15 == 0){
				if(auto_duration){
					gameDuration = Maths::Max((teams[SURVIVOR_TEAM].players_count - 1) * EACH_PLAYER_SUPPL_TIME * getTicksASecond(),0);
				}
				// printf("duration = "+ gameDuration);
				// printf("game start = "+gamestart);
				rules.set_u32("game_end_time", gamestart + warmUpTime + gameDuration);
			}
		}
		
        RulesCore::Update(); //update respawns
        CheckTeamWon();
    }
	
	void ChangePlayersClass(const string _class){
		printf("CHANGE ALL PLAYER S CLASS TO "+ _class);
		GivePlayersItem();
        for (int player_step = 0; player_step < getPlayersCount(); ++player_step)
        {
			ChangeClass(getPlayer(player_step),_class);
        }
	}
	
	void ChangeClass(CPlayer@ player, const string _class){
		CBlob@ oldBlob = player.getBlob();
		
		if(oldBlob !is null){
			CBlob @newBlob = server_CreateBlob( _class, oldBlob.getTeamNum(), oldBlob.getPosition() );
			
			if (newBlob !is null){
				if(oldBlob.getHealth() != oldBlob.getInitialHealth()) //only if was damaged, else just set max hearts //fix contributed by norill 19 aug 13
					newBlob.server_SetHealth( Maths::Min(oldBlob.getHealth(), newBlob.getInitialHealth()) ); //set old hearts, capped by new initial hearts
				
				// plug the soul
				newBlob.server_SetPlayer( player );
				newBlob.setPosition( oldBlob.getPosition() );
				
				// no extra immunity after class change
				if(oldBlob.exists("spawn immunity time"))
				{
					newBlob.set_u32("spawn immunity time", oldBlob.get_u32("spawn immunity time"));
					newBlob.Sync("spawn immunity time", true);
				}

				oldBlob.Tag("switch class");
				oldBlob.server_SetPlayer( null );
				removeInventory(oldBlob);
				oldBlob.server_Die();
			}
		}
	}
	
	void GivePlayersItem(){
		for (int num_player = 0; num_player < players.length; num_player++){
			ZSPlayerInfo@ info = cast<ZSPlayerInfo@>(players[num_player]);
			if (info !is null){
				info.can_give_spawn_item = true;
			}
		}
	}
	
	void UpdatePlayersScore(uint team, int score){
		for(uint i=0; i< getPlayersCount(); i++){
			CPlayer@ player = getPlayer(i);
			if(player.getTeamNum() == team){
				player.setScore(player.getScore()+ score);
			}
		}
	}
	
	void SpawnInfected(){
		// CPlayer@ infected = getPlayerByUsername("gentleboy2"); // debug
		// if(infected is null)
		CPlayer@ infected = getPlayer(XORRandom(getPlayersCount()));
		CBlob@ blob = infected.getBlob();
		blob.Tag("infected");
		blob.Sync("infected", true);
		blob.server_Hit( blob, blob.getPosition(), Vec2f(0,0), 4.0f, 0);
	}
	
	void GiveSupportItemToTeam(int numTeam, int amount){
		if(numTeam >= 0 && numTeam < teams.length){
			for(uint i=0; i< getPlayersCount(); i++){
				CPlayer@ player = getPlayer(i);
				if( player.getTeamNum() == numTeam){
					GiveSupportItem(player, amount);
				}
			}
		}
	}
	
	bool GiveSupportItem(CPlayer@ player, int amount)
	{
		bool ret = false;
		
		CBlob@ blob = player.getBlob();
		
		ZSPlayerInfo@ info = cast<ZSPlayerInfo@>(getInfoFromPlayer(player));
		
		if(blob !is null){
			if (blob.getName() == "builder")
			{
				ret = SetMaterials( blob, "mat_wood", 100 * amount) || ret;
				ret = SetMaterials( blob, "mat_stone", 50 * amount) || ret;
				ret = SetMaterials( blob, "drill", 1) || ret;
			}
			else if(blob.getName() == "archer")
			{
				ret = SetMaterials( blob, "mat_arrows", 30 ) || ret;
				ret = SetMaterials( blob, "mat_bombarrows", amount ) || ret;
			}
			else if(blob.getName() == "knight")
			{
				ret = SetMaterials( blob, "mat_bombs", amount ) || ret;
				ret = SetMaterials( blob, "mat_waterbombs", amount ) || ret;
			}
			if(!ret){
				info.give_support_item = amount;
			}else{
				info.give_support_item = 0;
			}
		}else{
			info.give_support_item = amount;
		}
		return ret;
	}
	
	bool SetMaterials( CBlob@ blob,  const string &in name, const int quantity )
	{
		CInventory@ inv = blob.getInventory();

		CBlob@ mat = server_CreateBlob( name );
		if (mat !is null)
		{
			mat.Tag("do not set materials");
			mat.server_SetQuantity(quantity);
			if (!blob.server_PutInInventory(mat))
			{
				mat.setPosition( blob.getPosition() );
			}
		}
		
		return true;
	}
	
    //team stuff
    void AddTeam(CTeam@ team)
    {
		// printf("add team "+ team.getName());
        ZSTeamInfo t(teams.length, team.getName());
        teams.push_back(t);
    }
	
	//working with players
    void SetupPlayers()
    {
        players.clear();
		
        for (int player_step = 0; player_step < getPlayersCount(); ++player_step)
        {	
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
    void AddPlayer(CPlayer@ player, u8 team = 0, string class_config = "")
    {
		class_config = class_config==""?"builder":class_config;
		
		team = getRules().isMatchRunning()? INFECTED_TEAM: SURVIVOR_TEAM;
		
		// printf("player team: "+ team);
		// printf("team 1: "+ SURVIVOR_TEAM);
		// printf("team 2: "+ INFECTED_TEAM);
		
        ZSPlayerInfo p(player.getUsername(), team, class_config);
        player.lastBlobName = class_config;
		
		players.push_back(p);
		
        ChangeTeamPlayerCount(p.team, 1);
    }
	
  	void AddPlayerSpawn(CPlayer@ player)
    {
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
		
        // if (player.lastBlobName.length() > 0 && p !is null)
        // {
            // p.blob_name = filterBlobNameToSpawn(player.lastBlobName, player);
        // }

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
		if(player !is null){
			ZSPlayerInfo@ p = cast<ZSPlayerInfo@>(getInfoFromPlayer(player));
			if(p is null) return;
			
			if(!p.isAlive){
				p.isAlive = true;
				
				if(player.getTeamNum()>-1 && player.getTeamNum() < teams.length){
					teams[player.getTeamNum()].alive_count++;
				}
				
				if(p.give_support_item > 0){
					GiveSupportItem(player, p.give_support_item);
				}
			}
		}
	}
	
	void onPlayerDie(CPlayer@ victim, CPlayer@ killer, u8 customData)
	{
		if(victim !is null){
			ZSPlayerInfo@ p = cast<ZSPlayerInfo@>(getInfoFromPlayer(victim));
			if(p is null) return;
			
			// printf("on die spawn id "+ p.spawn_point);
			
			CBlob@ blob = victim.getBlob();
			if(blob !is null){
				s32 blobid = blob.getNetworkID();
				// printf("blob isnt null id: "+ blobid);
				if(blobid != p.spawn_point){
					p.spawn_point = blobid;
				}
				
				removeInventory(blob);
			}
			
			if(p.isAlive){
				p.isAlive = false;
				if(victim.getTeamNum()>-1 && victim.getTeamNum() < teams.length){
					teams[victim.getTeamNum()].alive_count--;
				}
			}
			
			if(rules.isMatchRunning()){
				ChangeTeamPlayerCount(p.team, -1);
				ChangeTeamPlayerCount(INFECTED_TEAM, 1);
				
				p.blob_name = victim.lastBlobName;
				
				p.setTeam(INFECTED_TEAM);	 
				victim.server_setTeamNum(INFECTED_TEAM);				
			}
				
		}
	}

	bool isEveryOneDead(u8 numTeam){
		return teams[numTeam].players_count > 0 && teams[numTeam].alive_count<=0;
	}
	
	bool haveAnyoneInTeam(u8 numTeam){
		return teams[numTeam].players_count > 0;
	}
	
	bool canStartGame(){
		if(!rules.isWarmup()) return false;
		
		return teams[SURVIVOR_TEAM].players_count > 1;
	}

    //checks
    void CheckTeamWon()
    {
		if (rules.isMatchRunning()){
			if(!haveAnyoneInTeam(SURVIVOR_TEAM)){		//infected win
				rules.SetGlobalMessage( "Infected team win");
				rules.SetTeamWon( INFECTED_TEAM );
				// UpdatePlayersScore(INFECTED_TEAM,100);
				// UpdatePlayersScore(SURVIVOR_TEAM,-100);
				rules.SetCurrentState(GAME_OVER);
			} 
			// survivors win at end of timer. see TimeToEnd.as
		}
    }
	
};

shared void removeInventory(CBlob@ blob){
	CInventory@ inv = blob.getInventory();
	if (inv !is null)
	{
		for (int i = 0; i < inv.getItemsCount(); i++)
		{
			CBlob @blob = inv.getItem(i);	
			blob.server_Die();
		}
	}
}
	
void onBlobDie( CRules@ this, CBlob@ blob )
{			
	removeInventory(blob);
}

 /*
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
 */