// Nursery

#include "Requirements.as"
#include "ShopCommon.as";
// #include "Descriptions.as";
// #include "WARCosts.as";

void onInit( CBlob@ this )
{
	printf("nursery script loaded ... ");
	this.set_TileType("background tile", CMap::tile_wood_back);
	//this.getSprite().getConsts().accurateLighting = true;

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP

	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(3,2));	
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);
	this.set_bool("shop seed", true);
	
	{	 
		ShopItem@ s = addShopItem( this, "Pine tree seed", "$tree_pine$", "tree_pine", "Exchange 60 Coins for a pine seed", false );
		AddRequirement( s.requirements, "coin", "", "Coins", 60 );
	}

	{
		ShopItem@ s = addShopItem( this, "Oak tree seed", "$tree_bushy$", "tree_bushy", "Exchange 50 Coins for a Oak tree seed", false );
		AddRequirement( s.requirements, "coin", "", "Coins", 50 );
	}
	
	{
		ShopItem@ s = addShopItem( this, "Grain plant seed", "$grain_plant$", "grain_plant", "Exchange 20 Coins for a Grain plant seed", false );
		AddRequirement( s.requirements, "coin", "", "Coins", 20 );
	}
	{
		ShopItem@ s = addShopItem( this, "Bush seed", "$bush$", "bush", "Exchange 10 Coins for a Bush seed", false );
		AddRequirement( s.requirements, "coin", "", "Coins", 10 );
	}
	{
		ShopItem@ s = addShopItem( this, "Flowers seed", "$flowers$", "flowers", "Exchange 20 Coins for a Flowers seed", false );
		AddRequirement( s.requirements, "coin", "", "Coins", 20 );
	}
	
}
							   
void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound( "/ChaChing.ogg" );
	}
}
