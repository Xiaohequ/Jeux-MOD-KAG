
#define CLIENT_ONLY

CPlayer@ BEST_PLAYER;
string icon_file = "GUI/BestPlayer.png";

void onTick( CRules@ this )
{
	if(this.isMatchRunning()&& getGameTime()%30==0){
		int best_score = 0;
		CPlayer@ bestPlayer;
		for(uint i=0; i< getPlayerCount(); i++){
			CPlayer@ player = getPlayer(i);
			if(player.getScore() > best_score){
				best_score = player.getScore();
				@bestPlayer = player;
			}
		}
		@BEST_PLAYER = bestPlayer;
	}
}

// render gui for the player
void onRender(CRules@ this)
{
	if(BEST_PLAYER !is null && BEST_PLAYER.getScore() > 0){
		CBlob@ blob = BEST_PLAYER.getBlob();
		if(blob !is null && blob.isOnScreen()){
			renderIcon(blob, Vec2f(-32,-(blob.getHeight()*3 +32)));
		}
	}
}

void renderIcon(CBlob@ blob, Vec2f offset){
	f32 zoom = getCamera().targetDistance;
	Vec2f pos = blob.getScreenPos() + offset+ Vec2f(0, (1 - zoom) * 32) + Vec2f(0, Maths::Sin(getGameTime() / 5.0f) * 5.0f);
	GUI::DrawIcon(icon_file, 0, Vec2f(32,32), pos, 1);
}