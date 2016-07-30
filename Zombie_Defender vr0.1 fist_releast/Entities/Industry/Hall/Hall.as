// Hall

#include "ClassSelectMenu.as";
#include "StandardRespawnCommand.as";
#include "Requirements.as"

#include "Help.as"

void onInit( CBlob@ this )
{
	this.getCurrentScript().tickFrequency = 30;

	InitClasses( this );
	InitRespawnCommand( this );
	this.set_TileType("background tile", CMap::tile_castle_back);
	this.Tag("change class store inventory");
	
	this.Tag("respawn");
	
	this.Tag("hall"); //for zombie to attaque this
	
	this.Tag("attack_signaled");	 

	this.addCommandID("respawn");
		// shipment
	this.addCommandID("shipment");

	this.inventoryButtonPos = Vec2f(48.0f, -28.0f);
	this.set_Vec2f("travel button pos", Vec2f(-24.0f, 20.0f));

	this.Tag("storage");	 // gives spawn mats

	//minimap icon
	SetMinimap( this );

	this.getShape().getConsts().waterPasses = false;
	
	// wont work in basichelps in single for some map loading reason
	SetHelp( this, "help use", "", "Change class    $KEY_E$", "", 5 );
}

void onTick( CBlob@ this )
{
	SetMinimap(this);
	
	//add indestructible support
	if(getNet().isServer())
	{
		if(this.getTickSinceCreated() > 30)
		{
			if(!this.hasTag("nobuild sector added") && this.getTickSinceCreated() > 30)
			{
				this.Tag("nobuild sector added");
				Vec2f pos = this.getPosition();
				
				CMap@ map = this.getMap();
				int nb_block_under_hall = map.tilemapheight - (pos.y / map.tilesize + 3);

				int support_width = this.getSprite().getFrameWidth() / map.tilesize;
				int from_left = (support_width/2) * map.tilesize;
				
				//build support of hall
				for(uint i = 0; i< support_width; i++){
					map.server_SetTile( pos+Vec2f(-from_left + i * map.tilesize,3 * map.tilesize), CMap::tile_bedrock );
				}
				
				//build wall below hall
				for(uint j = 0; j< nb_block_under_hall; j++){
					//fill empty tile below hall
					//todo
					
					//fill with bedrock below of the hall
					for(uint i = 0; i< 2; i++){
						map.server_SetTile( pos + Vec2f((-1+2*i)*from_left-(i* map.tilesize),(j+4) * map.tilesize), CMap::tile_bedrock );
					}	
				}
				
				//remove blobsInRadius
				CBlob@[] blobs;
				// Vec2f frameSizs = Vec2f(this.getSprite().getFrameWidth(),this.getSprite().getFrameHeight());
				// Vec2f topleft = pos + -frameSizs/2;
				// Vec2f bottomright = pos + frameSizs/2;
				// map.getBlobsInBox(topleft,bottomright,@blobs);
				map.getBlobsInRadius(this.getPosition(), 40, @blobs);
				
				for(uint j = 0; j <blobs.length; j++){
					CBlob@ blob = blobs[j];
					if(blob !is this && !blob.hasTag("player")){
						blob.server_Die();
					}
				}
				
			}
		}
	}
	
/* 	if(!this.hasTag("attack_signaled")){
		this.Tag("attack_signaled");
		this.Sync("attack_signaled", true);
		if(!getNet().isServer()){
			Sound::Play( "/flag_capture.ogg" );
		}
	} */
}
 
 void SetMinimap( CBlob@ this )
{
	// minimap icon
	if (!this.hasTag("attack_signaled")){
		this.SetMinimapOutsideBehaviour(CBlob::minimap_snap);
		this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 1, Vec2f(16,16));
		if(this.get_s32("last under attack") - getGameTime() <=0) this.Tag("attack_signaled");
	}else{
		this.SetMinimapOutsideBehaviour(CBlob::minimap_arrow);
		this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 2, Vec2f(16,8));
	}
	this.SetMinimapRenderAlways(true);
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(!caller.isOverlapping(this))
		return;
	
	if (this.getTeamNum() != 255)
	{
		CBitStream params;
		params.write_u16( caller.getNetworkID() );
		CButton@ button = caller.CreateGenericButton( "$change_class$", Vec2f(24.0f, 20.0f), this, SpawnCmd::buildMenu, "Change class", params);
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	CSprite@ sprite = this.getSprite();
	
	if( cmd == this.getCommandID("shipment") )
	{
		CBlob@ localBlob = getLocalPlayerBlob();
		if (localBlob !is null && localBlob.getTeamNum() == this.getTeamNum()) {
			client_AddToChat( "Supplies will drop at your halls." );
		}
	}
	else {
		onRespawnCommand( this, cmd, params );
	} 
}

bool isInventoryAccessible( CBlob@ this, CBlob@ forBlob )
{
	return (this.getTeamNum() != 255 && //not neutral
			forBlob.getTeamNum() == this.getTeamNum() && //teammate
			forBlob.isOverlapping(this) && //inside
			!getRules().exists("singleplayer"));
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	if(hitterBlob.getTeamNum() == this.getTeamNum()){
		return 0.0f;
	}
	
	if(this.get_s32("last under attack") - getGameTime() <=0){
		this.Untag("attack_signaled");
		Sound::Play( "/flag_capture.ogg" );
	}
	
	this.set_s32("last under attack", getGameTime() + 5 * getTicksASecond());
	
	return damage;
}

// SPRITE

void onInit(CSprite@ this)
{
	int team = this.getBlob().getTeamNum();
	if(team >= 0 && team < 8) //"normal" team
		this.animation.frame = 1;
}
