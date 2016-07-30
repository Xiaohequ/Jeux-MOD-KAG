//
//Animation script for
//Greg

#include "Hitters.as";
#include "AnimalConsts.as";

const u8 DEFAULT_PERSONALITY = AGGRO_BIT;
const s16 MAD_TIME = 600;
const string chomp_tag = "chomping";

//sprite

void onInit(CSprite@ this)
{
    this.ReloadSprites(0,0); //always blue
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
    if (this.isAnimation("revive") && !this.isAnimationEnded()) return;
	if (this.isAnimation("bite") && !this.isAnimationEnded()) return;
    if (blob.getHealth() > 0.0)
    {
		f32 x = blob.getVelocity().x;
		
		if (this.isAnimation("dead"))
		{
			this.SetAnimation("revive");
		}
		else
		if( blob.hasTag(chomp_tag) && !this.isAnimation("bite"))
		{
			if (!this.isAnimation("bite")) {
			// this.PlaySound( "/GregRoar.ogg" );
			
			this.SetAnimation("bite");
			return;
			}
		}
		else
		if (Maths::Abs(x) > 0.1f)
		{
			if (!this.isAnimation("walk")) {
				this.SetAnimation("walk");
			}
		}
		else
		{
			if (XORRandom(200)==0)
			{
				this.PlaySound( "/GregRoar.ogg" );
			}
			if (!this.isAnimation("idle")) {
			this.SetAnimation("idle");
			}
		}
	}
	else 
	{
		if (!this.isAnimation("dead"))
		{
			this.SetAnimation("dead");
			this.PlaySound( "/GregCry.ogg" );
		}
		this.getCurrentScript().runFlags |= Script::remove_after_this;
	}
}

void onGib(CSprite@ this)
{
    if (g_kidssafe) {
        return;
    }

    CBlob@ blob = this.getBlob();
    Vec2f pos = blob.getPosition();
    Vec2f vel = blob.getVelocity();
	vel.y -= 3.0f;
    f32 hp = Maths::Min(Maths::Abs(blob.getHealth()), 2.0f) + 1.0;
	const u8 team = blob.getTeamNum();
    CParticle@ Body     = makeGibParticle( "GregGibs.png", pos, vel + getRandomVelocity( 90, hp , 80 ),       0, 0, Vec2f (8,8), 2.0f, 20, "/BodyGibFall", team );
    CParticle@ Arm1     = makeGibParticle( "GregGibs.png", pos, vel + getRandomVelocity( 90, hp - 0.2 , 80 ), 0, 1, Vec2f (8,8), 2.0f, 20, "/BodyGibFall", team );
    CParticle@ Arm2     = makeGibParticle( "GregGibs.png", pos, vel + getRandomVelocity( 90, hp - 0.2 , 80 ), 0, 2, Vec2f (8,8), 2.0f, 20, "/BodyGibFall", team );
    CParticle@ Shield   = makeGibParticle( "GregGibs.png", pos, vel + getRandomVelocity( 90, hp , 80 ),       0, 3, Vec2f (8,8), 2.0f, 0, "/BodyGibFall", team );
    CParticle@ Sword    = makeGibParticle( "GregGibs.png", pos, vel + getRandomVelocity( 90, hp + 1 , 80 ),   0, 4, Vec2f (8,8), 2.0f, 0, "/BodyGibFall", team );
	
}
