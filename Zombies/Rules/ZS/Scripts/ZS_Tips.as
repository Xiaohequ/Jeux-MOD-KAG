//tips scripts

#define CLIENT_ONLY

const string[] tips = {
	"Tip: Hight score = fast respawn",
	"Tip: Kill zombie to boost your score",
	"Tip: More the zombie is hard to kill, more it has bonus score"
};

uint currentTip = 0;
Vec2f middle = Vec2f(getScreenWidth()/2, getScreenHeight()*0.75f );
Vec2f Tip_Pos = middle;
Vec2f dimTip = Vec2f(0,0);
bool canDraw = false;

void onPlayerDie( CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData )
{
	 if(victim !is null && victim is getLocalPlayer()){
		currentTip = XORRandom(tips.length);
		GUI::GetTextDimensions(tips[currentTip], dimTip);
		printf("dim text: " + dimTip.x + " , " + dimTip.y);
		Tip_Pos = middle + Vec2f(-dimTip.x/2,0);
		canDraw = true;
	 }
}

void onSetPlayer( CRules@ this, CBlob@ blob, CPlayer@ player )
{
	if(player !is null &&  player is getLocalPlayer()){
		canDraw = false;
	}
}

// void onTick( CRules@ this )
// {
	
	// if((!canDraw || (getGameTime() % (3*getTicksASecond())) != 0))
		// return;

	// if(!getNet().isServer())
		// return;
		
	// printf(" tick tack !!!!!!!!!!!!!!");
	// currentTip = XORRandom(tips.length);
// }

// render gui for the player
void onRender(CRules@ this)
{
	if( canDraw ){
		Vec2f pos = Tip_Pos + Vec2f(0,Maths::Sin(getGameTime() / 5.0f) * 5.0f);
		GUI::DrawText( "  " + tips[currentTip] + "\n", pos , pos + dimTip + Vec2f(20,20), SColor(255,112,43,0) , true , true , true );
	}
	
}