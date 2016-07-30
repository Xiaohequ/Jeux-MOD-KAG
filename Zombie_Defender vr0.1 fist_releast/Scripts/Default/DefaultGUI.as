
void LoadDefaultGUI()
{
    if (v_driver > 0)
    {
        // load default skin
        GUI::LoadSkin( "GUI/guiSkin.cfg" );
        // add color tokens
        AddColorToken( "$RED$", SColor(255, 105, 25, 5) );
        AddColorToken( "$GREEN$", SColor(255, 5, 105, 25) );
		AddColorToken( "$GREY$", SColor(255, 195, 195, 195) );
        // add default icon tokens
        AddIconToken( "$NONE$", "GUI/InteractionIcons.png", Vec2f(32,32), 9 );
        AddIconToken( "$TIME$", "GUI/InteractionIcons.png", Vec2f(32,32), 0 );
        AddIconToken( "$COIN$", "GUI/MaterialIcons.png", Vec2f(16,16), 5 );
        AddIconToken( "$GOLD$", "GUI/MaterialIcons.png", Vec2f(16,16), 2 );
        AddIconToken( "$TEAMS$", "GUI/MenuItems.png", Vec2f(32,32), 1 );
        AddIconToken( "$SPECTATOR$", "GUI/MenuItems.png", Vec2f(32,32), 19 );
        AddIconToken( "$FLAG$", CFileMatcher("flag.png").getFirst(), Vec2f(32,16), 0 );
        AddIconToken( "$DISABLED$", "GUI/InteractionIcons.png", Vec2f(32,32), 9, 1 );
		AddIconToken( "$CANCEL$", "GUI/MenuItems.png", Vec2f(32,32), 29 );		
		AddIconToken( "$RESEARCH$", "GUI/InteractionIcons.png", Vec2f(32,32), 27 );
		AddIconToken( "$ALERT$", "GUI/InteractionIcons.png", Vec2f(32,32), 10 ); 
		AddIconToken( "$down_arrow$", "GUI/ArrowDown.png", Vec2f(8,8), 0 );
		AddIconToken( "$ATTACK_LEFT$", "GUI/InteractionIcons.png", Vec2f(32,32), 18, 1 );
		AddIconToken( "$ATTACK_RIGHT$", "GUI/InteractionIcons.png", Vec2f(32,32), 17, 1 );
		AddIconToken( "$ATTACK_THIS$", "GUI/InteractionIcons.png", Vec2f(32,32), 19, 1 );
		AddIconToken( "$DEFEND_LEFT$", "GUI/InteractionIcons.png", Vec2f(32,32), 18, 2 );
		AddIconToken( "$DEFEND_RIGHT$", "GUI/InteractionIcons.png", Vec2f(32,32), 17, 2 );
		AddIconToken( "$DEFEND_THIS$", "GUI/InteractionIcons.png", Vec2f(32,32), 19, 2 );
		AddIconToken( "$CLASSCHANGE$", "Rules/Tutorials/TutorialImages.png", Vec2f(32,32), 7 );
		AddIconToken( "$BUILD$", "GUI/InteractionIcons.png", Vec2f(32,32), 15 );
		AddIconToken( "$STONE$", "Sprites/World.png", Vec2f(8,8), 48 );
		AddIconToken( "$!!!$", "/Emoticons.png", Vec2f(22,22), 48 );		
				
		// zombie mod - GUI
		
		AddIconToken( "$spawn_at_player$", "GUI/Orders.png", Vec2f(32,32), 3 );
		AddIconToken( "$change_to_builder$", "GUI/change_class_icon.png", Vec2f(32,32), 0 );
		AddIconToken( "$change_to_knight$", "GUI/change_class_icon.png", Vec2f(32,32), 1 );
		AddIconToken( "$change_to_archer$", "GUI/change_class_icon.png", Vec2f(32,32), 2 );
		
		// zombie mod - building
		AddIconToken("$shop_nursery$", "Entities/Industry/OldBuildings/Nursery/Nursery2.png", Vec2f(40, 24), 0 , SColor(255,136,136,136));
		AddIconToken("$shop_dorm$", "Entities/Industry/OldBuildings/Dorm/Dorm.png", Vec2f(40, 24), 0);
		AddIconToken("$shop_zstradingPost$", "Entities/Industry/ZS_TradingPost/ZS_TradingPost.png", Vec2f(40, 24), 0);
		// AddIconToken("$ZS_Tent$", "Entities/Industry/ZombieShops/ZS_Tent/ZS_Tent.png", Vec2f(40, 24), 1);
		
		// zombie mod - block		
		
		AddIconToken( "$goldbrick$", "Entities/Structures/GoldBrick/goldbrick.png", Vec2f(8,8), 0);
		AddIconToken( "$gold_door$", "Entities/Structures/Door/1x1GoldDoorIcon.png", Vec2f(8,8), 0);
		
		// zombie mod - item
		
		AddIconToken( "$ZS_MountedBow$", "Entities/Items/ZS_MountedBow/ZS_MountedBow.png", Vec2f(16,16), 6);
		AddIconToken( "$saw$", "Entities/Industry/Saw/Saw.png", Vec2f(24,16), 4);
		
		// classes

		AddIconToken( "$ARCHER$", "ClassIcons.png", Vec2f(16,16), 2 );
		AddIconToken( "$KNIGHT$", "ClassIcons.png", Vec2f(16,16), 1 );
		AddIconToken( "$BUILDER$", "ClassIcons.png", Vec2f(16,16), 0 );

		// blocks

		AddIconToken( "$stone_block$", "Sprites/World.png", Vec2f(8,8), CMap::tile_castle );
		AddIconToken( "$back_stone_block$", "Sprites/World.png", Vec2f(8,8), CMap::tile_castle_back );
		AddIconToken( "$wood_block$", "Sprites/World.png", Vec2f(8,8), CMap::tile_wood );
		AddIconToken( "$back_wood_block$", "Sprites/World.png", Vec2f(8,8), CMap::tile_wood_back );

		// techs

		AddIconToken( "$tech_stone$", "GUI/TechnologyIcons.png", Vec2f(16,16), 16 );

		// keys
		const Vec2f keyIconSize(16,16);
		AddIconToken( "$KEY_W$", "GUI/Keys.png", keyIconSize, 6 );
		AddIconToken( "$KEY_A$", "GUI/Keys.png", keyIconSize, 0 );
		AddIconToken( "$KEY_S$", "GUI/Keys.png", keyIconSize, 1 );
		AddIconToken( "$KEY_D$", "GUI/Keys.png", keyIconSize, 2 );
		AddIconToken( "$KEY_E$", "GUI/Keys.png", keyIconSize, 3 );
		AddIconToken( "$KEY_F$", "GUI/Keys.png", keyIconSize, 4 );
		AddIconToken( "$KEY_C$", "GUI/Keys.png", keyIconSize, 5 );
		AddIconToken( "$KEY_M$", "GUI/Keys.png", keyIconSize, 10 );
		AddIconToken( "$KEY_Q$", "GUI/Keys.png", keyIconSize, 7 );
		AddIconToken( "$LMB$", "GUI/Keys.png", keyIconSize, 8 );
		AddIconToken( "$RMB$", "GUI/Keys.png", keyIconSize, 9 );
		AddIconToken( "$KEY_SPACE$", "GUI/Keys.png", Vec2f(24,16), 8 );
		AddIconToken( "$KEY_HOLD$", "GUI/Keys.png", Vec2f(24,16), 9 );
		AddIconToken( "$KEY_TAP$", "GUI/Keys.png", Vec2f(24,16), 10 );
		AddIconToken( "$KEY_F1$", "GUI/Keys.png", Vec2f(24,16), 12 );
		AddIconToken( "$KEY_ESC$", "GUI/Keys.png", Vec2f(24,16), 13 );
		AddIconToken( "$KEY_ENTER$", "GUI/Keys.png", Vec2f(24,16), 14 );

		// vehicles

		AddIconToken( "$LoadAmmo$", "GUI/InteractionIcons.png", Vec2f(16,16), 7, 7 );
    }
}
