// scroll script that makes zombie turn into allies
//work with CanTame.as script

#include "Hitters.as";

const u32 TAME_TIME = 30; //second

void onInit( CBlob@ this )
{
	this.addCommandID( "tame" );
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	caller.CreateGenericButton( 11, Vec2f_zero, this, this.getCommandID("tame"), "Use this to make nearby enemies instantly turn into allies for a while.", params );
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("tame"))
	{
		if (!getNet().isServer())
		{
			ParticleZombieLightning( this.getPosition() ); 
		}
		bool hit = false;
		CBlob@ caller = getBlobByNetworkID( params.read_u16() );
		if (caller !is null)
		{
			const int team = caller.getTeamNum();
			CBlob@[] blobsInRadius;	   
			if (this.getMap().getBlobsInRadius( this.getPosition(), 100.0f, @blobsInRadius )) 
			{
				for (uint i = 0; i < blobsInRadius.length; i++)
				{
					CBlob @b = blobsInRadius[i];
					if (b.getTeamNum() != team && b.hasTag("flesh") && b.hasTag("zombie") && b.hasTag("can tame"))
					{
					
						ParticleZombieLightning( b.getPosition() );
						
						if (getNet().isServer())
						{
							b.server_setTeamNum(team);
							b.set_s32("taming time",getGameTime() + TAME_TIME*getTicksASecond());
						}
						
						//	caller.server_Hit( b, this.getPosition(), Vec2f(0,0), 10.0f, Hitters::suddengib, true );
						hit = true;
					}
				}
			}
		}

		if (hit)
		{
			this.server_Die();
			if (!getNet().isServer())
				Sound::Play( "SuddenGib.ogg" );
		}
	}
}