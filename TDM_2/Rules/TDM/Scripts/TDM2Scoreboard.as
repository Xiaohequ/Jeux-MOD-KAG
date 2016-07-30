
// set kills and deaths

void onBlobDie( CRules@ this, CBlob@ blob )
{
	if (blob !is null )
	{
		CPlayer@ killer = blob.getPlayerOfRecentDamage();
		CPlayer@ victim = blob.getPlayer();

		if (victim !is null)
		{
			victim.setDeaths(victim.getDeaths() + 1);
			
			if (killer !is null) //requires victim so that killing trees matters
			{
				if (killer.getTeamNum() != blob.getTeamNum())
				{
					killer.setKills(killer.getKills() + 1);
					
					if(isBestScorePlayer(victim)){
						killer.setScore(  killer.getScore() + 4 );
					}else{
						killer.setScore(  killer.getScore() + 2 );
					}
				}
			}
			
		}
	}
}

bool isBestScorePlayer(CPlayer@ player){
	int score = player.getScore();
	for(uint i = 0; i< getPlayerCount(); i++){
		CPlayer@ p = getPlayer(i);
		if(p.getScore() > score && p.getScore() > 0){
			return false;
		}
	}
	return true;
}
