#include "ClassSelectMenu.as";

string last_pick_class = "";
bool menu_already = false;
bool can_build_menu = false;

void onInit( CRules@ this )
{
	// this.addCommandID("change class");
	InitClasses(this);
}

// default classes
void InitClasses( CRules@ this )
{
	AddIconToken( "$builder_class_icon$", "GUI/MenuItems.png", Vec2f(32,32), 8 );
	AddIconToken( "$knight_class_icon$", "GUI/MenuItems.png", Vec2f(32,32), 12 );
	AddIconToken( "$archer_class_icon$", "GUI/MenuItems.png", Vec2f(32,32), 16 );
	// AddIconToken( "$change_class$", "GUI/InteractionIcons.png", Vec2f(32,32), 12, 2 );
	
	PlayerClass[] classes;
	{
		PlayerClass pc = makePlayerClass("Builder", "$builder_class_icon$", "builder", "Build ALL the towers." );
		classes.push_back(pc);
	}
	{
		PlayerClass pc = makePlayerClass("Knight", "$knight_class_icon$", "knight", "Hack and Slash.");
		classes.push_back(pc);
	}
	{
		PlayerClass pc = makePlayerClass("Archer", "$archer_class_icon$", "archer", "The Ranged Advantage.");
		classes.push_back(pc);
	}

	this.set( "playerZclasses", classes );
}


PlayerClass makePlayerClass(string name, string iconName, string configFilename, string description ){
    PlayerClass p;
    p.name = name;
    p.iconName = iconName;
    p.configFilename = configFilename;
    p.description = description;
	return p;
}

void onTick(CRules@ this)
{
	if(!getNet().isServer() && can_build_menu && !menu_already && !this.isWarmup()){
		BuildClassMenu(this, getLocalPlayer());
	}
}

void onPlayerDie( CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData )
{
	if (victim !is null && victim.isMyPlayer() && !this.isGameOver())
	{
		Menu::CloseAllMenus();
		can_build_menu = true;
		// BuildClassMenu(this, victim);
	}
}

void onSetPlayer( CRules@ this, CBlob@ blob, CPlayer@ player )
{
	if (blob !is null && player !is null && player.isMyPlayer())
    {
		can_build_menu = false;
		menu_already = false;
		getHUD().ClearMenus(true);
	}
}

// hook after the change has been decided
void onPlayerChangedTeam( CRules@ this, CPlayer@ player, u8 oldteam, u8 newteam )	// be careful at beginning of the game, this function will be called
{
	if(player !is null && player.isMyPlayer() && !this.isGameOver() && !this.isWarmup()){
		BuildClassMenu(this, player);
	}
} 

void BuildClassMenu(CRules@ this, CPlayer@ caller){
	// printf("build menu");
	
	getHUD().ClearMenus(true);
	
	PlayerClass[]@ classes;
    this.get( "playerZclasses", @classes );

    if (caller !is null && caller.isMyPlayer() && classes !is null)
    {
		last_pick_class = caller.lastBlobName;
		menu_already = true;
		
		// printf("menu length: "+classes.length);
        CGridMenu@ menu = CreateGridMenu( getDriver().getScreenCenterPos() +Vec2f(0.0f, getDriver().getScreenHeight()/2.0f - CLASS_BUTTON_SIZE - 46.0f), null, Vec2f(classes.length*CLASS_BUTTON_SIZE,CLASS_BUTTON_SIZE), "Swap class" );
        if (menu !is null) {
			menu.modal = true;
			menu.deleteAfterClick = false;
            addClassesToMenu(this, classes, menu, caller.getNetworkID());

        }
    }
}

//helper for building menus of classes

void addClassesToMenu(CRules@ this, PlayerClass[]@ classes, CGridMenu@ menu, u16 callerID)
{
    if (classes.length > 0)
    {
        for (uint i = 0 ; i < classes.length; i++)
        {
            PlayerClass @pclass = classes[i];
            
            CBitStream params;
            write_classchange(params, callerID, pclass.configFilename);
			
            CGridButton@ button = menu.AddButton( pclass.iconName, pclass.name, SpawnCmd::changeClass, Vec2f(CLASS_BUTTON_SIZE,CLASS_BUTTON_SIZE), params );
            //button.SetHoverText( pclass.description + "\n" );
			if(button !is null){
				button.selectOneOnClick = true;
				button.deleteAfterClick = false;
				if(pclass.configFilename == last_pick_class)
					button.SetSelected(1);
			}
			
			// params.ResetBitIndex();
			// write_classchange(params, callerID, last_pick_class);
			// menu.SetDefaultCommand( SpawnCmd::changeClass, params );
        }
    }
}


void onCommand( CRules@ this, u8 cmd, CBitStream @params )
{
	if(cmd == SpawnCmd::changeClass)
    {
		if (getNet().isServer() )
		{
			CPlayer@ player = getPlayerByNetworkId( params.read_netid() );
			string classconfig = params.read_string();
			// printf("on command change class, pick class: "+classconfig + " last pick: "+last_pick_class);
			if(player !is null && classconfig != last_pick_class){

				player.lastBlobName = classconfig;
				last_pick_class = classconfig;

				// printf("change class to "+ classconfig);
			}
		}

    }
}

