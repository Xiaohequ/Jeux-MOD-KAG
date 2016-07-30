#include "StandardRespawnCommand.as"

const string req_class = "required class";

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(!this.exists(req_class))
		return;
	
	string _class = this.get_string(req_class);
    if (canChangeClass(this,caller) && caller.getName() != _class) {
        CBitStream params;
        write_classchange(params, caller.getNetworkID(), _class);
       caller.CreateGenericButton( "$change_to_"+ _class +"$", Vec2f(20,0), this, SpawnCmd::changeClass, "Swap Class", params );
    }
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	onRespawnCommand( this, cmd, params );
}

void onInit(CBlob@ this)
{
	this.Tag("change class drop inventory");
}