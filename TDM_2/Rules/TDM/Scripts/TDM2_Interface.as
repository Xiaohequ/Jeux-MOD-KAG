#include "TDM2_Structs.as";

/*
void onTick( CRules@ this )
{
    //see the logic script for this
}
*/

void onInit( CRules@ this )
{
    CBitStream stream;
    stream.write_u16(0xDEAD);
    this.set_CBitStream("tdm_serialised_team_hud", stream);
}

void onRender( CRules@ this )
{
    CPlayer@ p = getLocalPlayer();

    if (p is null || !p.isMyPlayer()) { return; }

    CBitStream serialised_team_hud;
    this.get_CBitStream("tdm_serialised_team_hud", serialised_team_hud);

    if (serialised_team_hud.getBytesUsed() > 8)
    {
        serialised_team_hud.Reset(); // reset pointer to 0
        u16 check;

        if (serialised_team_hud.saferead_u16(check) && check == 0x5afe)
        {
            const string gui_image_fname = "Rules/TDM/TDM2Gui.png";
			const u8 PROGRESS_BAR_LENGTH = 3;
			const float SCALE = 1.7f;
			Vec2f barIconsSize = Vec2f(256,32);
			Vec2f screenTopMiddle = Vec2f(getDriver().getScreenCenterPos().x , 0);
			
			s16[] team_kills;
			s16 kills_to_win = 0;
			
			//draw progress bar background icon
			GUI::DrawIcon(gui_image_fname, 2, barIconsSize, screenTopMiddle - Vec2f(barIconsSize.x * SCALE, 0 ), SCALE);
			
            while (!serialised_team_hud.isBufferEnd()) //2 teams
            {
                TDM2_HUD hud(serialised_team_hud);
				
				team_kills.push_back(hud.kills);
				
				if(hud.team_num == 0){
					kills_to_win = hud.kills_limit;
				}
				
				s8 side = hud.team_num == 0 ? -1 : 1;
				//draw static bloc at end of the bar of progression
				Vec2f offset = hud.team_num == 0 ? Vec2f(0, 0): Vec2f(-24 * SCALE, 0);
				Vec2f teamSide = screenTopMiddle + Vec2f(side * (182 * SCALE), 24 * SCALE) + offset;
				
				GUI::DrawRectangle( teamSide, teamSide + Vec2f(23 * SCALE, 25 * SCALE), hud.team_num == 0 ? SColor(0xff2CAFDE) : SColor(0xffDE0000));

				// GUI::DrawText(""+hud.kills, teamSide, teamSide + Vec2f(23 * SCALE, 25 * SCALE), SColor(255,255,255,255), true , false);
				
				//draw kills progression
				s32 distanceEachKill = 130 * SCALE / hud.kills_limit;
				s32 currentkillDistance = distanceEachKill * hud.kills;
				
				Vec2f killsOffset = hud.team_num == 0 ? Vec2f(0, 0): Vec2f( -currentkillDistance, 0);
				Vec2f posInit = screenTopMiddle + Vec2f(side * (160 * SCALE  ), 34 * SCALE) + killsOffset;
				
				GUI::DrawRectangle( posInit, posInit + Vec2f(currentkillDistance, 14 * SCALE), hud.team_num == 0 ? SColor(0xff2CAFDE) : SColor(0xffDE0000));
				
            }
			
			//draw progress bar icon
			GUI::DrawIcon(gui_image_fname, 1, barIconsSize, screenTopMiddle - Vec2f(barIconsSize.x * SCALE, 0 ), SCALE);
			
			//Kill to win 
			GUI::DrawText(" "+kills_to_win + " ", screenTopMiddle + Vec2f(-10, 40), SColor(255,255,255,255));
			
			//draw kills progression hand
			for(uint i = 0; i < team_kills.length; i++){
				s8 side = i == 0 ? -1 : 1;
								
				s32 distanceEachKill = 130 * SCALE / kills_to_win;
				s32 currentkillDistance = distanceEachKill * team_kills[i];
				
				Vec2f handOffset = Vec2f( -32 * SCALE * i, -17);
				Vec2f killsOffset =  Vec2f( -currentkillDistance * side, 0);
				Vec2f posInit = screenTopMiddle + Vec2f(side * (160 * SCALE  ), 34 * SCALE);
				
				GUI::DrawIcon(gui_image_fname, i, Vec2f(16, 16), posInit + handOffset + killsOffset, SCALE);
				
				GUI::DrawText(""+team_kills[i], posInit + Vec2f(side * 20 - 12 * i, -5), SColor(255,255,255,255));
			}
        }

        serialised_team_hud.Reset();
    }

    string propname = "tdm spawn time "+p.getUsername();	
    if (p.getBlob() is null && this.exists(propname) )
    {
        u8 spawn = this.get_u8(propname);

        if (spawn != 255)
        {
            if (spawn == 254)
            {
                GUI::DrawText( "In Queue to Respawn..." , Vec2f( getScreenWidth()/2 - 70, getScreenHeight()/3 + Maths::Sin(getGameTime() / 3.0f) * 5.0f ), SColor(255, 255, 255, 55) );
            }
            if (spawn == 253)
            {
                GUI::DrawText( "No Respawning - Wait for the Game to End." , Vec2f( getScreenWidth()/2 - 70, getScreenHeight()/3 + Maths::Sin(getGameTime() / 3.0f) * 5.0f ), SColor(255, 255, 255, 55) );
            }
            else
            {
                GUI::DrawText( "Respawn in: "+spawn , Vec2f( getScreenWidth()/2 - 70, getScreenHeight()/3 + Maths::Sin(getGameTime() / 3.0f) * 5.0f ), SColor(255, 255, 255, 55) );
            }
        }
    }
}
