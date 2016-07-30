// Tent logic

#include "StandardRespawnCommand.as"
// #include "ShopCommon.as";

void onInit( CBlob@ this )
{
	//shop
	this.set_TileType("background tile", CMap::tile_empty);
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(2,2));
	this.set_u8("shop icon", 25);
	this.set_bool("shop available", false );
	
	//default
	this.getSprite().SetZ(-50.0f);
	
    this.CreateRespawnPoint( "tent", Vec2f(0.0f, -4.0f) );
    InitClasses( this );
	this.Tag("change class drop inventory");
    
    this.Tag("respawn");
    
    // minimap
    this.SetMinimapOutsideBehaviour(CBlob::minimap_snap);
	this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 1, Vec2f(8,8));
	this.SetMinimapRenderAlways(true);
    
    // defaultnobuild
	// this.set_Vec2f("nobuild extend", Vec2f(0.0f, 8.0f));
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
    // button for runner
    // create menu for class change
    if (canChangeClass( this, caller ) && caller.getTeamNum() == this.getTeamNum())
    {
        CBitStream params;
        params.write_u16(caller.getNetworkID());
        caller.CreateGenericButton( "$change_class$", Vec2f(0,0), this, SpawnCmd::buildMenu, "Swap Class", params );
    }
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
    onRespawnCommand( this, cmd, params );
}


