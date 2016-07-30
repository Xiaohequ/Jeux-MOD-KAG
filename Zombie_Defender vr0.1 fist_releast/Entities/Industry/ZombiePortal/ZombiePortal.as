// Zombie portal
#include "WARCosts.as";
#include "ShopCommon.as";
#include "Descriptions.as";

void onInit( CBlob@ this )
{	 
	this.getSprite().SetZ(-50); //background
	// CSpriteLayer@ portal = this.getSprite().addSpriteLayer( "portal", "ZombiePortal.png" , 40, 24, -1, -1 );
	CSpriteLayer@ lightning = this.getSprite().addSpriteLayer( "lightning", "EvilLightning.png" , 32, 32, -1, -1 );
	// Animation@ anim = portal.addAnimation( "default", 0, true );
	Animation@ lanim = lightning.addAnimation( "default", 4, false );
	for (int i=0; i<7; i++) lanim.AddFrame(i*4);
	Animation@ lanim2 = lightning.addAnimation( "default2", 4, false );
	for (int i=0; i<7; i++) lanim2.AddFrame(i*4+1);
	// anim.AddFrame(1);
	// portal.SetRelativeZ( 1000 );
//	portal.SetOffset(Vec2f(0,-24));
//	lightning.SetOffset(Vec2f(0,-24));
	
	this.set_TileType("background tile", CMap::tile_castle_back_moss);
	this.getShape().getConsts().mapCollisions = false;
	this.set_bool("portalbreach",false);
	this.set_bool("portalplaybreach",false);
	this.SetLight(false);
	this.SetLightRadius( 64.0f );
	
}

void onDie( CBlob@ this)
{
	server_DropCoins(this.getPosition() + Vec2f(0,-32.0f), 1000);
}
void onTick( CBlob@ this)
{
	int spawnRate = 16 + (184*this.getHealth() / 42.0);
	if (getGameTime() % spawnRate == 0 && this.get_bool("portalbreach"))
	{
		this.getSprite().PlaySound("Thunder");
		CSpriteLayer@ lightning = this.getSprite().getSpriteLayer("lightning");
		if (XORRandom(4)>2) lightning.SetAnimation("default"); else lightning.SetAnimation("default2");
		//lightning.SetFrame(0);
	}

	if (this.get_bool("portalplaybreach")) {
		this.getSprite().PlaySound("PortalBreach");
		this.set_bool("portalplaybreach",false);
		this.SetLight(true);
		this.SetLightRadius( 40.0f );		
	}
	if (!getNet().isServer()) return;
	int num_zombies = getRules().get_s32("num_zombies");
	if (this.get_bool("portalbreach"))
	{
		
		if ((getGameTime() % spawnRate == 0) && num_zombies < 100)
		{
			Vec2f sp = this.getPosition();
			
			int r;
			r = XORRandom(9);
			int rr = XORRandom(8);
			if (r==8 && rr<3)
			server_CreateBlob( "wraith", -1, sp);
			else										
			if (r==7 && rr<3)
			server_CreateBlob( "greg", -1, sp);
			else					
			if (r==6)
			server_CreateBlob( "zombieKnight", -1, sp);
			else
			if (r>=3)
			server_CreateBlob( "zombie", -1, sp);
			else
			server_CreateBlob( "skeleton", -1, sp);
			if ((r==7 && rr<3) || (r==8 && rr<3) || (r<7))
			{
				num_zombies++;
				getRules().set_s32("num_zombies",num_zombies);
				
			}
		}
	}
	else
	{
		if (getGameTime() % 600 == 0)
		{
			Vec2f sp = this.getPosition();
			
		
			CBlob@[] blobs;
			this.getMap().getBlobsInRadius( sp, 64, @blobs );
			for (uint step = 0; step < blobs.length; ++step)
			{
				CBlob@ other = blobs[step];
				if (other.hasTag("player"))
				{
					this.set_bool("portalbreach",true);
					this.set_bool("portalplaybreach",true);
					this.Sync("portalplaybreach",true);
					this.Sync("portalbreach",true);
				}
			}
		}
	}
}
void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
//	this.set_bool("shop available", this.isOverlapping(caller) /*&& caller.getName() == "builder"*/ );
}
							   
