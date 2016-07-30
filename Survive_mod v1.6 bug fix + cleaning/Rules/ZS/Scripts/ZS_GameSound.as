//tips scripts

#define CLIENT_ONLY

bool sound_played = false;

void onInit( CRules@ this )
{	
	sound_played = false;
}

void onRestart( CRules@ this )
{
	sound_played = false;
}

void onTick(CRules@ this)
{
	if(!sound_played && this.isMatchRunning()){
		sound_played= true;
		
		Sound::Play("/ResearchComplete.ogg");
		
		Sound::Play("/Wilhelm.ogg");
		
		Sound::Play("/PortalBreach.ogg");
	}
}
