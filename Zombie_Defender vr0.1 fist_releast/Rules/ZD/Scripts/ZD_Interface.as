
void onInit( CRules@ this )
{
}

void onRender( CRules@ this )
{
    CPlayer@ p = getLocalPlayer();

    if (p is null || !p.isMyPlayer()) { return; }
	
	if(!this.isWarmup()){
		//wave timer
		u16 wave_timer = this.get_u16("wave_timer");
		string draw_text = "";
		if(wave_timer >1){
			draw_text = "Next Wave start in " + wave_timer + " !";
		}else{
			draw_text = "Zombies is coming!!!";
		}

		GUI::DrawText(draw_text, Vec2f( getScreenWidth()/2 - 75, getScreenHeight()*0.2f + Maths::Sin(getGameTime() / 5.0f) * 5.0f ), SColor(255, 255, 255, 55));
	
		//text for respawn count down
		string propname = "Zombies spawn time "+p.getUsername();	
		if (p.getBlob() is null && this.exists(propname))
		{
			u8 spawn = this.get_u8(propname);

			if (spawn != 255)
			{
				GUI::DrawText( "Respawn in: "+spawn , Vec2f( getScreenWidth()/2 - 70, getScreenHeight()/3 + Maths::Sin(getGameTime() / 3.0f) * 5.0f ), SColor(255, 255, 255, 55) );
			}
		}
	}
	
	

}
