// Trader shop

#include "Requirements.as"
#include "ShopCommon.as";
#include "Descriptions.as";
#include "WARCosts.as";
#include "MakeScroll.as"
// #include "CheckSpam.as";

void onInit( CBlob@ this )
{	 
	this.set_TileType("background tile", CMap::tile_wood_back);
	//this.getSprite().getConsts().accurateLighting = true;
	

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;


	// SHOP

	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(3,1));	
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);
	this.set_bool("shop scroll", true);

	{
		ShopItem@ s = addShopItem( this, "Scroll of Taming", "$scroll26$", "tame", "Exchange 125 Gold for a Scroll of Taming", true );
		AddRequirement( s.requirements, "blob", "mat_gold", "Gold", 125 );
	}
	
	{	 
		ShopItem@ s = addShopItem( this, "Scroll of Carnage", "$scroll24$", "carnage", "Exchange 500 Gold for Scroll of Carnage", true );
		AddRequirement( s.requirements, "blob", "mat_gold", "Gold", 500 );
	}

	// this.set_string("required class", "builder");
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
