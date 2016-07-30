#include "Hitters.as";
#include "AnimalConsts.as";
#include "MakeScroll.as";

const u8 DEFAULT_PERSONALITY = AGGRO_BIT;
const s16 MAD_TIME = 600;

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	if (blob.hasTag("dead")) return false;
	if (!blob.hasTag("zombie") && blob.hasTag("flesh") && this.getTeamNum() == blob.getTeamNum()) return false;
	if (blob.hasTag("zombie") && blob.getHealth()<0.0) return false;
	return true;
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1 )
{
	if (this.getHealth() <= 0.0 || blob is null) return; // dead

	if (blob.getTeamNum() != this.getTeamNum() && blob.hasTag("flesh") && !blob.hasTag("dead"))
	{
		MadAt( this, blob );
	}
}

void MadAt( CBlob@ this, CBlob@ hitterBlob )
{
	const u16 damageOwnerId = (hitterBlob.getDamageOwnerPlayer() !is null && hitterBlob.getDamageOwnerPlayer().getBlob() !is null) ? 
		hitterBlob.getDamageOwnerPlayer().getBlob().getNetworkID() : 0;

	this.set_s16("mad timer", MAD_TIME);
	this.set_u8(personality_property, DEFAULT_PERSONALITY | AGGRO_BIT);
	this.set_u8(state_property, MODE_TARGET);
	if (hitterBlob.hasTag("player"))
		this.set_netid(target_property, hitterBlob.getNetworkID() );
	else
		if (damageOwnerId > 0) {
			this.set_netid(target_property, damageOwnerId );
		}
}

 
f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{		
	MadAt( this, hitterBlob );
	
	// if (customData == Hitters::arrow) damage*=2.0;
	
	if (this.getHealth()>0 && this.getHealth() <= damage)
	{
		if (getNet().isServer())
		this.set_u16("death ticks",this.getTickSinceCreated());
		this.Sync("death ticks",true);
	}
	
    this.Damage( damage, hitterBlob );
    // Gib if health below gibHealth
    f32 gibHealth = getGibHealth( this );
	
	//printf("ON HIT " + damage + " he " + this.getHealth() + " g " + gibHealth );
    // blob server_Die()() and then gib

	
	//printf("gibHealth " + gibHealth + " health " + this.getHealth() );
    if (this.getHealth() <= gibHealth)
    {
        this.getSprite().Gib();
		//drop coins
		u16 coins = 10;
		if(this.exists("drop coins")){
			coins = this.get_u16("drop coins");
		}
		
		if(this.getName() == "zombieKnight"){
			if (getNet().isServer())
			{
				int r = XORRandom(80);
				if (r<3 && getRules().get_bool("scrolls_spawn"))
				{
					if (r == 0)
						server_MakePredefinedScroll( hitterBlob.getPosition() + Vec2f(0,-3.0f), "carnage" );
					else
					if (r == 1)
						server_MakePredefinedScroll( hitterBlob.getPosition() + Vec2f(0,-3.0f), "midas" );				
					else
					if (r == 2)
						server_MakePredefinedScroll( hitterBlob.getPosition() + Vec2f(0,-3.0f), "tame" );				
				}
			}
		}
		
		server_DropCoins(this.getPosition() + Vec2f(0,-3.0f), coins);
		
        this.server_Die();
    }
		
    return 0.0f; //done, we've used all the damage	
	
}

f32 getGibHealth( CBlob@ this )
{
    if (this.exists("gib health")) {
        return this.get_f32("gib health");
    }

    return 0.0f;
}
