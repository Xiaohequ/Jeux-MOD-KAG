// Dorm script

void onInit( CBlob@ this )
{
	this.set_TileType("background tile", CMap::tile_wood_back);
	this.SetLight( true );
	this.SetLightRadius(50);
}

// SPRITE
void onInit(CSprite@ this)
{	
	this.SetFrame(1);

	CSpriteLayer@ fire = this.addSpriteLayer( "fire", 8,8 );
	if(fire !is null)
	{
		fire.addAnimation("default",3,true);
		int[] frames = {10,11,26,27};
		fire.animation.AddFrames(frames);
		fire.SetOffset(Vec2f(-9, 5));
		fire.SetRelativeZ(0.1f);
		fire.SetLighting(true);
		fire.SetVisible(true);
	}
}
