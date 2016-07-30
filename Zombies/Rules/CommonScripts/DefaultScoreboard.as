
// set kills and deaths

void onBlobDie( CRules@ this, CBlob@ blob )
{
	if (blob !is null )
	{
 		if(blob.hasTag("zombie")){	//todo: add different zombie for different score bonus
			u8 bonus_score = 2;
			if(blob.exists("bonus score")){
				bonus_score = blob.get_u8("bonus score");
			}
			CPlayer@ killer = blob.getPlayerOfRecentDamage();
			if (killer !is null)
			{
				if (killer.getTeamNum() != blob.getTeamNum())
				{
					killer.setKills(killer.getKills() + 1);
					// temporary until we have a proper score system
					// killer.setScore(  (f32(killer.getKills()) - f32(killer.getDeaths()*10)) );
					killer.setScore(  killer.getScore() + bonus_score );
				}
			}
		}
		else if(blob.getName( ) == "ZombiePortal"){
			CPlayer@ killer = blob.getPlayerOfRecentDamage();
			if (killer !is null)
			{
				if (killer.getTeamNum() != blob.getTeamNum())
				{
					killer.setKills(killer.getKills() + 1);
					// temporary until we have a proper score system
					// killer.setScore(  (f32(killer.getKills()) - f32(killer.getDeaths()*10)) );
					killer.setScore(  killer.getScore() + 50 );
				}
			}
		}
		else
		{ 
			CPlayer@ killer = blob.getPlayerOfRecentDamage();
			CPlayer@ victim = blob.getPlayer();

			if (victim !is null)
			{
				victim.setDeaths(victim.getDeaths() + 1);
				// temporary until we have a proper score system
				// victim.setScore(  100 * (f32(victim.getKills()) / f32(victim.getDeaths()+1)) );
				victim.setScore( victim.getScore()-10 );
				
				if (killer !is null) //requires victim so that killing trees matters
				{
					if (killer.getTeamNum() != blob.getTeamNum())
					{
						killer.setKills(killer.getKills() + 1);
						// temporary until we have a proper score system
						// killer.setScore(  100 * (f32(killer.getKills()) / f32(killer.getDeaths()+1)) );
						killer.setScore(  killer.getScore()+10 );
					}
				}
				
			}
		}
	}
}
