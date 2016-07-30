
//Zombies gamemode player respawn system script
#define SERVER_ONLY

#include "ZS_Structs.as";
#include "RespawnSystem.as";
#include "ZS_PopulateSpawnList.as";

//player spawn system

const s32 spawnspam_limit_time = 10;

shared class ZombiesSpawns : RespawnSystem
{
	private ZombiesCore@ Zombies_core;

    bool force;
    s32 limit;
	
	ZombiesSpawns(){ super(); }
	
	void SetCore(RulesCore@ _core)
	{
		RespawnSystem::SetCore(_core);
		@Zombies_core = cast<ZombiesCore@>(core);
		
		limit = spawnspam_limit_time;
	}

    void Update()
    {
		//for each team
        for (uint team_num = 0; team_num < Zombies_core.teams.length; ++team_num )
        {
            ZSTeamInfo@ team = cast<ZSTeamInfo@>( Zombies_core.teams[team_num] );
			
			//spawn players
            for (uint i = 0; i < team.spawns.length; i++)
            {
                ZSPlayerInfo@ info = cast<ZSPlayerInfo@>(team.spawns[i]);
				
				UpdateSpawnTime(info, i);
				
                DoSpawnPlayer( info );
				
            }
        }
    }
    
    void UpdateSpawnTime(ZSPlayerInfo@ info, int i)
    {
		if ( info !is null )
		{
			u8 spawn_property = 255;
			
			if(info.can_spawn_time > 0) {
				info.can_spawn_time--;
				spawn_property = u8(Maths::Min(250,(info.can_spawn_time / 30)));
			}
			
			string propname = "Zombies spawn time "+info.username;
			
			Zombies_core.rules.set_u8( propname, spawn_property );
			Zombies_core.rules.SyncToPlayer( propname, getPlayerByUsername(info.username) );
		}
	}
	
    void DoSpawnPlayer( PlayerInfo@ p_info )
    {
        if (canSpawnPlayer(p_info))
        {
			//limit how many spawn per second
			if(limit > 0)
			{
				limit--;
				return;
			}
			else
			{
				limit = spawnspam_limit_time;
			}
			
            CPlayer@ player = getPlayerByUsername(p_info.username); // is still connected?

            if (player is null)
            {
				RemovePlayerFromSpawn(p_info);
                return;
            }
            if (player.getTeamNum() != int(p_info.team))
            {
				player.server_setTeamNum(p_info.team);
			}

			// remove previous players blob	  			
			if (player.getBlob() !is null)
			{
				CBlob @blob = player.getBlob();
				blob.server_SetPlayer( null );
				blob.server_Die();					
			}

			p_info.blob_name = "builder"; //hard-set the respawn blob
            CBlob@ playerBlob = SpawnPlayerIntoWorld( getSpawnLocation(p_info), p_info);

            if (playerBlob !is null)
            {
                p_info.spawnsCount++;
                RemovePlayerFromSpawn(player);
				
            }
        }
    }
	
	bool canSpawnPlayer(PlayerInfo@ p_info)
    {
        ZSPlayerInfo@ info = cast<ZSPlayerInfo@>(p_info);

        if (info is null) { warn("Zombies LOGIC: Couldn't get player info ( in bool canSpawnPlayer(PlayerInfo@ p_info) ) "); return false; }
       
	   if (force) { return true; }
		
        return info.can_spawn_time <= 0;
    }

	//change player spawn location
    Vec2f getSpawnLocation(PlayerInfo@ p_info)
    {
        ZSPlayerInfo@ c_info = cast<ZSPlayerInfo@>(p_info);
		if(c_info !is null)
        {
			CBlob@ pickSpawn = getBlobByNetworkID( c_info.spawn_point );
			//has spawn point
			// if (pickSpawn !is null && pickSpawn.hasTag("respawn") && pickSpawn.getTeamNum() == p_info.team)
			if (pickSpawn !is null && pickSpawn.getTeamNum() == p_info.team)
			{
				return pickSpawn.getPosition();
			}
			else //hasn't spawn point
			{
			
				CMap@ map = getMap();
				if(map !is null)
				{
					f32 x = XORRandom(2) == 0 ? 32.0f : map.tilemapwidth * map.tilesize - 32.0f;
					return Vec2f(x, map.getLandYAtX(s32(x/map.tilesize))*map.tilesize - 16.0f);
				}

			}
        }

        return Vec2f(0,0);
    }

    void RemovePlayerFromSpawn(CPlayer@ player)		
    {
        RemovePlayerFromSpawn(core.getInfoFromPlayer(player));
    }
    
    void RemovePlayerFromSpawn(PlayerInfo@ p_info)
    {
        ZSPlayerInfo@ info = cast<ZSPlayerInfo@>(p_info);
        
        if (info is null) { warn("Zombies LOGIC: Couldn't get player info ( in void RemovePlayerFromSpawn(PlayerInfo@ p_info) )"); return; }

        string propname = "Zombies spawn time "+info.username;
        
        for (uint i = 0; i < Zombies_core.teams.length; i++)
        {
			ZSTeamInfo@ team = cast<ZSTeamInfo@>(Zombies_core.teams[i]);
			int pos = team.spawns.find(info);

			if (pos != -1) {
				team.spawns.erase(pos);
				break;
			}
		}
		
		Zombies_core.rules.set_u8( propname, 255 ); //not respawning
		Zombies_core.rules.SyncToPlayer( propname, getPlayerByUsername(info.username) ); 
		
		info.can_spawn_time = 0;
	}
	
	void RemoveAllPlayerFromSpawn(){
	    for (uint team_num = 0; team_num < Zombies_core.teams.length; team_num++ )
        {
            ZSTeamInfo@ team = cast<ZSTeamInfo@>( Zombies_core.teams[team_num] );

            for (uint i = 0; i < team.spawns.length; i++)
            {
                ZSPlayerInfo@ info = cast<ZSPlayerInfo@>(team.spawns[i]);
				
				RemovePlayerFromSpawn(info);
            }
        }
	}
	
	
    void AddPlayerToSpawn( CPlayer@ player )
    {
		if(isSpawning(player)) {
			ZSPlayerInfo@ info = cast<ZSPlayerInfo@>(core.getInfoFromPlayer(player));
			info.spawn_point = player.getSpawnPoint();
			return;
		}

		s32 tickspawndelay = getPlayerSpawnTime(player);
		
		// if(player.getDeaths()==0){
			// tickspawndelay = 0;
		// }
		
        ZSPlayerInfo@ info = cast<ZSPlayerInfo@>(core.getInfoFromPlayer(player));

        if (info is null) { warn("Zombies LOGIC: Couldn't get player info  ( in void AddPlayerToSpawn(CPlayer@ player) )"); return; }

		RemovePlayerFromSpawn(player);
		if (player.getTeamNum() == core.rules.getSpectatorTeamNum())
			return;
		// printf(" player team: " + player.getTeamNum()+" , spectator team: " + core.rules.getSpectatorTeamNum());
		
		if (info.team < Zombies_core.teams.length)
		{
			ZSTeamInfo@ team = cast<ZSTeamInfo@>(Zombies_core.teams[info.team]);
			
			info.can_spawn_time = tickspawndelay;
			
			info.spawn_point = player.getSpawnPoint();
	
			team.spawns.push_back(info);
			
			//printf(player.getUsername() + " added to spawn, spawns size: " + team.spawns.length + " players size: " + Zombies_core.players.length);
		}
		else
		{
			error("PLAYER TEAM NOT SET CORRECTLY!");
		}
    }
	
	//calculate spawn time of the player
	s32 getPlayerSpawnTime(CPlayer@ player){
		PlayerInfo@ pinfo = core.getInfoFromName(player.getUsername());
		if(pinfo.lastSpawnRequest == 0) return 10 * getTicksASecond();
		if(player.getScore()>500){
			return Zombies_core.spawnTime - 25* getTicksASecond();
		}else if(player.getScore()>250){
			return Zombies_core.spawnTime - 10* getTicksASecond();
		}
		return Zombies_core.spawnTime;
	}
	
	bool isSpawning( CPlayer@ player )
	{
		int8 playerTeamNum = player.getTeamNum();
		if(playerTeamNum > -1 && playerTeamNum < Zombies_core.teams.length){
			ZSTeamInfo@ team = cast<ZSTeamInfo@>(Zombies_core.teams[playerTeamNum]);
			for(uint i = 0; i < team.spawns.length; i++){
				if(team.spawns[i].username == player.getUsername()){
					return true;
				}
			}
		}else{
			for (uint i = 0; i < Zombies_core.teams.length; i++)
			{
				ZSTeamInfo@ team = cast<ZSTeamInfo@>(Zombies_core.teams[i]);
				for(uint j = 0; j < team.spawns.length; j++){
					if(team.spawns[j].username == player.getUsername()){
						return true;
					}
				}
			}
		}
		return false;
	}
};




