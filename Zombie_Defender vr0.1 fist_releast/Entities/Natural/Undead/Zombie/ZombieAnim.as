
//script for a bison

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
		if( blob.get_s32("climb") > 1 ) 
		{
			if (!this.isAnimation("climb")) {
				this.SetAnimation("climb");
			}
		}
		else
		if( blob.hasTag(chomp_tag) && !this.isAnimation("bite"))
		{
			if (!this.isAnimation("bite")) {
			this.PlaySound( "/ZombieBite" );
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
				this.PlaySound( "/ZombieGroan" );
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
			this.PlaySound( "/ZombieDie" );
			blob.getShape().setFriction( 0.75f );
			blob.getShape().setElasticity( 0.2f );					
		}
//		this.getCurrentScript().runFlags |= Script::remove_after_this;
	}
}

void onRender(CSprite@ this)
{
	if (getLocalPlayer().getUsername() == "Eanmig" && getRules().get_bool("target lines"))
	{
		CBlob@ blob = this.getBlob();
		if(blob.get_u8(state_property) == MODE_TARGET )
		{
			CBlob@ b = getBlobByNetworkID(blob.get_netid(target_property));
			if (b !is null)
			{
				Vec2f mypos = getDriver().getScreenPosFromWorldPos(blob.getPosition());
				Vec2f targetpos = getDriver().getScreenPosFromWorldPos(b.getPosition());
				GUI::DrawArrow2D( mypos,targetpos , SColor(0xffdd2212) );
			}
		}
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
    CParticle@ Body     = makeGibParticle( "ZombieGibs.png", pos, vel + getRandomVelocity( 90, hp , 80 ),       1, 0, Vec2f (8,8), 2.0f, 20, "/BodyGibFall", team );
    CParticle@ Arm1     = makeGibParticle( "ZombieGibs.png", pos, vel + getRandomVelocity( 90, hp - 0.2 , 80 ), 1, 1, Vec2f (8,8), 2.0f, 20, "/BodyGibFall", team );
    CParticle@ Arm2     = makeGibParticle( "ZombieGibs.png", pos, vel + getRandomVelocity( 90, hp - 0.2 , 80 ), 1, 2, Vec2f (8,8), 2.0f, 20, "/BodyGibFall", team );
    CParticle@ Shield   = makeGibParticle( "ZombieGibs.png", pos, vel + getRandomVelocity( 90, hp , 80 ),       1, 3, Vec2f (8,8), 2.0f, 0, "/BodyGibFall", team );
    CParticle@ Sword    = makeGibParticle( "ZombieGibs.png", pos, vel + getRandomVelocity( 90, hp + 1 , 80 ),   1, 4, Vec2f (8,8), 2.0f, 0, "/BodyGibFall", team );
}


