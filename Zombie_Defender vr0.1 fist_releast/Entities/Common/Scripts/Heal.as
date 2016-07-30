void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 1.5 * getTicksASecond();
}

void onTick(CBlob@ this)
{
	CBlob@[] blobsInRadius;
	if (getMap().getBlobsInRadius( this.getPosition(), 20, @blobsInRadius ))
	{
		if(blobsInRadius.length>0)
		{
			const u8 teamNum = this.getTeamNum();
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob @b = blobsInRadius[i];
				if (this.getTeamNum() == teamNum && b.getHealth() < b.getInitialHealth() && b.hasTag("flesh") && !b.hasTag("dead"))
				{								  
					b.server_Heal( 0.5f );
					b.getSprite().PlaySound( "/Heart.ogg" );
				}
			}
		}

	}
}
