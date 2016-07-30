#define CLIENT_ONLY

bool effect_played = false;

void onInit( CRules@ this )
{	
	effect_played = false;
}

void onRestart( CRules@ this )
{
	effect_played = false;
}

void onTick(CRules@ this)
{
	if(!getNet().isServer() && !effect_played && this.isMatchRunning()){
		effect_played= true;
		
 		CBlob@[] blobs;
		getBlobsByTag("infected", @blobs);
		
		if(blobs.length>0){
			CBlob@ blob = blobs[0];
			ParticleZombieLightning(blob.getPosition());
		}
	}
}

void onBlobCreated( CRules@ this, CBlob@ blob )
{
	printf("on blob created");
	if(this.isMatchRunning() && blob !is null && blob.hasTag("player") && blob.getTeamNum() == 1 ){
		blob.getSprite().PlaySound("Thunder");
		ParticleZombieLightning(blob.getPosition());
	}
}


