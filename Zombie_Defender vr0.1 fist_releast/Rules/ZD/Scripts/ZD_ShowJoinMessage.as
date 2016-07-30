#define CLIENT_ONLY

int TIME = 600;
int showTime = TIME;
float posY = 200.0f;

void onRestart( CRules@ this )
{
	showTime = TIME;
}

void onRender( CRules@ this )
{
	if (showTime > -60)
	{
		showTime-=2;
		Vec2f middle(getScreenWidth()/2.0f, showTime < posY ? showTime : posY );
		
		//gamemode info
		// const string name = this.gamemode_name;
		// const string info = this.gamemode_info;
		// const string servername = getNet().joined_servername;
		
		//build display strings
		string display = "    Welcome to GB's Zombie Defender server   \n    Defend hall from zombie's attack, \n    defeat 20 waves of zombie to Win \n     Have fun!  :D  " ;

		GUI::DrawText( display ,
			Vec2f(middle.x - 150.0f, middle.y), Vec2f(middle.x + 150.0f, middle.y+60.0f), color_black, true, true, true );
	}
}
