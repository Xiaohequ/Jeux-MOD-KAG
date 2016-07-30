
#include "ZS_PopulateSpawnList.as";

int deathTime = 0;
const int BUTTON_SIZE = 2;
u16 LAST_PICK = 0;
bool MENU_ALREADY = false;
bool myPlayerIsDead = false;

void onInit( CRules@ this )
{	
	this.addCommandID("pick default");
    this.addCommandID("pick spawn");
}

void onTick(CRules@ this)
{
	if(!getNet().isServer() && (getGameTime() % 16 == 0)){
			//draw spawn menu when player die after 2s
		if(myPlayerIsDead && !this.isWarmup() && !MENU_ALREADY && (deathTime - getGameTime())<0){
			BuildRespawnMenu(this, getLocalPlayer());
		}
	}
}

// hook after the change has been decided
void onPlayerChangedTeam( CRules@ this, CPlayer@ player, u8 oldteam, u8 newteam )	// be careful at beginning of the game, this function will be called
{
	if(player !is null && player.isMyPlayer() && !this.isGameOver() && !this.isWarmup()){
		BuildRespawnMenu(this, player);
	}
} 

// local player requests a spawn right after death
void onPlayerDie( CRules@ this, CPlayer@ victim, CPlayer@ killer, u8 customData )
{
    if (victim !is null && !this.isGameOver())
    {
		if(victim.isMyPlayer()){
			//clear
			Menu::CloseAllMenus();
			
			// spawn even without pick
			victim.client_RequestSpawn(0);
			
			myPlayerIsDead = true;
			deathTime = getGameTime()+ 1.7f*getTicksASecond();
		}else if(MENU_ALREADY){
			MENU_ALREADY = false;
			// BuildRespawnMenu(this, getLocalPlayer());
		}
	}
}


// now we know for sure that we don't have menus
void onSetPlayer( CRules@ this, CBlob@ blob, CPlayer@ player )
{
	if (blob !is null && player !is null )
    {
		if(player.isMyPlayer()){
			getHUD().ClearMenus(true); // kill all even modal
			myPlayerIsDead = false;
			MENU_ALREADY = false;
			LAST_PICK = 0;
		} else if(MENU_ALREADY){
			getHUD().ClearMenus(true);
			BuildRespawnMenu(this, getLocalPlayer());
		}
	}
}

void BuildRespawnMenu(CRules@ this, CPlayer@ player)
{
	if(!player.isMyPlayer() || getNet().isServer()) return;
	// if(player !is getLocalPlayer()) return;
	
	getHUD().ClearMenus(true); // kill all even modal
	
	const int teamNum = player.getTeamNum();
	
	const u16 localID = getLocalPlayer().getNetworkID();
	// CPlayer@ localPlayer = getLocalPlayer();
	
	// if( localPlayer is null ) return;
	
	// const u16 localID = localPlayer.getNetworkID();

	if (teamNum != this.getSpectatorTeamNum())
	{
		if(!MENU_ALREADY)
		{
			MENU_ALREADY = true;
		}
		CBlob@[] respawns;
		// populateSpawnList( @respawns, 0 );
		populateSpawnList( @respawns, teamNum );
		
		// if there are no posts just respawn
		if (respawns.length < 1)
		{
			LAST_PICK = 0;
			return;
		}

		SortByPosition( @respawns, teamNum );
		
		CGridMenu@ oldmenu = getGridMenuByName("Pick spawn");

		if (oldmenu !is null) {
			oldmenu.kill = true;
		}
		// build menu for spawns
		CGridMenu@ menu = CreateGridMenu( getDriver().getScreenCenterPos() +Vec2f(0.0f, getDriver().getScreenHeight()/2.0f - BUTTON_SIZE - 46.0f), null, Vec2f( respawns.length * BUTTON_SIZE, BUTTON_SIZE), "Pick spawn point ");
		
		if (menu !is null)
		{
			menu.modal = true;
			menu.deleteAfterClick = false;
			
			CBitStream params;
			// printf(" nb bouton : " + respawns.length);
			 
 			for (uint i=0; i < respawns.length; i++)
			{
				CBlob@ respawn = respawns[i];
				params.ResetBitIndex();
				params.write_netid( respawn.getNetworkID() );
				params.write_netid( localID );
				
				CGridButton@ button;
				if(respawn.hasTag("player")){
					string respawn_name = respawn.getInventoryName();
					if(respawn.getPlayer() !is null){
						respawn_name = respawn.getPlayer().getUsername();
					}
					@button = menu.AddButton( "$spawn_at_player$", "Spawn at "+ respawn_name, this.getCommandID("pick spawn"), Vec2f(BUTTON_SIZE, BUTTON_SIZE), params );
				}else{
					@button = menu.AddButton( "$"+respawn.getName()+"$", "Spawn at " + respawn.getInventoryName(), this.getCommandID("pick spawn"), Vec2f(BUTTON_SIZE, BUTTON_SIZE), params );
				}
				
				if (button !is null)
				{
					button.selectOneOnClick = true;
					button.deleteAfterClick = false;
					if (LAST_PICK == respawn.getNetworkID()) {
						button.SetSelected(1);
					}
				} 
			}

			// default behaviour on clicking anywhere else
			if (respawns.length > 0)
			{
				params.ResetBitIndex();
				params.write_netid( localID );
				params.write_netid( LAST_PICK );
				menu.SetDefaultCommand( this.getCommandID("pick default"), params );
			} 
		}
	}
}

void SortByPosition( CBlob@[]@ spawns, const int teamNum )
{
	// Selection Sort
	uint N = spawns.length;
	for (uint i = 0; i < N; i++)
	{
		uint minIndex = i;

		// Find the index of the minimum element
		for (uint j = i + 1; j < N; j++)
		{
			if (
				(teamNum == 0 && spawns[j].getPosition().x < spawns[minIndex].getPosition().x)
				||
				(teamNum == 1 && spawns[j].getPosition().x < spawns[minIndex].getPosition().x)
			   )
			{
				minIndex = j;
			}
		}

		// Swap if i-th element not already smallest
		if (minIndex > i)
		{
			CBlob@ temp = spawns[i];
			@spawns[i] = spawns[minIndex];
			@spawns[minIndex] = temp;
		}
	}
}

void readPickCmd( CRules@ this, CPlayer@ player, const u16 pick)
{
	if( player is null ) return;

    if (player is getLocalPlayer())
    {
		if (player.getTeamNum() == this.getSpectatorTeamNum()) {
			getHUD().ClearMenus(true);
		}
		else {
			//focus at the picked spawn point
			LAST_PICK = pick;
			CBlob@ pickBlob = getBlobByNetworkID( pick );
			if(pickBlob !is null){
				CCamera@ camera = getCamera();
				camera.setPosition(pickBlob.getPosition());
				camera.setTarget(pickBlob);
				camera.mousecamstyle = 1;
			}else{ //refresh menu
				LAST_PICK = 0;
				// MENU_ALREADY = false;
				BuildRespawnMenu(this, player);
			}
			//readd player to spawn with new spawn point
			player.client_RequestSpawn( LAST_PICK );
		}
    }
}

void onCommand( CRules@ this, u8 cmd, CBitStream @params )
{
	// check if this is spawn menu button's command
    if (cmd == this.getCommandID("pick spawn")){
		const u16 pick = params.read_netid();
		if(pick != LAST_PICK){
			// LAST_PICK = pick;
			CPlayer@ player = getPlayerByNetworkId( params.read_netid() );
			readPickCmd( this, player ,pick);
		}
    }
} 