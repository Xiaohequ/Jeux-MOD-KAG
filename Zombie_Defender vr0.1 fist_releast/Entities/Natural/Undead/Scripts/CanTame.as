
const string TAME_ICON_FILE = "GUI/PartyIndicator.png";
const f32 ICON_SCALE = 1.5f;

//blob
void onInit(CBlob@ this)
{
	this.Tag("can tame");
}

void onTick(CBlob@ this)
{
	if(this.getTeamNum() != -1){
		if(this.exists("taming time") ){
			if(this.get_s32("taming time") - getGameTime() <= 0){
				this.server_setTeamNum(-1);
			}
		}
	}
}

void onRender( CSprite@ this )
{
	CBlob@ blob = this.getBlob();
	
	if(blob.getTeamNum() != 255){
		drawTamedIcon(blob);
	}
}

void drawTamedIcon(CBlob@ this){
	
	if(this.isOnScreen()){
		f32 zoom = getCamera().targetDistance;
		
		Vec2f pos = this.getScreenPos() + Vec2f(-16 * ICON_SCALE, -16 * ICON_SCALE) + Vec2f(0, -(this.getSprite().getFrameHeight()*2.0f * zoom));
		
		GUI::DrawIcon(TAME_ICON_FILE, 8, Vec2f(16,16), pos, ICON_SCALE);
	}
}