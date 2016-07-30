//Animation script
//for 
//Skeleton

#include "Hitters.as";
#include "AnimalConsts.as";

const u8 DEFAULT_PERSONALITY = AGGRO_BIT;
const s16 MAD_TIME = 600;
const string chomp_tag = "chomping";

//sprite

void onInit(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
    this.ReloadSprites(blob.getTeamNum(),0);
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	bool walking = (blob.isKeyPressed(key_left) || blob.isKeyPressed(key_right));
    if (!blob.hasTag("dead"))
    {
		if( blob.hasTag(chomp_tag) )
		{
			if (!this.isAnimation("bite")||(this.isAnimation("bite")&&this.isAnimationEnded())) {
				this.PlaySound( "/SkeletonAttack" );
				this.SetAnimation("bite");
			}
//			this.PlaySound( "/SkeletonSpawn1" );
			return;
		}
		//f32 x = blob.getVelocity().x;
		if( blob.get_s32("climb") > 1 ) 
		{
			//if (!this.isAnimation("climb")&& this.isAnimationEnded()) {
				this.SetAnimation("climb");
			//}
		}
		else if (walking)
        {
            this.SetAnimation("run");
        }
		else
		{
			if (XORRandom(200)==0 && !this.isAnimation("idle"))
			{
				this.SetAnimation("idle");
				this.PlaySound( "/SkeletonSayDuh" );
			}
		}
	}
	else 
	{
		if(this.animation.name != "dead")
		{
			this.PlaySound( "/SkeletonBreak1" );
			this.SetAnimation("dead");
			this.getCurrentScript().runFlags |= Script::remove_after_this;
		}
		this.PlaySound( "/SkeletonSayDuh" );
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
    CParticle@ Body     = makeGibParticle( "SkeletonGibs.png", pos, vel + getRandomVelocity( 90, hp , 80 ),       0, 0, Vec2f (8,8), 2.0f, 20, "/BodyGibFall", team );
    CParticle@ Arm1     = makeGibParticle( "SkeletonGibs.png", pos, vel + getRandomVelocity( 90, hp - 0.2 , 80 ), 0, 1, Vec2f (8,8), 2.0f, 20, "/BodyGibFall", team );
    CParticle@ Arm2     = makeGibParticle( "SkeletonGibs.png", pos, vel + getRandomVelocity( 90, hp - 0.2 , 80 ), 0, 2, Vec2f (8,8), 2.0f, 20, "/BodyGibFall", team );
    CParticle@ Shield   = makeGibParticle( "SkeletonGibs.png", pos, vel + getRandomVelocity( 90, hp , 80 ),       0, 3, Vec2f (8,8), 2.0f, 0, "/BodyGibFall", team );
    CParticle@ Sword    = makeGibParticle( "SkeletonGibs.png", pos, vel + getRandomVelocity( 90, hp + 1 , 80 ),   0, 4, Vec2f (8,8), 2.0f, 0, "/BodyGibFall", team );
}

