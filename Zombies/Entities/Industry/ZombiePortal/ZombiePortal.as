// Zombie portal
#include "WARCosts.as";
#include "ShopCommon.as";
#include "Descriptions.as";

void onInit( CBlob@ this )
{	 
	this.getSprite().SetZ(-50); //background
	CSpriteLayer@ lightning = this.getSprite().addSpriteLayer( "lightning", "EvilLightning.png" , 32, 32, -1, -1 );
	Animation@ lanim = lightning.addAnimation( "default", 4, false );
	for (int i=0; i<7; i++) lanim.AddFrame(i*4);
	Animation@ lanim2 = lightning.addAnimation( "default2", 4, false );
	for (int i=0; i<7; i++) lanim2.AddFrame(i*4+1);

	
	this.set_TileType("background tile", CMap::tile_empty);
	this.getShape().getConsts().mapCollisions = false;
	this.set_bool("portalbreach",false);
	this.set_bool("portalplaybreach",false);
	this.SetLight(false);
	this.SetLightRadius( 64.0f );
}

void onDie( CBlob@ this)
{
	server_DropCoins(this.getPosition() + Vec2f(0,-32.0f), 500);
}
void onTick( CBlob@ this)
{
	if (this.get_bool("portalbreach"))
	{
		if(!getNet().isServer()){
			int spawnRate = 16 + (184*this.getHealth() / 42.0);
			if(getGameTime()% spawnRate ==0){
				this.getSprite().PlaySound("Thunder");
				CSpriteLayer@ lightning = this.getSprite().getSpriteLayer("lightning");
				if (XORRandom(4)>2) lightning.SetAnimation("default"); else lightning.SetAnimation("default2");
			}
		}
	}
	else
	{
		if (getGameTime() % 300 == 0)
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
	
	if (this.get_bool("portalplaybreach")) {
		this.getSprite().PlaySound("PortalBreach");
		this.set_bool("portalplaybreach",false);
		this.SetLight(true);
		this.SetLightRadius( 40.0f );		
	}
}

							   
