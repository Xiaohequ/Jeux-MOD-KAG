
//script for zombie boss
#include "Hitters.as";
#include "UndeadConsts.as";
#include "MakeScroll.as";

const u8 DEFAULT_PERSONALITY = AGGRO_BIT;
const s16 MAD_TIME = 600;
const string chomp_tag = "chomping";

//blob
void onInit(CBrain@ this)
{
	this.getCurrentScript().runFlags = Script::tick_not_attached;
}
void onInit(CBlob@ this)
{
	//for EatOthers
	string[] tags = {"hall","player","lantern"};
	this.set("tags to eat", tags);
	this.set_f32("gib health", -3.0f);	
	// float difficulty = getRules().get_f32("difficulty")/4.0;
	// if (difficulty<1.0) difficulty=1.0;
	this.set_f32("bite damage", 1.5f);
	// int bitefreq = 35-difficulty*5.0;
	// if (bitefreq<5) bitefreq=5;
	this.set_u16("bite freq", 30);
	
	//brain
	this.set_u8(personality_property, DEFAULT_PERSONALITY);
	this.set_u8("random move freq",4);
	this.set_f32(target_searchrad_property, 700.0f);
	this.set_f32(terr_rad_property, 185.0f);
	this.set_u8(target_lose_random,50);
	
	this.getBrain().server_SetActive( true );
	
	//for steaks
	//this.set_u8("number of steaks", 1);
	
	//for shape
	this.getShape().SetRotationsAllowed(false);
	
	
	this.Tag("flesh");
	this.Tag("zombie");
	this.set_s16("mad timer", 0);

	this.getShape().SetOffset(Vec2f(0,0));
	
//	this.getCurrentScript().runFlags = Script::tick_blob_in_proximity;
//	this.getCurrentScript().runProximityTag = "player";
//	this.getCurrentScript().runProximityRadius = 320.0f;
	this.getCurrentScript().runFlags = Script::tick_not_attached;
	
	Sound::Play( CFileMatcher("/ZombieBossGrowl.ogg").getFirst() );
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return false;
}

void onTick(CBlob@ this)
{
	f32 x = this.getVelocity().x;
		
	if (this.getHealth()<=0.0)
	{
		this.getShape().setFriction( 0.8f );
		this.getShape().setElasticity( 0.1f );		
	}

	if (this.getHealth()<0.0) return;
	
	float difficulty = getRules().get_f32("difficulty");
	int break_chance = 30 - 2*(difficulty-1.0);	
	if (break_chance<2) break_chance=2;

	if (getNet().isServer() && this.hasTag(chomp_tag))
	{
		if (this.getTeamNum() != -1) this.server_setTeamNum(-1);
		u16 lastbite = this.get_u16("lastbite");
		u16 bitefreq = this.get_u16("bite freq");
		if (bitefreq<0) bitefreq=15;
		if (lastbite > bitefreq)
		{
			float aimangle=0;
			if(this.get_u8(state_property) == MODE_TARGET )
			{
				CBlob@ b = getBlobByNetworkID(this.get_netid(target_property));
				Vec2f vel;
				if(b !is null)
				{
					vel = b.getPosition()-this.getPosition();
					
				}
				else vel = Vec2f(1,0);
				{
					vel.Normalize();
					HitInfo@[] hitInfos;
					CMap @map = getMap();
					if (map.getHitInfosFromArc( this.getPosition()- Vec2f(2,0).RotateBy(-vel.Angle()), -vel.Angle(), 90, this.getRadius() + 16.0f, this, @hitInfos ))
					{
						//HitInfo objects are sorted, first come closest hits
						bool hit_block = false;
						for (uint i = 0; i < hitInfos.length; i++)
						{
							HitInfo@ hi = hitInfos[i];
							CBlob@ other = hi.blob;	  
							if (other !is null)
							{
								if (other.hasTag("flesh") && other.getTeamNum() != this.getTeamNum())
								{
									f32 power = this.get_f32("bite damage");
									this.server_Hit(other,other.getPosition(),vel,power,Hitters::bite, false);
									this.set_u16("lastbite",0);
									break;
								}
								else if (!hit_block)
								{
									const bool large = other.hasTag("blocks sword") && other.isCollidable();
									
									if (other.getName() == "wooden_platform")
									{
										this.server_Hit(other,other.getPosition(),vel,0.2,Hitters::saw, false);
										this.set_u16("lastbite",0);
										hit_block=true;
									}
									//
									else
									{
										f32 power = this.get_f32("bite damage");
										if (!other.hasTag("flesh")) power=0.2;
										
										this.server_Hit(other,other.getPosition(),vel,power,Hitters::saw, false);
										if (other.getTeamNum() == this.getTeamNum() && getNet().isServer())
										{
											if (this.getHealth()+power<this.getInitialHealth()) this.server_SetHealth(this.getHealth()+power);
											else this.server_SetHealth(this.getInitialHealth());
										}
										this.set_u16("lastbite",0);
										if (!other.hasTag("flesh")) hit_block=true;
										if (other.hasTag("large")) break;
									}
									
									
								}
							}
							else
							{
								
								if ( hi.tile != CMap::tile_empty ) {		
									
									if (!this.getMap().isTileGroundStuff( hi.tile ))
									{
										//if (XORRandom(2) == 0) 
										{
											this.getMap().server_DestroyTile(hi.hitpos, 0.4);
											this.set_u16("lastbite",0);
										}
									}
									else
									{
										//if (XORRandom(2) == 0) 
										{
											this.getMap().server_DestroyTile(hi.hitpos, 0.5);
											this.set_u16("lastbite",0);
										}
									}
								}
								
							}
						}
					}
				}		
			}
		}
		else
		{
			this.set_u16("lastbite",this.get_u16("lastbite")+1);
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
			if(b !is null && XORRandom(2) == 0)
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

void onHitBlob( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData )
{
/*	if (hitBlob !is null)
	{
		Vec2f force = velocity * this.getMass() * 0.35f ;
		force.y -= 1.0f;
		hitBlob.AddForce( force);
	}*/
}
