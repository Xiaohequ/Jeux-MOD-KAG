// spawn resources

#include "RulesCore.as";
#include "ZS_Structs.as";

bool SetMaterials( CBlob@ blob,  const string &in name, const int quantity )
{
	CInventory@ inv = blob.getInventory();
	
	//already got them?
	// if(inv.isInInventory(name, quantity))
		// return false;
	
	//otherwise...
	// inv.server_RemoveItems(name, quantity); //shred any old ones
	
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


//when the player is set, give materials if possible
void onSetPlayer( CRules@ this, CBlob@ blob, CPlayer@ player )
{
	if(!getNet().isServer())
		return;
	
	if (blob !is null && player !is null) 
	{
		RulesCore@ core;
		this.get("core", @core);
		if (core !is null)
		{
			doGiveSpawnMats(this, player, blob, core);
		}
	}
}

//when player dies, unset archer flag so he can get arrows if he really sucks :)
//give a guy a break :)
void onPlayerDie( CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData )
{
	if (victim !is null)
	{
		RulesCore@ core;
		this.get("core", @core);
		if (core !is null)
		{
			ZSPlayerInfo@ info = cast<ZSPlayerInfo@>( core.getInfoFromPlayer( victim ) );
			if (info !is null)
			{
				info.can_give_spawn_item = true;
			}
		}
	}
}

//takes into account and sets the limiting timer
//prevents dying over and over, and allows getting more mats throughout the game
void doGiveSpawnMats(CRules@ this, CPlayer@ p, CBlob@ b, RulesCore@ core)
{
	if(canGetSpawnmats(this, p, core))
	{
		ZSPlayerInfo@ info = cast<ZSPlayerInfo@>( core.getInfoFromPlayer( p ) );
		
		bool gotmats = GiveSpawnResources( this, b, p, info );
		if (gotmats)
		{
			info.can_give_spawn_item = false;
		}
	}
}


bool canGetSpawnmats(CRules@ this, CPlayer@ p, RulesCore@ core)
{
	ZSPlayerInfo@ info = cast<ZSPlayerInfo@>( core.getInfoFromPlayer( p ) );
	
	if( info is null) return false;
	
	CBlob@ b = p.getBlob();
	string name = b.getName();
	
	if(name == "builder"){
		if(info.can_give_spawn_item){
			return true;
		}
	}
	return false;
}


bool GiveSpawnResources( CRules@ this, CBlob@ blob, CPlayer@ player, ZSPlayerInfo@ info )
{
	bool ret = false;
	
	if (blob.getName() == "builder")
	{
		ret = SetMaterials( blob, "mat_wood", 200 ) || ret;
		ret = SetMaterials( blob, "mat_stone", 100 ) || ret;
	}
	
	return ret;
}
