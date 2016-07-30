//default actor hud
// a bar with hearts in the bottom left, bottom right free for actor specific stuff

#include "ActorHUDStartPos.as";

const string heartFile = "GUI/HeartNBubble.png";
	 
void renderBackBar( Vec2f origin, f32 width, f32 scale)
{
    for (f32 step = 0.0f; step < width/scale - 64; step += 64.0f * scale)
    {
        GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 1, Vec2f(64,32), origin+Vec2f(step*scale,0), scale);
    }

    GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 1, Vec2f(64,32), origin+Vec2f(width - 128*scale,0), scale);
}

void renderFrontStone( Vec2f farside, f32 width, f32 scale)
{
    for (f32 step = 0.0f; step < width/scale - 16.0f*scale*2; step += 16.0f*scale*2)
    {
        GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 2, Vec2f(16,32), farside+Vec2f(-step*scale - 32*scale,0), scale);
    }

    if (width > 16) {
        GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 2, Vec2f(16,32), farside+Vec2f(-width, 0), scale);
    }

    GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 0, Vec2f(16,32), farside+Vec2f(-width - 32*scale, 0), scale);
    GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 3, Vec2f(16,32), farside, scale);
}

void renderHPBar( CBlob@ blob, Vec2f origin)
{
    int segmentWidth = 32;
    GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 0, Vec2f(16,32), origin+Vec2f(-segmentWidth,0));
    int HPs = 0;

    for (f32 step = 0.0f; step < blob.getInitialHealth(); step += 0.5f)
    {
        GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 1, Vec2f(16,32), origin+Vec2f(segmentWidth*HPs,0));
        f32 thisHP = blob.getHealth() - step;

        if (thisHP > 0)
        {
            Vec2f heartoffset = (Vec2f(2,10) * 2);
            Vec2f heartpos = origin+Vec2f(segmentWidth*HPs,0)+heartoffset;

            if (thisHP <= 0.125f)
            {
                GUI::DrawIcon(heartFile, 4, Vec2f(12,12), heartpos);
            }
            else if (thisHP <= 0.25f)
            {
                GUI::DrawIcon(heartFile, 3, Vec2f(12,12), heartpos);
            }
            else if (thisHP <= 0.375f)
            {
                GUI::DrawIcon(heartFile, 2, Vec2f(12,12), heartpos);
            }
            else
            {
                GUI::DrawIcon(heartFile, 1, Vec2f(12,12), heartpos);
            }
        }

        HPs++;
    }

    GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 3, Vec2f(16,32), origin+Vec2f(32*HPs,0));
}

const f32 HEART_SCALE = 0.8f;
const f32 HEART_SEGMENT_WIDTH = 21 * HEART_SCALE;

void renderHPBarOnBlob( CBlob@ blob, Vec2f offset){
    
	if(blob.getHealth() < blob.getInitialHealth()){
		int HPs = 0;
		
		f32 zoom = getCamera().targetDistance;
		
		//
		Vec2f heartBarPos = blob.getScreenPos() + Vec2f(-blob.getInitialHealth()*HEART_SEGMENT_WIDTH, (1 - zoom) * 40) + offset;
		
		for (f32 step = 0.0f; step < blob.getInitialHealth(); step += 0.5f)
		{
			f32 thisHP = blob.getHealth() - step;
			
			Vec2f heartpos = heartBarPos + Vec2f(HEART_SEGMENT_WIDTH * HPs,0);
			
			if (thisHP > 0)
			{
				if (thisHP <= 0.125f)
				{
					GUI::DrawIcon(heartFile, 4, Vec2f(12,12), heartpos, HEART_SCALE);
				}
				else if (thisHP <= 0.25f)
				{
					GUI::DrawIcon(heartFile, 3, Vec2f(12,12), heartpos, HEART_SCALE);
				}
				else if (thisHP <= 0.375f)
				{
					GUI::DrawIcon(heartFile, 2, Vec2f(12,12), heartpos, HEART_SCALE);
				}
				else
				{
					GUI::DrawIcon(heartFile, 1, Vec2f(12,12), heartpos, HEART_SCALE);
				}
			}
			
			GUI::DrawIcon(heartFile, 0, Vec2f(12,12), heartpos, HEART_SCALE);
		   
			HPs++;
			
		}
	}

} 

void onInit( CSprite@ this )
{
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";
}

void onRender( CSprite@ this )
{
	if (g_videorecording)
		return;

    CBlob@ blob = this.getBlob();
    Vec2f dim = Vec2f(362,64);
    Vec2f ul(HUD_X - dim.x/2.0f, HUD_Y - dim.y + 12 );
    Vec2f lr( ul.x + dim.x, ul.y + dim.y );
    //GUI::DrawPane(ul, lr);
    renderBackBar(ul, dim.x, 1.0f);
    u8 bar_width_in_slots = blob.get_u8("gui_HUD_slots_width");
    f32 width = bar_width_in_slots * 32.0f;
    renderFrontStone( ul+Vec2f(dim.x+32,0), width, 1.0f);
    renderHPBar( blob, ul);
	//Hp bar on top of the blob
	renderHPBarOnBlob(blob,Vec2f(0,-blob.getHeight()*3.5f));
    //GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 0, Vec2f(128,32), topLeft);
}
