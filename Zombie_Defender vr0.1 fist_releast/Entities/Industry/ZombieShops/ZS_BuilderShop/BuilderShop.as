// Builder Workshop

#include "Requirements.as"
#include "ShopCommon.as";
#include "Descriptions.as";
#include "WARCosts.as";
#include "CheckSpam.as";

void onInit( CBlob@ this )
{	 
	this.set_TileType("background tile", CMap::tile_wood_back);
	//this.getSprite().getConsts().accurateLighting = true;
	

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP

	this.set_Vec2f("shop offset", Vec2f(-10, 0));
	this.set_Vec2f("shop menu size", Vec2f(3,1));	
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	{	 
		ShopItem@ s = addShopItem( this, "Coins for Wood", "$mat_wood$", "mat_wood", "Exchange 100 Coins for 250 Wood", true );
		AddRequirement( s.requirements, "coin", "", "Coins", 100 );
	}

	{
		ShopItem@ s = addShopItem( this, "Coins for Stone", "$mat_stone$", "mat_stone", "Exchange 200 Coins for 250 Stone", true );
		AddRequirement( s.requirements, "coin", "", "Coins", 200 );
	}
	
	{
		ShopItem@ s = addShopItem( this, "Coins for Gold", "$mat_gold$", "mat_gold", "Exchange 300 Coins for 250 Gold", true );
		AddRequirement( s.requirements, "coin", "", "Coins", 300 );
	}
	
	this.set_string("required class", "builder");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	this.set_bool("shop available", this.isOverlapping(caller) /*&& caller.getName() == "builder"*/ );
}
								   
void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound( "/ChaChing.ogg" );
	}
}
