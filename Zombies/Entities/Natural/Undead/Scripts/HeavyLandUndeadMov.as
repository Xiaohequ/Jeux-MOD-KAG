//script for undead movement

#define SERVER_ONLY

#include "Hitters.as";
#include "UndeadConsts.as";

//blob
void onInit(CBlob@ this)
{
	UndeadVars vars;
	//walking vars
	vars.walkForce.Set(4.5f,0.0f);
	vars.runForce.Set(6.0f,0.0f);
	vars.slowForce.Set(1.0f,0.0f);
	vars.jumpForce.Set(0.0f,-2.2f);
	vars.maxVelocity = 3.0f;
	this.set( "vars", vars );

	// force no team
	this.server_setTeamNum(-1);

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag	= "dead";
}

//movement
void onInit( CMovement@ this )
{
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag	= "dead";   
}

void onTick( CMovement@ this )
{
    CBlob@ blob = this.getBlob();

	UndeadVars@ vars;
	if (!blob.get( "vars", @vars ))
		return;
	if (blob.getHealth() <= 0.0) return; // dead
	const bool left = blob.isKeyPressed(key_left);
	const bool right = blob.isKeyPressed(key_right);
	bool up = blob.isKeyPressed(key_up);

	Vec2f vel = blob.getVelocity();
	if (left) {
		blob.AddForce(Vec2f( -1.0f * vars.walkForce.x, vars.walkForce.y));
	}
	if (right) {
		blob.AddForce(Vec2f( 1.0f * vars.walkForce.x, vars.walkForce.y));
	}
	
	// jump at target

	CBrain@ brain = blob.getBrain();
	if (brain !is null)
	{	 
		CBlob@ target = brain.getTarget();
		if (target !is null)
		{	 
			if ((target.getPosition() - blob.getPosition()).getLength() < blob.getRadius()*2.0f && target.getPosition().y < blob.getPosition().y - blob.getRadius() ) 
			{
				up = true;
			}
		}
	}

	// jump if blocked

	if (left || right || up)
	{
		Vec2f pos = blob.getPosition();
		CMap@ map = blob.getMap();
		const f32 radius = blob.getRadius();
		bool rightsolid = map.isTileSolid( Vec2f( pos.x + (radius+1.0f), pos.y )) ;
		bool leftsolid = map.isTileSolid( Vec2f( pos.x - (radius+1.0f), pos.y ));
		if ((blob.isOnGround() || blob.isInWater()) && (up || (right && rightsolid) || (left && leftsolid)))
		{ 
			f32 mod = blob.isInWater() ? 0.23f : 1.0f;
			blob.AddForce(Vec2f( mod*vars.jumpForce.x * blob.getMass(), mod*vars.jumpForce.y * blob.getMass()));
		}
	}

	CShape@ shape = blob.getShape();

	// too fast - slow down
	if (shape.vellen > vars.maxVelocity)
	{		  
		Vec2f vel = blob.getVelocity();
		blob.AddForce( Vec2f(-vel.x * vars.slowForce.x, -vel.y * vars.slowForce.y) );
	}
}
