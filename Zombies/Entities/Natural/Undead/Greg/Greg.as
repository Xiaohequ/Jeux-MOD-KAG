//
//script for
//Greg

#include "Hitters.as";
#include "UndeadConsts.as";

const u8 DEFAULT_PERSONALITY = AGGRO_BIT;
const s16 MAD_TIME = 600;
const string chomp_tag = "chomping";

//blob
void onInit(CBrain@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_attached;
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().runFlags = 0;
}
void onInit(CBlob@ this)
{
	//for EatOthers
	string[] tags = {"player"};
	this.set_u16("drop coins", 30);
	this.set("tags to eat", tags);
	
	this.set_f32("bite damage", 0.125f);
	
	//brain
	this.set_u8(personality_property, DEFAULT_PERSONALITY);
	this.set_u8("random move freq",20);
	this.set_f32(target_searchrad_property, 700.0f);
	this.set_f32(terr_rad_property, 185.0f);
	this.set_u8(target_lose_random,50);
	
	this.getBrain().server_SetActive( true );
	
	//for steaks
	//this.set_u8("number of steaks", 1);
	
	//for shape
	this.getShape().SetRotationsAllowed(false);
	
	//for flesh hit
	this.set_f32("gib health", -0.0f);
	
	this.Tag("flesh");
	this.Tag("zombie");
	this.Tag("Greg");
	this.set_s16("mad timer", 0);

//	this.getShape().SetOffset(Vec2f(0,8));
	
//	this.getCurrentScript().runFlags = Script::tick_blob_in_proximity;
//	this.getCurrentScript().runProximityTag = "player";
//	this.getCurrentScript().runProximityRadius = 320.0f;
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().runFlags |= Script::tick_attached;
	this.getCurrentScript().runFlags = 0;
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return this.getTeamNum() == byBlob.getTeamNum();
}

void onTick(CBlob@ this)
{
	f32 x = this.getVelocity().x;
	if (this.hasAttached())
	{
		Vec2f pos = this.getPosition();
		CMap@ map = this.getMap();
		const f32 radius = this.getRadius();
		
		f32 x = pos.x;
		Vec2f top = Vec2f(x, map.tilesize);
		Vec2f bottom = Vec2f(x, map.tilemapheight * map.tilesize);
		Vec2f end;
		
		if (map.rayCastSolid(top,bottom,end))
		{
			f32 y = end.y;
			
			if (y-pos.y>200 && XORRandom(20)==0)
			{	
				this.server_DetachAll();
			}
		}
	}
	
	if (getGameTime() % 5 == 0 && (XORRandom(20)==0))
	{	
		string name = this.getName();
		CBlob@[] blobs;
		this.getMap().getBlobsInRadius( this.getPosition(), 16.0, @blobs );
		for (uint step = 0; step < blobs.length; ++step)
		{
			//TODO: sort on proximity? done by engine?
			CBlob@ other = blobs[step];
			if (other is this) continue; //lets not run away from / try to eat ourselves...
		
			if (other.getName() == "lantern" || other.getName() == "wooden_door")
			{
				Vec2f vel(0,0);
				//this.server_Hit(other,other.getPosition(),vel,0.2,Hitters::saw, false);
			}
		}	
	}

	if (Maths::Abs(x) > 1.0f)
	{
		this.SetFacingLeft( x < 0 );
	}
	else
	{
		if (this.isKeyPressed(key_left)) {
			this.SetFacingLeft( true );
		}
		if (this.isKeyPressed(key_right)) {
			this.SetFacingLeft( false );
		}
	}

	// relax the madness

	if (getGameTime() % 65 == 0)
	{
		s16 mad = this.get_s16("mad timer");
		if (mad > 0)
		{
			mad -= 65;
			if (mad < 0 ) {
				this.set_u8(personality_property, DEFAULT_PERSONALITY);
//				this.getSprite().PlaySound("/BisonBoo");
			}
			this.set_s16("mad timer", mad);
		}

//		if (XORRandom(mad > 0 ? 3 : 12) == 0)
//			this.getSprite().PlaySound("/BisonBoo");
	}

	// footsteps

	if (this.isOnGround() && (this.isKeyPressed(key_left) || this.isKeyPressed(key_right)) )
	{
		if (XORRandom(20)==0)
		{
			Vec2f tp = this.getPosition() + (Vec2f( XORRandom(16)-8, XORRandom(16)-8 )/8.0)*(this.getRadius() + 4.0f);
			TileType tile = this.getMap().getTile( tp ).type;
			if ( this.getMap().isTileWood( tile ) ) {		
			//this.getMap().server_DestroyTile(tp, 0.1);
			}
		}	
		if (this.isKeyPressed(key_right))
		{
			TileType tile = this.getMap().getTile( this.getPosition() + Vec2f( this.getRadius() + 4.0f, 0.0f )).type;
			if (this.getMap().isTileCastle( tile )) {		
			//this.getMap().server_DestroyTile(this.getPosition() + Vec2f( this.getRadius() + 4.0f, 0.0f ), 0.1);
			}
		}
		if ((this.getNetworkID() + getGameTime()) % 9 == 0)
		{
			f32 volume = Maths::Min( 0.1f + Maths::Abs(this.getVelocity().x)*0.1f, 1.0f );
			TileType tile = this.getMap().getTile( this.getPosition() + Vec2f( 0.0f, this.getRadius() + 4.0f )).type;

			if (this.getMap().isTileGroundStuff( tile )) {
				this.getSprite().PlaySound("/EarthStep", volume, 0.75f );
			}
			else {
				this.getSprite().PlaySound("/StoneStep", volume, 0.75f );
			}
		}
	}
	
	if(getNet().isServer() && getGameTime() % 10 == 0)
	{
		if(this.get_u8(state_property) == MODE_TARGET )
		{
			CBlob@ b = getBlobByNetworkID(this.get_netid(target_property));
			if(b !is null && this.getDistanceTo(b) < 106.0f)
			{
				this.Tag(chomp_tag);
			}
			else
			{
				this.Untag(chomp_tag);
			}
		}
		else
		{
			this.Untag(chomp_tag);
		}
		this.Sync(chomp_tag,true);
	}
	
}

void MadAt( CBlob@ this, CBlob@ hitterBlob )
{
	const u16 damageOwnerId = (hitterBlob.getDamageOwnerPlayer() !is null && hitterBlob.getDamageOwnerPlayer().getBlob() !is null) ? 
		hitterBlob.getDamageOwnerPlayer().getBlob().getNetworkID() : 0;

/* 	const u16 friendId = this.get_netid(friend_property);
	if (friendId == hitterBlob.getNetworkID() || friendId == damageOwnerId) // unfriend
		this.set_netid(friend_property, 0);
	else // now I'm mad!
	{ */
//		if (this.get_s16("mad timer") <= MAD_TIME/8)
//			this.getSprite().PlaySound("/BisonMad");
	this.set_s16("mad timer", MAD_TIME);
	this.set_u8(personality_property, DEFAULT_PERSONALITY | AGGRO_BIT);
	this.set_u8(state_property, MODE_TARGET);
	if (hitterBlob.hasTag("player"))
		this.set_netid(target_property, hitterBlob.getNetworkID() );
	else
		if (damageOwnerId > 0) {
			this.set_netid(target_property, damageOwnerId );
		}
	// }
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{	
	if (customData == Hitters::arrow) damage*=2.0;
	MadAt( this, hitterBlob );
    this.Damage( damage, hitterBlob );
    // Gib if health below gibHealth
    f32 gibHealth = getGibHealth( this );
    if (this.getHealth() <= gibHealth)
    {
        this.getSprite().Gib();
		//drop coins
		u16 coins = 10;
		if(this.exists("drop coins")){
			coins = this.get_u16("drop coins");
		}
		
		server_DropCoins(this.getPosition() + Vec2f(0,-3.0f), coins);
		
        this.server_Die();
    }
	return 0.0f;
}							

f32 getGibHealth( CBlob@ this )
{
    if (this.exists("gib health")) {
        return this.get_f32("gib health");
    }

    return 0.0f;
}							

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	if (blob.hasTag("dead"))
		return false;
	return true;
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1 )
{
	if (this.getHealth() <= 0.0 || blob is null) return; // dead

	const u16 friendId = this.get_netid(friend_property);
	CBlob@ friend = getBlobByNetworkID(friendId);
	if ((friend is null || blob.getTeamNum() != friend.getTeamNum()) && blob.getName() != this.getName() && blob.hasTag("flesh") && !blob.hasTag("dead") && blob.getName() != "Wraith" && blob.getName() != "zombieBoss"&& !blob.isAttached())
	{
		const f32 vellen = this.getShape().vellen;
		f32 power = this.get_f32("bite damage");
		if (vellen > 0.1f)
		{
			Vec2f pos = this.getPosition();
			Vec2f vel = this.getVelocity();
			Vec2f other_pos = blob.getPosition();
			Vec2f direction = other_pos - pos;		
			direction.Normalize();
			vel.Normalize();
			//if (vel * direction > 0.33f)
			if (getNet().isServer() && XORRandom(4)==0)
			{
				//f32 power = Maths::Max( 0.25f, 1.0f*vellen );
				//this.server_Hit( blob, point1, vel, power, Hitters::bite, false);
				this.server_AttachTo(blob,"PICKUP");
				//this.getShape().getConsts().collideWhenAttached = true;
				//blob.getShape().getConsts().collideWhenAttached = true;
			}
		}	

		MadAt( this, blob );
	}
}

void onHitBlob( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData )
{
	if (hitBlob !is null && customData == Hitters::flying)
	{
		Vec2f force = velocity * this.getMass() * 0.35f ;
		force.y -= 7.0f;
		hitBlob.AddForce( force);
	}
}

